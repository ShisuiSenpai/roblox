# Multi Jump Pad Setup Guide

## 🎯 Overview

This system lets you have **unlimited jump pads** with **only 2 scripts total**:
- ✅ 1 server script (manages ALL pads)
- ✅ 1 client script (handles ALL physics)

No more duplicating scripts for each pad!

---

## 📦 Installation (One-Time Setup)

### Step 1: Server Manager Script

1. Go to **ServerScriptService**
2. Add a **Script** (regular Script, not LocalScript)
3. Copy ALL code from **`JumpPadManager.lua`** into it
4. Name it "JumpPadManager"

```
ServerScriptService
  └─ JumpPadManager (Script) ← Manages all jump pads
```

### Step 2: Client Script (Same as Before)

1. Go to **StarterPlayer** > **StarterPlayerScripts**
2. Add a **LocalScript**
3. Copy ALL code from **`JumpPadClient.lua`** into it
4. Name it "JumpPadClient"

```
StarterPlayer
  └─ StarterPlayerScripts
      └─ JumpPadClient (LocalScript) ← Handles all physics
```

**Done!** Now you can add unlimited jump pads.

---

## 🎨 Adding Jump Pads (Easy Method)

### For Each Jump Pad:

1. Create a **Part** in Workspace
2. Name it anything you want (e.g., "JumpPad", "SuperJump", "SpeedBoost")
3. **Right-click the Part** → **Add Tag** → Type **"JumpPad"**
4. Done! It automatically works!

```
Workspace
  ├─ JumpPad (Part) [Tagged: "JumpPad"]
  ├─ SuperJump (Part) [Tagged: "JumpPad"]
  ├─ SpeedBoost (Part) [Tagged: "JumpPad"]
  └─ AnotherJumpPad (Part) [Tagged: "JumpPad"]
```

**No scripts in the parts!** Just the tag.

---

## 🏷️ How to Add Tags

### Method 1: Using Tag Editor (Recommended)

1. **Open Tag Editor:**
   - Click **View** in top menu → Check **"Tags"**
   - Tag Editor panel appears on right side

2. **Tag your parts:**
   - Select a Part
   - In Tag Editor, click **"+"**
   - Type: `JumpPad`
   - Press Enter

### Method 2: Via Properties Panel

1. Select your Part
2. In Properties, find **"Tags"**
3. Click **"+"**
4. Type: `JumpPad`
5. Press Enter

### Method 3: Via Script (For Batch Tagging)

```lua
-- Select multiple parts, run this in Command Bar:
for _, part in ipairs(game.Selection:Get()) do
    CollectionService:AddTag(part, "JumpPad")
end
```

---

## ⚙️ Configuration

### Default Settings (All Pads)

Open **JumpPadManager** in ServerScriptService:

```lua
local DEFAULT_SETTINGS = {
    JumpStrength = 50,      -- Change for all pads
    Cooldown = 0.5,
    ShowVisual = true,
    ActiveColor = Color3.fromRGB(0, 255, 150),
    FlashDuration = 0.2
}
```

This applies to **every jump pad** unless you override it.

---

### Custom Settings (Specific Pads)

Want different pads with different strengths? Add custom configs by **part name**:

```lua
local CUSTOM_CONFIGS = {
    ["SuperJump"] = {
        JumpStrength = 100,
        Cooldown = 0.7,
        ActiveColor = Color3.fromRGB(255, 100, 0)
    },
    ["SpeedBoost"] = {
        JumpStrength = 35,
        Cooldown = 0.3,
        ActiveColor = Color3.fromRGB(100, 200, 255)
    },
    ["MegaLaunch"] = {
        JumpStrength = 150,
        Cooldown = 1.0,
        ActiveColor = Color3.fromRGB(255, 0, 255)
    }
}
```

**How it works:**
1. Manager checks the Part's **Name**
2. If name matches a custom config, uses those settings
3. Otherwise, uses default settings

**Example:**
- Part named "JumpPad" → Uses default (50 strength)
- Part named "SuperJump" → Uses custom (100 strength)
- Part named "MyCustomPad" → Uses default (50 strength)
- Part named "SpeedBoost" → Uses custom (35 strength)

---

## 🎮 Full Example

Let's create 3 different jump pad types:

### 1. Standard Jump Pad

```
1. Create a Part
2. Name it: "JumpPad"
3. Tag it: "JumpPad"
4. Color: Green
```

Result: Uses default settings (50 strength)

### 2. Super Jump Pad

```
1. Create a Part
2. Name it: "SuperJump"
3. Tag it: "JumpPad"
4. Color: Orange
5. Material: Neon
```

