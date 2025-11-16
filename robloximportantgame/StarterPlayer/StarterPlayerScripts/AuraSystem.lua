-- Aura System (Client Script)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts
-- Handles body auras/VFX for specific swords

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

print("[AURA SYSTEM] ========================================")
print("[AURA SYSTEM] Loading Aura System...")
print("[AURA SYSTEM] ========================================")

-- ========================================
-- CONFIGURATION
-- ========================================

local AURA_CONFIG = {
	-- Sword name → VFX model name mapping
	["DawnStar"] = {
		VFXModel = "DawnstarVFX", -- Name of the VFX rig in ReplicatedStorage.Assets.AuraVFX
		FadeInDuration = 0.8, -- How long to fade in (seconds)
		FadeOutDuration = 0.5, -- How long to fade out (seconds)
		Scale = 1.0, -- Size multiplier for particles
	},
	
	-- Add more sword auras here:
	-- ["SwordName"] = {
	-- 	VFXModel = "SwordNameVFX",
	-- 	FadeInDuration = 0.8,
	-- 	FadeOutDuration = 0.5,
	-- 	Scale = 1.0,
	-- },
}

-- ========================================
-- VARIABLES
-- ========================================

local currentAura = nil
local currentSword = nil
local auraFolder = nil
local activeTweens = {}
local lastCheckedSword = nil

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Function to get the VFX model from ReplicatedStorage
local function getVFXModel(vfxName)
	print("[AURA SYSTEM] Looking for VFX model:", vfxName)
	
	local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
	if not assetsFolder then
		warn("[AURA SYSTEM] ❌ Assets folder not found in ReplicatedStorage!")
		return nil
	end
	print("[AURA SYSTEM] ✓ Found Assets folder")
	
	local auraVFXFolder = assetsFolder:FindFirstChild("AuraVFX")
	if not auraVFXFolder then
		warn("[AURA SYSTEM] ❌ AuraVFX folder not found in Assets!")
		print("[AURA SYSTEM] Available folders in Assets:", table.concat(getChildrenNames(assetsFolder), ", "))
		return nil
	end
	print("[AURA SYSTEM] ✓ Found AuraVFX folder")
	
	local vfxModel = auraVFXFolder:FindFirstChild(vfxName)
	if not vfxModel then
		warn("[AURA SYSTEM] ❌ VFX model not found:", vfxName)
		print("[AURA SYSTEM] Available models in AuraVFX:", table.concat(getChildrenNames(auraVFXFolder), ", "))
		return nil
	end
	
	print("[AURA SYSTEM] ✓ Found VFX model:", vfxModel.Name, "- Type:", vfxModel.ClassName)
	print("[AURA SYSTEM] ✓ VFX model has", #vfxModel:GetChildren(), "children")
	
	return vfxModel
end

-- Helper to get children names for debugging
local function getChildrenNames(parent)
	local names = {}
	for _, child in ipairs(parent:GetChildren()) do
		table.insert(names, child.Name)
	end
	return names
end

-- Function to find matching body part in character
local function findMatchingBodyPart(character, vfxPartName)
	-- Try exact match first
	local part = character:FindFirstChild(vfxPartName)
	if part and part:IsA("BasePart") then
		return part
	end
	
	-- Try common name variations
	local nameMap = {
		["Head"] = "Head",
		["Torso"] = "Torso",
		["UpperTorso"] = "UpperTorso",
		["LowerTorso"] = "LowerTorso",
		["LeftArm"] = "LeftArm",
		["LeftUpperArm"] = "LeftUpperArm",
		["LeftLowerArm"] = "LeftLowerArm",
		["LeftHand"] = "LeftHand",
		["RightArm"] = "RightArm",
		["RightUpperArm"] = "RightUpperArm",
		["RightLowerArm"] = "RightLowerArm",
		["RightHand"] = "RightHand",
		["LeftLeg"] = "LeftLeg",
		["LeftUpperLeg"] = "LeftUpperLeg",
		["LeftLowerLeg"] = "LeftLowerLeg",
		["LeftFoot"] = "LeftFoot",
		["RightLeg"] = "RightLeg",
		["RightUpperLeg"] = "RightUpperLeg",
		["RightLowerLeg"] = "RightLowerLeg",
		["RightFoot"] = "RightFoot",
		["HumanoidRootPart"] = "HumanoidRootPart",
	}
	
	local mappedName = nameMap[vfxPartName]
	if mappedName then
		part = character:FindFirstChild(mappedName)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	
	return nil
end

-- Recursive function to process and store original transparency values
local function processEffectTransparency(effect, scale)
	if effect:IsA("ParticleEmitter") then
		-- Store original transparency
		effect:SetAttribute("OriginalTransparency", effect.Transparency)
		
		-- Apply scale to particle size
		if scale ~= 1.0 then
			local keypoints = effect.Size.Keypoints
			local scaledKeypoints = {}
			for i, keypoint in ipairs(keypoints) do
				table.insert(scaledKeypoints, NumberSequenceKeypoint.new(
					keypoint.Time,
					keypoint.Value * scale,
					keypoint.Envelope * scale
				))
			end
			effect.Size = NumberSequence.new(scaledKeypoints)
		end
		
		-- Start fully transparent for fade-in
		effect.Transparency = NumberSequence.new(1)
		
	elseif effect:IsA("Beam") then
		-- Store original transparency
		effect:SetAttribute("OriginalTransparency", effect.Transparency)
		
		-- Start fully transparent for fade-in
		effect.Transparency = NumberSequence.new(1)
	end
end

-- Function to recursively clone ALL VFX from source part to target part
local function cloneAllVFXToBodyPart(sourcePart, targetPart, scale)
	local clonedObjects = {}
	
	print("[AURA SYSTEM]   Scanning", sourcePart.Name, "for VFX...")
	print("[AURA SYSTEM]   Source part has", #sourcePart:GetDescendants(), "total descendants")
	
	-- Go through ALL descendants recursively
	for _, descendant in ipairs(sourcePart:GetDescendants()) do
		local clonedObject = nil
		
		-- Clone Attachments (with all their children)
		if descendant:IsA("Attachment") then
			-- Only clone if it's a direct child of the source part
			-- (nested attachments will be cloned with their parent)
			if descendant.Parent == sourcePart then
				clonedObject = descendant:Clone()
				clonedObject.Parent = targetPart
				
				print("[AURA SYSTEM]     → Cloned Attachment:", descendant.Name, "with", #clonedObject:GetDescendants(), "children")
				
				-- Process all effects inside this attachment
				for _, effect in ipairs(clonedObject:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
						print("[AURA SYSTEM]       → Processing", effect.ClassName, "inside attachment")
						processEffectTransparency(effect, scale)
					end
				end
				
				table.insert(clonedObjects, clonedObject)
			end
			
		-- Clone ParticleEmitters (direct children only, as nested ones come with attachments)
		elseif descendant:IsA("ParticleEmitter") then
			if descendant.Parent == sourcePart then
				clonedObject = descendant:Clone()
				clonedObject.Parent = targetPart
				
				print("[AURA SYSTEM]     → Cloned ParticleEmitter:", descendant.Name)
				
				processEffectTransparency(clonedObject, scale)
				table.insert(clonedObjects, clonedObject)
			end
			
		-- Clone Beams
		elseif descendant:IsA("Beam") then
			if descendant.Parent == sourcePart then
				clonedObject = descendant:Clone()
				clonedObject.Parent = targetPart
				
				print("[AURA SYSTEM]     → Cloned Beam:", descendant.Name)
				
				processEffectTransparency(clonedObject, scale)
				table.insert(clonedObjects, clonedObject)
			end
			
		-- Clone PointLights, SpotLights, SurfaceLights
		elseif descendant:IsA("Light") then
			if descendant.Parent == sourcePart then
				clonedObject = descendant:Clone()
				clonedObject.Parent = targetPart
				
				print("[AURA SYSTEM]     → Cloned Light:", descendant.Name)
				table.insert(clonedObjects, clonedObject)
			end
		end
	end
	
	print("[AURA SYSTEM]   ✅ Cloned", #clonedObjects, "objects from", sourcePart.Name)
	
	return clonedObjects
end

-- Function to fade in aura effects
local function fadeInAura(duration)
	-- Cancel any active tweens
	for _, tween in ipairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
	
	if not auraFolder then return end
	
	-- Collect all emitters and beams from character
	local effects = {}
	for _, bodyPart in ipairs(character:GetChildren()) do
		if bodyPart:IsA("BasePart") then
			for _, descendant in ipairs(bodyPart:GetDescendants()) do
				if (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) and 
				   descendant:GetAttribute("OriginalTransparency") then
					table.insert(effects, descendant)
				end
			end
		end
	end
	
	print("[AURA SYSTEM] Found", #effects, "effects to fade in")
	
	-- Fade in each effect
	for _, effect in ipairs(effects) do
		local originalTransparency = effect:GetAttribute("OriginalTransparency")
		if originalTransparency then
			-- Create tween
			local tweenInfo = TweenInfo.new(
				duration,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.Out
			)
			
			local tween = TweenService:Create(effect, tweenInfo, {
				Transparency = originalTransparency
			})
			
			table.insert(activeTweens, tween)
			tween:Play()
		end
	end
	
	print("[AURA SYSTEM] ✨ Fading in aura over", duration, "seconds")
end

-- Function to fade out aura effects
local function fadeOutAura(duration)
	-- Cancel any active tweens
	for _, tween in ipairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
	
	if not auraFolder then return end
	
	-- Collect all emitters and beams from character
	local effects = {}
	for _, bodyPart in ipairs(character:GetChildren()) do
		if bodyPart:IsA("BasePart") then
			for _, descendant in ipairs(bodyPart:GetDescendants()) do
				if (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam")) and 
				   descendant:GetAttribute("OriginalTransparency") then
					table.insert(effects, descendant)
				end
			end
		end
	end
	
	-- Fade out
	local completedCount = 0
	for _, effect in ipairs(effects) do
		local tweenInfo = TweenInfo.new(
			duration,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.In
		)
		
		local tween = TweenService:Create(effect, tweenInfo, {
			Transparency = NumberSequence.new(1)
		})
		
		table.insert(activeTweens, tween)
		
		-- Track completion
		tween.Completed:Connect(function()
			completedCount = completedCount + 1
			if completedCount == #effects then
				-- All effects faded out, clean up
				removeAura()
			end
		end)
		
		tween:Play()
	end
	
	print("[AURA SYSTEM] Fading out aura over", duration, "seconds")
end

-- ========================================
-- MAIN FUNCTIONS
-- ========================================

-- Function to apply aura to character
local function applyAura(swordName)
	-- Check if this sword has an aura config
	local auraConfig = AURA_CONFIG[swordName]
	if not auraConfig then
		print("[AURA SYSTEM] No aura config for sword:", swordName)
		return -- No aura for this sword
	end
	
	-- Remove existing aura first
	if currentAura then
		print("[AURA SYSTEM] Removing existing aura:", currentAura)
		removeAura()
	end
	
	print("[AURA SYSTEM] ========================================")
	print("[AURA SYSTEM] 🌟 Applying aura for sword:", swordName)
	print("[AURA SYSTEM] ========================================")
	
	-- Get VFX model
	local vfxModel = getVFXModel(auraConfig.VFXModel)
	if not vfxModel then
		warn("[AURA SYSTEM] ❌ Failed to get VFX model for", swordName)
		return
	end
	
	print("[AURA SYSTEM] VFX Model Structure:")
	for _, child in ipairs(vfxModel:GetChildren()) do
		if child:IsA("BasePart") then
			print("[AURA SYSTEM]   -", child.Name, "→", #child:GetDescendants(), "descendants")
		end
	end
	
	-- Create folder to hold references to all aura effects
	auraFolder = Instance.new("Folder")
	auraFolder.Name = "AuraEffects_" .. swordName
	auraFolder.Parent = character
	
	-- Apply VFX from each body part in the VFX model to the matching character body part
	local totalEffectsApplied = 0
	local bodyPartsProcessed = 0
	local bodyPartsMatched = 0
	
	for _, sourcePart in ipairs(vfxModel:GetChildren()) do
		if sourcePart:IsA("BasePart") then
			bodyPartsProcessed = bodyPartsProcessed + 1
			print("[AURA SYSTEM] Processing VFX body part:", sourcePart.Name)
			
			local targetPart = findMatchingBodyPart(character, sourcePart.Name)
			if targetPart then
				bodyPartsMatched = bodyPartsMatched + 1
				print("[AURA SYSTEM] ✓ Matched to character part:", targetPart.Name)
				
				-- Clone ALL VFX from this source part to the target part
				local clonedObjects = cloneAllVFXToBodyPart(sourcePart, targetPart, auraConfig.Scale)
				
				-- Track these objects in aura folder
				for _, obj in ipairs(clonedObjects) do
					-- Create a reference object to track this for cleanup
					local ref = Instance.new("ObjectValue")
					ref.Name = "VFXRef_" .. obj.Name
					ref.Value = obj
					ref.Parent = auraFolder
				end
				
				totalEffectsApplied = totalEffectsApplied + #clonedObjects
			else
				warn("[AURA SYSTEM] ❌ Could not find matching body part for:", sourcePart.Name)
			end
		end
	end
	
	print("[AURA SYSTEM] ========================================")
	print("[AURA SYSTEM] Summary:")
	print("[AURA SYSTEM]   Body parts in VFX model:", bodyPartsProcessed)
	print("[AURA SYSTEM]   Body parts matched:", bodyPartsMatched)
	print("[AURA SYSTEM]   Total effects applied:", totalEffectsApplied)
	print("[AURA SYSTEM] ========================================")
	
	if totalEffectsApplied > 0 then
		currentAura = swordName
		currentSword = swordName
		
		-- Fade in the aura
		fadeInAura(auraConfig.FadeInDuration)
		
		print("[AURA SYSTEM] ✅ Successfully applied aura to character!")
	else
		-- No effects applied, clean up
		if auraFolder then
			auraFolder:Destroy()
			auraFolder = nil
		end
		warn("[AURA SYSTEM] ❌ No effects were applied! Check your VFX model structure.")
	end
end

-- Function to remove aura from character
function removeAura()
	if not auraFolder then return end
	
	print("[AURA SYSTEM] Removing aura...")
	
	-- Cancel any active tweens
	for _, tween in ipairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
	
	-- Destroy all tracked VFX objects
	for _, ref in ipairs(auraFolder:GetChildren()) do
		if ref:IsA("ObjectValue") and ref.Value then
			ref.Value:Destroy()
		end
	end
	
	-- Destroy aura folder
	auraFolder:Destroy()
	auraFolder = nil
	currentAura = nil
	
	print("[AURA SYSTEM] ✅ Aura removed")
end

-- Function to handle sword equipped
local function onSwordEquipped(swordName)
	if swordName == currentSword then
		return -- Already has this aura
	end
	
	print("[AURA SYSTEM] 🗡️ Sword changed to:", swordName)
	
	-- Check if this sword has an aura
	if AURA_CONFIG[swordName] then
		print("[AURA SYSTEM] ✓ This sword has an aura configuration!")
		
		-- Fade out old aura if exists
		if currentAura then
			local oldConfig = AURA_CONFIG[currentAura]
			if oldConfig then
				fadeOutAura(oldConfig.FadeOutDuration)
			else
				removeAura()
			end
			
			-- Wait for fade out before applying new aura
			task.wait(oldConfig and oldConfig.FadeOutDuration or 0.5)
		end
		
		-- Apply new aura
		applyAura(swordName)
	else
		print("[AURA SYSTEM] ✗ No aura configured for this sword")
		
		-- Sword has no aura, remove existing aura
		if currentAura then
			local oldConfig = AURA_CONFIG[currentAura]
			if oldConfig then
				fadeOutAura(oldConfig.FadeOutDuration)
			else
				removeAura()
			end
		end
		
		currentSword = swordName
	end
end

-- ========================================
-- INITIALIZATION
-- ========================================

-- Function to check current sword from MultiSwordSystem
local function checkCurrentSword()
	local currentSwordName = _G.CurrentSwordName
	
	if currentSwordName and currentSwordName ~= lastCheckedSword then
		lastCheckedSword = currentSwordName
		onSwordEquipped(currentSwordName)
	end
end

-- Listen for character respawn
local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	
	-- Remove any existing aura
	removeAura()
	lastCheckedSword = nil
	
	print("[AURA SYSTEM] Character respawned - ready for new auras")
end

-- Handle character respawn
player.CharacterAdded:Connect(onCharacterAdded)

-- Poll for sword changes
RunService.Heartbeat:Connect(function()
	checkCurrentSword()
end)

-- Initial check
task.wait(1) -- Wait for sword system to initialize
checkCurrentSword()

print("[AURA SYSTEM] ========================================")
print("[AURA SYSTEM] ✅ Aura System Ready!")
print("[AURA SYSTEM] ========================================")
print("[AURA SYSTEM] Configured auras:")
for swordName, config in pairs(AURA_CONFIG) do
	print("[AURA SYSTEM]   -", swordName, "→", config.VFXModel)
end
print("[AURA SYSTEM] ========================================")
print("[AURA SYSTEM] Watching _G.CurrentSwordName for changes...")
print("[AURA SYSTEM] ========================================")
