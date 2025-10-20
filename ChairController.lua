--[[
	Chair Controller - Server Script with Seat Lock
	
	SETUP:
	Place this Script (NOT LocalScript) inside the Chair model in Workspace
	
	Required hierarchy:
	Chair (Model)
	  ├─ Seat (Seat)
	  ├─ Part1 (Part - contains ProximityPrompt)
	  │   └─ ProximityPrompt
	  └─ ChairController (This Script)
--]]

-- Services
local RunService = game:GetService("RunService")

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
local seatLocked = false
local reseatConnection = nil

-- Function to unseat player
local function unseatPlayer(player)
	if not player or not player.Character then return end
	
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Sit = false
		humanoid.Jump = true
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
	seatLocked = true
	
	-- Disable jumping for the humanoid
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	
	-- Set humanoid to seated state and lock it
	humanoid.Sit = true
	
	-- Monitor and force player to stay seated (server-side enforcement)
	if reseatConnection then
		reseatConnection:Disconnect()
	end
	
	reseatConnection = RunService.Heartbeat:Connect(function()
		if seatLocked and currentOccupant == player then
			-- Force seated state
			if humanoid and humanoid.Health > 0 then
				-- Prevent jumping every frame
				humanoid.JumpPower = 0
				humanoid.JumpHeight = 0
				
				-- If not sitting anymore, force back
				if not humanoid.Sit or seat.Occupant ~= humanoid then
					humanoid.Sit = true
					seat:Sit(humanoid)
				end
			end
		end
	end)

	-- Fire event to client to show UI (send seat reference)
	local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
	if remoteEvent then
		remoteEvent:FireClient(player, "ShowUI", seat)
	end
end

-- Function to handle player leaving seat
local function onSeatLeft()
	-- Only allow leaving if seat is unlocked
	if not seatLocked then
		if currentOccupant then
			local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
			if remoteEvent then
				remoteEvent:FireClient(currentOccupant, "HideUI")
			end
			currentOccupant = nil
		end
	else
		-- Seat is locked - force player back
		if currentOccupant and currentOccupant.Character then
			local humanoid = currentOccupant.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				task.wait(0.05)
				humanoid.Sit = true
				seat:Sit(humanoid)
			end
		end
	end
end

-- Handle events from client
local function onServerEvent(player, action)
	if action == "Timeout" then
		-- Unlock and kick player from chair
		if player == currentOccupant then
			seatLocked = false
			
			-- Stop monitoring
			if reseatConnection then
				reseatConnection:Disconnect()
				reseatConnection = nil
			end
			
			-- Re-enable jumping
			if player.Character then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.JumpPower = 50
					humanoid.JumpHeight = 7.2
				end
			end
			
			unseatPlayer(player)
			currentOccupant = nil
		end
	elseif action == "UnlockSeat" then
		-- Client requests unlock (death/UI close)
		if player == currentOccupant then
			seatLocked = false
			
			-- Stop monitoring
			if reseatConnection then
				reseatConnection:Disconnect()
				reseatConnection = nil
			end
			
			-- Re-enable jumping
			if player.Character then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.JumpPower = 50
					humanoid.JumpHeight = 7.2
				end
			end
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
