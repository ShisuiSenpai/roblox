# 🔧 Sword Positioning Debug Guide

## 🐛 Problem Description

When attacking, the server-side sword appears in the **wrong position** (e.g., above the player's head) instead of in their hand. This happens when:
- Other players watch you attack
- The sword briefly appears in incorrect position
- It looks "floaty" or misaligned

## 🔍 Root Causes

### **Cause #1: Missing Handle**
The Tool must have a child named **"Handle"** (exact name, case-sensitive).
- Without it, Roblox doesn't know what part to weld to the hand
- The tool will appear at world origin or character's HumanoidRootPart

### **Cause #2: Missing/Wrong RightGripAttachment**
The Handle should have a **RightGripAttachment** (Attachment instance).
- Defines WHERE on the handle the hand grabs
- Without it, Roblox uses Handle's center (often wrong for swords)
- Wrong CFrame = sword points in wrong direction

### **Cause #3: Motor6D Not Creating**
`Humanoid:EquipTool()` should automatically create a Motor6D named "RightGrip".
- Sometimes fails due to timing issues
- Sometimes fails if Handle is anchored
- Sometimes fails if Tool properties are wrong

### **Cause #4: Wrong C0/C1 Offsets**
The Motor6D uses C0 (hand offset) and C1 (handle offset):
- Wrong offsets = sword in wrong position/rotation
- Need to match the RightGripAttachment CFrame

## 🛠️ Debugging Steps

### **Step 1: Test With Debugging**

I've added extensive debugging to `MultiSwordSystem.lua`. When you attack, check the **Server Output** for:

```
[SWORD EQUIP] ========================================
[SWORD EQUIP] Starting equip for: PlayerName sword: DawnStar
[SWORD EQUIP] ✓ Found tool template: DawnStar_Tool
[SWORD EQUIP] ✓ Handle found: Handle
[SWORD EQUIP]   Handle CFrame: ...
[SWORD EQUIP]   Handle Size: ...
[SWORD EQUIP] ✓ RightGripAttachment found  <-- IMPORTANT!
[SWORD EQUIP] ✓ Tool parented to character
[SWORD EQUIP] ✓ Humanoid and RightArm found
[SWORD EQUIP]   RightArm name: Right Arm
[SWORD EQUIP] ✓ Tool equipped via Humanoid:EquipTool()
[SWORD EQUIP] ✓ RightGrip Motor6D created successfully!  <-- IMPORTANT!
[SWORD EQUIP]   Part0: Right Arm
[SWORD EQUIP]   Part1: Handle
[SWORD EQUIP]   C0: ...
[SWORD EQUIP]   C1: ...
[SWORD EQUIP]   Final Handle Position: ...
[SWORD EQUIP] ========================================
```

### **Step 2: Check For Errors**

Look for these warning messages:

#### ❌ **"No Handle found in tool!"**
**Problem:** Your tool doesn't have a "Handle" part  
**Solution:** 
1. Go to `ReplicatedStorage.ToolSwords` → Find your sword tool
2. Make sure there's a part named **exactly** "Handle" (case-sensitive)
3. This part will be welded to the player's hand

#### ❌ **"No RightGripAttachment found in Handle!"**
**Problem:** Handle doesn't have proper grip attachment  
**Solution:**
1. Select the Handle part
2. Insert → Attachment
3. Name it **"RightGripAttachment"** (exact name)
4. Adjust its CFrame/rotation so the sword points correctly when held
   - Use Studio's Move/Rotate tools on the attachment
   - The attachment's "Forward" axis should point along the blade
   - The attachment's "Up" axis should point toward the handle's "back"

#### ❌ **"RightGrip Motor6D NOT found!"**
**Problem:** Motor6D didn't get created by EquipTool  
**Solution:** Use manual welding (see Step 3 below)

### **Step 3: Try Manual Welding**

If automatic `Humanoid:EquipTool()` doesn't work, use manual welding:

1. **Open** `ServerScriptService/MultiSwordSystem_ManualWeld.lua`
2. **Copy** the `equipSwordManualWeld` function
3. **Replace** the `equipSword` function in `MultiSwordSystem.lua` with it
4. **Test** - the sword should now position correctly

The manual weld function:
- Creates Motor6D explicitly
- Sets C0/C1 with proper offsets
- Uses RightGripAttachment if available
- More reliable than EquipTool

## 📋 Quick Fixes

### **Fix #1: Verify Tool Structure**

Your tool in `ReplicatedStorage.ToolSwords` should look like:

```
DawnStar_Tool (Tool)
├── Handle (Part)  ← REQUIRED, exact name
│   ├── RightGripAttachment (Attachment)  ← REQUIRED for proper grip
│   ├── Mesh or MeshPart
│   ├── ParticleEmitters (optional)
│   └── Other decorative parts (welded to Handle)
└── Other parts (optional, welded to Handle)
```

### **Fix #2: Check Handle Properties**

The Handle part should have:
- ✅ **Name:** "Handle" (exact, case-sensitive)
- ✅ **Anchored:** false (MUST be unanchored!)
- ✅ **CanCollide:** false (recommended)
- ✅ **Contains RightGripAttachment:** Yes

### **Fix #3: Check RightGripAttachment**

The RightGripAttachment should:
- ✅ **Parent:** Handle part
- ✅ **Name:** "RightGripAttachment" (exact)
- ✅ **Type:** Attachment (not Part or anything else)
- ✅ **CFrame:** Adjusted so sword looks natural in hand

**How to adjust:**
1. Select RightGripAttachment
2. Use Studio's Rotate tool
3. Preview by equipping tool on a test dummy
4. Adjust until sword looks good in hand

### **Fix #4: Verify R6 vs R15**

Your game uses R6 or R15 rigs:

**R6 Bodies:**
- Right arm part: "Right Arm"

**R15 Bodies:**
- Right hand part: "RightHand"
- Right lower arm: "RightLowerArm"

The debug script checks for both, but verify your character type.

## 🎯 Common Issues & Solutions

### **Issue: Sword appears at (0, 0, 0) world position**
**Cause:** No Handle part  
**Fix:** Add Handle part to tool

### **Issue: Sword floats above character's head**
**Cause:** Handle is anchored OR Motor6D not creating  
**Fix:** 
1. Unanchor Handle
2. Use manual welding if EquipTool fails

### **Issue: Sword points in wrong direction**
**Cause:** RightGripAttachment rotation is wrong  
**Fix:** 
1. Adjust RightGripAttachment's Orientation
2. Common fix: Rotate 90 degrees around X or Y axis

### **Issue: Sword is offset to the side**
**Cause:** RightGripAttachment position is wrong  
**Fix:**
1. Adjust RightGripAttachment's Position
2. Should typically be near the handle's "grip point"

### **Issue: Motor6D creates but sword still wrong position**
**Cause:** C1 offset doesn't match RightGripAttachment  
**Fix:** Manual welding reads RightGripAttachment correctly

## 🔬 Advanced Debugging

### **Check C0 and C1 Values**

In the debug output, look at C0 and C1:

```
[SWORD EQUIP]   C0: 0, -1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0
[SWORD EQUIP]   C1: 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1
```

**C0 (Hand Offset):**
- Relative to Right Arm
- Standard Roblox: `CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(90), 0, 0)`
- Positions grip at bottom of right arm, rotated 90°

**C1 (Handle Offset):**
- Relative to Handle
- Should match RightGripAttachment.CFrame
- `CFrame.new(0, 0, 0)` = center of handle

### **Visual Test in Studio**

1. **Play** your game in Studio
2. **Attack** with sword
3. **Pause** game (press F5 or pause button)
4. **Select** the character model in Explorer
5. **Expand** → Right Arm → RightGrip (Motor6D)
6. **Check** Part0, Part1, C0, C1 properties
7. **Manually adjust** C0/C1 values in Properties to test

## 🚀 Recommended Solution

**Use Manual Welding:**
1. It's more reliable
2. Handles edge cases better
3. Direct control over positioning
4. Works on all rig types

**Steps:**
1. Test with current debugging first (see what's wrong)
2. If Motor6D not creating OR position is wrong:
   - Use `MultiSwordSystem_ManualWeld.lua`
   - Replace `equipSword` function
3. Make sure all tools have proper Handle + RightGripAttachment
4. Done!

---

## 📝 Summary

**Most Common Fix:**
1. ✅ Ensure Handle part exists and is named exactly "Handle"
2. ✅ Ensure Handle is **not anchored**
3. ✅ Add RightGripAttachment to Handle
4. ✅ Adjust RightGripAttachment rotation/position
5. ✅ Use manual welding if EquipTool fails

**After fixing, you should see:**
- ✅ Sword in player's hand when attacking
- ✅ Correct rotation and position
- ✅ Smooth animation
- ✅ Looks the same on client and server (for the attacker)

Run your game with the new debugging, send me the Server Output, and I'll tell you exactly what's wrong! 🔍
