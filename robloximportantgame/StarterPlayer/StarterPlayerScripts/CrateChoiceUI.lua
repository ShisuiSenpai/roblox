-- Crate Choice UI - Client Script
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts
-- Shows UI when player interacts with crate, letting them choose Regular or Premium

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[CRATE CHOICE UI] Loading...")

-- Wait for RemoteEvents
local crateRemotes = ReplicatedStorage:WaitForChild("CrateRemotes", 10)
if not crateRemotes then
	warn("[CRATE CHOICE UI] CrateRemotes not found!")
	return
end

local showCrateChoiceEvent = crateRemotes:WaitForChild("ShowCrateChoice", 10)
local requestCrateOpenEvent = crateRemotes:WaitForChild("RequestCrateOpen", 10)

if not showCrateChoiceEvent or not requestCrateOpenEvent then
	warn("[CRATE CHOICE UI] Remote events not found!")
	return
end

-- ==================== SETTINGS ====================

local UI_CONFIG = {
	-- Colors
	BackgroundColor = Color3.fromRGB(15, 15, 20),
	RegularCardColor = Color3.fromRGB(30, 30, 40),
	PremiumCardColor = Color3.fromRGB(45, 35, 60), -- Purple tint for premium
	
	TextColor = Color3.fromRGB(255, 255, 255),
	PriceColor = Color3.fromRGB(120, 200, 120), -- Green for Yen
	RobuxColor = Color3.fromRGB(255, 200, 50), -- Gold for Robux
	
	AccentColor = Color3.fromRGB(100, 150, 255),
	PremiumAccent = Color3.fromRGB(255, 215, 0), -- Gold
}

-- ==================== CREATE UI ====================

local crateChoiceGui = Instance.new("ScreenGui")
crateChoiceGui.Name = "CrateChoiceUI"
crateChoiceGui.ResetOnSpawn = false
crateChoiceGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
crateChoiceGui.IgnoreGuiInset = true
crateChoiceGui.DisplayOrder = 200
crateChoiceGui.Enabled = false
crateChoiceGui.Parent = playerGui

-- Dim background
local dimBackground = Instance.new("Frame")
dimBackground.Name = "DimBackground"
dimBackground.Size = UDim2.new(1, 0, 1, 0)
dimBackground.Position = UDim2.new(0, 0, 0, 0)
dimBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dimBackground.BackgroundTransparency = 0.5
dimBackground.BorderSizePixel = 0
dimBackground.Parent = crateChoiceGui

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.Size = UDim2.new(0, 700, 0, 450)
mainFrame.BackgroundColor3 = UI_CONFIG.BackgroundColor
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = crateChoiceGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_CONFIG.AccentColor
mainStroke.Thickness = 2
mainStroke.Transparency = 0.4
mainStroke.Parent = mainFrame

-- Mobile scaling
local uiScale = Instance.new("UIScale")
uiScale.Parent = mainFrame

local function updateUIScale()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local baseScale = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)
	uiScale.Scale = math.clamp(baseScale, 0.7, 1.2)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)
updateUIScale()

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 0, 60)
title.Position = UDim2.new(0, 20, 0, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Choose Crate Type"
title.TextColor3 = UI_CONFIG.TextColor
title.TextSize = 32
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = mainFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -15, 0, 15)
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.BackgroundTransparency = 0.1
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.AutoButtonColor = false
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.25, 0)
closeCorner.Parent = closeButton

-- Container for cards
local cardsContainer = Instance.new("Frame")
cardsContainer.Name = "CardsContainer"
cardsContainer.Position = UDim2.new(0, 20, 0, 80)
cardsContainer.Size = UDim2.new(1, -40, 1, -100)
cardsContainer.BackgroundTransparency = 1
cardsContainer.Parent = mainFrame

-- ==================== CREATE CRATE CARDS ====================

