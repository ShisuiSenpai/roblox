# 🐛 Premium Crate Debugging Guide

## 🔍 What I Fixed

### Problem:
Premium crate wasn't opening after Robux purchase - animation never played.

### Root Causes Found:
1. **ProcessReceipt was blocking** - Running synchronously instead of in a separate thread
2. **Insufficient wait time** - Only waiting 2 seconds but animation is 5+ seconds
3. **No error handling** - If anything failed, no logs
4. **Missing logging** - Hard to debug what was happening

### Solutions Applied:
1. ✅ **Spawned ProcessReceipt in separate thread** - Returns immediately to Roblox
2. ✅ **Increased wait time to 7 seconds** - Matches animation duration (5s spin + extras)
3. ✅ **Added extensive logging** - Every step now prints to Output
4. ✅ **Added error handling** - pcall wraps everything, errors are caught and logged
5. ✅ **Added validation checks** - Verifies player exists, ProductId configured, etc.

---

## 🧪 How to Test

### Step 1: Configure ProductId
1. Make sure you've set the `ProductId` in `DualCrateSystem.lua` line ~25:
   ```lua
   ProductId = 1234567890, -- YOUR ACTUAL PRODUCT ID
   ```

2. Check Output for this message when server starts:
   ```
   [DUAL CRATE] ✅ Premium Crate configured with ProductId: YOUR_ID
   ```

   ❌ If you see this, ProductId is NOT set:
   ```
   ⚠️ [DUAL CRATE] Premium Crate ProductId not set!
   ```

### Step 2: Test in Studio (Won't Complete Purchase)
1. Play test in Studio
2. Walk up to Premium Crate
3. Press E
4. **Expected:** Robux purchase prompt appears
5. **Expected Output:**
   ```
   [DUAL CRATE] PlayerName initiating PREMIUM crate purchase for 99 Robux
   ```

**NOTE:** In Studio, you CAN'T actually complete the purchase. You need to test in a published game.

### Step 3: Test in Published Game (Real Test)
1. **Publish your game** to Roblox
2. Play the game (NOT in Studio)
3. Make sure you have enough Robux (99 R$)
4. Walk up to Premium Crate
5. Press E → Purchase prompt appears
6. **Complete the purchase**

### Step 4: Watch Output Window
After completing purchase, you should see this sequence:

```
[DUAL CRATE] ProcessReceipt called! ProductId: YOUR_ID PlayerId: YOUR_USER_ID
[DUAL CRATE] ✅ Processing Premium Crate purchase for UserId: YOUR_USER_ID
[DUAL CRATE] Cleared pending purchase for YOUR_USER_ID
[DUAL CRATE] Player PlayerName marked as opening crate
[DUAL CRATE] Using PREMIUM rarities (Legendary/Godly/??? only)
[DUAL CRATE] Selected rarity: Godly from Premium crate (Roll: XX.XX / Total: 100)
[DUAL CRATE] Chosen sword: SwordName
[DUAL CRATE] Chosen sword: SwordName for PlayerName
[DUAL CRATE] Firing animation event to client for PlayerName
[DUAL CRATE] ✅ Animation event fired to PlayerName
[DUAL CRATE] Waiting 7 seconds for animation to complete...
```

**Then on client:**
```
[CRATE CLIENT] ✅ Crate System Client loaded!
(Animation plays - 5 seconds of spinning, then VFX)
```

**Then back on server after 7 seconds:**
```
[DUAL CRATE] Awarding sword to PlayerName
[DUAL CRATE] ✅ PlayerName received (PREMIUM): SwordName
[DUAL CRATE] Player PlayerName unmarked from opening
```

---

## ❌ Troubleshooting

### Issue: "ProcessReceipt called!" never appears
**Problem:** ProcessReceipt is not being called by Roblox
**Causes:**
1. **ProductId doesn't match** - Check that the ProductId in the script matches your Developer Product
2. **Purchase failed** - Player cancelled or didn't have enough Robux
3. **Another script overrides ProcessReceipt** - Check if you have other scripts with `MarketplaceService.ProcessReceipt =`

**Fix:**
- Verify ProductId matches: Go to Creator Dashboard → Your Product → Check ID
- Try purchasing again
- Check Output for: `⚠️ [DUAL CRATE] ProcessReceipt handler was removed!`

