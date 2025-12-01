# Visual Setup Guide - Multi Jump Pad System

## 🎯 The Simple Truth

**You only need 2 scripts for unlimited jump pads.**

```
┌──────────────────────────────────────────┐
│  2 SCRIPTS = ∞ JUMP PADS                 │
└──────────────────────────────────────────┘
```

---

## 📦 Installation Diagram

```
YOUR GAME
│
├─ ServerScriptService
│  └─ 📄 JumpPadManager         ← 1. Copy JumpPadManager.lua here
│                                   (manages all pads automatically)
│
├─ StarterPlayer
│  └─ StarterPlayerScripts
│     └─ 📄 JumpPadClient        ← 2. Copy JumpPadClient.lua here
│                                   (handles physics for all pads)
│
└─ Workspace
   ├─ 🟩 JumpPad                 ← 3. Tag with "JumpPad"
   ├─ 🟧 SuperJump               ← 3. Tag with "JumpPad"
   ├─ 🟦 SpeedBoost              ← 3. Tag with "JumpPad"
   └─ 🟩 AnotherJumpPad          ← 3. Tag with "JumpPad"
      (no scripts inside!)         (just the tag!)
```

---

## 🏷️ How to Tag Parts

### Visual Steps:

```
Step 1: Open Tag Editor
┌────────────────────────┐
│ VIEW → ☑ Tags          │
└────────────────────────┘

Step 2: Select Your Part
┌────────────────────────┐
│ Click on JumpPad Part  │
└────────────────────────┘

Step 3: Add Tag
┌────────────────────────┐
│ Tag Editor Panel       │
│ ┌────────────────────┐ │
│ │ + JumpPad          │ │
│ └────────────────────┘ │
└────────────────────────┘

Step 4: Press Enter!
```

---

## ⚙️ Configuration Visual

### Where Settings Live:

```
┌─────────────────────────────────────────────┐
│  JumpPadManager.lua (ServerScriptService)   │
├─────────────────────────────────────────────┤
│                                             │
│  DEFAULT_SETTINGS = {                       │
│    JumpStrength = 50  ← Change this!        │
│    Cooldown = 0.5                           │
│  }                                          │
│                                             │
│  CUSTOM_CONFIGS = {                         │
│    ["SuperJump"] = {                        │
│      JumpStrength = 100  ← Higher!          │
│    },                                       │
│    ["SpeedBoost"] = {                       │
│      JumpStrength = 35   ← Lower!           │
│    }                                        │
│  }                                          │
└─────────────────────────────────────────────┘
```

---

## 🎮 Creating Different Pad Types

### Example: 3 Different Jump Pads

```
Type 1: STANDARD
┌──────────────┐
│  Part Name:  │  "JumpPad"
│  Tag:        │  "JumpPad"
│  Result:     │  Uses DEFAULT (strength: 50)
└──────────────┘

Type 2: SUPER JUMP
┌──────────────┐
│  Part Name:  │  "SuperJump"
│  Tag:        │  "JumpPad"
│  Config:     │  Add to CUSTOM_CONFIGS
│  Result:     │  Higher jump (strength: 100)
└──────────────┘

Type 3: SPEED BOOST
┌──────────────┐
│  Part Name:  │  "SpeedBoost"
│  Tag:        │  "JumpPad"
│  Config:     │  Add to CUSTOM_CONFIGS
│  Result:     │  Small jump, more speed
└──────────────┘
```

---

## 🔄 How It Works

```
PLAYER STEPS ON PAD
        ↓
┌───────────────────┐
│  JumpPadManager   │  ← Detects touch via tag
│  (Server)         │    Validates player
└───────────────────┘    Checks cooldown
        ↓
    [RemoteEvent]    ← Sends: "Jump with strength X"
        ↓
┌───────────────────┐
│  JumpPadClient    │  ← Applies physics instantly
│  (Client)         │    Player launches!
└───────────────────┘
        ↓
    🚀 SMOOTH JUMP
```

---

## ➕ Adding More Pads (Copy-Paste Friendly)

```
STEP 1: Create a Part
• Insert → Part
• Name it: "JumpPad" (or anything)
• Position it where you want

STEP 2: Tag it "JumpPad"
• Select the Part
• Tag Editor → "+" → "JumpPad"

STEP 3: Done!
• It automatically works
• No scripting needed
```

### Want 100 pads?

```
• Create 1 pad
• Tag it
• Duplicate it 99 times (Ctrl+D)
• All automatically work!
```

---

## 🎨 Visual Example Setup

```
Workspace Layout:
├─ 🟩 JumpPad (Green, Normal)      Tag: JumpPad
│  Settings: Default (50)
│
├─ 🟧 SuperJump (Orange, Neon)     Tag: JumpPad
│  Settings: Custom (100)
│
├─ 🟦 SpeedBoost (Cyan, Smooth)    Tag: JumpPad
│  Settings: Custom (35)
│
└─ 🟩 JumpPad Copy x 10            Tag: JumpPad
   Settings: Default (50)
```

**Total Scripts:** 2 (manager + client)
**Total Pads:** 13
**Total Config Entries:** 2 (SuperJump, SpeedBoost)

---

## ✅ Checklist

Before testing, verify:

- [ ] JumpPadManager is in **ServerScriptService**
- [ ] JumpPadClient is in **StarterPlayerScripts**
- [ ] Your Parts are **tagged** with "JumpPad"
- [ ] Parts have **CanCollide = true**
- [ ] Parts are **Anchored = true**

---

## 🚀 What You See in Output

```
✅ Jump Pad Manager ready! Watching for 'JumpPad' tags.
✅ Jump Pad setup: JumpPad (Strength: 50)
✅ Jump Pad setup: SuperJump (Strength: 100)
✅ Jump Pad setup: SpeedBoost (Strength: 35)
✅ Jump Pad Client ready!
```

One "setup" message per pad = working correctly!

---

## 💡 Pro Tips

**Tip 1: Color Coding**
```
Standard pads → Green
Super jumps   → Orange/Red
Speed boosts  → Blue/Cyan
```

**Tip 2: Material = Visibility**
```
Material: Neon
Transparency: 0.3
= Glowing, obvious pads
```

**Tip 3: Duplicate = Easy Scaling**
```
Create + Tag 1 pad
→ Ctrl+D to duplicate
→ All copies keep the tag!
```

**Tip 4: Name-Based Configs**
```
Name your part → Add to CUSTOM_CONFIGS
= Automatic custom settings!
```

---

## 🎯 Summary

```
┌────────────────────────────────────┐
│  OLD WAY:                          │
│  10 pads = 10 server scripts ❌    │
│  Hard to manage                    │
└────────────────────────────────────┘

┌────────────────────────────────────┐
│  NEW WAY:                          │
│  ∞ pads = 1 manager script ✅      │
│  Just tag parts                    │
│  Auto-managed                      │
└────────────────────────────────────┘
```

---

Read **MULTI_PAD_SETUP.md** for detailed instructions!
