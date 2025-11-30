--[[
	Jump Pad - SERVER SCRIPT
	Place this inside the JumpPad Part
	
	Responsibilities:
	- Detect valid pad touches
	- Validate players and cooldowns
	- Tell the client to apply the jump (via RemoteEvent)
]]

local jumpPad = script.Parent

-- Configuration
local JUMP_STRENGTH = 50         -- Passed to client (upward boost in studs/sec)
local COOLDOWN_TIME = 0.5        -- Seconds between uses per player
local SHOW_VISUAL = true         -- Flash the pad when activated

-- Visual settings
local ACTIVE_COLOR = Color3.fromRGB(0, 255, 150)
local DEFAULT_COLOR = jumpPad.Color
local FLASH_DURATION = 0.2

-- Cooldown tracker
local playerCooldowns = {}

-- Create or get RemoteEvent for communication
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jumpPadEvent = ReplicatedStorage:FindFirstChild("JumpPadEvent")

if not jumpPadEvent then
	jumpPadEvent = Instance.new("RemoteEvent")
	jumpPadEvent.Name = "JumpPadEvent"
	jumpPadEvent.Parent = ReplicatedStorage
end

-- Check if player is on cooldown
local function isOnCooldown(userId)
	if playerCooldowns[userId] then
		return (tick() - playerCooldowns[userId]) < COOLDOWN_TIME
	end
	return false
end

-- Visual feedback
local function flashPad()
	if not SHOW_VISUAL then return end
	
	jumpPad.Color = ACTIVE_COLOR
	task.delay(FLASH_DURATION, function()
		jumpPad.Color = DEFAULT_COLOR
	end)
end

-- Main touch handler - ONLY handles detection and validation
jumpPad.Touched:Connect(function(hit)
	-- Fast rejection: must be a part
	if not hit or not hit.Parent then
		return
	end
	
	-- Must be a character with Humanoid
	local character = hit.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	
	-- Must be a valid player
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	
	-- Check cooldown
	if isOnCooldown(player.UserId) then
		return
	end
	
	-- Valid jump - set cooldown
	playerCooldowns[player.UserId] = tick()
	
	-- Tell the CLIENT to apply the jump (this is the key!)
	jumpPadEvent:FireClient(player, JUMP_STRENGTH)
	
	-- Visual feedback on server
	flashPad()
end)

-- Cleanup
game.Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)

print("✅ Jump Pad Server ready!")
