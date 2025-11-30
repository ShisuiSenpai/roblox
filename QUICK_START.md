# Jump Pad Quick Start Guide

## 📦 Installation (2 Steps)

### Step 1: Put Server Script in the Jump Pad Part

1. Find your **JumpPad Part** in Workspace
2. Add a **Script** (not LocalScript) to it
3. Copy ALL code from `JumpPadServer.lua` into that Script

### Step 2: Put Client Script in StarterPlayerScripts

1. Go to **StarterPlayer** > **StarterPlayerScripts**
2. Add a **LocalScript** (must be LocalScript!)
3. Copy ALL code from `JumpPadClient.lua` into that LocalScript

**Done!** Play and test.

---

## ⚙️ Quick Tuning

### Make it jump higher/lower

Open the **server script** in your JumpPad Part:

```lua
local JUMP_STRENGTH = 50  -- Change this number
```

- `30-40` = Small hop
- `50-75` = Standard jump
- `100-150` = Super jump

### Make it keep/boost speed

Open the **client script** in StarterPlayerScripts:

```lua
local HORIZONTAL_PRESERVATION = 0.9  -- Change this number
```

- `0.5` = Slow down
- `0.9` = Keep speed (natural)
- `1.5` = Speed boost

---

## ✅ Verification Checklist

- [ ] Server script is in the **Part** (not Model, not StarterPlayerScripts)
- [ ] Server script is a regular **Script** (not LocalScript)
- [ ] Client script is in **StarterPlayerScripts**
- [ ] Client script is a **LocalScript** (not regular Script)
- [ ] The Part has **CanCollide = true**
- [ ] The Part is **Anchored = true**

---

## 🎮 Testing

1. **Play** the game
2. **Walk onto** the jump pad
3. You should see in Output:
   ```
   ✅ Jump Pad Server ready!
   ✅ Jump Pad Client ready!
   ```
4. You should **launch into the air** smoothly!

---

## 🚨 Troubleshooting

**"Jump Pad Server ready!" but no client message?**
- Make sure client script is a **LocalScript** in **StarterPlayerScripts**

**No jump at all?**
- Check Part has **CanCollide = true**
- Verify both scripts are running (check Output)

**Jump is weak?**
- Increase `JUMP_STRENGTH` (try 75 or 100)

**Still feels laggy?**
- You might have old scripts interfering
- Delete any old jump pad scripts
- Make sure you're using the NEW code (client-server version)

---

## 📚 More Info

- **Full setup guide:** Read `SETUP_INSTRUCTIONS.md`
- **Different jump types:** Read `EXAMPLE_CONFIGURATIONS.md`
- **How it works:** Read `ARCHITECTURE.md`

---

## 💾 File Reference

| File | Goes Where | Type |
|------|------------|------|
| `JumpPadServer.lua` | Inside JumpPad Part | Script |
| `JumpPadClient.lua` | StarterPlayerScripts | LocalScript |

That's it! 🚀
