--[[
	Typing Test Client - LocalScript
	
	SETUP:
	Place this LocalScript in StarterPlayer > StarterPlayerScripts
	
	Features:
	- Smooth UI animations
	- Real-time typing validation
	- Animation speed based on typing speed
	- WPM (Words Per Minute) calculation
	- Mistake tracking
--]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local ANIMATION_ID = "rbxassetid://YOUR_ANIMATION_ID_HERE" -- Replace with your animation ID
local MIN_ANIMATION_SPEED = 0.5
local MAX_ANIMATION_SPEED = 3.0
local WPM_FOR_MAX_SPEED = 100 -- WPM needed to reach max animation speed

-- Sentences pool
local SENTENCES = {
	"The quick brown fox jumps over the lazy dog",
	"Practice makes perfect when typing fast",
	"Speed and accuracy are both important skills",
	"Challenge yourself to type faster every day",
	"Master the keyboard with dedication and practice",
	"Typing is a valuable skill in the modern world",
	"Focus on accuracy before increasing your speed",
	"Every keystroke brings you closer to mastery",
	"Consistent practice leads to incredible results",
	"Push your limits and break your records"
}

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local screenGui = nil
local mainFrame = nil
local sentenceLabel = nil
local inputBox = nil
local statsLabel = nil
local resultLabel = nil

local animationTrack = nil
local currentSentence = ""
local startTime = 0
local isTyping = false
local typingSpeedConnection = nil
local lastTypingTime = 0
local currentWPM = 0

-- Create UI
local function createUI()
	-- Main ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TypingTestUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player.PlayerGui
	
	-- Main Frame (container) - Minimal and transparent
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 120)
	mainFrame.Position = UDim2.new(0.5, 0, -0.2, 0) -- Start off-screen (top)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0)
	mainFrame.BackgroundTransparency = 1 -- Fully transparent
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- Container for sentence and input (with subtle background)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 0, 90)
	contentFrame.Position = UDim2.new(0, 0, 0, 0)
	contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	contentFrame.BackgroundTransparency = 0.7 -- Semi-transparent
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = mainFrame
	
	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 12)
	contentCorner.Parent = contentFrame
	
	-- Subtle glow effect
	local glow = Instance.new("UIStroke")
	glow.Color = Color3.fromRGB(100, 200, 255)
	glow.Thickness = 1
	glow.Transparency = 0.6
	glow.Parent = contentFrame
	
	-- Sentence Display (no background, just text)
	sentenceLabel = Instance.new("TextLabel")
	sentenceLabel.Name = "SentenceLabel"
	sentenceLabel.Size = UDim2.new(1, -120, 0, 35)
	sentenceLabel.Position = UDim2.new(0, 15, 0, 10)
	sentenceLabel.BackgroundTransparency = 1
	sentenceLabel.Text = "Loading..."
	sentenceLabel.Font = Enum.Font.GothamMedium
	sentenceLabel.TextSize = 18
	sentenceLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	sentenceLabel.TextXAlignment = Enum.TextXAlignment.Left
	sentenceLabel.TextTruncate = Enum.TextTruncate.AtEnd
	sentenceLabel.Parent = contentFrame
	
	-- Input Box (minimal, transparent background)
	inputBox = Instance.new("TextBox")
	inputBox.Name = "InputBox"
	inputBox.Size = UDim2.new(1, -120, 0, 35)
	inputBox.Position = UDim2.new(0, 15, 0, 50)
	inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.BackgroundTransparency = 0.9 -- Very transparent
	inputBox.PlaceholderText = "Type here..."
	inputBox.Text = ""
	inputBox.Font = Enum.Font.GothamMedium
	inputBox.TextSize = 18
	inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
	inputBox.ClearTextOnFocus = false
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.BorderSizePixel = 0
	inputBox.Parent = contentFrame
	
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 8)
	inputCorner.Parent = inputBox
	
	local inputPadding = Instance.new("UIPadding")
	inputPadding.PaddingLeft = UDim.new(0, 12)
	inputPadding.PaddingRight = UDim.new(0, 12)
	inputPadding.Parent = inputBox
	
	-- Stats Label (compact, on the right side)
	statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "StatsLabel"
	statsLabel.Size = UDim2.new(0, 100, 1, 0)
	statsLabel.Position = UDim2.new(1, -110, 0, 0)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "0\nWPM"
	statsLabel.Font = Enum.Font.GothamBold
	statsLabel.TextSize = 20
	statsLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
	statsLabel.TextXAlignment = Enum.TextXAlignment.Center
	statsLabel.TextYAlignment = Enum.TextYAlignment.Center
	statsLabel.Parent = contentFrame
	
	-- Result Label (minimal, appears below)
	resultLabel = Instance.new("TextLabel")
	resultLabel.Name = "ResultLabel"
	resultLabel.Size = UDim2.new(1, 0, 0, 25)
	resultLabel.Position = UDim2.new(0, 0, 0, 95)
	resultLabel.BackgroundTransparency = 1
	resultLabel.Text = ""
	resultLabel.Font = Enum.Font.GothamBold
	resultLabel.TextSize = 16
	resultLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	resultLabel.TextXAlignment = Enum.TextXAlignment.Center
	resultLabel.Visible = false
	resultLabel.Parent = mainFrame
end

-- Load animation
local function loadAnimation()
	if animationTrack then return end
	
	local animation = Instance.new("Animation")
	animation.AnimationId = ANIMATION_ID
	animationTrack = animator:LoadAnimation(animation)
	animationTrack.Looped = true
end

