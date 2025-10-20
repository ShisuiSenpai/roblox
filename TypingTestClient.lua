--[[
	Typing Test Client - LocalScript with Timer System
	
	SETUP:
	Place this LocalScript in StarterPlayer > StarterPlayerScripts
	
	Features:
	- Timer slider showing time remaining
	- Progressive difficulty (timer gets faster each round)
	- Auto-kick on timeout
	- Smooth UI animations
	- Real-time typing validation
	- Animation speed based on typing speed
--]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Configuration
local ANIMATION_ID = "rbxassetid://114838686458565" -- Replace with your animation ID
local MIN_ANIMATION_SPEED = 0.5
local MAX_ANIMATION_SPEED = 3.0
local WPM_FOR_MAX_SPEED = 100

-- Timer Configuration
local INITIAL_TIME = 15 -- Starting time in seconds
local MIN_TIME = 5 -- Minimum time allowed (difficulty cap)
local TIME_REDUCTION = 1 -- Seconds reduced each successful round
local COUNTDOWN_TIME = 3 -- Countdown before each round starts

-- Sound Configuration
local SOUNDS_ENABLED = true -- Set to false to disable all sounds
local SOUND_IDS = {
	TYPING_CORRECT = "rbxassetid://12221967",      -- Soft click (correct typing)
	TYPING_WRONG = "rbxassetid://12221984",        -- Error beep (wrong typing)
	COUNTDOWN_TICK = "rbxassetid://12221976",      -- Tick sound (3, 2, 1)
	COUNTDOWN_GO = "rbxassetid://12221981",        -- "type!" sound (go!)
	ROUND_WIN = "rbxassetid://12221982",           -- Success chime (round complete)
	ROUND_LOSE = "rbxassetid://12221991",          -- Fail sound (timeout)
}

-- Sound Volume Settings (0.0 to 1.0)
local SOUND_VOLUMES = {
	TYPING_CORRECT = 0.3,    -- Quiet for frequent sounds
	TYPING_WRONG = 0.5,      -- Slightly louder for errors
	COUNTDOWN_TICK = 0.6,    -- Clear countdown
	COUNTDOWN_GO = 0.7,      -- "type!" emphasis
	ROUND_WIN = 0.7,         -- Celebratory
	ROUND_LOSE = 0.6,        -- Clear failure
}

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
local timerBar = nil
local timerBackground = nil
local roundLabel = nil
local countdownLabel = nil
local contentGlow = nil

local animationTrack = nil
local currentSentence = ""
local startTime = 0
local isTyping = false
local typingSpeedConnection = nil
local timerConnection = nil
local lastTypingTime = 0
local currentWPM = 0

local currentRound = 1
local currentTimeLimit = INITIAL_TIME
local timeRemaining = INITIAL_TIME
local isCountingDown = false
local canType = false

-- Sound system variables
local soundPool = {}
local lastTypingSoundTime = 0
local TYPING_SOUND_COOLDOWN = 0.05 -- Minimum time between typing sounds (50ms)
local previousTextLength = 0

-- Seat lock variables
local currentSeat = nil
local seatLockConnection = nil
local isSeated = false
local canLeaveSeat = false

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
	mainFrame.Size = UDim2.new(0, 700, 0, 200) -- Increased for countdown below
	mainFrame.Position = UDim2.new(0.5, 0, -0.3, 0) -- Start off-screen (top)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	-- Container for sentence and input (with subtle background)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 0, 90)
	contentFrame.Position = UDim2.new(0, 0, 0, 0)
	contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	contentFrame.BackgroundTransparency = 0.7
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = mainFrame

	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 12)
	contentCorner.Parent = contentFrame

	contentGlow = Instance.new("UIStroke")
	contentGlow.Name = "Glow"
	contentGlow.Color = Color3.fromRGB(100, 200, 255)
	contentGlow.Thickness = 1
	contentGlow.Transparency = 0.6
	contentGlow.Parent = contentFrame

	-- Sentence Display
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

	-- Input Box
	inputBox = Instance.new("TextBox")
	inputBox.Name = "InputBox"
	inputBox.Size = UDim2.new(1, -120, 0, 35)
	inputBox.Position = UDim2.new(0, 15, 0, 50)
	inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	inputBox.BackgroundTransparency = 0.9
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

	-- Stats Label (WPM + Round)
	statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "StatsLabel"
	statsLabel.Size = UDim2.new(0, 100, 0, 60)
	statsLabel.Position = UDim2.new(1, -110, 0, 5)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = "0\nWPM"
	statsLabel.Font = Enum.Font.GothamBold
	statsLabel.TextSize = 20
	statsLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
	statsLabel.TextXAlignment = Enum.TextXAlignment.Center
	statsLabel.TextYAlignment = Enum.TextYAlignment.Top
	statsLabel.Parent = contentFrame

	-- Round Label
	roundLabel = Instance.new("TextLabel")
	roundLabel.Name = "RoundLabel"
	roundLabel.Size = UDim2.new(0, 100, 0, 25)
	roundLabel.Position = UDim2.new(1, -110, 0, 60)
	roundLabel.BackgroundTransparency = 1
	roundLabel.Text = "Round 1"
	roundLabel.Font = Enum.Font.GothamMedium
	roundLabel.TextSize = 14
	roundLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	roundLabel.TextXAlignment = Enum.TextXAlignment.Center
	roundLabel.Parent = contentFrame

	-- Timer Background (the track)
	timerBackground = Instance.new("Frame")
	timerBackground.Name = "TimerBackground"
	timerBackground.Size = UDim2.new(1, 0, 0, 8)
	timerBackground.Position = UDim2.new(0, 0, 0, 100)
	timerBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	timerBackground.BackgroundTransparency = 0.5
	timerBackground.BorderSizePixel = 0
	timerBackground.Parent = mainFrame

	local timerBgCorner = Instance.new("UICorner")
	timerBgCorner.CornerRadius = UDim.new(0, 4)
	timerBgCorner.Parent = timerBackground

	-- Timer Bar (the fill)
	timerBar = Instance.new("Frame")
	timerBar.Name = "TimerBar"
	timerBar.Size = UDim2.new(1, 0, 1, 0)
	timerBar.Position = UDim2.new(0, 0, 0, 0)
	timerBar.BackgroundColor3 = Color3.fromRGB(100, 220, 255)
	timerBar.BorderSizePixel = 0
	timerBar.Parent = timerBackground

	local timerBarCorner = Instance.new("UICorner")
	timerBarCorner.CornerRadius = UDim.new(0, 4)
	timerBarCorner.Parent = timerBar

	-- Removed old gradient - will use transparency instead

	-- Result Label
	resultLabel = Instance.new("TextLabel")
	resultLabel.Name = "ResultLabel"
	resultLabel.Size = UDim2.new(1, 0, 0, 30)
	resultLabel.Position = UDim2.new(0, 0, 0, 115)
	resultLabel.BackgroundTransparency = 1
	resultLabel.Text = ""
	resultLabel.Font = Enum.Font.GothamBold
	resultLabel.TextSize = 16
	resultLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	resultLabel.TextXAlignment = Enum.TextXAlignment.Center
	resultLabel.Visible = false
	resultLabel.Parent = mainFrame

	-- Countdown Label (below the UI, casual)
	countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.Size = UDim2.new(1, 0, 0, 60)
	countdownLabel.Position = UDim2.new(0, 0, 0, 125) -- Below timer bar
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Text = ""
	countdownLabel.Font = Enum.Font.GothamMedium
	countdownLabel.TextSize = 32
	countdownLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
	countdownLabel.TextXAlignment = Enum.TextXAlignment.Center
	countdownLabel.TextYAlignment = Enum.TextYAlignment.Center
	countdownLabel.Visible = false
	countdownLabel.TextTransparency = 0
	countdownLabel.Parent = mainFrame

	-- Add subtle glow to countdown
	local countdownStroke = Instance.new("UIStroke")
	countdownStroke.Color = Color3.fromRGB(100, 220, 255)
	countdownStroke.Thickness = 0
	countdownStroke.Transparency = 0.3
	countdownStroke.Parent = countdownLabel
