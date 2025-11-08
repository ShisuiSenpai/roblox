# 🎨 ViewportFrame 3D Models - Setup Guide

## 🎯 What's New

Your crate opening animation now shows **actual 3D models** of the swords using ViewportFrames! Just like CS:GO! 🎮

---

## 📂 Required Structure

### ReplicatedStorage Setup:

```
ReplicatedStorage
├─ VFmodels (Folder) ✅ YOU HAVE
│  ├─ NormalSwordVF (Model) ← Must match this naming
│  ├─ IceSwordVF (Model)
│  ├─ PurpleSwordVF (Model)
│  └─ SteelSwordVF (Model)
│
├─ SwordConfig (ModuleScript)
├─ NormalSword (Tool)
├─ IceSword (Tool)
├─ PurpleSword (Tool)
└─ SteelSword (Tool)
```

### ⚠️ IMPORTANT: Model Naming Convention

The models in VFmodels folder **MUST** be named:
```
[SwordName]VF

Examples:
- NormalSword → NormalSwordVF
- IceSword → IceSwordVF
- PurpleSword → PurpleSwordVF
- SteelSword → SteelSwordVF
```

The script automatically adds "VF" to the sword name to find the model!

---

## 🎨 How It Looks Now

### Before (Text Only):
```
┌──────────┐ ┌──────────┐ ┌──────────┐
│          │ │          │ │          │
│  Normal  │ │   Ice    │ │  Purple  │
│  Sword   │ │  Sword   │ │  Sword   │
│          │ │          │ │          │
└──────────┘ └──────────┘ └──────────┘
```

### Now (3D Models):
```
┌──────────┐ ┌──────────┐ ┌──────────┐
│    ⚔️     │ │    🗡️     │ │    ⚔️     │
│   [3D]   │ │   [3D]   │ │   [3D]   │
│  Model   │ │  Model   │ │  Model   │
│          │ │          │ │          │
│  Normal  │ │   Ice    │ │  Purple  │
└──────────┘ └──────────┘ └──────────┘
```

Each card now shows:
- ✅ Actual 3D model of the sword (180x180 pixels)
- ✅ Rotated at a nice angle (45° + camera tilt)
- ✅ Properly lit and sized
- ✅ Text name below the model

---

## ⚙️ Customization Settings

All settings are in `UI_SETTINGS` in the CrateSystemClient:

### Model Display Size
```lua
ViewportSize = 180, -- Size of the 3D preview (pixels)
```
- **Smaller:** `ViewportSize = 150` (more compact)
- **Larger:** `ViewportSize = 220` (bigger models)

### Camera Distance
```lua
CameraDistance = 8, -- How far camera is from model
```
- **Closer:** `CameraDistance = 5` (zoomed in)
- **Further:** `CameraDistance = 12` (full sword visible)

### Model Rotation
```lua
ModelRotation = 25, -- Angle in degrees
```
- **Straight:** `ModelRotation = 0`
- **More angled:** `ModelRotation = 45`

### Card Width
```lua
ItemWidth = 220, -- Width of each sword card
```
Automatically adjusted for 3D models (wider than text-only)

---

## 🔧 How ViewportFrame Works

### Camera Setup:
1. **Calculates model size** using GetBoundingBox()
2. **Positions camera** at an angle looking at the model
3. **Tilts camera** 15° down for better view
4. **Rotates model** 45° on Y-axis for depth

### Lighting:
- **Ambient:** Bright gray (200, 200, 200) - overall lighting
- **LightColor:** Pure white (255, 255, 255) - highlights

### Positioning:
- Model is **centered** in the viewport
- Camera **distance scales** with model size
- Works with **any size sword model**

---

## 🎯 Creating VF Models

### Best Practices:

1. **Copy your existing sword models**
   - Right-click your sword model → Duplicate
   - Rename with "VF" suffix

2. **Clean up the model**
   - Remove any scripts
   - Keep only the visual parts
   - Make sure all parts are welded/attached properly

3. **Check the pivot point**
   - Select the model
   - The pivot should be near the center/handle
   - This is what the camera looks at

