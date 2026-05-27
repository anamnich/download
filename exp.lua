local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

local Config = {
    BoxEnabled  = true,
    LineEnabled = true,
    NameEnabled = true,
    DistEnabled = true,

    BoxColor    = Color3.fromRGB(255, 60,  60),
    LineColor   = Color3.fromRGB(100, 180, 255),
    NameColor   = Color3.fromRGB(255, 255, 255),
    DistColor   = Color3.fromRGB(100, 220, 180),

    BoxThickness  = 1.5,
    LineThickness = 1,
    NameSize      = 13,
    DistSize      = 12,
    Font          = Drawing.Fonts.UI,
}

local ESPEnabled = true
local ESPObjects = {}

local function D(t, p)
    local o = Drawing.new(t)
    for k,v in pairs(p) do o[k]=v end
    return o
end

local function CreateESP(player)
    if player == LP then return end
    local c = Config
    ESPObjects[player] = {
        BoxTop    = D("Line",{Color=c.BoxColor,Thickness=c.BoxThickness,Visible=false,Transparency=1}),
        BoxBottom = D("Line",{Color=c.BoxColor,Thickness=c.BoxThickness,Visible=false,Transparency=1}),
        BoxLeft   = D("Line",{Color=c.BoxColor,Thickness=c.BoxThickness,Visible=false,Transparency=1}),
        BoxRight  = D("Line",{Color=c.BoxColor,Thickness=c.BoxThickness,Visible=false,Transparency=1}),
        Line      = D("Line",{Color=c.LineColor,Thickness=c.LineThickness,Visible=false,Transparency=1}),
        Name      = D("Text",{Text=player.Name,Color=c.NameColor,Size=c.NameSize,Font=c.Font,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Visible=false,Transparency=1}),
        Dist      = D("Text",{Text="0m",Color=c.DistColor,Size=c.DistSize,Font=c.Font,Center=true,Outline=true,OutlineColor=Color3.new(0,0,0),Visible=false,Transparency=1}),
    }
end

local function RemoveESP(player)
    if not ESPObjects[player] then return end
    for _,o in pairs(ESPObjects[player]) do o:Remove() end
    ESPObjects[player] = nil
end

RunService.RenderStepped:Connect(function()
    local lpChar = LP.Character
    local lpRoot = lpChar and lpChar:FindFirstChild("HumanoidRootPart")

    for player, esp in pairs(ESPObjects) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local alive = root and head and hum and hum.Health > 0

        if not (ESPEnabled and alive) then
            for _,o in pairs(esp) do o.Visible=false end
            continue
        end

        local topPos,bottV    = Camera:WorldToViewportPoint(head.Position+Vector3.new(0,0.8,0))
        local bottomPos,_    = Camera:WorldToViewportPoint(root.Position-Vector3.new(0,3,0))
        local rootPos,rootVis = Camera:WorldToViewportPoint(root.Position)
        local vis = bottV and topPos.Z > 0

        local height = math.abs(topPos.Y - bottomPos.Y)
        local width  = height * 0.5
        local x = topPos.X - width/2
        local y = topPos.Y

        local dist = lpRoot and math.floor((lpRoot.Position-root.Position).Magnitude) or 0

        local bv = vis and Config.BoxEnabled
        esp.BoxTop.From=Vector2.new(x,y);         esp.BoxTop.To=Vector2.new(x+width,y)
        esp.BoxBottom.From=Vector2.new(x,y+height); esp.BoxBottom.To=Vector2.new(x+width,y+height)
        esp.BoxLeft.From=Vector2.new(x,y);         esp.BoxLeft.To=Vector2.new(x,y+height)
        esp.BoxRight.From=Vector2.new(x+width,y);  esp.BoxRight.To=Vector2.new(x+width,y+height)
        esp.BoxTop.Visible=bv; esp.BoxBottom.Visible=bv
        esp.BoxLeft.Visible=bv; esp.BoxRight.Visible=bv

        if Config.LineEnabled and vis and rootVis then
            local vp=Camera.ViewportSize
            esp.Line.From=Vector2.new(vp.X/2,vp.Y); esp.Line.To=Vector2.new(rootPos.X,rootPos.Y)
            esp.Line.Visible=true
        else esp.Line.Visible=false end

        if Config.NameEnabled and vis then
            esp.Name.Position=Vector2.new(topPos.X, y-16); esp.Name.Visible=true
        else esp.Name.Visible=false end

        if Config.DistEnabled and vis then
            esp.Dist.Text=tostring(dist).."m"
            esp.Dist.Position=Vector2.new(topPos.X, y-30); esp.Dist.Visible=true
        else esp.Dist.Visible=false end
    end
end)

