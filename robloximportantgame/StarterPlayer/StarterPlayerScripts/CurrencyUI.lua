-- Currency Display UI - Client Script
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts
-- Shows player's currency in the top-left area

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[CURRENCY UI] Loading...")

-- ==================== SETTINGS ====================

local CURRENCY_SETTINGS = {
	-- Colors (matching game's dark theme)
	BackgroundColor = Color3.fromRGB(20, 20, 25),
	BackgroundTransparency = 0.1,
	
	TextColor = Color3.fromRGB(255, 255, 255),
	BorderColor = Color3.fromRGB(252, 252, 252),
	
	-- Position
	LeftOffset = 10,
	TopOffset = 0.35, -- 35% from top (middle-left area)
	
	-- Sizes
	FrameWidth = 180,
	FrameHeight = 60,
	IconSize = 40,
	IconPadding = 10,
	
	-- Corner radius
	CornerRadius = 10,
}

-- ==================== CURRENCY DATA ====================

-- This will be replaced with actual currency from server
local currentCurrency = 1300 -- Test value (will show as "1.3K")

-- ==================== HELPER FUNCTIONS ====================

-- Format large numbers (e.g., 1300 -> "1.3K", 1500000 -> "1.5M")
local function formatCurrency(amount)
	if amount >= 1000000000 then
		return string.format("%.1fB", amount / 1000000000)
	elseif amount >= 1000000 then
		return string.format("%.1fM", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("%.1fK", amount / 1000)
	else
		return tostring(math.floor(amount))
	end
end

-- ==================== CREATE UI ====================

-- Create ScreenGui
local currencyGui = Instance.new("ScreenGui")
currencyGui.Name = "CurrencyUI"
currencyGui.ResetOnSpawn = false
currencyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
currencyGui.IgnoreGuiInset = true
currencyGui.DisplayOrder = 100
currencyGui.Parent = playerGui

-- Main currency frame
local currencyFrame = Instance.new("Frame")
currencyFrame.Name = "CurrencyFrame"
currencyFrame.Size = UDim2.new(0, CURRENCY_SETTINGS.FrameWidth, 0, CURRENCY_SETTINGS.FrameHeight)
currencyFrame.Position = UDim2.new(0, CURRENCY_SETTINGS.LeftOffset, CURRENCY_SETTINGS.TopOffset, 0)
currencyFrame.AnchorPoint = Vector2.new(0, 0.5)
currencyFrame.BackgroundColor3 = CURRENCY_SETTINGS.BackgroundColor
currencyFrame.BackgroundTransparency = CURRENCY_SETTINGS.BackgroundTransparency
currencyFrame.BorderSizePixel = 0
currencyFrame.Parent = currencyGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, CURRENCY_SETTINGS.CornerRadius)
corner.Parent = currencyFrame

-- Border stroke
local stroke = Instance.new("UIStroke")
stroke.Color = CURRENCY_SETTINGS.BorderColor
stroke.Thickness = 1.5
stroke.Transparency = 0.6
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = currencyFrame

-- Currency icon (ImageLabel)
local currencyIcon = Instance.new("ImageLabel")
currencyIcon.Name = "CurrencyIcon"
currencyIcon.Size = UDim2.new(0, CURRENCY_SETTINGS.IconSize, 0, CURRENCY_SETTINGS.IconSize)
currencyIcon.Position = UDim2.new(0, CURRENCY_SETTINGS.IconPadding, 0.5, 0)
currencyIcon.AnchorPoint = Vector2.new(0, 0.5)
currencyIcon.BackgroundTransparency = 1
currencyIcon.Image = "rbxassetid://0" -- REPLACE WITH YOUR CURRENCY ICON ID
currencyIcon.ScaleType = Enum.ScaleType.Fit
currencyIcon.ImageColor3 = Color3.fromRGB(255, 215, 0) -- Gold color (fallback if no image)
currencyIcon.Parent = currencyFrame

-- Placeholder circle if no image is set
local iconPlaceholder = Instance.new("Frame")
iconPlaceholder.Name = "IconPlaceholder"
iconPlaceholder.Size = UDim2.new(1, 0, 1, 0)
iconPlaceholder.Position = UDim2.new(0.5, 0, 0.5, 0)
iconPlaceholder.AnchorPoint = Vector2.new(0.5, 0.5)
iconPlaceholder.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold
iconPlaceholder.BackgroundTransparency = 0.2
iconPlaceholder.BorderSizePixel = 0
iconPlaceholder.Parent = currencyIcon

local placeholderCorner = Instance.new("UICorner")
placeholderCorner.CornerRadius = UDim.new(1, 0) -- Circle
placeholderCorner.Parent = iconPlaceholder

-- Coin symbol in placeholder
local coinSymbol = Instance.new("TextLabel")
coinSymbol.Size = UDim2.new(1, 0, 1, 0)
coinSymbol.BackgroundTransparency = 1
coinSymbol.Font = Enum.Font.GothamBold
coinSymbol.Text = "$"
coinSymbol.TextColor3 = Color3.fromRGB(20, 20, 25)
coinSymbol.TextSize = 24
coinSymbol.TextXAlignment = Enum.TextXAlignment.Center
coinSymbol.TextYAlignment = Enum.TextYAlignment.Center
coinSymbol.Parent = iconPlaceholder

-- Currency amount text
local currencyText = Instance.new("TextLabel")
currencyText.Name = "CurrencyText"
currencyText.Size = UDim2.new(1, -(CURRENCY_SETTINGS.IconSize + CURRENCY_SETTINGS.IconPadding * 2 + 5), 1, 0)
currencyText.Position = UDim2.new(0, CURRENCY_SETTINGS.IconSize + CURRENCY_SETTINGS.IconPadding + 5, 0, 0)
currencyText.BackgroundTransparency = 1
currencyText.Font = Enum.Font.GothamBold
currencyText.Text = formatCurrency(currentCurrency)
currencyText.TextColor3 = CURRENCY_SETTINGS.TextColor
currencyText.TextSize = 22
currencyText.TextXAlignment = Enum.TextXAlignment.Left
currencyText.TextYAlignment = Enum.TextYAlignment.Center
currencyText.TextTruncate = Enum.TextTruncate.AtEnd
currencyText.Parent = currencyFrame

-- ==================== HOVER EFFECT ====================

-- Subtle hover effect
currencyFrame.MouseEnter:Connect(function()
	TweenService:Create(currencyFrame, TweenInfo.new(0.2), {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.2), {
		Transparency = 0.4
	}):Play()
end)

currencyFrame.MouseLeave:Connect(function()
	TweenService:Create(currencyFrame, TweenInfo.new(0.2), {
		BackgroundTransparency = CURRENCY_SETTINGS.BackgroundTransparency
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.2), {
		Transparency = 0.6
	}):Play()
end)

-- ==================== UPDATE FUNCTION ====================

-- Function to update currency display
local function updateCurrency(newAmount)
	currentCurrency = newAmount
	
	-- Animate the change
	local oldText = currencyText.Text
	local newText = formatCurrency(newAmount)
	
	if oldText ~= newText then
		-- Quick pulse animation
		local pulseTween = TweenService:Create(
			currencyText,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{TextSize = 26}
		)
		
		local resetTween = TweenService:Create(
			currencyText,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{TextSize = 22}
		)
		
		pulseTween:Play()
		pulseTween.Completed:Connect(function()
			currencyText.Text = newText
			resetTween:Play()
		end)
	end
end

-- ==================== GLOBAL API ====================

-- Make function available globally for other scripts
_G.CurrencyUI = {
	updateCurrency = updateCurrency,
	getCurrency = function() return currentCurrency end,
	formatCurrency = formatCurrency
}

-- ==================== TESTING ====================

-- Test animation (cycles through different values to show formatting)
-- REMOVE THIS in production when you have real currency system
task.spawn(function()
	task.wait(3)
	
	-- Simulate currency changes for testing
	local testValues = {1300, 5600, 12800, 156000, 1200000, 1300}
	
	for _, value in ipairs(testValues) do
		task.wait(2)
		updateCurrency(value)
	end
	
	-- Reset to initial test value
	task.wait(2)
	updateCurrency(1300)
end)

print("========================================")
print("Currency UI Ready!")
print("Current currency:", formatCurrency(currentCurrency))
print("Replace 'rbxassetid://0' with your currency icon!")
print("========================================")
