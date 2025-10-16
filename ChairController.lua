--[[
	Chair Controller - Server Script
	
	SETUP:
	Place this Script (NOT LocalScript) inside the Chair model in Workspace
	
	Required hierarchy:
	Chair (Model)
	  ├─ Seat (Seat)
	  ├─ ProximityPrompt (ProximityPrompt)
	  └─ ChairController (This Script)
--]]

-- Get components
local chair = script.Parent
local seat = chair:WaitForChild("Seat")
local proximityPrompt = chair:WaitForChild("ProximityPrompt")

-- Configuration
proximityPrompt.ActionText = "Sit"
proximityPrompt.ObjectText = "Chair"
proximityPrompt.HoldDuration = 0
proximityPrompt.MaxActivationDistance = 10

-- Track current occupant
local currentOccupant = nil

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
	
	-- Fire event to client to show UI
	local remoteEvent = game.ReplicatedStorage:FindFirstChild("TypingTestRemote")
	if remoteEvent then
		remoteEvent:FireClient(player, "ShowUI")
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

-- Connect proximity prompt
proximityPrompt.Triggered:Connect(sitPlayer)

-- Monitor seat occupancy
seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	if not seat.Occupant then
		onSeatLeft()
	end
end)

-- Create RemoteEvent if it doesn't exist
if not game.ReplicatedStorage:FindFirstChild("TypingTestRemote") then
	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "TypingTestRemote"
	remoteEvent.Parent = game.ReplicatedStorage
end
