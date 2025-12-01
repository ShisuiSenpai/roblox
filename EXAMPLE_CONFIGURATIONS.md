# Example Jump Pad Configurations

These are tested configurations for different jump styles. Adjust `JUMP_STRENGTH` in the **server script** and `HORIZONTAL_PRESERVATION` in the **client script**.

---

## 🟢 Standard Platform Jump
Natural, responsive jump for platforming sections.

**Server (JumpPadServer.lua):**
```lua
local JUMP_STRENGTH = 50
local COOLDOWN_TIME = 0.5
```

**Client (JumpPadClient.lua):**
```lua
local HORIZONTAL_PRESERVATION = 0.9
```

**Feel:** Smooth, natural jump that feels like a spring. Good for precise platforming.

---

## 🟡 High Jump Pad
Get to elevated areas with a strong vertical boost.

**Server:**
```lua
local JUMP_STRENGTH = 75
local COOLDOWN_TIME = 0.6
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 0.85
```

**Feel:** Strong upward launch, slight momentum loss for control in air.

---

## 🔴 Super Jump / Launch Pad
Dramatic launch for reaching very high areas.

**Server:**
```lua
local JUMP_STRENGTH = 120
local COOLDOWN_TIME = 0.8
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 1.0
```

**Feel:** Powerful vertical boost that keeps your forward momentum. Exciting!

---

## 🚀 Cannon Launch (Extreme)
Maximum height - for special moments or shortcuts.

**Server:**
```lua
local JUMP_STRENGTH = 150
local COOLDOWN_TIME = 1.0
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 0.7
```

**Feel:** Extreme vertical launch. Slows horizontal movement for easier landing.

---

## 🎯 Vertical Launcher
Straight up with minimal horizontal carry.

**Server:**
```lua
local JUMP_STRENGTH = 100
local COOLDOWN_TIME = 0.7
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 0.3
```

**Feel:** Mostly vertical. Good for jump puzzles requiring precision.

---

## 💨 Speed Booster Pad
Small jump with major forward acceleration.

**Server:**
```lua
local JUMP_STRENGTH = 35
local COOLDOWN_TIME = 0.3
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 1.6
```

**Feel:** Speeds you up! Small hop but significant speed increase.

---

## 🎪 Trampoline / Bounce Pad
Quick, repeatable bounces for fun traversal.

**Server:**
```lua
local JUMP_STRENGTH = 60
local COOLDOWN_TIME = 0.3
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 1.1
```

**Feel:** Fast, bouncy, can chain jumps quickly. Fun and energetic.

---

## 🧊 Low Gravity Bounce
Gentle, floaty jump for puzzle areas.

**Server:**
```lua
local JUMP_STRENGTH = 40
local COOLDOWN_TIME = 0.8
```

**Client:**
```lua
local HORIZONTAL_PRESERVATION = 0.95
```

**Feel:** Soft, controlled launch. Good for precision or chill areas.

---

## 🎮 Game-Style References

### Overwatch-style Jump Pad
```lua
-- Server
local JUMP_STRENGTH = 85
local COOLDOWN_TIME = 0.5

-- Client
local HORIZONTAL_PRESERVATION = 1.1
```

### Fortnite-style Launch Pad
```lua
-- Server
local JUMP_STRENGTH = 110
local COOLDOWN_TIME = 0.7

-- Client
local HORIZONTAL_PRESERVATION = 1.3
```

### Rocket League-style Boost Pad
```lua
-- Server
local JUMP_STRENGTH = 25
local COOLDOWN_TIME = 0.2

-- Client
local HORIZONTAL_PRESERVATION = 2.0
```

---

## 🧪 Testing Tips

1. **Start conservative:** Begin with `JUMP_STRENGTH = 50`, increase from there
2. **Test while running:** Walk AND sprint onto the pad to see both cases
3. **Check landing zones:** Make sure players can land safely
4. **Adjust for your gravity:** If you modified workspace gravity, scale accordingly
5. **Feel over numbers:** Trust your instincts - if it feels good, it is good

---

## 🔧 Fine-Tuning Formula

If you know your desired height in studs:

```
JUMP_STRENGTH ≈ sqrt(desired_height * 196)
```

Examples:
- 10 studs high → ~44 strength
- 20 studs high → ~63 strength
- 30 studs high → ~77 strength
- 50 studs high → ~99 strength

**Note:** This is approximate. Roblox physics and your `HORIZONTAL_PRESERVATION` will affect actual height.

---

## 💡 Pro Tips

**Momentum Preservation:**
- `< 1.0` = Slows you down (use for high jumps where you need control)
- `= 1.0` = Neutral (keeps your speed exactly)
- `> 1.0` = Speeds you up (use for speed boost pads)

**Cooldown Timing:**
- Short (0.2-0.4s) = Fast-paced, bouncy gameplay
- Medium (0.5-0.7s) = Standard, prevents spam
- Long (0.8-1.5s) = Tactical, deliberate use

**Visual Feedback:**
- Set `SHOW_VISUAL = true` and adjust colors in server script
- Use bright colors (neon material) for better visibility
- Add `Sound` effects in the server script for audio cues

---

## 🎨 Making Different Pad Types

Want multiple pad types in your game?

1. **Copy the JumpPad Part**
2. **Rename it** (e.g., "SpeedPad", "SuperJumpPad")
3. **Adjust the server script** in each pad with different values
4. **Use different colors/materials** to show function
5. The **client script** automatically works with all types!

Example hierarchy:
```
Workspace
  ├─ JumpPad (Part) → Standard jump (strength: 50)
  ├─ SuperJump (Part) → High jump (strength: 100)
  └─ SpeedBoost (Part) → Speed boost (strength: 35, preservation: 1.6)
```

Each gets its own server script with unique settings!
