local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local WHITELIST_URL = "https://raw.githubusercontent.com/anamnich/whitelist/refs/heads/main/whitelist.json"
local HttpService = game:GetService("HttpService")

local function CheckWhitelist()
    local fetchOk, result = pcall(game.HttpGet, game, WHITELIST_URL, true)
    if not fetchOk or not result or result == "" then
        warn("[ZassXd] HttpGet gagal: " .. tostring(result))
        LocalPlayer:Kick("❌ Gagal fetch whitelist. Coba lagi nanti.")
        return false
    end
    result = result:gsub("^\xEF\xBB\xBF", "")
    result = result:match("^%s*(.-)%s*$")
    local parseOk, data = pcall(HttpService.JSONDecode, HttpService, result)
    if not parseOk then
        warn("[ZassXd] JSONDecode gagal: " .. tostring(data))
        LocalPlayer:Kick("❌ Whitelist format error. Hubungi admin.")
        return false
    end
    if type(data) ~= "table" then
        warn("[ZassXd] JSON tidak valid!")
        LocalPlayer:Kick("❌ Whitelist structure error. Hubungi admin.")
        return false
    end
    local list = (type(data.whitelist) == "table") and data.whitelist or data
    local username = LocalPlayer.Name:lower()
    for _, entry in ipairs(list) do
        local clean = tostring(entry):lower():gsub("%s+", "")
        if clean == username then
            print("[ZassXd] ✓ Whitelist OK: " .. LocalPlayer.Name)
            return true
        end
    end
    warn("[ZassXd] '" .. LocalPlayer.Name .. "' tidak ada di whitelist.")
    LocalPlayer:Kick("❌ Kamu tidak ada di whitelist ZassXd!\nHubungi admin untuk akses.")
    return false
end

if not CheckWhitelist() then return end

-- ══════════════════════════════════════
--  RESPONSIVE SYSTEM
-- ══════════════════════════════════════

local Camera = workspace.CurrentCamera

local function GetScreenSize()
    local vp = Camera.ViewportSize
    local w, h = vp.X, vp.Y
    local isTouch = UserInputService.TouchEnabled
    local hasKbd  = UserInputService.KeyboardEnabled
    local isDesktop = hasKbd or (not isTouch)
    local isTablet  = isTouch and (w >= 700)

    if isDesktop then
        return { guiW=720, guiH=490, sidebarW=195, cardH=136,
                 titleSize=15, subSize=11, navSize=13, cardName=15, cardDesc=12,
                 searchH=36, navH=40, showExclusive=true, iconOnly=false, label="desktop" }
    elseif isTablet then
        return { guiW=math.min(math.floor(w*0.93),690), guiH=math.min(math.floor(h*0.80),450),
                 sidebarW=160, cardH=136, titleSize=13, subSize=10, navSize=12, cardName=14, cardDesc=12,
                 searchH=34, navH=38, showExclusive=true, iconOnly=false, label="tablet" }
    else
        return { guiW=math.floor(w*0.97), guiH=math.floor(h*0.88),
                 sidebarW=76, cardH=134, titleSize=11, subSize=9, navSize=11, cardName=13, cardDesc=11,
                 searchH=30, navH=36, showExclusive=false, iconOnly=true, label="mobile" }
    end
end

-- ══════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════

local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.22, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, dragArea)
    local dragging, dragInput, dragStart, startPos
    dragArea = dragArea or frame
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ══════════════════════════════════════
--  PALETTE
-- ══════════════════════════════════════

local C = {
    -- Backgrounds
    BG_BASE      = Color3.fromRGB(10,  14,  20),   -- hampir hitam, panel utama
    BG_SIDEBAR   = Color3.fromRGB(12,  17,  24),   -- sidebar sedikit lebih gelap
    BG_CONTENT   = Color3.fromRGB(14,  20,  30),   -- area konten
    BG_CARD      = Color3.fromRGB(18,  26,  38),   -- card background
    BG_CARD_HVR  = Color3.fromRGB(21,  31,  46),   -- card hover
    BG_INPUT     = Color3.fromRGB(16,  23,  33),   -- searchbox
    BG_BTN       = Color3.fromRGB(20,  30,  44),   -- tombol default
    BG_BTN_HVR   = Color3.fromRGB(0,   80,  110),  -- tombol hover (accent tint)
    BG_NAV_ACT   = Color3.fromRGB(17,  30,  46),   -- nav aktif

    -- Accent — safir dingin
    ACCENT       = Color3.fromRGB(56,  189, 248),  -- biru safir utama
    ACCENT_DIM   = Color3.fromRGB(30,  100, 140),  -- accent redup
    ACCENT_GLOW  = Color3.fromRGB(0,   150, 200),  -- untuk animasi

    -- Garis & border
    LINE         = Color3.fromRGB(28,  40,  58),   -- separator
    LINE_CARD    = Color3.fromRGB(32,  48,  68),   -- border card
    LINE_CARD_HI = Color3.fromRGB(56,  189, 248),  -- border card saat sukses

    -- Teks
    TXT_BRIGHT   = Color3.fromRGB(235, 242, 255),  -- teks utama
    TXT_MID      = Color3.fromRGB(140, 168, 200),  -- teks sekunder
    TXT_DIM      = Color3.fromRGB(70,  95,  125),  -- teks redup / label
    TXT_ACCENT   = Color3.fromRGB(56,  189, 248),  -- teks highlight
    TXT_SUCCESS  = Color3.fromRGB(52,  211, 153),
    TXT_ERROR    = Color3.fromRGB(251, 113, 113),
    TXT_WARN     = Color3.fromRGB(251, 191, 36),

    -- Tag badge
    TAG_BG       = Color3.fromRGB(14,  40,  58),
    TAG_LINE     = Color3.fromRGB(30,  90,  120),
}

