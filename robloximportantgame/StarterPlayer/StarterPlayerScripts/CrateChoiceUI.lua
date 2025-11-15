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
local crateErrorEvent = crateRemotes:WaitForChild("CrateError", 10)

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
	PriceColor = Color3.fromRGB(120, 220, 120), -- Green for Yen
	RobuxColor = Color3.fromRGB(255, 215, 0), -- Gold for Robux
	
	AccentColor = Color3.fromRGB(100, 150, 255),
	PremiumAccent = Color3.fromRGB(255, 215, 0), -- Gold
	
	-- Image Assets (USER WILL REPLACE THESE)
	RegularCrateImage = "rbxassetid://0", -- ⚠️ REPLACE WITH YOUR REGULAR CRATE IMAGE ID
	PremiumCrateImage = "rbxassetid://0", -- ⚠️ REPLACE WITH YOUR PREMIUM CRATE IMAGE ID
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
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = crateChoiceGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_CONFIG.AccentColor
mainStroke.Thickness = 3
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Subtle shadow effect
local shadowFrame = Instance.new("Frame")
shadowFrame.Name = "Shadow"
shadowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
shadowFrame.Position = UDim2.new(0.5, 0, 0.5, 5)
shadowFrame.Size = UDim2.new(1, 10, 1, 10)
shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadowFrame.BackgroundTransparency = 0.8
shadowFrame.BorderSizePixel = 0
shadowFrame.ZIndex = -1
shadowFrame.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 16)
shadowCorner.Parent = shadowFrame

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
title.Position = UDim2.new(0, 20, 0, 15)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Choose Relic Type"
title.TextColor3 = UI_CONFIG.TextColor
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextStrokeTransparency = 0.8
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
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 24
closeButton.AutoButtonColor = false
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.3, 0)
closeCorner.Parent = closeButton

-- Container for cards
local cardsContainer = Instance.new("Frame")
cardsContainer.Name = "CardsContainer"
cardsContainer.Position = UDim2.new(0, 20, 0, 85)
cardsContainer.Size = UDim2.new(1, -40, 1, -105)
cardsContainer.BackgroundTransparency = 1
cardsContainer.Parent = mainFrame

-- ==================== CREATE CRATE CARDS ====================

-- Regular Crate Card
local regularCard = Instance.new("Frame")
regularCard.Name = "RegularCard"
regularCard.Size = UDim2.new(0.48, 0, 1, 0)
regularCard.Position = UDim2.new(0, 0, 0, 0)
regularCard.BackgroundColor3 = UI_CONFIG.RegularCardColor
regularCard.BackgroundTransparency = 0.15
regularCard.BorderSizePixel = 0
regularCard.Parent = cardsContainer

local regularCorner = Instance.new("UICorner")
regularCorner.CornerRadius = UDim.new(0, 14)
regularCorner.Parent = regularCard

local regularStroke = Instance.new("UIStroke")
regularStroke.Color = UI_CONFIG.AccentColor
regularStroke.Thickness = 2.5
regularStroke.Transparency = 0.4
regularStroke.Parent = regularCard

-- Regular title
local regularTitle = Instance.new("TextLabel")
regularTitle.Size = UDim2.new(1, -20, 0, 40)
regularTitle.Position = UDim2.new(0, 10, 0, 10)
regularTitle.BackgroundTransparency = 1
regularTitle.Font = Enum.Font.GothamBold
regularTitle.Text = "REGULAR RELIC"
regularTitle.TextColor3 = UI_CONFIG.TextColor
regularTitle.TextSize = 22
regularTitle.TextStrokeTransparency = 0.8
regularTitle.Parent = regularCard

-- Regular icon/image
local regularIcon = Instance.new("ImageLabel")
regularIcon.Name = "RegularIcon"
regularIcon.Size = UDim2.new(0, 140, 0, 140)
regularIcon.Position = UDim2.new(0.5, -70, 0, 55)
regularIcon.BackgroundTransparency = 1
regularIcon.Image = UI_CONFIG.RegularCrateImage
regularIcon.ScaleType = Enum.ScaleType.Fit
regularIcon.Parent = regularCard

