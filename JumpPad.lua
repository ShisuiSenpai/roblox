--[[
	Simple & Smooth Jump Pad
	Place this script inside a Part named "JumpPad"
]]

local jumpPad = script.Parent

-- ⚙️ CONFIGURATION - Adjust these to change jump behavior
local JUMP_POWER = 50           -- How high you go (50 = standard, 100 = super high)
local COOLDOWN = 0.5             -- Seconds between jumps per player
local SHOW_EFFECT = true         -- Visual feedback when activated

-- Visual settings
local ACTIVE_COLOR = Color3.fromRGB(0, 255, 150)
local DEFAULT_COLOR = jumpPad.Color

-- Track which players are on cooldown
local playersOnCooldown = {}

-- Simple function to launch a player
local function launchPlayer(player, character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if not humanoidRootPart or not humanoid then
		return
	end
	
	-- Set the upward velocity - simple and effective!
	humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
		humanoidRootPart.AssemblyLinearVelocity.X,  -- Keep horizontal speed
		JUMP_POWER,                                   -- Set vertical speed
		humanoidRootPart.AssemblyLinearVelocity.Z   -- Keep horizontal speed
	)
	
	-- Visual feedback
	if SHOW_EFFECT then
		jumpPad.Color = ACTIVE_COLOR
		task.wait(0.2)
		jumpPad.Color = DEFAULT_COLOR
	end
end

-- Main touch handler with proper debouncing
jumpPad.Touched:Connect(function(hit)
	-- Check if what touched us is a player's body part
	local character = hit.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	
	if not humanoid then
		return  -- Not a player
	end
	
	-- Get the player
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then
		return  -- Not a valid player
	end
	
	-- Check if player is on cooldown
	if playersOnCooldown[player.UserId] then
		return  -- Still on cooldown
	end
	
	-- Put player on cooldown
	playersOnCooldown[player.UserId] = true
	
	-- Launch the player
	launchPlayer(player, character)
	
	-- Remove cooldown after delay
	task.delay(COOLDOWN, function()
		playersOnCooldown[player.UserId] = nil
	end)
end)

-- Cleanup when players leave
game.Players.PlayerRemoving:Connect(function(player)
	playersOnCooldown[player.UserId] = nil
end)

print("✅ Jump Pad ready!")
