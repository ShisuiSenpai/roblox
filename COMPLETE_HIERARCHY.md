# Complete Explorer Hierarchy Setup

## 🎯 Exact Setup for Your Game

Based on your structure: `Workspace.RocketArenaMap.Cube`

---

## 📋 Step-by-Step Setup

### 1. SERVER SCRIPT (JumpPadManager)

```
game
├─ ServerScriptService
│  └─ JumpPadManager (Script) ← Paste JumpPadManager.lua code here
│     • Script type: Script (NOT LocalScript)
│     • Contains: All code from JumpPadManager.lua
```

**How to do it:**
1. Open **ServerScriptService** in Explorer
2. Click **+** button → Insert **Script**
3. Rename it to **"JumpPadManager"**
4. Open the script and **paste ALL code** from `JumpPadManager.lua`

---

### 2. CLIENT SCRIPT (JumpPadClient)

```
game
├─ StarterPlayer
│  └─ StarterPlayerScripts
│     └─ JumpPadClient (LocalScript) ← Paste JumpPadClient.lua code here
│        • Script type: LocalScript (NOT Script)
│        • Contains: All code from JumpPadClient.lua
```

**How to do it:**
1. Open **StarterPlayer** → **StarterPlayerScripts** in Explorer
2. Click **+** button → Insert **LocalScript**
3. Rename it to **"JumpPadClient"**
4. Open the script and **paste ALL code** from `JumpPadClient.lua`

---

### 3. YOUR JUMP PAD PARTS (Tag Them!)

```
game
├─ Workspace
│  └─ RocketArenaMap (Model or Folder)
│     └─ Cube (Part) ← THIS NEEDS THE TAG!
│        • NO script inside
│        • Properties: CanCollide = true, Anchored = true
│        • TAG: "JumpPad" ← THIS IS CRITICAL!
```

**How to tag it:**
1. Open **View** menu → Check **"Tags"** (opens Tag Editor panel)
2. Select your **Cube** part in Explorer
3. In Tag Editor panel, click **"+"** button
4. Type: **JumpPad** (exactly like this, case-sensitive)
5. Press **Enter**

You should see **"JumpPad"** appear as a tag on the part!

---

## 📊 Complete Visual Hierarchy

```
game
│
├─ ServerScriptService
│  └─ 📄 JumpPadManager (Script)
│     └─ Contains: JumpPadManager.lua code
│
├─ StarterPlayer
│  └─ StarterPlayerScripts
│     └─ 📄 JumpPadClient (LocalScript)
│        └─ Contains: JumpPadClient.lua code
│
├─ ReplicatedStorage
│  └─ 🔧 JumpPadEvent (RemoteEvent)
│     └─ Created automatically by JumpPadManager
│
└─ Workspace
   └─ 🗺️ RocketArenaMap
      └─ 🟦 Cube (Part)
         └─ 🏷️ Tag: "JumpPad"
```

---

## ✅ Testing Checklist

### Before Playing:

- [ ] JumpPadManager script is in **ServerScriptService**
- [ ] JumpPadManager is a **Script** (not LocalScript)
- [ ] JumpPadClient script is in **StarterPlayerScripts**
- [ ] JumpPadClient is a **LocalScript** (not Script)
- [ ] Your Cube part is tagged with **"JumpPad"**
- [ ] Cube part has **CanCollide = true**
- [ ] Cube part is **Anchored = true**

### When You Play:

Check the **Output** window. You should see:

```
🚀 Initializing Jump Pad Manager...
✅ Jump Pad Manager ready! Watching for 'JumpPad' tags.
✅ Jump Pad setup: Cube (Strength: 50)
✅ Jump Pad Client ready!
```

**If you see these 4 messages**, it's working! Walk onto the Cube and you should launch up.

---

## 🚨 Common Issues

### Issue 1: "No setup messages in Output"

**Problem:** The tag isn't applied or scripts aren't running.

**Solution:**
1. Verify tag is on the part (select Cube, check Tag Editor)
2. Verify scripts are in correct locations
3. Check that scripts don't have any errors (red text in Output)

---

### Issue 2: "Only see Manager ready, no 'setup: Cube' message"

**Problem:** The Cube part isn't tagged.

**Solution:**
1. Select the **Cube** part
2. Open Tag Editor (View → Tags)
3. Add tag: **"JumpPad"**
4. Stop and restart the game

---

### Issue 3: "No client ready message"

**Problem:** Client script isn't in the right place or is a Script instead of LocalScript.

**Solution:**
1. Make sure script is in **StarterPlayerScripts** (not ServerScriptService)
2. Make sure it's a **LocalScript** (should have a blue icon)
3. If it's a regular Script (red icon), delete it and create a LocalScript

---

### Issue 4: "Part turns green but no jump"

**Problem:** Client script isn't running or has errors.

**Solution:**
1. Check Output for any red error messages
2. Verify client script is a **LocalScript** in **StarterPlayerScripts**
3. Make sure you see "✅ Jump Pad Client ready!" in Output

---

## 🎮 For Multiple Jump Pads

If you have more Cube parts or other parts:

```
Workspace
├─ RocketArenaMap
│  ├─ Cube [Tag: "JumpPad"] ← This one works
│  ├─ Cube2 [Tag: "JumpPad"] ← Tag this too!
│  └─ JumpPadPart [Tag: "JumpPad"] ← Tag this too!
```

Just **tag each one** with "JumpPad" and they all work automatically!

---

## 📸 Visual Guide: How to Tag

1. **Enable Tag Editor:**
   ```
   Top Menu → View → ☑ Tags
   ```

2. **Select Your Part:**
   ```
   Explorer → Workspace → RocketArenaMap → Cube (click it)
   ```

3. **Add Tag:**
   ```
   Tag Editor Panel (right side) → Click "+" → Type "JumpPad" → Enter
   ```

4. **Verify:**
   ```
   You should see "JumpPad" listed under the part's name in Tag Editor
   ```

---

## 🔧 Properties to Set on Cube Part

Select the **Cube** part and set these properties:

| Property | Value | Why |
|----------|-------|-----|
| **Anchored** | ✅ true | Prevents part from moving when touched |
| **CanCollide** | ✅ true | Allows player to touch it |
| **Transparency** | 0 (or your choice) | So players can see it |
| **Material** | Neon (optional) | Makes it glow/stand out |
| **Color** | Bright color | Makes it obvious |

---

## 📝 Summary

**3 Things You Need:**

1. **JumpPadManager** (Script) in **ServerScriptService**
2. **JumpPadClient** (LocalScript) in **StarterPlayerScripts**
3. **Tag your Cube part** with **"JumpPad"** (no script inside the part!)

That's it! The system handles everything else automatically. 🚀