4. **Test the size**
   - Models are automatically scaled to fit
   - But try to keep them similar sizes for consistency

### Example Structure:
```
NormalSwordVF (Model)
├─ Handle (MeshPart)
├─ Blade (MeshPart)
├─ Guard (MeshPart)
└─ Pommel (MeshPart)
```

---

## 🐛 Troubleshooting

### Problem: "Model Not Found" text shows
**Solution:** Check that:
- [ ] Folder is named exactly `VFmodels` in ReplicatedStorage
- [ ] Model is named exactly `[SwordName]VF`
- [ ] Model is inside the VFmodels folder
- [ ] No typos in names (case-sensitive!)

### Problem: Model is too small/large
**Solution:** Adjust `CameraDistance` in UI_SETTINGS:
```lua
CameraDistance = 12, -- Increase to show more of model
```

### Problem: Model is rotated weird
**Solution:** Adjust `ModelRotation`:
```lua
ModelRotation = 0, -- Start with 0 and adjust
```

### Problem: Model is dark/hard to see
**Solution:** Increase lighting:
```lua
viewport.Ambient = Color3.fromRGB(255, 255, 255) -- Brighter
viewport.LightColor = Color3.fromRGB(255, 255, 255)
```

### Problem: Can't see whole sword
**Solution:** 
1. Increase camera distance
2. Or check your model's pivot point
3. Make sure all parts are properly positioned

---

## 💡 Advanced Customization

### Add Animated Rotation

Make swords slowly spin in the viewport:

```lua
-- After setupViewportCamera(viewport, model)
task.spawn(function()
	local rotation = 0
	while viewport and viewport.Parent do
		rotation = rotation + 1
		if model and model.Parent then
			local modelCFrame, modelSize = model:GetBoundingBox()
			model:PivotTo(modelCFrame * CFrame.Angles(0, math.rad(rotation), 0))
		end
		task.wait(0.03)
	end
end)
```

### Add Glow Effect for Rare Swords

```lua
-- Add after creating viewport
if swordName == "SteelSword" then -- Rare sword
	local glow = Instance.new("ImageLabel")
	glow.Size = UDim2.new(1, 20, 1, 20)
	glow.Position = UDim2.new(0, -10, 0, -10)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxasset://textures/ui/Glow.png"
	glow.ImageColor3 = Color3.fromRGB(255, 215, 0) -- Gold glow
	glow.ImageTransparency = 0.5
	glow.ZIndex = 0
	glow.Parent = itemFrame
end
```

### Change Background Color for Each Sword

```lua
-- In createSwordItem function, replace BackgroundColor3
local rarityColors = {
	NormalSword = Color3.fromRGB(25, 25, 35), -- Gray
	IceSword = Color3.fromRGB(25, 35, 45), -- Blue tint
	PurpleSword = Color3.fromRGB(35, 25, 45), -- Purple tint
	SteelSword = Color3.fromRGB(45, 45, 25), -- Gold tint
}

itemFrame.BackgroundColor3 = rarityColors[swordName] or UI_SETTINGS.ItemBackgroundColor
```

---

## ✅ What You Need to Do

1. ✅ **Update CrateSystemClient.lua** with the new code
2. ✅ **Make sure VFmodels folder exists** in ReplicatedStorage
3. ✅ **Add your 4 sword models** with correct names:
   - NormalSwordVF
   - IceSwordVF
   - PurpleSwordVF
   - SteelSwordVF
4. ✅ **Test** - Open a crate and see 3D models!

---

## 📊 Technical Details

### ViewportFrame Properties:
- **Size:** 180x180 (adjustable)
- **Position:** Centered in card, 10px from top
- **Ambient Light:** RGB(200, 200, 200)
- **Light Color:** RGB(255, 255, 255)
- **Camera Angle:** 15° down, rotatable

### Performance:
- ✅ Models are cloned efficiently
- ✅ Camera is set up once per card
- ✅ No continuous updates (static display)
- ✅ ViewportFrames are destroyed when UI closes
- ✅ No performance impact with 60+ cards

---

Now your crate opening looks **exactly like CS:GO** with real 3D models! 🎉
