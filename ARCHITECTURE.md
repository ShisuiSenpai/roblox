# Jump Pad System Architecture

## 🏗️ System Design Overview

This document explains the technical architecture and why each design decision was made.

---

## The Problem Space

### What Makes Jump Pads Hard?

1. **Network Ownership Conflict**
   - Player characters are **client-owned** in Roblox
   - Server changes to client-owned physics → reconciliation lag
   - Result: stuttering, "buffering" feel

2. **Noisy Input**
   - `.Touched` fires multiple times (one per body part)
   - Can trigger 5-10 times in <0.1 seconds
   - Without proper debouncing → spam triggers

3. **Physics vs Networking**
   - Players expect instant response (<50ms)
   - Server round-trip can be 50-200ms
   - Solution must feel instant despite network

---

## Architecture Pattern: Client-Authoritative with Server Validation

```
┌─────────────────────────────────────────────────────────────┐
│  PLAYER TOUCHES PAD                                         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  SERVER (JumpPadServer.lua)                                 │
│                                                             │
│  1. .Touched event fires                                    │
│  2. Validate: Is it a player? Health > 0?                   │
│  3. Check: Is player on cooldown?                           │
│  4. Set cooldown for player                                 │
│  5. Fire RemoteEvent → Client with jump strength            │
│  6. Visual feedback (flash pad color)                       │
│                                                             │
│  Role: Gate keeper, validator, authority                    │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ RemoteEvent:FireClient(player, strength)
                            │ (Network cost: ~8 bytes)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  CLIENT (JumpPadClient.lua)                                 │
│                                                             │
│  1. Receive jump command from server                        │
│  2. Get current velocity from HumanoidRootPart              │
│  3. Calculate: newVelocity = oldVelocity + impulse          │
│  4. Apply locally to character (instant!)                   │
│  5. Set Humanoid state to Jumping (animation)               │
│                                                             │
│  Role: Executor, physics handler, instant responder         │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PLAYER LAUNCHES SMOOTHLY                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Design Decisions

### 1. Why Split Server/Client?

| Approach | Who Changes Physics | Perceived Lag | Smoothness |
|----------|-------------------|---------------|------------|
| **Server-only** | Server | High (50-200ms) | ❌ Stuttery |
| **Client-only** | Client | None (0ms) | ⚠️ Exploitable |
| **This system** | Client (validated by server) | None (0ms) | ✅ Smooth + Safe |

**Decision:** Server validates, client executes
- Server prevents cheating (cooldowns, valid triggers)
- Client applies physics for instant feel
- Best of both worlds

---

### 2. Why RemoteEvent Instead of Direct Velocity Change?

```lua
-- ❌ Bad: Server changes client-owned physics
-- (In server script)
humanoidRootPart.AssemblyLinearVelocity = newVelocity
-- Problem: Server → Client replication lag, reconciliation conflicts

-- ✅ Good: Server commands, client executes
-- (In server script)
jumpPadEvent:FireClient(player, jumpStrength)
-- (In client script)
humanoidRootPart.AssemblyLinearVelocity = newVelocity
-- Benefit: Client changes its own physics (instant, no conflict)
```

---

### 3. Why Impulse Addition vs Velocity Override?

```lua
-- ❌ Override approach (feels unnatural)
local newVelocity = Vector3.new(
    oldVelocity.X,
    CONSTANT,        -- Hard-set to constant value
    oldVelocity.Z
)

-- ✅ Impulse approach (feels natural)
local newVelocity = Vector3.new(
    oldVelocity.X * preservation,
    oldVelocity.Y + JUMP_STRENGTH,  -- ADD impulse
    oldVelocity.Z * preservation
)
```

**Why impulse is better:**
- Preserves momentum (feels physically consistent)
- Allows horizontal preservation tuning
- Players feel in control (not "yanked" by pad)
- Natural acceleration curve

---

### 4. Why Per-Player Cooldowns?

```lua
-- ❌ Global cooldown
local lastTrigger = 0
if tick() - lastTrigger < COOLDOWN then return end
-- Problem: One player blocks all players

-- ✅ Per-player cooldown
local playerCooldowns = {}
if playerCooldowns[userId] and (tick() - playerCooldowns[userId] < COOLDOWN) then
    return
end
-- Benefit: Each player has independent cooldown
```

---

## Data Flow Diagram

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   BasePart   │────>│    Server    │────>│    Client    │
│  .Touched    │     │  Validation  │     │   Physics    │
└──────────────┘     └──────────────┘     └──────────────┘
       │                     │                     │
       │                     │                     │
   Multiple              One event             Instant
   fires/sec            per player            application
       │                     │                     │
       ▼                     ▼                     ▼
   Debounced            Cooldown              Smooth launch
   in server            enforced              no lag
```