-- Calculate WPM
local function calculateWPM(text, timeInSeconds)
	local words = #text / 5 -- Standard: 5 characters = 1 word
	local minutes = timeInSeconds / 60
	return math.floor(words / minutes)
end

-- Update animation speed based on typing speed
local function updateAnimationSpeed()
	if not animationTrack or not animationTrack.IsPlaying then return end
	
	-- Calculate speed multiplier based on WPM (0-100 WPM range)
	local speedMultiplier = math.clamp(currentWPM / WPM_FOR_MAX_SPEED, 0, 1)
	local animSpeed = MIN_ANIMATION_SPEED + (speedMultiplier * (MAX_ANIMATION_SPEED - MIN_ANIMATION_SPEED))
	
	animationTrack:AdjustSpeed(animSpeed)
end

-- Start new test
local function startNewTest()
	-- Reset
	currentSentence = SENTENCES[math.random(1, #SENTENCES)]
	sentenceLabel.Text = currentSentence
	inputBox.Text = ""
	resultLabel.Visible = false
	resultLabel.Text = ""
	statsLabel.Text = "0\nWPM"
	isTyping = false
	startTime = 0
	currentWPM = 0
	
	-- Focus input
	task.wait(0.5)
	inputBox:CaptureFocus()
end

-- Check typing progress
local function onTextChanged()
	local inputText = inputBox.Text
	
	-- Start timing on first character
	if #inputText == 1 and not isTyping then
		isTyping = true
		startTime = tick()
		
		-- Start animation
		if animationTrack then
			animationTrack:Play(0.1)
		end
		
		-- Start monitoring typing speed
		if typingSpeedConnection then
			typingSpeedConnection:Disconnect()
		end
		
		typingSpeedConnection = RunService.Heartbeat:Connect(function()
			local currentTime = tick()
			local elapsed = currentTime - startTime
			
			if elapsed > 0 and #inputText > 0 then
				currentWPM = calculateWPM(inputText, elapsed)
				
				-- Update animation speed based on typing activity
				local timeSinceLastType = currentTime - lastTypingTime
				if timeSinceLastType < 0.5 then -- Actively typing
					updateAnimationSpeed()
				else -- Slowing down or stopped
					if animationTrack and animationTrack.IsPlaying then
						animationTrack:AdjustSpeed(MIN_ANIMATION_SPEED)
					end
				end
			end
		end)
	end
	
	-- Update last typing time
	lastTypingTime = tick()
	
	-- Check for completion
	if inputText == currentSentence then
		local timeTaken = tick() - startTime
		local finalWPM = calculateWPM(inputText, timeTaken)
		
		-- Stop animation
		if animationTrack and animationTrack.IsPlaying then
			animationTrack:Stop(0.2)
		end
		
		if typingSpeedConnection then
			typingSpeedConnection:Disconnect()
			typingSpeedConnection = nil
		end
		
		-- Show results
		resultLabel.Text = string.format("✓ %d WPM in %.1fs - Perfect!", finalWPM, timeTaken)
		resultLabel.Visible = true
		statsLabel.Text = string.format("%d\nWPM", finalWPM)
		
		-- Celebrate animation
		local celebration = TweenService:Create(resultLabel, TweenInfo.new(0.3, Enum.EasingStyle.Bounce), {
			TextSize = 24
		})
		celebration:Play()
		
		-- Auto-restart after 3 seconds
		task.wait(3)
		startNewTest()
		
	elseif #inputText > 0 then
		-- Update stats during typing
		local elapsed = tick() - startTime
		if elapsed > 0 then
			local wpm = calculateWPM(inputText, elapsed)
			
			-- Check accuracy
			local correct = inputText == string.sub(currentSentence, 1, #inputText)
			local accuracy = correct and 100 or 0
			
			-- Color code accuracy
			if correct then
				inputBox.TextColor3 = Color3.fromRGB(100, 255, 150)
			else
				inputBox.TextColor3 = Color3.fromRGB(255, 100, 100)
			end
			
			statsLabel.Text = string.format("%d\nWPM", wpm)
		end
	end
end

-- Show UI with smooth animation
local function showUI()
	if not screenGui then
		createUI()
		loadAnimation()
	end
	
	-- Smooth slide down from top animation
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.02, 0) -- Position at top with small margin
	})
	tween:Play()
	
	-- Start test
	task.wait(0.3)
	startNewTest()
end

-- Hide UI with smooth animation
local function hideUI()
	if not screenGui then return end
	
	-- Stop animation if playing
	if animationTrack and animationTrack.IsPlaying then
		animationTrack:Stop(0.2)
	end
	
	if typingSpeedConnection then
		typingSpeedConnection:Disconnect()
		typingSpeedConnection = nil
	end
	
	-- Smooth slide up animation (hide)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, -0.2, 0) -- Slide up and off screen
	})
	tween:Play()
	
	-- Cleanup
	tween.Completed:Wait()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
	
	isTyping = false
end

-- Connect input box
local function connectInputBox()
	if inputBox then
		inputBox:GetPropertyChangedSignal("Text"):Connect(onTextChanged)
	end
end

-- Remote event handler
local function onRemoteEvent(action)
	if action == "ShowUI" then
		showUI()
		connectInputBox()
	elseif action == "HideUI" then
		hideUI()
	end
end

-- Wait for remote event
local remoteEvent = ReplicatedStorage:WaitForChild("TypingTestRemote", 10)
if remoteEvent then
	remoteEvent.OnClientEvent:Connect(onRemoteEvent)
end

-- Cleanup on character death
humanoid.Died:Connect(function()
	hideUI()
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	animator = humanoid:WaitForChild("Animator")
	
	-- Reload animation
	animationTrack = nil
	loadAnimation()
end)
