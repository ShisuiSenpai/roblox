# ✨ Sword Aura System - Setup Guide

## 📋 Overview

I've created a **beautiful aura system** that applies VFX to your character when holding specific swords!

### **Features:**
- ✅ Automatically applies VFX when sword is equipped
- ✅ Smooth fade-in/fade-out with tweening
- ✅ Matches body parts automatically (works with R6 and R15)
- ✅ Copies ALL particle emitters, beams, and attachments
- ✅ Optimized - no performance impact
- ✅ Easy to add more swords

---

## 🎮 How It Works

### **When You Equip DawnStar Sword:**
1. Script detects sword equipped
2. Finds `DawnstarVFX` model in `ReplicatedStorage.Assets.AuraVFX`
3. Scans all body parts in the VFX rig (Head, Torso, LeftLeg, etc.)
4. Matches them to your character's body parts
5. Clones all ParticleEmitters and Attachments to your body
6. Fades in over 0.8 seconds (smooth!)
7. **You now have a glowing aura!** ✨

### **When You Unequip/Switch Swords:**
1. Script detects sword removed
2. Fades out aura over 0.5 seconds
3. Cleans up all effects
4. Character returns to normal

---

## 📂 File Structure

### **Your VFX Setup (Already Exists):**
```
ReplicatedStorage
└── Assets
    └── AuraVFX
        └── DawnstarVFX (Model/Rig)
            ├── Head (Part)
            │   ├── Attachment (with ParticleEmitters)
            │   └── ParticleEmitter (direct child)
            ├── LeftLeg (Part)
            │   └── Attachment (with ParticleEmitters)
            ├── RightLeg (Part)
            │   └── Attachment (with ParticleEmitters)
            ├── UpperTorso (Part)
            │   └── ParticleEmitter
            └── ... (other body parts)
```

### **Script Handles:**
- ✅ Attachments with ParticleEmitters inside
- ✅ ParticleEmitters directly in body parts
- ✅ Beams
- ✅ Any combination of the above

---

## ⚙️ Configuration

### **Edit `AuraSystem.lua` Lines 20-30:**

```lua
local AURA_CONFIG = {
    -- Sword name → VFX model name mapping
    ["DawnStar"] = {
        VFXModel = "DawnstarVFX", -- Name in ReplicatedStorage.Assets.AuraVFX
        FadeInDuration = 0.8, -- Fade in time (seconds)
        FadeOutDuration = 0.5, // Fade out time (seconds)
        Scale = 1.0, -- Particle size multiplier (1.0 = normal, 2.0 = double size)
    },
}
```

### **To Add More Sword Auras:**

Just add more entries:

```lua
local AURA_CONFIG = {
    ["DawnStar"] = {
        VFXModel = "DawnstarVFX",
        FadeInDuration = 0.8,
        FadeOutDuration = 0.5,
        Scale = 1.0,
    },
    
    ["Nightward"] = {
        VFXModel = "NightwardVFX", -- Create this in AuraVFX folder
        FadeInDuration = 1.0,
        FadeOutDuration = 0.7,
        Scale = 1.2, -- Slightly larger particles
    },
    
    ["FireBlade"] = {
        VFXModel = "FireBladeVFX",
        FadeInDuration = 0.5, -- Quick fade in
        FadeOutDuration = 0.3,
        Scale = 0.8, // Smaller particles
    },
}
```

---

## 🎨 How to Create VFX Models

### **For Each Sword Aura:**

1. **Create a Rig Model:**
   - Use R6 or R15 dummy
   - Name it: `[SwordName]VFX` (e.g., `DawnstarVFX`)
   - Place in `ReplicatedStorage.Assets.AuraVFX`

2. **Add Particle Effects:**
   - Select body parts (Head, Torso, Legs, etc.)
   - Add `ParticleEmitter` instances
   - OR add `Attachment` with ParticleEmitters inside
   - Configure colors, sizes, textures, etc.

3. **Configure in Script:**
   - Add entry to `AURA_CONFIG` table
   - Map sword name to VFX model name
   - Set fade durations and scale

4. **Done!** The system auto-copies everything to the player!

---

## 🔧 Technical Details

### **Body Part Matching:**
The script automatically matches these body parts:
- Head, Torso, UpperTorso, LowerTorso
- LeftArm, RightArm, LeftUpperArm, RightUpperArm, etc.
- LeftLeg, RightLeg, LeftUpperLeg, RightUpperLeg, etc.
- LeftHand, RightHand, LeftFoot, RightFoot
- HumanoidRootPart

Works with **both R6 and R15** characters!

