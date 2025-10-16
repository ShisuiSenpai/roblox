# Roblox Animation Controller - Setup Guide

## 📋 Quick Setup

### Step 1: Place the Script
1. Open Roblox Studio
2. In the Explorer, navigate to: **StarterPlayer → StarterCharacterScripts**
3. Insert a new **LocalScript** (Right-click → Insert Object → LocalScript)
4. Rename it to "AnimationController" (optional but recommended)
5. Copy the contents of `AnimationController.lua` into this LocalScript

### Step 2: Configure Your Animation
1. Upload your animation to Roblox (if you haven't already)
2. Get your animation ID from the Creator Dashboard
3. Open the script and find line 15: `local ANIMATION_ID = "rbxassetid://YOUR_ANIMATION_ID_HERE"`
4. Replace `YOUR_ANIMATION_ID_HERE` with your actual animation ID

**Example:**
```lua
local ANIMATION_ID = "rbxassetid://507766388"
```

### Step 3: Customize Speed Pattern (Optional)
The script changes animation speed every second. Modify the `SPEED_PATTERN` table on line 18:

```lua
local SPEED_PATTERN = {1.0, 1.5, 0.5, 2.0, 1.2}
```

- **1.0** = normal speed
- **2.0** = 2x faster
- **0.5** = half speed
- Pattern repeats if duration is longer than array length

**Example patterns:**
```lua
-- Gradually speed up then slow down
local SPEED_PATTERN = {0.5, 1.0, 1.5, 2.0, 1.5}

-- Random variation
local SPEED_PATTERN = {1.0, 0.8, 1.3, 0.6, 1.8}

-- Extreme variation
local SPEED_PATTERN = {0.3, 3.0, 0.5, 2.5, 1.0}
```

## 🎮 How to Use

### In-Game Controls
- **PC/Console:** Press **R** to activate the animation
- **Mobile:** A button will appear on screen automatically

### Customizing the Key Bind
Change line 16 to use a different key:
```lua
local KEY_BIND = Enum.KeyCode.E  -- or Q, F, T, etc.
```

### Customizing Duration
Change line 17 to adjust how long the animation plays:
```lua
local DURATION = 10  -- Animation will play for 10 seconds
```

## ✨ Features & Optimization

### Performance Optimizations Included:
✅ **Debouncing** - Prevents multiple animations from playing simultaneously  
✅ **Connection Cleanup** - Properly disconnects events to prevent memory leaks  
✅ **Heartbeat Usage** - Uses efficient RunService for smooth speed changes  
✅ **Fade Transitions** - Smooth animation start (0.1s) and stop (0.2s)  
✅ **Input Filtering** - Ignores keypresses when typing in chat/UI  
✅ **Death Cleanup** - Stops animation when character dies  
✅ **Mobile Support** - Automatic mobile button via ContextActionService  

### Additional Best Practices:
- Animation is loaded once and reused (not recreated each time)
- Uses LocalScript (runs on client for better responsiveness)
- Proper garbage collection when script is destroyed
- No loops that could cause performance issues

## 🔧 Troubleshooting

### Animation doesn't play:
1. ✓ Verify animation ID is correct (include "rbxassetid://")
2. ✓ Make sure animation is uploaded to your account or group
3. ✓ Check that the script is in StarterCharacterScripts
4. ✓ Ensure the script is a **LocalScript** (not a regular Script)

### Animation plays but doesn't change speed:
1. ✓ Check that SPEED_PATTERN values are different numbers
2. ✓ Try more extreme values like 0.3 or 3.0 to see the effect clearly

### Multiple animations playing at once:
1. ✓ Make sure you only have one instance of this script
2. ✓ Check that isPlaying debounce is working

## 📝 Notes

- This script requires an R15 or R6 character with a Humanoid
- Animation must be compatible with your character rig type
- Speed changes are instantaneous (no smoothing between speeds)
- Animation will loop continuously during the 5-second duration

## 🎯 Advanced Customization

### Make speed changes smoother:
You can interpolate between speeds by modifying the Heartbeat connection. Contact me if you need help with this feature.

### Add sound effects:
Add this inside `playAnimationWithSpeedVariation()`:
```lua
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://YOUR_SOUND_ID"
sound.Parent = character.HumanoidRootPart
sound:Play()
game:GetService("Debris"):AddItem(sound, DURATION)
```

### Add visual effects:
Connect particle emitters or other effects in the same function.

---

**Created with ❤️ for Roblox developers**
