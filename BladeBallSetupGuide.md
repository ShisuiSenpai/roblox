# Blade Ball Style Sword System - Setup Guide

## 🎮 Installation

### Step 1: Setup Your Game Structure

**ReplicatedStorage should contain:**
1. **HolsteredSword** (Model)
   - Sword (Part/MeshPart inside)
2. **Sword** (Tool)
   - Handle (MeshPart inside)

**StarterPlayer:**
1. Create a **LocalScript** in `StarterPlayer > StarterPlayerScripts` or `StarterPlayer > StarterCharacterScripts`
2. Copy the code from `BladeBallStyleSwordScript.lua` into this LocalScript
3. Name it something like "SwordAttackSystem"

### Step 2: Remove Tool from StarterPack
- Make sure the Sword Tool is **NOT** in StarterPack
- It should **ONLY** be in ReplicatedStorage
- The script handles everything automatically

## ⚙️ How It Works

1. **Holstered Sword**: Always visible on your character (on your hip/back)
2. **Click to Attack**: When you click (M1), the sword temporarily appears in your hand
3. **Auto-Return**: After the attack, the sword automatically returns to holstered position
4. **Just like Blade Ball!** 

## 🎯 Customization Settings

### Holster Position (Already Set to Your Perfect Settings!)

```lua
local HOLSTER_SETTINGS = {
	AttachmentPart = "Torso",
	PositionOffset = Vector3.new(1, -1.2, 0.7),
	RotationOffset = Vector3.new(0, 90, 110),
	TransparencyValue = 0, -- 0 = fully visible
}
```

### Attack Settings

```lua
local ATTACK_SETTINGS = {
	-- How long sword stays in hand during attack
	AttackDuration = 0.5,
	
	-- Your sword slash animation ID
	AnimationId = "rbxassetid://YOUR_ANIMATION_ID",
	
	-- Time between attacks (seconds)
	AttackCooldown = 1,
	
	-- Damage and range (for future implementation)
	Damage = 10,
	AttackRange = 10,
}
```

## 🎬 Adding Your Attack Animation

### Step 1: Create/Upload Animation
1. Create a sword slash animation in Roblox Studio's Animation Editor
2. Publish the animation
3. Copy the animation ID

### Step 2: Add to Script
Replace this line:
```lua
AnimationId = "rbxassetid://0",
```

With your animation ID:
```lua
AnimationId = "rbxassetid://123456789",
```

## 🔧 Advanced Customization

### Change Attack Duration
Make the sword stay in hand longer or shorter:
```lua
AttackDuration = 0.3, -- Faster attack
AttackDuration = 1.0, -- Slower, more dramatic attack
```

### Change Cooldown
Control how fast players can spam attacks:
```lua
AttackCooldown = 0.5, -- Fast spam
AttackCooldown = 2.0, -- Slower, more strategic
```

### Different Holster Positions

**Back Holster (Vertical):**
```lua
PositionOffset = Vector3.new(0, 0.3, -0.9)
RotationOffset = Vector3.new(0, 0, 0)
```

**Left Hip:**
```lua
PositionOffset = Vector3.new(-1.2, -0.3, 0.2)
RotationOffset = Vector3.new(0, 90, 90)
```

## 🎮 Testing

1. **Enter Play mode**
2. **Look at your character** - sword should be holstered on your hip
3. **Click (M1)** - sword should appear in hand briefly
4. **After attack** - sword should return to holster automatically

## 💡 Adding Damage System

To make the sword deal damage, you'll need to add server-side hit detection. Here's a basic example:

### Client (LocalScript) - Add Remote Event
```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local attackEvent = ReplicatedStorage:FindFirstChild("SwordAttackEvent")

-- In performAttack function, add:
if attackEvent then
	attackEvent:FireServer(mouse.Hit.Position)
end
```

### Server (Script) - Handle Damage
```lua
-- Place in ServerScriptService
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent in ReplicatedStorage named "SwordAttackEvent"
local attackEvent = Instance.new("RemoteEvent")
attackEvent.Name = "SwordAttackEvent"
attackEvent.Parent = ReplicatedStorage

attackEvent.OnServerEvent:Connect(function(player, targetPosition)
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	-- Find nearby enemies
	for _, otherPlayer in pairs(game.Players:GetPlayers()) do
		if otherPlayer ~= player then
			local otherCharacter = otherPlayer.Character
			if otherCharacter then
				local otherHRP = otherCharacter:FindFirstChild("HumanoidRootPart")
				local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
				
				if otherHRP and otherHumanoid then
					local distance = (humanoidRootPart.Position - otherHRP.Position).Magnitude
					
					-- Check if in range
					if distance <= 10 then -- Attack range
						otherHumanoid:TakeDamage(10) -- Damage amount
					end
				end
			end
		end
	end
end)
```

## 🐛 Troubleshooting

**Problem**: Sword doesn't appear at all
- Check that `HolsteredSword` model exists in ReplicatedStorage
- Check that it has a part named "Sword" inside it
- Look in Output window for error messages

**Problem**: Click doesn't work
- Make sure the script is in StarterPlayerScripts or StarterCharacterScripts
- Check that `Sword` Tool exists in ReplicatedStorage
- Try clicking multiple times (there's a cooldown)

**Problem**: Sword stays in hand
- Check `AttackDuration` - it might be set too high
- Make sure the script isn't erroring (check Output)

**Problem**: Animation doesn't play
- Make sure you've set a valid `AnimationId`
- Verify the animation is published and accessible
- Check that the animation is for the right rig type (R6/R15)

**Problem**: Holstered sword is in wrong position
- Adjust `PositionOffset` and `RotationOffset` in `HOLSTER_SETTINGS`
- Small changes (like 0.1) can make a big difference

## 🎨 Making It Look Cooler

### Add Sound Effects
Add these lines in the `performAttack` function:

```lua
-- Add after "hideHolster()"
local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxassetid://YOUR_SOUND_ID"
slashSound.Parent = character.HumanoidRootPart
slashSound:Play()
game:GetService("Debris"):AddItem(slashSound, 2)
```

### Add Visual Effects
```lua
-- Add a slash effect
local slashEffect = ReplicatedStorage.SlashEffect:Clone()
slashEffect.Parent = workspace
slashEffect.Position = character.HumanoidRootPart.Position
game:GetService("Debris"):AddItem(slashEffect, 1)
```

---

**Need help?** All settings are at the top of the script for easy customization!
