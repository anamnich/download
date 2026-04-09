local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
-- ============================================================
-- WHITELIST SYSTEM (RAW GITHUB)
-- ============================================================

local HttpService = game:GetService("HttpService")

local WHITELIST_URL = "https://raw.githubusercontent.com/ZassTdr/whitelist/refs/heads/main/whitelist.json" 
-- contoh: https://raw.githubusercontent.com/username/repo/main/whitelist.txt

local function CheckWhitelist()
    local success, response = pcall(function()
        return game:HttpGet(WHITELIST_URL)
    end)

    if not success then
        warn("[Whitelist] Gagal mengambil data!")
        LocalPlayer:Kick("Whitelist error, coba lagi nanti.")
        return
    end

    local allowed = false
    local username = LocalPlayer.Name:lower()

    for line in string.gmatch(response, "[^\r\n]+") do
        if line:lower() == username then
            allowed = true
            break
        end
    end

    if not allowed then
        LocalPlayer:Kick("Kamu tidak ada di whitelist!")
    else
        print("[Whitelist] Akses diterima:", LocalPlayer.Name)
    end
end

-- Jalankan whitelist check
CheckWhitelist()

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea = dragArea or frame
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ============================================================
-- SCRIPT DATA
-- ============================================================
local Scripts = {
    Fuun = {
        {
            Name = "Indo Voice",
            Desc = "Khusus Premium excutor/loader",
            Tags = {"Fuun"},
            URL = "https://raw.githubusercontent.com/danuuww/scripts/refs/heads/main/free.lua",
        },
        {
            Name = "Fish Zar",
            Desc = "ytta",
            Tags = {"Fuun"},
            URL = "https://raw.githubusercontent.com/4LynxX/all_Game/refs/heads/main/fishzar.lua",
        },
        {
            Name = "Fish It",
            Desc = "usahakan server privat.",
            Tags = {"Fuun"},
            URL = "https://raw.githubusercontent.com/4LynxX/all_Game/refs/heads/main/Fish_It.lua",
        },
        {
            Name = "Vd Kematian",
            Desc = "ytta.",
            Tags = {"Fuun"},
            URL = "https://raw.githubusercontent.com/numerouno2/eugunewupremium/refs/heads/main/main.lua",
        },
        {
            Name = "Sambung Kata",
            Desc = "ytta.",
            Tags = {"Fuun"},
            URL = "https://raw.githubusercontent.com/numerouno2/eugunewupremium/refs/heads/main/main.lua",
        },
        {
            Name = "Sawah Indo",
            Desc = "ytta.",
            Tags = {"Fuun"},
            URL = "https://raw.githubusercontent.com/4LynxX/all_Game/refs/heads/main/Sawah_Indo.lua",
        },
    },
    Player = {
        {
            Name = "Fly",
            Desc = "Terbang bebas di udara dengan speed control.",
            Tags = {"Player"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/fly8.lua",
        },
        {
            Name = "Clone Ava",
            Desc = "ini visual",
            Tags = {"Player"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/cloneava7.lua",
        },
        {
            Name = "Fps Boster",
            Desc = "untuk meringankan devis",
            Tags = {"Player"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/fps2.lua",
        },
        {
            Name = "Server Sepi",
            Desc = "ini untuk mencari server yang sepi pemain",
            Tags = {"Player"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/searchserver.lua",
        },
    },
    Exploit = {
        {
            Name = "Report Player",
            Desc = "ini untuk report player setiap 1 menit",
            Tags = {"exploit"},
            URL = "https://raw.githubusercontent.com/xploitforceofficial-stack/rathubpublic/refs/heads/main/rathub.lua",
        },
        {
            Name = "NoCounter",
            Desc = "sc ini bukan dari saya ini dari no counter famely",
            Tags = {"exploit"},
            URL = "https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/NC-Full",
        },
        {
            Name = "Infinite Yeild",
            Desc = "untuk membuka isi dalam map pakai dex",
            Tags = {"exploit"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/iy1.lua",
        },
        {
            Name = "Flyfing",
            Desc = "memantulkan player lain.",
            Tags = {"exploit"},
            URL = "https://pastefy.app/DW3NUZcN/raw",
        },
        {
            Name = "Speed",
            Desc = "control speed dan jump",
            Tags = {"exploit"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/speed4.lua",
        },
        {
            Name = "Laser",
            Desc = "untuk rusuh",
            Tags = {"exploit"},
            URL = "https://mpangppxhub.vercel.app/laserpiwpiw",
        },
        {
            Name = "Kordinat",
            Desc = "ini untuk save kodinat, agar bisa di combo sama script teleport",
            Tags = {"exploit"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/kordinat.lua",
        },
        {
            Name = "Auto Walk",
            Desc = "key "Z" record manual bang jangan manja",
            Tags = {"exploit"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/record3.lua",
        },
    },
    Teleport = {
        {
            Name = "Teleport to Spown",
            Desc = "Teleport ke posisi player lain.",
            Tags = {"teleport"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/tp5.lua",
        },
        {
            Name = "Teleport to Player",
            Desc = "Kembali ke spawn point.",
            Tags = {"teleport"},
            URL = "https://raw.githubusercontent.com/anamnich/download/refs/heads/main/tpplayer6.lua",
        },
    },
    Copy = {
        {
            Name = "Copy Map No Train",
            Desc = "ini adalah fiture copy map yang bisa di buka untuk pc/laptop.",
            Tags = {"copy"},
            URL = "https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/Copy-Maps",
        },
    },
    Info = {
        {
            Name = "gada info banh :V",
        },
    },
}

-- ============================================================
-- GUI BUILDER
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZassXdGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 700, 0, 480)
MainFrame.Position = UDim2.new(0.5, -350, 1.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 20, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(13, 20, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

-- Avatar Badge
local AvatarBadge = Instance.new("Frame")
AvatarBadge.Size = UDim2.new(0, 36, 0, 36)
AvatarBadge.Position = UDim2.new(0, 14, 0.5, -18)
AvatarBadge.BackgroundColor3 = Color3.fromRGB(0, 188, 212)
AvatarBadge.Parent = TopBar
Instance.new("UICorner", AvatarBadge).CornerRadius = UDim.new(0, 6)
local BadgeLabel = Instance.new("TextLabel")
BadgeLabel.Size = UDim2.new(1,0,1,0)
BadgeLabel.BackgroundTransparency = 1
BadgeLabel.Text = "ZX"
BadgeLabel.TextColor3 = Color3.fromRGB(10, 16, 24)
BadgeLabel.TextScaled = true
BadgeLabel.Font = Enum.Font.GothamBold
BadgeLabel.Parent = AvatarBadge

-- Title Labels
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 0, 22)
TitleLabel.Position = UDim2.new(0, 58, 0, 10)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ZassXd Official"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 200, 0, 16)
SubLabel.Position = UDim2.new(0, 58, 0, 32)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "VVIP MEMBER"
SubLabel.TextColor3 = Color3.fromRGB(0, 188, 212)
SubLabel.TextSize = 11
SubLabel.Font = Enum.Font.GothamBold
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Exclusive Badge
local ExclusiveBadge = Instance.new("TextButton")
ExclusiveBadge.Size = UDim2.new(0, 90, 0, 30)
ExclusiveBadge.Position = UDim2.new(1, -140, 0.5, -15)
ExclusiveBadge.BackgroundColor3 = Color3.fromRGB(0, 188, 212)
ExclusiveBadge.Text = "Exclusive"
ExclusiveBadge.TextColor3 = Color3.fromRGB(10, 16, 24)
ExclusiveBadge.TextSize = 13
ExclusiveBadge.Font = Enum.Font.GothamBold
ExclusiveBadge.AutoButtonColor = false
ExclusiveBadge.Parent = TopBar
Instance.new("UICorner", ExclusiveBadge).CornerRadius = UDim.new(1, 0)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -12)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "—"
CloseBtn.TextColor3 = Color3.fromRGB(130, 150, 170)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.Gotham
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Position = UDim2.new(0.5, -350, 1.5, 0)}, 0.3)
    task.delay(0.35, function() ScreenGui:Destroy() end)
end)

MakeDraggable(MainFrame, TopBar)

-- Separator
local Sep = Instance.new("Frame")
Sep.Size = UDim2.new(1, 0, 0, 1)
Sep.Position = UDim2.new(0, 0, 0, 60)
Sep.BackgroundColor3 = Color3.fromRGB(30, 45, 60)
Sep.BorderSizePixel = 0
Sep.Parent = MainFrame

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 190, 1, -61)
Sidebar.Position = UDim2.new(0, 0, 0, 61)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -20, 0, 38)
SearchBox.Position = UDim2.new(0, 10, 0, 12)
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 42, 55)
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.TextColor3 = Color3.fromRGB(200, 220, 240)
SearchBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 130)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.BorderSizePixel = 0
SearchBox.Parent = Sidebar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)
local SearchPad = Instance.new("UIPadding")
SearchPad.PaddingLeft = UDim.new(0, 12)
SearchPad.Parent = SearchBox

