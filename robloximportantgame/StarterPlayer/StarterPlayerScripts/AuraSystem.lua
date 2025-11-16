-- Aura System (Client Script)
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts
-- Handles body auras/VFX for specific swords

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

print("[AURA SYSTEM] Loading...")

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

-- ========================================
-- HELPER FUNCTIONS
-- ========================================

-- Function to get the VFX model from ReplicatedStorage
local function getVFXModel(vfxName)
	local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
	if not assetsFolder then
		warn("[AURA SYSTEM] Assets folder not found in ReplicatedStorage!")
		return nil
	end
	
	local auraVFXFolder = assetsFolder:FindFirstChild("AuraVFX")
	if not auraVFXFolder then
		warn("[AURA SYSTEM] AuraVFX folder not found in Assets!")
		return nil
	end
	
	local vfxModel = auraVFXFolder:FindFirstChild(vfxName)
	if not vfxModel then
		warn("[AURA SYSTEM] VFX model not found:", vfxName)
		return nil
	end
	
	return vfxModel
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

-- Function to clone VFX from source part to target part
local function cloneVFXToBodyPart(sourcePart, targetPart, scale)
	local clonedObjects = {}
	
	-- Clone attachments with their ParticleEmitters
	for _, child in ipairs(sourcePart:GetChildren()) do
		if child:IsA("Attachment") then
			local attachmentClone = child:Clone()
			attachmentClone.Parent = targetPart
			table.insert(clonedObjects, attachmentClone)
			
			-- Set initial transparency for fade-in
			for _, emitter in ipairs(attachmentClone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					-- Store original transparency
					emitter:SetAttribute("OriginalTransparency", emitter.Transparency)
					
					-- Apply scale
					if scale ~= 1.0 then
						emitter.Size = NumberSequence.new(
							emitter.Size.Keypoints[1].Value * scale,
							emitter.Size.Keypoints[#emitter.Size.Keypoints].Value * scale
						)
					end
					
					-- Start fully transparent
					emitter.Transparency = NumberSequence.new(1)
				end
			end
		end
		
		-- Clone ParticleEmitters directly in the part
		if child:IsA("ParticleEmitter") then
			local emitterClone = child:Clone()
			emitterClone.Parent = targetPart
			table.insert(clonedObjects, emitterClone)
			
			-- Store original transparency
			emitterClone:SetAttribute("OriginalTransparency", emitterClone.Transparency)
			
			-- Apply scale
			if scale ~= 1.0 then
				emitterClone.Size = NumberSequence.new(
					emitterClone.Size.Keypoints[1].Value * scale,
					emitterClone.Size.Keypoints[#emitterClone.Size.Keypoints].Value * scale
				)
			end
			
			-- Start fully transparent
			emitterClone.Transparency = NumberSequence.new(1)
		end
		
		-- Clone Beams
		if child:IsA("Beam") then
			local beamClone = child:Clone()
			beamClone.Parent = targetPart
			table.insert(clonedObjects, beamClone)
			
			-- Store original transparency
			beamClone:SetAttribute("OriginalTransparency", beamClone.Transparency)
			
			-- Start fully transparent
			beamClone.Transparency = NumberSequence.new(1)
		end
	end
	
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
	
	-- Collect all emitters and beams
	local effects = {}
	for _, descendant in ipairs(auraFolder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
			table.insert(effects, descendant)
		end
	end
	
	-- Fade in
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
	
	print("[AURA SYSTEM] Fading in aura over", duration, "seconds")
end

-- Function to fade out aura effects
local function fadeOutAura(duration)
	-- Cancel any active tweens
	for _, tween in ipairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
	
	if not auraFolder then return end
	
	-- Collect all emitters and beams
	local effects = {}
	for _, descendant in ipairs(auraFolder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") then
			table.insert(effects, descendant)
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
		return -- No aura for this sword
	end
	
	-- Remove existing aura first
	if currentAura then
		removeAura()
	end
	
	print("[AURA SYSTEM] Applying aura for sword:", swordName)
	
	-- Get VFX model
	local vfxModel = getVFXModel(auraConfig.VFXModel)
	if not vfxModel then
		warn("[AURA SYSTEM] Failed to get VFX model for", swordName)
		return
	end
	
	-- Create folder to hold all aura effects
	auraFolder = Instance.new("Folder")
	auraFolder.Name = "AuraEffects_" .. swordName
	auraFolder.Parent = character
	
	-- Apply VFX to each matching body part
	local effectsApplied = 0
	for _, sourcePart in ipairs(vfxModel:GetChildren()) do
		if sourcePart:IsA("BasePart") then
			local targetPart = findMatchingBodyPart(character, sourcePart.Name)
			if targetPart then
				local clonedObjects = cloneVFXToBodyPart(sourcePart, targetPart, auraConfig.Scale)
				
				-- Parent cloned objects to aura folder for easy cleanup
				for _, obj in ipairs(clonedObjects) do
					obj.Parent = auraFolder
					-- But keep the visual parent as the body part
					if obj:IsA("Attachment") then
						obj.Parent = targetPart
					elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
						obj.Parent = targetPart
					end
				end
				
				effectsApplied = effectsApplied + #clonedObjects
			else
				warn("[AURA SYSTEM] Could not find matching body part for:", sourcePart.Name)
			end
		end
	end
	
	if effectsApplied > 0 then
		currentAura = swordName
		currentSword = swordName
		
		-- Fade in the aura
		fadeInAura(auraConfig.FadeInDuration)
		
		print("[AURA SYSTEM] ✅ Applied", effectsApplied, "effects to character")
	else
		-- No effects applied, clean up
		if auraFolder then
			auraFolder:Destroy()
			auraFolder = nil
		end
		warn("[AURA SYSTEM] No effects were applied!")
	end
end

-- Function to remove aura from character
function removeAura()
	if not auraFolder then return end
	
	print("[AURA SYSTEM] Removing aura")
	
	-- Cancel any active tweens
	for _, tween in ipairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
	
	-- Destroy aura folder and all effects
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
	
	print("[AURA SYSTEM] Sword equipped:", swordName)
	
	-- Check if this sword has an aura
	if AURA_CONFIG[swordName] then
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

-- Listen for sword changes
-- The MultiSwordSystem should expose the current sword somehow
-- Let's check for tool equipped in character

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	
	-- Remove any existing aura
	removeAura()
	
	-- Listen for tools equipped
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			onSwordEquipped(child.Name)
		end
	end)
	
	-- Listen for tools unequipped
	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") and child.Name == currentSword then
			-- Sword unequipped, remove aura
			if currentAura then
				local auraConfig = AURA_CONFIG[currentAura]
				if auraConfig then
					fadeOutAura(auraConfig.FadeOutDuration)
				else
					removeAura()
				end
			end
			currentSword = nil
		end
	end)
	
	-- Check if already holding a tool
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			onSwordEquipped(child.Name)
			break
		end
	end
end

-- Handle character respawn
player.CharacterAdded:Connect(onCharacterAdded)
onCharacterAdded(character)

print("[AURA SYSTEM] ✅ Ready! Listening for sword changes...")

-- List configured auras
local configuredSwords = {}
for swordName, _ in pairs(AURA_CONFIG) do
	table.insert(configuredSwords, swordName)
end
print("[AURA SYSTEM] Configured auras for:", table.concat(configuredSwords, ", "))
