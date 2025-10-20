# 🔊 Sound System Guide

## Overview

The typing test now has a complete sound system with 5 different sound effects:

1. **Typing Correct** 🟢 - Soft click when typing the right letter
2. **Typing Wrong** 🔴 - Error beep when making a mistake
3. **Countdown Tick** ⏰ - Tick sound for 3, 2, 1
4. **Round Win** 🎉 - Success chime when completing a round
5. **Round Lose** ❌ - Fail sound when time runs out

---

## 🎵 Sound IDs Setup

### Where to Configure
Open `TypingTestClient.lua` and find lines **35-42**:

```lua
local SOUND_IDS = {
	TYPING_CORRECT = "rbxassetid://12221967",   -- Replace with your sound ID
	TYPING_WRONG = "rbxassetid://12221984",     -- Replace with your sound ID
	COUNTDOWN_TICK = "rbxassetid://12221976",   -- Replace with your sound ID
	ROUND_WIN = "rbxassetid://12221982",        -- Replace with your sound ID
	ROUND_LOSE = "rbxassetid://12221991",       -- Replace with your sound ID
}
```

### How to Get Sound IDs

1. **Go to Roblox Creator Marketplace**
   - Visit: https://create.roblox.com/marketplace/audio

2. **Find or Upload Sounds**
   - Search for free sounds OR upload your own
   - Click on the sound you want

3. **Copy the Asset ID**
   - Look at the URL: `https://create.roblox.com/marketplace/asset/12221967`
   - The number at the end is the asset ID: `12221967`

4. **Replace in the Script**
   - Change `12221967` to your sound's ID
   - Format: `"rbxassetid://YOUR_ID_HERE"`

---

## 🎚️ Volume Settings

### Where to Configure
Lines **44-50** in `TypingTestClient.lua`:

```lua
local SOUND_VOLUMES = {
	TYPING_CORRECT = 0.3,    -- Quiet (plays frequently)
	TYPING_WRONG = 0.5,      -- Slightly louder
	COUNTDOWN_TICK = 0.6,    -- Clear countdown
	ROUND_WIN = 0.7,         -- Celebratory
	ROUND_LOSE = 0.6,        -- Clear failure
}
```

**Volume Range:** `0.0` (silent) to `1.0` (maximum)

**Recommendations:**
- **Typing sounds:** Keep low (0.2-0.4) - they play very frequently
- **Countdown/Results:** Medium (0.5-0.7) - important feedback
- **Round Win:** Higher (0.6-0.8) - celebration!

---

## 🎛️ Disable Sounds

### Turn Off All Sounds
Line **34** in `TypingTestClient.lua`:

```lua
local SOUNDS_ENABLED = true  -- Change to false to disable
```

Set to `false` to completely disable the sound system.

---

## 🎯 How the Sound System Works

### Sound Pool Technology
- **Pre-loads all sounds** when you sit in the chair
- **Reuses sound instances** instead of creating new ones
- **No lag** from constantly creating/destroying sounds
- **Optimized for performance**

### Typing Sound Cooldown
- **50ms cooldown** between typing sounds (line 109)
- Prevents sound spam when typing very fast
- Adjustable: Change `TYPING_SOUND_COOLDOWN = 0.05` (in seconds)

### Pitch Variation
- **Typing sounds:** ±10% pitch variation for natural feel
- **Error sounds:** ±5% pitch variation
- Makes repetitive sounds less monotonous

---

## 🎵 Sound Recommendations

### Good Free Sounds on Roblox

**Typing Correct:**
- Soft keyboard click
- Gentle "tap" sound
- Light mechanical click

**Typing Wrong:**
- Short error beep
- "Bonk" sound
- Warning tone

**Countdown Tick:**
- Clock tick
- Digital beep
- Short "blip" sound

**Round Win:**
- Success chime
- Level up sound
- Achievement sound
- Bell ding

**Round Lose:**
- Buzzer
- Game over sound
- Sad trombone
- Error alert

---

## 🎼 When Sounds Play

| Sound | Trigger | Frequency |
|-------|---------|-----------|
| **TYPING_CORRECT** | Each correct letter typed | Very frequent |
| **TYPING_WRONG** | Each wrong letter typed | Occasional |
| **COUNTDOWN_TICK** | Each countdown number (3, 2, 1) | Once per second |
| **ROUND_WIN** | Complete sentence successfully | Once per round |
| **ROUND_LOSE** | Run out of time | Once (game over) |

---

## ⚙️ Advanced Configuration

### Adjust Typing Sound Cooldown

**Line 109:**
```lua
local TYPING_SOUND_COOLDOWN = 0.05  -- 50 milliseconds
```

**Faster typing sounds:**
```lua
local TYPING_SOUND_COOLDOWN = 0.03  -- 30ms (more frequent)
```

**Slower typing sounds:**
```lua
local TYPING_SOUND_COOLDOWN = 0.1   -- 100ms (less frequent)
```

