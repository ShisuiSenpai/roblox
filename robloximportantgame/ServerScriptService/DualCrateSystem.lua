--[[
	DUAL CRATE SYSTEM - SERVER SCRIPT
	Place this Script in ServerScriptService
	
	Handles both Regular (Yen) and Premium (Robux) crate opening
	Replace the old CrateSystem.lua with this file
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

print("[DUAL CRATE] Loading dual crate system...")

-- ========================================
-- CONFIGURATION
-- ========================================

local CRATE_CONFIG = {
	Regular = {
		Cost = 250, -- Yen cost
		CostType = "Currency",
		ProximptText = "Regular Relic | ¥250",
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
		Cost = 99, -- Robux cost (REPLACE WITH YOUR DEVELOPER PRODUCT ID)
		ProductId = 0, -- REPLACE WITH YOUR ACTUAL DEVELOPER PRODUCT ID
		CostType = "Robux",
		ProximptText = "Premium Relic | 99 R$",
		RarityMultipliers = {
			["Common"] = 0.5, -- Half the chance for common
			["Uncommon"] = 0.7,
			["Rare"] = 1.2,
			["Legendary"] = 2.0, -- Double chance for legendary
			["Godly"] = 3.0, -- Triple chance for godly
			["???"] = 2.5, -- 2.5x chance for mystery
		},
	},
}

-- ========================================
-- FIND CRATE PARTS & PROMPTS
-- ========================================

local crateTemple = workspace:WaitForChild("CrateTemple")

-- Regular crate (existing one)
local regularCratePart = crateTemple:WaitForChild("OpenCratePart")
local regularPrompt = regularCratePart:WaitForChild("OpenSwordBox")

-- Premium crate (you need to create this in workspace)
local premiumCratePart = crateTemple:FindFirstChild("PremiumCratePart")
local premiumPrompt = nil

if premiumCratePart then
	premiumPrompt = premiumCratePart:FindFirstChild("OpenPremiumBox")
	print("[DUAL CRATE] Premium crate found!")
else
	warn("[DUAL CRATE] Premium crate not found! Create 'PremiumCratePart' with 'OpenPremiumBox' ProximityPrompt")
end

-- ========================================
-- CONFIGURE PROXIMITY PROMPTS
-- ========================================

-- Regular crate prompt
regularPrompt.ObjectText = CRATE_CONFIG.Regular.ProximptText
regularPrompt.ActionText = "Open"
regularPrompt.RequiresLineOfSight = false
regularPrompt.MaxActivationDistance = 7
regularPrompt.HoldDuration = 0
regularPrompt.Style = Enum.ProximityPromptStyle.Default
regularPrompt.Enabled = true
regularPrompt.ClickablePrompt = true

-- Premium crate prompt
if premiumPrompt then
	premiumPrompt.ObjectText = CRATE_CONFIG.Premium.ProximptText
	premiumPrompt.ActionText = "Open"
	premiumPrompt.RequiresLineOfSight = false
	premiumPrompt.MaxActivationDistance = 7
	premiumPrompt.HoldDuration = 0
	premiumPrompt.Style = Enum.ProximityPromptStyle.Default
	premiumPrompt.Enabled = true
	premiumPrompt.ClickablePrompt = true
end

-- ========================================
-- REMOTE EVENTS
-- ========================================

local crateRemotes = ReplicatedStorage:FindFirstChild("CrateRemotes")
if not crateRemotes then
	crateRemotes = Instance.new("Folder")
	crateRemotes.Name = "CrateRemotes"
	crateRemotes.Parent = ReplicatedStorage
end

local openCrateEvent = crateRemotes:FindFirstChild("OpenCrate")
if not openCrateEvent then
	openCrateEvent = Instance.new("RemoteEvent")
	openCrateEvent.Name = "OpenCrate"
	openCrateEvent.Parent = crateRemotes
end

local switchSwordEvent = crateRemotes:FindFirstChild("SwitchSword")
if not switchSwordEvent then
	switchSwordEvent = Instance.new("RemoteEvent")
	switchSwordEvent.Name = "SwitchSword"
	switchSwordEvent.Parent = crateRemotes
end

-- ========================================
-- WAIT FOR DEPENDENCIES
-- ========================================

-- Load sword config
local modulesFolder = ReplicatedStorage:WaitForChild("Modules")
local SwordConfig = require(modulesFolder:WaitForChild("SwordConfig"))

-- Wait for managers
repeat task.wait() until _G.InventoryManager
local InventoryManager = _G.InventoryManager

repeat task.wait() until _G.CurrencyManager
local CurrencyManager = _G.CurrencyManager

-- Table of all available swords
local availableSwords = {}
for swordName, _ in pairs(SwordConfig.Swords) do
	table.insert(availableSwords, swordName)
end

-- ========================================
-- CRATE OPENING LOGIC
-- ========================================

-- Function to choose a random sword based on rarity weights (with multipliers)
local function chooseRandomSword(crateType)
	local multipliers = CRATE_CONFIG[crateType].RarityMultipliers
	
	-- Build a weighted pool based on rarities and multipliers
	local weightedPool = {}
	local totalWeight = 0

	for swordName, swordConfig in pairs(SwordConfig.Swords) do
		local rarity = swordConfig.Rarity or "Common"
		local rarityData = SwordConfig.Rarities[rarity]

		if rarityData then
			-- Apply multiplier for this crate type
			local baseWeight = rarityData.Chance
			local multiplier = multipliers[rarity] or 1.0
			local weight = baseWeight * multiplier
			
			totalWeight = totalWeight + weight

			table.insert(weightedPool, {
				name = swordName,
				weight = weight,
				cumulativeWeight = totalWeight,
				rarity = rarity,
			})
		end
	end

	-- Pick a random value between 0 and totalWeight
	local roll = math.random() * totalWeight

	-- Find which sword the roll landed on
	for _, entry in ipairs(weightedPool) do
		if roll <= entry.cumulativeWeight then
			return entry.name, entry.rarity
		end
	end

	-- Fallback (should never happen)
	return availableSwords[1], "Common"
end

-- Function to switch player's sword
local function switchPlayerSword(player, swordName)
	local swordConfig = SwordConfig.Swords[swordName]
	if not swordConfig then
		warn("[DUAL CRATE] Sword config not found: " .. swordName)
		return false
	end

	switchSwordEvent:FireClient(player, swordName)
	return true
end

-- Track players currently opening crates
local playersOpening = {}

-- Track pending premium purchases (to prevent double-processing)
local pendingPurchases = {}

-- ========================================
-- REGULAR CRATE OPENING (YEN)
-- ========================================

local function openRegularCrate(player)
	-- Check if player is already opening a crate
	if playersOpening[player.UserId] then
		warn("[DUAL CRATE] " .. player.Name .. " tried to open crate while already opening one")
		return false
	end

	-- Check if player has enough currency
	local balance = CurrencyManager.getCurrency(player)
	if balance < CRATE_CONFIG.Regular.Cost then
		warn("[DUAL CRATE] " .. player.Name .. " doesn't have enough Yen! Has: " .. balance .. " Needs: " .. CRATE_CONFIG.Regular.Cost)
		return false
	end

	-- Deduct currency
	local success = CurrencyManager.removeCurrency(player, CRATE_CONFIG.Regular.Cost, "Opened Regular Relic")
	if not success then
		warn("[DUAL CRATE] Failed to deduct currency from " .. player.Name)
		return false
	end

	print("[DUAL CRATE] " .. player.Name .. " opened REGULAR crate for " .. CRATE_CONFIG.Regular.Cost .. " Yen")

	-- Mark player as opening
	playersOpening[player.UserId] = true

	-- Choose a random sword (regular odds)
	local chosenSword, rarity = chooseRandomSword("Regular")

	-- Send to client to show animation
	openCrateEvent:FireClient(player, chosenSword, availableSwords)

	print("[DUAL CRATE] " .. player.Name .. " rolled: " .. chosenSword .. " (" .. rarity .. ")")

	-- Wait for animation, then add sword
	task.delay(6, function()
		InventoryManager.AddSword(player, chosenSword)
		playersOpening[player.UserId] = nil
	end)

	return true
end

-- Regular crate proximity trigger
regularPrompt.Triggered:Connect(function(player)
	openRegularCrate(player)
end)

-- ========================================
-- PREMIUM CRATE OPENING (ROBUX)
-- ========================================

local function openPremiumCrate(player)
	-- Check if player is already opening a crate
	if playersOpening[player.UserId] then
		warn("[DUAL CRATE] " .. player.Name .. " tried to open crate while already opening one")
		return false
	end

	-- Check if developer product ID is configured
	if CRATE_CONFIG.Premium.ProductId == 0 then
		warn("[DUAL CRATE] Premium crate Developer Product ID not configured!")
		return false
	end

	-- Mark as pending purchase
	pendingPurchases[player.UserId] = true

	-- Prompt purchase
	local success, errorMsg = pcall(function()
		MarketplaceService:PromptProductPurchase(player, CRATE_CONFIG.Premium.ProductId)
	end)

	if not success then
		warn("[DUAL CRATE] Failed to prompt purchase for " .. player.Name .. ": " .. tostring(errorMsg))
		pendingPurchases[player.UserId] = nil
		return false
	end

	print("[DUAL CRATE] Prompted " .. player.Name .. " to purchase premium crate")
	return true
end

-- Premium crate proximity trigger
if premiumPrompt then
	premiumPrompt.Triggered:Connect(function(player)
		openPremiumCrate(player)
	end)
end

-- ========================================
-- MARKETPLACE SERVICE CALLBACKS
-- ========================================

-- Process receipt (called when player completes purchase)
local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	
	-- Check if it's our premium crate product
	if receiptInfo.ProductId == CRATE_CONFIG.Premium.ProductId then
		if player then
			print("[DUAL CRATE] Processing premium crate purchase for " .. player.Name)
			
			-- Clear pending purchase
			pendingPurchases[player.UserId] = nil
			
			-- Mark player as opening
			playersOpening[player.UserId] = true

			-- Choose a random sword (PREMIUM odds - better rates!)
			local chosenSword, rarity = chooseRandomSword("Premium")

			-- Send to client to show animation
			openCrateEvent:FireClient(player, chosenSword, availableSwords)

			print("[DUAL CRATE] " .. player.Name .. " rolled PREMIUM: " .. chosenSword .. " (" .. rarity .. ")")

			-- Wait for animation, then add sword
			task.delay(6, function()
				InventoryManager.AddSword(player, chosenSword)
				playersOpening[player.UserId] = nil
			end)
			
			-- Grant purchase
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			-- Player left, still grant (they paid!)
			warn("[DUAL CRATE] Player left before premium crate could open - granting anyway")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	
	-- Not our product
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Set the callback
MarketplaceService.ProcessReceipt = processReceipt

-- ========================================
-- CLEANUP
-- ========================================

-- Clean up pending purchases when players leave
Players.PlayerRemoving:Connect(function(player)
	playersOpening[player.UserId] = nil
	pendingPurchases[player.UserId] = nil
end)

print("========================================")
print("Dual Crate System Ready!")
print("Regular Crate: " .. CRATE_CONFIG.Regular.Cost .. " Yen")
print("Premium Crate: " .. CRATE_CONFIG.Premium.Cost .. " Robux")
print("Premium Product ID:", CRATE_CONFIG.Premium.ProductId)
if CRATE_CONFIG.Premium.ProductId == 0 then
	warn("⚠️  CONFIGURE PREMIUM PRODUCT ID!")
end
print("========================================")