-- Placeholder frame if no image set
local regularIconPlaceholder = Instance.new("Frame")
regularIconPlaceholder.Size = UDim2.new(1, 0, 1, 0)
regularIconPlaceholder.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
regularIconPlaceholder.BackgroundTransparency = 0.3
regularIconPlaceholder.BorderSizePixel = 0
regularIconPlaceholder.Parent = regularIcon

local regularIconCorner = Instance.new("UICorner")
regularIconCorner.CornerRadius = UDim.new(0, 12)
regularIconCorner.Parent = regularIconPlaceholder

local regularIconText = Instance.new("TextLabel")
regularIconText.Size = UDim2.new(1, 0, 1, 0)
regularIconText.BackgroundTransparency = 1
regularIconText.Font = Enum.Font.GothamBold
regularIconText.Text = "IMAGE\nHERE"
regularIconText.TextColor3 = Color3.fromRGB(150, 150, 150)
regularIconText.TextSize = 16
regularIconText.Parent = regularIconPlaceholder

-- Regular description
local regularDesc = Instance.new("TextLabel")
regularDesc.Size = UDim2.new(1, -20, 0, 65)
regularDesc.Position = UDim2.new(0, 10, 0, 200)
regularDesc.BackgroundTransparency = 1
regularDesc.Font = Enum.Font.Gotham
regularDesc.Text = "Standard drop rates\nEarn through gameplay\nPlay to unlock!"
regularDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
regularDesc.TextSize = 15
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
regularPrice.TextSize = 32
regularPrice.TextStrokeTransparency = 0.7
regularPrice.Parent = regularCard

-- Regular button
local regularButton = Instance.new("TextButton")
regularButton.Name = "OpenRegularButton"
regularButton.Size = UDim2.new(1, -20, 0, 48)
regularButton.Position = UDim2.new(0, 10, 1, -58)
regularButton.BackgroundColor3 = UI_CONFIG.AccentColor
regularButton.BackgroundTransparency = 0.1
regularButton.BorderSizePixel = 0
regularButton.Font = Enum.Font.GothamBold
regularButton.Text = "OPEN"
regularButton.TextColor3 = Color3.fromRGB(255, 255, 255)
regularButton.TextSize = 20
regularButton.TextStrokeTransparency = 0.8
regularButton.AutoButtonColor = false
regularButton.Parent = regularCard

local regularButtonCorner = Instance.new("UICorner")
regularButtonCorner.CornerRadius = UDim.new(0, 10)
regularButtonCorner.Parent = regularButton

-- Premium Crate Card
local premiumCard = Instance.new("Frame")
premiumCard.Name = "PremiumCard"
premiumCard.Size = UDim2.new(0.48, 0, 1, 0)
premiumCard.Position = UDim2.new(0.52, 0, 0, 0)
premiumCard.BackgroundColor3 = UI_CONFIG.PremiumCardColor
premiumCard.BackgroundTransparency = 0.15
premiumCard.BorderSizePixel = 0
premiumCard.Parent = cardsContainer

local premiumCorner = Instance.new("UICorner")
premiumCorner.CornerRadius = UDim.new(0, 14)
premiumCorner.Parent = premiumCard

local premiumStroke = Instance.new("UIStroke")
premiumStroke.Color = UI_CONFIG.PremiumAccent
premiumStroke.Thickness = 2.5
premiumStroke.Transparency = 0.2
premiumStroke.Parent = premiumCard

-- Add subtle glow effect to premium
local premiumGlow = Instance.new("UIGradient")
premiumGlow.Rotation = 90
premiumGlow.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.8),
	NumberSequenceKeypoint.new(0.5, 0.6),
	NumberSequenceKeypoint.new(1, 0.8),
})
premiumGlow.Parent = premiumStroke

-- Premium badge (smaller, more subtle, higher up)
local premiumBadge = Instance.new("TextLabel")
premiumBadge.Size = UDim2.new(0, 90, 0, 22)
premiumBadge.Position = UDim2.new(1, -95, 0, 5)
premiumBadge.BackgroundColor3 = UI_CONFIG.PremiumAccent
premiumBadge.BackgroundTransparency = 0.4
premiumBadge.BorderSizePixel = 0
premiumBadge.Font = Enum.Font.GothamBold
premiumBadge.Text = "PREMIUM"
premiumBadge.TextColor3 = Color3.fromRGB(30, 30, 30)
premiumBadge.TextSize = 11
premiumBadge.TextStrokeTransparency = 0.9
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
premiumTitle.TextSize = 22
premiumTitle.TextStrokeTransparency = 0.8
premiumTitle.Parent = premiumCard

