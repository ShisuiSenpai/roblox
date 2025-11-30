# Roblox Jump Pad Script

A high-performance, optimized jump pad script for Roblox games with smooth player launching and proper hitbox detection.

## Installation

### Simple Setup (Single Part)
1. Create a **Part** in your Roblox workspace and name it **"JumpPad"**
2. Insert a **Script** (not LocalScript) into the JumpPad part
3. Copy the contents of `JumpPad.lua` into that Script
4. The jump pad will automatically work when players touch it!

### Model Setup (Multiple Parts)
1. Have a **Model** containing at least one Part
2. Insert a **Script** (not LocalScript) into the Model
3. Copy the contents of `JumpPad.lua` into that Script
4. Optional: Set the Model's PrimaryPart to specify which part triggers the jump

The script automatically detects whether it's in a Part or Model and works accordingly!

## Features

✅ **Optimized Hitbox Detection** - Uses efficient .Touched event with proper player validation  
✅ **Smooth Launching** - Preserves horizontal momentum for natural movement  
✅ **Anti-Spam Protection** - Per-player cooldown system prevents exploitation  
✅ **Visual Feedback** - Optional color flash when activated  
✅ **Memory Safe** - Automatic cleanup of cooldown data  
✅ **Configurable** - Easy-to-adjust parameters at the top of the script  

## Configuration

Open the script and adjust these values at the top:

```lua
local JUMP_POWER = 80                -- Vertical force (how high)
local HORIZONTAL_MULTIPLIER = 1.2    -- Horizontal velocity preservation
local LAUNCH_DURATION = 0.1          -- Force application time
local COOLDOWN_TIME = 0.5            -- Cooldown between uses (per player)
local USE_VISUAL_FEEDBACK = true     -- Enable/disable color flash
```

### Parameter Guide

- **JUMP_POWER**: Controls how high players jump (50-150 typical range)
  - Lower values (50-70): Small bounce
  - Medium values (70-100): Standard jump pad
  - Higher values (100-150): Super jump pad

- **HORIZONTAL_MULTIPLIER**: Preserves player's running momentum
  - 0 = No horizontal movement (straight up)
  - 1.0 = Keep current speed
  - 1.5+ = Speed boost on jump

- **COOLDOWN_TIME**: Prevents spam (in seconds)
  - 0.3-0.5 recommended for fast-paced games
  - 1.0+ for puzzle/exploration games

## Optimization Features

1. **Fast Player Detection**: Efficiently checks if the touching object is a player
2. **Debounce System**: Per-player cooldowns prevent multiple rapid triggers
3. **Memory Management**: Automatic cleanup of disconnected players
4. **Direct Velocity Application**: Uses modern `AssemblyLinearVelocity` for best performance

## Customization Ideas

Once the basic functionality works, you can:
- Adjust launch angle (currently vertical with horizontal preservation)
- Add sound effects when activated
- Create different jump pad types with varying strengths
- Add particle effects for better visual feedback
- Implement directional launch pads

## Next Steps

Test the jump pad in your game, then let me know:
1. How high you want players to jump
2. How much horizontal distance they should travel
3. Any specific angles or directions you want

I can then fine-tune the parameters or add directional launching!
