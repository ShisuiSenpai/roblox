# 🔧 Convert TypingTestClient to Multiplayer

Instead of replacing the entire file, make these targeted changes to your existing `TypingTestClient.lua`:

---

## Step 1: Add Multiplayer Variables

**At the top, after line 113 (`local canLeaveSeat = false`), ADD:**

```lua
-- Multiplayer variables
local matchRemote = nil
local isMultiplayer = false
local waitingForRound = false
local lastWPMReport = 0
local WPM_REPORT_INTERVAL = 0.2 -- Report WPM every 0.2 seconds
```

---

## Step 2: Initialize Match Remote

**After line 283 (`local remoteEvent = ReplicatedStorage:WaitForChild...`), ADD:**

```lua
-- Initialize match remote for multiplayer
matchRemote = ReplicatedStorage:FindFirstChild("MatchRemote")
```

---

## Step 3: Modify `startNewTest()` Function

**Find the `startNewTest()` function (around line 665) and REPLACE with:**

```lua
-- Start new test
local function startNewTest(sentence, timeLimit, round)
	-- Use provided values or defaults (for solo mode)
	currentSentence = sentence or SENTENCES[math.random(1, #SENTENCES)]
	currentTimeLimit = timeLimit or currentTimeLimit
	currentRound = round or currentRound
	
	-- Reset UI
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
```

---

## Step 4: Modify Completion Handler

**In `onTextChanged()`, find the completion section (around line 780) and REPLACE:**

```lua
		-- OLD CODE (line ~780):
		-- Show success with smooth animation
		resultLabel.Text = string.format("✓ %d WPM - Next round!", finalWPM)
		-- ... rest of success code ...
		
		-- Auto-continue after brief pause
		task.wait(2)
		startNewTest()
```

**WITH:**

```lua
		-- Show success with smooth animation
		if isMultiplayer then
			resultLabel.Text = string.format("✓ %d WPM - Waiting for others...", finalWPM)
		else
			resultLabel.Text = string.format("✓ %d WPM - Next round!", finalWPM)
		end
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

		-- Increase difficulty (for solo)
		if not isMultiplayer then
			currentRound = currentRound + 1
			currentTimeLimit = math.max(MIN_TIME, currentTimeLimit - TIME_REDUCTION)
		end
		
		-- Report completion to match controller
		if isMultiplayer and matchRemote then
			matchRemote:FireServer("PlayerComplete", finalWPM, timeTaken)
			waitingForRound = true
		else
			-- Solo mode: auto-continue
			task.wait(2)
			startNewTest()
		end
```

---

## Step 5: Modify Timeout Handler

**In `onTimeout()` function (around line 447), FIND:**

```lua
	-- Kill the player's character
	if character and humanoid then
		humanoid.Health = 0
	end
	
	hideUI()
```

**REPLACE WITH:**

```lua
	-- Report failure to match controller
	if isMultiplayer and matchRemote then
		matchRemote:FireServer("PlayerFail")
	end

	-- Kill the player's character
	if character and humanoid then
		humanoid.Health = 0
	end
	
	hideUI()
```

---

## Step 6: Add WPM Reporting

**In `onTextChanged()`, in the section where WPM is calculated (around line 830), ADD:**

```lua
			statsLabel.Text = string.format("%d\nWPM", wpm)
			
			-- ADD THIS: Report WPM to match controller
			if isMultiplayer and matchRemote then
				local currentTime = tick()
				if currentTime - lastWPMReport >= WPM_REPORT_INTERVAL then
					matchRemote:FireServer("UpdateWPM", wpm)
					lastWPMReport = currentTime
				end
			end
```

---

## Step 7: Add Match Event Listeners

**At the VERY END of the file, BEFORE the last print statement, ADD:**

```lua
-- Listen for multiplayer match events
if matchRemote then
	matchRemote.OnClientEvent:Connect(function(action, ...)
		if action == "StartRound" then
			local sentence, timeLimit, round = ...
			isMultiplayer = true
			waitingForRound = false
			
			-- Start the round with server-provided data
			startNewTest(sentence, timeLimit, round)
			
		elseif action == "LobbyCountdown" then
			local timeLeft = ...
			if resultLabel and resultLabel.Parent then
				resultLabel.Text = "Starting in " .. timeLeft .. "..."
				resultLabel.Visible = true
			end
			
		elseif action == "MatchStarting" then
			if resultLabel and resultLabel.Parent then
				resultLabel.Text = "Match starting..."
				resultLabel.Visible = true
			end
			
		elseif action == "MatchEnd" then
			local winnerName = ...
			if resultLabel and resultLabel.Parent then
				if winnerName == player.Name then
					resultLabel.Text = "🏆 YOU WIN! 🏆"
					resultLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
				elseif winnerName then
					resultLabel.Text = winnerName .. " wins!"
					resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				else
					resultLabel.Text = "Match ended"
					resultLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
				end
				resultLabel.Visible = true
			end
		end
	end)
end
```

---

## Step 8: Modify `showUI()` Function

**In `showUI()` function (around line 850), FIND:**

```lua
	-- Reset progression
	currentRound = 1
	currentTimeLimit = INITIAL_TIME
```

**REPLACE WITH:**

```lua
	-- Reset progression (only for solo mode)
	if not isMultiplayer then
		currentRound = 1
		currentTimeLimit = INITIAL_TIME
	end
	
	-- Check if we're in multiplayer
	if matchRemote then
		isMultiplayer = true
		waitingForRound = true
		
		-- Show waiting message
		if resultLabel then
			resultLabel.Text = "Waiting for players..."
			resultLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
			resultLabel.Visible = true
		end
	else
		isMultiplayer = false
	end
```

---

## Step 9: Modify `showUI()` Start Test Call

**Still in `showUI()`, FIND the end:**

```lua
	-- Start test
	task.wait(0.3)
	startNewTest()
end
```

**REPLACE WITH:**

```lua
	-- Start test (only in solo mode)
	if not isMultiplayer then
		task.wait(0.3)
		startNewTest()
	end
	-- In multiplayer, wait for server to send StartRound
end
```

---

## ✅ That's It!

Save your modified `TypingTestClient.lua` and you're done!

### Summary of Changes:

1. ✅ Added multiplayer variables
2. ✅ Modified `startNewTest()` to accept server parameters
3. ✅ Modified completion handler to report to server
4. ✅ Modified timeout to report failure
5. ✅ Added WPM reporting
6. ✅ Added match event listeners
7. ✅ Modified `showUI()` for multiplayer mode
8. ✅ Prevented auto-start in multiplayer

### Testing:

**Solo Mode (1 player):**
- Should work exactly as before
- Auto-starts rounds
- No waiting

**Multiplayer Mode (2+ players):**
- Waits for server to start round
- All players get same sentence
- Reports progress to match
- Waits for next round signal

---

**Ready to race! 🎮🔥**
