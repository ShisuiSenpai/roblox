# 🎵 Sound Quick Start

## 30-Second Setup

### 1. Find Your Sounds
Go to: https://create.roblox.com/marketplace/audio

Find 6 sounds:
- ✅ Typing click (correct)
- ✅ Error beep (wrong)
- ✅ Tick sound (countdown 3,2,1)
- ✅ "Go" sound (type!)
- ✅ Success chime (win)
- ✅ Fail sound (lose)

### 2. Get Asset IDs
From URL: `https://create.roblox.com/marketplace/asset/12221967`  
Copy number: `12221967`

### 3. Update Script
Open `TypingTestClient.lua`, find lines **35-43**:

```lua
local SOUND_IDS = {
	TYPING_CORRECT = "rbxassetid://12221967",   -- Paste your ID here
	TYPING_WRONG = "rbxassetid://12221984",     -- Paste your ID here
	COUNTDOWN_TICK = "rbxassetid://12221976",   -- Paste your ID here
	COUNTDOWN_GO = "rbxassetid://12221981",     -- Paste your ID here (NEW!)
	ROUND_WIN = "rbxassetid://12221982",        -- Paste your ID here
	ROUND_LOSE = "rbxassetid://12221991",       -- Paste your ID here
}
```

**Replace each number with your sound's ID!**

### 4. Done! 🎉
Test in-game and adjust volumes if needed (lines 45-52).

---

## Quick Volume Adjustment

Too loud? Change these (lines **45-52**):

```lua
local SOUND_VOLUMES = {
	TYPING_CORRECT = 0.3,    -- Lower = quieter
	TYPING_WRONG = 0.5,
	COUNTDOWN_TICK = 0.6,
	COUNTDOWN_GO = 0.7,      -- NEW! "type!" sound
	ROUND_WIN = 0.7,
	ROUND_LOSE = 0.6,
}
```

**Range:** 0.0 (silent) to 1.0 (max)

---

## Disable Sounds

Set to `false` on line **34**:

```lua
local SOUNDS_ENABLED = false
```

---

## When Sounds Play

| Event | Sound |
|-------|-------|
| Type correct letter | Soft click 🟢 |
| Type wrong letter | Error beep 🔴 |
| Countdown 3...2...1 | Tick ⏰ |
| "type!" appears | Go/start sound 🚀 |
| Complete round | Success! 🎉 |
| Time runs out | Fail ❌ (then you die 💀) |

---

## Recommended Sound Types

**Typing Correct:** Short, soft click (< 0.2s)  
**Typing Wrong:** Quick error beep  
**Countdown:** Clock tick or digital beep  
**Round Win:** Success chime, level up sound  
**Round Lose:** Buzzer, game over sound  

---

**Need more help? Check `SOUND_SYSTEM_GUIDE.md` for full details!**