-- Premium icon
local premiumIcon = Instance.new("ImageLabel")
premiumIcon.Name = "PremiumIcon"
premiumIcon.Size = UDim2.new(0, 140, 0, 140)
premiumIcon.Position = UDim2.new(0.5, -70, 0, 55)
premiumIcon.BackgroundTransparency = 1
premiumIcon.Image = UI_CONFIG.PremiumCrateImage
premiumIcon.ScaleType = Enum.ScaleType.Fit
premiumIcon.Parent = premiumCard

-- Placeholder frame if no image set
local premiumIconPlaceholder = Instance.new("Frame")
premiumIconPlaceholder.Size = UDim2.new(1, 0, 1, 0)
premiumIconPlaceholder.BackgroundColor3 = UI_CONFIG.PremiumAccent
premiumIconPlaceholder.BackgroundTransparency = 0.6
premiumIconPlaceholder.BorderSizePixel = 0
premiumIconPlaceholder.Parent = premiumIcon

local premiumIconCorner = Instance.new("UICorner")
premiumIconCorner.CornerRadius = UDim.new(0, 12)
premiumIconCorner.Parent = premiumIconPlaceholder

local premiumIconText = Instance.new("TextLabel")
premiumIconText.Size = UDim2.new(1, 0, 1, 0)
premiumIconText.BackgroundTransparency = 1
premiumIconText.Font = Enum.Font.GothamBold
premiumIconText.Text = "IMAGE\nHERE"
premiumIconText.TextColor3 = Color3.fromRGB(180, 180, 100)
premiumIconText.TextSize = 16
premiumIconText.Parent = premiumIconPlaceholder

-- Premium description
local premiumDesc = Instance.new("TextLabel")
premiumDesc.Size = UDim2.new(1, -20, 0, 65)
premiumDesc.Position = UDim2.new(0, 10, 0, 200)
premiumDesc.BackgroundTransparency = 1
premiumDesc.Font = Enum.Font.Gotham
premiumDesc.Text = "Better drop rates!\n2-3x chance for rare items\nSupport the game! ✨"
premiumDesc.TextColor3 = Color3.fromRGB(255, 235, 170)
premiumDesc.TextSize = 15
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
premiumPrice.TextSize = 32
premiumPrice.TextStrokeTransparency = 0.7
premiumPrice.Parent = premiumCard

-- Premium button
local premiumButton = Instance.new("TextButton")
premiumButton.Name = "OpenPremiumButton"
premiumButton.Size = UDim2.new(1, -20, 0, 48)
premiumButton.Position = UDim2.new(0, 10, 1, -58)
premiumButton.BackgroundColor3 = UI_CONFIG.PremiumAccent
premiumButton.BackgroundTransparency = 0.1
premiumButton.BorderSizePixel = 0
premiumButton.Font = Enum.Font.GothamBold
premiumButton.Text = "OPEN"
premiumButton.TextColor3 = Color3.fromRGB(30, 30, 30)
premiumButton.TextSize = 20
premiumButton.TextStrokeTransparency = 0.9
premiumButton.AutoButtonColor = false
premiumButton.Parent = premiumCard

local premiumButtonCorner = Instance.new("UICorner")
premiumButtonCorner.CornerRadius = UDim.new(0, 10)
premiumButtonCorner.Parent = premiumButton

-- ==================== ERROR NOTIFICATION ====================

local errorNotification = Instance.new("Frame")
errorNotification.Name = "ErrorNotification"
errorNotification.AnchorPoint = Vector2.new(0.5, 0)
errorNotification.Position = UDim2.new(0.5, 0, 0, -100)
errorNotification.Size = UDim2.new(0, 350, 0, 60)
errorNotification.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
errorNotification.BackgroundTransparency = 1
errorNotification.BorderSizePixel = 0
errorNotification.Visible = false
errorNotification.ZIndex = 300
errorNotification.Parent = crateChoiceGui

local errorCorner = Instance.new("UICorner")
errorCorner.CornerRadius = UDim.new(0, 12)
errorCorner.Parent = errorNotification

local errorStroke = Instance.new("UIStroke")
errorStroke.Color = Color3.fromRGB(255, 100, 100)
errorStroke.Thickness = 2
errorStroke.Transparency = 1
errorStroke.Parent = errorNotification

