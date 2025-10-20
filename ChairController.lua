--[[
	Chair Controller - Server Script with Timeout Handling
	
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

	-- Fire event to client to show UI (send seat reference)
	local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
	if remoteEvent then
		remoteEvent:FireClient(player, "ShowUI", seat)
	end
end

-- Function to handle player leaving seat
local function onSeatLeft()
	if currentOccupant then
		local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
		if remoteEvent then
			remoteEvent:FireClient(currentOccupant, "HideUI")
		end
		currentOccupant = nil
	end
end

-- Handle timeout from client
local function onServerEvent(player, action)
	if action == "Timeout" then
		-- Kick player from chair if they're the current occupant
		if player == currentOccupant then
			unseatPlayer(player)
			onSeatLeft()
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
