# Jump Pad Setup Guide

## ✅ Quick Fix for Your SpringPad

Your error happened because the script was in a **Model** but it was looking for a **Part**. I've fixed the script - it now works in both situations!

## 🎯 Two Ways to Set Up

### Option 1: Direct in a Part (Simple)
1. Create a **Part** in Workspace
2. Name it "JumpPad" or "SpringPad" 
3. Add a **Script** directly inside that Part
4. Copy the code from `JumpPad.lua` into the Script
5. Done!

```
Workspace
  └─ JumpPad (Part)
      └─ Script
```

### Option 2: In a Model (Your Current Setup)
1. Have a **Model** in Workspace (your "SpringPad")
2. Make sure the Model contains at least one **Part**
3. Add a **Script** inside the Model
4. Copy the code from `JumpPad.lua` into the Script
5. Done!

```
Workspace
  └─ SpringPad (Model)
      ├─ Part (this is what players touch)
      └─ Script (the jump pad script)
```

### Option 3: Model with PrimaryPart (Best for Complex Models)
1. Have a **Model** with multiple parts
2. Set the **PrimaryPart** to the part you want to trigger the jump
3. Add the **Script** inside the Model
4. The script will automatically use the PrimaryPart!

```
Workspace
  └─ SpringPad (Model) [PrimaryPart = Base]
      ├─ Base (Part) ← Players touch this to jump
      ├─ Decoration (Part)
      ├─ Spring (Part)
      └─ Script
```

## 🔧 How to Set PrimaryPart (Optional)

In Roblox Studio:
1. Select your Model in the Explorer
2. In Properties, find **"PrimaryPart"**
3. Set it to the main part players should touch
4. This gives you precise control over which part triggers the jump

## 🧪 Testing

After updating your script:
1. **Stop** the current game session
2. **Update** the script code in your SpringPad
3. **Play** the game again
4. **Walk onto** the part

You should see in the Output:
```
✅ Jump Pad initialized successfully! Using part: [PartName]
```

And you should launch into the air when you step on it!

## ❓ Still Not Working?

If it's still not working, check:

1. **Is the Script a normal Script?** (Not a LocalScript)
2. **Is there actually a Part in the Model?** (Not just other objects)
3. **Does the Output show the success message?**
4. **Is the part properly anchored?** (Set Anchored = true)
5. **Is CanCollide enabled?** (Set CanCollide = true so players touch it)

## 💡 Pro Tip

Make your jump pad more visible:
- Set the Material to "Neon" or "ForceField"
- Give it a bright color like lime green
- Make sure it's at ground level where players walk
- Set Transparency to 0 (fully visible)
