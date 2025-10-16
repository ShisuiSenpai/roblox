# 🎨 Typing Test UI - Design Notes

## New Minimal UI Design

The UI has been redesigned to be **transparent, compact, and positioned at the top** of the screen for a sleek, non-intrusive experience.

---

## 📐 Layout Overview

```
┌─────────────────────────────────────────────────────────┐
│                    TOP OF SCREEN                        │
│  ┌───────────────────────────────────────────────┐     │
│  │  [Sentence to type...]              │ 45 │   │     │ ← Semi-transparent box
│  │  [Your typing here_____]            │WPM │   │     │
│  └───────────────────────────────────────────────┘     │
│           ✓ 45 WPM in 3.2s - Perfect!                  │ ← Shows on complete
└─────────────────────────────────────────────────────────┘
```

---

## 🎯 Design Features

### 1. **Transparent Background**
- Main container: 100% transparent
- Content box: 70% transparent (30% visible)
- Subtle glow effect with cyan stroke

### 2. **Top Positioning**
- Slides down from top when seated
- Stays at top of screen (2% from edge)
- Slides back up when leaving chair

### 3. **Compact Layout**
- **Size**: 700px wide × 120px tall
- **Sentence**: Left-aligned, 18px text
- **Input**: Below sentence, same width
- **WPM**: Right side, compact display (100px wide)

### 4. **Color Coding**
- ✅ **Correct typing**: Bright green `RGB(100, 255, 150)`
- ❌ **Wrong typing**: Bright red `RGB(255, 100, 100)`
- 📊 **WPM counter**: Cyan `RGB(100, 220, 255)`
- 📝 **Sentence text**: Light gray `RGB(230, 230, 230)`

---

## 🔧 Customization Guide

### Make UI More/Less Transparent

**Location**: `TypingTestClient.lua` line 81

```lua
-- Current (30% visible)
contentFrame.BackgroundTransparency = 0.7

-- More visible (50% visible)
contentFrame.BackgroundTransparency = 0.5

-- Less visible (10% visible)
contentFrame.BackgroundTransparency = 0.9

-- Solid background (100% visible)
contentFrame.BackgroundTransparency = 0
```

### Adjust UI Size

**Location**: `TypingTestClient.lua` line 73

```lua
-- Current size
mainFrame.Size = UDim2.new(0, 700, 0, 120)

-- Wider and taller
mainFrame.Size = UDim2.new(0, 900, 0, 150)

-- Smaller and more compact
mainFrame.Size = UDim2.new(0, 500, 0, 100)
```

### Change Background Color

**Location**: `TypingTestClient.lua` line 80

```lua
-- Current (black)
contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

-- Dark blue
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)

-- Dark purple
contentFrame.BackgroundColor3 = Color3.fromRGB(40, 20, 60)

-- Dark green
contentFrame.BackgroundColor3 = Color3.fromRGB(10, 30, 20)
```

### Adjust Glow Effect

**Location**: `TypingTestClient.lua` lines 86-89

```lua
-- Current (subtle cyan glow)
glow.Color = Color3.fromRGB(100, 200, 255)
glow.Thickness = 1
glow.Transparency = 0.6

-- Brighter glow
glow.Thickness = 2
glow.Transparency = 0.3

-- No glow (remove or set)
glow.Transparency = 1

-- Different color (green glow)
glow.Color = Color3.fromRGB(100, 255, 150)
```

### Move UI Position

**Location**: `TypingTestClient.lua` line 344 (in showUI function)

```lua
-- Current (2% from top)
Position = UDim2.new(0.5, 0, 0.02, 0)

-- Higher (right at top)
Position = UDim2.new(0.5, 0, 0, 0)

-- Lower (5% from top)
Position = UDim2.new(0.5, 0, 0.05, 0)

-- Move to bottom instead
Position = UDim2.new(0.5, 0, 0.85, 0)
```

---

## 🎨 Color Schemes

### Preset 1: Neon (Current)
```lua
-- Background
contentFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
contentFrame.BackgroundTransparency = 0.7

-- Glow
glow.Color = Color3.fromRGB(100, 200, 255)

-- WPM
statsLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
```

### Preset 2: Matrix Green
```lua
-- Background
contentFrame.BackgroundColor3 = Color3.fromRGB(0, 20, 0)
contentFrame.BackgroundTransparency = 0.6

-- Glow
glow.Color = Color3.fromRGB(0, 255, 0)

-- WPM
statsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
```

### Preset 3: Purple Dream
```lua
-- Background
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
contentFrame.BackgroundTransparency = 0.5

-- Glow
glow.Color = Color3.fromRGB(200, 100, 255)

-- WPM
statsLabel.TextColor3 = Color3.fromRGB(220, 150, 255)
```

### Preset 4: Fire
```lua
-- Background
contentFrame.BackgroundColor3 = Color3.fromRGB(50, 20, 0)
contentFrame.BackgroundTransparency = 0.6

-- Glow
glow.Color = Color3.fromRGB(255, 150, 0)

-- WPM
statsLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
```

---

## 📊 WPM Display Format

The WPM counter is displayed vertically on the right:

```
┌─────┐
│ 45  │  ← WPM number (large)
│ WPM │  ← Label (smaller)
└─────┘
```

**Location**: `TypingTestClient.lua` line 92

```lua
-- Current format
statsLabel.Text = string.format("%d\nWPM", wpm)

-- Horizontal format
statsLabel.Text = string.format("%d WPM", wpm)

-- With icon
statsLabel.Text = string.format("⚡%d\nWPM", wpm)
```

---

## 🎬 Animation Behavior

### Show Animation (when sitting)
- **Duration**: 0.5 seconds
- **Easing**: Quart Out (smooth deceleration)
- **Movement**: Slides down from above screen to top position

### Hide Animation (when standing)
- **Duration**: 0.4 seconds
- **Easing**: Quart In (smooth acceleration)
- **Movement**: Slides up and off screen

### Adjust Animation Speed

**Location**: `TypingTestClient.lua` lines 342-343

```lua
-- Show animation
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Faster (0.3 seconds)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Slower (1 second)
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Bouncy effect
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
```

---

## 🖱️ Input Box Styling

### Current Design
- Very transparent background (90% transparent)
- Rounded corners (8px radius)
- Light text with color feedback
- Subtle padding

### Make Input More Visible

**Location**: `TypingTestClient.lua` line 69

```lua
-- Current (very transparent)
inputBox.BackgroundTransparency = 0.9

-- More visible
inputBox.BackgroundTransparency = 0.7

-- Solid
inputBox.BackgroundTransparency = 0
```

### Change Input Background Color

**Location**: `TypingTestClient.lua` line 68

```lua
-- Current (white)
inputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

-- Cyan tint
inputBox.BackgroundColor3 = Color3.fromRGB(150, 200, 255)

-- Dark
inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
```

---

## 💡 UI Best Practices

1. **Transparency Balance**: Keep between 0.5-0.8 for readability
2. **Contrast**: Ensure text is readable against game background
3. **Size**: Don't make too small (min 500px width recommended)
4. **Position**: Top placement keeps player's view clear
5. **Colors**: Use high contrast for correct/incorrect feedback
6. **Glow**: Keep subtle to avoid distraction

---

## 🔄 Responsive Design

The UI is designed to work on different screen sizes:

- **Desktop/Console**: 700px wide (perfect fit)
- **Tablet**: Scales proportionally
- **Mobile**: May need size adjustment

For mobile optimization, reduce size:
```lua
mainFrame.Size = UDim2.new(0, 500, 0, 100)
```

---

**UI redesigned for minimal distraction and maximum style!** ✨
