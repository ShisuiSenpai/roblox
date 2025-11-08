# Multi-Sword System - Complete Setup Guide

## 🎯 Overview

This system lets you have **multiple swords** with unique settings, all working from one script!

**Features:**
- ✅ Multiple swords with custom positions, rotations, attack speeds
- ✅ Switch between swords with keybinds (1, 2, 3, etc.)
- ✅ Each sword can have unique animations and stats
- ✅ Easy to add new swords - just edit the config!
- ✅ Highly optimized - single script handles everything

## 📦 Installation

### Step 1: Setup File Structure

**ReplicatedStorage:**
```
├─ SwordConfig (ModuleScript) ← Put the SwordConfig.lua code here
├─ HolsteredSword (Model)
│  └─ Sword (Part)
├─ Sword (Tool)
│  └─ Handle (MeshPart)
├─ HolsteredSword2 (Model) ← Your second sword
│  └─ Sword (Part)
├─ Sword2 (Tool)
│  └─ Handle (MeshPart)
└─ ... (more swords)
```

**StarterPlayer > StarterPlayerScripts:**
```
└─ MultiSwordSystem (LocalScript) ← Put the MultiSwordSystem.lua code here
```

### Step 2: Create the ModuleScript

1. In **ReplicatedStorage**, create a **ModuleScript** named `SwordConfig`
2. Delete the default code
3. Copy the contents of `SwordConfig.lua` into it

### Step 3: Create the LocalScript

1. In **StarterPlayer > StarterPlayerScripts**, create a **LocalScript** named `MultiSwordSystem`
2. Copy the contents of `MultiSwordSystem.lua` into it

### Step 4: Remove Old Scripts

- Delete your old `BladeBallStyleSwordScript` (this replaces it)
- Make sure all sword tools are in **ReplicatedStorage** (not StarterPack)

## ⚙️ Adding New Swords

### Quick Method (Copy-Paste)

1. **Add your models to ReplicatedStorage:**
   - `HolsteredSwordName` (Model with "Sword" part inside)
   - `SwordToolName` (Tool with "Handle" inside)

2. **Open the SwordConfig ModuleScript**

3. **Copy this template and paste it in the `Swords` table:**

```lua
["MySwordName"] = {
	HolsteredModelName = "HolsteredMySword",
	ToolName = "MySwordTool",
	
	Holster = {
		AttachmentPart = "Torso",
		PositionOffset = Vector3.new(1, -1.2, 0.7),
		RotationOffset = Vector3.new(0, 90, 110),
		TransparencyValue = 0,
	},
	
	Attack = {
		AttackDuration = 0.3,
		AttackCooldown = 0.4,
		AnimationId = "rbxassetid://0",
		Damage = 10,
		AttackRange = 10,
	},
	
	Keybind = Enum.KeyCode.Four, -- Press "4" to equip
},
```

4. **Customize the values** (see customization section below)

5. **Done!** The sword will automatically appear in-game

## 🎨 Customization Guide

### Holster Settings

```lua
Holster = {
	-- Where to attach on body
	AttachmentPart = "Torso", -- or "UpperTorso", "LowerTorso"
	
	-- Position (X = Left/Right, Y = Up/Down, Z = Forward/Back)
	PositionOffset = Vector3.new(1, -1.2, 0.7),
	
	-- Rotation in degrees
	RotationOffset = Vector3.new(0, 90, 110),
	
	-- 0 = visible, 1 = invisible
	TransparencyValue = 0,
},
```

**Common Holster Positions:**

**Right Hip:**
```lua
PositionOffset = Vector3.new(1, -1.2, 0.7)
RotationOffset = Vector3.new(0, 90, 110)
```

**Left Hip:**
```lua
PositionOffset = Vector3.new(-1, -1.2, 0.7)
RotationOffset = Vector3.new(0, -90, 110)
```

**Back (Vertical):**
```lua
AttachmentPart = "UpperTorso"
PositionOffset = Vector3.new(0, 0.5, -0.9)
RotationOffset = Vector3.new(0, 0, 0)
```

**Back (Diagonal):**
```lua
AttachmentPart = "UpperTorso"
PositionOffset = Vector3.new(0.5, 0.5, -0.8)
RotationOffset = Vector3.new(45, 0, -25)
```

### Attack Settings

```lua
Attack = {
	-- How long sword stays in hand (seconds)
	AttackDuration = 0.3,
	
	-- Time between attacks (seconds)
	AttackCooldown = 0.4,
	
	-- Animation ID
	AnimationId = "rbxassetid://YOUR_ID",
	
	-- For future damage system
	Damage = 10,
	AttackRange = 10,
},
```

**Attack Speed Presets:**

**Ultra Fast:**
```lua
AttackDuration = 0.2
AttackCooldown = 0.3
```

