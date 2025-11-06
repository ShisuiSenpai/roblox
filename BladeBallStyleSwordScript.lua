--[[
	BLADE BALL STYLE SWORD SYSTEM
	Place this LocalScript in StarterPlayerScripts or StarterCharacterScripts
	
	Features:
	- Sword stays holstered on your character at all times
	- Click (M1) to temporarily equip and attack
	- Sword returns to holster after attack animation
	- Tool should be in ReplicatedStorage
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local mouse = player:GetMouse()

-- Disable the hotbar/inventory UI
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- References to your models
local holsteredSwordTemplate = ReplicatedStorage:WaitForChild("HolsteredSword")
local swordTool = ReplicatedStorage:WaitForChild("Sword")

-- ========================================
-- CUSTOMIZATION SETTINGS
-- ========================================

local HOLSTER_SETTINGS = {
	-- Which body part to attach the holstered sword to
	AttachmentPart = "Torso",
	
	-- Position offset from the attachment part (X, Y, Z)
	PositionOffset = Vector3.new(1, -1.2, 0.7),
	
	-- Rotation in degrees (X, Y, Z)
	RotationOffset = Vector3.new(0, 90, 110),
	
	-- Visual settings
	TransparencyValue = 0, -- 0 = visible when holstered
}

local ATTACK_SETTINGS = {
	-- How long the sword stays in hand during attack (seconds)
	AttackDuration = 0.3,
	
	-- Animation ID (replace with your sword slash animation)
	AnimationId = "rbxassetid://0", -- Replace 0 with your animation ID
	
	-- Cooldown between attacks (seconds)
	AttackCooldown = 0.4,
	
	-- Damage settings (if you want to implement damage)
	Damage = 10,
	AttackRange = 10,
}

-- ========================================
-- SCRIPT
-- ========================================

local holsteredSword = nil
local holsterWeld = nil
local attackSword = nil
local isAttacking = false
local canAttack = true

-- Function to set transparency of a model
local function setModelTransparency(model, transparency)
	if not model then return end
	
	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = transparency
		end
	end
end

-- Function to get the correct body part for attachment
local function getAttachmentPart()
	local attachPart = character:FindFirstChild(HOLSTER_SETTINGS.AttachmentPart)
	
	-- Fallback to Torso if the specified part doesn't exist
	if not attachPart then
		attachPart = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	end
	
	return attachPart
end

-- Function to create the holstered sword (always visible)
local function createHolsteredSword()
	if holsteredSword then return end
	
	local attachPart = getAttachmentPart()
	if not attachPart then 
		warn("Could not find attachment part for holster")
		return 
	end
	
	-- Clone the HolsteredSword model from ReplicatedStorage
	holsteredSword = holsteredSwordTemplate:Clone()
	
	-- Find the main sword part to weld
	local swordPart = holsteredSword:FindFirstChild("Sword")
	if not swordPart then
		warn("Could not find 'Sword' part in HolsteredSword model!")
		holsteredSword:Destroy()
		holsteredSword = nil
		return
	end
	
	-- Make all parts non-collidable and massless
	for _, descendant in pairs(holsteredSword:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Massless = true
		end
	end
	
	-- Create weld to attach holstered sword to body part
	holsterWeld = Instance.new("Weld")
	holsterWeld.Name = "HolsterWeld"
	holsterWeld.Part0 = attachPart
	holsterWeld.Part1 = swordPart
	
	-- Apply position and rotation offsets
	local rotationCFrame = CFrame.Angles(
		math.rad(HOLSTER_SETTINGS.RotationOffset.X),
		math.rad(HOLSTER_SETTINGS.RotationOffset.Y),
		math.rad(HOLSTER_SETTINGS.RotationOffset.Z)
	)
	
	holsterWeld.C0 = CFrame.new(HOLSTER_SETTINGS.PositionOffset) * rotationCFrame
	holsterWeld.Parent = swordPart
	
	holsteredSword.Parent = character
	
	-- Set visibility
	setModelTransparency(holsteredSword, HOLSTER_SETTINGS.TransparencyValue)
end

-- Function to hide holstered sword during attack
local function hideHolster()
	if holsteredSword then
		setModelTransparency(holsteredSword, 1) -- Make invisible
	end
end

-- Function to show holstered sword after attack
local function showHolster()
	if holsteredSword then
		setModelTransparency(holsteredSword, HOLSTER_SETTINGS.TransparencyValue)
	end
end

-- Function to cleanup holstered sword
local function cleanupHolster()
	if holsteredSword then
		holsteredSword:Destroy()
		holsteredSword = nil
		holsterWeld = nil
	end
end

-- Function to perform attack
local function performAttack()
	if not canAttack or isAttacking then return end
	
	canAttack = false
	isAttacking = true
	
	-- Hide holstered sword
	hideHolster()
	
	-- Clone the sword tool and equip it temporarily
	attackSword = swordTool:Clone()
	attackSword.Parent = character
	
	-- Equip the sword (simulates equipping to hand)
	humanoid:EquipTool(attackSword)
	
	-- Load and play attack animation if provided
	if ATTACK_SETTINGS.AnimationId ~= "rbxassetid://0" then
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local animation = Instance.new("Animation")
			animation.AnimationId = ATTACK_SETTINGS.AnimationId
			local animTrack = animator:LoadAnimation(animation)
			animTrack:Play()
		end
	end
	
	-- Wait for attack duration
	task.wait(ATTACK_SETTINGS.AttackDuration)
	
	-- Remove attack sword
	if attackSword then
		attackSword:Destroy()
		attackSword = nil
	end
	
	-- Show holstered sword again
	showHolster()
	
	isAttacking = false
	
	-- Cooldown
	task.wait(ATTACK_SETTINGS.AttackCooldown)
	canAttack = true
end

-- Mouse click handler
mouse.Button1Down:Connect(function()
	performAttack()
end)

-- Alternative: UserInputService for more control
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		-- Already handled by mouse.Button1Down
		-- You can use this instead if you remove the mouse handler above
	end
end)

-- Cleanup on character death
humanoid.Died:Connect(function()
	cleanupHolster()
	if attackSword then
		attackSword:Destroy()
		attackSword = nil
	end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	cleanupHolster()
	task.wait(0.5) -- Wait for character to fully load
	createHolsteredSword()
	
	humanoid.Died:Connect(function()
		cleanupHolster()
		if attackSword then
			attackSword:Destroy()
			attackSword = nil
		end
	end)
end)

-- Initialize
createHolsteredSword()