Add to JumpPadManager:
```lua
local CUSTOM_CONFIGS = {
    ["SuperJump"] = {
        JumpStrength = 100,
        ActiveColor = Color3.fromRGB(255, 100, 0)
    }
}
```

Result: Jumps twice as high!

### 3. Speed Boost Pad

```
1. Create a Part
2. Name it: "SpeedBoost"
3. Tag it: "JumpPad"
4. Color: Cyan
```

Add to JumpPadManager:
```lua
local CUSTOM_CONFIGS = {
    ["SuperJump"] = {
        JumpStrength = 100,
        ActiveColor = Color3.fromRGB(255, 100, 0)
    },
    ["SpeedBoost"] = {
        JumpStrength = 35,
        ActiveColor = Color3.fromRGB(100, 200, 255)
    }
}
```

And in **JumpPadClient**, increase:
```lua
local HORIZONTAL_PRESERVATION = 1.5  -- Speed boost!
```

---

## 📊 System Overview

```
┌─────────────────────────────────────────────────┐
│  ServerScriptService                            │
│    └─ JumpPadManager (Script)                   │
│       ├─ Watches for "JumpPad" tag              │
│       ├─ Manages all pads automatically         │
│       └─ Handles cooldowns & validation         │
└─────────────────────────────────────────────────┘
                      │
                      │ RemoteEvent
                      │
┌─────────────────────────────────────────────────┐
│  StarterPlayerScripts                           │
│    └─ JumpPadClient (LocalScript)               │
│       └─ Applies physics for all pads           │
└─────────────────────────────────────────────────┘
                      │
                      │ Works with
                      ▼
┌─────────────────────────────────────────────────┐
│  Workspace                                      │
│    ├─ JumpPad [Tag: "JumpPad"] ← Auto-managed  │
│    ├─ SuperJump [Tag: "JumpPad"] ← Auto-managed│
│    ├─ SpeedBoost [Tag: "JumpPad"] ← Auto-managed│
│    └─ (Any part with tag) ← Auto-managed       │
└─────────────────────────────────────────────────┘
```

---

## ✅ Benefits

### Old System (Per-Pad Scripts):
- ❌ 10 pads = 10 duplicate server scripts
- ❌ Hard to update all pads at once
- ❌ Easy to make mistakes copying scripts

### New System (Tag-Based):
- ✅ 100 pads = still just 1 server script
- ✅ Update one script, affects all pads
- ✅ Just tag parts, no scripting needed
- ✅ Can still customize individual pads by name

---

## 🔧 Advanced: Per-Pad Settings with Attributes

Want different settings **without naming**? Use Attributes:

```lua
-- In JumpPadManager, modify getSettings:
local function getSettings(pad)
    local settings = {}
    for k, v in pairs(DEFAULT_SETTINGS) do
        settings[k] = v
    end
    
    -- Check for attribute overrides
    local attrStrength = pad:GetAttribute("JumpStrength")
    if attrStrength then
        settings.JumpStrength = attrStrength
    end
    
    return settings
end
```

Then in Roblox Studio:
1. Select a Part
2. In Properties, click **"+"** next to Attributes
3. Add attribute: `JumpStrength` (Number) = 75
4. That specific pad now jumps at 75 strength!

---

## 🚨 Troubleshooting

**Pads not working?**
- [ ] Is the Part tagged with **"JumpPad"**? (Check Tag Editor)
- [ ] Is JumpPadManager in **ServerScriptService**?
- [ ] Is JumpPadClient in **StarterPlayerScripts**?
- [ ] Check Output for "✅ Jump Pad Manager ready!"

**Tag not appearing?**
- Make sure Tag Editor is open: **View → Tags**
- Tag name is case-sensitive: must be `JumpPad` exactly

**Custom config not working?**
- Check the Part's **Name** matches the config key exactly
- Names are case-sensitive: "superjump" ≠ "SuperJump"

---

## 📝 Quick Reference

| Task | How To |
|------|--------|
| Add new pad | Create Part → Tag "JumpPad" |
| Change default strength | Edit `DEFAULT_SETTINGS.JumpStrength` |
| Create custom pad type | Add entry to `CUSTOM_CONFIGS` |
| Remove pad | Remove "JumpPad" tag (auto-cleanup) |
| Change all pads | Edit JumpPadManager settings |
| Change one pad | Name it and add to `CUSTOM_CONFIGS` |

---

## 🎯 Next Steps

1. **Install the 2 scripts** (JumpPadManager + JumpPadClient)
2. **Tag your existing Part** with "JumpPad"
3. **Test it**
4. **Duplicate the Part** as many times as you want
5. **Adjust settings** in JumpPadManager

You can now have hundreds of jump pads with zero script duplication! 🚀