end

-- Sound System: Create sound pool for optimized playback
local function createSoundPool()
	if not SOUNDS_ENABLED then return end
	
	-- Create a container for sounds
	local soundContainer = Instance.new("Folder")
	soundContainer.Name = "TypingSounds"
	soundContainer.Parent = player.PlayerGui
	
	-- Create sound instances for each sound type
	for soundName, soundId in pairs(SOUND_IDS) do
		local sound = Instance.new("Sound")
		sound.Name = soundName
		sound.SoundId = soundId
		sound.Volume = SOUND_VOLUMES[soundName] or 0.5
		sound.PlaybackSpeed = 1
		sound.Parent = soundContainer
		
		-- Preload the sound
		sound:Play()
		sound:Stop()
		
		-- Store in pool
		soundPool[soundName] = sound
	end
end

-- Play sound from pool (optimized - reuses instances)
local function playSound(soundName, pitchVariation)
	if not SOUNDS_ENABLED or not soundPool[soundName] then return end
	
	local sound = soundPool[soundName]
	
	-- Apply pitch variation if specified
	if pitchVariation then
		sound.PlaybackSpeed = 1 + (math.random(-pitchVariation, pitchVariation) / 100)
	else
		sound.PlaybackSpeed = 1
	end
	
	-- Play sound (stop first if already playing for instant restart)
	sound:Stop()
	sound:Play()
