# 🎁 Dual Crate System Setup Instructions

## 📋 Overview
You now have **TWO crate types** with separate proximity prompts:
- **Regular Relic (Normal Crate)** - Costs 250 Yen (in-game currency)
- **Premium Relic (Premium Crate)** - Costs Robux (real money), **2-3x better drop rates**

---

## 🏗️ Workspace Structure

Your workspace should already have this structure:
```
Workspace
└── Lobby
    ├── NormalCrate (Model/Folder)
    │   └── NormalPart (Part)
    │       └── OpenNormalCrate (ProximityPrompt)
    └── PremiumCrate (Model/Folder)
        └── PremiumPart (Part)
            └── OpenPremiumCrate (ProximityPrompt)
```

✅ **If you already have this, you're good!**

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

## ⚙️ STEP 2: Configure the Script

1. Open `ServerScriptService` → `DualCrateSystem.lua`
2. Find line ~26 (Premium config)
3. Replace `ProductId = 0` with your actual Developer Product ID:

```lua
Premium = {
    Cost = 99, -- Change this to your Robux price
    ProductId = 1234567890, -- ← PASTE YOUR PRODUCT ID HERE
    CostType = "Robux",
    ProximityText = "Premium Relic | 99 R$",
    -- ... rest of config
}
```

**You can also customize the proximity prompt text here!**

---

## 📊 STEP 3: Adjust Drop Rates (Optional)

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

## ✅ STEP 4: Test It!

### Test Regular Crate:
1. Play test in Studio
2. Walk up to **NormalCrate**
3. Should show: `"Regular Relic | ¥250"`
4. Open with 250+ Yen
5. Animation plays, sword added

### Test Premium Crate:
1. Walk up to **PremiumCrate**
2. Should show: `"Premium Relic | 99 R$"`
3. Click/press E
4. **Robux purchase prompt appears**
5. (In Studio, you can't actually purchase, but prompt should appear)

---

## 🎨 Visual Enhancement Ideas

### Make Premium Crate Stand Out:

**Gold/Shiny Effect:**
```lua
-- Select PremiumPart in Workspace
local premiumPart = workspace.Lobby.PremiumCrate.PremiumPart

-- Make it glow
premiumPart.Material = Enum.Material.Neon
premiumPart.Color = Color3.fromRGB(255, 215, 0) -- Gold

-- Add PointLight
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(255, 215, 0)
light.Brightness = 2
light.Range = 15
light.Parent = premiumPart

-- Add ParticleEmitter (sparkles)
local particles = Instance.new("ParticleEmitter")
particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
particles.Rate = 20
particles.Lifetime = NumberRange.new(1, 2)
particles.Speed = NumberRange.new(2, 5)
particles.Parent = premiumPart
```

**Different Size/Color:**
- Make premium crate **taller** or **larger**
- Use **gold/purple/rainbow** colors
- Place it on a **pedestal**
- Add a **sign** or **billboard** above it

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
- **Regular:** 250 Yen (achievable through gameplay - 7 kills or 3 wins + 1 kill)
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
1. ✅ Make sure workspace structure is correct (`Lobby/NormalCrate/NormalPart`, etc.)
2. ✅ Create Developer Product on Roblox website
3. ✅ Copy Product ID
4. ✅ Paste Product ID in `DualCrateSystem.lua` (line ~26)
5. ✅ Test both crates
6. ✅ (Optional) Make premium crate look fancy with particles/lights
7. ✅ (Optional) Adjust drop rates and prices

**That's it!** Your game now has a **dual crate system** with Yen and Robux monetization! 🎮💰

---

## 🐛 Troubleshooting

**"Lobby not found" error:**
- Make sure `Lobby` folder/model exists in `Workspace`
- Check spelling (case-sensitive!)

**"NormalCrate not found" error:**
- Make sure `NormalCrate` is inside `Lobby`
- Check that it's named exactly `NormalCrate` (not "Normal Crate" with a space)

**"OpenNormalCrate ProximityPrompt not found" error:**
- Make sure the ProximityPrompt is inside `NormalPart`
- Check that it's named exactly `OpenNormalCrate`
- Same applies for Premium crate

**Regular crate doesn't deduct Yen:**
- Make sure `CurrencyManager.lua` is running
- Check Output for currency-related errors
- Verify you have 250+ Yen before opening

**Premium purchase doesn't work:**
- Make sure `ProductId` is set correctly in `DualCrateSystem.lua`
- Check that the Product exists in Creator Dashboard
- Remember: Purchases don't work in Studio, only in published game

**Need Help?**
Check the Output window for detailed error messages. All scripts print helpful debug info!
