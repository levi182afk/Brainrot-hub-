--[[
AUTO STEAL TP - SAFE STUDIO TEST HARNESS
Place this LocalScript in StarterPlayer > StarterPlayerScripts
in a Roblox experience you own/control.

This is a local visual prototype:
- Save Position / Teleport to Saved Position
- Fake Invisible visual toggle (body fades, feet remain visible)
- Restore / Stop All
- Draggable mobile-friendly panel with minimize/reopen

IMPORTANT:
This deliberately does NOT bury, rotate, anchor, or disable collision on
the real character. Those actions can cause falling, noclip, or server
corrections. The character's physics and collision remain unchanged.
It is not a Delta exploit and does not automate stealing in other games.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local previous = playerGui:FindFirstChild("AutoStealTP_Test")
if previous then previous:Destroy() end

local ORANGE = Color3.fromRGB(255, 132, 25)
local DARK = Color3.fromRGB(15, 15, 18)
local PANEL = Color3.fromRGB(29, 29, 34)
local WHITE = Color3.fromRGB(245, 245, 245)
local GREY = Color3.fromRGB(175, 175, 180)

local savedCFrame = nil
local fakeInvisible = false
local originalTransparency = {}
local characterConnection = nil

local gui = Instance.new("ScreenGui")
gui.Name = "AutoStealTP_Test"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function addStroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = obj
end

local function label(parent, text, pos, size, textSize, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = pos
    l.Size = size
    l.Font = Enum.Font.GothamSemibold
    l.Text = text
    l.TextSize = textSize
    l.TextColor3 = color or WHITE
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function button(parent, text, y, height)
    local b = Instance.new("TextButton")
    b.Position = UDim2.new(0, 12, 0, y)
    b.Size = UDim2.new(1, -24, 0, height)
    b.BackgroundColor3 = Color3.fromRGB(83, 47, 23)
    b.Text = text
    b.TextColor3 = WHITE
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.Parent = parent
    addCorner(b, 10)
    addStroke(b, ORANGE, 1)
    return b
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(310, 390)
main.Position = UDim2.new(0.5, -155, 0.5, -195)
main.BackgroundColor3 = DARK
main.Parent = gui
addCorner(main, 16)
addStroke(main, ORANGE, 2)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(35, 27, 21)
header.Parent = main
addCorner(header, 14)

label(header, "AUTO STEAL TP  •  TEST", UDim2.new(0, 13, 0, 0),
    UDim2.new(1, -105, 1, 0), 15, ORANGE)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(32, 30)
minimize.Position = UDim2.new(1, -75, 0, 9)
minimize.BackgroundColor3 = PANEL
minimize.Text = "—"
minimize.TextColor3 = WHITE
minimize.TextSize = 18
minimize.Parent = header
addCorner(minimize, 8)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 30)
close.Position = UDim2.new(1, -38, 0, 9)
close.BackgroundColor3 = Color3.fromRGB(100, 39, 29)
close.Text = "×"
close.TextColor3 = WHITE
close.TextSize = 20
close.Parent = header
addCorner(close, 8)

local status = label(main, "Status: Ready", UDim2.new(0, 14, 0, 58),
    UDim2.new(1, -28, 0, 22), 12, GREY)

local saveBtn = button(main, "SAVE POSITION", 88, 43)
local tpBtn = button(main, "TELEPORT TO SAVED POSITION", 140, 43)
local invisibleBtn = button(main, "FAKE INVISIBLE: OFF", 192, 43)
local restoreBtn = button(main, "RESTORE NORMAL LOOK", 244, 43)
local stopBtn = button(main, "STOP ALL / RESET EFFECTS", 296, 43)

label(main,
    "Studio prototype: visual effect only; character collision stays normal.",
    UDim2.new(0, 14, 1, -38), UDim2.new(1, -28, 0, 30), 10, GREY).TextWrapped = true

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(54, 54)
reopen.Position = UDim2.new(0, 18, 0.55, 0)
reopen.BackgroundColor3 = DARK
reopen.Text = "TP"
reopen.TextColor3 = ORANGE
reopen.TextSize = 17
reopen.Font = Enum.Font.GothamBlack
reopen.Visible = false
reopen.Parent = gui
addCorner(reopen, 27)
addStroke(reopen, ORANGE, 2)

local function getCharacter()
    return player.Character
end

local function setStatus(text, color)
    status.Text = "Status: " .. text
    status.TextColor3 = color or GREY
end

local function restoreVisuals()
    local character = getCharacter()
    if character then
        for part, transparency in pairs(originalTransparency) do
            if part and part.Parent then
                part.LocalTransparencyModifier = transparency
            end
        end
    end
    originalTransparency = {}
    fakeInvisible = false
    invisibleBtn.Text = "FAKE INVISIBLE: OFF"
    invisibleBtn.BackgroundColor3 = Color3.fromRGB(83, 47, 23)
end

local function applyFakeInvisible()
    local character = getCharacter()
    if not character then
        setStatus("Character not loaded", ORANGE)
        return
    end

    restoreVisuals()
    fakeInvisible = true

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            originalTransparency[obj] = obj.LocalTransparencyModifier
            local n = string.lower(obj.Name)
            local isFoot = string.find(n, "foot") ~= nil
                or string.find(n, "shoe") ~= nil
            if isFoot then
                obj.LocalTransparencyModifier = 0.05
            else
                obj.LocalTransparencyModifier = 0.95
            end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            originalTransparency[obj] = obj.Transparency
            obj.Transparency = 1
        end
    end

    invisibleBtn.Text = "FAKE INVISIBLE: ON"
    invisibleBtn.BackgroundColor3 = Color3.fromRGB(120, 62, 20)
    setStatus("Visual fade enabled; physics unchanged", ORANGE)
end

saveBtn.Activated:Connect(function()
    local character = getCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then
        setStatus("Character not ready", ORANGE)
        return
    end
    savedCFrame = root.CFrame
    setStatus("Position saved", ORANGE)
end)

tpBtn.Activated:Connect(function()
    local character = getCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not savedCFrame then
        setStatus("Save a position first", ORANGE)
        return
    end
    root.CFrame = savedCFrame + Vector3.new(0, 3, 0)
    setStatus("Returned to saved position", ORANGE)
end)

invisibleBtn.Activated:Connect(function()
    if fakeInvisible then
        restoreVisuals()
        setStatus("Normal appearance restored")
    else
        applyFakeInvisible()
    end
end)

restoreBtn.Activated:Connect(function()
    restoreVisuals()
    setStatus("Normal appearance restored")
end)

stopBtn.Activated:Connect(function()
    restoreVisuals()
    savedCFrame = nil
    setStatus("Stopped; saved position cleared")
end)

local function hide()
    main.Visible = false
    reopen.Visible = true
end

minimize.Activated:Connect(hide)
close.Activated:Connect(hide)

reopen.Activated:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

-- Drag panel by its header using mouse or touch.
local dragging = false
local dragStart
local startPos
local dragInput

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local camera = workspace.CurrentCamera
        local view = camera and camera.ViewportSize or Vector2.new(800, 600)
        local maxX = math.max(0, view.X - main.AbsoluteSize.X)
        local maxY = math.max(0, view.Y - main.AbsoluteSize.Y)
        local x = math.clamp(startPos.X.Offset + delta.X, 0, maxX)
        local y = math.clamp(startPos.Y.Offset + delta.Y, 0, maxY)
        main.Position = UDim2.fromOffset(x, y)
    end
end)

player.CharacterAdded:Connect(function()
    originalTransparency = {}
    fakeInvisible = false
    invisibleBtn.Text = "FAKE INVISIBLE: OFF"
    invisibleBtn.BackgroundColor3 = Color3.fromRGB(83, 47, 23)
    setStatus("Character respawned")
end)
