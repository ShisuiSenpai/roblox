# 🎁 CS:GO Style Crate System - Setup Guide

## 📦 What You Get

A fully functional CS:GO style crate opening system with:
- ✅ Smooth spinning animation
- ✅ Dark, minimal, modern UI
- ✅ Player can't move while opening
- ✅ Automatically equips won sword
- ✅ Works with all 4 swords in your config
- ✅ Text-based (no images needed)

---

## 📂 Complete Hierarchy

### ✅ Workspace
```
Workspace
└─ Chest (MeshPart) ✅ YOU HAVE
   └─ ProximityPrompt ✅ YOU HAVE
```

### ✅ ReplicatedStorage
```
ReplicatedStorage
├─ SwordConfig (ModuleScript) ✅ Already have
├─ CrateRemotes (Folder) ← AUTO-CREATED by scripts
│  ├─ OpenCrate (RemoteEvent)
│  └─ ClaimSword (RemoteEvent)
│
├─ NormalSword (Tool) ✅ Already have
├─ HolsteredSwordNormal (Model) ✅ Already have
├─ IceSword (Tool) ✅ Already have
├─ HolsteredSwordIce (Model) ✅ Already have
├─ PurpleSword (Tool) ✅ Already have
├─ HolsteredSwordPurple (Model) ✅ Already have
├─ SteelSword (Tool) ✅ Already have
└─ HolsteredSwordSteel (Model) ✅ Already have
```

### ✅ ServerScriptService
```
ServerScriptService
└─ CrateSystemServer (Script) ← CREATE THIS
```

### ✅ StarterPlayer > StarterPlayerScripts
```
StarterPlayerScripts
├─ MultiSwordSystem (LocalScript) ✅ Already have
└─ CrateSystemClient (LocalScript) ← CREATE THIS
```

---

## 🚀 Installation Steps

### Step 1: Create Server Script
1. Go to **ServerScriptService**
2. Insert a **Script** (NOT LocalScript!)
3. Name it **`CrateSystemServer`**
4. Copy code from **`CrateSystemServer.lua`** and paste it

### Step 2: Create Client Script
1. Go to **StarterPlayer > StarterPlayerScripts**
2. Insert a **LocalScript**
3. Name it **`CrateSystemClient`**
4. Copy code from **`CrateSystemClient.lua`** and paste it

### Step 3: Verify Chest Setup
✅ Make sure you have in Workspace:
- **Chest** (MeshPart or Part)
- Inside it: **ProximityPrompt**

The ProximityPrompt settings don't matter much, but recommended:
- ActionText: "Open Crate"
- KeyboardKeyCode: E
- HoldDuration: 0

---

## 🎮 How It Works

### Player Experience:
1. **Walk up to chest** → See "Open Crate" prompt
2. **Press E** → Screen darkens, crate opening UI appears
3. **Animation plays** → Swords spin past in a horizontal list
4. **Slows down** → Eventually lands on a random sword
5. **Shows result** → "YOU GOT: [SWORD NAME]"
6. **Sword auto-equips** → Immediately equipped to player
7. **UI closes** → Player can move again

### Under the Hood:
1. Server picks random sword when chest is opened
2. Tells client to show animation with that sword as the target
3. Client plays smooth CS:GO style animation
4. Client tells server to give the sword
5. Server gives and equips the sword

---

## 🎨 Customization

### Animation Speed
In **CrateSystemClient.lua**, find `UI_SETTINGS`:

```lua
SpinDuration = 4, -- How long spin takes (seconds)
```

- **Faster:** `SpinDuration = 2`
- **Slower:** `SpinDuration = 6`

### Colors
Change the color scheme:

```lua
BackgroundColor = Color3.fromRGB(15, 15, 20), -- Main background
ItemBackgroundColor = Color3.fromRGB(25, 25, 35), -- Sword cards
TextColor = Color3.fromRGB(220, 220, 230), -- Text
AccentColor = Color3.fromRGB(100, 100, 255), -- Selector line & result
```

**Example Color Schemes:**

**Red Theme:**
```lua
AccentColor = Color3.fromRGB(255, 50, 50)
```

**Green Theme:**
```lua
AccentColor = Color3.fromRGB(50, 255, 100)
```

**Purple Theme:**
```lua
AccentColor = Color3.fromRGB(150, 50, 255)
```

### Item Size
Make sword cards bigger or smaller:

```lua
ItemWidth = 200, -- Width of each sword card
ItemSpacing = 20, -- Space between cards
```