-- Nav List
local Categories = {"Fuun", "Player", "Exploit", "Teleport", "Copy", "Info"}
local CategoryIcons = {"✈", "<>", "▶", "◉", "◆", "⚙"}
local NavButtons = {}
local ActiveCategory = "Fuun"

local NavList = Instance.new("Frame")
NavList.Size = UDim2.new(1, 0, 1, -62)
NavList.Position = UDim2.new(0, 0, 0, 62)
NavList.BackgroundTransparency = 1
NavList.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 2)
NavLayout.Parent = NavList

-- Active indicator
local ActiveIndicator = Instance.new("Frame")
ActiveIndicator.Size = UDim2.new(0, 3, 0, 30)
ActiveIndicator.BackgroundColor3 = Color3.fromRGB(0, 188, 212)
ActiveIndicator.BorderSizePixel = 0
ActiveIndicator.Parent = Sidebar
Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(1, 0)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -191, 1, -61)
ContentArea.Position = UDim2.new(0, 191, 0, 61)
ContentArea.BackgroundColor3 = Color3.fromRGB(16, 24, 34)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local EdgeFill = Instance.new("Frame")
EdgeFill.Size = UDim2.new(0, 12, 1, 0)
EdgeFill.BackgroundColor3 = Color3.fromRGB(16, 24, 34)
EdgeFill.BorderSizePixel = 0
EdgeFill.Parent = ContentArea