-- Regular Crate Card
local regularCard = Instance.new("Frame")
regularCard.Name = "RegularCard"
regularCard.Size = UDim2.new(0.48, 0, 1, 0)
regularCard.Position = UDim2.new(0, 0, 0, 0)
regularCard.BackgroundColor3 = UI_CONFIG.RegularCardColor
regularCard.BackgroundTransparency = 0.2
regularCard.BorderSizePixel = 0
regularCard.Parent = cardsContainer

local regularCorner = Instance.new("UICorner")
regularCorner.CornerRadius = UDim.new(0, 12)
regularCorner.Parent = regularCard

local regularStroke = Instance.new("UIStroke")
regularStroke.Color = UI_CONFIG.AccentColor
regularStroke.Thickness = 2
regularStroke.Transparency = 0.5
regularStroke.Parent = regularCard

-- Regular title
local regularTitle = Instance.new("TextLabel")
regularTitle.Size = UDim2.new(1, -20, 0, 40)
regularTitle.Position = UDim2.new(0, 10, 0, 10)
regularTitle.BackgroundTransparency = 1
regularTitle.Font = Enum.Font.GothamBold
regularTitle.Text = "REGULAR RELIC"
regularTitle.TextColor3 = UI_CONFIG.TextColor
regularTitle.TextSize = 24
regularTitle.Parent = regularCard

-- Regular icon/image placeholder
local regularIcon = Instance.new("Frame")
regularIcon.Size = UDim2.new(0, 120, 0, 120)
regularIcon.Position = UDim2.new(0.5, -60, 0, 60)
regularIcon.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
regularIcon.BackgroundTransparency = 0.3
regularIcon.BorderSizePixel = 0
regularIcon.Parent = regularCard

local regularIconCorner = Instance.new("UICorner")
regularIconCorner.CornerRadius = UDim.new(0, 10)
regularIconCorner.Parent = regularIcon

local regularIconText = Instance.new("TextLabel")
regularIconText.Size = UDim2.new(1, 0, 1, 0)
regularIconText.BackgroundTransparency = 1
regularIconText.Font = Enum.Font.GothamBold
regularIconText.Text = "📦"
regularIconText.TextSize = 64
regularIconText.Parent = regularIcon

-- Regular description
local regularDesc = Instance.new("TextLabel")
regularDesc.Size = UDim2.new(1, -20, 0, 60)
regularDesc.Position = UDim2.new(0, 10, 0, 190)
regularDesc.BackgroundTransparency = 1
regularDesc.Font = Enum.Font.Gotham
regularDesc.Text = "Standard drop rates\nEarn through gameplay"
regularDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
regularDesc.TextSize = 14
regularDesc.TextWrapped = true
regularDesc.TextYAlignment = Enum.TextYAlignment.Top
regularDesc.Parent = regularCard

-- Regular price
local regularPrice = Instance.new("TextLabel")
regularPrice.Size = UDim2.new(1, 0, 0, 35)
regularPrice.Position = UDim2.new(0, 0, 1, -100)
regularPrice.BackgroundTransparency = 1
regularPrice.Font = Enum.Font.GothamBold
regularPrice.Text = "¥ 250"
regularPrice.TextColor3 = UI_CONFIG.PriceColor
regularPrice.TextSize = 28
regularPrice.Parent = regularCard

-- Regular button
local regularButton = Instance.new("TextButton")
regularButton.Name = "OpenRegularButton"
regularButton.Size = UDim2.new(1, -20, 0, 45)
regularButton.Position = UDim2.new(0, 10, 1, -55)
regularButton.BackgroundColor3 = UI_CONFIG.AccentColor
regularButton.BackgroundTransparency = 0.1
regularButton.BorderSizePixel = 0
regularButton.Font = Enum.Font.GothamBold
regularButton.Text = "OPEN"
regularButton.TextColor3 = Color3.fromRGB(255, 255, 255)
regularButton.TextSize = 18
regularButton.AutoButtonColor = false
regularButton.Parent = regularCard

local regularButtonCorner = Instance.new("UICorner")
regularButtonCorner.CornerRadius = UDim.new(0, 8)
regularButtonCorner.Parent = regularButton

