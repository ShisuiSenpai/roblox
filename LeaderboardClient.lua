--[[
	Leaderboard Client - Multiplayer Typing Race
	
	SETUP:
	Place this LocalScript in StarterPlayer > StarterPlayerScripts
	
	Shows real-time leaderboard with all players
--]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local matchRemote = ReplicatedStorage:WaitForChild("MatchRemote")

local screenGui = nil
local leaderboardFrame = nil
local playerSlots = {}
local roundLabel = nil
local MAX_PLAYERS = 6

-- Create leaderboard UI
local function createLeaderboard()
	-- Main ScreenGui
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LeaderboardUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player.PlayerGui

	-- Main frame (container)
	leaderboardFrame = Instance.new("Frame")
	leaderboardFrame.Name = "LeaderboardFrame"
	leaderboardFrame.Size = UDim2.new(0, 320, 0, 500)
	leaderboardFrame.Position = UDim2.new(1, -340, 0, 20)
	leaderboardFrame.AnchorPoint = Vector2.new(0, 0)
	leaderboardFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	leaderboardFrame.BackgroundTransparency = 0.7
	leaderboardFrame.BorderSizePixel = 0
	leaderboardFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = leaderboardFrame

	local glow = Instance.new("UIStroke")
	glow.Color = Color3.fromRGB(100, 200, 255)
	glow.Thickness = 1
	glow.Transparency = 0.6
	glow.Parent = leaderboardFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "TYPING RACE"
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Parent = leaderboardFrame

	-- Round label
	roundLabel = Instance.new("TextLabel")
	roundLabel.Name = "RoundLabel"
	roundLabel.Size = UDim2.new(1, 0, 0, 25)
	roundLabel.Position = UDim2.new(0, 0, 0, 40)
	roundLabel.BackgroundTransparency = 1
	roundLabel.Text = "Waiting for players..."
	roundLabel.Font = Enum.Font.GothamMedium
	roundLabel.TextSize = 14
	roundLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	roundLabel.TextXAlignment = Enum.TextXAlignment.Center
	roundLabel.Parent = leaderboardFrame

	-- Divider
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -20, 0, 1)
	divider.Position = UDim2.new(0, 10, 0, 70)
	divider.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
	divider.BackgroundTransparency = 0.7
	divider.BorderSizePixel = 0
	divider.Parent = leaderboardFrame

	-- Player slots container
	local slotsContainer = Instance.new("Frame")
	slotsContainer.Name = "SlotsContainer"
	slotsContainer.Size = UDim2.new(1, 0, 1, -75)
	slotsContainer.Position = UDim2.new(0, 0, 0, 75)
	slotsContainer.BackgroundTransparency = 1
	slotsContainer.Parent = leaderboardFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = slotsContainer

	-- Create 6 player slots
	for i = 1, MAX_PLAYERS do
		local slot = createPlayerSlot(i)
		slot.Parent = slotsContainer
		playerSlots[i] = slot
	end
end

-- Create individual player slot
function createPlayerSlot(slotNumber)
	local slotFrame = Instance.new("Frame")
	slotFrame.Name = "Slot" .. slotNumber
	slotFrame.Size = UDim2.new(1, -20, 0, 65)
	slotFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	slotFrame.BackgroundTransparency = 0.95
	slotFrame.BorderSizePixel = 0
	slotFrame.LayoutOrder = slotNumber

	local slotCorner = Instance.new("UICorner")
	slotCorner.CornerRadius = UDim.new(0, 8)
	slotCorner.Parent = slotFrame

	-- Status indicator (colored circle)
	local statusIndicator = Instance.new("Frame")
	statusIndicator.Name = "StatusIndicator"
	statusIndicator.Size = UDim2.new(0, 12, 0, 12)
	statusIndicator.Position = UDim2.new(0, 10, 0.5, -6)
	statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	statusIndicator.BorderSizePixel = 0
	statusIndicator.Parent = slotFrame

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = statusIndicator

	-- Profile image
	local profileImage = Instance.new("ImageLabel")
	profileImage.Name = "ProfileImage"
	profileImage.Size = UDim2.new(0, 40, 0, 40)
	profileImage.Position = UDim2.new(0, 30, 0.5, -20)
	profileImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	profileImage.BorderSizePixel = 0
	profileImage.Image = ""
	profileImage.Parent = slotFrame

	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(1, 0)
	imageCorner.Parent = profileImage

	-- Player name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, -85, 0, 20)
	nameLabel.Position = UDim2.new(0, 75, 0, 8)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Empty Slot"
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = slotFrame

	-- WPM label
	local wpmLabel = Instance.new("TextLabel")
	wpmLabel.Name = "WPMLabel"
	wpmLabel.Size = UDim2.new(0, 80, 0, 18)
	wpmLabel.Position = UDim2.new(0, 75, 0, 30)
	wpmLabel.BackgroundTransparency = 1
	wpmLabel.Text = "-- WPM"
	wpmLabel.Font = Enum.Font.GothamMedium
	wpmLabel.TextSize = 12
	wpmLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
	wpmLabel.TextXAlignment = Enum.TextXAlignment.Left
	wpmLabel.Parent = slotFrame

	-- Time label
	local timeLabel = Instance.new("TextLabel")
	timeLabel.Name = "TimeLabel"
	timeLabel.Size = UDim2.new(1, -165, 0, 18)
	wpmLabel.Position = UDim2.new(0, 160, 0, 30)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = ""
	timeLabel.Font = Enum.Font.GothamMedium
	timeLabel.TextSize = 11
	timeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	timeLabel.TextXAlignment = Enum.TextXAlignment.Left
	timeLabel.Parent = slotFrame

	return slotFrame
