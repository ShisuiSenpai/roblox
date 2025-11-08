# ⚡ ViewportFrame Quick Setup

## ✅ What Changed

Your crate opening now shows **actual 3D sword models** instead of just text!

---

## 🚀 Setup in 3 Steps

### Step 1: Update the Script
Replace `CrateSystemClient.lua` in StarterPlayerScripts with the new version

### Step 2: Check Your Folder Structure
```
ReplicatedStorage
└─ VFmodels (Folder) ✅
   ├─ NormalSwordVF (Model)
   ├─ IceSwordVF (Model)
   ├─ PurpleSwordVF (Model)
   └─ SteelSwordVF (Model)
```

### Step 3: Name Your Models Correctly
**Pattern:** `[SwordName]VF`

- NormalSword → **NormalSwordVF**
- IceSword → **IceSwordVF**
- PurpleSword → **PurpleSwordVF**
- SteelSword → **SteelSwordVF**

---

## 🎨 What It Looks Like

### Old:
```
┌─────────┐
│  Ice    │  ← Just text
│  Sword  │
└─────────┘
```

### New:
```
┌─────────┐
│   🗡️    │  ← Actual 3D model!
│  [3D]   │
│         │
│   Ice   │  ← Small text below
└─────────┘
```

---

## ⚙️ Quick Customization

In `CrateSystemClient.lua`, find `UI_SETTINGS`:

**Make models bigger:**
```lua
ViewportSize = 200, -- Default is 180
```

**Zoom camera in:**
```lua
CameraDistance = 5, -- Default is 8
```

**Change rotation:**
```lua
ModelRotation = 45, -- Default is 25
```

---

## 🐛 If Model Doesn't Show

Check Output window for: `"VF Model not found: [name]"`

**Fix:**
1. Make sure model name is EXACTLY: `[SwordName]VF`
2. Model is IN the `VFmodels` folder
3. Folder is IN ReplicatedStorage
4. Names are case-sensitive!

---

## ✅ That's It!

Test by opening a crate - you should see beautiful 3D models spinning by! 🎉

For more details, see `ViewportFrame_Setup_Guide.md`
