# 🎮 Roblox Typing Test System - Complete Setup Guide

## 📋 System Overview

This system creates an interactive typing test that activates when players sit in a chair. Features include:
- ✅ Proximity prompt to sit in chair
- ✅ Smooth UI animations (slides up/down)
- ✅ Real-time typing validation
- ✅ WPM (Words Per Minute) calculation
- ✅ Animation that plays and speeds up based on typing speed
- ✅ Accuracy tracking
- ✅ Auto-restart with new sentences
- ✅ Fully optimized with proper cleanup

---

## 🚀 Quick Setup (5 Steps)

### Step 1: Setup the Chair Model

1. In **Workspace**, find or create your **Chair** model
2. Ensure it has this exact hierarchy:

```
Workspace
└─ Chair (Model)
   ├─ Seat (Seat object)
   ├─ ProximityPrompt (ProximityPrompt)
   └─ ChairController (Script) ← Add this
```

**To create the hierarchy:**
- Right-click Chair → Insert Object → **Seat** (name it "Seat")
- Right-click Chair → Insert Object → **ProximityPrompt** (name it "ProximityPrompt")
- Right-click Chair → Insert Object → **Script** (name it "ChairController")

### Step 2: Add Server Script to Chair

1. Open the **ChairController** Script in the Chair model
2. Copy the contents of `ChairController.lua` into it
3. This script handles the proximity prompt and sitting logic

### Step 3: Add Client Script to StarterPlayerScripts

1. Navigate to: **StarterPlayer → StarterPlayerScripts**
2. Insert a **LocalScript** (Right-click → Insert Object → LocalScript)
3. Rename it to "TypingTestClient"
4. Copy the contents of `TypingTestClient.lua` into it

### Step 4: Configure Your Animation

1. Upload your animation to Roblox (if not already done)
2. Get your animation ID
3. Open **TypingTestClient** LocalScript
4. Find line 21: `local ANIMATION_ID = "rbxassetid://YOUR_ANIMATION_ID_HERE"`
5. Replace with your animation ID:
   ```lua
   local ANIMATION_ID = "rbxassetid://507766388"
   ```

### Step 5: Test!

1. **Play** the game in Roblox Studio
2. Walk up to the chair
3. Press the proximity prompt button to sit
4. Start typing when the UI appears!

---

## ⚙️ Configuration & Customization

### Animation Speed Settings

In `TypingTestClient.lua`, adjust these values (lines 20-23):

```lua
local MIN_ANIMATION_SPEED = 0.5      -- Slowest animation speed (when not typing)
local MAX_ANIMATION_SPEED = 3.0      -- Fastest animation speed (when typing fast)
local WPM_FOR_MAX_SPEED = 100        -- WPM needed to reach max speed
```

**Examples:**
- **Gentle speed changes:** MIN = 0.8, MAX = 1.5
- **Extreme speed changes:** MIN = 0.3, MAX = 5.0
- **Easier to max out:** WPM_FOR_MAX_SPEED = 50

### Adding Your Own Sentences

In `TypingTestClient.lua`, find the `SENTENCES` table (line 25):

```lua
local SENTENCES = {
	"The quick brown fox jumps over the lazy dog",
	"Practice makes perfect when typing fast",
	-- Add more sentences here!
	"Your custom sentence here",
	"Another sentence to type",
}
```

**Tips for good sentences:**
- Keep them 40-60 characters long
- Use common words for better flow
- Mix letters, numbers, and punctuation for challenge
- Avoid extremely rare words

### Proximity Prompt Settings

In `ChairController.lua`, customize the prompt (lines 16-19):

```lua
proximityPrompt.ActionText = "Sit"                    -- Button text
proximityPrompt.ObjectText = "Chair"                  -- Object name
proximityPrompt.HoldDuration = 0                      -- Hold time (0 = instant)
proximityPrompt.MaxActivationDistance = 10            -- Distance to activate
```

### UI Styling

The UI is fully customizable in `TypingTestClient.lua`:

**Main Frame (line 73):**
```lua
mainFrame.Size = UDim2.new(0, 700, 0, 120)           -- Width x Height (compact)
mainFrame.BackgroundTransparency = 1                  -- Fully transparent
```

**Content Frame (line 81):**
```lua
contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
contentFrame.BackgroundTransparency = 0.7             -- Semi-transparent (adjust 0-1)
```

**Text Colors:**
- Sentence: Line 62 `Color3.fromRGB(230, 230, 230)` - Light gray
- Stats: Line 92 `Color3.fromRGB(100, 220, 255)` - Cyan
- Success: Line 104 `Color3.fromRGB(100, 255, 150)` - Green
- Correct Typing: `Color3.fromRGB(100, 255, 150)` - Green
- Wrong Typing: `Color3.fromRGB(255, 100, 100)` - Red

---

## 🎯 How It Works

### Animation Speed Logic

The animation speed is dynamically calculated based on typing speed:

1. **Not typing**: Animation plays at MIN_ANIMATION_SPEED (0.5x)
2. **Typing slowly** (0-50 WPM): Speed gradually increases
3. **Typing fast** (100+ WPM): Animation reaches MAX_ANIMATION_SPEED (3x)

Formula: `speed = MIN + (WPM/100) × (MAX - MIN)`

