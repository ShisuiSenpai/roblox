--[[
    GRAVITY GUN UI SCRIPT
    Place this in StarterGui (as a ScreenGui with this LocalScript inside)
    
    Creates:
    - Futuristic crosshair
    - Status indicators
    - Control hints
    - Visual feedback
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Wait a moment for the UI to be created
wait(0.5)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GravityGunUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- Create crosshair container
local crosshairFrame = Instance.new("Frame")
crosshairFrame.Name = "CrosshairFrame"
crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)
crosshairFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
crosshairFrame.Size = UDim2.new(0, 60, 0, 60)
crosshairFrame.BackgroundTransparency = 1
crosshairFrame.Parent = screenGui

-- Center dot
local centerDot = Instance.new("Frame")
centerDot.Name = "CenterDot"
centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
centerDot.Size = UDim2.new(0, 4, 0, 4)
centerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
centerDot.BorderSizePixel = 0
centerDot.Parent = crosshairFrame

local centerDotCorner = Instance.new("UICorner")
centerDotCorner.CornerRadius = UDim.new(1, 0)
centerDotCorner.Parent = centerDot

-- Create crosshair lines (4 directional)
local function createCrosshairLine(rotation, name)
    local line = Instance.new("Frame")
    line.Name = name
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Position = UDim2.new(0.5, 0, 0.5, 0)
    line.Size = UDim2.new(0, 20, 0, 2)
    line.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    line.BorderSizePixel = 0
    line.Rotation = rotation
    line.Parent = crosshairFrame
    
    -- Gradient for fade effect
    local gradient = Instance.new("UIGradient")
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(1, 0)
    })
    gradient.Rotation = rotation + 90
    gradient.Parent = line
    
    return line
end

local topLine = createCrosshairLine(0, "TopLine")
local rightLine = createCrosshairLine(90, "RightLine")
local bottomLine = createCrosshairLine(180, "BottomLine")
local leftLine = createCrosshairLine(270, "LeftLine")

-- Outer ring
local outerRing = Instance.new("ImageLabel")
outerRing.Name = "OuterRing"
outerRing.AnchorPoint = Vector2.new(0.5, 0.5)
outerRing.Position = UDim2.new(0.5, 0, 0.5, 0)
outerRing.Size = UDim2.new(0, 50, 0, 50)
outerRing.BackgroundTransparency = 1
outerRing.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
outerRing.ImageColor3 = Color3.fromRGB(0, 200, 255)
outerRing.ImageTransparency = 0.7
outerRing.Parent = crosshairFrame

-- Make it a circle using UIStroke
local outerStroke = Instance.new("UIStroke")
outerStroke.Color = Color3.fromRGB(0, 255, 255)
outerStroke.Thickness = 2
outerStroke.Transparency = 0.5
outerStroke.Parent = outerRing

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(1, 0)
outerCorner.Parent = outerRing

-- Status text
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Position = UDim2.new(0.5, 0, 0.5, 40)
statusLabel.Size = UDim2.new(0, 200, 0, 30)
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "GRAVITY GUN READY"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextStrokeTransparency = 0.5
statusLabel.Parent = crosshairFrame

-- Control hints
local controlsFrame = Instance.new("Frame")
controlsFrame.Name = "ControlsFrame"
controlsFrame.Position = UDim2.new(0.5, 0, 0.85, 0)
controlsFrame.Size = UDim2.new(0, 400, 0, 80)
controlsFrame.AnchorPoint = Vector2.new(0.5, 0)
controlsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlsFrame.BackgroundTransparency = 0.7
controlsFrame.BorderSizePixel = 0
controlsFrame.Parent = screenGui

local controlsCorner = Instance.new("UICorner")
controlsCorner.CornerRadius = UDim.new(0, 8)
controlsCorner.Parent = controlsFrame

-- Control text
local function createControlText(text, position, order)
    local label = Instance.new("TextLabel")
    label.Position = position
    label.Size = UDim2.new(1, -20, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = controlsFrame
    label.LayoutOrder = order
    return label
end

local control1 = createControlText("🖱️ LEFT CLICK - Grab / Throw Object", UDim2.new(0, 10, 0, 10), 1)
local control2 = createControlText("🖱️ RIGHT CLICK - Release Object Gently", UDim2.new(0, 10, 0, 35), 2)
local control3 = createControlText("🎯 Max Distance: 50 studs | Max Mass: 500", UDim2.new(0, 10, 0, 60), 3)

-- Pulse animation for crosshair
local function pulseCrosshair()
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local goal = {Rotation = 45}
    local tween = TweenService:Create(outerRing, tweenInfo, goal)
    tween:Play()
end

pulseCrosshair()

-- Animate lines expanding/contracting
local function animateLines()
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    
    for _, line in ipairs({topLine, rightLine, bottomLine, leftLine}) do
        local originalSize = line.Size
        local goal = {Size = UDim2.new(0, 25, 0, 2)}
        local tween = TweenService:Create(line, tweenInfo, goal)
        tween:Play()
    end
end

animateLines()

-- Update status when holding
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GravityEvent = ReplicatedStorage:WaitForChild("GravityGunEvent")

GravityEvent.OnClientEvent:Connect(function(action)
    if action == "GrabSuccess" then
        statusLabel.Text = "OBJECT LOCKED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        -- Flash effect
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local flashGoal = {ImageTransparency = 0.3}
        TweenService:Create(outerRing, tweenInfo, flashGoal):Play()
    elseif action == "Released" then
        statusLabel.Text = "GRAVITY GUN READY"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local normalGoal = {ImageTransparency = 0.7}
        TweenService:Create(outerRing, tweenInfo, normalGoal):Play()
    end
end)

print("Gravity Gun UI loaded!")
