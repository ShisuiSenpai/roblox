# 🪓 Tomahawk - Final Setup Guide

## ✅ Perfect Holster Settings

Update your **SwordConfig.lua** Tomahawk entry with these settings:

```lua
["Tomahawk"] = {
    HolsteredModelName = "HolsteredTomahawk",
    SwordPartName = "Tomahawk",
    ToolName = "Tomahawk",
    
    Holster = {
        AttachmentPart = "UpperTorso",
        PositionOffset = Vector3.new(0.2, -0.5, 0.7),  -- Perfect position!
        RotationOffset = Vector3.new(0, 0, -57),        -- Perfect angle!
        TransparencyValue = 0,
    },
    
    Attack = {
        AttackDuration = 0.5,
        AttackCooldown = 0.4,
        AnimationId = "rbxassetid://102835293832677",
        Damage = 15,
        AttackRange = 10,
    },
    
    Keybind = Enum.KeyCode.Five,
},
```

---

## 🤚 Fixing Hand Position (Tool Grip)

The issue where the Tomahawk is too far forward in your hand is controlled by the **Tool's Grip properties**, not the config!

### How to Fix:

1. **Open Roblox Studio**
2. **Go to:** `ReplicatedStorage > ToolSwords > Tomahawk`
3. **Select the Tomahawk Tool** (not the Handle inside)
4. **In Properties, find these settings:**

```
Grip
├─ GripForward: Vector3
├─ GripPos: Vector3         ← This controls position in hand!
├─ GripRight: Vector3
├─ GripUp: Vector3
```

---

## 📐 Adjusting Grip Position

### Problem: Tomahawk too far forward
**Solution:** Adjust `GripPos` (the position offset)

**Try these values:**

```
GripPos: (0, 0, -1)    ← Pulls it back 1 stud
```

Or start with these and adjust:
```
X = Left(-)/Right(+) in hand
Y = Down(-)/Up(+) in hand  
Z = Forward(+)/Back(-) in hand

Examples:
GripPos: (0, 0, -0.5)  ← Slightly back
GripPos: (0, 0, -1)    ← Further back
GripPos: (0, 0, -1.5)  ← Even further back
```

---

## 🎯 Step-by-Step Grip Adjustment

### Step 1: Test Current Position
1. Equip the Tomahawk (Press 5)
2. Click to attack
3. Note where it appears in your hand

### Step 2: Adjust GripPos Z value
1. Go to `ReplicatedStorage > ToolSwords > Tomahawk`
2. Select the Tool
3. In Properties, find `GripPos`
4. Change the **Z value** (third number)
   - **Current Z** → **New Z - 1**
   - Example: If Z = 0, try Z = -1

### Step 3: Test Again
1. Save and test in Play mode
2. Equip and attack
3. Check if position is better

### Step 4: Fine-Tune
Keep adjusting Z until it looks perfect:
- Too far back? Increase Z (less negative)
- Still too forward? Decrease Z (more negative)

---

## 🔧 Common Grip Settings for Tomahawks

### Style 1: Handle at Bottom
```
GripPos: Vector3.new(0, 0, -1)
```

### Style 2: Balanced Middle
```
GripPos: Vector3.new(0, 0, -0.7)
```

### Style 3: Head Forward (aggressive)
```
GripPos: Vector3.new(0, 0, -0.3)
```

---

## 📊 Understanding Grip Properties

### GripPos (Position):
- **X axis:** Left/Right in hand
- **Y axis:** Up/Down in hand
- **Z axis:** Forward/Back in hand ← **This fixes your issue!**

### GripForward, GripRight, GripUp (Rotation):
- These control the angle/rotation
- Usually don't need to change these
- Only adjust if the tomahawk is tilted wrong

---

## 🎨 Visual Guide

```
Before (Too Forward):
    👤
    │
  🤚──🪓  ← Tomahawk extends forward

After (Adjusted with GripPos Z = -1):
    👤
    │
  🤚🪓    ← Tomahawk sits nicely in hand
```

---

## 💡 Pro Tips

### Tip 1: Test with Animation
Make sure to test while the attack animation plays - the grip might look different during animation!

### Tip 2: Match Holster Style
Since your tomahawk is angled at -57° on back, you might want a similar grip angle for consistency.

### Tip 3: Small Changes
Adjust in small increments (0.1 or 0.2) for precision:
```
GripPos: (0, 0, -0.8)  → Try
GripPos: (0, 0, -0.9)  → Better
GripPos: (0, 0, -1.0)  → Perfect!
```

---

## 🔍 Troubleshooting

**Problem:** Tomahawk is sideways in hand
- **Fix:** Adjust `GripRight` or `GripUp` vectors

**Problem:** Tomahawk is upside down
- **Fix:** Rotate the `GripUp` vector

**Problem:** Can't find Grip properties
- **Fix:** Make sure you selected the **Tool** object, not the Handle inside

**Problem:** Changes don't apply
- **Fix:** Make sure to save and restart Play mode

---

## ✅ Checklist

- [ ] Updated SwordConfig with new holster settings
- [ ] Located Tomahawk Tool in ReplicatedStorage/ToolSwords
- [ ] Found GripPos property
- [ ] Adjusted Z value (try -1 first)
- [ ] Tested in Play mode
- [ ] Fine-tuned until perfect

---

## 📝 Final Settings Summary

**Holster (Back):**
```lua
PositionOffset = Vector3.new(0.2, -0.5, 0.7)
RotationOffset = Vector3.new(0, 0, -57)
```

**Hand Grip (To Fix):**
```
GripPos = Vector3.new(0, 0, -1)  ← Start here and adjust!
```

---

Perfect tomahawk setup incoming! 🪓✨
