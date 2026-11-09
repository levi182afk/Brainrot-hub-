
--[[
    BRAINROT HUB v1.8
    Safe Roblox Studio prototype
    Client GUI
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local VERSION = "v1.8"
local DISCORD = "https://discord.gg/69nEumtA7Z"

local Old = PlayerGui:FindFirstChild("BrainrotHub")
if Old then Old:Destroy() end

local SavedPosition
local Invisible = false
local AutoSteal = false
local SilentWalk = false
local SavedTransparency = {}
local SelectedBrainrot

local Remotes = ReplicatedStorage:FindFirstChild("BrainrotHubRemotes")

local SetAutoSteal = Remotes and Remotes:FindFirstChild("SetAutoSteal")
local GetBrainrots = Remotes and Remotes:FindFirstChild("GetVisibleBrainrots")
local RequestTeleport = Remotes and Remotes:FindFirstChild("RequestTeleportToBrainrot")

-- THEMES

local Themes = {
    Orange = Color3.fromRGB(240,120,40),
    Red = Color3.fromRGB(240,65,65),
    Blue = Color3.fromRGB(65,140,240),
    Purple = Color3.fromRGB(160,90,240),
    Green = Color3.fromRGB(65,190,110),
    Pink = Color3.fromRGB(240,110,180),
    Grey = Color3.fromRGB(150,150,160),
    Rainbow = Color3.fromRGB(255,100,160),
    Transparent = Color3.fromRGB(120,190,255)
}

local CurrentTheme = "Orange"
local Transparency = 0.08
local GUIScale = 1

-- GUI

local GUI = Instance.new("ScreenGui")
GUI.Name = "BrainrotHub"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(520,365)
Main.Position = UDim2.new(.5,-260,.5,-182)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BackgroundTransparency = Transparency
Main.BorderSizePixel = 0
Main.Parent = GUI

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke",Main)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-100,0,42)
Title.Position = UDim2.fromOffset(12,0)
Title.BackgroundTransparency = 1
Title.Text = "BRAINROT HUB "..VERSION
Title.TextColor3 = Themes.Orange
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local function Button(parent,text,size,pos)
    local B = Instance.new("TextButton")
    B.Size = size
    B.Position = pos
    B.BackgroundColor3 = Color3.fromRGB(50,50,58)
    B.TextColor3 = Color3.new(1,1,1)
    B.Text = text
    B.TextSize = 13
    B.Font = Enum.Font.GothamBold
    B.BorderSizePixel = 0
    B.Parent = parent

    Instance.new("UICorner",B).CornerRadius = UDim.new(0,7)

    return B
end

local function Label(parent,text,height)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,-10,0,height or 30)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.new(1,1,1)
    L.TextSize = 12
    L.TextWrapped = true
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Font = Enum.Font.Gotham
    L.Parent = parent
    return L
end

local Status = Label(Main,"Status: Ready",22)
Status.Position = UDim2.new(0,10,1,-26)

local function SetStatus(text)
    Status.Text = "Status: "..text
end

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10,50)
Sidebar.Size = UDim2.new(0,110,1,-85)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Main

local SideLayout = Instance.new("UIListLayout",Sidebar)
SideLayout.Padding = UDim.new(0,6)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(130,50)
Content.Size = UDim2.new(1,-140,1,-85)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}
local Nav = {}

local function MakePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.fromScale(1,1)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout",Page)
    Layout.Padding = UDim.new(0,7)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0,Layout.AbsoluteContentSize.Y+10)
    end)

    Pages[name] = Page
    return Page
end

local MainPage = MakePage("MAIN")
local PlayerPage = MakePage("PLAYER")
local SettingsPage = MakePage("SETTINGS")
local UpdatesPage = MakePage("UPDATES")
local DiscordPage = MakePage("DISCORD")

local function ShowPage(name)
    for n,p in pairs(Pages) do
        p.Visible = n == name
    end
end

local function AddNav(name)
    local B = Button(
        Sidebar,
        name,
        UDim2.new(1,0,0,38),
        UDim2.new()
    )

    Nav[name] = B

    B.MouseButton1Click:Connect(function()
        ShowPage(name)
    end)
end

