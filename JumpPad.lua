--[[
	Jump Pad Script
	Place this script inside the JumpPad part OR inside a Model containing the jump pad
	
	Features:
	- Optimized hitbox detection
	- Smooth player launching
	- Debounce system to prevent spam
	- Easy to configure parameters
]]

-- Find the jump pad part (works whether script is in a Part or Model)
local JumpPad
if script.Parent:IsA("BasePart") then
	-- Script is directly in a Part
	JumpPad = script.Parent
else
	-- Script is in a Model, find the primary part or first part
	if script.Parent.PrimaryPart then
		JumpPad = script.Parent.PrimaryPart
	else
		-- Find the first BasePart in the model
		JumpPad = script.Parent:FindFirstChildWhichIsA("BasePart")
	end
end

-- Validate we found a part
if not JumpPad then
	error("Jump Pad script must be inside a Part or a Model containing parts!")
end

-- Configuration
local JUMP_POWER = 80 -- Vertical force (how high the player goes)
local HORIZONTAL_MULTIPLIER = 1.2 -- Multiplier for horizontal velocity preservation
local LAUNCH_DURATION = 0.1 -- How long the force is applied
local COOLDOWN_TIME = 0.5 -- Cooldown per player to prevent spam
local USE_VISUAL_FEEDBACK = true -- Enable/disable visual effects

-- Visual feedback settings
local ACTIVATED_COLOR = Color3.fromRGB(0, 255, 100)
local DEFAULT_COLOR = JumpPad.Color  -- Store the original color
local FLASH_DURATION = 0.3

-- Player cooldown tracker (prevents spam)
local playerCooldowns = {}

-- Function to check if the touched part belongs to a player
local function getPlayerFromPart(part)
	if not part or not part.Parent then
		return nil
	end
	
	local character = part.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	-- Verify this is a valid player character
	if humanoid and humanoid.Health > 0 then
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			return player, character, humanoid
		end
	end
	
	return nil
end

-- Function to check if player is on cooldown
local function isOnCooldown(player)
	if playerCooldowns[player.UserId] then
		local timeElapsed = tick() - playerCooldowns[player.UserId]
		return timeElapsed < COOLDOWN_TIME
	end
	return false
end

-- Function to set player cooldown
local function setCooldown(player)
	playerCooldowns[player.UserId] = tick()
end

-- Function to apply jump force to character
local function launchPlayer(character, humanoid)
	-- Get the character's root part
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		warn("⚠️ Could not find HumanoidRootPart!")
		return
	end
	
	print("🚀 Launching player:", character.Name)
	
	-- Calculate launch velocity
	-- Preserve some horizontal movement for natural feel
	local currentVelocity = rootPart.AssemblyLinearVelocity
	local horizontalVelocity = Vector3.new(
		currentVelocity.X * HORIZONTAL_MULTIPLIER,
		0,
		currentVelocity.Z * HORIZONTAL_MULTIPLIER
	)
	
	-- Combine with vertical jump power
	local launchVelocity = horizontalVelocity + Vector3.new(0, JUMP_POWER, 0)
	
	-- Method 1: Set velocity directly (try both modern and legacy)
	rootPart.AssemblyLinearVelocity = launchVelocity
	rootPart.Velocity = launchVelocity
	
	-- Method 2: Use BodyVelocity for more reliable launching
	-- Remove any existing BodyVelocity first
	local existingBV = rootPart:FindFirstChild("JumpPadVelocity")
	if existingBV then
		existingBV:Destroy()
	end
	
	-- Create new BodyVelocity
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "JumpPadVelocity"
	bodyVelocity.Velocity = launchVelocity
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.P = 1250
	bodyVelocity.Parent = rootPart
	
	-- Remove BodyVelocity after a short time
	task.delay(LAUNCH_DURATION, function()
		if bodyVelocity and bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end
	end)
	
	-- Set character state to jumping for better animation
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	
	print("✅ Launch complete! Velocity:", launchVelocity)
end

-- Visual feedback function
local function showActivationEffect()
	if not USE_VISUAL_FEEDBACK then
		return
	end
	
	-- Flash the jump pad color
	JumpPad.Color = ACTIVATED_COLOR
	
	-- Reset color after flash duration
	task.delay(FLASH_DURATION, function()
		JumpPad.Color = DEFAULT_COLOR
	end)
end

-- Main touch detection
local function onTouch(hit)
	-- Quick rejection: check if hit part exists
	if not hit or not hit.Parent then
		return
	end
	
	-- Get player information
	local player, character, humanoid = getPlayerFromPart(hit)
	
	-- If not a valid player, ignore
	if not player then
		return
	end
	
	print("👟 Player touched jump pad:", player.Name)
	
	-- Check cooldown
	if isOnCooldown(player) then
		print("⏳ Player on cooldown:", player.Name)
		return
	end
	
	-- Set cooldown for this player
	setCooldown(player)
	
	-- Launch the player
	launchPlayer(character, humanoid)
	
	-- Show visual feedback
	showActivationEffect()
end

-- Connect the touch event
JumpPad.Touched:Connect(onTouch)

-- Cleanup function for player cooldowns (prevent memory leaks)
game.Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)

-- Optional: Clean up old cooldowns periodically
task.spawn(function()
	while true do
		task.wait(60) -- Every minute
		local currentTime = tick()
		for userId, timestamp in pairs(playerCooldowns) do
			if currentTime - timestamp > COOLDOWN_TIME * 2 then
				playerCooldowns[userId] = nil
			end
		end
	end
end)

print("✅ Jump Pad initialized successfully! Using part:", JumpPad.Name)
