--[[
	Chair Controller - WELD-BASED Seat Lock System
	
	SETUP:
	Place this Script (NOT LocalScript) inside the Chair model in Workspace
	
	Required hierarchy:
	Chair (Model)
	  ├─ Seat (Seat)
	  ├─ Part1 (Part - contains ProximityPrompt)
	  │   └─ ProximityPrompt
	  └─ ChairController (This Script)
--]]

-- Get components
local chair = script.Parent
local seat = chair:WaitForChild("Seat")
local proximityPrompt = chair:WaitForChild("Part1"):WaitForChild("ProximityPrompt")

-- Configuration
proximityPrompt.ActionText = "Sit"
proximityPrompt.ObjectText = "Typing Chair"
proximityPrompt.HoldDuration = 0
proximityPrompt.MaxActivationDistance = 10

-- Track current occupant
local currentOccupant = nil
local seatWeld = nil

-- Function to lock player in seat with WELD
local function lockPlayerToSeat(player)
	if not player or not player.Character then return end
	
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if not humanoidRootPart or not humanoid then return end
	
	-- Create weld to physically attach player to seat
	local weld = Instance.new("WeldConstraint")
	weld.Name = "SeatLock"
	weld.Part0 = seat
	weld.Part1 = humanoidRootPart
	weld.Parent = seat
	
	seatWeld = weld
	
	-- Disable jumping
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	
	-- Set to sitting state
	humanoid.Sit = true
	
	print("🔒 Player locked to seat with WELD")
end

-- Function to unlock player from seat
local function unlockPlayerFromSeat(player)
	-- Destroy the weld
	if seatWeld then
		seatWeld:Destroy()
		seatWeld = nil
		print("🔓 Weld destroyed - player unlocked")
	end
	
	-- Re-enable jumping
	if player and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.JumpPower = 50
			humanoid.JumpHeight = 7.2
		end
	end
end

-- Function to sit player
local function sitPlayer(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Prevent if someone is already sitting
	if seat.Occupant then return end

	-- Sit the player
	seat:Sit(humanoid)
	currentOccupant = player
	
	-- Wait a tiny bit for seat to actually sit them
	task.wait(0.1)
	
	-- Lock them with weld
	lockPlayerToSeat(player)

	-- Fire event to client to show UI
	local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
	if remoteEvent then
		remoteEvent:FireClient(player, "ShowUI", seat)
	end
end

-- Function to unseat player
local function unseatPlayer(player)
	if not player or not player.Character then return end
	
	-- Unlock first
	unlockPlayerFromSeat(player)
	
	-- Then unseat
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Sit = false
		task.wait(0.1)
		humanoid.Jump = true
	end
end

-- Function to handle player leaving seat
local function onSeatLeft()
	if currentOccupant then
		-- Always unlock when leaving
		unlockPlayerFromSeat(currentOccupant)
		
		-- Hide UI
		local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
		if remoteEvent then
			remoteEvent:FireClient(currentOccupant, "HideUI")
		end
		
		currentOccupant = nil
	end
end

-- Handle events from client
local function onServerEvent(player, action)
	if action == "Timeout" then
		-- Unlock and kick player from chair
		if player == currentOccupant then
			print("⏱ Timeout - kicking player")
			unseatPlayer(player)
			currentOccupant = nil
		end
	elseif action == "UnlockSeat" then
		-- Client requests unlock (death/UI close)
		if player == currentOccupant then
			print("🔓 Unlock request from client")
			unlockPlayerFromSeat(player)
		end
	end
end

-- Connect proximity prompt
proximityPrompt.Triggered:Connect(sitPlayer)

-- Monitor seat occupancy
seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if not seat.Occupant then
		onSeatLeft()
	end
end)

-- Create RemoteEvent if it doesn't exist
local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "TypingTestRemote"
	remoteEvent.Parent = game.ReplicatedStorage
end

-- Connect server event handler
remoteEvent.OnServerEvent:Connect(onServerEvent)