for _,name in ipairs({
    "MAIN",
    "PLAYER",
    "SETTINGS",
    "UPDATES",
    "DISCORD"
}) do
    AddNav(name)
end

local function Action(parent,text,callback)
    local B = Button(
        parent,
        text,
        UDim2.new(1,-8,0,36),
        UDim2.new()
    )

    B.MouseButton1Click:Connect(callback)
    return B
end

-- MAIN TAB

Label(MainPage,"MAIN CONTROLS",25)

Action(MainPage,"SAVE POSITION",function()
    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if Root then
        SavedPosition = Root.CFrame
        SetStatus("Position saved")
    end
end)

Action(MainPage,"TELEPORT TO SAVED POSITION",function()
    if not SavedPosition then
        SetStatus("Save position first")
        return
    end

    local Character = Player.Character
    if Character then
        Character:PivotTo(SavedPosition + Vector3.new(0,3,0))
        SetStatus("Teleported in local test")
    end
end)

local InvisibleButton

local function SetInvisible(enabled)
    local Character = Player.Character
    if not Character then return end

    if enabled then
        SavedTransparency = {}

        for _,obj in ipairs(Character:GetDescendants()) do
            if obj:IsA("BasePart") then
                SavedTransparency[obj] = obj.LocalTransparencyModifier

                local Name = obj.Name:lower()

                obj.LocalTransparencyModifier =
                    (Name:find("foot") or Name:find("leg"))
                    and 0.05 or 0.95
            end
        end

        Invisible = true
    else
        for obj,value in pairs(SavedTransparency) do
            if obj and obj.Parent then
                obj.LocalTransparencyModifier = value
            end
        end

        SavedTransparency = {}
        Invisible = false
    end

    InvisibleButton.Text = "FAKE INVISIBLE: "..(Invisible and "ON" or "OFF")
end

InvisibleButton = Action(MainPage,"FAKE INVISIBLE: OFF",function()
    SetInvisible(not Invisible)
end)

Action(MainPage,"RESTORE VISIBILITY",function()
    SetInvisible(false)
    SetStatus("Visibility restored")
end)

Action(MainPage,"STOP ALL",function()
    SetInvisible(false)
    SavedPosition = nil
    SetStatus("Stopped")
end)

-- AUTO STEAL

local AutoButton

AutoButton = Action(MainPage,"AUTO STEAL: OFF",function()
    AutoSteal = not AutoSteal

    AutoButton.Text =
        "AUTO STEAL: "..(AutoSteal and "ON" or "OFF")

    if SetAutoSteal and SetAutoSteal:IsA("RemoteEvent") then
        SetAutoSteal:FireServer(AutoSteal)
        SetStatus("Auto Steal setting sent to server")
    else
        SetStatus("Server integration required")
    end
end)

Label(
    MainPage,
    "Returns to your base after the server confirms a successful collection. Requires your game's server integration.",
    48
)

-- PLAYER TAB

Label(PlayerPage,"PLAYER SETTINGS",25)

Action(PlayerPage,"SILENT WALK: TOGGLE",function()
    SilentWalk = not SilentWalk

    local Character = Player.Character
    local Animate = Character and Character:FindFirstChild("Animate")

    if Animate and Animate:IsA("LocalScript") then
        Animate.Disabled = SilentWalk
    end

    SetStatus(SilentWalk and "Silent Walk ON locally" or "Silent Walk OFF")
end)

Label(
    PlayerPage,
    "Silent Walk changes local animations. Server-controlled footsteps may still be heard by other players.",
    55
)

-- SETTINGS TAB

Label(SettingsPage,"CHOOSE YOUR THEME",25)

for Name,Color in pairs(Themes) do
    Action(SettingsPage,Name.." THEME",function()
        CurrentTheme = Name
        Stroke.Color = Color
        Title.TextColor3 = Color
        SetStatus(Name.." theme selected")
    end)
end

Label(SettingsPage,"Transparency",25)

Action(SettingsPage,"TRANSPARENCY +",function()
    Transparency = math.clamp(Transparency+0.05,0,0.5)
    Main.BackgroundTransparency = Transparency
end)

Action(SettingsPage,"TRANSPARENCY -",function()
    Transparency = math.clamp(Transparency-0.05,0,0.5)
    Main.BackgroundTransparency = Transparency
end)