**Fast:**
```lua
AttackDuration = 0.3
AttackCooldown = 0.4
```

**Normal:**
```lua
AttackDuration = 0.4
AttackCooldown = 0.6
```

**Slow (Heavy):**
```lua
AttackDuration = 0.5
AttackCooldown = 1.0
```

### Keybinds

Change which key equips each sword:

```lua
Keybind = Enum.KeyCode.One,   -- Press "1"
Keybind = Enum.KeyCode.Two,   -- Press "2"
Keybind = Enum.KeyCode.Three, -- Press "3"
Keybind = Enum.KeyCode.Q,     -- Press "Q"
Keybind = Enum.KeyCode.E,     -- Press "E"
```

## 🎮 Global Settings

At the bottom of the SwordConfig, you'll find global settings:

```lua
-- Which sword player starts with
SwordConfig.DefaultSword = "Sword"

-- Show ALL swords holstered at once?
SwordConfig.ShowAllSwords = false -- true = all visible on body

-- Allow switching between swords?
SwordConfig.AllowSwitching = true -- false = locks to default sword
```

### Show All Swords Example

If you set `ShowAllSwords = true`, the player will have ALL swords visible on their body at once (one on right hip, one on left hip, one on back, etc.). They can still only use one at a time by pressing the keybinds!

This looks really cool for a "weapon arsenal" effect! 🗡️⚔️

## 📋 Example: Adding a Katana

Let's say you want to add a katana:

**Step 1: Models in ReplicatedStorage**
- `HolsteredKatana` (Model with "Sword" part)
- `Katana` (Tool with "Handle")

**Step 2: Add to SwordConfig**
```lua
["Katana"] = {
	HolsteredModelName = "HolsteredKatana",
	ToolName = "Katana",
	
	Holster = {
		AttachmentPart = "UpperTorso",
		PositionOffset = Vector3.new(-0.3, 0.5, -0.9), -- Back, slightly left
		RotationOffset = Vector3.new(0, 0, 10), -- Slight tilt
		TransparencyValue = 0,
	},
	
	Attack = {
		AttackDuration = 0.25, -- Fast katana slash
		AttackCooldown = 0.35,
		AnimationId = "rbxassetid://123456789", -- Your katana slash anim
		Damage = 15,
		AttackRange = 12,
	},
	
	Keybind = Enum.KeyCode.K, -- Press "K" for Katana
},
```

**Step 3: Test!**
- Play the game
- Press "K" to equip katana
- Click to attack
- Press "1" to switch back to original sword

## 🎯 Testing Your Setup

1. **Enter Play mode**
2. **Check holstered sword** - Should see your default sword on character
3. **Click to attack** - Sword appears in hand briefly
4. **Press number keys** - Switch between different swords
5. **Check console** - Should see "Multi-Sword System Loaded!"

## 🐛 Troubleshooting

**Problem: Sword doesn't appear**
- Check that model names in config match exactly (case-sensitive!)
- Verify models are in ReplicatedStorage
- Look for warnings in Output window

**Problem: Can't switch swords**
- Check `AllowSwitching = true` in SwordConfig
- Make sure keybinds aren't conflicting
- Check console for errors

**Problem: Sword in wrong position**
- Adjust `PositionOffset` and `RotationOffset` in config
- Small changes (like 0.1) make a difference
- Test different `AttachmentPart` options

**Problem: Attack doesn't work**
- Verify tool name matches exactly
- Check that tool has a "Handle" part
- Make sure tool is in ReplicatedStorage, not StarterPack

## 💡 Pro Tips

### Tip 1: Different Swords for Different Styles
```lua
-- Fast dagger
AttackDuration = 0.2
AttackCooldown = 0.3
Damage = 5

-- Heavy greatsword
AttackDuration = 0.6
AttackCooldown = 1.2
Damage = 25
```

### Tip 2: Disable Switching for Single Sword Mode
```lua
SwordConfig.AllowSwitching = false
```
Players can only use the default sword (great for game modes)

### Tip 3: Show Full Arsenal
```lua
SwordConfig.ShowAllSwords = true
```
All swords appear holstered on character = looks epic! 

### Tip 4: Quick Keybind Reference
- Number keys (1-9) for main swords
- Q/E for quick-switch favorites
- F for special sword
- X for heavy sword

## 📊 Performance Notes

This system is **highly optimized**:
- ✅ Single script handles all swords
- ✅ Swords are pre-loaded, not created on-demand
- ✅ Only active sword is fully visible (unless ShowAllSwords is true)
- ✅ No memory leaks or unnecessary cloning
- ✅ Efficient weld-based positioning

You can have **10+ swords** with no performance issues!

---

**Need help?** All sword settings are in the SwordConfig module for easy editing!
