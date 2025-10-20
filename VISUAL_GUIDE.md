# 👀 Visual Guide - UI Layout & Animations

## 🎨 Complete UI Layout

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ┌─────────────────────────────────────────────────────┐   ║
║   │ ╭─────────────────────────────────────────────────╮ │   ║ ← Main Frame
║   │ │ The quick brown fox jumps...    ┌─────────┐   │ │   ║
║   │ │                                  │  45     │   │ │   ║ ← Content Frame
║   │ │ [Type here...]                   │  WPM    │   │ │   ║   (semi-transparent)
║   │ │                                  │ Round 3 │   │ │   ║
║   │ ╰─────────────────────────────────────────────────╯ │   ║
║   │ ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │   ║ ← Timer Bar
║   │                                                     │   ║   (blue, fading)
║   │                  2... 1... type!                    │   ║ ← Countdown
║   └─────────────────────────────────────────────────────┘   ║   (below UI)
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 📏 Dimensions

```
Main Frame: 700px × 200px
├─ Content Frame: 700px × 90px
│  ├─ Sentence Label: 580px × 35px (top)
│  ├─ Input Box: 580px × 35px (bottom)
│  └─ Stats/Round: 100px × 90px (right side)
│
├─ Timer Background: 700px × 8px
│  └─ Timer Bar: (width varies) × 8px
│
├─ Countdown Label: 700px × 60px (below timer)
└─ Result Label: 700px × 30px (below countdown)
```

---

## 🎬 Animation Flow

### 1. Sitting Down
```
     Frame Position         Content Opacity       Countdown
t=0s  ┃ (off-screen top)     ┃ 0%                ┃ Hidden
      ┃ ↓ slide down         ┃ ↓ fade in         ┃
      ┃ (bounces)            ┃                    ┃
t=0.6s┃ Top of screen        ┃ 70% opaque        ┃ Visible
      ┃                      ┃                    ┃ ↓ "3"
t=1.0s┃ Stable               ┃ Stable            ┃ ↓ "2"
t=2.0s┃                      ┃                    ┃ ↓ "1"
t=3.0s┃                      ┃                    ┃ ↓ "type!"
t=3.5s┃                      ┃                    ┃ Fade out
```

### 2. Countdown Animation (Each Number)
```
     Text         Size        Opacity
     "3"          24px        0%
      ↓           ↓           ↓
   (0.2s fade in + scale)
      ↓           ↓           ↓
     "3"          36px        100%
      |           |           |
   (hold 0.4s)
      ↓           ↓           ↓
   (0.3s fade out)
      ↓           ↓           ↓
     "3"          28px        0%
```

### 3. "type!" Message
```
     Text         Size        Opacity
     "type!"      20px        0%
      ↓           ↓           ↓
   (0.4s bounce in)
      ↓           ↓           ↓
     "type!"      40px        100%
      |           |           |
   (hold 0.3s)
      ↓           ↓           ↓
   (0.4s fade out)
      ↓           ↓           ↓
     "type!"      32px        0%
```

### 4. Typing Starts
```
     Glow         Input       Timer
     Normal       White       Full (100%)
      ↓           ↓           ↓
   (0.3s pulse)  (0.2s)      (drains)
      ↓           ↓           ↓
     Bright       Highlight   Decreasing
      ↓           ↓           ↓
   (typing...)   Green/Red   + Transparent
```

### 5. Round Complete
```
     Glow         Result      Wait
     Bright       Hidden      -
      ↓           ↓           ↓
   (0.4s fade)   (0.3s in)   2 seconds
      ↓           ↓           ↓
     Normal       "✓ 45 WPM"  -
                              ↓
                           New countdown
```

---

## 🎨 Color Scheme

### Main UI
```css
Background:      rgb(0, 0, 0) @ 70% transparent
Glow:            rgb(100, 200, 255) @ 60% transparent
Sentence:        rgb(230, 230, 230)
Input Placeholder: rgb(180, 180, 180)
```

### States
```css
/* Timer Bar */
Always Blue:     rgb(100, 220, 255)
Full:            0% transparent
Empty:           70% transparent

/* Input Text */
Correct:         rgb(100, 255, 150) ← Green
Wrong:           rgb(255, 100, 100) ← Red

/* WPM Display */
Always:          rgb(100, 220, 255) ← Cyan

/* Countdown */
Numbers:         rgb(100, 220, 255) ← Blue
"type!":         rgb(100, 255, 150) ← Green

/* Results */
Success:         rgb(100, 255, 150) ← Green
Failure:         rgb(255, 100, 100) ← Red
```

---

## 💫 Interactive States