-- Premium Crate Card
local premiumCard = Instance.new("Frame")
premiumCard.Name = "PremiumCard"
premiumCard.Size = UDim2.new(0.48, 0, 1, 0)
premiumCard.Position = UDim2.new(0.52, 0, 0, 0)
premiumCard.BackgroundColor3 = UI_CONFIG.PremiumCardColor
premiumCard.BackgroundTransparency = 0.2
premiumCard.BorderSizePixel = 0
premiumCard.Parent = cardsContainer

local premiumCorner = Instance.new("UICorner")
premiumCorner.CornerRadius = UDim.new(0, 12)
premiumCorner.Parent = premiumCard

local premiumStroke = Instance.new("UIStroke")
premiumStroke.Color = UI_CONFIG.PremiumAccent
premiumStroke.Thickness = 2
premiumStroke.Transparency = 0.3
premiumStroke.Parent = premiumCard

-- Premium badge
local premiumBadge = Instance.new("TextLabel")
premiumBadge.Size = UDim2.new(0, 80, 0, 25)
premiumBadge.Position = UDim2.new(1, -85, 0, 10)
premiumBadge.BackgroundColor3 = UI_CONFIG.PremiumAccent
premiumBadge.BackgroundTransparency = 0.1
premiumBadge.Font = Enum.Font.GothamBold
premiumBadge.Text = "PREMIUM"
premiumBadge.TextColor3 = Color3.fromRGB(0, 0, 0)
premiumBadge.TextSize = 12
premiumBadge.Parent = premiumCard

local premiumBadgeCorner = Instance.new("UICorner")
premiumBadgeCorner.CornerRadius = UDim.new(0, 6)
premiumBadgeCorner.Parent = premiumBadge

-- Premium title
local premiumTitle = Instance.new("TextLabel")
premiumTitle.Size = UDim2.new(1, -20, 0, 40)
premiumTitle.Position = UDim2.new(0, 10, 0, 10)
premiumTitle.BackgroundTransparency = 1
premiumTitle.Font = Enum.Font.GothamBold
premiumTitle.Text = "PREMIUM RELIC"
premiumTitle.TextColor3 = UI_CONFIG.PremiumAccent
premiumTitle.TextSize = 24
premiumTitle.Parent = premiumCard

-- Premium icon
local premiumIcon = Instance.new("Frame")
premiumIcon.Size = UDim2.new(0, 120, 0, 120)
premiumIcon.Position = UDim2.new(0.5, -60, 0, 60)
premiumIcon.BackgroundColor3 = UI_CONFIG.PremiumAccent
premiumIcon.BackgroundTransparency = 0.7
premiumIcon.BorderSizePixel = 0
premiumIcon.Parent = premiumCard

local premiumIconCorner = Instance.new("UICorner")
premiumIconCorner.CornerRadius = UDim.new(0, 10)
premiumIconCorner.Parent = premiumIcon

local premiumIconText = Instance.new("TextLabel")
premiumIconText.Size = UDim2.new(1, 0, 1, 0)
premiumIconText.BackgroundTransparency = 1
premiumIconText.Font = Enum.Font.GothamBold
premiumIconText.Text = "✨"
premiumIconText.TextSize = 64
premiumIconText.Parent = premiumIcon

-- Premium description
local premiumDesc = Instance.new("TextLabel")
premiumDesc.Size = UDim2.new(1, -20, 0, 60)
premiumDesc.Position = UDim2.new(0, 10, 0, 190)
premiumDesc.BackgroundTransparency = 1
premiumDesc.Font = Enum.Font.Gotham
premiumDesc.Text = "Better drop rates!\n2-3x chance for rare items"
premiumDesc.TextColor3 = Color3.fromRGB(255, 215, 150)
premiumDesc.TextSize = 14
premiumDesc.TextWrapped = true
premiumDesc.TextYAlignment = Enum.TextYAlignment.Top
premiumDesc.Parent = premiumCard

