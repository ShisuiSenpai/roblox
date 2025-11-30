# Roblox Jump Pad - Professional Client-Server System

A high-performance jump pad system using proper client-server architecture for smooth, lag-free launching.

## 🎯 Why This Design?

**Problem with naive approaches:**
- Server-side velocity changes fight with client physics ownership
- `.Touched` spam causes stuttering
- Hard velocity overrides feel unnatural

**This solution:**
- ✅ Server validates, client executes (zero perceived lag)
- ✅ Impulse-based force (natural momentum preservation)
- ✅ Clean event-driven architecture
- ✅ Proper cooldown and validation

## 📦 What's Included

| File | Purpose |
|------|---------|
| `JumpPadServer.lua` | Server script: Touch detection & validation |
| `JumpPadClient.lua` | Client script: Physics application |
| `SETUP_INSTRUCTIONS.md` | Detailed installation guide |
| `EXAMPLE_CONFIGURATIONS.md` | Pre-configured jump types |

## 🚀 Quick Start

### 1. Server Script (in JumpPad Part)

```
Workspace
  └─ JumpPad (Part)
      └─ Script ← Paste JumpPadServer.lua here
```

### 2. Client Script (in StarterPlayerScripts)

```
StarterPlayer
  └─ StarterPlayerScripts
      └─ LocalScript ← Paste JumpPadClient.lua here
```

**Done!** The system will automatically create the RemoteEvent.

## ⚙️ Configuration

### Server Side (Detection)
```lua
local JUMP_STRENGTH = 50      -- Upward boost strength
local COOLDOWN_TIME = 0.5     -- Seconds between uses
```

### Client Side (Physics)
```lua
local HORIZONTAL_PRESERVATION = 0.9  -- Keep momentum (0.0-1.0)
local IMPULSE_DURATION = 0.15        -- Force application time
```

## 🎮 Example Configurations

| Style | JUMP_STRENGTH | HORIZONTAL_PRESERVATION |
|-------|---------------|------------------------|
| Standard Jump | 50 | 0.9 |
| High Jump | 75 | 0.9 |
| Super Jump | 100 | 1.0 |
| Speed Boost Pad | 40 | 1.5 |
| Cannon Launch | 150 | 0.3 |

## 🔧 How It Works

```
Player touches pad → Server validates → RemoteEvent fired → Client applies force
```

**Why this is smooth:**
1. Client owns character physics (no server interference)
2. Velocity change is local (instant, no replication delay)
3. Impulse addition (not hard override) feels natural
4. Server still controls game logic (anti-cheat safe)

## 📈 Scalability

- ✅ Works with unlimited jump pads
- ✅ Each pad has its own settings (just duplicate the server script)
- ✅ One client script handles all pads
- ✅ Minimal network traffic (one RemoteEvent per jump)

## 🐛 Troubleshooting

**Not jumping?**
- Verify server script is in the **Part** (not Model)
- Verify client script is in **StarterPlayerScripts**
- Check Part has **CanCollide = true**

**Still feels laggy?**
- Increase JUMP_STRENGTH (try 75-100)
- Check game ping (network lag is separate issue)

**Jump too weak/strong?**
- Adjust JUMP_STRENGTH in server script

## 🎓 Technical Details

**Architecture Pattern:** Command Pattern with Client-Side Prediction
- **Server:** Authoritative game logic
- **Client:** Immediate physics response
- **Communication:** One-way RemoteEvent (server → client)

**Physics Model:** Impulse addition
- Old approach: `velocity.Y = constant` (override)
- This approach: `velocity.Y += impulse` (addition)
- Result: Natural momentum preservation

**Network Optimization:**
- Character physics are client-owned (Roblox default)
- Client changes its own physics (no replication needed)
- Server only sends small event (< 10 bytes)

---

Read `SETUP_INSTRUCTIONS.md` for detailed installation and tuning guide!