end

-- Play typing sound with cooldown to prevent spam
local function playTypingSound(isCorrect)
	local currentTime = tick()
	
	-- Cooldown check
	if currentTime - lastTypingSoundTime < TYPING_SOUND_COOLDOWN then
		return
	end
	
	lastTypingSoundTime = currentTime
	
	-- Play appropriate sound with slight pitch variation for variety
	if isCorrect then
		playSound("TYPING_CORRECT", 10) -- ±10% pitch variation
	else
		playSound("TYPING_WRONG", 5) -- ±5% pitch variation
	end
end

-- Cleanup sound pool
local function cleanupSounds()
	if soundPool and next(soundPool) then
		for _, sound in pairs(soundPool) do
			if sound then
				sound:Stop()
			end
		end
	end
end

-- Lock player in seat (prevent exit)
local function lockInSeat(seat)
	if not seat then return end
	
	currentSeat = seat
	isSeated = true
	canLeaveSeat = false
	
	-- Disable jumping immediately
	if humanoid then
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		humanoid.Sit = true -- Force sitting
	end
	
	-- Monitor seat and force player to stay seated AGGRESSIVELY
	if seatLockConnection then
		seatLockConnection:Disconnect()
	end
	
	seatLockConnection = RunService.Heartbeat:Connect(function()
		if not canLeaveSeat and isSeated and humanoid and humanoid.Health > 0 then
			-- Force seated state every frame
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
			
		-- If not sitting, force sitting
		if not humanoid.Sit then
			humanoid.Sit = true
		end
		
		-- If not in the seat, force back
		if currentSeat and currentSeat.Occupant ~= humanoid then
			currentSeat:Sit(humanoid)
		end
		end
	end)
end

-- Unlock seat (allow player to leave)
local function unlockSeat()
	canLeaveSeat = true
	isSeated = false
	
	-- Notify server to unlock seat
	local remoteEvent = ReplicatedStorage:FindFirstChild("TypingTestRemote")
	if remoteEvent then
		remoteEvent:FireServer("UnlockSeat")
	end
	
	-- Disconnect seat lock
	if seatLockConnection then
		seatLockConnection:Disconnect()
		seatLockConnection = nil
	end
	
	-- Re-enable jumping
	if humanoid then
		humanoid.JumpPower = 50 -- Default Roblox jump power
		humanoid.JumpHeight = 7.2 -- Default Roblox jump height
	end
	
	currentSeat = nil
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
	local words = #text / 5
	local minutes = timeInSeconds / 60
	return math.floor(words / minutes)
