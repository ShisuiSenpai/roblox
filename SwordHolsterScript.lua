--[[
	SWORD HOLSTERING SYSTEM
	Place this LocalScript inside your Sword Tool
	
	Features:
	- Uses your custom HolsteredSword model from ReplicatedStorage
	- Smoothly toggles between holstered and equipped states
	- Fully customizable positioning and attachment points
	- Works with both R6 and R15 rigs
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

-- Reference to the holstered sword model in ReplicatedStorage
local holsteredSwordTemplate = ReplicatedStorage:WaitForChild("HolsteredSword")

-- ========================================
-- CUSTOMIZATION SETTINGS
-- ========================================

local HOLSTER_SETTINGS = {
	-- Which body part to attach the holstered sword to
	-- R15 options: "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm"
	-- R6 options: "Torso"
	AttachmentPart = "UpperTorso", -- Change this to your preferred body part
	
	-- Position offset from the attachment part (X, Y, Z)
	-- Tweak these values to move the sword around your body
	PositionOffset = Vector3.new(0, -0.7, -0.5),
	
	-- Rotation in degrees (X, Y, Z)
	-- Based on your manual positioning: CFrame Orientation (0, 90, 110)
	RotationOffset = Vector3.new(0, 90, 110),
	
	-- Visual settings
	UseTransparency = true, -- If true, uses transparency. If false, completely removes/creates the holster
	TransparencyValue = 0, -- 0 = visible when holstered, 1 = invisible
	
	-- Animation settings
	FadeSpeed = 0.1, -- How fast to fade in/out (only used if UseTransparency is true)
}

-- ========================================
-- SCRIPT (Don't modify unless you know what you're doing)
-- ========================================

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local holsteredSword = nil
local holsterWeld = nil
local isEquipped = false

-- Function to set transparency of holstered sword
local function setHolsterTransparency(targetTransparency)
	if not holsteredSword then return end
	
	for _, descendant in pairs(holsteredSword:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = targetTransparency
		end
	end
end

-- Function to get the correct body part for attachment (R6 vs R15)
local function getAttachmentPart()
	local attachPart = character:FindFirstChild(HOLSTER_SETTINGS.AttachmentPart)
	
	-- Fallback to Torso if the specified part doesn't exist (R6 compatibility)
	if not attachPart then
		attachPart = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	end
	
	return attachPart
end

-- Function to create the holstered sword
local function createHolsteredSword()
	if holsteredSword then return end
	
	local attachPart = getAttachmentPart()
	if not attachPart then 
		warn("Could not find attachment part for holster")
		return 
	end
	
	-- Clone the HolsteredSword model from ReplicatedStorage
	holsteredSword = holsteredSwordTemplate:Clone()
	
	-- Find the main sword part to weld (the "Sword" part inside the model)
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
	holsterWeld.Part1 = swordPart  -- Weld to the main Sword part
	
	-- Apply position and rotation offsets
	local rotationCFrame = CFrame.Angles(
		math.rad(HOLSTER_SETTINGS.RotationOffset.X),
		math.rad(HOLSTER_SETTINGS.RotationOffset.Y),
		math.rad(HOLSTER_SETTINGS.RotationOffset.Z)
	)
	
	holsterWeld.C0 = CFrame.new(HOLSTER_SETTINGS.PositionOffset) * rotationCFrame
	holsterWeld.Parent = swordPart
	
	holsteredSword.Parent = character
	
	-- Set initial visibility
	if HOLSTER_SETTINGS.UseTransparency then
		local initialTransparency = 1
		if not isEquipped then
			initialTransparency = HOLSTER_SETTINGS.TransparencyValue
		end
		setHolsterTransparency(initialTransparency)
	else
		if isEquipped then
			holsteredSword.Parent = nil
		else
			holsteredSword.Parent = character
		end
	end
end

-- Function to show holstered sword
local function showHolster()
	if not holsteredSword then return end
	
	if HOLSTER_SETTINGS.UseTransparency then
		-- Fade in
		for transparency = 1, HOLSTER_SETTINGS.TransparencyValue, -HOLSTER_SETTINGS.FadeSpeed do
			setHolsterTransparency(transparency)
			task.wait()
		end
		setHolsterTransparency(HOLSTER_SETTINGS.TransparencyValue)
	else
		holsteredSword.Parent = character
	end
end

-- Function to hide holstered sword
local function hideHolster()
	if not holsteredSword then return end
	
	if HOLSTER_SETTINGS.UseTransparency then
		-- Fade out
		for transparency = HOLSTER_SETTINGS.TransparencyValue, 1, HOLSTER_SETTINGS.FadeSpeed do
			setHolsterTransparency(transparency)
			task.wait()
		end
		setHolsterTransparency(1)
	else
		holsteredSword.Parent = nil
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

-- Event handlers
tool.Equipped:Connect(function()
	isEquipped = true
	hideHolster()
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	showHolster()
end)

-- Cleanup on character death or tool removal
humanoid.Died:Connect(cleanupHolster)
tool.AncestryChanged:Connect(function()
	if not tool:IsDescendantOf(game) then
		cleanupHolster()
	end
end)

-- Character respawn handler
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	cleanupHolster()
	task.wait(0.5) -- Wait for character to fully load
	createHolsteredSword()
	
	humanoid.Died:Connect(cleanupHolster)
end)

-- Initialize
createHolsteredSword()
