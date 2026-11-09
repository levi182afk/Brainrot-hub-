--[[
    BrainrotHub v1.6
    Safe Roblox Studio prototype
    Place this LocalScript in StarterPlayer > StarterPlayerScripts
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local VERSION = "v1.6"
local DISCORD_INVITE = "https://discord.gg/69nEumtA7Z"

-- Remove an older copy of the GUI
local oldGui = playerGui:FindFirstChild("BrainrotHub")
if oldGui then
    oldGui:Destroy()
end

local savedPosition = nil
local invisibleEnabled = false
local savedTransparency = {}

local function getCharacter()
    return player.Character
        or player.CharacterAdded:Wait()
end

local function getRoot()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart")
end

local function setStatus(message)
    statusLabel.Text = "Status: " .. message
end

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(330, 420)
main.Position = UDim2.new(0.5, -165, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(255, 115, 35)
outline.Thickness = 2
outline.Parent = main

local function makeLabel(parent, text, size, position, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.Size = size
    label.Position = position
    label.Parent = parent
    return label
end

local title = makeLabel(
    main,
    "BRAINROT HUB  " .. VERSION,
    UDim2.new(1, -100, 0, 42),
    UDim2.fromOffset(12, 0),
    Color3.fromRGB(255, 135, 55)
)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 30)
minimize.Position = UDim2.new(1, -78, 0, 6)
minimize.Text = "_"
minimize.TextSize = 20
minimize.Font = Enum.Font.GothamBold
minimize.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35, 30)
close.Position = UDim2.new(1, -39, 0, 6)
close.Text = "X"
close.TextSize = 15
close.Font = Enum.Font.GothamBold
close.BackgroundColor3 = Color3.fromRGB(180, 55, 40)
close.TextColor3 = Color3.new(1, 1, 1)
close.Parent = main

local tabs = Instance.new("Frame")
tabs.Size = UDim2.new(1, -20, 0, 38)
tabs.Position = UDim2.fromOffset(10, 48)
tabs.BackgroundTransparency = 1
tabs.Parent = main

local function makeTabButton(text, x)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1/3, -5, 1, 0)
    button.Position = UDim2.new(x, x * 5, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Parent = tabs

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    return button
end

local mainTab = makeTabButton("MAIN", 0)
local updatesTab = makeTabButton("UPDATES", 1)
local discordTab = makeTabButton("DISCORD", 2)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -20, 1, -145)
content.Position = UDim2.fromOffset(10, 95)
content.BackgroundTransparency = 1
content.Parent = main

local statusLabel = makeLabel(
    main,
    "Status: Ready",
    UDim2.new(1, -20, 0, 30),
    UDim2.new(0, 10, 1, -35),
    Color3.fromRGB(255, 170, 90)
)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local pages = {}

local function makePage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content
    pages[name] = page
    return page
end

local mainPage = makePage("MainPage")
local updatesPage = makePage("UpdatesPage")
local discordPage = makePage("DiscordPage")

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end

    mainTab.BackgroundColor3 =
        name == "MainPage"
        and Color3.fromRGB(220, 95, 30)
        or Color3.fromRGB(48, 48, 53)

    updatesTab.BackgroundColor3 =
        name == "UpdatesPage"
        and Color3.fromRGB(220, 95, 30)
        or Color3.fromRGB(48, 48, 53)

    discordTab.BackgroundColor3 =
        name == "DiscordPage"
        and Color3.fromRGB(220, 95, 30)
        or Color3.fromRGB(48, 48, 53)
end

mainTab.MouseButton1Click:Connect(function()
    showPage("MainPage")
end)

updatesTab.MouseButton1Click:Connect(function()
    showPage("UpdatesPage")
end)

discordTab.MouseButton1Click:Connect(function()
    showPage("DiscordPage")
end)

local function makeActionButton(parent, text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 42)
    button.Position = UDim2.fromOffset(5, y)
    button.BackgroundColor3 = Color3.fromRGB(48, 48, 53)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

-- MAIN TAB

makeActionButton(mainPage, "SAVE POSITION", 5, function()
    local root = getRoot()
    savedPosition = root.CFrame
    setStatus("Position saved!")
end)

makeActionButton(mainPage, "TELEPORT TO SAVED POSITION", 55, function()
    if not savedPosition then
        setStatus("Save a position first!")
        return
    end

    local root = getRoot()
    root.CFrame = savedPosition + Vector3.new(0, 3, 0)
    setStatus("Teleported!")
end)

local function restoreTransparency()
    local character = player.Character
    if not character then
        return
    end

    for object, oldValue in pairs(savedTransparency) do
        if object and object.Parent then
            object.LocalTransparencyModifier = oldValue
        end
    end

    savedTransparency = {}
end

local function setFakeInvisible(enabled)
    local character = getCharacter()

    if enabled then
        savedTransparency = {}

        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") then
                savedTransparency[object] =
                    object.LocalTransparencyModifier

                local name = object.Name:lower()

                if name:find("foot") or name:find("leg") then
                    object.LocalTransparencyModifier = 0.05
                else
                    object.LocalTransparencyModifier = 0.95
                end
            end
        end

        invisibleEnabled = true
        setStatus("Local visual effect ON")
    else
        restoreTransparency()
        invisibleEnabled = false
        setStatus("Visibility restored")
    end
end

makeActionButton(mainPage, "FAKE INVISIBLE: TOGGLE", 105, function()
    setFakeInvisible(not invisibleEnabled)
end)

makeActionButton(mainPage, "RESTORE VISIBILITY", 155, function()
    setFakeInvisible(false)
end)

makeActionButton(mainPage, "STOP ALL", 205, function()
    setFakeInvisible(false)
    savedPosition = nil
    setStatus("All effects stopped")
end)

-- UPDATES TAB

makeLabel(
    updatesPage,
    "BRAINROT HUB " .. VERSION,
    UDim2.new(1, -10, 0, 35),
    UDim2.fromOffset(5, 5),
    Color3.fromRGB(255, 135, 55)
).Font = Enum.Font.GothamBold

makeLabel(
    updatesPage,
    "VERSION 1.6\n\n" ..
    "- Added MAIN tab\n" ..
    "- Added UPDATES tab\n" ..
    "- Added DISCORD tab\n" ..
    "- Added mobile-friendly layout\n" ..
    "- Added Save Position\n" ..
    "- Added Teleport\n" ..
    "- Added local visual toggle\n" ..
    "- Added Restore and Stop All\n\n" ..
    "This is a safe Studio prototype.",
    UDim2.new(1, -10, 1, -50),
    UDim2.fromOffset(5, 45),
    Color3.fromRGB(220, 220, 220)
).TextYAlignment = Enum.TextYAlignment.Top

-- DISCORD TAB

makeLabel(
    discordPage,
    "JOIN OUR DISCORD!",
    UDim2.new(1, -10, 0, 40),
    UDim2.fromOffset(5, 10),
    Color3.fromRGB(255, 135, 55)
).Font = Enum.Font.GothamBold

makeLabel(
    discordPage,
    DISCORD_INVITE,
    UDim2.new(1, -10, 0, 45),
    UDim2.fromOffset(5, 55),
    Color3.fromRGB(220, 220, 220)
)

makeActionButton(discordPage, "OPEN DISCORD", 110, function()
    local success = pcall(function()
        GuiService:OpenBrowserWindow(DISCORD_INVITE)
    end)

    if success then
        setStatus("Opening Discord...")
    else
        setStatus("Open the invite link manually")
    end
end)

-- MINIMIZE / CLOSE / REOPEN

local reopen = Instance.new("TextButton")
reopen.Name = "ReopenButton"
reopen.Size = UDim2.fromOffset(65, 65)
reopen.Position = UDim2.new(0, 20, 0.5, -32)
reopen.BackgroundColor3 = Color3.fromRGB(220, 95, 30)
reopen.Text = "HUB"
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.TextSize = 16
reopen.Font = Enum.Font.GothamBold
reopen.Visible = false
reopen.Parent = screenGui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(1, 0)
reopenCorner.Parent = reopen

local function hideHub()
    main.Visible = false
    reopen.Visible = true
end

minimize.MouseButton1Click:Connect(hideHub)
close.MouseButton1Click:Connect(hideHub)

reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

-- MOBILE DRAGGING

local dragging = false
local dragInput
local dragStart
local startPosition

local function updateDrag(input)
    local delta = input.Position - dragStart

    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateDrag(input)
    end
end)

-- Reset local visual effects when the character respawns
player.CharacterAdded:Connect(function()
    invisibleEnabled = false
    savedTransparency = {}
    setStatus("Character respawned")
end)

showPage("MainPage")
setStatus("Ready")

print("BrainrotHub " .. VERSION .. " loaded!")