---

## Performance Characteristics

### Network Traffic

**Per jump:**
- RemoteEvent: ~8 bytes (player reference + number)
- No physics replication needed (client-owned)
- Total: ~8 bytes/jump

**Comparison:**
- Server velocity change: ~24 bytes + replication overhead
- This system: ~8 bytes

**Savings:** ~66% less network usage

### CPU Usage

**Server:**
- Touch validation: O(1) per touch
- Cooldown check: O(1) hashtable lookup
- RemoteEvent fire: O(1)

**Client:**
- Vector math: 3 operations
- Property assignment: O(1)

**Total:** Extremely lightweight

### Memory Usage

**Server:**
- Per player: 12 bytes (UserId + timestamp)
- 100 players: ~1.2 KB
- Auto-cleanup on player leave

**Client:**
- No per-pad memory (all stateless)

---

## Scalability

### Multiple Jump Pads

The system scales **linearly** with pad count:

```
1 pad  = 1 server script
5 pads = 5 server scripts (independent)
∞ pads = ∞ server scripts

Client script = 1 (handles all pads)
```

Each pad:
- Independent settings
- Independent cooldowns
- No cross-talk or interference

### Adding Features

Easy extension points:

1. **Different jump types:** Modify JUMP_STRENGTH per pad
2. **Directional pads:** Add launch direction vector to RemoteEvent
3. **Particle effects:** Add in server script (visual feedback)
4. **Sound effects:** Add in server script (audio feedback)
5. **Combo multipliers:** Add counter in client script
6. **Air control:** Modify HORIZONTAL_PRESERVATION dynamically

---

## Anti-Cheat Considerations

### What's Protected

✅ **Server-side cooldowns** - Client can't spam RemoteEvent  
✅ **Server validation** - Only valid players get events  
✅ **Bounded jump strength** - Server sends fixed values  

### What's Not Protected (and why it's ok)

⚠️ **Client applies physics** - Could be modified by exploiter

**However:**
- Jump pad advantage is minimal (not game-breaking)
- Server could add sanity checks if needed
- Trade-off is worth it for smooth gameplay

**If you need strict anti-cheat:**
```lua
-- In server, after RemoteEvent fires:
task.wait(0.5)
-- Verify player's vertical velocity is reasonable
if humanoidRootPart.AssemblyLinearVelocity.Y > JUMP_STRENGTH * 1.5 then
    -- Flag suspicious behavior
end
```

---

## Comparison to Other Approaches

### Approach 1: Pure Server

```lua
-- Everything on server
part.Touched:Connect(function(hit)
    local character = hit.Parent
    local hrp = character.HumanoidRootPart
    hrp.Velocity = Vector3.new(0, 100, 0)  -- Server changes physics
end)
```

**Problems:**
- ❌ Stuttering (server-client reconciliation)
- ❌ Network lag visible
- ❌ Unnatural feel (hard override)

---

### Approach 2: Pure Client

```lua
-- Client detects and applies
local part = workspace.JumpPad
part.Touched:Connect(function(hit)
    if hit.Parent == player.Character then
        -- Apply jump
    end
end)
```

**Problems:**
- ❌ No server validation (easy to exploit)
- ❌ No centralized cooldown
- ❌ Client can't detect server Parts reliably

---

### Approach 3: This System (Hybrid)

```lua
-- Server validates, client executes
-- Best: Smooth + secure
```

**Benefits:**
- ✅ Zero perceived lag
- ✅ Server-enforced rules
- ✅ Natural physics
- ✅ Scalable and maintainable

---

## Future Enhancements

Possible additions (already architectured for):

1. **Directional Pads**
   - Add direction parameter to RemoteEvent
   - Client calculates launch vector

2. **Variable Strength**
   - Base strength on player speed
   - More speed = higher launch

3. **Charge-Up Pads**
   - Hold on pad to charge
   - Release for bigger jump

4. **Combo System**
   - Count consecutive pad uses
   - Increase strength with combo

5. **Team-Specific Pads**
   - Server checks player.Team
   - Only trigger for specific teams

All possible without architecture changes!

---

## Summary

**Core Principle:** Let each system do what it's best at.

- **Server:** Validation, cooldowns, game rules (authority)
- **Client:** Physics, responsiveness, instant feedback (execution)
- **Network:** Minimal communication, efficient protocol

**Result:** Smooth, secure, scalable jump pad system that feels natural and performs well at any scale.
