# Quick Guide: Adding Your Next Sword (You Already Have Models)

Since you already have your models ready, here's the **fastest way** to add them:

## 🚀 Super Quick Steps

### 1. Put Models in ReplicatedStorage
Make sure each sword has TWO models:
- `HolsteredSwordName` (the visual holstered version)
- `SwordToolName` (the tool that goes in hand)

Example:
```
ReplicatedStorage/
├─ HolsteredSword (your first one - already done ✅)
├─ Sword (already done ✅)
├─ HolsteredFireSword (new one)
├─ FireSword (new one)
├─ HolsteredIceSword (new one)
└─ IceSword (new one)
```

### 2. Open SwordConfig ModuleScript

In ReplicatedStorage, open the `SwordConfig` ModuleScript

### 3. Copy-Paste This Template

Add this inside `SwordConfig.Swords = { ... }`:

```lua
["FireSword"] = {
	HolsteredModelName = "HolsteredFireSword",
	ToolName = "FireSword",
	
	Holster = {
		AttachmentPart = "Torso",
		PositionOffset = Vector3.new(1, -1.2, 0.7), -- Start with same position as first sword
		RotationOffset = Vector3.new(0, 90, 110),
		TransparencyValue = 0,
	},
	
	Attack = {
		AttackDuration = 0.3,
		AttackCooldown = 0.4,
		AnimationId = "rbxassetid://0",
		Damage = 15,
		AttackRange = 10,
	},
	
	Keybind = Enum.KeyCode.Two, -- Press "2" to equip
},
```

### 4. Test Finding Perfect Position

**Option A: Use Same Position**
Just keep the same position/rotation as your first sword - it'll work fine!

**Option B: Find Perfect Position** (like you did before)
1. In Studio, take the "Sword" part from your HolsteredFireSword model
2. Place it on a rig manually
3. Check the CFrame orientation in Properties
4. Copy those values to `RotationOffset`
5. Adjust `PositionOffset` by testing in-game

### 5. Done!

Press Play → Press "2" → Your new sword equips! 🎉

---

## 🎯 Example: Adding 3 Swords

Here's what your SwordConfig would look like with 3 swords:

```lua
SwordConfig.Swords = {
	["Sword"] = {
		HolsteredModelName = "HolsteredSword",
		ToolName = "Sword",
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
		Keybind = Enum.KeyCode.One,
	},
	
	["FireSword"] = {
		HolsteredModelName = "HolsteredFireSword",
		ToolName = "FireSword",
		Holster = {
			AttachmentPart = "Torso",
			PositionOffset = Vector3.new(-1, -1.2, 0.7), -- LEFT hip
			RotationOffset = Vector3.new(0, -90, 110),
			TransparencyValue = 0,
		},
		Attack = {
			AttackDuration = 0.25, -- Faster
			AttackCooldown = 0.35,
			AnimationId = "rbxassetid://0",
			Damage = 12,
			AttackRange = 11,
		},
		Keybind = Enum.KeyCode.Two,
	},
	
	["IceSword"] = {
		HolsteredModelName = "HolsteredIceSword",
		ToolName = "IceSword",
		Holster = {
			AttachmentPart = "UpperTorso",
			PositionOffset = Vector3.new(0, 0.5, -0.9), -- BACK
			RotationOffset = Vector3.new(0, 0, 0),
			TransparencyValue = 0,
		},
		Attack = {
			AttackDuration = 0.4, -- Slower
			AttackCooldown = 0.6,
			AnimationId = "rbxassetid://0",
			Damage = 15,
			AttackRange = 12,
		},
		Keybind = Enum.KeyCode.Three,
	},
}
```

Now you have:
- Sword on RIGHT hip (press 1)
- FireSword on LEFT hip (press 2)
- IceSword on BACK (press 3)

---

## 💡 Want All Swords Visible?

At the bottom of SwordConfig, change this:

```lua
SwordConfig.ShowAllSwords = true
```

Now ALL your swords will be visible at once on your character! You switch between them with keybinds, but they all stay visible. Looks super cool! ⚔️🗡️

---

## ✅ Checklist for Each New Sword

- [ ] HolsteredSword model in ReplicatedStorage with "Sword" part inside
- [ ] Sword tool in ReplicatedStorage with "Handle" part inside
- [ ] Added entry to SwordConfig.Swords table
- [ ] Set unique keybind
- [ ] Tested in-game
- [ ] Adjusted position/rotation if needed

That's it! Super simple to add infinite swords now! 🚀