### Glow States
```
[Idle State]
Thickness: 1px
Transparency: 60%
Color: Blue

       ↓ (typing starts)

[Active State]
Thickness: 2px
Transparency: 20%
Color: Blue

       ↓ (round ends)

[Idle State]
(smoothly returns)
```

### Input Box States
```
[Waiting]
Background: 90% transparent
Text: White
Editable: No

       ↓ (countdown ends)

[Focused]
Background: 85% transparent ← Slight highlight
Text: White
Editable: Yes

       ↓ (typing)

[Typing - Correct]
Text: Green
(smooth color transition)

[Typing - Wrong]
Text: Red
(smooth color transition)

       ↓ (round ends)

[Locked]
Background: 90% transparent
Editable: No
```

---

## 📊 Timer Bar Visual States

### Full Time (100%)
```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
Solid blue, 0% transparent
```

### Half Time (50%)
```
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░
Semi-transparent blue, ~35% transparent
```

### Low Time (25%)
```
▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
Very transparent blue, ~52% transparent
```

### Almost Out (10%)
```
▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
Nearly invisible blue, ~63% transparent
```

---

## 🔄 Complete Round Cycle

```
┌─────────────────────────────────────────┐
│ 1. Sit in Chair                         │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 2. UI Slides In (0.6s bounce)          │
│    Content Fades In (0.4s)              │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 3. Countdown (3-2-1-type!)             │
│    - Each number fades in/out           │
│    - "type!" bounces in                 │
│    Total: ~3.5 seconds                  │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 4. Input Unlocks                        │
│    - Focus highlight                    │
│    - Glow ready                         │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 5. Type First Character                 │
│    - Glow pulses bright                 │
│    - Timer starts draining              │
│    - Animation plays                    │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│ 6. Continue Typing                      │
│    - Timer bar shrinks + fades          │
│    - Text green (correct) / red (wrong) │
│    - WPM updates live                   │
└──────────────┬──────────────────────────┘
               ↓
         ┌─────┴─────┐
         ↓           ↓
  ┌──────────┐  ┌──────────┐
  │ Complete │  │ Timeout  │
  └─────┬────┘  └────┬─────┘
        ↓            ↓
┌───────────┐  ┌────────────┐
│ Success!  │  │ Time's up! │
│ Input     │  │ Input      │
│ locks     │  │ locks      │
│ Glow      │  │ Glow       │
│ resets    │  │ resets     │
│           │  │            │
│ Wait 2s   │  │ Wait 1.5s  │
│           │  │            │
│ New       │  │ Kicked     │
│ countdown │  │ from chair │
└─────┬─────┘  └────┬───────┘
      ↓            ↓
  (repeat)     (UI slides out)
```

---

## 🎯 Positioning Details

### Top of Screen (Y Positions)
```
                Screen Top (0)
                     ↓
              [88px space]
                     ↓
     ┌───────────────────────────┐  ← 0.02 of screen height
     │   Main Frame (200px)      │
     │  ┌─────────────────────┐  │
     │  │ Content (90px)      │  │  ← Position: 0
     │  │                     │  │
     │  └─────────────────────┘  │
     │  ▓ Timer (8px)           │  ← Position: 100
     │                           │
     │  Countdown (60px)         │  ← Position: 125
     │                           │
     │  Result (30px)            │  ← Position: 155 (when shown)
     └───────────────────────────┘
```

### Content Frame Internal Layout
```
┌────────────────────────────────┐
│ Sentence Label                 │ ← Y: 10, Height: 35
│                                │
│ Input Box                      │ ← Y: 50, Height: 35
└────────────────────────────────┘
                            Stats → X: -110 (right aligned)
```

---

## 🎨 Transparency Breakdown

| Element | Normal | Active | Notes |
|---------|--------|--------|-------|
| Main Frame | 100% | 100% | Always invisible |
| Content Frame BG | 70% | 70% | Semi-transparent black |
| Content Glow | 60% | 20% | Brightens when typing |
| Input Box BG | 90% | 85% | Slight highlight on focus |
| Timer Bar | 0-70% | varies | Based on time remaining |
| Countdown | 0-100% | varies | Fades in/out |
| Results | 0-100% | varies | Fades in |

---

## 💡 Animation Easing Guide

```
[Bounce Effects]
UI Entry/Exit: Back easing
  → Slight overshoot for playful feel

[Smooth Fades]
Colors, Opacity: Quad easing
  → Natural, smooth transitions

[Timer Updates]
Size/Transparency: Sine easing
  → Consistent, predictable motion

[Countdown]
Numbers: Quad easing
  → Simple, casual feel
"type!": Back easing
  → Slight bounce for energy
```

---

**🎨 Every pixel designed for smooth, professional feel!**
