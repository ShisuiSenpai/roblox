# 🎁 Crate System - Quick Start

## ⚡ Super Fast Setup (2 minutes)

### 1. Create Server Script
**ServerScriptService** → Insert **Script** → Name: `CrateSystemServer`
→ Paste code from `CrateSystemServer.lua`

### 2. Create Client Script  
**StarterPlayerScripts** → Insert **LocalScript** → Name: `CrateSystemClient`
→ Paste code from `CrateSystemClient.lua`

### 3. Test!
- Press Play
- Walk to chest
- Press E
- Watch the magic! ✨

---

## 🎬 How The Animation Looks

```
┌─────────────────────────────────────────┐
│         OPENING CRATE                   │  ← Title
│                                         │
│  ┌────┐ ┌────┐ ┌────┐│┌────┐ ┌────┐  │
│  │Ice │ │Purp│ │Norm││Steel│ │Ice │  │  ← Swords scroll →
│  │Swrd│ │Swrd│ │Swrd││Swrd│ │Swrd│  │     horizontally
│  └────┘ └────┘ └────┘│└────┘ └────┘  │
│                       │                 │
│         Selector ─────┘                 │  ← Stops here
│                                         │
└─────────────────────────────────────────┘

Background: Dark semi-transparent overlay
```

**Animation:**
1. Swords scroll from right to left
2. Starts fast, slows down
3. Lands on the chosen sword in the center
4. Shows "YOU GOT: [SWORD NAME]"

---

## 🎨 What It Looks Like

**Colors:**
- Background: Very dark (almost black) with transparency
- Sword cards: Dark gray/blue, slightly transparent
- Text: Light gray/white
- Selector line: Blue (center indicator)
- Result text: Blue accent color

**Style:**
- Minimal
- Modern
- Clean
- Easy on the eyes
- No emojis
- No harsh colors

---

## ✅ What Happens

1. **Player walks to chest** → Sees proximity prompt
2. **Presses E** → Animation starts
3. **Screen darkens** → Player can't move
4. **Swords spin** → Smooth CS:GO style animation
5. **Lands on winner** → Shows which sword they got
6. **Sword equips** → Automatically in hand
7. **UI closes** → Player can move again

---

## 🔥 Features

- ✅ Works with all 4 swords (NormalSword, IceSword, PurpleSword, SteelSword)
- ✅ Random selection (each sword has equal chance)
- ✅ Smooth animation (4 second spin)
- ✅ Player frozen during opening (can't move/jump)
- ✅ Auto-equip winner
- ✅ Text-based (no images needed)
- ✅ Dark theme
- ✅ Modern UI

---

## 🎯 Current Swords

Based on your config:
1. **Normal Sword** (Press 1)
2. **Ice Sword** (Press 2)
3. **Purple Sword** (Press 3)
4. **Steel Sword** (Press 4)

All 4 will appear in the crate opening animation!

---

## 📦 Hierarchy Checklist

- [ ] `CrateSystemServer` Script in ServerScriptService
- [ ] `CrateSystemClient` LocalScript in StarterPlayerScripts
- [ ] `Chest` with `ProximityPrompt` in Workspace
- [ ] All 4 sword tools in ReplicatedStorage
- [ ] SwordConfig module in ReplicatedStorage

---

That's it! Simple and clean! 🚀