-- ══════════════════════════════════════
--  SCRIPT DATA
-- ══════════════════════════════════════

local Scripts = {
    Fuun = {
        {Name="99 Night",      Desc="ytta",                               Tags={"Fuun"}, URL="https://nexus-script.vercel.app/99-Nights-in-the-Forest.lua"},
        {Name="Indo Strike",   Desc="ytta",                               Tags={"Fuun"}, URL="https://raw.githubusercontent.com/ambonaja/Kultivasi-Ambon/refs/heads/main/apaseh/kontol/indostrikev1"},
        {Name="Indo Voice",    Desc="ytta",                               Tags={"Fuun"}, URL="https://raw.githubusercontent.com/danuuww/scripts/refs/heads/main/free.lua"},
        {Name="Fish Zar",      Desc="ytta",                               Tags={"Fuun"}, URL="https://raw.githubusercontent.com/4LynxX/all_Game/refs/heads/main/fishzar.lua"},
        {Name="Fish It",       Desc="Usahakan server privat.",            Tags={"Fuun"}, URL="https://raw.githubusercontent.com/4LynxX/all_Game/refs/heads/main/Fish_It.lua"},
        {Name="Vd Kematian",   Desc="ytta.",                              Tags={"Fuun"}, URL="https://raw.githubusercontent.com/numerouno2/eugunewupremium/refs/heads/main/main.lua"},
        {Name="Sambung Kata",  Desc="ytta.",                              Tags={"Fuun"}, URL="https://raw.githubusercontent.com/numerouno2/eugunewupremium/refs/heads/main/main.lua"},
        {Name="Sawah Indo",    Desc="ytta.",                              Tags={"Fuun"}, URL="https://raw.githubusercontent.com/4LynxX/all_Game/refs/heads/main/Sawah_Indo.lua"},
        {Name="Empang Indo",   Desc="ytta.",                              Tags={"Fuun"}, URL="https://raw.githubusercontent.com/fay23-dam/sazaraaax-script/refs/heads/main/empang-indo.lua"},
    },
    Player = {
        {Name="Fly",           Desc="Terbang bebas di udara dengan speed control.", Tags={"Player"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/fly8.lua"},
        {Name="Clone Ava",     Desc="Visual avatar clone.",               Tags={"Player"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/cloneava7.lua"},
        {Name="Fps Booster",   Desc="Meringankan perangkat.",             Tags={"Player"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/fps2.lua"},
        {Name="Server Sepi",   Desc="Cari server dengan pemain sedikit.", Tags={"Player"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/searchserver.lua"},
    },
    Exploit = {
        {Name="Fake Donate",   Desc="",                                   Tags={"Exploit"}, URL="https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/Fake-Donate"},
        {Name="Fiqqzr7",       Desc="",                                   Tags={"Exploit"}, URL="https://raw.githubusercontent.com/Fiqqzr7Lua/SCRIPTFIQQZR7/refs/heads/main/Loader%20Fiqqzr7"},
        {Name="FayintXhub",    Desc="",                                   Tags={"Exploit"}, URL="https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/Universal"},
        {Name="Report Player", Desc="Report player setiap 1 menit.",      Tags={"Exploit"}, URL="https://raw.githubusercontent.com/xploitforceofficial-stack/rathubpublic/refs/heads/main/rathub.lua"},
        {Name="NoCounter",     Desc="Dari NoCounter family.",             Tags={"Exploit"}, URL="https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/NC-Full"},
        {Name="Infinite Yeild",Desc="Buka isi map, pakai dex.",          Tags={"Exploit"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/iy1.lua"},
        {Name="Flyfing",       Desc="Memantulkan player lain.",           Tags={"Exploit"}, URL="https://pastefy.app/DW3NUZcN/raw"},
        {Name="Speed",         Desc="Control speed dan jump.",            Tags={"Exploit"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/speed4.lua"},
        {Name="Laser",         Desc="Untuk rusuh.",                       Tags={"Exploit"}, URL="https://raw.githubusercontent.com/KNTLX69/SXTHR666/refs/heads/main/SIEXTHER-HYTAMKAN"},
        {Name="Kordinat",      Desc="Save koordinat, combo sama teleport.",Tags={"Exploit"},URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/kordinat.lua"},
        {Name="Auto Walk",     Desc="Key Z untuk record manual.",         Tags={"Exploit"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/record3.lua"},
    },
    Animation = {
        {Name="Animasi",       Desc="ZOMBIE · VAMPIRE · ADIDAS",          Tags={"Animation"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/animations.lua"},
    },
    Teleport = {
        {Name="TP to Spawn",   Desc="Teleport ke posisi spawn.",          Tags={"Teleport"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/tp5.lua"},
        {Name="TP to Player",  Desc="Teleport ke posisi player lain.",    Tags={"Teleport"}, URL="https://raw.githubusercontent.com/anamnich/download/refs/heads/main/tpplayer6.lua"},
    },
    Copy = {
        {Name="Copy Map",      Desc="Copy map — buka di PC/laptop.",      Tags={"Copy"}, URL="https://raw.githubusercontent.com/FayintXhub/FayintExploit/refs/heads/main/Copy-Maps"},
    },
    Info = {
        {Name="Gada info bang :V", Desc="Hubungi admin untuk informasi lebih lanjut."},
    },
}

-- ══════════════════════════════════════
--  BUILD UI
-- ══════════════════════════════════════

local S = GetScreenSize()
print("[ZassXd] Device: " .. S.label .. " (" .. S.guiW .. "×" .. S.guiH .. ")")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZassXdGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- ─── Shadow layer (frame semu di belakang, sedikit lebih besar) ───
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, S.guiW, 0, S.guiH)
MainFrame.Position = UDim2.new(0.5, -S.guiW/2, 1.5, 0)
MainFrame.BackgroundColor3 = C.BG_BASE
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local MFCorner = Instance.new("UICorner", MainFrame)
MFCorner.CornerRadius = UDim.new(0, 14)

-- Shadow sebagai child MainFrame — otomatis ikut drag
local Shadow = Instance.new("Frame")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(1, 24, 1, 24)
Shadow.Position = UDim2.new(0, -12, 0, -12)
Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
Shadow.BackgroundTransparency = 0.62
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = MainFrame
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 18)

-- ─── Main Frame ───

-- outline tipis
local MFStroke = Instance.new("UIStroke", MainFrame)
MFStroke.Color = Color3.fromRGB(36, 54, 76)
MFStroke.Thickness = 1

-- ─── Top Bar ───
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.BackgroundColor3 = C.BG_BASE
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 10
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

-- Logo dot (accent indicator kecil)
local LogoDot = Instance.new("Frame")
LogoDot.Size = UDim2.new(0, 8, 0, 8)
LogoDot.Position = UDim2.new(0, 20, 0.5, -4)
LogoDot.BackgroundColor3 = C.ACCENT
LogoDot.BorderSizePixel = 0
LogoDot.Parent = TopBar
Instance.new("UICorner", LogoDot).CornerRadius = UDim.new(1, 0)

-- Title
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 220, 0, 20)
TitleLabel.Position = UDim2.new(0, 36, 0, 11)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ZassXd"
TitleLabel.TextColor3 = C.TXT_BRIGHT
TitleLabel.TextSize = S.titleSize + 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Sub label
local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(0, 220, 0, 13)
SubLabel.Position = UDim2.new(0, 36, 0, 33)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "VVIP · Member"
SubLabel.TextColor3 = C.ACCENT
SubLabel.TextSize = S.subSize
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TopBar

-- Pill badge (exclusive — desktop/tablet)
if S.showExclusive then
    local Badge = Instance.new("Frame")
    Badge.Size = UDim2.new(0, 76, 0, 22)
    Badge.Position = UDim2.new(1, -114, 0.5, -11)
    Badge.BackgroundColor3 = Color3.fromRGB(14, 38, 54)
    Badge.BorderSizePixel = 0
    Badge.ZIndex = 11
    Badge.Parent = TopBar
    Instance.new("UICorner", Badge).CornerRadius = UDim.new(1, 0)
    local BadgeStroke = Instance.new("UIStroke", Badge)
    BadgeStroke.Color = C.ACCENT
    BadgeStroke.Thickness = 1
    local BadgeTxt = Instance.new("TextLabel", Badge)
    BadgeTxt.Size = UDim2.new(1,0,1,0)
    BadgeTxt.BackgroundTransparency = 1
    BadgeTxt.Text = "Exclusive"
    BadgeTxt.TextColor3 = C.ACCENT
    BadgeTxt.TextSize = 11
    BadgeTxt.Font = Enum.Font.GothamBold
    BadgeTxt.ZIndex = 12
end

-- Minimize/Close buttons
local function MakeTopBtn(char, posX, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, posX, 0.5, -14)
    btn.BackgroundColor3 = Color3.fromRGB(22, 32, 46)
    btn.Text = char
    btn.TextColor3 = color
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.ZIndex = 11
    btn.Parent = TopBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
    local st = Instance.new("UIStroke", btn)
    st.Color = Color3.fromRGB(36, 54, 76)
    st.Thickness = 1
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 55, 72)}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(22, 32, 46)}, 0.15)
    end)
    return btn
end

local CloseBtn = MakeTopBtn("X", -36, Color3.fromRGB(251,113,113))
CloseBtn.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Position = UDim2.new(0.5, -S.guiW/2, 1.5, 0), BackgroundTransparency = 1}, 0.28, Enum.EasingStyle.Quint)
    Tween(Shadow, {BackgroundTransparency = 1}, 0.28)
    task.delay(0.32, function() ScreenGui:Destroy() end)
end)

MakeDraggable(MainFrame, TopBar)

-- ─── Separator line ───
local function MakeLine(parent, y)
    local l = Instance.new("Frame")
    l.Size = UDim2.new(1, 0, 0, 1)
    l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundColor3 = C.LINE
    l.BorderSizePixel = 0
    l.Parent = parent
    return l
end
MakeLine(MainFrame, 58)

-- ─── Sidebar ───
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, S.sidebarW, 1, -59)
Sidebar.Position = UDim2.new(0, 0, 0, 59)
Sidebar.BackgroundColor3 = C.BG_SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- vertical divider antara sidebar & konten
local VLine = Instance.new("Frame")
VLine.Size = UDim2.new(0, 1, 1, -59)
VLine.Position = UDim2.new(0, S.sidebarW, 0, 59)
VLine.BackgroundColor3 = C.LINE
VLine.BorderSizePixel = 0
VLine.Parent = MainFrame

-- ─── Search Box ───
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -12, 0, S.searchH)
SearchBox.Position = UDim2.new(0, 6, 0, 8)
SearchBox.BackgroundColor3 = C.BG_INPUT
SearchBox.Text = ""
SearchBox.PlaceholderText = S.iconOnly and "⌕" or "⌕  Cari script..."
SearchBox.TextColor3 = C.TXT_MID
SearchBox.PlaceholderColor3 = C.TXT_DIM
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.BorderSizePixel = 0
SearchBox.Parent = Sidebar
local SBCorner = Instance.new("UICorner", SearchBox)
SBCorner.CornerRadius = UDim.new(0, 8)
local SBStroke = Instance.new("UIStroke", SearchBox)
SBStroke.Color = C.LINE_CARD
SBStroke.Thickness = 1
local SBPad = Instance.new("UIPadding", SearchBox)
SBPad.PaddingLeft = UDim.new(0, S.iconOnly and 4 or 10)

SearchBox.Focused:Connect(function()
    Tween(SBStroke, {Color = C.ACCENT_DIM}, 0.18)
end)
SearchBox.FocusLost:Connect(function()
    Tween(SBStroke, {Color = C.LINE_CARD}, 0.18)
end)

-- ─── Nav List ───
local Categories    = {"Fuun","Player","Exploit","Animation","Teleport","Copy","Info"}
local CategoryIcons = {"✦","◈","⚡","◉","◆","❖","⚙"}
local NavButtons    = {}
local ActiveCategory = "Fuun"

local navTop = S.searchH + 14
local NavList = Instance.new("Frame")
NavList.Size = UDim2.new(1, 0, 1, -navTop)
NavList.Position = UDim2.new(0, 0, 0, navTop)
NavList.BackgroundTransparency = 1
NavList.Parent = Sidebar
local NavLayout = Instance.new("UIListLayout", NavList)
NavLayout.Padding = UDim.new(0, 1)

-- Active indicator (strip vertikal)
local ActiveBar = Instance.new("Frame")
ActiveBar.Size = UDim2.new(0, 3, 0, 22)
ActiveBar.BackgroundColor3 = C.ACCENT
ActiveBar.BorderSizePixel = 0
ActiveBar.ZIndex = 8
ActiveBar.Parent = Sidebar
Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(1, 0)

-- ─── Content Area ───
local cOffX = S.sidebarW + 2
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -cOffX, 1, -59)
ContentArea.Position = UDim2.new(0, cOffX, 0, 59)
ContentArea.BackgroundColor3 = C.BG_CONTENT
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

-- Category breadcrumb label
local CatLabel = Instance.new("TextLabel")
CatLabel.Size = UDim2.new(1, -16, 0, 28)
CatLabel.Position = UDim2.new(0, 12, 0, 4)
CatLabel.BackgroundTransparency = 1
CatLabel.Text = "FUUN"
CatLabel.TextColor3 = C.TXT_DIM
CatLabel.TextSize = S.iconOnly and 9 or 10
CatLabel.Font = Enum.Font.GothamBold
CatLabel.TextXAlignment = Enum.TextXAlignment.Left
CatLabel.Parent = ContentArea

-- thin accent underline di bawah label
local CatUnderline = Instance.new("Frame")
CatUnderline.Size = UDim2.new(0, 32, 0, 1)
CatUnderline.Position = UDim2.new(0, 12, 0, 30)
CatUnderline.BackgroundColor3 = C.ACCENT
CatUnderline.BorderSizePixel = 0
CatUnderline.Parent = ContentArea

-- ─── Scroll Frame ───
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -40)
ScrollFrame.Position = UDim2.new(0, 5, 0, 36)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 2
ScrollFrame.ScrollBarImageColor3 = C.ACCENT_DIM
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = ContentArea

local ScrollLayout = Instance.new("UIListLayout", ScrollFrame)
ScrollLayout.Padding = UDim.new(0, 7)

local ScrollPad = Instance.new("UIPadding", ScrollFrame)
ScrollPad.PaddingBottom = UDim.new(0, 10)
ScrollPad.PaddingTop = UDim.new(0, 4)
ScrollPad.PaddingLeft = UDim.new(0, 2)
ScrollPad.PaddingRight = UDim.new(0, 2)

-- ══════════════════════════════════════
--  CARD BUILDER
-- ══════════════════════════════════════

local function CreateScriptCard(data)
    local Card = Instance.new("Frame")
    Card.Name = data.Name
    Card.Size = UDim2.new(1, 0, 0, S.cardH)
    Card.BackgroundColor3 = C.BG_CARD
    Card.BorderSizePixel = 0
    Card.Parent = ScrollFrame
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 10)

    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = C.LINE_CARD
    CardStroke.Thickness = 1

    -- Accent strip kiri (thin, elegan)
    local Strip = Instance.new("Frame")
    Strip.Size = UDim2.new(0, 2, 0.6, 0)
    Strip.Position = UDim2.new(0, 0, 0.2, 0)
    Strip.BackgroundColor3 = C.ACCENT_DIM
    Strip.BorderSizePixel = 0
    Strip.Parent = Card
    Instance.new("UICorner", Strip).CornerRadius = UDim.new(1, 0)

    -- Hover effect
    local CardBtn = Instance.new("TextButton")
    CardBtn.Size = UDim2.new(1,0,1,0)
    CardBtn.BackgroundTransparency = 1
    CardBtn.Text = ""
    CardBtn.AutoButtonColor = false
    CardBtn.ZIndex = 0
    CardBtn.Parent = Card

    CardBtn.MouseEnter:Connect(function()
        Tween(Card, {BackgroundColor3 = C.BG_CARD_HVR}, 0.18)
        Tween(Strip, {BackgroundColor3 = C.ACCENT}, 0.18)
    end)
    CardBtn.MouseLeave:Connect(function()
        Tween(Card, {BackgroundColor3 = C.BG_CARD}, 0.18)
        Tween(Strip, {BackgroundColor3 = C.ACCENT_DIM}, 0.18)
    end)

    -- Name
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -16, 0, 20)
    NameLabel.Position = UDim2.new(0, 13, 0, 9)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = data.Name
    NameLabel.TextColor3 = C.TXT_BRIGHT
    NameLabel.TextSize = S.cardName
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.ZIndex = 2
    NameLabel.Parent = Card

    -- Desc
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -16, 0, 15)
    DescLabel.Position = UDim2.new(0, 13, 0, 30)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Text = data.Desc or ""
    DescLabel.TextColor3 = C.TXT_MID
    DescLabel.TextSize = S.cardDesc
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DescLabel.ZIndex = 2
    DescLabel.Parent = Card

    -- Tags
    if data.Tags then
        local TagX = 13
        for _, tag in pairs(data.Tags) do
            local tw = math.max(#tag * 6 + 14, 40)
            local TagBadge = Instance.new("TextLabel")
            TagBadge.Size = UDim2.new(0, tw, 0, 15)
            TagBadge.Position = UDim2.new(0, TagX, 0, 50)
            TagBadge.BackgroundColor3 = C.TAG_BG
            TagBadge.Text = tag
            TagBadge.TextColor3 = C.TXT_ACCENT
            TagBadge.TextSize = 9
            TagBadge.Font = Enum.Font.GothamBold
            TagBadge.BorderSizePixel = 0
            TagBadge.ZIndex = 2
            TagBadge.Parent = Card
            Instance.new("UICorner", TagBadge).CornerRadius = UDim.new(0, 4)
            local TS = Instance.new("UIStroke", TagBadge)
            TS.Color = C.TAG_LINE
            TS.Thickness = 1
            TagX = TagX + tw + 6
        end
    end

    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -16, 0, 12)
    StatusLabel.Position = UDim2.new(0, 13, 0, S.cardH - 18)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = C.TXT_ACCENT
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.ZIndex = 2
    StatusLabel.Parent = Card

    if not data.URL then return end

    -- Button sizes
    local btnW  = S.iconOnly and 90  or 118
    local btnW2 = S.iconOnly and 60  or 76
    local btnH  = S.iconOnly and 26  or 29
    local btnY  = 72
    local btnTxt = S.iconOnly and 10 or 12

    -- ── Execute Button ──
    local ExecBtn = Instance.new("TextButton")
    ExecBtn.Size = UDim2.new(0, btnW, 0, btnH)
    ExecBtn.Position = UDim2.new(0, 13, 0, btnY)
    ExecBtn.BackgroundColor3 = C.BG_BTN
    ExecBtn.Text = "▶  Jalankan"
    ExecBtn.TextColor3 = C.TXT_MID
    ExecBtn.TextSize = btnTxt
    ExecBtn.Font = Enum.Font.GothamBold
    ExecBtn.BorderSizePixel = 0
    ExecBtn.AutoButtonColor = false
    ExecBtn.ZIndex = 3
    ExecBtn.Parent = Card
    Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 7)
    local EBStroke = Instance.new("UIStroke", ExecBtn)
    EBStroke.Color = Color3.fromRGB(40, 60, 84)
    EBStroke.Thickness = 1

    ExecBtn.MouseEnter:Connect(function()
        Tween(ExecBtn, {BackgroundColor3 = C.BG_BTN_HVR, TextColor3 = C.TXT_BRIGHT}, 0.16)
        Tween(EBStroke, {Color = C.ACCENT}, 0.16)
    end)
    ExecBtn.MouseLeave:Connect(function()
        Tween(ExecBtn, {BackgroundColor3 = C.BG_BTN, TextColor3 = C.TXT_MID}, 0.16)
        Tween(EBStroke, {Color = Color3.fromRGB(40,60,84)}, 0.16)
    end)

    ExecBtn.MouseButton1Click:Connect(function()
        if not ExecBtn.Active then return end
        ExecBtn.Active = false
        ExecBtn.Text = "Memuat..."
        StatusLabel.Text = "Mengambil script..."
        StatusLabel.TextColor3 = C.TXT_MID
        Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(12,50,70)}, 0.12)

        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(data.URL, true))()
            end)
            if ok then
                ExecBtn.Text = "✓ Berhasil"
                ExecBtn.TextColor3 = C.TXT_SUCCESS
                StatusLabel.Text = "Script berhasil dijalankan."
                StatusLabel.TextColor3 = C.TXT_SUCCESS
                Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(8,45,35)}, 0.2)
                Tween(CardStroke, {Color = Color3.fromRGB(30,120,90)}, 0.2)
                Tween(Strip, {BackgroundColor3 = C.TXT_SUCCESS}, 0.2)
                task.delay(2.5, function()
                    ExecBtn.Text = "▶  Jalankan"
                    ExecBtn.TextColor3 = C.TXT_MID
                    Tween(ExecBtn, {BackgroundColor3 = C.BG_BTN}, 0.2)
                    Tween(CardStroke, {Color = C.LINE_CARD}, 0.2)
                    Tween(Strip, {BackgroundColor3 = C.ACCENT_DIM}, 0.2)
                    ExecBtn.Active = true
                    StatusLabel.Text = ""
                end)
            else
                ExecBtn.Text = "✗ Gagal"
                ExecBtn.TextColor3 = C.TXT_ERROR
                StatusLabel.Text = "Gagal. Periksa URL script."
                StatusLabel.TextColor3 = C.TXT_ERROR
                Tween(ExecBtn, {BackgroundColor3 = Color3.fromRGB(60,15,15)}, 0.2)
                Tween(CardStroke, {Color = Color3.fromRGB(120,40,40)}, 0.2)
                Tween(Strip, {BackgroundColor3 = C.TXT_ERROR}, 0.2)
                warn("[ZassXd] Error '" .. data.Name .. "': " .. tostring(err))
                task.delay(3, function()
                    ExecBtn.Text = "▶  Jalankan"
                    ExecBtn.TextColor3 = C.TXT_MID
                    Tween(ExecBtn, {BackgroundColor3 = C.BG_BTN}, 0.2)
                    Tween(CardStroke, {Color = C.LINE_CARD}, 0.2)
                    Tween(Strip, {BackgroundColor3 = C.ACCENT_DIM}, 0.2)
                    ExecBtn.Active = true
                    StatusLabel.Text = ""
                end)
            end
        end)
    end)

    -- ── Detail Button ──
    local DetailBtn = Instance.new("TextButton")
    DetailBtn.Size = UDim2.new(0, btnW2, 0, btnH)
    DetailBtn.Position = UDim2.new(0, 13 + btnW + 6, 0, btnY)
    DetailBtn.BackgroundColor3 = C.BG_BTN
    DetailBtn.Text = "Info"
    DetailBtn.TextColor3 = C.TXT_DIM
    DetailBtn.TextSize = btnTxt
    DetailBtn.Font = Enum.Font.Gotham
    DetailBtn.BorderSizePixel = 0
    DetailBtn.AutoButtonColor = false
    DetailBtn.ZIndex = 3
    DetailBtn.Parent = Card
    Instance.new("UICorner", DetailBtn).CornerRadius = UDim.new(0, 7)
    local DBStroke = Instance.new("UIStroke", DetailBtn)
    DBStroke.Color = Color3.fromRGB(34, 50, 70)
    DBStroke.Thickness = 1

    DetailBtn.MouseEnter:Connect(function()
        Tween(DetailBtn, {BackgroundColor3 = Color3.fromRGB(24,36,52), TextColor3 = C.TXT_MID}, 0.16)
    end)
    DetailBtn.MouseLeave:Connect(function()
        Tween(DetailBtn, {BackgroundColor3 = C.BG_BTN, TextColor3 = C.TXT_DIM}, 0.16)
    end)
    DetailBtn.MouseButton1Click:Connect(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = data.Name,
            Text  = data.Desc or "—",
            Duration = 5,
        })
    end)