Label(SettingsPage,"GUI SIZE",25)

Action(SettingsPage,"INCREASE GUI SIZE",function()
    GUIScale = math.clamp(GUIScale+0.05,0.75,1.25)
    Main.Size = UDim2.fromOffset(520*GUIScale,365*GUIScale)
end)

Action(SettingsPage,"DECREASE GUI SIZE",function()
    GUIScale = math.clamp(GUIScale-0.05,0.75,1.25)
    Main.Size = UDim2.fromOffset(520*GUIScale,365*GUIScale)
end)

Action(SettingsPage,"COMPACT MODE",function()
    Main.Size = UDim2.fromOffset(450,315)
    SetStatus("Compact mode enabled")
end)

Action(SettingsPage,"RESET APPEARANCE",function()
    CurrentTheme = "Orange"
    Transparency = 0.08
    GUIScale = 1
    Main.Size = UDim2.fromOffset(520,365)
    Main.BackgroundTransparency = Transparency
    Stroke.Color = Themes.Orange
    Title.TextColor3 = Themes.Orange
    SetStatus("Appearance reset")
end)

-- UPDATES TAB

Label(UpdatesPage,"BRAINROT HUB v1.8",30)

Label(
    UpdatesPage,
    "NEW IN v1.8\n\n"..
    "• Sidebar navigation\n"..
    "• Separate Server Scanner\n"..
    "• Exact brainrot names and rarities\n"..
    "• Mutation display\n"..
    "• AUTO STEAL toggle\n"..
    "• Theme customization\n"..
    "• Transparency and size controls\n"..
    "• Silent Walk option\n"..
    "• Startup update log\n\n"..
    "Some features require server support.",
    190
)

-- DISCORD TAB

Label(DiscordPage,"JOIN OUR DISCORD",30)
Label(DiscordPage,DISCORD,40)

Action(DiscordPage,"OPEN DISCORD",function()
    local ok = pcall(function()
        GuiService:OpenBrowserWindow(DISCORD)
    end)

    SetStatus(ok and "Opening Discord" or "Open invite manually")
end)

-- SERVER SCANNER WINDOW

local ScannerButton = Button(
    GUI,
    "SCAN",
    UDim2.fromOffset(60,48),
    UDim2.new(1,-70,0.55,0)
)

local Scanner = Instance.new("Frame")
Scanner.Size = UDim2.fromOffset(300,300)
Scanner.Position = UDim2.new(1,-315,0.5,-150)
Scanner.BackgroundColor3 = Color3.fromRGB(32,32,38)
Scanner.BorderSizePixel = 0
Scanner.Visible = false
Scanner.Parent = GUI
Instance.new("UICorner",Scanner).CornerRadius = UDim.new(0,10)

local ScannerTitle = Label(Scanner,"SERVER SCANNER",35)
ScannerTitle.Position = UDim2.fromOffset(8,0)

local ScannerClose = Button(
    Scanner,"X",
    UDim2.fromOffset(30,27),
    UDim2.new(1,-36,0,4)
)

local Scan = Button(
    Scanner,"SCAN SERVER",
    UDim2.new(1,-16,0,32),
    UDim2.fromOffset(8,38)
)

local Results = Instance.new("ScrollingFrame")
Results.Position = UDim2.fromOffset(8,76)
Results.Size = UDim2.new(1,-16,1,-122)
Results.BackgroundColor3 = Color3.fromRGB(23,23,27)
Results.BorderSizePixel = 0
Results.ScrollBarThickness = 4
Results.Parent = Scanner

local ResultLayout = Instance.new("UIListLayout",Results)
ResultLayout.Padding = UDim.new(0,5)

ResultLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Results.CanvasSize = UDim2.fromOffset(0,ResultLayout.AbsoluteContentSize.Y+5)
end)

local TeleportSelected = Button(
    Scanner,"TELEPORT TO SELECTED",
    UDim2.new(1,-16,0,34),
    UDim2.new(0,8,1,-40)
)

