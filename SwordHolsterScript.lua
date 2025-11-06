--[[
	SWORD HOLSTERING SYSTEM
	Place this LocalScript inside your Sword Tool
	
	Features:
	- Automatically creates a holstered version of your sword
	- Smoothly toggles between holstered and equipped states
	- Fully customizable positioning and attachment points
	- Works with both R6 and R15 rigs
]]

local tool = script.Parent
local handle = tool:WaitForChild("Handle")

-- ========================================
-- CUSTOMIZATION SETTINGS
-- ========================================

local HOLSTER_SETTINGS = {
	-- Which body part to attach the holstered sword to
	-- R15 options: "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm"
	-- R6 options: "Torso"
	AttachmentPart = "UpperTorso", -- Change this to your preferred body part
	
	-- Position offset from the attachment part (X, Y, Z)
	-- X = Left/Right, Y = Up/Down, Z = Forward/Back
	PositionOffset = Vector3.new(0.5, 0.5, -0.8), -- Adjust for placement (back-right shoulder area)
	
	-- Rotation in degrees (X, Y, Z)
	-- Play with these values to get the angle you want
	RotationOffset = Vector3.new(45, 0, -25), -- Tilted angle for back holster
	
	-- Visual settings
	UseTransparency = true, -- If true, uses transparency. If false, completely removes/creates the holster
	TransparencyValue = 0, -- 0 = invisible, 1 = visible, 0.5 = semi-transparent
	
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
	
	-- Clone the handle to create the holstered version
	holsteredSword = handle:Clone()
	holsteredSword.Name = "HolsteredSword"
	holsteredSword.CanCollide = false
	holsteredSword.Massless = true
	
	-- Make all descendants non-collidable
	for _, descendant in pairs(holsteredSword:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.CanCollide = false
			descendant.Massless = true
		end
	end
	
	-- Create weld to attach holstered sword to body part
	holsterWeld = Instance.new("Weld")
	holsterWeld.Part0 = attachPart
	holsterWeld.Part1 = holsteredSword
	
	-- Apply position and rotation offsets
	local rotationCFrame = CFrame.Angles(
		math.rad(HOLSTER_SETTINGS.RotationOffset.X),
		math.rad(HOLSTER_SETTINGS.RotationOffset.Y),
		math.rad(HOLSTER_SETTINGS.RotationOffset.Z)
	)
	
	holsterWeld.C0 = CFrame.new(HOLSTER_SETTINGS.PositionOffset) * rotationCFrame
	holsterWeld.Parent = holsteredSword
	
	holsteredSword.Parent = character
	
	-- Set initial visibility
	if HOLSTER_SETTINGS.UseTransparency then
		setHolsterTransparency(isEquipped and 1 or HOLSTER_SETTINGS.TransparencyValue)
	else
		holsteredSword.Parent = isEquipped and nil or character
	end
end

-- Function to set transparency of holstered sword
local function setHolsterTransparency(targetTransparency)
	if not holsteredSword then return end
	
	for _, descendant in pairs(holsteredSword:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = targetTransparency
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
