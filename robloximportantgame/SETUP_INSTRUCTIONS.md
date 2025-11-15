# 🎁 Dual Crate System Setup Instructions

## 📋 Overview
You now have TWO crate types:
- **Regular Crate** - Costs 250 Yen (in-game currency)
- **Premium Crate** - Costs Robux (real money), better drop rates

---

## 🔧 STEP 1: Create Developer Product

1. Go to **Roblox Creator Dashboard**: https://create.roblox.com/
2. Select your game
3. Go to **Monetization** → **Passes, Products & DLC**
4. Click **Create a Developer Product**
5. Fill in:
   - **Name:** `Premium Relic Crate`
   - **Description:** `Open a premium crate with better drop rates!`
   - **Price:** `99` Robux (or whatever you want)
6. Click **Create**
7. **COPY THE PRODUCT ID** (it's in the URL or on the product page)

---

## 🏗️ STEP 2: Create Premium Crate in Workspace

### Option A: Duplicate Existing Crate (Easiest)
1. Open Roblox Studio
2. Find `Workspace` → `CrateTemple` → `OpenCratePart`
3. **Duplicate it** (Ctrl+D)
4. Rename the duplicate to: `PremiumCratePart`
5. **Move it to a different location** (next to regular crate)
6. Find the `OpenSwordBox` ProximityPrompt inside it
7. Rename it to: `OpenPremiumBox`

### Option B: Make Premium Crate Look Different (Recommended)
1. After duplicating, select `PremiumCratePart`
2. Change its appearance:
   - **Color:** Gold/Purple/Rainbow (make it fancy!)
   - **Material:** Neon or ForceField
   - **Add effects:** ParticleEmitter, PointLight (gold sparkles!)
3. This makes it clear which is premium

**IMPORTANT:** Structure should be:
```
Workspace
└── CrateTemple
    ├── OpenCratePart (Regular - already exists)
    │   └── OpenSwordBox (ProximityPrompt)
    └── PremiumCratePart (NEW - Premium)
        └── OpenPremiumBox (ProximityPrompt)
```

---

## ⚙️ STEP 3: Configure the Script

1. Open `ServerScriptService` → `DualCrateSystem.lua`
2. Find line ~24 (Premium config)
3. Replace `ProductId = 0` with your actual Developer Product ID:

```lua
Premium = {
    Cost = 99, -- Change this to your Robux price
    ProductId = 1234567890, -- ← PASTE YOUR PRODUCT ID HERE
    CostType = "Robux",
    -- ... rest of config
}
```

---

## 📊 STEP 4: Adjust Drop Rates (Optional)

In `DualCrateSystem.lua`, you can customize the rarity multipliers:

```lua
Premium = {
    -- ... other settings ...
    RarityMultipliers = {
        ["Common"] = 0.5,    -- 50% chance (half as common)
        ["Uncommon"] = 0.7,  -- 70% chance
        ["Rare"] = 1.2,      -- 120% chance (20% boost)
        ["Legendary"] = 2.0, -- 200% chance (DOUBLE!)
        ["Godly"] = 3.0,     -- 300% chance (TRIPLE!)
        ["???"] = 2.5,       -- 250% chance
    },
}
```

**Example:** If "Godly" normally has 5% chance, premium crate makes it 15% (5% × 3.0)

---

## 🗑️ STEP 5: Remove Old Script

1. **DELETE** `ServerScriptService` → `CrateSystem.lua` (old version)
2. The new `DualCrateSystem.lua` replaces it completely

---

## ✅ STEP 6: Test It!

### Test Regular Crate:
1. Play test in Studio
2. Walk up to regular crate
3. Should show: `"Regular Relic | ¥250"`
4. Open with 250+ Yen
5. Animation plays, sword added

### Test Premium Crate:
1. Walk up to premium crate
2. Should show: `"Premium Relic | 99 R$"`
3. Click/press E
4. **Robux purchase prompt appears**
5. (In Studio, you can't actually purchase, but prompt should appear)

---

## 🎨 Visual Enhancement Ideas

### Make Premium Crate Stand Out:

**Gold/Shiny Effect:**
```lua
-- Add to PremiumCratePart
premiumCratePart.Material = Enum.Material.Neon
premiumCratePart.Color = Color3.fromRGB(255, 215, 0) -- Gold

-- Add PointLight
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255, 215, 0)
light.Brightness = 2
light.Range = 15
light.Parent = premiumCratePart

-- Add ParticleEmitter (sparkles)
local particles = Instance.new("ParticleEmitter")
particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
particles.Rate = 20
particles.Lifetime = NumberRange.new(1, 2)
particles.Speed = NumberRange.new(2, 5)
particles.Parent = premiumCratePart
```

**Different Size/Height:**
- Make premium crate **taller** or **larger**
- Place it on a **pedestal**
- Add a **sign** above it saying "PREMIUM"

---

## 🔒 Security & Anti-Exploit

✅ **All checks done on server**
✅ **Robux payment required before opening**
✅ **Can't open multiple crates simultaneously**
✅ **Developer Products are secure (Roblox handles payment)**
✅ **Receipt processing ensures player gets their purchase**

---

## 💡 Monetization Tips

### Pricing Strategy:
- **Regular:** 250 Yen (achievable through gameplay - 3-4 kills or 1 win)
- **Premium:** 99 Robux (affordable impulse purchase)

### Value Proposition:
- Premium gives **2-3x better odds** for rare items
- Players who want instant gratification buy premium
- Free players grind Yen for regular crates
- Both are valuable!

### Recommended Robux Prices:
- **Single Premium Crate:** 99 R$ (good entry point)
- **3-Pack Bundle:** 249 R$ (save 48 R$) - *implement later*
- **10-Pack Bundle:** 799 R$ (save 191 R$) - *implement later*

---

## 📝 Summary

**What You Need To Do:**
1. ✅ Create Developer Product on Roblox website
2. ✅ Copy Product ID
3. ✅ Duplicate crate in workspace (name it `PremiumCratePart`)
4. ✅ Paste Product ID in `DualCrateSystem.lua`
5. ✅ Delete old `CrateSystem.lua`
6. ✅ Test both crates
7. ✅ Customize premium crate appearance (make it shiny!)

**That's it!** Your game now has a premium monetization option while keeping free-to-play viable. 🎮💰
