# 🔒 Seat Lock System - No Escape!

## What's New

**Players are now LOCKED in the chair!**

You **cannot** leave the seat until:
- ❌ You die (timeout)
- ✅ The game ends/UI closes
- 💀 Your character dies

**No more:**
- ❌ Jumping out
- ❌ Walking away
- ❌ Using reset character
- ❌ Any escape tricks

---

## 🎯 How It Works

### When You Sit Down
```
Sit in chair
    ↓
Jump disabled (JumpPower = 0)
    ↓
Seat locked (server side)
    ↓
Force-reseat system active
    ↓
You're trapped! 🔒
```

### Continuous Monitoring
```
Every frame (Heartbeat):
  ├─ Check if player left seat
  ├─ If left → Force back into seat
  ├─ Disable jump (continuously)
  └─ Repeat until unlocked
```

### When You Can Leave
```
Game ends OR Player dies
    ↓
Unlock request sent to server
    ↓
Server unlocks seat
    ↓
Client stops forcing reseat
    ↓
Jump re-enabled
    ↓
You're free! ✅
```

---

## 🔧 Technical Details

### Client-Side Lock (TypingTestClient)

**New Variables:**
```lua
local currentSeat = nil
local seatLockConnection = nil
local isSeated = false
local canLeaveSeat = false
```

**Lock Function:**
```lua
local function lockInSeat(seat)
	-- Disable jumping
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	
	-- Monitor and force reseat
	RunService.Heartbeat:Connect(function()
		if not seat.Occupant then
			seat:Sit(humanoid)  -- Force back
		end
		-- Keep jump disabled
	end)
end
```

**Unlock Function:**
```lua
local function unlockSeat()
	-- Notify server
	remoteEvent:FireServer("UnlockSeat")
	
	-- Re-enable jump
	humanoid.JumpPower = 50
	humanoid.JumpHeight = 7.2
	
	-- Stop monitoring
	disconnect()
end
```

### Server-Side Lock (ChairController)

**New Variable:**
```lua
local seatLocked = false
```

**Sitting:**
```lua
seatLocked = true  -- Lock on sit
remoteEvent:FireClient(player, "ShowUI", seat)
```

**Leaving Prevention:**
```lua
-- Only allow leaving if unlocked
if currentOccupant and not seatLocked then
	-- Process leave
end
```

**Unlock Events:**
```lua
-- Timeout
seatLocked = false
unseatPlayer()

-- Client request (death/UI close)
if action == "UnlockSeat" then
	seatLocked = false
end
```

---

## 🎮 Player Experience

### Before Lock System
```
Sit → Type → Don't like it → Jump out → Walk away ❌
```

### After Lock System
```
Sit → LOCKED 🔒 → Must complete or die → No escape!
```

**Forces commitment!**

---

## 💡 Why This Change?

### Problems Before:
- ❌ Players could cheat by leaving mid-game
- ❌ Could avoid death by jumping out
- ❌ No real stakes or commitment
- ❌ Could troll by sitting and leaving

### Benefits After:
- ✅ Forces players to commit
- ✅ Can't escape death
- ✅ Higher stakes = more engaging
- ✅ Prevents seat trolling
- ✅ More intense gameplay

---

## 🔓 When Unlock Happens

### Automatic Unlock:
1. **Timeout (lose)** - Server unlocks after death
2. **Character death** - Client unlocks before cleanup
3. **UI closes** - Client unlocks when hiding UI

### Unlock Flow:
```
Event triggers (death/close)
    ↓
unlockSeat() called (client)
    ↓
"UnlockSeat" sent to server
    ↓
Server: seatLocked = false
    ↓
Client: Stop monitoring
    ↓
Client: Re-enable jump
    ↓
Player can move freely
```

---

## 🛡️ Anti-Exploit Features

### Client-Side Protection:
- **Heartbeat monitoring** - Checks every frame
- **Force reseat** - Immediately reseats if escaped
- **Jump disabled** - Set to 0 continuously
- **State tracking** - Knows when lock is active

### Server-Side Protection:
- **Lock flag** - Server tracks lock state
- **Ignore leave events** - Won't process if locked
- **Unlock verification** - Only unlock on valid events
- **Occupant tracking** - Knows who should be seated

### Combined:
- Even if client tries to bypass, server won't allow leave
- Even if server glitches, client forces reseat
- Double protection = no escape!

---

## 🎯 Updated Files

### TypingTestClient.lua
**Added:**
- Seat lock variables (lines ~107-110)
- `lockInSeat()` function
- `unlockSeat()` function
- Lock on showUI()
- Unlock on hideUI()
- Unlock on death
- "UnlockSeat" server message

### ChairController.lua
**Added:**
- `seatLocked` variable
- Lock on sit
- Unlock on timeout
- Unlock event handler
- Leave prevention when locked
- Seat reference sent to client

---

## 🧪 Testing

### Test Checklist:
- [ ] Sit in chair → Locked ✅
- [ ] Try jumping → Can't jump ✅
- [ ] Try walking → Forced back ✅
- [ ] Try reset character → Respawns, seat unlocked ✅
- [ ] Timeout → Dies, seat unlocked ✅
- [ ] Complete round → Stays locked ✅
- [ ] Multiple rounds → Still locked ✅
- [ ] Die from timeout → Unlocked ✅

### Expected Behavior:
✅ **Can't jump** - JumpPower = 0  
✅ **Can't walk away** - Forced back instantly  
✅ **Can't escape** - Until death/end  
✅ **Jump works after** - Re-enabled on unlock  

---

## 🐛 Troubleshooting

### Player stuck in seat forever?
- Check unlock is called on death
- Check "UnlockSeat" event sent
- Check server receives unlock event

### Player can still leave?
- Check seatLockConnection is active
- Check Heartbeat is running
- Check server lock flag is true

### Can't jump after leaving?
- Check unlockSeat() re-enables jump
- Verify JumpPower set to 50
- Verify JumpHeight set to 7.2

---

## ⚙️ Customization

### Adjust Jump Power After Unlock

In `unlockSeat()` function (~line 370):
```lua
humanoid.JumpPower = 50      -- Default
humanoid.JumpHeight = 7.2    -- Default
```

Change to custom values:
```lua
humanoid.JumpPower = 100     -- Super jump
humanoid.JumpHeight = 15     -- High jump
```

### Disable Lock (If Needed)

Comment out in `showUI()`:
```lua
-- if seat then
--     lockInSeat(seat)
-- end
```

---

## 📊 Performance

### Impact:
- **Client:** 1 Heartbeat connection while seated
- **Server:** 1 boolean flag per seated player
- **Network:** 1 extra message on unlock
- **Overall:** Negligible performance impact

### Optimizations:
✅ Single Heartbeat connection (not per-frame create)  
✅ Simple boolean checks (very fast)  
✅ Disconnects when unlocked (no waste)  
✅ Server flag prevents exploit spam  

---

## 🎯 Summary

**Players are now locked in the chair!**

- 🔒 **Can't jump** out
- 🔒 **Can't walk** away  
- 🔒 **Can't escape** at all
- ✅ **Must complete** or **die**
- ✅ **Higher stakes** = more fun!

**Both client AND server enforce the lock = no exploits!**

---

**No more quitters! Face the challenge! 💪🔒**
