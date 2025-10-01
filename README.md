# 🌀 ROBLOX GRAVITY GUN - Complete System

A fully functional, visually stunning Gravity Gun tool for Roblox that lets players pick up, hold, and throw objects with amazing particle effects, beams, and a futuristic UI!

## ✨ Features

- **Physics-Based Grabbing**: Pick up any unanchored object within range
- **Visual Effects**: 
  - Particle effects on held objects
  - Beam connecting player to object
  - Trail effects when throwing
  - Animated crosshair and UI
- **Smooth Controls**: 
  - Left click to grab/throw
  - Right click to release gently
  - Objects follow your camera smoothly
- **Anti-Exploit Protection**: Server-side validation for all actions
- **Mass & Distance Limits**: Can't grab objects that are too heavy or far away
- **Beautiful UI**: Animated crosshair with status indicators and control hints

---

## 📦 Installation Guide

### Step 1: Create the Tool Object

1. Open **Roblox Studio**
2. Go to **ReplicatedStorage** in the Explorer
3. Insert a new **Tool** object (right-click ReplicatedStorage → Insert Object → Tool)
4. Name it `GravityGun`
5. Set the Tool properties:
   - **CanBeDropped**: true
   - **RequiresHandle**: false (or create a cool handle mesh if you want!)

### Step 2: Add Main Tool Script

1. Inside the `GravityGun` Tool you just created, insert a **LocalScript**
2. Copy the entire contents of **`GravityGunTool.lua`** 
3. Paste it into the LocalScript
4. You can name the script "GravityGunClient" or leave it as is

### Step 3: Add Server Script

1. Go to **ServerScriptService** in the Explorer
2. Insert a new **Script** (NOT LocalScript)
3. Copy the entire contents of **`GravityGunServer.lua`**
4. Paste it into the Script
5. Name it "GravityGunServer"

### Step 4: Add Effects Handler

1. Go to **StarterPlayer** → **StarterPlayerScripts** in the Explorer
2. Insert a new **LocalScript**
3. Copy the entire contents of **`GravityGunEffects.lua`**
4. Paste it into the LocalScript
5. Name it "GravityGunEffects"

### Step 5: Add UI System

1. Go to **StarterGui** in the Explorer
2. Insert a new **ScreenGui** object
3. Inside the ScreenGui, insert a **LocalScript**
4. Copy the entire contents of **`GravityGunUI.lua`**
5. Paste it into the LocalScript
6. Name it "GravityGunUI"

---

## 🎮 How to Test

1. **Click "Play" in Roblox Studio** (test as a single player or in a server)
2. **Give yourself the tool**: 
   - Option A: Drag the GravityGun from ReplicatedStorage into your StarterPack
   - Option B: In the Command Bar, type: 
     ```lua
     game.ReplicatedStorage.GravityGun:Clone().Parent = game.Players.LocalPlayer.Backpack
     ```
3. **Equip the tool** from your inventory
4. **Point at an object** and see it highlight in cyan
5. **Left click** to grab it - it will float in front of you!
6. **Move your mouse** to control where the object goes
7. **Left click again** to throw it in the direction you're looking
8. **Right click** to release it gently without throwing

---

## 🛠️ How It Works

### Architecture Overview

The system uses a **client-server architecture** with three main components:

#### 1. **GravityGunTool.lua** (Client - Tool Script)
- Handles user input (mouse clicks, movement)
- Creates visual highlights on targetable objects
- Sends grab/throw/release requests to server
- Updates held object position every frame
- Shows/hides UI when tool is equipped/unequipped

**Key Features:**
- Uses `Mouse.Target` to detect what you're pointing at
- Validates objects client-side for instant feedback
- Sends position updates to server during holding
- Maximum distance: 50 studs
- Hold distance: 10 studs in front of camera

#### 2. **GravityGunServer.lua** (Server - ServerScriptService)
- Validates all client requests (anti-exploit)
- Creates `BodyPosition` and `BodyGyro` for physics manipulation
- Tracks which objects are held by which players
- Handles object throwing with velocity application
- Cleans up when players leave

**Security Features:**
- Checks if object is anchored
- Validates object mass (max 500)
- Confirms distance is within range
- Prevents grabbing characters/humanoids
- Prevents multiple players from grabbing same object
- Throttles position updates (0.03s minimum)

#### 3. **GravityGunEffects.lua** (Client - PlayerScripts)
- Creates particle effects on grabbed objects
- Generates beam from player to object
- Spawns trail effects when throwing
- Plays sound effects
- Cleans up effects when objects are released

