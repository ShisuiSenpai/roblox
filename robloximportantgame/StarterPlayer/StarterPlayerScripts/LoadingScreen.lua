-- Loading Screen - Client Script
-- Place this LocalScript in StarterPlayer > StarterPlayerScripts
-- Shows loading screen until all game systems are ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("[LOADING] Starting loading screen...")

-- ==================== CREATE LOADING UI ====================

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.DisplayOrder = 10000 -- Always on top
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.Parent = playerGui

-- Full screen black background
local blackFrame = Instance.new("Frame")
blackFrame.Name = "BlackFrame"
blackFrame.Size = UDim2.new(1, 0, 1, 0)
blackFrame.Position = UDim2.new(0, 0, 0, 0)
blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackFrame.BackgroundTransparency = 0
blackFrame.BorderSizePixel = 0
blackFrame.ZIndex = 10000
blackFrame.Parent = loadingGui

-- Loading text container
local loadingContainer = Instance.new("Frame")
loadingContainer.Name = "LoadingContainer"
loadingContainer.AnchorPoint = Vector2.new(0.5, 0.5)
loadingContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
loadingContainer.Size = UDim2.new(0, 400, 0, 100)
loadingContainer.BackgroundTransparency = 1
loadingContainer.Parent = blackFrame

-- Loading text
local loadingText = Instance.new("TextLabel")
loadingText.Name = "LoadingText"
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.Position = UDim2.new(0, 0, 0, 0)
loadingText.BackgroundTransparency = 1
loadingText.Font = Enum.Font.GothamBold
loadingText.Text = "Loading"
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextSize = 32
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.TextYAlignment = Enum.TextYAlignment.Center
loadingText.Parent = loadingContainer

-- ==================== ANIMATED DOTS ====================

local dotCount = 0
local dotAnimation = nil

local function animateDots()
	dotAnimation = RunService.Heartbeat:Connect(function()
		dotCount = (dotCount + 0.03) % 4 -- Cycle through 0-3
		local dots = string.rep(".", math.floor(dotCount))
		loadingText.Text = "Loading" .. dots
	end)
end

-- Start dot animation
animateDots()

-- ==================== LOADING CHECKS ====================

local loadingSteps = {
	{name = "Character", check = function() 
		return player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid")
	end},
	
	{name = "Modules", check = function()
		local modules = ReplicatedStorage:FindFirstChild("Modules")
		if not modules then return false end
		
		local swordConfig = modules:FindFirstChild("SwordConfig")
		local soundConfig = modules:FindFirstChild("SoundConfig")
		
		return swordConfig ~= nil and soundConfig ~= nil
	end},
	
	{name = "Assets", check = function()
		local toolSwords = ReplicatedStorage:FindFirstChild("ToolSwords")
		local holsteredModels = ReplicatedStorage:FindFirstChild("HolsteredModels")
		local vfModels = ReplicatedStorage:FindFirstChild("VFmodels")
		
		return toolSwords ~= nil and holsteredModels ~= nil and vfModels ~= nil
	end},
	
	{name = "RemoteEvents", check = function()
		local swordRemotes = ReplicatedStorage:FindFirstChild("SwordRemotes")
		local crateRemotes = ReplicatedStorage:FindFirstChild("CrateRemotes")
		local updateKing = ReplicatedStorage:FindFirstChild("UpdateKing")
		local roundStatus = ReplicatedStorage:FindFirstChild("RoundStatus")
		
		return swordRemotes ~= nil and crateRemotes ~= nil and updateKing ~= nil and roundStatus ~= nil
	end},
	
	{name = "ClientScripts", check = function()
		-- Check if essential client scripts have loaded
		return _G.ClientSoundHandler ~= nil
	end},
	
	{name = "PlayerData", check = function()
		-- Check if leaderstats are ready
		return player:FindFirstChild("leaderstats") ~= nil
	end},
}

-- ==================== WAIT FOR EVERYTHING ====================

local function waitForGameReady()
	print("[LOADING] Checking game systems...")
	
	local startTime = tick()
	local maxWaitTime = 30 -- Maximum 30 seconds (safety timeout)
	
	-- Wait for each loading step
	for i, step in ipairs(loadingSteps) do
		local stepStartTime = tick()
		local maxStepWait = 10 -- Max 10 seconds per step
		
		print("[LOADING] Waiting for:", step.name)
		
		while not step.check() do
			task.wait(0.1)
			
			-- Safety timeout for individual step
			if tick() - stepStartTime > maxStepWait then
				warn("[LOADING] Timeout waiting for:", step.name, "- Continuing anyway")
				break
			end
			
			-- Global timeout
			if tick() - startTime > maxWaitTime then
				warn("[LOADING] Global timeout reached - Starting game anyway")
				return
			end
		end
		
		print("[LOADING] ✓", step.name, "ready!")
	end
	
	-- Additional small delay to ensure everything is truly settled
	print("[LOADING] All systems ready! Final check...")
	task.wait(0.5)
	
	local totalTime = tick() - startTime
	print("[LOADING] Loading complete in", string.format("%.2f", totalTime), "seconds")
end

-- ==================== MAIN LOADING SEQUENCE ====================

task.spawn(function()
	-- Wait for everything to be ready
	waitForGameReady()
	
	-- Stop dot animation
	if dotAnimation then
		dotAnimation:Disconnect()
		dotAnimation = nil
	end
	
	-- Change text to "Ready!"
	loadingText.Text = "Ready!"
	
	-- Wait a moment
	task.wait(0.3)
	
	-- Fade out the loading screen
	local fadeOutTween = TweenService:Create(
		blackFrame,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{BackgroundTransparency = 1}
	)
	
	local textFadeTween = TweenService:Create(
		loadingText,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{TextTransparency = 1}
	)
	
	fadeOutTween:Play()
	textFadeTween:Play()
	
	-- Wait for fade to complete
	fadeOutTween.Completed:Wait()
	
	-- Remove the loading GUI
	task.wait(0.2)
	loadingGui:Destroy()
	
	print("[LOADING] Loading screen removed - Game ready!")
end)

-- ==================== SAFETY CLEANUP ====================

-- Emergency timeout: Remove loading screen after 35 seconds no matter what
task.delay(35, function()
	if loadingGui and loadingGui.Parent then
		warn("[LOADING] Emergency timeout - Forcing loading screen removal!")
		
		if dotAnimation then
			dotAnimation:Disconnect()
		end
		
		loadingGui:Destroy()
	end
end)
