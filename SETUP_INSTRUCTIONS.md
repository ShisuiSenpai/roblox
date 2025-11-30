# Jump Pad Setup - Client-Server Architecture

## Why This Approach?

Your previous setup was **server-driven**, which caused:
- ❌ Stuttering/buffering (server changes client-owned physics)
- ❌ Network lag (server → client replication delay)
- ❌ Unnatural feel (hard velocity override instead of impulse)

This new setup is **client-driven**:
- ✅ Server detects and validates
- ✅ Client applies physics instantly (no lag)
- ✅ Impulse-based (adds force, doesn't replace it)

---

## Installation (2 Scripts)

### Step 1: Server Script (Detection & Validation)

1. In **Workspace**, find or create your **JumpPad Part**
2. Add a **Script** (regular Script, NOT LocalScript) inside the Part
3. Copy the contents of **`JumpPadServer.lua`** into that Script
4. Name it something like "JumpPadServer"

```
Workspace
  └─ JumpPad (Part)
      └─ JumpPadServer (Script) ← Server script here
```

### Step 2: Client Script (Physics Application)

1. In **StarterPlayer** > **StarterPlayerScripts**
2. Add a **LocalScript** (must be LocalScript!)
3. Copy the contents of **`JumpPadClient.lua`** into that LocalScript
4. Name it something like "JumpPadClient"

```
StarterPlayer
  └─ StarterPlayerScripts
      └─ JumpPadClient (LocalScript) ← Client script here
```

**Important:** The client script goes in **StarterPlayerScripts**, NOT in the JumpPad Part!

---

## How It Works

### The Flow:

```
1. Player touches JumpPad Part
   ↓
2. SERVER detects touch
   ↓
3. SERVER validates (Is it a player? Cooldown ok?)
   ↓
4. SERVER sends RemoteEvent to CLIENT: "Jump with strength X"
   ↓
5. CLIENT applies velocity change LOCALLY (instant, smooth)
   ↓
6. Player launches smoothly!
```

### Why This Is Better:

| Old Approach | New Approach |
|--------------|--------------|
| Server changes physics | Client changes its own physics |
| Network delay visible | Zero perceived delay |
| Replicated state conflict | Local state, no conflict |
| Hard velocity set | Impulse addition |

---

## Configuration

### Server Script (JumpPadServer.lua):

```lua
local JUMP_STRENGTH = 50         -- How strong the upward boost is
local COOLDOWN_TIME = 0.5        -- Seconds between uses
local SHOW_VISUAL = true         -- Flash effect when activated
```

### Client Script (JumpPadClient.lua):

```lua
local HORIZONTAL_PRESERVATION = 0.9  -- Keep horizontal momentum (0.0 - 1.0)
local IMPULSE_DURATION = 0.15        -- How long force applies
```

---

## Tuning Guide

### Want Higher Jumps?
Increase `JUMP_STRENGTH` in the **server** script:
- `50` = Standard jump
- `75` = High jump
- `100` = Super jump
- `150` = Launch pad

### Want More Speed Boost?
Increase `HORIZONTAL_PRESERVATION` in the **client** script:
- `0.5` = Lose half your speed (slow down)
- `0.9` = Keep most speed (natural feel)
- `1.2` = Speed boost (accelerate forward)
- `2.0` = Major speed boost

### Want Faster Re-use?
Decrease `COOLDOWN_TIME` in the **server** script:
- `0.3` = Fast-paced gameplay
- `0.5` = Standard (recommended)
- `1.0` = Slow, deliberate use

---

## Multiple Jump Pads?

The system automatically works with multiple pads!

Just copy the **JumpPadServer** script into each jump pad Part.

The **client script** stays as ONE copy in StarterPlayerScripts and handles ALL jump pads.

---

## Troubleshooting

### "Jump Pad Server ready!" but no client message?
- Check that JumpPadClient is in **StarterPlayerScripts** (not ServerScriptService)
- Make sure it's a **LocalScript** (not regular Script)

### Still feels laggy?
- Make sure JUMP_STRENGTH is high enough (try 75-100)
- Check your game's ping (high ping = delay no matter what)
- Ensure the Part's **CanCollide** is **true**

### Jump is too weak?
- Increase `JUMP_STRENGTH` in server script
- Try values between 75-150

### Jump is too strong?
- Decrease `JUMP_STRENGTH` in server script
- Try values between 30-50

### Want different strengths on different pads?
Modify each pad's server script individually - change `JUMP_STRENGTH` to different values.

---

## Technical Notes

**Network Ownership:**
- Characters are client-owned in Roblox
- Server changes to client-owned parts cause reconciliation
- Client changes to its own parts = instant, smooth

**RemoteEvent:**
- Created automatically in ReplicatedStorage
- Reused by all jump pads
- One-way communication: Server → Client

**Impulse vs Override:**
- Old: `velocity.Y = 50` (replace)
- New: `velocity.Y = velocity.Y + 50` (add impulse)
- Result: Natural momentum preservation

---

## What You Get

✅ **Zero perceived lag** - client applies its own physics  
✅ **Smooth, natural feel** - impulse-based force  
✅ **Proper validation** - server controls game logic  
✅ **Scalable** - works with unlimited jump pads  
✅ **Configurable** - easy tuning on server and client  

Test it and adjust `JUMP_STRENGTH` until it feels perfect for your game!