local errorText = Instance.new("TextLabel")
errorText.Size = UDim2.new(1, -20, 1, 0)
errorText.Position = UDim2.new(0, 10, 0, 0)
errorText.BackgroundTransparency = 1
errorText.Font = Enum.Font.GothamBold
errorText.Text = "Not enough Yen!"
errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
errorText.TextSize = 20
errorText.TextTransparency = 1
errorText.TextStrokeTransparency = 1
errorText.Parent = errorNotification

-- ==================== FUNCTIONS ====================

local isOpen = false

local function showError(message)
	errorText.Text = message
	errorNotification.Visible = true
	
	-- Slide in and fade in
	errorNotification.Position = UDim2.new(0.5, 0, 0, -100)
	errorNotification.BackgroundTransparency = 1
	errorStroke.Transparency = 1
	errorText.TextTransparency = 1
	
	local slideIn = TweenService:Create(
		errorNotification,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, 0, 0, 20), BackgroundTransparency = 0.1}
	)
	
	local strokeFade = TweenService:Create(
		errorStroke,
		TweenInfo.new(0.3),
		{Transparency = 0.3}
	)
	
	local textFade = TweenService:Create(
		errorText,
		TweenInfo.new(0.3),
		{TextTransparency = 0, TextStrokeTransparency = 0.8}
	)
	
	slideIn:Play()
	strokeFade:Play()
	textFade:Play()
	
	-- Auto hide after 2 seconds
	task.wait(2)
	
	local slideOut = TweenService:Create(
		errorNotification,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, 0, 0, -100), BackgroundTransparency = 1}
	)
	
	local strokeFadeOut = TweenService:Create(
		errorStroke,
		TweenInfo.new(0.3),
		{Transparency = 1}
	)
	
	local textFadeOut = TweenService:Create(
		errorText,
		TweenInfo.new(0.3),
		{TextTransparency = 1, TextStrokeTransparency = 1}
	)
	
	slideOut:Play()
	strokeFadeOut:Play()
	textFadeOut:Play()
	
	slideOut.Completed:Wait()
	errorNotification.Visible = false
end

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

-- Close button hover
closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(255, 100, 100),
		Size = UDim2.new(0, 44, 0, 44)
	}):Play()
end)

closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(255, 80, 80),
		Size = UDim2.new(0, 40, 0, 40)
	}):Play()
end)

-- Click outside to close (but NOT on mainFrame)
dimBackground.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		-- Check if click was inside mainFrame
		local mousePos = UserInputService:GetMouseLocation()
		local framePos = mainFrame.AbsolutePosition
		local frameSize = mainFrame.AbsoluteSize
		
		local isInsideFrame = mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X
			and mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y
		
		if not isInsideFrame then
			closeUI()
		end
	end
end)

-- Regular button hover
regularButton.MouseEnter:Connect(function()
	TweenService:Create(regularButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(120, 170, 255),
		Size = UDim2.new(1, -18, 0, 50)
	}):Play()
end)

regularButton.MouseLeave:Connect(function()
	TweenService:Create(regularButton, TweenInfo.new(0.2), {
		BackgroundColor3 = UI_CONFIG.AccentColor,
		Size = UDim2.new(1, -20, 0, 48)
	}):Play()
end)

-- Premium button hover
premiumButton.MouseEnter:Connect(function()
	TweenService:Create(premiumButton, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(255, 235, 50),
		Size = UDim2.new(1, -18, 0, 50)
	}):Play()
end)

premiumButton.MouseLeave:Connect(function()
	TweenService:Create(premiumButton, TweenInfo.new(0.2), {
		BackgroundColor3 = UI_CONFIG.PremiumAccent,
		Size = UDim2.new(1, -20, 0, 48)
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

-- ==================== SERVER EVENT LISTENERS ====================

showCrateChoiceEvent.OnClientEvent:Connect(function()
	openUI()
end)

-- Listen for errors from server
if crateErrorEvent then
	crateErrorEvent.OnClientEvent:Connect(function(errorMessage)
		showError(errorMessage)
	end)
end

print("[CRATE CHOICE UI] Ready!")
print("[CRATE CHOICE UI] ⚠️ Remember to set image IDs in UI_CONFIG!")