end

-- Update animation speed based on typing speed
local function updateAnimationSpeed()
	if not animationTrack or not animationTrack.IsPlaying then return end

	local speedMultiplier = math.clamp(currentWPM / WPM_FOR_MAX_SPEED, 0, 1)
	local animSpeed = MIN_ANIMATION_SPEED + (speedMultiplier * (MAX_ANIMATION_SPEED - MIN_ANIMATION_SPEED))

	animationTrack:AdjustSpeed(animSpeed)
end

-- Stop all timers and animations
local function cleanup()
	if typingSpeedConnection then
		typingSpeedConnection:Disconnect()
		typingSpeedConnection = nil
	end

	if timerConnection then
		timerConnection:Disconnect()
		timerConnection = nil
	end

	if animationTrack and animationTrack.IsPlaying then
		animationTrack:Stop(0.2)
	end

	isTyping = false
end

-- Handle timeout (kicked from chair)
local function onTimeout()
	cleanup()

	-- Lock input
	if inputBox then
		inputBox.TextEditable = false
		inputBox.Active = false
	end
	canType = false
	
	-- Reset glow smoothly
	if contentGlow then
		local glowReset = TweenService:Create(contentGlow,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 0.6,
			Thickness = 1
		})
		glowReset:Play()
	end

	-- Play lose sound
	playSound("ROUND_LOSE")

	-- Show failure message with smooth fade
	resultLabel.Text = "⏱ Time's up! Try again!"
	resultLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	resultLabel.TextTransparency = 1
	resultLabel.Visible = true
	
	local failFade = TweenService:Create(resultLabel,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		TextTransparency = 0
	})
	failFade:Play()

	-- Notify server to kick player
	local remoteEvent = ReplicatedStorage:FindFirstChild("TypingTestRemote")
	if remoteEvent then
		remoteEvent:FireServer("Timeout")
	end

	-- Kill player after brief delay
	task.wait(1.5)
	
	-- Kill the player's character
	if character and humanoid then
		humanoid.Health = 0
	end
	
	hideUI()
end

-- Update timer bar
local function updateTimer()
	if not isTyping then return end

	local elapsed = tick() - startTime
	timeRemaining = currentTimeLimit - elapsed

	if timeRemaining <= 0 then
		timeRemaining = 0
		onTimeout()
		return
	end

	-- Update bar size with smooth tween
	local progress = timeRemaining / currentTimeLimit
	local targetSize = UDim2.new(progress, 0, 1, 0)
	
	-- Smooth size transition
	local sizeTween = TweenService:Create(timerBar, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {
		Size = targetSize
	})
	sizeTween:Play()

	-- Keep blue color but adjust transparency based on progress
	timerBar.BackgroundColor3 = Color3.fromRGB(100, 220, 255)
	
	-- More transparent = less time remaining
	local transparency = 1 - progress -- As progress decreases, transparency increases
	transparency = math.clamp(transparency * 0.7, 0, 0.7) -- Max 70% transparent
	
	local colorTween = TweenService:Create(timerBar, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
		BackgroundTransparency = transparency
	})
	colorTween:Play()
end

