-- ALTERNATIVE EQUIP FUNCTION WITH MANUAL WELDING
-- Replace the equipSword function in MultiSwordSystem.lua with this if automatic EquipTool doesn't work

local function equipSwordManualWeld(character, swordName, config)
	print("[SWORD EQUIP MANUAL] ========================================")
	print("[SWORD EQUIP MANUAL] Starting manual weld equip for:", character.Name, "sword:", swordName)
	
	-- Remove any existing equipped sword
	local existingEquipped = character:FindFirstChild("EquippedSword")
	if existingEquipped then
		print("[SWORD EQUIP MANUAL] Removing existing equipped sword")
		existingEquipped:Destroy()
	end

	-- Find tool template
	local toolTemplate = toolSwordsFolder:FindFirstChild(config.ToolName)
	if not toolTemplate then
		warn("[SWORD EQUIP MANUAL] ❌ Could not find tool:", config.ToolName)
		return
	end
	print("[SWORD EQUIP MANUAL] ✓ Found tool template:", config.ToolName)

	-- Clone tool
	local equippedSword = toolTemplate:Clone()
	equippedSword.Name = "EquippedSword"
	
	-- Get Handle
	local handle = equippedSword:FindFirstChild("Handle")
	if not handle then
		warn("[SWORD EQUIP MANUAL] ❌ No Handle found in tool!")
		return
	end
	print("[SWORD EQUIP MANUAL] ✓ Handle found")
	
	-- Disable collision
	for _, descendant in ipairs(equippedSword:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end
	
	-- Parent to character BEFORE creating weld
	equippedSword.Parent = character
	print("[SWORD EQUIP MANUAL] ✓ Tool parented to character")

	-- Find right arm/hand
	local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand")
	if not rightArm then
		warn("[SWORD EQUIP MANUAL] ❌ No RightArm/RightHand found!")
		return
	end
	print("[SWORD EQUIP MANUAL] ✓ RightArm found:", rightArm.Name)
	
	-- Remove any existing RightGrip
	local existingGrip = rightArm:FindFirstChild("RightGrip")
	if existingGrip then
		existingGrip:Destroy()
		print("[SWORD EQUIP MANUAL] Removed existing RightGrip")
	end
	
	-- Create Motor6D manually
	local motor = Instance.new("Motor6D")
	motor.Name = "RightGrip"
	motor.Part0 = rightArm
	motor.Part1 = handle
	
	-- Set C0 and C1 for proper positioning
	-- C0 is relative to RightArm (the grip point in the hand)
	-- C1 is relative to Handle (where the hand grabs the handle)
	
	-- Standard Roblox Tool grip (right-handed)
	motor.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(90), 0, 0)
	
	-- Check for RightGripAttachment in Handle for custom grip point
	local gripAttachment = handle:FindFirstChild("RightGripAttachment")
	if gripAttachment and gripAttachment:IsA("Attachment") then
		motor.C1 = gripAttachment.CFrame
		print("[SWORD EQUIP MANUAL] ✓ Using RightGripAttachment for C1")
	else
		-- Default: center of handle
		motor.C1 = CFrame.new(0, 0, 0)
		print("[SWORD EQUIP MANUAL] Using default C1 (no RightGripAttachment)")
	end
	
	motor.Parent = rightArm
	
	print("[SWORD EQUIP MANUAL] ✓ Motor6D created and parented!")
	print("[SWORD EQUIP MANUAL]   Part0:", motor.Part0.Name)
	print("[SWORD EQUIP MANUAL]   Part1:", motor.Part1.Name)
	print("[SWORD EQUIP MANUAL]   C0:", motor.C0)
	print("[SWORD EQUIP MANUAL]   C1:", motor.C1)
	print("[SWORD EQUIP MANUAL]   Handle Position:", handle.Position)
	print("[SWORD EQUIP MANUAL] ========================================")

	return equippedSword
end

--[[
INSTRUCTIONS TO USE THIS:

1. In MultiSwordSystem.lua, find the equipSword function (around line 403)

2. Replace this line:
   local function equipSword(character, swordName, config)
   
   With:
   local function equipSwordOLD(character, swordName, config)  -- Rename old one
   
3. Add this new function above it (copy from this file)

4. OR simply replace the contents of equipSword with the code from equipSwordManualWeld

5. The manual weld version will:
   - Create Motor6D manually
   - Set proper C0/C1 offsets
   - Use RightGripAttachment if it exists
   - Position sword correctly in hand
   
This should fix the "sword floating above head" issue!
]]
