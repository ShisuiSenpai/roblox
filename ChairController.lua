--[[
	Chair Controller - Multiplayer Version
	
	SETUP:
	Place this Script in EACH of your 6 chairs
	Each chair should be named Chair1, Chair2, etc. and be in "TypingChairs" folder
--]]

-- Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get components
local chair = script.Parent
local seat = chair:WaitForChild("Seat")
local proximityPrompt = chair:WaitForChild("Part1"):WaitForChild("ProximityPrompt")

-- Get chair number from name (Chair1 = 1, Chair2 = 2, etc.)
local chairNumber = tonumber(chair.Name:match("%d+")) or 1

-- Configuration
proximityPrompt.ActionText = "Join Race"
proximityPrompt.ObjectText = "Chair " .. chairNumber
proximityPrompt.HoldDuration = 0
proximityPrompt.MaxActivationDistance = 10

-- Track current occupant
local currentOccupant = nil
local seatLocked = false
local reseatConnection = nil

-- Get server events
local ServerScriptService = game:GetService("ServerScriptService")

-- Create/Get BindableEvent for server-to-server communication
local matchEvent = ServerScriptService:FindFirstChild("MatchBindable")
if not matchEvent then
	matchEvent = Instance.new("BindableEvent")
	matchEvent.Name = "MatchBindable"
	matchEvent.Parent = ServerScriptService
end

-- Remote Events
local typingRemote = ReplicatedStorage:FindFirstChild("TypingTestRemote")
if not typingRemote then
	typingRemote = Instance.new("RemoteEvent")
	typingRemote.Name = "TypingTestRemote"
	typingRemote.Parent = ReplicatedStorage
end

-- Function to lock player in seat
local function lockPlayerToSeat(player)
	if not player or not player.Character then return end
	
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if not humanoidRootPart or not humanoid then return end
	
	seatLocked = true
	
	-- Disable jumping
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.Sit = true
	
	-- Monitor and keep locked
	if reseatConnection then
		reseatConnection:Disconnect()
	end
	
	reseatConnection = RunService.Heartbeat:Connect(function()
		if seatLocked and currentOccupant == player then
			if humanoid and humanoid.Health > 0 then
				humanoid.JumpPower = 0
				humanoid.JumpHeight = 0
				
				if not humanoid.Sit or seat.Occupant ~= humanoid then
					humanoid.Sit = true
					seat:Sit(humanoid)
				end
			end
		end
	end)
	
	print("🔒 Player", player.Name, "locked to chair", chairNumber)
end

-- Function to unlock player from seat
local function unlockPlayerFromSeat(player)
	seatLocked = false
	
	if reseatConnection then
		reseatConnection:Disconnect()
		reseatConnection = nil
	end
	
	if player and player.Character then
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.JumpPower = 50
			humanoid.JumpHeight = 7.2
		end
	end
	
	print("🔓 Player unlocked from chair", chairNumber)
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
	
	-- Wait for seat to register
	task.wait(0.1)
	
	-- Lock them
	lockPlayerToSeat(player)

	-- Notify match controller (server-to-server)
	matchEvent:Fire("PlayerJoin", player, chairNumber)
	
	-- Fire event to client to show UI
	typingRemote:FireClient(player, "ShowUI", seat)
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
		local player = currentOccupant
		
		-- Always unlock when leaving
		unlockPlayerFromSeat(player)
		
		-- Notify match controller (server-to-server)
		matchEvent:Fire("PlayerLeave", player)
		
		-- Hide UI
		typingRemote:FireClient(player, "HideUI")
		
		currentOccupant = nil
	end
end

-- Handle events from typing client
typingRemote.OnServerEvent:Connect(function(player, action)
	if player ~= currentOccupant then return end
	
	if action == "Timeout" then
		-- Unlock and kick player from chair
		print("⏱ Timeout for", player.Name)
		unseatPlayer(player)
		currentOccupant = nil
		
	elseif action == "UnlockSeat" then
		-- Client requests unlock (death/UI close)
		unlockPlayerFromSeat(player)
	end
end)

-- Connect proximity prompt
proximityPrompt.Triggered:Connect(sitPlayer)

-- Monitor seat occupancy
seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if not seat.Occupant and not seatLocked then
		onSeatLeft()
	elseif not seat.Occupant and seatLocked and currentOccupant then
		-- Force back if locked
		task.wait(0.05)
		if currentOccupant and currentOccupant.Character then
			local humanoid = currentOccupant.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Sit = true
				seat:Sit(humanoid)
			end
		end
	end
end)

-- Listen for unlock all command from match controller
matchEvent.Event:Connect(function(action)
	if action == "UnlockAll" then
		-- Force unlock this chair's player
		if currentOccupant then
			print("🔓 Force unlock chair", chairNumber)
			unlockPlayerFromSeat(currentOccupant)
		end
	end
end)

print("🪑 Chair", chairNumber, "controller ready!")
