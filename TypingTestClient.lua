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
	
	-- Main Frame (container)
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 400)
	mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0) -- Start off-screen
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- UI Corner for main frame
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 20)
	mainCorner.Parent = mainFrame
	
	-- Drop shadow effect
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0, -15, 0, -15)
	shadow.Size = UDim2.new(1, 30, 1, 30)
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.7
	shadow.ZIndex = 0
	shadow.Parent = mainFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 50)
	title.Position = UDim2.new(0, 20, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "⚡ TYPING TEST"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = mainFrame
	
	-- Sentence Display
	sentenceLabel = Instance.new("TextLabel")
	sentenceLabel.Name = "SentenceLabel"
	sentenceLabel.Size = UDim2.new(1, -40, 0, 80)
	sentenceLabel.Position = UDim2.new(0, 20, 0, 90)
	sentenceLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	sentenceLabel.Text = "Loading..."
	sentenceLabel.Font = Enum.Font.Gotham
	sentenceLabel.TextSize = 20
	sentenceLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	sentenceLabel.TextWrapped = true
	sentenceLabel.Parent = mainFrame
	
	local sentenceCorner = Instance.new("UICorner")
	sentenceCorner.CornerRadius = UDim.new(0, 10)
	sentenceCorner.Parent = sentenceLabel
	
	-- Input Box
	inputBox = Instance.new("TextBox")
	inputBox.Name = "InputBox"
	inputBox.Size = UDim2.new(1, -40, 0, 50)
	inputBox.Position = UDim2.new(0, 20, 0, 190)
	inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	inputBox.PlaceholderText = "Start typing here..."
	inputBox.Text = ""
	inputBox.Font = Enum.Font.Gotham
	inputBox.TextSize = 18
	inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	inputBox.ClearTextOnFocus = false
	inputBox.TextXAlignment = Enum.TextXAlignment.Left
	inputBox.Parent = mainFrame
	
	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 10)
	inputCorner.Parent = inputBox
	
	local inputPadding = Instance.new("UIPadding")
	inputPadding.PaddingLeft = UDim.new(0, 15)
	inputPadding.PaddingRight = UDim.new(0, 15)
	inputPadding.Parent = inputBox
	
	-- Stats Label
	statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "StatsLabel"
	statsLabel.Size = UDim2.new(1, -40, 0, 30)
	statsLabel.Position = UDim2.new(0, 20, 0, 260)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "WPM: 0 | Accuracy: 100%"
	statsLabel.Font = Enum.Font.GothamMedium
	statsLabel.TextSize = 16
	statsLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.Parent = mainFrame
	
	-- Result Label
	resultLabel = Instance.new("TextLabel")
	resultLabel.Name = "ResultLabel"
	resultLabel.Size = UDim2.new(1, -40, 0, 60)
	resultLabel.Position = UDim2.new(0, 20, 0, 300)
	resultLabel.BackgroundTransparency = 1
	resultLabel.Text = ""
	resultLabel.Font = Enum.Font.GothamBold
	resultLabel.TextSize = 22
	resultLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	resultLabel.TextWrapped = true
	resultLabel.Visible = false
	resultLabel.Parent = mainFrame
	
	-- Instructions
	local instructions = Instance.new("TextLabel")
	instructions.Name = "Instructions"
	instructions.Size = UDim2.new(1, -40, 0, 30)
	instructions.Position = UDim2.new(0, 20, 0, 360)
	instructions.BackgroundTransparency = 1
	instructions.Text = "💡 Type the sentence above as fast as you can!"
	instructions.Font = Enum.Font.Gotham
	instructions.TextSize = 14
	instructions.TextColor3 = Color3.fromRGB(150, 150, 150)
	instructions.TextXAlignment = Enum.TextXAlignment.Center
	instructions.Parent = mainFrame
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
	statsLabel.Text = "WPM: 0 | Accuracy: 100%"
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
		resultLabel.Text = string.format("✓ Complete! %d WPM in %.1f seconds", finalWPM, timeTaken)
		resultLabel.Visible = true
		statsLabel.Text = string.format("WPM: %d | Accuracy: 100%%", finalWPM)
		
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
			
			statsLabel.Text = string.format("WPM: %d | Accuracy: %d%%", wpm, accuracy)
		end
	end
end

-- Show UI with smooth animation
local function showUI()
	if not screenGui then
		createUI()
		loadAnimation()
	end
	
	-- Smooth slide up animation
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.5, 0)
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
	
	-- Smooth slide down animation
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, 1.5, 0)
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