-- Premium price
local premiumPrice = Instance.new("TextLabel")
premiumPrice.Size = UDim2.new(1, 0, 0, 35)
premiumPrice.Position = UDim2.new(0, 0, 1, -100)
premiumPrice.BackgroundTransparency = 1
premiumPrice.Font = Enum.Font.GothamBold
premiumPrice.Text = "99 R$"
premiumPrice.TextColor3 = UI_CONFIG.RobuxColor
premiumPrice.TextSize = 28
premiumPrice.Parent = premiumCard

-- Premium button
local premiumButton = Instance.new("TextButton")
premiumButton.Name = "OpenPremiumButton"
premiumButton.Size = UDim2.new(1, -20, 0, 45)
premiumButton.Position = UDim2.new(0, 10, 1, -55)
premiumButton.BackgroundColor3 = UI_CONFIG.PremiumAccent
premiumButton.BackgroundTransparency = 0.1
premiumButton.BorderSizePixel = 0
premiumButton.Font = Enum.Font.GothamBold
premiumButton.Text = "OPEN"
premiumButton.TextColor3 = Color3.fromRGB(0, 0, 0)
premiumButton.TextSize = 18
premiumButton.AutoButtonColor = false
premiumButton.Parent = premiumCard

local premiumButtonCorner = Instance.new("UICorner")
premiumButtonCorner.CornerRadius = UDim.new(0, 8)
premiumButtonCorner.Parent = premiumButton

-- ==================== FUNCTIONS ====================

local isOpen = false

local function closeUI()
	if not isOpen then return end
	isOpen = false
	
	-- Fade out animation
	local fadeTween = TweenService:Create(
		dimBackground,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{BackgroundTransparency = 1}
	)
	
	local scaleTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Size = UDim2.new(0, 0, 0, 0)}
	)
	
	fadeTween:Play()
	scaleTween:Play()
	
	scaleTween.Completed:Wait()
	crateChoiceGui.Enabled = false
end

local function openUI()
	if isOpen then return end
	isOpen = true
	
	crateChoiceGui.Enabled = true
	
	-- Reset for animation
	dimBackground.BackgroundTransparency = 1
	mainFrame.Size = UDim2.new(0, 0, 0, 0)
	
	-- Fade in animation
	local fadeTween = TweenService:Create(
		dimBackground,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{BackgroundTransparency = 0.5}
	)
	
	local scaleTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 700, 0, 450)}
	)
	
	fadeTween:Play()
	scaleTween:Play()
end

-- ==================== BUTTON HANDLERS ====================

-- Close button
closeButton.MouseButton1Click:Connect(closeUI)

-- Click outside to close
dimBackground.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		closeUI()
	end
end)

-- Regular button hover
regularButton.MouseEnter:Connect(function()
	TweenService:Create(regularButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(120, 170, 255)
	}):Play()
end)

regularButton.MouseLeave:Connect(function()
	TweenService:Create(regularButton, TweenInfo.new(0.2), {
		BackgroundColor3 = UI_CONFIG.AccentColor
	}):Play()
end)

-- Premium button hover
premiumButton.MouseEnter:Connect(function()
	TweenService:Create(premiumButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(255, 230, 50)
	}):Play()
end)

premiumButton.MouseLeave:Connect(function()
	TweenService:Create(premiumButton, TweenInfo.new(0.2), {
		BackgroundColor3 = UI_CONFIG.PremiumAccent
	}):Play()
end)

-- Regular button click
regularButton.MouseButton1Click:Connect(function()
	print("[CRATE CHOICE] Player chose REGULAR crate")
	requestCrateOpenEvent:FireServer("Regular")
	closeUI()
end)

-- Premium button click
premiumButton.MouseButton1Click:Connect(function()
	print("[CRATE CHOICE] Player chose PREMIUM crate")
	requestCrateOpenEvent:FireServer("Premium")
	closeUI()
end)

-- ==================== SERVER EVENT LISTENER ====================

showCrateChoiceEvent.OnClientEvent:Connect(function()
	openUI()
end)

print("[CRATE CHOICE UI] Ready!")