end

-- ══════════════════════════════════════
--  NAVIGATION
-- ══════════════════════════════════════

local function LoadCategory(category)
    ActiveCategory = category
    CatLabel.Text = string.upper(category)
    -- Resize underline sesuai teks
    local labelW = math.max(#category * 7 + 8, 28)
    Tween(CatUnderline, {Size = UDim2.new(0, labelW, 0, 1)}, 0.22)
    -- Clear cards
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
            Tween(btn, {BackgroundColor3 = C.BG_NAV_ACT}, 0.2)
            btn.TextColor3 = C.TXT_ACCENT
            -- Geser indicator bar
            local relY = btn.AbsolutePosition.Y - Sidebar.AbsolutePosition.Y + (S.navH / 2) - 11
            Tween(ActiveBar, {Position = UDim2.new(0, 0, 0, relY)}, 0.22, Enum.EasingStyle.Quint)
        else
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(13, 17, 24)}, 0.2)
            btn.BackgroundTransparency = 0
            btn.TextColor3 = C.TXT_DIM
        end
    end
end

for i, cat in ipairs(Categories) do
    local NavBtn = Instance.new("TextButton")
    NavBtn.Size = UDim2.new(1, 0, 0, S.navH)
    NavBtn.BackgroundTransparency = 0
    NavBtn.BackgroundColor3 = Color3.fromRGB(13, 17, 24)
    NavBtn.Text = S.iconOnly and (" " .. CategoryIcons[i]) or ("  " .. CategoryIcons[i] .. "  " .. cat)
    NavBtn.TextColor3 = C.TXT_DIM
    NavBtn.TextSize = S.navSize
    NavBtn.Font = Enum.Font.Gotham
    NavBtn.TextXAlignment = Enum.TextXAlignment.Left
    NavBtn.BorderSizePixel = 0
    NavBtn.AutoButtonColor = false
    NavBtn.ZIndex = 4
    NavBtn.Parent = NavList

    local BPad = Instance.new("UIPadding", NavBtn)
    BPad.PaddingLeft = UDim.new(0, 6)

    NavButtons[cat] = NavBtn

    NavBtn.MouseEnter:Connect(function()
        if ActiveCategory ~= cat then
            Tween(NavBtn, {TextColor3 = C.TXT_MID}, 0.15)
        end
    end)
    NavBtn.MouseLeave:Connect(function()
        if ActiveCategory ~= cat then
            Tween(NavBtn, {TextColor3 = C.TXT_DIM}, 0.15)
        end
    end)
    NavBtn.MouseButton1Click:Connect(function()
        LoadCategory(cat)
        UpdateNavButtons(cat)
    end)
