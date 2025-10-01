--[[
    GRAVITY GUN SERVER SCRIPT
    Place this script in ServerScriptService
    
    Handles:
    - Server-side physics manipulation
    - Validation of grab/throw requests
    - BodyPosition/BodyGyro management
    - Anti-exploit measures
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create RemoteEvents
local GravityEvent = Instance.new("RemoteEvent")
GravityEvent.Name = "GravityGunEvent"
GravityEvent.Parent = ReplicatedStorage

local EffectsEvent = Instance.new("RemoteEvent")
EffectsEvent.Name = "GravityGunEffects"
EffectsEvent.Parent = ReplicatedStorage

-- Track held objects per player
local heldObjects = {} -- [player] = {object, bodyPosition, bodyGyro}

-- Configuration
local MAX_DISTANCE = 50
local MAX_MASS = 500 -- Maximum mass that can be picked up
local UPDATE_RATE = 0.03 -- Throttle position updates

-- Player data for throttling
local playerData = {}

local function canGrabObject(player, object)
    -- Validation checks
    if not object or not object:IsA("BasePart") then 
        print("Gravity Gun Server: Validation failed - not a BasePart")
        return false 
    end
    
    if object.Anchored then 
        print("Gravity Gun Server: Validation failed - object is anchored")
        return false 
    end
    
    -- Check if object is part of a character
    local model = object:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then 
        print("Gravity Gun Server: Validation failed - object is part of a character")
        return false 
    end
    
    -- Check mass
    local mass = object:GetMass()
    if mass > MAX_MASS then 
        print("Gravity Gun Server: Validation failed - mass too high:", mass)
        return false 
    end
    
    -- Check distance
    if player.Character and player.Character:FindFirstChild("Head") then
        local distance = (object.Position - player.Character.Head.Position).Magnitude
        if distance > MAX_DISTANCE then 
            print("Gravity Gun Server: Validation failed - too far:", distance)
            return false 
        end
    else
        print("Gravity Gun Server: Validation failed - player has no character/head")
        return false
    end
    
    -- Check if already held by someone
    for p, data in pairs(heldObjects) do
        if data.object == object then 
            print("Gravity Gun Server: Validation failed - already held by another player")
            return false 
        end
    end
    
    print("Gravity Gun Server: All validation checks passed!")
    return true
end

local function grabObject(player, object)
    print("Gravity Gun Server: grabObject called for", player.Name, object)
    if not canGrabObject(player, object) then 
        print("Gravity Gun Server: Cannot grab object - validation failed")
        return 
    end
    
    print("Gravity Gun Server: Validation passed, grabbing object")
    
    -- Release any currently held object
    if heldObjects[player] then
        releaseObject(player)
    end
    
    -- Create BodyPosition to hold the object
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.MaxForce = Vector3.new(1, 1, 1) * object:GetMass() * 196.2 * 2
    bodyPos.P = 10000
    bodyPos.D = 500
    bodyPos.Position = object.Position
    bodyPos.Parent = object
    
    -- Create BodyGyro to stabilize rotation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10000
    bodyGyro.P = 3000
    bodyGyro.D = 500
    bodyGyro.CFrame = object.CFrame
    bodyGyro.Parent = object
    
    -- Store reference
    heldObjects[player] = {
        object = object,
        bodyPosition = bodyPos,
        bodyGyro = bodyGyro,
        lastUpdate = tick()
    }
    
    print("Gravity Gun Server: Grab successful!")
    
    -- Notify client
    GravityEvent:FireClient(player, "GrabSuccess", object)
    
    -- Trigger effects
    EffectsEvent:FireAllClients("Grab", object, player.Character)
end

function releaseObject(player)
    local data = heldObjects[player]
    if data then
        if data.bodyPosition then data.bodyPosition:Destroy() end
        if data.bodyGyro then data.bodyGyro:Destroy() end
        heldObjects[player] = nil
        GravityEvent:FireClient(player, "Released")
    end
end

local function updateObjectPosition(player, object, targetPos)
    local data = heldObjects[player]
    if not data or data.object ~= object then return end
    
    -- Throttle updates
    local now = tick()
    if now - data.lastUpdate < UPDATE_RATE then return end
    data.lastUpdate = now
    
    -- Validate distance from player
    if player.Character and player.Character:FindFirstChild("Head") then
        local distance = (targetPos - player.Character.Head.Position).Magnitude
        if distance > MAX_DISTANCE then return end
    end
    
    -- Update position
    if data.bodyPosition and data.bodyPosition.Parent then
        data.bodyPosition.Position = targetPos
    end
end

local function throwObject(player, object, direction, power)
    local data = heldObjects[player]
    if not data or data.object ~= object then return end
    
    -- Clean up constraints
    if data.bodyPosition then data.bodyPosition:Destroy() end
    if data.bodyGyro then data.bodyGyro:Destroy() end
    
    -- Apply velocity
    if object and object.Parent then
        object.Velocity = direction * power
        
        -- Trigger throw effects
        EffectsEvent:FireAllClients("Throw", object, direction)
    end
    
    heldObjects[player] = nil
    GravityEvent:FireClient(player, "Released")
end

-- Handle client requests
GravityEvent.OnServerEvent:Connect(function(player, action, ...)
    print("Gravity Gun Server: Received", action, "from", player.Name)
    if action == "Grab" then
        local object = ...
        print("Gravity Gun Server: Attempting to grab", object)
        grabObject(player, object)
    elseif action == "Release" then
        releaseObject(player)
    elseif action == "UpdatePosition" then
        local object, targetPos = ...
        updateObjectPosition(player, object, targetPos)
    elseif action == "Throw" then
        local object, direction, power = ...
        throwObject(player, object, direction, power)
    end
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    releaseObject(player)
    playerData[player] = nil
end)

print("Gravity Gun Server loaded successfully!")