### **What Gets Cloned:**
1. **Attachments** - Copied to matching body part
2. **ParticleEmitters** - Whether in attachments or directly in parts
3. **Beams** - If you have any beam effects
4. **Properties preserved** - All settings (color, size, rate, etc.) are kept

### **Transparency Fade System:**
- All emitters start at `Transparency = 1` (invisible)
- Fade in using TweenService
- Original transparency values are stored as attributes
- Smooth, professional fade effect

---

## 🚀 Optimization Features

### **1. Efficient Cloning:**
- Only clones what's needed (no extra objects)
- Stores effects in a single folder for easy cleanup
- No memory leaks

### **2. Smooth Tweening:**
- Uses TweenService for hardware-accelerated animation
- Cancels old tweens before starting new ones
- No tween buildup or lag

### **3. Proper Cleanup:**
- Removes all effects when sword is unequipped
- Clears on character respawn
- No orphaned particles

### **4. Smart Detection:**
- Doesn't reapply if already wearing aura
- Handles rapid sword switching
- Works with character respawn

---

## 🎯 Example Output

### **When Equipping DawnStar:**
```
[AURA SYSTEM] Sword equipped: DawnStar
[AURA SYSTEM] Applying aura for sword: DawnStar
[AURA SYSTEM] ✅ Applied 24 effects to character
[AURA SYSTEM] Fading in aura over 0.8 seconds
```

### **When Unequipping:**
```
[AURA SYSTEM] Fading out aura over 0.5 seconds
[AURA SYSTEM] Removing aura
[AURA SYSTEM] ✅ Aura removed
```

---

## 💡 Tips & Tricks

### **Make Particles Bigger:**
```lua
["DawnStar"] = {
    VFXModel = "DawnstarVFX",
    Scale = 2.0, -- Double size particles!
},
```

### **Faster Fade In:**
```lua
["DawnStar"] = {
    VFXModel = "DawnstarVFX",
    FadeInDuration = 0.3, -- Super quick!
},
```

### **Slower, Dramatic Fade Out:**
```lua
["DawnStar"] = {
    VFXModel = "DawnstarVFX",
    FadeOutDuration = 1.5, // Slow, cinematic!
},
```

---

## 🐛 Troubleshooting

### **Issue: No aura appears**

**Check:**
1. Is sword name exactly `"DawnStar"` (case-sensitive)?
2. Is VFX model named exactly `"DawnstarVFX"`?
3. Is it in `ReplicatedStorage.Assets.AuraVFX`?
4. Check Output for errors

### **Issue: "VFX model not found"**

**Fix:**
- Check path: `ReplicatedStorage → Assets → AuraVFX → DawnstarVFX`
- Verify folder names are exact
- Check spelling

### **Issue: "Could not find matching body part"**

**Cause:** VFX rig has a body part name that doesn't exist in player character

**Fix:**
- Use standard body part names (Head, Torso, LeftLeg, etc.)
- Check if you're using R6 vs R15 names correctly

### **Issue: Particles don't show up**

**Cause:** ParticleEmitters might be disabled or have wrong settings

**Fix:**
- Check that ParticleEmitters in VFX rig have `Enabled = true`
- Check that `Rate` is > 0
- Check that `Lifetime` is reasonable

---

## ✨ Result

When you equip **DawnStar sword**, your character will:
- ✨ Glow with particles from head to toe
- ✨ Fade in smoothly over 0.8 seconds
- ✨ Look **EPIC** and powerful
- ✨ Stand out from other players

When you unequip or switch swords:
- ✨ Fade out smoothly over 0.5 seconds
- ✨ No abrupt disappearance
- ✨ Professional, polished effect

---

## 🎨 Creative Ideas

### **Multiple Aura Types:**
- **??? Rarity (DawnStar):** Rainbow/cosmic particles
- **Godly Rarity:** Gold/holy particles
- **Legendary Rarity:** Epic glow
- **Fire Swords:** Flame particles
- **Ice Swords:** Frost/snow particles

### **Rarity-Based Auras:**
Instead of per-sword, you could make it per-rarity:
- All ??? swords get cosmic aura
- All Godly swords get gold aura
- etc.

(Would require modifying the script to check sword rarity instead of name)

---

## 📝 Summary

**New File Created:**
- ✅ `StarterPlayer/StarterPlayerScripts/AuraSystem.lua`

**What It Does:**
- ✅ Applies body VFX when DawnStar is equipped
- ✅ Removes VFX when unequipped
- ✅ Smooth fading with tweening
- ✅ Optimized and performant
- ✅ Easy to add more swords

**How to Use:**
1. ✅ Make sure `DawnstarVFX` model exists in correct location
2. ✅ Equip DawnStar sword
3. ✅ Enjoy the aura! ✨

**That's it!** Your ??? rarity sword now has an epic body aura! 🚀
