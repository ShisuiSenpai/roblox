--[[
	CRATE SYSTEM - SERVER SCRIPT
	Place this Script in ServerScriptService
	
	Handles crate opening logic and gives swords to players
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get the chest and prompt
local chest = workspace:WaitForChild("Chest")
local proximityPrompt = chest:WaitForChild("ProximityPrompt")

-- Get or create RemoteEvents
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

local claimSwordEvent = crateRemotes:FindFirstChild("ClaimSword")
if not claimSwordEvent then
	claimSwordEvent = Instance.new("RemoteEvent")
	claimSwordEvent.Name = "ClaimSword"
	claimSwordEvent.Parent = crateRemotes
end

-- Load sword config
local SwordConfig = require(ReplicatedStorage:WaitForChild("SwordConfig"))

-- Table of all available swords
local availableSwords = {}
for swordName, _ in pairs(SwordConfig.Swords) do
	table.insert(availableSwords, swordName)
end

-- ========================================
-- CRATE OPENING LOGIC
-- ========================================

-- Function to choose a random sword
local function chooseRandomSword()
	local randomIndex = math.random(1, #availableSwords)
	return availableSwords[randomIndex]
end

-- Function to give sword to player
local function giveSwordToPlayer(player, swordName)
	local character = player.Character
	if not character then return false end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return false end
	
	-- Find the sword tool in ReplicatedStorage
	local swordConfig = SwordConfig.Swords[swordName]
	if not swordConfig then
		warn("Sword config not found: " .. swordName)
		return false
	end
	
	local swordTool = ReplicatedStorage:FindFirstChild(swordConfig.ToolName)
	if not swordTool then
		warn("Sword tool not found: " .. swordConfig.ToolName)
		return false
	end
	
	-- Clone the sword and give it to player
	local newSword = swordTool:Clone()
	newSword.Parent = character
	
	-- Equip it immediately
	humanoid:EquipTool(newSword)
	
	return true
end

-- ========================================
-- EVENT HANDLERS
-- ========================================

-- When player interacts with chest
proximityPrompt.Triggered:Connect(function(player)
	-- Choose a random sword
	local chosenSword = chooseRandomSword()
	
	-- Send to client to show animation
	openCrateEvent:FireClient(player, chosenSword, availableSwords)
	
	print(player.Name .. " is opening a crate! Chosen sword: " .. chosenSword)
end)

-- When client finishes animation and wants the sword
claimSwordEvent.OnServerEvent:Connect(function(player, swordName)
	-- Verify the sword name is valid
	if not SwordConfig.Swords[swordName] then
		warn("Invalid sword claim attempt: " .. tostring(swordName))
		return
	end
	
	-- Give the sword to the player
	local success = giveSwordToPlayer(player, swordName)
	
	if success then
		print("Gave " .. swordName .. " to " .. player.Name)
	else
		warn("Failed to give sword to " .. player.Name)
	end
end)

print("Crate System Server loaded!")
