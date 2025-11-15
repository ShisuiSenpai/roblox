# 🎁 Dual Crate System Setup Instructions

## 📋 Overview
You now have a **clean dual crate system**:
- **ONE proximity prompt** at the crate
- Opens a **beautiful UI** showing BOTH options
- **Regular Relic** - Costs 250 Yen (in-game currency)
- **Premium Relic** - Costs Robux (real money), **2-3x better drop rates**

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

## ⚙️ STEP 2: Configure the Scripts

### A. Set Premium Crate Product ID

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

### B. Set Crate Image IDs

1. Open `StarterPlayer` → `StarterPlayerScripts` → `CrateChoiceUI.lua`
2. Find lines ~32-33 (UI_CONFIG)
3. Replace the image asset IDs with your actual uploaded images:

```lua
local UI_CONFIG = {
    -- ... other settings ...
    
    -- Image Assets (USER WILL REPLACE THESE)
    RegularCrateImage = "rbxassetid://1234567890", -- ← PASTE YOUR REGULAR CRATE IMAGE ID
    PremiumCrateImage = "rbxassetid://9876543210", -- ← PASTE YOUR PREMIUM CRATE IMAGE ID
}
```

**How to get Image IDs:**
1. Go to Roblox Creator Dashboard → Development Items → Decals
2. Upload your crate images (PNG/JPG recommended)
3. Click on the uploaded decal
4. Copy the **Asset ID** from the URL
5. Paste into the config above

**⚠️ IMPORTANT:** 
- If you don't set images, placeholder text will show instead
- Images should be square (512x512 or 1024x1024 recommended)
- Make sure images are approved by Roblox moderation

---

## 🗑️ STEP 3: Remove Old Script

1. **DELETE** `ServerScriptService` → `CrateSystem.lua` (old version, if it exists)
2. The new `DualCrateSystem.lua` replaces it completely

---

## ✅ STEP 4: Test It!

### How It Works Now:
1. Play test in Studio
2. Walk up to the **single crate**
3. ProximityPrompt shows: `"Open Relic"`
4. Click/Press E → **UI pops up** with both options:
   - **Regular Relic (¥ 250)** - Standard drops
   - **Premium Relic (99 R$)** - Better drops!
5. Player chooses which one they want
6. Animation plays, sword awarded

### Test Regular Crate:
- Make sure you have 250+ Yen
- Click "OPEN" on Regular card
- Should deduct Yen and open crate