end

-- ─── Search ───
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = SearchBox.Text:lower()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    if q == "" then
        LoadCategory(ActiveCategory)
        return
    end
    CatLabel.Text = "HASIL PENCARIAN"
    for _, list in pairs(Scripts) do
        for _, s in pairs(list) do
            if s.Name and s.Desc and (s.Name:lower():find(q) or s.Desc:lower():find(q)) then
                CreateScriptCard(s)
            end
        end
    end
end)

-- ══════════════════════════════════════
--  LOADING SCREEN
-- ══════════════════════════════════════

local RunService = game:GetService("RunService")
MainFrame.Visible = false

local LoadGui = Instance.new("Frame")
LoadGui.Name = "LoadingScreen"
LoadGui.Size = UDim2.new(1, 0, 1, 0)
LoadGui.Position = UDim2.new(0, 0, 0, 0)
LoadGui.BackgroundTransparency = 1
LoadGui.BorderSizePixel = 0
LoadGui.ZIndex = 100
LoadGui.Parent = ScreenGui

local BgTint = Instance.new("Frame")
BgTint.Size = UDim2.new(0, 0, 0, 0)
BgTint.BackgroundTransparency = 1
BgTint.BorderSizePixel = 0
BgTint.ZIndex = 0
BgTint.Parent = LoadGui

