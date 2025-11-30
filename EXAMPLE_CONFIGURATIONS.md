# Example Jump Pad Configurations

Here are some pre-configured settings for different jump pad types. Copy these values into your script's configuration section.

## 🟢 Gentle Bounce Pad
Perfect for platforming sections where you need precise control.

```lua
local JUMP_POWER = 50
local HORIZONTAL_MULTIPLIER = 1.0
local COOLDOWN_TIME = 0.4
```

## 🟡 Standard Jump Pad
Balanced for general gameplay - good height and distance.

```lua
local JUMP_POWER = 80
local HORIZONTAL_MULTIPLIER = 1.2
local COOLDOWN_TIME = 0.5
```

## 🔴 Super Jump Pad
For reaching high areas or creating exciting moments.

```lua
local JUMP_POWER = 120
local HORIZONTAL_MULTIPLIER = 1.5
local COOLDOWN_TIME = 0.6
```

## 🚀 Launch Pad (Extreme)
Maximum height and speed for special areas.

```lua
local JUMP_POWER = 150
local HORIZONTAL_MULTIPLIER = 2.0
local COOLDOWN_TIME = 1.0
```

## 🎯 Vertical Cannon
Shoots players straight up with minimal horizontal movement.

```lua
local JUMP_POWER = 100
local HORIZONTAL_MULTIPLIER = 0.2
local COOLDOWN_TIME = 0.8
```

## 💨 Speed Booster
Maintains momentum with a small vertical boost.

```lua
local JUMP_POWER = 40
local HORIZONTAL_MULTIPLIER = 2.5
local COOLDOWN_TIME = 0.3
```

## Testing Tips

1. **Start Conservative**: Begin with lower values and increase gradually
2. **Test with Running**: Have players run onto the pad vs walking onto it
3. **Check Landing**: Make sure landing areas are safe and accessible
4. **Multiplayer Test**: Test with multiple players to verify cooldowns work
5. **Ceiling Check**: Ensure players don't hit ceilings unexpectedly

## Fine-Tuning Formula

If you know the desired height in studs:
```
Approximate JUMP_POWER = sqrt(Height_in_studs * 196)

Examples:
- 10 studs high: JUMP_POWER ≈ 44
- 20 studs high: JUMP_POWER ≈ 63
- 30 studs high: JUMP_POWER ≈ 77
- 50 studs high: JUMP_POWER ≈ 99
```

Note: This is approximate due to Roblox physics and air resistance.