-- Countdown before round starts
local function startCountdown(callback)
	isCountingDown = true
	canType = false

	-- Lock input during countdown
	if inputBox then
		inputBox.TextEditable = false
		inputBox.Active = false
		inputBox.Text = ""
	end

	-- Show countdown label
	if countdownLabel then
		countdownLabel.Visible = true
	end

	-- Count down from 3 to 1 with smooth, casual animations
	for i = COUNTDOWN_TIME, 1, -1 do
		if countdownLabel then
			countdownLabel.Text = tostring(i)
			countdownLabel.TextSize = 24
			countdownLabel.TextTransparency = 1
			
			-- Play countdown tick sound
			playSound("COUNTDOWN_TICK")

			-- Smooth fade in + scale up
			local fadeIn = TweenService:Create(countdownLabel, 
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0,
				TextSize = 36
			})
			fadeIn:Play()
			fadeIn.Completed:Wait()
			
			task.wait(0.4)
			
			-- Smooth fade out
			local fadeOut = TweenService:Create(countdownLabel,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1,
				TextSize = 28
			})
			fadeOut:Play()
			fadeOut.Completed:Wait()
		end
		task.wait(0.1)
	end

	-- Show "type!" with casual bounce
	if countdownLabel then
		countdownLabel.Text = "type!"
		countdownLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
		countdownLabel.TextSize = 20
		countdownLabel.TextTransparency = 1
		
		-- Play "go" sound
		playSound("COUNTDOWN_GO")
		
		-- Smooth bounce in
		local goTween = TweenService:Create(countdownLabel, 
			TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			TextTransparency = 0,
			TextSize = 40
		})
		goTween:Play()
		goTween.Completed:Wait()
		
		task.wait(0.3)

		-- Smooth fade out
		local fadeTween = TweenService:Create(countdownLabel, 
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
			TextSize = 32
		})
		fadeTween:Play()
		fadeTween.Completed:Wait()
		
		countdownLabel.Visible = false
		countdownLabel.TextTransparency = 0
		countdownLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
	end

	isCountingDown = false
	canType = true

	-- Unlock input
	if inputBox then
		inputBox.TextEditable = true
		inputBox.Active = true
	end

	-- Execute callback
	if callback then
		callback()
	end
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
	roundLabel.Text = "Round " .. currentRound
	isTyping = false
	startTime = 0
	currentWPM = 0
	timeRemaining = currentTimeLimit
	canType = false
	previousTextLength = 0

	-- Reset timer bar with smooth animation
	timerBar.BackgroundColor3 = Color3.fromRGB(100, 220, 255)
	timerBar.BackgroundTransparency = 0
	local resetTween = TweenService:Create(timerBar, 
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0)
	})
	resetTween:Play()

	-- Reset glow
	if contentGlow then
		contentGlow.Transparency = 0.6
		contentGlow.Thickness = 1
	end

	-- Start countdown, then focus input with smooth effect
	startCountdown(function()
		if inputBox then
			inputBox:CaptureFocus()
			
			-- Subtle highlight on focus
			local focusTween = TweenService:Create(inputBox,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0.85
			})
			focusTween:Play()
		end
	end)
end

