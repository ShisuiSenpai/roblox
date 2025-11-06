# Roblox Sword Holstering System - Setup Guide

## 🎮 Installation

1. **Open Roblox Studio**
2. **Find your Sword Tool** in the workspace/ReplicatedStorage
3. **Create a LocalScript** inside the Tool (right-click Tool → Insert Object → LocalScript)
4. **Copy the code** from `SwordHolsterScript.lua` into this LocalScript
5. **Done!** Test it in Play mode

## ⚙️ Customization Guide

### 1. **Attachment Point** (`AttachmentPart`)
Where the sword attaches to your character:

**For R15 Characters:**
- `"UpperTorso"` - Upper back/chest area (default, good for back holster)
- `"LowerTorso"` - Lower back/waist area (good for hip holster)
- `"LeftUpperArm"` or `"RightUpperArm"` - Shoulder holster

**For R6 Characters:**
- `"Torso"` - Center body (only option for R6)

### 2. **Position Offset** (`PositionOffset`)
Fine-tune where the sword sits (Vector3):

```lua
PositionOffset = Vector3.new(X, Y, Z)
```

- **X axis**: Left (-) / Right (+)
  - Try: `-1` for left hip, `1` for right hip
- **Y axis**: Down (-) / Up (+)
  - Try: `0` for centered, `1` for higher up
- **Z axis**: Back (-) / Front (+)
  - Try: `-1` for behind back, `0.5` for hip side

**Common Presets:**
```lua
-- Back Holster (diagonal)
PositionOffset = Vector3.new(0.5, 0.5, -0.8)

-- Right Hip
PositionOffset = Vector3.new(1.2, -0.3, 0.2)

-- Left Hip
PositionOffset = Vector3.new(-1.2, -0.3, 0.2)

-- Back (vertical)
PositionOffset = Vector3.new(0, 0.3, -0.9)
```

### 3. **Rotation Offset** (`RotationOffset`)
Angle the sword (in degrees):

```lua
RotationOffset = Vector3.new(X, Y, Z)
```

- **X axis**: Pitch (forward/backward tilt)
- **Y axis**: Yaw (left/right turn)
- **Z axis**: Roll (side tilt)

**Common Presets:**
```lua
-- Diagonal Back Holster
RotationOffset = Vector3.new(45, 0, -25)

-- Vertical Back Holster
RotationOffset = Vector3.new(0, 0, 0)

-- Hip Holster (horizontal)
RotationOffset = Vector3.new(0, 90, 90)
```

### 4. **Visual Settings**

**Transparency Mode** (recommended):
```lua
UseTransparency = true
TransparencyValue = 0  -- 0 = fully visible, 1 = invisible
FadeSpeed = 0.1  -- Animation speed
```

**Complete Removal Mode**:
```lua
UseTransparency = false  -- Sword disappears/reappears instantly
```

## 🎯 Testing Your Setup

1. **Enter Play mode** in Roblox Studio
2. **Give yourself the sword** (make sure it's in StarterPack or your character's Backpack)
3. **Look at your character** - you should see the holstered sword
4. **Equip the tool** - holstered version should disappear
5. **Unequip the tool** - holstered version should reappear

## 🔧 Advanced Customization

### Different Holster for Different Swords
If you have multiple swords, you can customize each one differently by changing the settings in each tool's LocalScript.

### Adding Sound Effects
Add this after line 147 (in the `tool.Equipped:Connect` function):

```lua
tool.Equipped:Connect(function()
	isEquipped = true
	hideHolster()
	
	-- Add sound effect
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://YOUR_SOUND_ID_HERE"
	sound.Parent = handle
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
end)
```

### Making the Holster Interactive
Want players to see the holstered sword? Change line 18 to:
```lua
local HOLSTER_SETTINGS = {
	TransparencyValue = 0,  -- Makes it fully visible when holstered
}
```

## 🐛 Troubleshooting

**Problem**: Sword doesn't appear holstered
- Check that the Tool has a part named "Handle"
- Make sure the script is a **LocalScript** (not a regular Script)
- Check the Output window for errors

**Problem**: Sword is in the wrong position
- Adjust `PositionOffset` and `RotationOffset` values
- Remember: small changes (like 0.1) make a difference!

**Problem**: Works in Studio but not in-game
- Verify the LocalScript is inside the Tool
- Make sure the Tool is in StarterPack or given to players properly

**Problem**: Sword clips through character
- Increase the Z value (more negative) in `PositionOffset`
- Try a different `AttachmentPart`

## 📝 Example Configurations

### Configuration 1: Samurai Back Holster
```lua
AttachmentPart = "UpperTorso"
PositionOffset = Vector3.new(0, 0.5, -0.9)
RotationOffset = Vector3.new(0, 0, 0)  -- Straight vertical
```

### Configuration 2: Knight's Hip Sword
```lua
AttachmentPart = "LowerTorso"
PositionOffset = Vector3.new(-1.2, -0.2, 0.3)
RotationOffset = Vector3.new(0, 0, 45)  -- Angled at hip
```

### Configuration 3: Ninja Back Holster
```lua
AttachmentPart = "UpperTorso"
PositionOffset = Vector3.new(0.3, 0.7, -0.8)
RotationOffset = Vector3.new(45, 0, -20)  -- Diagonal across back
```

---

**Need more help?** The script is fully commented - look at the settings section at the top of the script to experiment!
