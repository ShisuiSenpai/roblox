--[[
	Animation Controller Script
	
	SETUP INSTRUCTIONS:
	1. Place this LocalScript in StarterPlayer > StarterCharacterScripts
	2. Replace ANIMATION_ID with your animation asset ID (e.g., "rbxassetid://123456789")
	3. Customize SPEED_PATTERN table to control speed changes per second
	
	FEATURES:
	- Press R to play animation for 5 seconds
	- Animation speed changes every second
	- Proper cleanup and debouncing
	- Mobile-friendly with context action
--]]

-- CONFIGURATION
local ANIMATION_ID = "rbxassetid://YOUR_ANIMATION_ID_HERE" -- Replace with your animation ID
local KEY_BIND = Enum.KeyCode.R
local DURATION = 5 -- seconds
local SPEED_PATTERN = {1.0, 1.5, 0.5, 2.0, 1.2} -- Speed for each second (customize as needed)

-- Services
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

-- Variables
local player = game.Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local animationTrack = nil
local isPlaying = false
local speedUpdateConnection = nil

-- Load Animation
local animation = Instance.new("Animation")
animation.AnimationId = ANIMATION_ID
animationTrack = animator:LoadAnimation(animation)
animationTrack.Looped = true

-- Cleanup function
local function cleanup()
	if speedUpdateConnection then
		speedUpdateConnection:Disconnect()
		speedUpdateConnection = nil
	end
	
	if animationTrack and animationTrack.IsPlaying then
		animationTrack:Stop(0.2) -- Fade out over 0.2 seconds
	end
	
	isPlaying = false
end

-- Play animation with speed variation
local function playAnimationWithSpeedVariation()
	-- Prevent multiple simultaneous plays
	if isPlaying then return end
	isPlaying = true
	
	-- Start the animation
	animationTrack:Play(0.1) -- Fade in over 0.1 seconds
	
	local startTime = tick()
	local lastSecond = 0
	
	-- Update speed every second
	speedUpdateConnection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local currentSecond = math.floor(elapsed)
		
		-- Change speed when entering a new second
		if currentSecond ~= lastSecond and currentSecond < DURATION then
			local speedIndex = (currentSecond % #SPEED_PATTERN) + 1
			animationTrack:AdjustSpeed(SPEED_PATTERN[speedIndex])
			lastSecond = currentSecond
		end
		
		-- Stop after duration
		if elapsed >= DURATION then
			cleanup()
		end
	end)
end

-- Input handler
local function onInputBegan(input, gameProcessed)
	-- Don't trigger if player is typing in chat or other UI
	if gameProcessed then return end
	
	if input.KeyCode == KEY_BIND then
		playAnimationWithSpeedVariation()
	end
end

-- Mobile support handler
local function handleAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		playAnimationWithSpeedVariation()
	end
	return Enum.ContextActionResult.Pass
end

-- Connect input
UserInputService.InputBegan:Connect(onInputBegan)

-- Bind for mobile (creates button on mobile devices)
ContextActionService:BindAction(
	"PlayAnimation",
	handleAction,
	true, -- Create mobile button
	KEY_BIND
)

-- Cleanup on character death/removal
character:WaitForChild("Humanoid").Died:Connect(cleanup)

-- Cleanup when script is destroyed
script.AncestryChanged:Connect(function()
	if not script:IsDescendantOf(game) then
		cleanup()
		ContextActionService:UnbindAction("PlayAnimation")
	end
end)