-- Check typing progress
local function onTextChanged()
	local inputText = inputBox.Text

	-- Prevent typing during countdown or after round ends
	if not canType or isCountingDown then
		inputBox.Text = ""
		return
	end

	-- Start timing on first character
	if #inputText == 1 and not isTyping then
		isTyping = true
		startTime = tick()

		-- Glow pulse when typing starts
		if contentGlow then
			local glowPulse = TweenService:Create(contentGlow,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 0.2,
				Thickness = 2
			})
			glowPulse:Play()
		end

		-- Start animation
		if animationTrack then
			animationTrack:Play(0.1)
		end

		-- Start timer update loop
		if timerConnection then
			timerConnection:Disconnect()
		end
		timerConnection = RunService.Heartbeat:Connect(updateTimer)

		-- Start monitoring typing speed
		if typingSpeedConnection then
			typingSpeedConnection:Disconnect()
		end

		typingSpeedConnection = RunService.Heartbeat:Connect(function()
			local currentTime = tick()
			local elapsed = currentTime - startTime

			if elapsed > 0 and #inputText > 0 then
				currentWPM = calculateWPM(inputText, elapsed)

				local timeSinceLastType = currentTime - lastTypingTime
				if timeSinceLastType < 0.5 then
					updateAnimationSpeed()
				else
					if animationTrack and animationTrack.IsPlaying then
						animationTrack:AdjustSpeed(MIN_ANIMATION_SPEED)
					end
				end
			end
		end)
	end

	lastTypingTime = tick()

	-- Check for completion
	if inputText == currentSentence then
		local timeTaken = tick() - startTime

		-- Must complete before time runs out
		if timeRemaining <= 0 then
			return
		end

		local finalWPM = calculateWPM(inputText, timeTaken)

		cleanup()
		
		-- Play success sound
		playSound("ROUND_WIN")

		-- Lock input
		if inputBox then
			inputBox.TextEditable = false
			inputBox.Active = false
		end
		canType = false
		
		-- Reset glow smoothly
		if contentGlow then
			local glowReset = TweenService:Create(contentGlow,
				TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				Transparency = 0.6,
				Thickness = 1
			})
			glowReset:Play()
		end

		-- Show success with smooth animation
		resultLabel.Text = string.format("✓ %d WPM - Next round!", finalWPM)
		resultLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
		resultLabel.TextTransparency = 1
		resultLabel.Visible = true
		statsLabel.Text = string.format("%d\nWPM", finalWPM)
		
		-- Smooth fade in
		local resultFade = TweenService:Create(resultLabel,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		})
		resultFade:Play()

		-- Increase difficulty
		currentRound = currentRound + 1
		currentTimeLimit = math.max(MIN_TIME, currentTimeLimit - TIME_REDUCTION)

		-- Auto-continue after brief pause
		task.wait(2)
		startNewTest()

	elseif #inputText > 0 then
		-- Update stats during typing
		local elapsed = tick() - startTime
		if elapsed > 0 then
			local wpm = calculateWPM(inputText, elapsed)

			-- Check accuracy
			local correct = inputText == string.sub(currentSentence, 1, #inputText)
			
			-- Play typing sound when a new character is added (not when deleting)
			if #inputText > previousTextLength then
				playTypingSound(correct)
			end
			previousTextLength = #inputText

			-- Color code accuracy with smooth transition
			local targetColor = correct and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 100, 100)
			local colorTween = TweenService:Create(inputBox,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
				TextColor3 = targetColor
			})
			colorTween:Play()

			statsLabel.Text = string.format("%d\nWPM", wpm)
		end
	end
end

-- Show UI with smooth animation
local function showUI()
	if not screenGui then
		createUI()
		loadAnimation()
		createSoundPool() -- Initialize sounds
	end

	-- Reset progression
	currentRound = 1
	currentTimeLimit = INITIAL_TIME

	-- Smooth slide down with bounce
	mainFrame.Position = UDim2.new(0.5, 0, -0.3, 0)
	local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.02, 0)
	})
	tween:Play()
	
	-- Fade in effect for content
	if mainFrame:FindFirstChild("ContentFrame") then
		local contentFrame = mainFrame.ContentFrame
		contentFrame.BackgroundTransparency = 1
		local fadeTween = TweenService:Create(contentFrame,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 0.7
		})
		fadeTween:Play()
	end

	-- Start test
	task.wait(0.3)
	startNewTest()
end

-- Hide UI with smooth animation
function hideUI()
	if not screenGui then return end

	cleanup()
	cleanupSounds() -- Stop all sounds
	unlockSeat() -- Allow player to leave seat

	-- Fade out content first
	if mainFrame:FindFirstChild("ContentFrame") then
		local contentFrame = mainFrame.ContentFrame
		local fadeTween = TweenService:Create(contentFrame,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		})
		fadeTween:Play()
	end
	
	-- Smooth slide up animation
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local tween = TweenService:Create(mainFrame, tweenInfo, {
		Position = UDim2.new(0.5, 0, -0.3, 0)
	})
	tween:Play()

	-- Cleanup
	tween.Completed:Wait()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
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
	unlockSeat() -- Unlock seat before hiding UI
	hideUI()
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	animator = humanoid:WaitForChild("Animator")

	animationTrack = nil
	loadAnimation()
end)