end

-- Update player slot with data
local function updateSlot(slotNumber, data)
	local slot = playerSlots[slotNumber]
	if not slot then return end

	local statusIndicator = slot:FindFirstChild("StatusIndicator")
	local profileImage = slot:FindFirstChild("ProfileImage")
	local nameLabel = slot:FindFirstChild("NameLabel")
	local wpmLabel = slot:FindFirstChild("WPMLabel")
	local timeLabel = slot:FindFirstChild("TimeLabel")

	if data.status == "empty" then
		-- Empty slot
		statusIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		profileImage.Image = ""
		profileImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		nameLabel.Text = "Empty Slot"
		nameLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
		wpmLabel.Text = "-- WPM"
		wpmLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
		timeLabel.Text = ""
		slot.BackgroundTransparency = 0.98

	else
		-- Player in slot
		profileImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. data.userId .. "&w=150&h=150"
		profileImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Text = data.playerName
		nameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)

		-- Status color
		if data.status == "completed" then
			statusIndicator.BackgroundColor3 = Color3.fromRGB(100, 255, 150) -- Green
			slot.BackgroundTransparency = 0.90
			wpmLabel.Text = data.wpm .. " WPM"
			wpmLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
			timeLabel.Text = "✓ " .. string.format("%.1fs", data.completionTime)
			timeLabel.TextColor3 = Color3.fromRGB(100, 255, 150)

		elseif data.status == "failed" then
			statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100) -- Red
			slot.BackgroundTransparency = 0.95
			wpmLabel.Text = "-- WPM"
			wpmLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			timeLabel.Text = "✗ Eliminated"
			timeLabel.TextColor3 = Color3.fromRGB(255, 100, 100)

		elseif data.status == "typing" then
			statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 200, 100) -- Yellow
			slot.BackgroundTransparency = 0.92
			wpmLabel.Text = data.wpm .. " WPM"
			wpmLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
			timeLabel.Text = "⚡ Typing..."
			timeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)

		elseif data.status == "waiting" then
			statusIndicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150) -- Gray
			slot.BackgroundTransparency = 0.95
			wpmLabel.Text = "-- WPM"
			wpmLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
			timeLabel.Text = "Waiting..."
			timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		end
	end
end

-- Update entire leaderboard
local function updateLeaderboard(leaderboardData, round, timeLimit)
	if not leaderboardFrame then return end

	-- Update round label
	if round and round > 0 then
		roundLabel.Text = "Round " .. round .. " | " .. timeLimit .. "s"
	end

	-- Update all slots
	for i = 1, MAX_PLAYERS do
		if leaderboardData[i] then
			updateSlot(i, leaderboardData[i])
		end
	end
end

-- Handle lobby countdown
local function onLobbyCountdown(timeLeft)
	if roundLabel then
		roundLabel.Text = "Starting in " .. timeLeft .. "..."
	end
end

-- Handle match end
local function onMatchEnd(winnerName, winnerUserId)
	if roundLabel then
		if winnerName then
			roundLabel.Text = "🏆 " .. winnerName .. " WINS!"
			roundLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		else
			roundLabel.Text = "Match ended - Draw!"
			roundLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	-- Flash winner slot
	if winnerUserId and winnerUserId > 0 then
		for i, slot in pairs(playerSlots) do
			local profileImage = slot:FindFirstChild("ProfileImage")
			if profileImage and profileImage.Image:find(tostring(winnerUserId)) then
				-- Flash animation
				for j = 1, 3 do
					slot.BackgroundTransparency = 0.5
					task.wait(0.3)
					slot.BackgroundTransparency = 0.9
					task.wait(0.3)
				end
			end
		end
	end
end

-- Listen to match events
matchRemote.OnClientEvent:Connect(function(action, ...)
	if action == "UpdateLeaderboard" then
		local leaderboardData, round, timeLimit = ...
		updateLeaderboard(leaderboardData, round, timeLimit)

	elseif action == "LobbyCountdown" then
		local timeLeft = ...
		onLobbyCountdown(timeLeft)

	elseif action == "MatchEnd" then
		local winnerName, winnerUserId = ...
		onMatchEnd(winnerName, winnerUserId)
	end
end)

-- Create UI on load
task.wait(1)
createLeaderboard()

print("📊 Leaderboard initialized!")
