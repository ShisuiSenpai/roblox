-- Dual Crate System (Server Script)
-- Place this Script in ServerScriptService
-- Manages both Regular (Yen) and Premium (Robux) crate purchases

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

print("[DUAL CRATE] Loading system...")

-- ========================================
-- CONFIGURATION
-- ========================================

local CRATE_CONFIG = {
	Regular = {
		Cost = 250,
		CostType = "Currency", -- Uses Yen
		ProximityText = "Regular Relic | ¥250",
		UseStandardRarities = true,
	},
	Premium = {
		Cost = 99, -- Robux price
		ProductId = 0, -- ⚠️ USER MUST SET THIS! Create a Developer Product
		CostType = "Robux", -- Uses Robux via Developer Product
		ProximityText = "Premium Relic ✨ 2x LUCK | 99 R$",
		UseStandardRarities = false, -- Premium uses ONLY high-tier drops
		PremiumRarities = {
			-- Only Legendary, Godly, and ???
			{name = "Legendary", weight = 55}, -- 55%
			{name = "Godly", weight = 40},     -- 40%
			{name = "???", weight = 5},        -- 5%
		},
	},
}

-- ========================================
-- WORKSPACE SETUP
-- ========================================

local lobby = workspace:WaitForChild("Lobby", 10)
if not lobby then
	error("[DUAL CRATE] Lobby not found in Workspace!")
end

-- Find Normal Crate
local normalCrate = lobby:WaitForChild("NormalCrate", 10)
if not normalCrate then
	error("[DUAL CRATE] NormalCrate not found in Lobby!")
end

local normalPart = normalCrate:WaitForChild("NormalPart", 10)
if not normalPart then
	error("[DUAL CRATE] NormalPart not found in NormalCrate!")
end

local normalPrompt = normalPart:WaitForChild("OpenNormalCrate", 10)
if not normalPrompt or not normalPrompt:IsA("ProximityPrompt") then
	error("[DUAL CRATE] OpenNormalCrate ProximityPrompt not found in NormalPart!")
end

-- Find Premium Crate
local premiumCrate = lobby:WaitForChild("PremiumCrate", 10)
if not premiumCrate then
	error("[DUAL CRATE] PremiumCrate not found in Lobby!")
end

local premiumPart = premiumCrate:WaitForChild("PremiumPart", 10)
if not premiumPart then
	error("[DUAL CRATE] PremiumPart not found in PremiumCrate!")
end

local premiumPrompt = premiumPart:WaitForChild("OpenPremiumCrate", 10)
if not premiumPrompt or not premiumPrompt:IsA("ProximityPrompt") then
	error("[DUAL CRATE] OpenPremiumCrate ProximityPrompt not found in PremiumPart!")
end

print("[DUAL CRATE] Found both crates in Lobby")

-- ========================================
-- CONFIGURE PROXIMITY PROMPTS
-- ========================================

-- Normal Crate Prompt
normalPrompt.ActionText = "Open"
normalPrompt.ObjectText = CRATE_CONFIG.Regular.ProximityText
normalPrompt.HoldDuration = 0
normalPrompt.MaxActivationDistance = 10
normalPrompt.RequiresLineOfSight = false
normalPrompt.ClickablePrompt = true

-- Premium Crate Prompt
premiumPrompt.ActionText = "Open"
premiumPrompt.ObjectText = CRATE_CONFIG.Premium.ProximityText
premiumPrompt.HoldDuration = 0
premiumPrompt.MaxActivationDistance = 10
premiumPrompt.RequiresLineOfSight = false
premiumPrompt.ClickablePrompt = true

print("[DUAL CRATE] Proximity prompts configured")

-- ========================================
-- REMOTE EVENTS SETUP
-- ========================================

-- Keep existing OpenCrate event for animation/reward
local openCrateEvent = ReplicatedStorage:WaitForChild("OpenCrate", 10)
if not openCrateEvent then
	warn("[DUAL CRATE] OpenCrate RemoteEvent not found!")
end

print("[DUAL CRATE] Remote events ready")

-- ========================================
-- WAIT FOR DEPENDENCIES
-- ========================================

-- Wait for InventoryManager
while not _G.InventoryManager do
	warn("[DUAL CRATE] Waiting for InventoryManager...")
	task.wait(1)
