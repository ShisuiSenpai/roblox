# 🎮 Multiplayer Setup Guide - 6 Player Racing

## Overview

Transform your typing test into a 6-player competitive race!

---

## 🏗️ Architecture

```
Workspace
  └─ TypingChairs (Folder)
      ├─ Chair1 (Model + ChairController)
      ├─ Chair2 (Model + ChairController)
      ├─ Chair3 (Model + ChairController)
      ├─ Chair4 (Model + ChairController)
      ├─ Chair5 (Model + ChairController)
      └─ Chair6 (Model + ChairController)

ServerScriptService
  └─ MatchController (Script) ← NEW!

ReplicatedStorage
  └─ TypingTestRemote (RemoteEvent) ← Already exists
  └─ MatchRemote (RemoteEvent) ← NEW!

StarterPlayerScripts
  ├─ TypingTestClient (LocalScript) ← Modified
  └─ LeaderboardClient (LocalScript) ← NEW!
```

---

## 📋 Step-by-Step Setup

### Step 1: Create the Chairs

1. **Duplicate your existing chair 6 times**
   - Select your current chair in Workspace
   - Press Ctrl+D (duplicate) 5 times
   - You now have 6 chairs

2. **Position them in a row**
   - Arrange in a line or semi-circle
   - Space them out (10-15 studs apart)
   - Make sure players can see each other

3. **Rename the chairs**
   - Chair1
   - Chair2
   - Chair3
   - Chair4
   - Chair5
   - Chair6

4. **Create a Folder**
   - Insert Folder in Workspace
   - Name it "TypingChairs"
   - Move all 6 chairs into this folder

---

### Step 2: Install New Scripts

**A. MatchController.lua**
1. Go to ServerScriptService
2. Insert new Script
3. Name it "MatchController"
4. Copy contents from `MatchController.lua`
5. Paste into script

**B. LeaderboardClient.lua**
1. Go to StarterPlayer > StarterPlayerScripts
2. Insert new LocalScript
3. Name it "LeaderboardClient"
4. Copy contents from `LeaderboardClient.lua`
5. Paste into script

**C. Replace ChairController.lua**
1. In each of your 6 chairs
2. Delete old ChairController
3. Insert new Script
4. Copy contents from `ChairController_Multi.lua`
5. Paste into each chair's script

**D. Replace TypingTestClient.lua**
1. Go to StarterPlayer > StarterPlayerScripts
2. Replace current TypingTestClient
3. Copy contents from `TypingTestClient_Multi.lua`
4. Paste

---

### Step 3: Create RemoteEvent

1. Go to ReplicatedStorage
2. Insert RemoteEvent
3. Name it "MatchRemote"
4. Should have both:
   - TypingTestRemote (already exists)
   - MatchRemote (new)

---

### Step 4: Configure Settings

**In MatchController.lua (top of script):**

```lua
-- Match Settings
local MIN_PLAYERS = 2        -- Minimum to start a match
local MAX_PLAYERS = 6        -- Maximum players
local LOBBY_WAIT_TIME = 10   -- Seconds to wait for players
local ROUND_DELAY = 3        -- Delay between rounds
```

**Adjust these to your preference!**

---

## 🎮 How It Works

### Matchmaking Flow

```
1. Players sit in chairs (1-6)
2. Wait for minimum players (2+)
3. Countdown: "Starting in 10... 9... 8..."
4. All players locked in
5. Synchronized 3-2-1-type! countdown
6. Same sentence for everyone
7. Timer starts for all simultaneously
8. Race to complete!
```

### During Round

```
Player A: Typing... (Yellow 🟡)
Player B: Typing... (Yellow 🟡)
Player C: Completed! (Green 🟢)
Player D: Typing... (Yellow 🟡)
Player E: Failed! (Red 🔴) → Dies
Player F: Typing... (Yellow 🟡)
```

### After Round