### Typing Detection

- ✅ **Green text**: Correct typing
- ❌ **Red text**: Incorrect typing (mistakes)
- 📊 **Real-time WPM**: Updates as you type
- 🎯 **Accuracy**: 100% only if perfect match

### Auto-Restart System

After completing a sentence:
1. Shows completion message with WPM and time
2. Waits 3 seconds
3. Automatically loads a new random sentence
4. Player can start typing again

---

## 🔧 Troubleshooting

### UI doesn't appear when sitting:
1. ✓ Check that `TypingTestRemote` exists in ReplicatedStorage (auto-created)
2. ✓ Verify TypingTestClient is in StarterPlayerScripts
3. ✓ Check Output for any errors (F9 in Studio)

### Animation doesn't play:
1. ✓ Verify animation ID is correct (include "rbxassetid://")
2. ✓ Make sure animation is uploaded to your account/group
3. ✓ Check animation is compatible with R15/R6 (whichever you're using)

### Animation doesn't change speed:
1. ✓ Type faster to increase WPM (try 50+ WPM)
2. ✓ Verify MIN and MAX speeds are different
3. ✓ Check WPM_FOR_MAX_SPEED value (lower = easier to reach max)

### Player can't sit:
1. ✓ Verify Seat object is properly configured
2. ✓ Check ChairController script is in the Chair model
3. ✓ Ensure ProximityPrompt is named exactly "ProximityPrompt"

### Typing validation not working:
1. ✓ Make sure you're typing exactly as shown (case-sensitive)
2. ✓ Check for extra spaces at the beginning/end
3. ✓ Verify the sentence is typed completely

---

## 📊 Performance Optimizations Included

✅ **Event Cleanup**: All connections properly disconnected  
✅ **Tween Efficiency**: Smooth animations without lag  
✅ **Heartbeat Usage**: Efficient real-time speed updates  
✅ **Single Animation Instance**: Loaded once and reused  
✅ **Debouncing**: Prevents multiple instances  
✅ **Memory Management**: UI destroyed when not in use  
✅ **Character Respawn Handling**: Proper re-initialization  
✅ **Death Cleanup**: Stops animation and hides UI on death  

---

## 🎨 Advanced Customization

### Change Animation Based on Performance

Add this to `onTextChanged()` function after line 289:

```lua
-- Different animations for different WPM ranges
if currentWPM > 80 then
    -- Load super fast animation
elseif currentWPM > 40 then
    -- Load normal animation
else
    -- Load slow animation
end
```

### Add Sound Effects

Add this when typing starts (line 261):

```lua
local typingSound = Instance.new("Sound")
typingSound.SoundId = "rbxassetid://YOUR_SOUND_ID"
typingSound.Parent = character.HumanoidRootPart
typingSound.Volume = 0.3
typingSound.Looped = true
typingSound:Play()
```

### Leaderboard Integration

Track high scores by saving WPM to a leaderboard:

```lua
-- After line 313 (when test completes)
local remoteFunction = ReplicatedStorage:FindFirstChild("SaveScore")
if remoteFunction then
    remoteFunction:InvokeServer(finalWPM)
end
```

### Multiple Chairs

Simply duplicate the Chair model with the script inside. Each chair will work independently!

---

## 📁 File Structure Summary

```
Workspace
└─ Chair
   ├─ Seat
   ├─ ProximityPrompt  
   └─ ChairController (Script) ← Server-side

ReplicatedStorage
└─ TypingTestRemote (RemoteEvent) ← Auto-created

StarterPlayer
└─ StarterPlayerScripts
   └─ TypingTestClient (LocalScript) ← Client-side
```

---

## 🎯 Testing Checklist

Before publishing, test these scenarios:

- [ ] Walk up to chair and activate proximity prompt
- [ ] UI slides up smoothly
- [ ] Can type in the text box
- [ ] Animation plays when typing starts
- [ ] Animation speeds up when typing faster
- [ ] WPM updates in real-time
- [ ] Completion shows correct stats
- [ ] New sentence loads after 3 seconds
- [ ] Standing up hides UI smoothly
- [ ] Animation stops when leaving chair
- [ ] No errors in Output window (F9)

---

## 💡 Tips for Best Results

1. **Animation Choice**: Use a repeatable animation (like typing, working, or gestures)
2. **Sentence Length**: 40-60 characters works best for engagement
3. **Speed Range**: Keep MIN_ANIMATION_SPEED ≥ 0.3 to avoid looking frozen
4. **UI Position**: Default center works well, but test on different screen sizes
5. **Accessibility**: Consider adding larger text size options

---

## 🆘 Need Help?

**Common Issues:**

1. **"Animation failed to load"**
   - Verify the animation ID is correct
   - Check animation ownership/permissions

2. **"RemoteEvent not found"**
   - The script creates it automatically
   - Make sure ChairController runs first

3. **UI appears but input doesn't work**
   - Check that inputBox.Text property is changeable
   - Verify no other scripts are interfering

4. **Animation plays but doesn't loop**
   - Animation itself must be set to loop in Animation Editor
   - Or keep `animationTrack.Looped = true` (line 232)

---

**System created with ❤️ for Roblox developers**

Happy typing! 🚀⌨️
