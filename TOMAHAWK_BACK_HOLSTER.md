# 🪓 Tomahawk Back Holster Configuration

## ✅ Applied Settings

Your Tomahawk is now holstered **horizontally across your back**!

---

## 🎯 Configuration

```lua
["Tomahawk"] = {
    HolsteredModelName = "HolsteredTomahawk",
    SwordPartName = "Tomahawk",
    ToolName = "Tomahawk",
    
    Holster = {
        AttachmentPart = "UpperTorso",      -- Upper back (R15) / Torso (R6)
        PositionOffset = Vector3.new(0, 0.5, -0.8),
        RotationOffset = Vector3.new(0, 0, -90),
        TransparencyValue = 0,
    },
    
    Attack = {
        AttackDuration = 0.5,
        AttackCooldown = 0.4,
        AnimationId = "rbxassetid://102835293832677",
        Damage = 15,  -- Increased from 10!
        AttackRange = 10,
    },
    
    Keybind = Enum.KeyCode.Five,  -- Press "5" to equip
}
```

---

## 📐 How It's Positioned

### Position Breakdown:
```lua
PositionOffset = Vector3.new(0, 0.5, -0.8)
                           X    Y     Z
```

- **X = 0** → Centered on back (not left or right)
- **Y = 0.5** → Upper back area (shoulder blade level)
- **Z = -0.8** → Behind the torso (negative = back)

### Rotation Breakdown:
```lua
RotationOffset = Vector3.new(0, 0, -90)
                           X  Y   Z
```

- **X = 0°** → No forward/backward tilt
- **Y = 0°** → No left/right turn
- **Z = -90°** → Rotated horizontally across back

**Result:** Tomahawk lies **flat horizontally** across your upper back!

---

## 🎨 Visual Representation

```
    Player (Back View)
         Head
          │
    ──────────────  ← Tomahawk (horizontal)
         │││
      UpperTorso
         │││
```

---

## ⚙️ Fine-Tuning Options

### Move Higher/Lower:
```lua
-- Higher on back (shoulder level)
PositionOffset = Vector3.new(0, 0.8, -0.8)

-- Lower on back (mid-back)
PositionOffset = Vector3.new(0, 0.2, -0.8)

-- Current (upper back)
PositionOffset = Vector3.new(0, 0.5, -0.8)
```

### Stick Out More/Less:
```lua
-- Closer to body
PositionOffset = Vector3.new(0, 0.5, -0.6)

-- Further from body
PositionOffset = Vector3.new(0, 0.5, -1.0)

-- Current
PositionOffset = Vector3.new(0, 0.5, -0.8)
```

### Angle Adjustments:
```lua
-- Diagonal (like an X)
RotationOffset = Vector3.new(0, 0, -45)

-- Vertical (straight up/down)
RotationOffset = Vector3.new(0, 0, 0)

-- Current (horizontal)
RotationOffset = Vector3.new(0, 0, -90)
```

---

## 🎯 Alternative Back Holster Styles

### Style 1: Diagonal (Assassin Style)
```lua
Holster = {
    AttachmentPart = "UpperTorso",
    PositionOffset = Vector3.new(0.3, 0.6, -0.9),  -- Slightly offset
    RotationOffset = Vector3.new(0, 0, -45),        -- 45° angle
    TransparencyValue = 0,
}
```

### Style 2: Vertical (Over Shoulder)
```lua
Holster = {
    AttachmentPart = "UpperTorso",
    PositionOffset = Vector3.new(0, 0.7, -0.8),    -- Higher up
    RotationOffset = Vector3.new(0, 0, 0),         -- Straight vertical
    TransparencyValue = 0,
}
```

### Style 3: Side Back (Hip-Side Hybrid)
```lua
Holster = {
    AttachmentPart = "UpperTorso",
    PositionOffset = Vector3.new(-0.7, 0, -0.5),   -- Left side back
    RotationOffset = Vector3.new(0, 45, -110),      -- Angled
    TransparencyValue = 0,
}
```

---

## 💡 Pro Tips

### Tip 1: R6 vs R15
If your game uses R6 characters, change:
```lua
AttachmentPart = "Torso"  -- R6 doesn't have UpperTorso
```

### Tip 2: Multiple Back Weapons
If you want multiple weapons on the back:
```lua
-- Weapon 1 (left side)
PositionOffset = Vector3.new(-0.3, 0.5, -0.8)

-- Weapon 2 (right side)
PositionOffset = Vector3.new(0.3, 0.5, -0.8)

-- Weapon 3 (center, lower)
PositionOffset = Vector3.new(0, 0.2, -0.8)
```

### Tip 3: Make It Stand Out
Since it's on the back, maybe increase Z to make it more visible:
```lua
PositionOffset = Vector3.new(0, 0.5, -1.0)  -- Sticks out more
```

---

## 🔍 Comparing to Swords

### Swords (Hip Holster):
```lua
AttachmentPart = "Torso"
PositionOffset = Vector3.new(1, -1.2, 0.7)  -- Side hip
RotationOffset = Vector3.new(0, 90, 110)
```

### Tomahawk (Back Holster):
```lua
AttachmentPart = "UpperTorso"
PositionOffset = Vector3.new(0, 0.5, -0.8)  -- Center back
RotationOffset = Vector3.new(0, 0, -90)
```

**Looks great with variety!** ⚔️🪓

---

## 📊 Current Setup Summary

- **Location:** Center of upper back
- **Height:** Shoulder blade level
- **Distance:** 0.8 studs behind torso
- **Angle:** Horizontal across back
- **Keybind:** Press "5" to equip
- **Damage:** 15 (stronger than swords!)

---

## ✅ Testing

1. **Update SwordConfig** with the new settings
2. **Test in-game:**
   - Look at player from behind
   - Tomahawk should be horizontal across back
   - Press "5" to equip
   - Click to attack
   - Should return to back after attack

Adjust the values if needed for perfect positioning!

---

Your Tomahawk now has a unique back holster style! 🪓✨