### Test Premium Crate:
- Click "OPEN" on Premium card
- **Robux purchase prompt appears**
- (In Studio, you can't actually purchase, but prompt should show)

---

## 📊 STEP 5: Adjust Drop Rates (Optional)

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

## 🎨 STEP 6: Customize UI (Optional)

### Change UI Colors/Text:
Open `StarterPlayer/StarterPlayerScripts/CrateChoiceUI.lua` and edit:

```lua
local UI_CONFIG = {
    BackgroundColor = Color3.fromRGB(15, 15, 20),
    RegularCardColor = Color3.fromRGB(30, 30, 40),
    PremiumCardColor = Color3.fromRGB(45, 35, 60),
    
    TextColor = Color3.fromRGB(255, 255, 255),
    PriceColor = Color3.fromRGB(120, 220, 120), -- Green for Yen
    RobuxColor = Color3.fromRGB(255, 215, 0), -- Gold for Robux
    
    AccentColor = Color3.fromRGB(100, 150, 255), -- Regular button/border
    PremiumAccent = Color3.fromRGB(255, 215, 0), -- Premium button/border
}
```

### Change Prices/Text:
- **Regular price:** Line ~192 (`regularPrice.Text = "¥ 250"`)
- **Premium price:** Line ~297 (`premiumPrice.Text = "99 R$"`)
- **Regular description:** Line ~183 (regularDesc)
- **Premium description:** Line ~288 (premiumDesc)
- **Title:** Line ~114 (`title.Text = "Choose Relic Type"`)

### Change Button Text:
- **Regular button:** Line ~208 (`regularButton.Text = "OPEN"`)
- **Premium button:** Line ~313 (`premiumButton.Text = "OPEN"`)

---

## 🔒 Security & Anti-Exploit

✅ **All checks done on server**
✅ **Robux payment required before opening**
✅ **Can't open multiple crates simultaneously**
✅ **Developer Products are secure (Roblox handles payment)**
✅ **Receipt processing ensures player gets their purchase**
✅ **UI is client-side only - all logic server-side**

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

## 🎨 Visual Enhancement Ideas

### Make Crate Stand Out:

**Gold/Shiny Effect:**
```lua
-- Select OpenCratePart in Workspace
local cratePart = workspace.CrateTemple.OpenCratePart

-- Make it glow
cratePart.Material = Enum.Material.Neon
cratePart.Color = Color3.fromRGB(100, 150, 255) -- Blue glow

-- Add PointLight
local light = Instance.new("PointLight")
light.Color = Color3.fromRGB(100, 150, 255)
light.Brightness = 2
light.Range = 15
light.Parent = cratePart

-- Add ParticleEmitter (sparkles)
local particles = Instance.new("ParticleEmitter")
particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
particles.Rate = 20
particles.Lifetime = NumberRange.new(1, 2)
particles.Speed = NumberRange.new(2, 5)
particles.Parent = cratePart
```

**Place on Pedestal:**
- Make crate **elevated**
- Add a **platform** beneath it
- Add a **sign** or **billboard** above saying "SWORD RELICS"

---

## ✨ What's Better About This System?

### Old Way (2 Proximity Prompts):
❌ Two crates next to each other (ugly)
❌ Confusing for players
❌ Hard to explain differences
❌ Takes up more space

### New Way (UI Choice):
✅ **ONE clean crate location**
✅ **Professional UI** shows both options
✅ **Side-by-side comparison** of benefits
✅ **Clear pricing** and descriptions
✅ **Looks like a real game!** 🎮

---

## 📝 Summary

**What You Need To Do:**
1. ✅ Create Developer Product on Roblox website
2. ✅ Copy Product ID
3. ✅ Paste Product ID in `DualCrateSystem.lua` (line ~24)
4. ✅ Upload your crate images to Roblox (Decals)
5. ✅ Paste Image IDs in `CrateChoiceUI.lua` (lines ~32-33)
6. ✅ Delete old `CrateSystem.lua` (if it exists)
7. ✅ Test by walking up to crate and choosing an option
8. ✅ (Optional) Customize UI colors/text in `CrateChoiceUI.lua`
9. ✅ (Optional) Make crate look fancy with particles/lights

**That's it!** Your game now has a **clean, professional dual crate system** with a beautiful UI! 🎮✨

---

## 🐛 Troubleshooting

**UI doesn't appear when clicking crate:**
- Check Output for errors
- Make sure `CrateChoiceUI.lua` is in `StarterPlayer > StarterPlayerScripts`
- Check that RemoteEvents exist in `ReplicatedStorage > CrateRemotes`

**Premium purchase doesn't work:**
- Make sure `ProductId` is set correctly in `DualCrateSystem.lua`
- Check that the Product exists in Creator Dashboard
- Remember: Purchases don't work in Studio, only in published game

**Regular crate doesn't deduct Yen:**
- Make sure `CurrencyManager.lua` is running
- Check Output for currency-related errors
- Verify you have 250+ Yen before opening

**Images showing "IMAGE HERE" text:**
- This means you haven't set the image IDs yet in `CrateChoiceUI.lua`
- Follow Step 2B above to upload images and set IDs
- If you have set IDs but still see placeholders, check that the Asset IDs are correct

**Need Help?**
Check the Output window for detailed error messages. All scripts print helpful debug info!
