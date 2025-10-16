# 🚀 Quick Reference - Typing Test System

## 📦 Files Created

1. **`ChairController.lua`** - Server script (goes in Chair model)
2. **`TypingTestClient.lua`** - Client script (goes in StarterPlayerScripts)
3. **`TYPING_TEST_SETUP.md`** - Complete setup guide
4. **`QUICK_REFERENCE.md`** - This file

---

## ⚡ 30-Second Setup

### 1. Chair Hierarchy (Workspace)
```
Chair (Model)
├─ Seat (Seat)
├─ ProximityPrompt (ProximityPrompt)
└─ ChairController (Script) ← Paste ChairController.lua here
```

### 2. Client Script
- **Location**: `StarterPlayer > StarterPlayerScripts`
- **Type**: LocalScript
- **Content**: Paste `TypingTestClient.lua`
- **Configure**: Set your animation ID on line 21

### 3. Test
- Walk to chair → Activate prompt → Type!

---

## 🎯 Key Features

| Feature | Description |
|---------|-------------|
| **Proximity Prompt** | Press to sit in chair |
| **Minimal UI** | Transparent, top-positioned design |
| **Smooth Animations** | Slides down from top when seated |
| **Typing Test** | Random sentences from pool |
| **WPM Display** | Compact WPM counter on the right |
| **Animation Control** | Speed based on typing speed |
| **Color Feedback** | Green = correct, Red = mistake |
| **Auto-Restart** | New sentence after 3 seconds |

---

## ⚙️ Quick Config

### Animation Speed
```lua
-- In TypingTestClient.lua (lines 20-23)
MIN_ANIMATION_SPEED = 0.5    -- Slow (not typing)
MAX_ANIMATION_SPEED = 3.0    -- Fast (typing fast)
WPM_FOR_MAX_SPEED = 100      -- WPM for max speed
```

### Add Sentences
```lua
-- In TypingTestClient.lua (line 25)
local SENTENCES = {
    "Your sentence here",
    "Another sentence",
    -- Add more...
}
```

### Proximity Distance
```lua
-- In ChairController.lua (line 19)
proximityPrompt.MaxActivationDistance = 10  -- studs
```

---

## 🎨 Customization Quick List

| What to Change | Where | Line |
|----------------|-------|------|
| Animation ID | TypingTestClient.lua | 23 |
| Min Animation Speed | TypingTestClient.lua | 24 |
| Max Animation Speed | TypingTestClient.lua | 25 |
| WPM for Max Speed | TypingTestClient.lua | 26 |
| Sentences | TypingTestClient.lua | 29-40 |
| UI Size | TypingTestClient.lua | 73 |
| UI Transparency | TypingTestClient.lua | 81 (0.7 = 30% visible) |
| Text Colors | TypingTestClient.lua | 62, 92, 104 |
| Proximity Distance | ChairController.lua | 19 |
| Prompt Text | ChairController.lua | 16-17 |

---

## 🔍 How Animation Speed Works

```
WPM = 0    → Speed = 0.5x (MIN)
WPM = 50   → Speed = 1.75x (MIDDLE)
WPM = 100+ → Speed = 3.0x (MAX)
```

Formula: `speed = MIN + (WPM/100) × (MAX - MIN)`

---

## 🐛 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| UI doesn't show | Check RemoteEvent in ReplicatedStorage |
| Animation doesn't play | Verify animation ID (include "rbxassetid://") |
| Can't sit | Check Seat object exists and is named "Seat" |
| Speed doesn't change | Type faster (50+ WPM) or lower WPM_FOR_MAX_SPEED |
| Text always red | Must match exactly (case-sensitive) |

---

## 📊 Optimization Features

✅ Proper event cleanup (no memory leaks)  
✅ Single animation instance (reused)  
✅ Efficient Heartbeat connections  
✅ UI destroyed when not needed  
✅ Debouncing prevents spam  
✅ Character respawn handling  
✅ Death cleanup included  

---

## 🎯 Animation Speed Examples

### Gentle (Good for beginners)
```lua
MIN_ANIMATION_SPEED = 0.8
MAX_ANIMATION_SPEED = 1.5
WPM_FOR_MAX_SPEED = 60
```

### Moderate (Default)
```lua
MIN_ANIMATION_SPEED = 0.5
MAX_ANIMATION_SPEED = 3.0
WPM_FOR_MAX_SPEED = 100
```

### Extreme (Advanced players)
```lua
MIN_ANIMATION_SPEED = 0.2
MAX_ANIMATION_SPEED = 5.0
WPM_FOR_MAX_SPEED = 120
```

---

## 📁 Required Hierarchy Summary

**Workspace:**
- Chair model with Seat, ProximityPrompt, and ChairController script

**ReplicatedStorage:**
- TypingTestRemote (auto-created by script)

**StarterPlayer > StarterPlayerScripts:**
- TypingTestClient (LocalScript)

---

## 💡 Pro Tips

1. Test typing speed at [typing.com](https://www.typing.com) to calibrate WPM settings
2. Use animations that loop naturally (typing, working, idle variations)
3. Keep sentences 40-60 characters for best engagement
4. Add difficulty levels by changing sentence complexity
5. Consider adding sound effects for each keystroke
6. Create multiple chairs for multiplayer races!

---

**Need detailed help?** → See `TYPING_TEST_SETUP.md`

**Ready to go!** 🚀