-- ─── GUI Panel ────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPGui"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=game:GetService("CoreGui")

local Main=Instance.new("Frame")
Main.Size            = UDim2.new(0,200,0,190)  -- ← diperpanjang
Main.Position        = UDim2.new(0,20,0,20)
Main.BackgroundColor3= Color3.fromRGB(18,18,22)
Main.BorderSizePixel = 0; Main.Active=true; Main.Draggable=true
Main.Parent=ScreenGui
Instance.new("UICorner").Parent=Main

local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(100,180,255); stroke.Thickness=1; stroke.Parent=Main

local TitleBar=Instance.new("Frame")
TitleBar.Size=UDim2.new(1,0,0,28)
TitleBar.BackgroundColor3=Color3.fromRGB(30,30,40)
TitleBar.BorderSizePixel=0; TitleBar.Parent=Main
Instance.new("UICorner").Parent=TitleBar

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-70,1,0); Title.Position=UDim2.new(0,10,0,0)
Title.Text="ESP Panel"; Title.TextColor3=Color3.fromRGB(100,180,255)
Title.TextSize=13; Title.Font=Enum.Font.GothamBold
Title.BackgroundTransparency=1; Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=TitleBar

local function MakeTitleBtn(label,xPos,color)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,20,0,20); btn.Position=UDim2.new(1,-xPos,0,4)
    btn.Text=label; btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.TextSize=12; btn.Font=Enum.Font.GothamBold
    btn.BackgroundColor3=color; btn.BorderSizePixel=0; btn.Parent=TitleBar
    Instance.new("UICorner").Parent=btn
    return btn
end

local CloseBtn    = MakeTitleBtn("✕",26,Color3.fromRGB(200,60,60))
local MinimizeBtn = MakeTitleBtn("─",50,Color3.fromRGB(80,80,100))

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,0,1,-28); Content.Position=UDim2.new(0,0,0,28)
Content.BackgroundTransparency=1; Content.Parent=Main
local layout=Instance.new("UIListLayout",Content)
layout.Padding=UDim.new(0,6)  -- ← jarak antar baris lebih longgar
local pad=Instance.new("UIPadding",Content)
pad.PaddingTop=UDim.new(0,10); pad.PaddingLeft=UDim.new(0,8); pad.PaddingRight=UDim.new(0,8)

local function MakeToggle(label, state, callback)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,24)  -- ← tinggi baris lebih besar
    row.BackgroundTransparency=1; row.Parent=Content

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-52,1,0); lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(200,200,210)
    lbl.TextSize=12; lbl.Font=Enum.Font.Gotham
    lbl.BackgroundTransparency=1; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.Parent=row

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,44,0,20); btn.Position=UDim2.new(1,-44,0,2)
    btn.Text=state and "ON" or "OFF"; btn.TextSize=11; btn.Font=Enum.Font.GothamBold
    btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.BackgroundColor3=state and Color3.fromRGB(60,180,100) or Color3.fromRGB(160,60,60)
    btn.BorderSizePixel=0; btn.Parent=row
    Instance.new("UICorner").Parent=btn

    local on=state
    btn.MouseButton1Click:Connect(function()
        on=not on
        btn.Text=on and "ON" or "OFF"
        btn.BackgroundColor3=on and Color3.fromRGB(60,180,100) or Color3.fromRGB(160,60,60)
        callback(on)
    end)
end

MakeToggle("ESP (Semua)", true, function(v) ESPEnabled=v end)
MakeToggle("Box",         true, function(v) Config.BoxEnabled=v end)
MakeToggle("Line",        true, function(v) Config.LineEnabled=v end)
MakeToggle("Name",        true, function(v) Config.NameEnabled=v end)
MakeToggle("Jarak",       true, function(v) Config.DistEnabled=v end)

local minimized=false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    Content.Visible=not minimized
    Main.Size=minimized and UDim2.new(0,200,0,28) or UDim2.new(0,200,0,190)  -- ← 170
end)

CloseBtn.MouseButton1Click:Connect(function()
    ESPEnabled=false
    for _,esp in pairs(ESPObjects) do
        for _,o in pairs(esp) do o.Visible=false end
    end
    ScreenGui:Destroy()
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _,p in ipairs(Players:GetPlayers()) do CreateESP(p) end

print("[ESP V2] Aktif — Box | Line | Name | Jarak | GUI")
