--[[
	JUMP PAD MANAGER - Centralized Server Script
	Place this ONCE in ServerScriptService
	
	Automatically manages ALL jump pads in your game!
	Just tag any Part with "JumpPad" and it works.
	
	✅ Works with pads ANYWHERE in your game:
	   • Inside folders
	   • Inside models
	   • Inside maps
	   • ANY level of nesting
	
	CollectionService automatically finds ALL tagged parts,
	no matter where they are in the game hierarchy!
]]

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ⚙️ DEFAULT CONFIGURATION (applies to all pads unless overridden)
local DEFAULT_SETTINGS = {
	JumpStrength = 50,      -- How high players jump
	Cooldown = 0.5,         -- Seconds between uses per player
	ShowVisual = true,      -- Flash effect when activated
	ActiveColor = Color3.fromRGB(0, 255, 150),
	FlashDuration = 0.2
}

-- 📋 CUSTOM CONFIGURATIONS (override for specific named pads)
local CUSTOM_CONFIGS = {
	-- Example: Different settings for different named pads
	["SuperJump"] = {
		JumpStrength = 100,
		Cooldown = 0.7,
		ActiveColor = Color3.fromRGB(255, 100, 0)
	},
	["SpeedBoost"] = {
		JumpStrength = 35,
		Cooldown = 0.3,
		ActiveColor = Color3.fromRGB(100, 200, 255)
	},
	-- Add more custom configs here!
}

-- Global state
local playerCooldowns = {}  -- Format: [userId][padName] = timestamp
local jumpPadEvent

-- Initialize RemoteEvent
local function initializeRemoteEvent()
	jumpPadEvent = ReplicatedStorage:FindFirstChild("JumpPadEvent")
	if not jumpPadEvent then
		jumpPadEvent = Instance.new("RemoteEvent")
		jumpPadEvent.Name = "JumpPadEvent"
		jumpPadEvent.Parent = ReplicatedStorage
	end
end

-- Get settings for a specific pad
local function getSettings(pad)
	-- Check if there's a custom config for this pad name
	if CUSTOM_CONFIGS[pad.Name] then
		-- Merge custom settings with defaults
		local settings = {}
		for key, value in pairs(DEFAULT_SETTINGS) do
			settings[key] = value
		end
		for key, value in pairs(CUSTOM_CONFIGS[pad.Name]) do
			settings[key] = value
		end
		return settings
	end
	
	-- Return defaults
	return DEFAULT_SETTINGS
end

-- Check if player is on cooldown for this specific pad
local function isOnCooldown(userId, padName, cooldownTime)
	if playerCooldowns[userId] and playerCooldowns[userId][padName] then
		return (tick() - playerCooldowns[userId][padName]) < cooldownTime
	end
	return false
end

-- Set cooldown for player on this pad
local function setCooldown(userId, padName)
	if not playerCooldowns[userId] then
		playerCooldowns[userId] = {}
	end
	playerCooldowns[userId][padName] = tick()
end

-- Visual feedback
local function flashPad(pad, settings)
	if not settings.ShowVisual then return end
	
	local originalColor = pad.Color
	pad.Color = settings.ActiveColor
	
	task.delay(settings.FlashDuration, function()
		if pad and pad.Parent then
			pad.Color = originalColor
		end
	end)
end

-- Setup a single jump pad
local function setupJumpPad(pad)
	if not pad:IsA("BasePart") then
		warn("JumpPad tag applied to non-BasePart:", pad:GetFullName())
		return
	end
	
	local settings = getSettings(pad)
	local padName = pad.Name
	
	-- Touch handler
	local connection = pad.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		
		local character = hit.Parent
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		
		local player = game.Players:GetPlayerFromCharacter(character)
		if not player then return end
		
		-- Check cooldown for this specific pad
		if isOnCooldown(player.UserId, padName, settings.Cooldown) then
			return
		end
		
		-- Set cooldown
		setCooldown(player.UserId, padName)
		
		-- Tell client to jump
		jumpPadEvent:FireClient(player, settings.JumpStrength)
		
		-- Visual feedback
		flashPad(pad, settings)
	end)
	
	-- Store connection for cleanup
	pad:SetAttribute("JumpPadActive", true)
	
	print(string.format("✅ Jump Pad setup: %s (Strength: %d)", padName, settings.JumpStrength))
	
	return connection
end

-- Cleanup a jump pad
local function cleanupJumpPad(pad)
	pad:SetAttribute("JumpPadActive", nil)
	print("🗑️ Jump Pad removed:", pad.Name)
end

-- Initialize system
local function initialize()
	print("🚀 Initializing Jump Pad Manager...")
	
	initializeRemoteEvent()
	
	-- Setup existing pads (finds ALL pads in entire game, regardless of location!)
	-- Works with pads in: workspace, folders, models, maps, any nesting level
	for _, pad in ipairs(CollectionService:GetTagged("JumpPad")) do
		setupJumpPad(pad)
	end
	
	-- Setup new pads as they're added
	CollectionService:GetInstanceAddedSignal("JumpPad"):Connect(function(pad)
		setupJumpPad(pad)
	end)
	
	-- Cleanup removed pads
	CollectionService:GetInstanceRemovedSignal("JumpPad"):Connect(function(pad)
		cleanupJumpPad(pad)
	end)
	
	-- Cleanup players on leave
	game.Players.PlayerRemoving:Connect(function(player)
		playerCooldowns[player.UserId] = nil
	end)
	
	print("✅ Jump Pad Manager ready! Watching for 'JumpPad' tags.")
end

initialize()