-- Panel — warna sesuai UI utama (biru gelap)
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 460, 0, 240)
Panel.Position = UDim2.new(0.5, -230, 0.5, 20)   -- mulai sedikit di bawah tengah
Panel.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
Panel.BackgroundTransparency = 1                   -- mulai transparan (fade in)
Panel.BorderSizePixel = 0
Panel.ZIndex = 103
Panel.Parent = LoadGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 14)

local PanelStroke = Instance.new("UIStroke", Panel)
PanelStroke.Color = Color3.fromRGB(56, 189, 248)  -- biru accent utama
PanelStroke.Thickness = 1
PanelStroke.Transparency = 1                       -- mulai transparan

-- Marquee
local MarqueeClip = Instance.new("Frame")
MarqueeClip.Size = UDim2.new(1, 0, 0, 28)
MarqueeClip.Position = UDim2.new(0, 0, 0, 16)
MarqueeClip.BackgroundTransparency = 1
MarqueeClip.ClipsDescendants = true
MarqueeClip.BorderSizePixel = 0
MarqueeClip.ZIndex = 104
MarqueeClip.Parent = Panel

local MarqueeText = Instance.new("TextLabel")
MarqueeText.Size = UDim2.new(0, 900, 1, 0)
MarqueeText.Position = UDim2.new(0, 0, 0, 0)
MarqueeText.BackgroundTransparency = 1
MarqueeText.Text = "  ZASSXD  •  VVIP  •  ZASSXD  •  VVIP  •  ZASSXD  •  VVIP  •  ZASSXD  •  "
MarqueeText.TextColor3 = Color3.fromRGB(56, 189, 248)
MarqueeText.TextTransparency = 1
MarqueeText.TextSize = 12
MarqueeText.Font = Enum.Font.GothamBold
MarqueeText.TextXAlignment = Enum.TextXAlignment.Left
MarqueeText.ZIndex = 105
MarqueeText.Parent = MarqueeClip

