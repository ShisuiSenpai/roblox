# Typing Test Game - Complete Setup Instructions

## 📋 Overview
This is a Roblox typing test game where players sit in a chair and must type sentences within a time limit. The timer gets progressively faster with each successful round. If time runs out, the player is kicked from the chair.

---

## 🎯 Features
- ⏱️ **Timer slider** - blue bar that fades to transparent as time runs out
- 📈 **Progressive difficulty** - timer gets 1 second faster each round
- 💀 **Death on timeout** - players DIE when time runs out (no escape!)
- 🔒 **Seat lock** - players CANNOT leave chair once seated (must play or die!)
- ✅ **Continuous gameplay** - automatically advances to next sentence on success
- 🎨 **Minimal UI** - smooth, polished, transparent modern style
- 🏃 **Animation speed** - changes based on typing speed (WPM)
- ⏳ **3-second countdown** - casual countdown below UI (3... 2... 1... type!)
- 🔒 **Input locking** - prevents typing during countdown and after round ends
- ✨ **Smooth animations** - everything transitions smoothly with professional polish
- 💫 **Glow effects** - UI pulses when you start typing for visual feedback
- 🔊 **Sound system** - optimized audio feedback for typing, countdown, wins, and losses

---

## 📁 File Placement

### 1. Client Script (TypingTestClient.lua)
**Location:** `StarterPlayer > StarterPlayerScripts`

**Steps:**
1. Open Roblox Studio
2. In Explorer, navigate to **StarterPlayer**
3. Click on **StarterPlayerScripts**
4. Right-click and select **Insert Object > LocalScript**
5. Rename it to **TypingTestClient**
6. Delete all default code
7. Copy and paste the entire contents of `TypingTestClient.lua`

### 2. Server Script (ChairController.lua)
**Location:** Inside your Chair model in Workspace

**Steps:**
1. In Explorer, find your **Chair** model in **Workspace**
2. Right-click on the Chair model
3. Select **Insert Object > Script** (NOT LocalScript!)
4. Rename it to **ChairController**
5. Delete all default code
6. Copy and paste the entire contents of `ChairController.lua`

---

## 🪑 Chair Model Setup

Your Chair model must have this exact hierarchy:

```
Chair (Model)
  ├─ Seat (Seat object)
  ├─ Part1 (Part - any part of the chair)
  │   └─ ProximityPrompt
  └─ ChairController (Script - the server script you just added)
```

### Creating the Required Components:

#### 1. Seat Object
- In your Chair model, you should have a **Seat** part
- Make sure it's named **"Seat"**
- Properties to check:
  - ClassName: `Seat` (not just a regular Part)
  - Anchored: `true` (recommended)

#### 2. ProximityPrompt
- Select **Part1** (or any part of your chair)
- Right-click and select **Insert Object > ProximityPrompt**
- The script will automatically configure it

---

## 🎮 Animation Setup

**IMPORTANT:** You need to set your animation ID!

1. Open `TypingTestClient` (the LocalScript)
2. Find line 24:
   ```lua
   local ANIMATION_ID = "rbxassetid://114838686458565"
   ```
3. Replace the number with **your actual animation ID**
4. Example: If your animation ID is 123456789, change it to:
   ```lua
   local ANIMATION_ID = "rbxassetid://123456789"
   ```

---

## 🔊 Sound Setup

**NEW:** The game now has sound effects! Here's how to set them up:

### Quick Setup
1. Find 5 sounds on Roblox: https://create.roblox.com/marketplace/audio
2. Get each sound's asset ID from the URL
3. Open `TypingTestClient` and find lines **35-42**
4. Replace the sound IDs with yours:

```lua
local SOUND_IDS = {
	TYPING_CORRECT = "rbxassetid://YOUR_ID",    -- Correct typing
	TYPING_WRONG = "rbxassetid://YOUR_ID",      -- Wrong typing
	COUNTDOWN_TICK = "rbxassetid://YOUR_ID",    -- 3, 2, 1 ticks
	ROUND_WIN = "rbxassetid://YOUR_ID",         -- Round complete
	ROUND_LOSE = "rbxassetid://YOUR_ID",        -- Timeout
}
```

### Sound Recommendations
- **Typing Correct:** Soft keyboard click
- **Typing Wrong:** Short error beep
- **Countdown Tick:** Clock tick or digital beep
- **Round Win:** Success chime or level up sound
- **Round Lose:** Buzzer or game over sound

### Disable Sounds (Optional)
If you don't want sounds, set line **34** to:
```lua
local SOUNDS_ENABLED = false
```

**For detailed sound setup, see `SOUND_QUICK_START.md`**

---

## ⚙️ Configuration Options

You can customize these settings in the **TypingTestClient** script:

### Timer Settings (Lines 27-31)
```lua
local INITIAL_TIME = 15        -- Starting time in seconds
local MIN_TIME = 5             -- Minimum time (difficulty cap)
local TIME_REDUCTION = 1       -- Seconds reduced per round
local COUNTDOWN_TIME = 3       -- Countdown before each round
```

