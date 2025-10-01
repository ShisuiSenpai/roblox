--[[
    SPAWN TEST OBJECTS SCRIPT
    Place this script in ServerScriptService (can delete after spawning objects)
    
    This will spawn several colorful, grabbable objects in front of your spawn point
    for testing the Gravity Gun!
]]

wait(2) -- Wait for game to load

local workspace = game:GetService("Workspace")

-- Clear any existing test objects
local existingFolder = workspace:FindFirstChild("GravityGunTestObjects")
if existingFolder then
    existingFolder:Destroy()
end

-- Create folder to organize test objects
local testFolder = Instance.new("Folder")
testFolder.Name = "GravityGunTestObjects"
testFolder.Parent = workspace

print("Spawning Gravity Gun test objects...")

-- Function to create a test object
local function createTestObject(name, position, size, color, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Color = color
    part.Material = Enum.Material.Neon
    part.Anchored = false
    part.CanCollide = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    
    if shape == "Ball" then
        part.Shape = Enum.PartType.Ball
    elseif shape == "Cylinder" then
        part.Shape = Enum.PartType.Cylinder
    end
    
    part.Parent = testFolder
    return part
end

-- Spawn position (in front of spawn)
local spawnX = 0
local spawnY = 10
local spawnZ = 10

-- Create various test objects
createTestObject("Cyan Cube", Vector3.new(spawnX - 10, spawnY, spawnZ), Vector3.new(4, 4, 4), Color3.fromRGB(0, 255, 255), "Block")
createTestObject("Purple Ball", Vector3.new(spawnX - 5, spawnY, spawnZ), Vector3.new(3, 3, 3), Color3.fromRGB(170, 0, 255), "Ball")
createTestObject("Green Cylinder", Vector3.new(spawnX, spawnY, spawnZ), Vector3.new(3, 5, 3), Color3.fromRGB(0, 255, 0), "Cylinder")
createTestObject("Red Cube", Vector3.new(spawnX + 5, spawnY, spawnZ), Vector3.new(4, 4, 4), Color3.fromRGB(255, 0, 0), "Block")
createTestObject("Yellow Cube", Vector3.new(spawnX + 10, spawnY, spawnZ), Vector3.new(3, 3, 3), Color3.fromRGB(255, 255, 0), "Block")

-- Create a small one
createTestObject("Tiny Orange Ball", Vector3.new(spawnX, spawnY + 8, spawnZ), Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(255, 150, 0), "Ball")

-- Create a large one
createTestObject("Big Blue Cube", Vector3.new(spawnX, spawnY, spawnZ + 10), Vector3.new(6, 6, 6), Color3.fromRGB(0, 100, 255), "Block")

-- Create some wedges and other shapes at different heights
local wedge1 = Instance.new("WedgePart")
wedge1.Name = "Pink Wedge"
wedge1.Size = Vector3.new(4, 4, 4)
wedge1.Position = Vector3.new(spawnX - 8, spawnY + 5, spawnZ + 5)
wedge1.Color = Color3.fromRGB(255, 0, 255)
wedge1.Material = Enum.Material.Neon
wedge1.Anchored = false
wedge1.Parent = testFolder

local cornerWedge = Instance.new("CornerWedgePart")
cornerWedge.Name = "White Corner"
cornerWedge.Size = Vector3.new(3, 3, 3)
cornerWedge.Position = Vector3.new(spawnX + 8, spawnY + 5, spawnZ + 5)
cornerWedge.Color = Color3.fromRGB(255, 255, 255)
cornerWedge.Material = Enum.Material.Neon
cornerWedge.Anchored = false
cornerWedge.Parent = testFolder

print("✅ Spawned " .. #testFolder:GetChildren() .. " test objects successfully!")
print("Look for the colorful neon objects floating in front of spawn!")
print("Try grabbing them with your Gravity Gun!")
