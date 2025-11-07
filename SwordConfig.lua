--[[
	SWORD CONFIGURATION MODULE
	Add all your swords here with their custom settings
	
	Each sword can have unique:
	- Models (HolsteredSword and Sword Tool)
	- Holster position and rotation
	- Attack speed and duration
	- Damage and range
	- Animation
]]

local SwordConfig = {}

-- ========================================
-- SWORD DEFINITIONS
-- ========================================

SwordConfig.Swords = {
	-- SWORD 1: Your Original Sword
	["Sword"] = {
		-- Model names in ReplicatedStorage
		HolsteredModelName = "HolsteredSword",
		ToolName = "Sword",
		
		-- Holster settings
		Holster = {
			AttachmentPart = "Torso",
			PositionOffset = Vector3.new(1, -1.2, 0.7),
			RotationOffset = Vector3.new(0, 90, 110),
			TransparencyValue = 0,
		},
		
		-- Attack settings
		Attack = {
			AttackDuration = 0.3,
			AttackCooldown = 0.4,
			AnimationId = "rbxassetid://0", -- Replace with your animation
			Damage = 10,
			AttackRange = 10,
		},
		
		-- Keybind to equip this sword (optional)
		Keybind = Enum.KeyCode.One, -- Press "1" to equip
	},
	
	-- SWORD 2: Example Second Sword
	["Sword2"] = {
		HolsteredModelName = "HolsteredSword2",
		ToolName = "Sword2",
		
		Holster = {
			AttachmentPart = "Torso",
			PositionOffset = Vector3.new(-1, -1.2, 0.7), -- Left hip instead
			RotationOffset = Vector3.new(0, -90, 110),
			TransparencyValue = 0,
		},
		
		Attack = {
			AttackDuration = 0.4,
			AttackCooldown = 0.5,
			AnimationId = "rbxassetid://0",
			Damage = 15,
			AttackRange = 12,
		},
		
		Keybind = Enum.KeyCode.Two, -- Press "2" to equip
	},
	
	-- SWORD 3: Example Third Sword
	["Sword3"] = {
		HolsteredModelName = "HolsteredSword3",
		ToolName = "Sword3",
		
		Holster = {
			AttachmentPart = "UpperTorso",
			PositionOffset = Vector3.new(0, 0.5, -0.9), -- Back holster
			RotationOffset = Vector3.new(0, 0, 0),
			TransparencyValue = 0,
		},
		
		Attack = {
			AttackDuration = 0.25,
			AttackCooldown = 0.35,
			AnimationId = "rbxassetid://0",
			Damage = 12,
			AttackRange = 11,
		},
		
		Keybind = Enum.KeyCode.Three, -- Press "3" to equip
	},
	
	--[[
	TEMPLATE: Copy this to add more swords!
	
	["SwordName"] = {
		HolsteredModelName = "HolsteredSwordName",
		ToolName = "SwordToolName",
		
		Holster = {
			AttachmentPart = "Torso", -- or "UpperTorso", "LowerTorso"
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
	]]
}

-- ========================================
-- DEFAULT SETTINGS
-- ========================================

-- Which sword the player starts with (must match a key in SwordConfig.Swords)
SwordConfig.DefaultSword = "Sword"

-- Should multiple swords be visible at once? (all holstered on body)
SwordConfig.ShowAllSwords = false -- Set to true to show all swords holstered

-- Allow switching between swords?
SwordConfig.AllowSwitching = true

return SwordConfig