### Issue: "Not our product. Expected: X Got: Y"
**Problem:** Wrong ProductId configured
**Fix:**
1. Go to Roblox Creator Dashboard
2. Navigate to your game → Monetization → Developer Products
3. Find your Premium Crate product
4. Copy the correct Product ID
5. Paste it in `DualCrateSystem.lua` line ~25
6. Restart server

### Issue: "Failed to choose sword"
**Problem:** No swords available for the selected rarity
**Fix:**
- Make sure you have at least one Legendary, Godly, and ??? sword in `SwordConfig.lua`

### Issue: Animation plays but sword not awarded
**Problem:** `InventoryManager.addSword` failed
**Check Output for:**
```
[DUAL CRATE] Failed to add sword to PlayerName's inventory!
```

**Fix:**
- Check that `InventoryManager` is loaded (`_G.InventoryManager` exists)
- Check Output for inventory-related errors

### Issue: Player gets stuck (can't open another crate)
**Problem:** `playersOpening` flag not cleared
**Fix:** This is now auto-cleared after 60 seconds if stuck. Check Output for:
```
[DUAL CRATE] Clearing stale pending purchase for PlayerName
```

---

## 📊 Expected Behavior

### Regular Crate (¥250):
1. Walk up → Proximity Prompt shows: `"Regular Relic | ¥250"`
2. Press E → **Instant deduction** of 250 Yen
3. Animation starts immediately (1-2 second delay max)
4. Spins for 5 seconds
5. VFX plays, sword awarded
6. **Drop rates:** Normal (Commons, Uncommons, Rares possible)

### Premium Crate (99 R$):
1. Walk up → Proximity Prompt shows: `"Premium Relic ✨ 2x LUCK | 99 R$"`
2. Press E → **Robux purchase prompt**
3. Complete purchase
4. **1-2 second delay** (ProcessReceipt processing)
5. Animation starts
6. Spins for 5 seconds
7. VFX plays, sword awarded
8. **Drop rates:** Legendary (55%), Godly (40%), ??? (5%) - NO Commons/Uncommons/Rares!

---

## 🚨 Common Mistakes

### 1. Testing in Studio
❌ **Wrong:** "It's not working in Studio!"
✅ **Right:** Test in published game - Studio can't complete Robux purchases

### 2. ProductId = 0
❌ **Wrong:** Leaving ProductId as 0 (default)
✅ **Right:** Set actual Product ID from Creator Dashboard

### 3. Not checking Output
❌ **Wrong:** "It's not working" (no details)
✅ **Right:** Check Output window for detailed logs

### 4. Expecting instant opening
❌ **Wrong:** "Nothing happens after purchase!"
✅ **Right:** Wait 1-2 seconds for ProcessReceipt to process, then animation starts

---

## 💡 Key Points

1. **ProcessReceipt is GLOBAL** - Only ONE script in your entire game can set it
2. **Animation takes time** - 5 seconds spin + VFX, server waits 7 seconds total
3. **Robux purchases are async** - Small delay between purchase and animation
4. **Logging is extensive** - Check Output window for detailed debugging
5. **Premium crate ONLY drops high-tier** - No Commons/Uncommons/Rares ever

---

## 📝 Summary

**What happens when you buy a Premium Crate:**
1. Click Premium Crate → `openPremiumCrate()` called
2. Marks `pendingPurchases[userId] = true`
3. Prompts Robux purchase via `PromptProductPurchase()`
4. Player completes purchase
5. Roblox calls `ProcessReceipt()`
6. Script verifies ProductId matches
7. Chooses random sword (Legendary/Godly/??? only)
8. Fires `OpenCrate` event to client
9. Client plays 5-second animation
10. Server waits 7 seconds
11. Server awards sword to inventory
12. Clears `playersOpening[userId]`
13. Returns `PurchaseGranted` to Roblox

**If any step fails, check Output window for detailed error messages!**

---

## 🆘 Still Not Working?

Copy your **entire Output window** after attempting a purchase and check for:
- Any `[DUAL CRATE]` messages
- Any errors or warnings
- Whether `ProcessReceipt called!` appears
- What step it fails at

This will tell you exactly where the problem is!