-- Category Title
local CategoryTitle = Instance.new("TextLabel")
CategoryTitle.Size = UDim2.new(1, -20, 0, 30)
CategoryTitle.Position = UDim2.new(0, 20, 0, 10)
CategoryTitle.BackgroundTransparency = 1
CategoryTitle.Text = "Fuun SCRIPTS"
CategoryTitle.TextColor3 = Color3.fromRGB(80, 110, 140)
CategoryTitle.TextSize = 12
CategoryTitle.Font = Enum.Font.GothamBold
CategoryTitle.TextXAlignment = Enum.TextXAlignment.Left
CategoryTitle.Parent = ContentArea

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -50)
ScrollFrame.Position = UDim2.new(0, 10, 0, 46)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 188, 212)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = ContentArea
local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Padding = UDim.new(0, 10)
ScrollLayout.Parent = ScrollFrame
local ScrollPad = Instance.new("UIPadding")
ScrollPad.PaddingBottom = UDim.new(0, 10)
ScrollPad.Parent = ScrollFrame

-- ============================================================
-- CARD BUILDER
-- ============================================================

local function CreateScriptCard(data)
    local Card = Instance.new("Frame")
    Card.Name = data.Name
    Card.Size = UDim2.new(1, 0, 0, 130)
    Card.BackgroundColor3 = Color3.fromRGB(20, 30, 42)
    Card.BorderSizePixel = 0
    Card.Parent = ScrollFrame
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = Color3.fromRGB(35, 55, 75)
    CardStroke.Thickness = 1
    CardStroke.Parent = Card

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -20, 0, 26)
    NameLabel.Position = UDim2.new(0, 16, 0, 12)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = data.Name
    NameLabel.TextColor3 = Color3.fromRGB(230, 240, 255)
    NameLabel.TextSize = 16
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = Card

    -- Desc
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -20, 0, 18)
    DescLabel.Position = UDim2.new(0, 16, 0, 38)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = data.Desc
    DescLabel.TextColor3 = Color3.fromRGB(100, 140, 170)
    DescLabel.TextSize = 13
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = Card

    -- Tags
    local TagX = 16
    for _, tag in pairs(data.Tags) do
        local TagBadge = Instance.new("TextLabel")
        TagBadge.Size = UDim2.new(0, #tag * 8 + 16, 0, 20)
        TagBadge.Position = UDim2.new(0, TagX, 0, 60)
        TagBadge.BackgroundColor3 = Color3.fromRGB(20, 45, 60)
        TagBadge.Text = tag
        TagBadge.TextColor3 = Color3.fromRGB(0, 188, 212)
        TagBadge.TextSize = 11
        TagBadge.Font = Enum.Font.Gotham
        TagBadge.BorderSizePixel = 0
        TagBadge.Parent = Card
        Instance.new("UICorner", TagBadge).CornerRadius = UDim.new(0, 5)
        local TS = Instance.new("UIStroke")
        TS.Color = Color3.fromRGB(0, 120, 150)
        TS.Thickness = 1
        TS.Parent = TagBadge
        TagX = TagX + #tag * 8 + 26
    end

    -- Status label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0, 200, 0, 14)
    StatusLabel.Position = UDim2.new(0, 16, 0, 112)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(0, 188, 212)
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Card

    -- Execute Button (Jalankan via loadstring)
    local ExecBtn = Instance.new("TextButton")
    ExecBtn.Size = UDim2.new(0, 130, 0, 36)
    ExecBtn.Position = UDim2.new(0, 16, 0, 86)
    ExecBtn.BackgroundColor3 = Color3.fromRGB(22, 35, 50)
    ExecBtn.Text = "▶ Jalankan"
    ExecBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
    ExecBtn.TextSize = 14
    ExecBtn.Font = Enum.Font.GothamBold
    ExecBtn.BorderSizePixel = 0
    ExecBtn.AutoButtonColor = false
    ExecBtn.Parent = Card
    Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 8)
    local EBStroke = Instance.new("UIStroke")
    EBStroke.Color = Color3.fromRGB(50, 80, 110)
    EBStroke.Thickness = 1.5
    EBStroke.Parent = ExecBtn

    ExecBtn.MouseEnter:Connect(function()
        Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(0, 70, 100)}, 0.15)
        Tween(EBStroke, {Color = Color3.fromRGB(0, 188, 212)}, 0.15)
    end)
    ExecBtn.MouseLeave:Connect(function()
        Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(22, 35, 50)}, 0.15)
        Tween(EBStroke, {Color = Color3.fromRGB(50, 80, 110)}, 0.15)
    end)

    ExecBtn.MouseButton1Click:Connect(function()
        if not ExecBtn.Active then return end
        ExecBtn.Active = false
        ExecBtn.Text = "Loading..."
        StatusLabel.Text = "⏳ Mengambil script..."
        StatusLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
        Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(0, 100, 130)}, 0.1)

        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(data.URL, true))()
            end)

            if ok then
                -- Sukses
                ExecBtn.Text = "✓ Berhasil"
                ExecBtn.TextColor3 = Color3.fromRGB(0, 255, 160)
                StatusLabel.Text = "✓ Script berhasil dijalankan!"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 140)
                Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(0, 70, 55)}, 0.2)
                CardStroke.Color = Color3.fromRGB(0, 150, 100)
                task.delay(2.5, function()
                    ExecBtn.Text = "▶ Jalankan"
                    ExecBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
                    Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(22, 35, 50)}, 0.2)
                    CardStroke.Color = Color3.fromRGB(35, 55, 75)
                    ExecBtn.Active = true
                    StatusLabel.Text = ""
                end)
            else
                -- Gagal
                ExecBtn.Text = "✗ Gagal"
                ExecBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
                StatusLabel.Text = "✗ Gagal! Cek URL script."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(80, 20, 20)}, 0.2)
                CardStroke.Color = Color3.fromRGB(150, 40, 40)
                warn("[ZassXd] loadstring error on '" .. data.Name .. "': " .. tostring(err))
                task.delay(3, function()
                    ExecBtn.Text = "▶ Jalankan"
                    ExecBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
                    Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(22, 35, 50)}, 0.2)
                    CardStroke.Color = Color3.fromRGB(35, 55, 75)
                    ExecBtn.Active = true
                    StatusLabel.Text = ""
                end)
            end
        end)
    end)

    -- Detail Button
    local DetailBtn = Instance.new("TextButton")
    DetailBtn.Size = UDim2.new(0, 90, 0, 36)
    DetailBtn.Position = UDim2.new(0, 156, 0, 86)
    DetailBtn.BackgroundColor3 = Color3.fromRGB(22, 35, 50)
    DetailBtn.Text = "Detail"
    DetailBtn.TextColor3 = Color3.fromRGB(220, 235, 255)
    DetailBtn.TextSize = 14
    DetailBtn.Font = Enum.Font.GothamBold
    DetailBtn.BorderSizePixel = 0
    DetailBtn.AutoButtonColor = false
    DetailBtn.Parent = Card
    Instance.new("UICorner", DetailBtn).CornerRadius = UDim.new(0, 8)
    local DBStroke = Instance.new("UIStroke")
    DBStroke.Color = Color3.fromRGB(50, 80, 110)
    DBStroke.Thickness = 1.5
    DBStroke.Parent = DetailBtn

    DetailBtn.MouseEnter:Connect(function()
        Tween(DetailBtn, {BackgroundColor3 = Color3.fromRGB(30, 50, 70)}, 0.15)
    end)
    DetailBtn.MouseLeave:Connect(function()
        Tween(DetailBtn, {BackgroundColor3 = Color3.fromRGB(22, 35, 50)}, 0.15)
    end)
    DetailBtn.MouseButton1Click:Connect(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📋 " .. data.Name,
            Text = data.Desc,
            Duration = 5
        })
    end)
