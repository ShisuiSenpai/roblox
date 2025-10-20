# 🔒 Seat Lock - Quick Guide

## What Changed

**Players can NO LONGER exit the chair!**

Once you sit:
- ❌ Can't jump out
- ❌ Can't walk away  
- ❌ Can't escape
- ✅ Must finish or die

---

## How It Works

### Lock System
```
Sit → Jump disabled → Forced to stay → Play or die!
```

### When You're Free
- 💀 Die from timeout
- ✅ Game/UI ends
- 🔄 Character respawns

---

## What You Need to Do

### Update BOTH Scripts

**1. TypingTestClient.lua** (Client)
- Replace with new version
- Has seat lock code

**2. ChairController.lua** (Server)  
- Replace with new version
- Has server lock code

⚠️ **BOTH files updated!** Replace both!

---

## Testing

Sit in chair and try:
- [ ] Jump → Should fail ✅
- [ ] Walk away → Forced back ✅
- [ ] Play until timeout → Dies, unlocked ✅
- [ ] Complete round → Still locked ✅

---

## Technical Overview

### Client Side:
- Disables jump (JumpPower = 0)
- Monitors seat every frame
- Forces player back if they leave
- Unlocks on death/end

### Server Side:
- Tracks lock state
- Ignores leave attempts when locked
- Unlocks on timeout/death
- Prevents exploits

### Double Protection:
✅ Client forces reseat  
✅ Server blocks leave  
✅ No escape possible!  

---

## Files Updated

- **TypingTestClient.lua** - ⚠️ Replace yours!
- **ChairController.lua** - ⚠️ Replace yours!
- **SEAT_LOCK_UPDATE.md** - Full documentation
- **SEAT_LOCK_QUICK_GUIDE.md** - This file

---

**Now players are committed! No escape! 🔒💪**
