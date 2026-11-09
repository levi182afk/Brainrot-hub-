
-- BrainrotHub V2 - Server
-- Place in ServerScriptService as BrainrotHubServer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local folder = ReplicatedStorage:FindFirstChild("BrainrotHubRemotes")
if not folder then
    folder = Instance.new("Folder")
    folder.Name = "BrainrotHubRemotes"
    folder.Parent = ReplicatedStorage
end

local function getRemote(name, className)
    local remote = folder:FindFirstChild(name)
    if not remote then
        remote = Instance.new(className)
        remote.Name = name
        remote.Parent = folder
    end
    return remote
end

local SavePosition = getRemote("SavePosition", "RemoteFunction")
local TeleportHome = getRemote("TeleportHome", "RemoteFunction")
local SetAutoSteal = getRemote("SetAutoSteal", "RemoteFunction")
local CollectionConfirmed = getRemote("CollectionConfirmed", "RemoteEvent")

-- This event is for YOUR game's server collection code to fire
local collectedEvent = ServerStorage:FindFirstChild("BrainrotHub_Collected")
if not collectedEvent then
    collectedEvent = Instance.new("BindableEvent")
    collectedEvent.Name = "BrainrotHub_Collected"
    collectedEvent.Parent = ServerStorage
end

local savedPositions = {}
local autoStealEnabled = {}
local lastSave = {}
local lastTeleport = {}

local function getRoot(player)
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end

SavePosition.OnServerInvoke = function(player)
    local now = os.clock()
    if lastSave[player] and now - lastSave[player] < 2 then
        return false, "Please wait before saving again."
    end

    local root = getRoot(player)
    if not root then
        return false, "Character not found."
    end

    lastSave[player] = now
    savedPositions[player] = root.CFrame

    return true, "Return position saved!"
end

TeleportHome.OnServerInvoke = function(player)
    local now = os.clock()
    if lastTeleport[player] and now - lastTeleport[player] < 3 then
        return false, "Teleport is on cooldown."
    end

    local destination = savedPositions[player]
    local root = getRoot(player)

    if not destination then
        return false, "Save a position first."
    end

    if not root then
        return false, "Character not found."
    end

    lastTeleport[player] = now
    root.CFrame = destination + Vector3.new(0, 3, 0)

    return true, "Returned to saved position."
end

SetAutoSteal.OnServerInvoke = function(player, enabled)
    if typeof(enabled) ~= "boolean" then
        return false, "Invalid setting."
    end

    if enabled and not savedPositions[player] then
        autoStealEnabled[player] = false
        return false, "Save your return position first."
    end

    autoStealEnabled[player] = enabled
    return true, enabled and "AUTO STEAL enabled." or "AUTO STEAL disabled."
end

-- Only fire this AFTER your game's server has confirmed a successful collection.
collectedEvent.Event:Connect(function(player)
    if not player or not player:IsA("Player") then return end

    CollectionConfirmed:FireClient(player, "Collection confirmed!")

    if not autoStealEnabled[player] then return end
    if not savedPositions[player] then return end

    task.wait(0.5)

    -- Check again after waiting. Never teleport if the toggle was turned off.
    if not player.Parent then return end
    if not autoStealEnabled[player] then return end

    local root = getRoot(player)
    local destination = savedPositions[player]

    if root and destination then
        root.CFrame = destination + Vector3.new(0, 3, 0)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    savedPositions[player] = nil
    autoStealEnabled[player] = nil
    lastSave[player] = nil
    lastTeleport[player] = nil
end)
