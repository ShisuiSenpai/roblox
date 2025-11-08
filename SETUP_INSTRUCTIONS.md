# 🚀 QUICK SETUP INSTRUCTIONS

Follow these steps EXACTLY and it will work!

---

## Step 1: Create SwordConfig ModuleScript

**Location:** `ReplicatedStorage`

1. In ReplicatedStorage, click **+**
2. Insert **ModuleScript**
3. Name it **`SwordConfig`**
4. Open it and **delete all default code**
5. Copy the code from **`SwordConfig.lua`** file and paste it

---

## Step 2: Create MultiSwordSystem LocalScript

**Location:** `StarterPlayer > StarterPlayerScripts`

1. In StarterPlayerScripts, click **+**
2. Insert **LocalScript** (NOT a regular Script!)
3. Name it **`MultiSwordSystem`**
4. Copy the code from **`MultiSwordSystem.lua`** file and paste it

---

## Step 3: Verify Your Existing Models

You already have these in ReplicatedStorage - just double-check the names:

✅ **NormalSword** (Tool)
   - Inside: Handle (MeshPart)

✅ **HolsteredSwordNormal** (Model)
   - Inside: NormalSword (MeshPart)

✅ **IceSword** (Tool)
   - Inside: Handle (MeshPart)

✅ **HolsteredSwordIce** (Model)
   - Inside: IceSword (MeshPart)

---

## Step 4: Test!

1. Press **Play**
2. You should see NormalSword holstered on your character's **right hip**
3. **Click** to attack
4. Press **"2"** to switch to IceSword (it will appear on **left hip**)
5. **Click** to attack with IceSword
6. Press **"1"** to switch back to NormalSword

---

## 🎯 Expected Result

- **Start:** NormalSword visible on right hip
- **Press 1:** Switch to NormalSword (right hip)
- **Press 2:** Switch to IceSword (left hip)
- **Click:** Attack with current sword
- **Swords swap visibility** when you switch between them

---

## 🐛 If Something's Wrong

**Check the Output window** (View > Output) for error messages

Common issues:
- Script is in wrong location
- Names don't match exactly (case-sensitive!)
- Tool is in StarterPack instead of ReplicatedStorage

---

## 📁 Final Hierarchy Check

```
ReplicatedStorage/
├─ SwordConfig (ModuleScript) ← YOU CREATE THIS
├─ NormalSword (Tool) ← YOU HAVE
├─ HolsteredSwordNormal (Model) ← YOU HAVE
├─ IceSword (Tool) ← YOU HAVE
└─ HolsteredSwordIce (Model) ← YOU HAVE

StarterPlayer/
└─ StarterPlayerScripts/
   └─ MultiSwordSystem (LocalScript) ← YOU CREATE THIS
```

---

That's it! 2 scripts to create, then you're done! 🎉
