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
		RarityMultipliers = {
			["Common"] = 1.0,
			["Uncommon"] = 1.0,
			["Rare"] = 1.0,
			["Legendary"] = 1.0,
			["Godly"] = 1.0,
			["???"] = 1.0,
		},
	},
	Premium = {
		Cost = 99, -- Robux price
		ProductId = 0, -- ⚠️ USER MUST SET THIS! See SETUP_INSTRUCTIONS.md
		CostType = "Robux", -- Uses Robux via Developer Product
		RarityMultipliers = {
			["Common"] = 0.5,     -- Less common drops
			["Uncommon"] = 0.7,   -- Slightly less uncommon
			["Rare"] = 1.2,       -- 20% better chance
			["Legendary"] = 2.0,  -- 2x better chance
			["Godly"] = 3.0,      -- 3x better chance
			["???"] = 2.5,        -- 2.5x better chance
		},
	},
}

-- ========================================
-- WORKSPACE SETUP (Single Proximity Prompt)
-- ========================================

local crateTemple = workspace:WaitForChild("CrateTemple", 10)
if not crateTemple then
	error("[DUAL CRATE] CrateTemple not found in Workspace!")
end

local cratePart = crateTemple:WaitForChild("OpenCratePart", 10)
if not cratePart then
	error("[DUAL CRATE] OpenCratePart not found in CrateTemple!")
end

-- Get or create proximity prompt
local cratePrompt = cratePart:FindFirstChildOfClass("ProximityPrompt")
if not cratePrompt then
	cratePrompt = Instance.new("ProximityPrompt")
	cratePrompt.Name = "OpenCratePrompt"
	cratePrompt.Parent = cratePart
end

-- Configure prompt
cratePrompt.ActionText = "Open Relic"
cratePrompt.ObjectText = "Sword Relic"
cratePrompt.HoldDuration = 0
cratePrompt.MaxActivationDistance = 10
cratePrompt.RequiresLineOfSight = false
cratePrompt.ClickablePrompt = true

print("[DUAL CRATE] Single proximity prompt configured")

-- ========================================
-- REMOTE EVENTS SETUP
-- ========================================

-- Create RemoteEvent folder if it doesn't exist
local crateRemotes = ReplicatedStorage:FindFirstChild("CrateRemotes")
if not crateRemotes then
	crateRemotes = Instance.new("Folder")
	crateRemotes.Name = "CrateRemotes"
	crateRemotes.Parent = ReplicatedStorage
end

-- Create ShowCrateChoice event (Server -> Client: show UI)
local showCrateChoiceEvent = crateRemotes:FindFirstChild("ShowCrateChoice")
if not showCrateChoiceEvent then
	showCrateChoiceEvent = Instance.new("RemoteEvent")
	showCrateChoiceEvent.Name = "ShowCrateChoice"
	showCrateChoiceEvent.Parent = crateRemotes
end

-- Create RequestCrateOpen event (Client -> Server: player chose a crate)
local requestCrateOpenEvent = crateRemotes:FindFirstChild("RequestCrateOpen")
if not requestCrateOpenEvent then
	requestCrateOpenEvent = Instance.new("RemoteEvent")
	requestCrateOpenEvent.Name = "RequestCrateOpen"
	requestCrateOpenEvent.Parent = crateRemotes
end

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
	local rarities = {
		{name = "Common", weight = 100},
		{name = "Uncommon", weight = 50},
		{name = "Rare", weight = 25},
		{name = "Legendary", weight = 8},
		{name = "Godly", weight = 2},
		{name = "???", weight = 0.5},
	}
	
	-- Apply crate-specific rarity multipliers
	local crateConfig = CRATE_CONFIG[crateType]
	if crateConfig and crateConfig.RarityMultipliers then
		for _, rarity in ipairs(rarities) do
			local multiplier = crateConfig.RarityMultipliers[rarity.name] or 1.0
			rarity.weight = rarity.weight * multiplier
		end
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
	
	print("[DUAL CRATE] Selected rarity:", selectedRarity, "from", crateType, "crate")
	
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
		-- TODO: Could fire a client event to show "Not enough Yen!" message
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
		-- TODO: Could show error message to player
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
-- PROXIMITY PROMPT: SHOW CHOICE UI
-- ========================================

cratePrompt.Triggered:Connect(function(player)
	if not player or not player.Parent then return end
	
	-- Check if player is already opening a crate
	if playersOpening[player.UserId] or pendingPurchases[player.UserId] then
		warn("[DUAL CRATE]", player.Name, "is already opening a crate!")
		return
	end
	
	-- Show choice UI to the player
	print("[DUAL CRATE]", player.Name, "triggered crate - showing choice UI")
	showCrateChoiceEvent:FireClient(player)
end)

-- ========================================
-- HANDLE PLAYER CHOICE FROM UI
-- ========================================

requestCrateOpenEvent.OnServerEvent:Connect(function(player, crateType)
	if not player or not player.Parent then return end
	
	print("[DUAL CRATE]", player.Name, "chose:", crateType)
	
	if crateType == "Regular" then
		openRegularCrate(player)
	elseif crateType == "Premium" then
		openPremiumCrate(player)
	else
		warn("[DUAL CRATE] Invalid crate type from", player.Name, ":", crateType)
	end
end)

-- ========================================
-- CLEANUP
-- ========================================

Players.PlayerRemoving:Connect(function(player)
	playersOpening[player.UserId] = nil
	pendingPurchases[player.UserId] = nil
end)

print("[DUAL CRATE] System ready! ✅")
print("[DUAL CRATE] Regular Crate: ¥" .. CRATE_CONFIG.Regular.Cost)
print("[DUAL CRATE] Premium Crate: " .. CRATE_CONFIG.Premium.Cost .. " R$ (ProductId:", CRATE_CONFIG.Premium.ProductId, ")")

if CRATE_CONFIG.Premium.ProductId == 0 then
	warn("⚠️ [DUAL CRATE] Premium Crate ProductId not set! See SETUP_INSTRUCTIONS.md")
end