```
✅ Completed: Continue to next round
❌ Failed: Die and kicked
⏱️ Timeout: Die and kicked

Next round:
- Surviving players get new sentence
- Timer gets faster
- Repeat until 1 winner!
```

---

## 🏆 Win Conditions

**Winner:**
- Last player standing
- Survives the most rounds

**Loser:**
- Runs out of time
- Makes mistake and can't complete

**Draw:**
- All players fail same round
- Game resets

---

## 📊 Leaderboard Features

**Shows for each player:**
- 🖼️ Profile picture (circular)
- 📝 Player name
- ⚡ Current WPM
- ⏱️ Completion time
- 🎨 Status color:
  - 🟢 Green = Completed
  - 🟡 Yellow = Typing
  - 🔴 Red = Failed/Out
  - ⚪ Gray = Empty slot

**Updates in real-time:**
- WPM changes as they type
- Status changes on complete/fail
- Smooth animations
- Always visible

---

## 🎨 Leaderboard Styling

**Matches your current UI:**
- Semi-transparent black background
- Blue glow border
- Smooth fade animations
- Modern, minimal design
- Top-right corner placement
- Doesn't block gameplay

---

## 🔧 Testing Checklist

### Solo Testing:
- [ ] Sit in chair alone
- [ ] Should say "Waiting for players..."
- [ ] After timeout, starts solo
- [ ] Can complete rounds normally

### 2 Player Testing:
- [ ] Both players sit
- [ ] Countdown starts
- [ ] Both see same sentence
- [ ] Both timers sync
- [ ] Leaderboard shows both
- [ ] First to finish = Green
- [ ] Slower player = Yellow
- [ ] Failed player = Red, dies

### 6 Player Testing:
- [ ] All 6 chairs work
- [ ] Leaderboard shows all 6
- [ ] All synced to same round
- [ ] Failed players die
- [ ] Winners continue
- [ ] Last player = WINNER!

---

## ⚙️ Configuration Options

### Match Settings

**Minimum Players:**
```lua
local MIN_PLAYERS = 2  -- At least 2 to race
```

**Lobby Wait Time:**
```lua
local LOBBY_WAIT_TIME = 10  -- Seconds to wait
```

**Round Settings:**
```lua
-- In TypingTestClient:
local INITIAL_TIME = 15  -- Stays the same
local MIN_TIME = 5
local TIME_REDUCTION = 1
```

### Leaderboard Position

**In LeaderboardClient.lua:**
```lua
-- Position (top-right)
Position = UDim2.new(1, -320, 0, 20)

-- Size
Size = UDim2.new(0, 300, 0, 400)
```

---

## 🎯 Game Modes (Future Ideas)

### Elimination Mode (Current)
- Fail = Die and kicked
- Last player wins

### Time Attack
- All players get X rounds
- Fastest average time wins
- No elimination

### Survival Mode
- Infinite rounds
- Gets progressively harder
- See who survives longest

### Tournament Mode
- Bracket system
- Winners advance
- Finals match

---

## 🐛 Troubleshooting

### Players not syncing:
- Check MatchController is in ServerScriptService
- Check MatchRemote exists
- Check all chairs in "TypingChairs" folder

### Leaderboard not showing:
- Check LeaderboardClient in StarterPlayerScripts
- Check RemoteEvent connections
- Check Output for errors

### Different sentences:
- Check MatchController is sending sentence
- Check sentence sync code
- Restart match

### Timer not syncing:
- Check startTime is same for all
- Check server sends start signal
- Check client receives signal

---

## 📁 Files You Need

1. **MatchController.lua** - Server game manager
2. **LeaderboardClient.lua** - Client leaderboard UI
3. **ChairController_Multi.lua** - Modified chair script
4. **TypingTestClient_Multi.lua** - Modified client script

**I'll create all these files for you next!**

---

## 🚀 Next Steps

1. Create the 6 chairs
2. Install all new scripts
3. Create MatchRemote
4. Test with friends!

---

**Ready to make it multiplayer! Let me create the scripts now! 🎮**
