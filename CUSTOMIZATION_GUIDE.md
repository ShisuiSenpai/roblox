# ⚙️ Crate Opening Customization Guide

## 🎯 All Settings Explained

Everything is in `UI_SETTINGS` at the top of **CrateSystemClient.lua**

---

## 🎬 Animation Settings

### Spin Speed
```lua
SpinDuration = 5, -- How long the spin takes (in seconds)
```

**Examples:**
- **Faster:** `SpinDuration = 3` (quick, snappy)
- **Current:** `SpinDuration = 5` (smooth, comfortable)
- **Slower:** `SpinDuration = 7` (dramatic, suspenseful)
- **Very Slow:** `SpinDuration = 10` (max suspense)

---

## 🔍 Zoom Settings

### Centered Item Zoom
```lua
HighlightScale = 1.08, -- How much bigger items get when centered
```

**Scale Guide:**
- `1.0` = No zoom at all
- `1.05` = 5% bigger (very subtle)
- `1.08` = 8% bigger (current, subtle)
- `1.1` = 10% bigger (noticeable)
- `1.15` = 15% bigger (dramatic)
- `1.2` = 20% bigger (very dramatic)

**Examples:**
```lua
HighlightScale = 1.0,  -- No zoom effect
HighlightScale = 1.05, -- Very subtle
HighlightScale = 1.15, -- More dramatic
```

---

## 💡 Brightness Settings

### Centered Brightness (Under Indicator)
```lua
CenteredBrightness = 1.0, -- How bright when under the indicator
```

**Brightness Guide:**
- `0.5` = 50% brightness (very dim)
- `0.7` = 70% brightness (slightly dim)
- `1.0` = 100% brightness (normal, current)
- `1.2` = 120% brightness (brighter than normal)
- `1.5` = 150% brightness (very bright, glowing)

### Default Brightness (Not Centered)
```lua
DefaultBrightness = 0.7, -- How bright items are by default
```

**Examples:**
```lua
DefaultBrightness = 0.5, -- Very dimmed (more dramatic contrast)
DefaultBrightness = 0.7, -- Slightly dimmed (current, balanced)
DefaultBrightness = 0.9, -- Almost full brightness (subtle)
```

---

## 🎨 Example Configurations

### Configuration 1: Dramatic & Slow
```lua
SpinDuration = 8,          -- Very slow
HighlightScale = 1.15,     -- Big zoom
CenteredBrightness = 1.3,  -- Bright glow
DefaultBrightness = 0.5,   -- Very dim background
```
**Effect:** Maximum suspense, strong contrast

### Configuration 2: Fast & Subtle
```lua
SpinDuration = 3,          -- Quick
HighlightScale = 1.05,     -- Small zoom
CenteredBrightness = 1.0,  -- Normal brightness
DefaultBrightness = 0.85,  -- Slightly dimmed
```
**Effect:** Quick and clean, minimal effects

### Configuration 3: Balanced (Current)
```lua
SpinDuration = 5,          -- Moderate
HighlightScale = 1.08,     -- Medium zoom
CenteredBrightness = 1.0,  -- Normal brightness
DefaultBrightness = 0.7,   -- Medium dim
```
**Effect:** Professional CS:GO style

### Configuration 4: Glowing Highlight
```lua
SpinDuration = 6,          -- Slower
HighlightScale = 1.12,     -- Bigger zoom
CenteredBrightness = 1.4,  -- Very bright
DefaultBrightness = 0.6,   -- Dark background
```
**Effect:** Items "glow" when centered

---

## 📊 Understanding Brightness

### How Brightness Works:
The brightness value multiplies the RGB colors:

**Example with DefaultBrightness = 0.7:**
- Background RGB(25, 25, 35) becomes RGB(17.5, 17.5, 24.5)
- Viewport lighting also adjusts
- Creates a dimmed, shadowed effect

**Example with CenteredBrightness = 1.0:**
- Background stays RGB(25, 25, 35) (normal)
- Viewport lighting at full
- Looks "normal" and highlighted