**Visual Effects:**
- **Grab**: Cyan sparkle particles + electric particles + beam connection
- **Throw**: Burst particles + trailing effect + whoosh sound
- **Colors**: Cyan to blue gradient theme

#### 4. **GravityGunUI.lua** (Client - StarterGui)
- Creates animated crosshair with rotating outer ring
- Shows status text (READY vs OBJECT LOCKED)
- Displays control hints at bottom of screen
- Pulse and rotation animations for visual appeal
- Changes colors based on tool state

**UI Elements:**
- Center dot with cyan glow
- 4 directional lines that pulse
- Rotating outer ring
- Status indicator
- Control hints panel with instructions

---

## 🎯 Customization Options

### Adjust Grab Distance & Power
In **GravityGunTool.lua** (lines 15-17):
```lua
local MAX_DISTANCE = 50  -- How far you can grab objects
local HOLD_DISTANCE = 10 -- How far in front objects are held
local THROW_POWER = 100  -- How hard objects are thrown
```

### Change Mass Limit
In **GravityGunServer.lua** (lines 19-20):
```lua
local MAX_DISTANCE = 50
local MAX_MASS = 500  -- Maximum mass of objects you can grab
```

### Modify Colors
In **GravityGunEffects.lua** and **GravityGunUI.lua**, change:
```lua
Color3.fromRGB(0, 255, 255)  -- Cyan
Color3.fromRGB(0, 150, 255)  -- Blue
```

### Add Custom Sounds
In **GravityGunEffects.lua**, replace sound IDs:
```lua
local grabSound = createSound("12222095", object, 0.3)  -- Grab sound
local throwSound = createSound("12222030", object, 0.4) -- Throw sound
```

Find sound IDs on the Roblox website and replace the numbers!

---

## 🔧 Troubleshooting

### Tool doesn't appear in inventory
- Make sure the GravityGun is in ReplicatedStorage
- Clone it to StarterPack or give it via script
- Check that RequiresHandle is set to false OR you have a Handle part

### Objects won't grab
- Check if object is anchored (must be unanchored)
- Verify object mass is under 500
- Make sure you're within 50 studs
- Can't grab characters or humanoid models

### No visual effects
- Confirm GravityGunEffects script is in StarterPlayerScripts
- Check Output window for errors
- RemoteEvents should be created automatically by server script

### UI not showing
- Check StarterGui for the ScreenGui with the UI script
- Make sure the script runs without errors
- UI only shows when tool is equipped

### "RemoteEvent not found" error
- The server script creates RemoteEvents automatically
- Make sure GravityGunServer is in ServerScriptService
- Wait a few seconds after joining for server to initialize

---

## 🎨 Cool Ideas to Extend

- **Add a charging mechanic**: Hold longer to throw harder
- **Color customization**: Let players choose their beam color
- **Dual wielding**: Hold multiple objects at once
- **Gravity field**: Create an area that affects multiple objects
- **Size scaling**: Shrink/grow held objects
- **Freeze object**: Toggle to lock object in midair
- **Team restrictions**: Only grab objects your team owns
- **Puzzle mechanics**: Use it for puzzle games requiring object placement

---

## 📝 Technical Details

### RemoteEvents Used
- **GravityGunEvent**: Client ↔ Server communication for grab/throw/release
- **GravityGunEffects**: Server → All Clients for synchronized effects

### Physics Objects Created
- **BodyPosition**: Moves object to target position smoothly
- **BodyGyro**: Stabilizes object rotation while held
- Both are destroyed when object is released/thrown

### Performance
- Efficient throttling on position updates (0.03s)
- Effects automatically cleaned up with Debris service
- Beams and particles only active when needed
- No memory leaks - proper cleanup on player disconnect

---

## 🎮 Controls Summary

| Input | Action |
|-------|--------|
| **Left Click** | Grab object / Throw held object |
| **Right Click** | Release object gently |
| **Mouse Movement** | Control held object position |
| **Equip Tool** | Activate Gravity Gun |
| **Unequip Tool** | Auto-release any held object |

---

## 🌟 Credits

Created as a complete, production-ready Roblox Luau system with:
- Client-server architecture
- Anti-exploit protection
- Professional visual effects
- Modern UI design
- Comprehensive documentation

Enjoy your Gravity Gun! Feel free to modify and expand it for your game! 🚀
