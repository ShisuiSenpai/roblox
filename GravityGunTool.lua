--[[
    GRAVITY GUN TOOL - Main Script
    Place this script inside a Tool object in ReplicatedStorage
    
    This is the main client-side script that handles:
    - Mouse input detection
    - Tool activation/deactivation
    - Communication with server and local effects
]]

local Tool = script.Parent
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("Gravity Gun Tool: Starting to load...")

-- Wait for RemoteEvents to be created
local GravityEvent = ReplicatedStorage:WaitForChild("GravityGunEvent", 10)
local EffectsEvent = ReplicatedStorage:WaitForChild("GravityGunEffects", 10)

if not GravityEvent or not EffectsEvent then
    warn("Gravity Gun Tool: RemoteEvents not found! Make sure server script is running.")
    return
end

print("Gravity Gun Tool: Loaded successfully!")

-- Configuration
local MAX_DISTANCE = 50 -- Maximum distance to grab objects
local HOLD_DISTANCE = 10 -- Distance to hold object in front of player
local THROW_POWER = 100 -- Power multiplier for throwing

-- State variables
local equippedTool = false
local heldObject = nil
local isHolding = false

-- Visual feedback
local function createHighlight(part)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = part
    highlight.FillColor = Color3.fromRGB(0, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = part
    return highlight
end

local currentHighlight = nil

-- Update held object position
local function updateHeldObject()
    if isHolding and heldObject and heldObject.Parent then
        local camera = workspace.CurrentCamera
        local targetPos = camera.CFrame.Position + camera.CFrame.LookVector * HOLD_DISTANCE
        
        -- Send position update to server
        GravityEvent:FireServer("UpdatePosition", heldObject, targetPos)
    end
end

-- Mouse movement for highlighting
local highlightConnection
local function onMouseMoved()
    if not equippedTool or isHolding then 
        if currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
        return 
    end
    
    local target = Mouse.Target
    if target and target.Parent and target:IsA("BasePart") then
        -- Check if it's a valid grabbable object
        local model = target:FindFirstAncestorOfClass("Model")
        if model and not model:FindFirstChildOfClass("Humanoid") then
            if not currentHighlight or currentHighlight.Adornee ~= target then
                if currentHighlight then
                    currentHighlight:Destroy()
                end
                currentHighlight = createHighlight(target)
            end
        elseif target.Parent == workspace and target.Anchored == false then
            if not currentHighlight or currentHighlight.Adornee ~= target then
                if currentHighlight then
                    currentHighlight:Destroy()
                end
                currentHighlight = createHighlight(target)
            end
        else
            if currentHighlight then
                currentHighlight:Destroy()
                currentHighlight = nil
            end
        end
    else
        if currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
    end
end

-- Tool activated (left click)
Tool.Activated:Connect(function()
    print("Gravity Gun: Tool activated!")
    if not isHolding then
        -- Try to grab object
        local target = Mouse.Target
        print("Gravity Gun: Target =", target)
        if target and target:IsA("BasePart") and target.Position then
            if Player.Character and Player.Character:FindFirstChild("Head") then
                local distance = (target.Position - Player.Character.Head.Position).Magnitude
                print("Gravity Gun: Distance =", distance)
                if distance <= MAX_DISTANCE then
                    -- Request server to grab object
                    print("Gravity Gun: Requesting grab for", target.Name)
                    GravityEvent:FireServer("Grab", target)
                else
                    print("Gravity Gun: Target too far away!")
                end
            end
        else
            print("Gravity Gun: No valid target")
        end
    else
        -- Throw object
        print("Gravity Gun: Throwing object!")
        local camera = workspace.CurrentCamera
        local throwDirection = camera.CFrame.LookVector
        GravityEvent:FireServer("Throw", heldObject, throwDirection, THROW_POWER)
        isHolding = false
        heldObject = nil
    end
end)

-- Secondary action (right click) - Release without throwing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if equippedTool and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if isHolding and heldObject then
            GravityEvent:FireServer("Release", heldObject)
            isHolding = false
            heldObject = nil
        end
    end
end)

-- Listen for server responses
GravityEvent.OnClientEvent:Connect(function(action, object)
    if action == "GrabSuccess" then
        heldObject = object
        isHolding = true
        if currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
        -- Play local effects
        EffectsEvent:FireServer("Grab", object)
    elseif action == "Released" then
        isHolding = false
        heldObject = nil
    end
end)

-- Tool equipped
Tool.Equipped:Connect(function()
    print("Gravity Gun: Tool equipped!")
    equippedTool = true
    highlightConnection = game:GetService("RunService").RenderStepped:Connect(function()
        onMouseMoved()
        if isHolding then
            updateHeldObject()
        end
    end)
    
    -- Show UI
    local playerGui = Player:WaitForChild("PlayerGui")
    local gravityUI = playerGui:FindFirstChild("GravityGunUI")
    if gravityUI then
        gravityUI.Enabled = true
    end
end)

-- Tool unequipped
Tool.Unequipped:Connect(function()
    equippedTool = false
    if highlightConnection then
        highlightConnection:Disconnect()
    end
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
    end
    if isHolding and heldObject then
        GravityEvent:FireServer("Release", heldObject)
        isHolding = false
        heldObject = nil
    end
    
    -- Hide UI
    local playerGui = Player:WaitForChild("PlayerGui")
    local gravityUI = playerGui:FindFirstChild("GravityGunUI")
    if gravityUI then
        gravityUI.Enabled = false
    end
end)