**Example with CenteredBrightness = 1.3:**
- Background becomes RGB(32.5, 32.5, 45.5) (brighter)
- Viewport lighting boosted
- Creates a glowing effect

---

## 🎯 Recommended Ranges

### Spin Duration
- **Min:** 2 seconds (very fast, hard to see)
- **Sweet Spot:** 4-6 seconds
- **Max:** 10 seconds (very slow, testing patience)

### Highlight Scale
- **Min:** 1.0 (no zoom)
- **Sweet Spot:** 1.05 - 1.12
- **Max:** 1.25 (anything higher looks weird)

### Centered Brightness
- **Min:** 0.8 (don't go below this)
- **Sweet Spot:** 1.0 - 1.2
- **Max:** 1.5 (very bright glow)

### Default Brightness
- **Min:** 0.5 (very dramatic darkness)
- **Sweet Spot:** 0.65 - 0.8
- **Max:** 0.95 (barely dimmed)

---

## 💡 Pro Tips

### Tip 1: Match Your Game's Style
**Dark, Mysterious Game:**
```lua
DefaultBrightness = 0.5    -- Dark shadows
CenteredBrightness = 1.2   -- Strong highlight
```

**Bright, Arcade Game:**
```lua
DefaultBrightness = 0.85   -- Not too dark
CenteredBrightness = 1.1   -- Subtle glow
```

### Tip 2: Speed vs. Suspense
- **Fast opening** = More crate openings per minute = More excitement
- **Slow opening** = More suspense = More dramatic

### Tip 3: Contrast is Key
The bigger the difference between `DefaultBrightness` and `CenteredBrightness`, the more dramatic the effect:

```lua
-- High Contrast (Dramatic)
DefaultBrightness = 0.5
CenteredBrightness = 1.3
-- Difference: 0.8

-- Low Contrast (Subtle)
DefaultBrightness = 0.8
CenteredBrightness = 1.0
-- Difference: 0.2
```

### Tip 4: Test Different Combinations
No single setting works for everyone! Try:
1. Start with current settings
2. Adjust ONE setting at a time
3. Test in-game
4. Keep what feels best

---

## 🔧 Quick Testing Commands

Copy these into your script to quickly test different styles:

### Style 1: Dramatic
```lua
UI_SETTINGS.SpinDuration = 7
UI_SETTINGS.HighlightScale = 1.15
UI_SETTINGS.CenteredBrightness = 1.3
UI_SETTINGS.DefaultBrightness = 0.5
```

### Style 2: Subtle
```lua
UI_SETTINGS.SpinDuration = 4
UI_SETTINGS.HighlightScale = 1.05
UI_SETTINGS.CenteredBrightness = 1.05
UI_SETTINGS.DefaultBrightness = 0.85
```

### Style 3: Fast & Exciting
```lua
UI_SETTINGS.SpinDuration = 3
UI_SETTINGS.HighlightScale = 1.1
UI_SETTINGS.CenteredBrightness = 1.2
UI_SETTINGS.DefaultBrightness = 0.7
```

---

## 📝 Current Settings Summary

```lua
-- Animation
SpinDuration = 5         -- Moderate speed

-- Zoom
HighlightScale = 1.08    -- 8% bigger when centered

-- Brightness
CenteredBrightness = 1.0 -- Normal brightness at center
DefaultBrightness = 0.7  -- 70% brightness by default
```

**Result:** Balanced, professional CS:GO style with good contrast

---

## ✅ Settings Checklist

When customizing, make sure:
- [ ] SpinDuration is between 2-10 seconds
- [ ] HighlightScale is between 1.0-1.25
- [ ] CenteredBrightness is between 0.8-1.5
- [ ] DefaultBrightness is between 0.5-0.95
- [ ] DefaultBrightness < CenteredBrightness (for contrast)
- [ ] Tested in-game before finalizing

---

Play around and find your perfect settings! 🎉