-- Separator line di bawah marquee
local SepLine = Instance.new("Frame")
SepLine.Size = UDim2.new(1, -32, 0, 1)
SepLine.Position = UDim2.new(0, 16, 0, 46)
SepLine.BackgroundColor3 = Color3.fromRGB(28, 40, 58)
SepLine.BorderSizePixel = 0
SepLine.ZIndex = 104
SepLine.Parent = Panel

-- Terminal lines
local TermLines = {
    "[SYSTEM] Initializing ZassXd v2.0...",
    "[AUTH]   Verifying whitelist...",
    "[AUTH]   Access Granted ✓",
    "[STATUS] Loading modules...",
    "[SYSTEM] Stay Safe & Have Fun",
}

local termLabels = {}
for i, line in ipairs(TermLines) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -32, 0, 18)
    lbl.Position = UDim2.new(0, 16, 0, 52 + (i-1) * 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = line
    lbl.TextColor3 = i == 3
        and Color3.fromRGB(52, 211, 153)   -- hijau sukses untuk "Access Granted"
        or  Color3.fromRGB(140, 168, 200)  -- biru-abu sesuai TXT_MID
    lbl.TextTransparency = 1
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 105
    lbl.Parent = Panel
    table.insert(termLabels, lbl)
end

-- Progress bar background
local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(1, -32, 0, 4)
BarBg.Position = UDim2.new(0, 16, 1, -28)
BarBg.BackgroundColor3 = Color3.fromRGB(28, 40, 58)
BarBg.BorderSizePixel = 0
BarBg.ZIndex = 105
BarBg.Parent = Panel
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(56, 189, 248)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 106
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local PctLabel = Instance.new("TextLabel")
PctLabel.Size = UDim2.new(0, 50, 0, 14)
PctLabel.Position = UDim2.new(1, -66, 1, -22)
PctLabel.BackgroundTransparency = 1
PctLabel.Text = "0%"
PctLabel.TextColor3 = Color3.fromRGB(56, 189, 248)
PctLabel.TextTransparency = 1
PctLabel.TextSize = 10
PctLabel.Font = Enum.Font.GothamBold
PctLabel.TextXAlignment = Enum.TextXAlignment.Right
PctLabel.ZIndex = 105
PctLabel.Parent = Panel

local PromptLabel = Instance.new("TextLabel")
PromptLabel.Size = UDim2.new(1, -32, 0, 14)
PromptLabel.Position = UDim2.new(0, 16, 1, -22)
PromptLabel.BackgroundTransparency = 1
PromptLabel.Text = "zassxd:~$ loading..."
PromptLabel.TextColor3 = Color3.fromRGB(70, 95, 125)
PromptLabel.TextTransparency = 1
PromptLabel.TextSize = 10
PromptLabel.Font = Enum.Font.Code
PromptLabel.TextXAlignment = Enum.TextXAlignment.Left
PromptLabel.ZIndex = 105
PromptLabel.Parent = Panel

-- ══════════════════════════════════════
--  ANIMATE LOADING
-- ══════════════════════════════════════

local function DoLoading()
    -- Animasi masuk: panel slide up + fade in
    Tween(Panel, {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -230, 0.5, -120)
    }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(0.2, function()
        Tween(PanelStroke, {Transparency = 0}, 0.3)
        Tween(MarqueeText, {TextTransparency = 0}, 0.4)
        Tween(PctLabel, {TextTransparency = 0}, 0.4)
        Tween(PromptLabel, {TextTransparency = 0}, 0.4)
    end)

    -- Marquee scroll
    local marqueeConn
    local marqueeX = 0
    marqueeConn = RunService.Heartbeat:Connect(function(dt)
        marqueeX = marqueeX - 55 * dt
        if marqueeX < -450 then marqueeX = 0 end
        MarqueeText.Position = UDim2.new(0, marqueeX, 0, 0)
    end)

    -- Terminal lines muncul bertahap
    local totalDuration = 3.2
    local lineDelay = totalDuration / (#termLabels + 1)
    for i, lbl in ipairs(termLabels) do
        task.delay(0.3 + lineDelay * i, function()
            Tween(lbl, {TextTransparency = 0}, 0.25)
        end)
    end

    -- Progress bar
    local progConn
    local elapsed = 0
    progConn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        local pct = math.min(elapsed / totalDuration, 1)
        BarFill.Size = UDim2.new(pct, 0, 1, 0)
        PctLabel.Text = math.floor(pct * 100) .. "%"

        if pct > 0.75 then
            BarFill.BackgroundColor3 = Color3.fromRGB(52, 211, 153)
            PctLabel.TextColor3 = Color3.fromRGB(52, 211, 153)
        end

        if pct >= 1 then progConn:Disconnect() end
    end)

    -- Fade out & tampilkan GUI utama
    task.delay(totalDuration + 0.4, function()
        marqueeConn:Disconnect()

        -- Animasi keluar: slide down + fade out
        Tween(Panel, {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -230, 0.5, -80)
        }, 0.35, Enum.EasingStyle.Quint)
        Tween(PanelStroke, {Transparency = 1}, 0.3)
        for _, lbl in pairs(termLabels) do
            Tween(lbl, {TextTransparency = 1}, 0.2)
        end
        Tween(MarqueeText, {TextTransparency = 1}, 0.2)
        Tween(PromptLabel, {TextTransparency = 1}, 0.2)
        Tween(PctLabel, {TextTransparency = 1}, 0.2)

        task.delay(0.4, function()
            LoadGui:Destroy()
            MainFrame.Visible = true
            LoadCategory("Fuun")
            UpdateNavButtons("Fuun")
            local targetPos = UDim2.new(0.5, -S.guiW/2, 0.5, -S.guiH/2)
            Tween(MainFrame, {Position = targetPos}, 0.42, Enum.EasingStyle.Back)
            print("[ZassXd GUI] Siap! Device=" .. S.label .. " | User=" .. LocalPlayer.Name)
        end)
    end)
end

DoLoading()
