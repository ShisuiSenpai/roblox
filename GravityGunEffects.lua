--[[
    GRAVITY GUN EFFECTS - Client Script
    Place this in StarterPlayer > StarterPlayerScripts
    
    Handles all visual and audio effects:
    - Particle effects
    - Beam effects
    - Sound effects
    - Visual feedback
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local EffectsEvent = ReplicatedStorage:WaitForChild("GravityGunEffects")

-- Sound effects
local function createSound(soundId, parent, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.5
    sound.Parent = parent
    return sound
end

-- Particle effect for grabbed objects
local function createGrabEffect(object)
    -- Create attachment for particles
    local attachment = Instance.new("Attachment")
    attachment.Name = "GravityGunAttachment"
    attachment.Parent = object
    
    -- Energy particles
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
    })
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Rate = 50
    particles.Speed = NumberRange.new(2, 4)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Electric effect
    local electric = Instance.new("ParticleEmitter")
    electric.Texture = "rbxasset://textures/particles/smoke_main.dds"
    electric.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
    electric.Size = NumberSequence.new(0.2)
    electric.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    electric.Lifetime = NumberRange.new(0.2, 0.4)
    electric.Rate = 30
    electric.Speed = NumberRange.new(1, 2)
    electric.Parent = attachment
    
    return attachment
end

-- Create beam from player to object
local function createBeamEffect(fromCharacter, toObject)
    if not fromCharacter or not toObject then return end
    
    local fromAttachment = Instance.new("Attachment")
    fromAttachment.Name = "GravityBeamStart"
    local humanoidRootPart = fromCharacter:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    fromAttachment.Parent = humanoidRootPart
    fromAttachment.Position = Vector3.new(0, 1, -2)
    
    local toAttachment = Instance.new("Attachment")
    toAttachment.Name = "GravityBeamEnd"
    toAttachment.Parent = toObject
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = fromAttachment
    beam.Attachment1 = toAttachment
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
    })
    beam.Width0 = 0.5
    beam.Width1 = 0.3
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    beam.FaceCamera = true
    beam.Texture = "rbxasset://textures/particles/smoke_main.dds"
    beam.TextureMode = Enum.TextureMode.Wrap
    beam.TextureSpeed = 3
    beam.TextureLength = 2
    beam.Parent = fromAttachment
    
    return {fromAttachment, toAttachment, beam}
end

-- Throw effect
local function createThrowEffect(object, direction)
    if not object or not object.Parent then return end
    
    -- Trail effect
    local attachment = Instance.new("Attachment")
    attachment.Parent = object
    
    local trail = Instance.new("Trail")
    trail.Attachment0 = attachment
    trail.Attachment1 = attachment
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Lifetime = 0.5
    trail.MinLength = 0.1
    trail.Parent = attachment
    
    -- Burst particles
    local burst = Instance.new("ParticleEmitter")
    burst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    burst.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255))
    burst.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    burst.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    burst.Lifetime = NumberRange.new(0.3, 0.6)
    burst.Speed = NumberRange.new(5, 10)
    burst.SpreadAngle = Vector2.new(30, 30)
    burst.Rate = 0
    burst.Parent = attachment
    burst:Emit(20)
    
    -- Clean up after a few seconds
    game:GetService("Debris"):AddItem(attachment, 2)
    
    -- Sound effect
    local throwSound = createSound("12222030", object, 0.4)
    throwSound:Play()
    game:GetService("Debris"):AddItem(throwSound, 2)
end

-- Active beam tracking
local activeBeams = {}

-- Handle effects from server
EffectsEvent.OnClientEvent:Connect(function(action, object, extra)
    if action == "Grab" then
        -- Create grab effects
        if object and object.Parent then
            local grabEffect = createGrabEffect(object)
            
            -- Create beam if this is from our character
            if extra and extra == Player.Character then
                local beamParts = createBeamEffect(Player.Character, object)
                activeBeams[object] = beamParts
            end
            
            -- Sound effect
            local grabSound = createSound("12222095", object, 0.3)
            grabSound:Play()
            game:GetService("Debris"):AddItem(grabSound, 2)
        end
    elseif action == "Throw" then
        -- Create throw effects
        createThrowEffect(object, extra)
        
        -- Clean up grab effects
        local attachment = object:FindFirstChild("GravityGunAttachment")
        if attachment then
            for _, child in ipairs(attachment:GetChildren()) do
                if child:IsA("ParticleEmitter") then
                    child.Enabled = false
                end
            end
            game:GetService("Debris"):AddItem(attachment, 1)
        end
        
        -- Clean up beam
        if activeBeams[object] then
            for _, part in ipairs(activeBeams[object]) do
                if part then part:Destroy() end
            end
            activeBeams[object] = nil
        end
    end
end)

-- Clean up beams when objects are removed
workspace.DescendantRemoving:Connect(function(descendant)
    if activeBeams[descendant] then
        for _, part in ipairs(activeBeams[descendant]) do
            if part then part:Destroy() end
        end
        activeBeams[descendant] = nil
    end
    
    -- Clean up grab effects
    if descendant:IsA("Attachment") and descendant.Name == "GravityGunAttachment" then
        descendant:Destroy()
    end
end)

print("Gravity Gun Effects loaded!")
