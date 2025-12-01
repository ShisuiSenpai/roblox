--[[
	Jump Pad - CLIENT SCRIPT
	Place this in StarterPlayer > StarterPlayerScripts
	
	Responsibilities:
	- Receive jump commands from server
	- Apply physics changes locally (smooth, instant, no lag)
	- Handle the actual force application
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Wait for RemoteEvent
local jumpPadEvent = ReplicatedStorage:WaitForChild("JumpPadEvent")

-- Configuration for how the jump feels
local HORIZONTAL_PRESERVATION = 0.9  -- Keep 90% of horizontal speed (feels natural)
local IMPULSE_DURATION = 0.15        -- How long the force applies (seconds)

-- Apply the jump force - this runs on CLIENT for smooth, instant response
local function applyJump(jumpStrength)
	-- Get current velocity
	local currentVel = humanoidRootPart.AssemblyLinearVelocity
	
	-- IMPULSE-STYLE: Add to vertical velocity instead of replacing it
	-- This feels much more natural and responsive
	local newVelocity = Vector3.new(
		currentVel.X * HORIZONTAL_PRESERVATION,  -- Keep most horizontal speed
		currentVel.Y + jumpStrength,              -- ADD to vertical (impulse!)
		currentVel.Z * HORIZONTAL_PRESERVATION   -- Keep most horizontal speed  
	)
	
	-- Apply velocity locally (instant, no server round-trip)
	humanoidRootPart.AssemblyLinearVelocity = newVelocity
	
	-- Set humanoid state for better animation
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

-- Listen for jump pad activation from server
jumpPadEvent.OnClientEvent:Connect(function(jumpStrength)
	applyJump(jumpStrength)
end)

-- Handle respawns
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
end)

print("✅ Jump Pad Client ready!")
