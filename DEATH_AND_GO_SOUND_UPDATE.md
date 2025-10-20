# 💀 Death on Loss + "type!" Sound Update

## What's Changed

### 1. 💀 Player Dies When Losing
- **Before:** Just kicked from chair on timeout
- **After:** Player's character **dies** when time runs out
- Adds higher stakes and consequence

### 2. 🔊 New "type!" Sound
- **Added:** Sound plays when "type!" appears after countdown
- **Total sounds:** Now **6 sounds** instead of 5
- Makes the "GO!" moment more exciting

---

## 🎯 How It Works

### Timeout Sequence
```
Time runs out
    ↓
Play lose sound 🔊
    ↓
Show "Time's up!" message
    ↓
Wait 1.5 seconds
    ↓
Kill player (Health = 0) 💀
    ↓
UI hides
    ↓
Player respawns
```

### Countdown Sequence
```
3... (tick sound)
    ↓
2... (tick sound)
    ↓
1... (tick sound)
    ↓
"type!" (NEW GO sound!) 🔊
    ↓
Start typing!
```

---

## 🔧 Configuration

### New Sound ID (Line 38)
```lua
local SOUND_IDS = {
	TYPING_CORRECT = "rbxassetid://12221967",
	TYPING_WRONG = "rbxassetid://12221984",
	COUNTDOWN_TICK = "rbxassetid://12221976",
	COUNTDOWN_GO = "rbxassetid://12221981",    -- NEW! "type!" sound
	ROUND_WIN = "rbxassetid://12221982",
	ROUND_LOSE = "rbxassetid://12221991",
}
```

### New Volume Setting (Line 47)
```lua
local SOUND_VOLUMES = {
	TYPING_CORRECT = 0.3,
	TYPING_WRONG = 0.5,
	COUNTDOWN_TICK = 0.6,
	COUNTDOWN_GO = 0.7,    -- NEW! "type!" volume
	ROUND_WIN = 0.7,
	ROUND_LOSE = 0.6,
}
```

---

## 🎵 Recommended "type!" Sounds

Good sound options for COUNTDOWN_GO:
- **Whoosh sound** - Energy/momentum
- **Bell ding** - Start signal
- **Power-up sound** - Energizing
- **Quick fanfare** - Exciting start
- **Digital "ready" beep** - Clean/modern
- **Quick drum hit** - Punchy start

**Keep it short:** < 0.5 seconds for best feel

---

## 💀 Death Mechanic

### Why Death Instead of Just Kick?

**Advantages:**
- ✅ Higher stakes = more engaging
- ✅ Clear consequence for failure
- ✅ Forces player to try again fresh
- ✅ More dramatic/impactful
- ✅ Auto-respawn = easy retry

### What Happens
1. Timer runs out
2. Player sees "Time's up!" message
3. 1.5 seconds later → player dies
4. Character respawns at spawn point
5. Player can try again

### Disable Death (If Needed)

If you want to go back to just kicking, comment out the death code around line 451:

```lua
-- Kill the player's character
-- if character and humanoid then
--     humanoid.Health = 0
-- end
```

---

## 🎮 Updated Player Experience

### Before Update
```
Typing → Timeout → Kicked from chair → Walk back → Try again
```

### After Update
```
Typing → Timeout → Lose sound → Death 💀 → Respawn → Try again
```

**More dramatic and engaging!**

---

## 📊 Sound Summary

Now you have **6 sounds** total:

| Sound | When | Volume | New? |
|-------|------|--------|------|
| TYPING_CORRECT | Correct letter | 0.3 | No |
| TYPING_WRONG | Wrong letter | 0.5 | No |
| COUNTDOWN_TICK | 3, 2, 1 | 0.6 | No |
| COUNTDOWN_GO | "type!" | 0.7 | ✅ **YES** |
| ROUND_WIN | Complete round | 0.7 | No |
| ROUND_LOSE | Timeout | 0.6 | No |

---

## 🎯 Setup Checklist

- [ ] Update TypingTestClient script
- [ ] Add 6th sound ID for COUNTDOWN_GO (line 38)
- [ ] Find a good "go/start" sound
- [ ] Test in game
- [ ] Adjust COUNTDOWN_GO volume if needed
- [ ] Confirm player dies on timeout
- [ ] Done! 💀🔊

---

## 🔊 Finding the "type!" Sound

### Option 1: Roblox Marketplace
https://create.roblox.com/marketplace/audio

Search for:
- "whoosh"
- "start"
- "ready"
- "go"
- "power up"

### Option 2: Upload Your Own
1. Find a short sound effect (< 0.5s)
2. Upload to Roblox
3. Wait for approval
4. Use the asset ID

---

## 💡 Pro Tips

1. **"type!" sound should be energizing** - It signals "GO!"
2. **Keep it short** - < 0.5 seconds
3. **Make it louder** than countdown ticks (0.7 vs 0.6)
4. **Different from tick sound** - Distinct "start" feel
5. **Test volume balance** - Should be noticeable but not jarring

---

## 🎨 Recommended Sound Combinations

### Minimal/Clean
- Tick: Soft beep
- Go: Quick digital "ready" beep

### Energetic/Fun  
- Tick: Clock tick
- Go: Whoosh or power-up sound

### Professional/Serious
- Tick: Digital countdown
- Go: Bell ding or alert tone

### Playful/Casual
- Tick: Gentle beep
- Go: Happy chime or boing

---

## 🐛 Troubleshooting

### "type!" sound doesn't play
- Check COUNTDOWN_GO sound ID is correct
- Verify sound is public/approved
- Make sure SOUNDS_ENABLED = true

### Player doesn't die on timeout
- Check you're testing in actual game
- Verify humanoid exists
- Check output for errors

### Death is too harsh
- Comment out the death code (see above)
- Or add a respawn delay/grace period

---

## 📝 Technical Details

### Death Code
```lua
-- Kill the player's character
if character and humanoid then
	humanoid.Health = 0
end
```

Simple and effective - sets health to 0, triggering death and respawn.

### "type!" Sound Code
```lua
-- Play "go" sound
playSound("COUNTDOWN_GO")
```

Plays when the "type!" text appears after countdown.

---

## 🎯 Summary

**Two simple but impactful changes:**

1. **💀 Death on loss** - Higher stakes, more dramatic
2. **🔊 "type!" sound** - Better countdown feel

Both make the game more engaging and polished!

---

**Update your script and add that 6th sound! 🚀**
