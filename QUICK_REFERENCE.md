# ⚡ Quick Reference Guide

## 📍 Where Everything Goes

### Client Script
```
StarterPlayer
  └─ StarterPlayerScripts
      └─ TypingTestClient (LocalScript) ← Paste TypingTestClient.lua here
```

### Server Script
```
Workspace
  └─ Chair (Model)
      ├─ Seat (Seat object)
      ├─ Part1 (Part)
      │   └─ ProximityPrompt
      └─ ChairController (Script) ← Paste ChairController.lua here
```

---

## 🔧 Configuration Values

| Setting | Location | Default | Description |
|---------|----------|---------|-------------|
| `INITIAL_TIME` | TypingTestClient line 30 | 15 | Starting time in seconds |
| `MIN_TIME` | TypingTestClient line 31 | 5 | Minimum time (hardest difficulty) |
| `TIME_REDUCTION` | TypingTestClient line 32 | 1 | Seconds removed each round |
| `COUNTDOWN_TIME` | TypingTestClient line 33 | 3 | Countdown before round starts |
| `ANIMATION_ID` | TypingTestClient line 24 | (Your ID) | Your animation asset ID |

---

## 🎮 Game Flow

```
Player walks to chair
    ↓
ProximityPrompt appears
    ↓
Player presses E (or prompt key)
    ↓
Player sits in chair
    ↓
UI appears at top of screen
    ↓
3-second countdown (3... 2... 1... GO!)
    ↓
Input unlocks, player can type
    ↓
Player starts typing
    ↓
Timer bar starts draining
    ↓
┌─────────────────┐
│ Success?        │
├─────────────────┤
│ ✅ YES          │ → Input locks → 2s pause → Countdown → Next round
│ ❌ NO (timeout) │ → Input locks → Kicked from chair → UI hides
└─────────────────┘
```

---

## 🎨 UI Colors

| Element | Color | RGB |
|---------|-------|-----|
| Background | Semi-transparent black | (0, 0, 0) 70% transparent |
| Glow | Light blue | (100, 200, 255) |
| Timer (good) | Blue | (100, 220, 255) |
| Timer (warning) | Orange | (255, 200, 100) |
| Timer (danger) | Red | (255, 100, 100) |
| WPM text | Cyan | (100, 220, 255) |
| Success text | Green | (100, 255, 150) |
| Failure text | Red | (255, 100, 100) |
| Correct input | Light green | (100, 255, 150) |
| Wrong input | Light red | (255, 100, 100) |

---

## 🐛 Common Issues & Fixes

| Problem | Solution |
|---------|----------|
| UI doesn't show | Check script is in StarterPlayerScripts |
| Can't sit | Make sure object is a Seat, not Part |
| No proximity prompt | Add ProximityPrompt to Part1 |
| Animation doesn't play | Update ANIMATION_ID with your ID |
| Timer doesn't work | Test in real game, not Play Solo |
| Not kicked on timeout | Check ChairController is in Chair model |

---

## 📏 Timer Bar Behavior

| Time Remaining | Bar Color | Bar Width |
|----------------|-----------|-----------|
| > 50% | Blue 🟦 | Wide |
| 25-50% | Orange 🟧 | Medium |
| < 25% | Red 🟥 | Narrow |
| 0% | - | Kicked! |

---

## 💯 Difficulty Chart

Starting time: **15 seconds**  
Time reduction: **1 second per round**  
Minimum time: **5 seconds**

```
Round 1:  ████████████████ 15s (Easy)
Round 2:  ███████████████░ 14s
Round 3:  ██████████████░░ 13s
Round 4:  █████████████░░░ 12s
Round 5:  ████████████░░░░ 11s (Medium)
Round 10: █████░░░░░░░░░░░ 6s (Hard)
Round 11+: ████░░░░░░░░░░░ 5s (MAX)
```

---

## 🎯 Key Functions

### Client (TypingTestClient)
- `createUI()` - Builds all UI elements
- `startNewTest()` - Begins a new round
- `onTextChanged()` - Handles typing validation
- `updateTimer()` - Drains timer bar
- `onTimeout()` - Handles failure
- `showUI()` / `hideUI()` - Animations

### Server (ChairController)
- `sitPlayer()` - Seats player, shows UI
- `unseatPlayer()` - Kicks player from chair
- `onSeatLeft()` - Cleans up when player leaves
- `onServerEvent()` - Handles timeout kicks

---

## 📝 Sentences Included

1. "The quick brown fox jumps over the lazy dog"
2. "Practice makes perfect when typing fast"
3. "Speed and accuracy are both important skills"
4. "Challenge yourself to type faster every day"
5. "Master the keyboard with dedication and practice"
6. "Typing is a valuable skill in the modern world"
7. "Focus on accuracy before increasing your speed"
8. "Every keystroke brings you closer to mastery"
9. "Consistent practice leads to incredible results"
10. "Push your limits and break your records"

---

## ✨ Optimizations Included

✅ **Single RunService connection** for timer updates  
✅ **Efficient UI updates** using TweenService  
✅ **Proper cleanup** on timeout/leave  
✅ **Event disconnection** to prevent memory leaks  
✅ **Minimal UI redraws** for better performance  
✅ **Client-side validation** with server authority  
✅ **Smooth animations** without lag  

---

**Need help? Check SETUP_INSTRUCTIONS.md for detailed guide!**