### Adjust Pitch Variation

**Find the `playTypingSound` function (around line 333):**

```lua
if isCorrect then
	playSound("TYPING_CORRECT", 10) -- ±10% pitch
else
	playSound("TYPING_WRONG", 5)    -- ±5% pitch
end
```

**More variation:**
```lua
playSound("TYPING_CORRECT", 20)  -- ±20% pitch
```

**No variation:**
```lua
playSound("TYPING_CORRECT", 0)   -- Consistent pitch
```

---

## 🐛 Troubleshooting

### Sounds Don't Play
1. ✅ Check `SOUNDS_ENABLED = true`
2. ✅ Verify sound IDs are correct
3. ✅ Make sure sounds are public/approved on Roblox
4. ✅ Check volume isn't set to 0
5. ✅ Test in actual game (not Studio Play Solo)

### Sounds Are Too Loud/Quiet
- Adjust the `SOUND_VOLUMES` table
- Typing sounds should be quieter (0.2-0.4)
- Results sounds can be louder (0.6-0.8)

### Sounds Lag the Game
- The sound pool system prevents this!
- If still lagging, check your sound file sizes
- Use shorter sound clips (< 1 second for typing sounds)

### Wrong Sound Plays
- Double-check you pasted the correct asset ID
- Make sure format is: `"rbxassetid://12345678"`
- No spaces or extra characters

---

## 📊 Sound System Performance

### Optimizations Included

✅ **Sound Pool** - Sounds created once, reused forever  
✅ **Preloading** - Sounds loaded when sitting, no delay  
✅ **Cooldown System** - Prevents sound spam/lag  
✅ **Client-Side Only** - No server communication needed  
✅ **Pitch Variation** - Adds variety without extra sounds  
✅ **Instant Restart** - Stops and plays immediately  

### Performance Metrics

| Aspect | Impact |
|--------|--------|
| Memory | ~5 Sound instances (minimal) |
| Network | Zero (client-side only) |
| CPU | Negligible (optimized) |
| Lag | None (with sound pool) |

---

## 🎨 Example Sound Setup

### Option 1: Minimal/Subtle
```lua
SOUND_VOLUMES = {
	TYPING_CORRECT = 0.2,   -- Very quiet
	TYPING_WRONG = 0.3,     -- Subtle
	COUNTDOWN_TICK = 0.4,   -- Soft
	ROUND_WIN = 0.5,        -- Gentle
	ROUND_LOSE = 0.4,       -- Subtle
}
```

### Option 2: Balanced (Default)
```lua
SOUND_VOLUMES = {
	TYPING_CORRECT = 0.3,
	TYPING_WRONG = 0.5,
	COUNTDOWN_TICK = 0.6,
	ROUND_WIN = 0.7,
	ROUND_LOSE = 0.6,
}
```

### Option 3: Loud/Energetic
```lua
SOUND_VOLUMES = {
	TYPING_CORRECT = 0.4,
	TYPING_WRONG = 0.7,
	COUNTDOWN_TICK = 0.8,
	ROUND_WIN = 0.9,
	ROUND_LOSE = 0.8,
}
```

---

## 🎯 Quick Setup Checklist

- [ ] Find 5 sounds on Roblox (or upload your own)
- [ ] Copy each sound's asset ID
- [ ] Replace IDs in `SOUND_IDS` table (lines 35-42)
- [ ] Adjust volumes if needed (lines 44-50)
- [ ] Test in game
- [ ] Tweak volumes based on preference
- [ ] Done! 🎉

---

## 💡 Pro Tips

1. **Keep typing sounds short** - < 0.2 seconds for best feel
2. **Use different pitches** - Makes sounds less repetitive
3. **Test volumes together** - Some sounds might overpower others
4. **Match game tone** - Casual game = softer sounds, competitive = louder
5. **Consider players** - Some prefer minimal sounds, make volumes adjustable

---

## 🔧 Disable Individual Sounds

Want to disable just one sound? Set its ID to empty:

```lua
local SOUND_IDS = {
	TYPING_CORRECT = "",  -- Disabled
	TYPING_WRONG = "rbxassetid://12221984",  -- Enabled
	-- etc...
}
```

Or set volume to 0:

```lua
local SOUND_VOLUMES = {
	TYPING_CORRECT = 0,  -- Muted
	TYPING_WRONG = 0.5,  -- Normal
	-- etc...
}
```

---

## 📝 Summary

The sound system:
- ✅ **Optimized** with sound pooling
- ✅ **Customizable** volumes and IDs
- ✅ **Smart cooldown** prevents spam
- ✅ **Pitch variation** for variety
- ✅ **Easy to configure** - just change IDs
- ✅ **Zero lag** - pre-loaded and reused
- ✅ **Client-side** - no server load

**Just replace the sound IDs and you're good to go! 🎵**