end

-- Wait for CurrencyManager
while not _G.CurrencyManager do
	warn("[DUAL CRATE] Waiting for CurrencyManager...")
	task.wait(1)
end

print("[DUAL CRATE] Dependencies loaded")

-- ========================================
-- DATA & STATE
-- ========================================

local playersOpening = {} -- Track who is opening crates
local pendingPurchases = {} -- Track pending Robux purchases

-- ========================================
-- CRATE LOGIC (Rarity System)
-- ========================================

local function chooseRandomSword(crateType)
	local crateConfig = CRATE_CONFIG[crateType]
	local rarities
	
	-- Check if this crate uses premium rarities (only high-tier)
	if crateConfig and not crateConfig.UseStandardRarities and crateConfig.PremiumRarities then
		-- Premium Crate: Only Legendary, Godly, ???
		rarities = crateConfig.PremiumRarities
		print("[DUAL CRATE] Using PREMIUM rarities (Legendary/Godly/??? only)")
	else
		-- Regular Crate: Standard drop table
		rarities = {
			{name = "Common", weight = 100},
			{name = "Uncommon", weight = 50},
			{name = "Rare", weight = 25},
			{name = "Legendary", weight = 8},
			{name = "Godly", weight = 2},
			{name = "???", weight = 0.5},
		}
	end
	
	-- Calculate total weight
	local totalWeight = 0
	for _, rarity in ipairs(rarities) do
		totalWeight = totalWeight + rarity.weight
	end
	
	-- Select random rarity
	local roll = math.random() * totalWeight
	local cumulative = 0
	local selectedRarity = "Common"
	
	for _, rarity in ipairs(rarities) do
		cumulative = cumulative + rarity.weight
		if roll <= cumulative then
			selectedRarity = rarity.name
			break
		end
	end
	
	print("[DUAL CRATE] Selected rarity:", selectedRarity, "from", crateType, "crate (Roll:", string.format("%.2f", roll), "/ Total:", totalWeight, ")")
	
	-- Get sword by rarity
	local swordsByRarity = _G.InventoryManager.getSwordsByRarity(selectedRarity)
	
	if #swordsByRarity == 0 then
		warn("[DUAL CRATE] No swords found for rarity:", selectedRarity)
		return nil
	end
	
	local randomSword = swordsByRarity[math.random(1, #swordsByRarity)]
	print("[DUAL CRATE] Chosen sword:", randomSword.SwordName, "(", selectedRarity, ")")
	
	return randomSword
end

-- ========================================
-- REGULAR CRATE (YEN)
-- ========================================

local function openRegularCrate(player)
	-- Prevent spam
	if playersOpening[player.UserId] then
		warn("[DUAL CRATE]", player.Name, "is already opening a crate!")
		return
	end
	
	-- Check currency
	local playerCurrency = _G.CurrencyManager.getCurrency(player)
	if not playerCurrency or playerCurrency < CRATE_CONFIG.Regular.Cost then
		warn("[DUAL CRATE]", player.Name, "doesn't have enough Yen! Has:", playerCurrency, "Need:", CRATE_CONFIG.Regular.Cost)
		return
	end
	
	-- Deduct currency
	local success = _G.CurrencyManager.removeCurrency(player, CRATE_CONFIG.Regular.Cost, "Regular Crate Purchase")
	if not success then
		warn("[DUAL CRATE]", player.Name, "currency deduction failed!")
		return
	end
	
	-- Mark as opening
	playersOpening[player.UserId] = true
	print("[DUAL CRATE]", player.Name, "opening REGULAR crate for", CRATE_CONFIG.Regular.Cost, "Yen")
	
	-- Choose random sword (Regular odds)
	local chosenSword = chooseRandomSword("Regular")
	if not chosenSword then
		warn("[DUAL CRATE] Failed to choose sword for", player.Name)
		playersOpening[player.UserId] = nil
		-- Refund
		_G.CurrencyManager.addCurrency(player, CRATE_CONFIG.Regular.Cost, "Crate Failed - Refund")
		return
	end
	
	-- Trigger client-side animation
	if openCrateEvent then
		openCrateEvent:FireClient(player, chosenSword.SwordName)
	end
	
	-- Wait for animation
	task.wait(2)
	
	-- Award sword
	local addSuccess = _G.InventoryManager.addSword(player, chosenSword.SwordName)
	if addSuccess then
		print("[DUAL CRATE]", player.Name, "received:", chosenSword.SwordName)
	else
		warn("[DUAL CRATE] Failed to add sword to", player.Name, "'s inventory!")
	end
	
	-- Unlock
	playersOpening[player.UserId] = nil
end

-- ========================================
-- PREMIUM CRATE (ROBUX)
-- ========================================

local function openPremiumCrate(player)
	-- Prevent spam
	if playersOpening[player.UserId] or pendingPurchases[player.UserId] then
		warn("[DUAL CRATE]", player.Name, "is already opening a crate or has a pending purchase!")
		return
	end
	
	-- Check if ProductId is configured
	if CRATE_CONFIG.Premium.ProductId == 0 then
		warn("[DUAL CRATE] Premium Crate ProductId not configured! Please set it in DualCrateSystem.lua")
		return
	end
	
	-- Mark as pending purchase
	pendingPurchases[player.UserId] = true
	print("[DUAL CRATE]", player.Name, "initiating PREMIUM crate purchase for", CRATE_CONFIG.Premium.Cost, "Robux")
	
	-- Prompt Robux purchase
	local success, errorMsg = pcall(function()
		MarketplaceService:PromptProductPurchase(player, CRATE_CONFIG.Premium.ProductId)
	end)
	
	if not success then
		warn("[DUAL CRATE] Failed to prompt purchase for", player.Name, ":", errorMsg)
		pendingPurchases[player.UserId] = nil
	end
end

-- ========================================
-- ROBUX PURCHASE RECEIPT (MarketplaceService)
-- ========================================

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	
	-- Check if it's our Premium Crate product
	if productId ~= CRATE_CONFIG.Premium.ProductId then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	print("[DUAL CRATE] Processing Premium Crate purchase for UserId:", userId)
	
	local player = Players:GetPlayerByUserId(userId)
	
	-- Clear pending purchase
	pendingPurchases[userId] = nil
	
	-- If player left, still process the receipt
	if not player then
		warn("[DUAL CRATE] Player left before purchase completed. Awarding sword on next join...")
		-- TODO: Could save pending reward in DataStore for next join
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	-- Mark as opening
	playersOpening[userId] = true
	
	-- Choose random sword (Premium odds - better!)
	local chosenSword = chooseRandomSword("Premium")
	if not chosenSword then
		warn("[DUAL CRATE] Failed to choose sword for", player.Name)
		playersOpening[userId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Trigger client-side animation
	if openCrateEvent then
		openCrateEvent:FireClient(player, chosenSword.SwordName)
	end
	
	-- Wait for animation
	task.wait(2)
	
	-- Award sword
	local addSuccess = _G.InventoryManager.addSword(player, chosenSword.SwordName)
	if addSuccess then
		print("[DUAL CRATE]", player.Name, "received (PREMIUM):", chosenSword.SwordName)
	else
		warn("[DUAL CRATE] Failed to add sword to", player.Name, "'s inventory!")
		playersOpening[userId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Unlock
	playersOpening[userId] = nil
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- ========================================
-- PROXIMITY PROMPT HANDLERS
-- ========================================

-- Normal Crate
normalPrompt.Triggered:Connect(function(player)
	if not player or not player.Parent then return end
	openRegularCrate(player)
end)

-- Premium Crate
premiumPrompt.Triggered:Connect(function(player)
	if not player or not player.Parent then return end
	openPremiumCrate(player)
end)

-- ========================================
-- CLEANUP
-- ========================================

Players.PlayerRemoving:Connect(function(player)
	playersOpening[player.UserId] = nil
	pendingPurchases[player.UserId] = nil
end)

print("[DUAL CRATE] System ready! ✅")
print("[DUAL CRATE] Regular Crate: ¥" .. CRATE_CONFIG.Regular.Cost .. " | Premium Crate: " .. CRATE_CONFIG.Premium.Cost .. " R$")

if CRATE_CONFIG.Premium.ProductId == 0 then
	warn("⚠️ [DUAL CRATE] Premium Crate ProductId not set! Create a Developer Product and paste the ID on line ~26")
end