local function ScanServer()
    for _,obj in ipairs(Results:GetChildren()) do
        if obj:IsA("TextButton") or obj:IsA("TextLabel") then
            obj:Destroy()
        end
    end

    SelectedBrainrot = nil

    if not GetBrainrots or not GetBrainrots:IsA("RemoteFunction") then
        Label(Results,"Server scanner integration is not installed.",45)
        return
    end

    local success,entries = pcall(function()
        return GetBrainrots:InvokeServer()
    end)

    if not success or type(entries) ~= "table" then
        SetStatus("Scanner request failed")
        return
    end

    for _,entry in ipairs(entries) do
        local id = tostring(entry.Id or "")
        local name = tostring(entry.Name or "Unknown")
        local rarity = tostring(entry.Rarity or "Unknown")
        local mutation = tostring(entry.Mutation or "None")

        local row = Button(
            Results,
            name.." | "..rarity.." | "..mutation,
            UDim2.new(1,-6,0,36),
            UDim2.new()
        )

        row.TextSize = 10

        row.MouseButton1Click:Connect(function()
            SelectedBrainrot = id
            SetStatus("Selected "..name)
        end)
    end

    SetStatus("Found "..#entries.." visible brainrots")
end

Scan.MouseButton1Click:Connect(ScanServer)

TeleportSelected.MouseButton1Click:Connect(function()
    if not SelectedBrainrot then
        SetStatus("Select a brainrot first")
        return
    end

    if RequestTeleport and RequestTeleport:IsA("RemoteEvent") then
        RequestTeleport:FireServer(SelectedBrainrot)
        SetStatus("Teleport request sent")
    else
        SetStatus("Server teleport integration required")
    end
end)

ScannerButton.MouseButton1Click:Connect(function()
    Scanner.Visible = true
    ScannerButton.Visible = false
end)

ScannerClose.MouseButton1Click:Connect(function()
    Scanner.Visible = false
    ScannerButton.Visible = true
end)

-- REOPEN / MINIMIZE
local Reopen = Button(GUI,"HUB",UDim2.fromOffset(55,48),UDim2.new(0,12,0.55,0))
Reopen.Visible = false

local function HideMain()
    Main.Visible = false
    Reopen.Visible = true
end

minimize.MouseButton1Click:Connect(HideMain)
close.MouseButton1Click:Connect(HideMain)

Reopen.MouseButton1Click:Connect(function()
    Main.Visible = true
    Reopen.Visible = false
end)

-- MOBILE DRAGGING
local function MakeDraggable(frame,handle)
    local dragging = false
    local startPosition
    local startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startInput = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = input.Position-startInput
            frame.Position = UDim2.new(
                startPosition.X.Scale,startPosition.X.Offset+delta.X,
                startPosition.Y.Scale,startPosition.Y.Offset+delta.Y
            )
        end
    end)
end

MakeDraggable(Main,topbar)
MakeDraggable(Scanner,ScannerTitle)

-- Startup update popup
local Popup = Instance.new("Frame")
Popup.Size = UDim2.fromOffset(300,210)
Popup.Position = UDim2.new(0.5,-150,0.5,-105)
Popup.BackgroundColor3 = Color3.fromRGB(28,28,33)
Popup.BorderSizePixel = 0
Popup.ZIndex = 10
Popup.Parent = GUI
Instance.new("UICorner",Popup).CornerRadius = UDim.new(0,10)

local PopupTitle = Label(Popup,"BRAINROT HUB v1.8",35)
PopupTitle.Position = UDim2.fromOffset(10,5)
PopupTitle.ZIndex = 11
PopupTitle.TextColor3 = Themes.Orange
PopupTitle.Font = Enum.Font.GothamBold

local PopupBody = Label(Popup,
    "What's new:\n• New sidebar layout\n• Server Scanner window\n• Theme and size controls\n• Silent Walk option\n• AUTO STEAL server hook\n\nPress Continue to open the hub.",
    125)
PopupBody.Position = UDim2.fromOffset(10,42)
PopupBody.TextYAlignment = Enum.TextYAlignment.Top
PopupBody.ZIndex = 11

local Continue = Button(Popup,"CONTINUE",UDim2.new(1,-20,0,30),UDim2.new(0,10,1,-38))
Continue.ZIndex = 11
Continue.MouseButton1Click:Connect(function() Popup:Destroy() end)

showPage("MAIN")
SetStatus("Ready - Studio prototype")
print("BrainrotHub "..VERSION.." loaded")