### Number of Spins
How many times it loops through all swords before landing:

```lua
SpinRepeats = 3, -- Number of full loops
```

---

## 🎯 Testing

1. **Enter Play mode**
2. **Walk up to the chest**
3. **Press E** when prompted
4. **Watch the animation** (don't try to move, you can't!)
5. **See the result** - Should say "YOU GOT: [SWORD NAME]"
6. **Check your character** - Sword should be equipped automatically
7. **Try it again!** Walk back to chest and open another

---

## 🔧 Advanced Customization

### Add Rarity System

In **CrateSystemServer.lua**, replace the `chooseRandomSword` function:

```lua
-- Function to choose a random sword with rarity
local function chooseRandomSword()
	local rarities = {
		NormalSword = 50,   -- 50% chance
		IceSword = 30,      -- 30% chance
		PurpleSword = 15,   -- 15% chance
		SteelSword = 5,     -- 5% chance (rare!)
	}
	
	local total = 0
	for _, weight in pairs(rarities) do
		total = total + weight
	end
	
	local rand = math.random() * total
	local current = 0
	
	for swordName, weight in pairs(rarities) do
		current = current + weight
		if rand <= current then
			return swordName
		end
	end
	
	return "NormalSword" -- Fallback
end
```

### Add Cooldown

In **CrateSystemServer.lua**, add at the top:

```lua
local playerCooldowns = {}
local COOLDOWN_TIME = 10 -- 10 seconds
```

Then modify the ProximityPrompt handler:

```lua
proximityPrompt.Triggered:Connect(function(player)
	-- Check cooldown
	local lastUse = playerCooldowns[player.UserId] or 0
	local currentTime = tick()
	
	if currentTime - lastUse < COOLDOWN_TIME then
		local remaining = math.ceil(COOLDOWN_TIME - (currentTime - lastUse))
		-- You could send a message to player here
		return
	end
	
	-- Set cooldown
	playerCooldowns[player.UserId] = currentTime
	
	-- Choose a random sword
	local chosenSword = chooseRandomSword()
	
	-- Send to client to show animation
	openCrateEvent:FireClient(player, chosenSword, availableSwords)
end)
```

### Add Sound Effects

In **CrateSystemClient.lua**, add sounds:

```lua
-- At the start of animateCrateOpening function
local spinSound = Instance.new("Sound")
spinSound.SoundId = "rbxassetid://YOUR_SPIN_SOUND_ID"
spinSound.Parent = scrollFrame
spinSound:Play()

-- After tween completes
local winSound = Instance.new("Sound")
winSound.SoundId = "rbxassetid://YOUR_WIN_SOUND_ID"
winSound.Parent = scrollFrame
winSound:Play()
```

---

## 🐛 Troubleshooting

**Problem: Prompt doesn't appear**
- Check that Chest exists in Workspace
- Check that ProximityPrompt is inside Chest
- Check that ProximityPrompt is enabled

**Problem: UI doesn't show**
- Check Output for errors
- Make sure CrateSystemClient is in StarterPlayerScripts
- Make sure it's a LocalScript (not regular Script)

**Problem: No sword is given**
- Check that all 4 swords exist in ReplicatedStorage
- Check that SwordConfig has all 4 swords defined
- Look in Output for warning messages

**Problem: Player can still move during opening**
- The script sets WalkSpeed to 0 temporarily
- This is normal and expected behavior

**Problem: Animation is too fast/slow**
- Adjust `SpinDuration` in UI_SETTINGS
- Adjust `SpinRepeats` for more/less loops

---

## 💡 Pro Tips

1. **Test in actual game mode** (not Studio edit mode) for best results
2. **Adjust SpinDuration** to match your preferred feel
3. **Use the rarity system** to make some swords more special
4. **Add sounds** for better player feedback
5. **Consider adding a cooldown** to prevent spam

---

## 📊 Files Summary

**Created files:**
- `CrateSystemServer.lua` → Copy to Script in ServerScriptService
- `CrateSystemClient.lua` → Copy to LocalScript in StarterPlayerScripts
- `CrateSystemSetup.md` → This guide

**Your existing files:**
- `SwordConfig.lua` (ModuleScript in ReplicatedStorage)
- `MultiSwordSystem.lua` (LocalScript in StarterPlayerScripts)
- All your sword models and tools

---

Everything is ready! Just create those 2 scripts and you're good to go! 🎉