end

-- ============================================================
-- NAVIGATION
-- ============================================================

local function LoadCategory(category)
    ActiveCategory = category
    CategoryTitle.Text = string.upper(category) .. " SCRIPTS"
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, s in pairs(Scripts[category] or {}) do
        CreateScriptCard(s)
    end
end

local function UpdateNavButtons(selected)
    for cat, btn in pairs(NavButtons) do
        if cat == selected then
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(20, 35, 50)}, 0.2)
            btn.TextColor3 = Color3.fromRGB(0, 188, 212)
            ActiveIndicator.Position = UDim2.new(0, 0, 0, btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + 9)
        else
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(0,0,0,0)}, 0.2)
            btn.TextColor3 = Color3.fromRGB(140, 165, 185)
        end
    end
end

for i, cat in ipairs(Categories) do
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, 0, 0, 42)
    NavBtn.BackgroundTransparency = 1
    NavBtn.Text = "  " .. CategoryIcons[i] .. "  " .. cat
    NavBtn.TextColor3 = Color3.fromRGB(140, 165, 185)
    NavBtn.TextSize = 14
    NavBtn.Font = Enum.Font.Gotham
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.BorderSizePixel = 0
    NavBtn.AutoButtonColor = false
    NavBtn.Parent = NavList
    local BtnPad = Instance.new("UIPadding")
    BtnPad.PaddingLeft = UDim.new(0, 8)
    BtnPad.Parent = NavBtn
    NavButtons[cat] = NavBtn

    NavBtn.MouseEnter:Connect(function()
        if ActiveCategory ~= cat then
            Tween(NavBtn, {TextColor3 = Color3.fromRGB(200, 220, 240)}, 0.15)
        end
    end)
    NavBtn.MouseLeave:Connect(function()
        if ActiveCategory ~= cat then
            Tween(NavBtn, {TextColor3 = Color3.fromRGB(140, 165, 185)}, 0.15)
        end
    end)
    NavBtn.MouseButton1Click:Connect(function()
        LoadCategory(cat)
        UpdateNavButtons(cat)
    end)
end

-- Search
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    if query == "" then
        LoadCategory(ActiveCategory)
        return
    end
    CategoryTitle.Text = "HASIL PENCARIAN"
    for _, list in pairs(Scripts) do
        for _, s in pairs(list) do
            if s.Name:lower():find(query) or s.Desc:lower():find(query) then
                CreateScriptCard(s)
            end
        end
    end
end)

-- Init
LoadCategory("Fuun")
UpdateNavButtons("Fuun")
Tween(MainFrame, {Position = UDim2.new(0.5, -350, 0.5, -240)}, 0.4, Enum.EasingStyle.Back)

print("[ZassXd GUI] Loaded! Ganti semua URL 'GANTI_URL_DISINI' dengan URL Pastebin/GitHub raw milikmu.")
