# Migration Guide: Single Pad → Multi Pad System

## 🔄 If You Already Have the Old Setup

If you already installed the single-pad system (with scripts in each Part), here's how to upgrade:

---

## Quick Migration (3 Steps)

### Step 1: Install New Manager

1. Open **ServerScriptService**
2. Create a new **Script**
3. Copy **`JumpPadManager.lua`** into it
4. Name it "JumpPadManager"

### Step 2: Delete Old Scripts from Parts

1. Go to Workspace
2. Find your JumpPad Part(s)
3. **Delete the Script(s) inside them**
4. Keep the Parts themselves!

### Step 3: Tag Your Parts

1. Open Tag Editor (**View → Tags**)
2. Select each jump pad Part
3. Add tag: **"JumpPad"**

**Done!** Your client script (JumpPadClient) stays the same.

---

## Detailed Comparison

### Old System:
```
Workspace
  └─ JumpPad (Part)
      └─ JumpPadServer (Script) ← Delete this

StarterPlayerScripts
  └─ JumpPadClient (LocalScript) ← Keep this!
```

### New System:
```
ServerScriptService
  └─ JumpPadManager (Script) ← Add this

Workspace
  └─ JumpPad (Part) [Tag: "JumpPad"] ← Just tag it, no script

StarterPlayerScripts
  └─ JumpPadClient (LocalScript) ← Same as before!
```

---

## Benefits of Upgrading

| Old | New |
|-----|-----|
| 10 pads = 10 scripts | 10 pads = 1 script |
| Hard to update all | Change once, affects all |
| Duplication = mistakes | No duplication |

---

## Verification

After migrating, check Output when you play:

```
✅ Jump Pad Manager ready! Watching for 'JumpPad' tags.
✅ Jump Pad setup: JumpPad (Strength: 50)
✅ Jump Pad Client ready!
```

You should see one "setup" line per pad you tagged!

---

## Don't Want to Migrate?

The old system still works fine! If you prefer:
- Keep using **JumpPadServer.lua** in each Part
- Don't install JumpPadManager
- Both approaches work, just different trade-offs

---

## Questions?

- **"Can I mix both systems?"** - No, pick one. JumpPadManager handles everything, so remove old scripts.
- **"What about my settings?"** - Copy your `JUMP_STRENGTH` values to `DEFAULT_SETTINGS` in JumpPadManager.
- **"Do I need to retag after duplicating?"** - No! Tags are copied when you duplicate Parts.