**Examples:**
- **Easier:** Set `INITIAL_TIME = 20`, `TIME_REDUCTION = 0.5`, `COUNTDOWN_TIME = 5`
- **Harder:** Set `INITIAL_TIME = 10`, `TIME_REDUCTION = 1.5`, `COUNTDOWN_TIME = 2`
- **Very Hard:** Set `INITIAL_TIME = 8`, `MIN_TIME = 3`, `COUNTDOWN_TIME = 1`
- **No Countdown:** Set `COUNTDOWN_TIME = 0` (instant start, but not recommended)

### Animation Settings (Lines 25-26)
```lua
local MIN_ANIMATION_SPEED = 0.5
local MAX_ANIMATION_SPEED = 3.0
local WPM_FOR_MAX_SPEED = 100
```

### Sentences
You can add/remove sentences in the `SENTENCES` table (Lines 33-44).

---

## 🎨 UI Style

The UI maintains the minimal, transparent style:
- **Semi-transparent black background** (70% transparent)
- **Subtle blue glow** outline
- **Timer bar** with gradient (blue → orange → red as time runs out)
- **WPM counter** on the right side
- **Round indicator** showing current round
- **Smooth animations** for all transitions

### UI Layout:
```
┌─────────────────────────────────────────┐
│ [Sentence to type...]        [WPM] │
│ [Your input here...]          [Round] │
└─────────────────────────────────────────┘
▓▓▓▓▓▓▓▓▓▓▓░░░░░░ ← Timer bar (fills left to right)
```

---

## 🧪 Testing Your Setup

1. **Place the scripts** in the correct locations
2. **Update the animation ID**
3. **Test in-game** (not in Studio's Play Solo - use the actual game)
4. **Walk up to the chair** and press the ProximityPrompt key
5. **You should sit down** and see the UI appear at the top
6. **Start typing** the sentence shown
7. **Watch the timer bar** decrease
8. **Complete before time runs out!**

---

## 🐛 Troubleshooting

### UI doesn't appear when sitting
- Check that **TypingTestClient** is in `StarterPlayer > StarterPlayerScripts`
- Check the Output window for errors
- Make sure **ReplicatedStorage** contains a **TypingTestRemote** RemoteEvent

### ProximityPrompt doesn't work
- Verify **Part1** exists in the Chair model
- Verify **ProximityPrompt** is a child of Part1
- Check that **ChairController** script is in the Chair model

### Timer doesn't work / Player doesn't get kicked
- Make sure you're testing in the **actual game**, not Studio Play Solo
- Check both scripts are running (check Output for errors)
- Verify the **RemoteEvent** exists in ReplicatedStorage

### Animation doesn't play
- Replace the `ANIMATION_ID` with your actual animation ID
- Make sure the animation is published and approved
- Check that your character has a Humanoid and Animator

### Can't sit in chair
- Make sure the Seat object is actually a **Seat** (not a regular Part)
- Check that the Seat is properly positioned in the model
- Verify no one else is already sitting

---

## 🎯 How It Works

1. **Player approaches chair** → ProximityPrompt appears
2. **Player triggers prompt** → Character sits in chair
3. **Server tells client** → Show typing UI
4. **3-second countdown** → "3... 2... 1... GO!" (input locked)
5. **Input unlocks** → Player can start typing
6. **Timer starts when typing begins** → Progress bar decreases
7. **Player completes sentence in time** → Input locks → Round increases, timer gets faster, new sentence
8. **Player runs out of time** → Input locks → Client tells server → Server kicks player from chair → UI hides

---

## 📊 Difficulty Progression

| Round | Time Limit | Difficulty |
|-------|-----------|------------|
| 1     | 15s       | Easy       |
| 2     | 14s       | Easy       |
| 3     | 13s       | Medium     |
| 4     | 12s       | Medium     |
| 5     | 11s       | Hard       |
| 10    | 6s        | Very Hard  |
| 11+   | 5s        | Max        |

---

## 💡 Tips for Players

- **Start slow** - Accuracy is more important than speed initially
- **Watch the timer bar** - Colors change to warn you (blue → orange → red)
- **Practice common words** - Many sentences reuse the same words
- **Stay focused** - One mistake can cost you the round
- **Build muscle memory** - The more you play, the faster you'll get

---

## 🎨 Customization Ideas

Want to make it your own? Try these:

1. **Change colors:** Edit the `Color3.fromRGB()` values
2. **Add sounds:** Add sound effects for success/failure
3. **Different sentences:** Replace the SENTENCES table with themed text
4. **Leaderboard:** Track highest round reached
5. **Rewards:** Give points/badges for reaching certain rounds
6. **Multiplayer:** Add multiple chairs for racing

---

## ✅ Quick Checklist

- [ ] TypingTestClient.lua placed in StarterPlayer > StarterPlayerScripts
- [ ] ChairController.lua placed inside Chair model in Workspace
- [ ] Animation ID updated in TypingTestClient
- [ ] Chair model has Seat object named "Seat"
- [ ] Part1 has ProximityPrompt as child
- [ ] Tested in actual game (not Play Solo)
- [ ] UI appears when sitting
- [ ] Timer bar works correctly
- [ ] Player gets kicked on timeout
- [ ] Rounds progress successfully

---

**🎉 You're all set! Enjoy your typing test game!**
