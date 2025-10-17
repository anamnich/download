-- 💠 ZassXd Teleport Manager v2.5 (Speed Display + Smart Minimize)
-- ✨ Fitur: Auto Save, Auto Teleport, Speed Control (Live), Smart Minimize, Neon Capsule UI

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- === DATA ===
local TeleportData = {}
local teleportCounter = 0
local dataFileName = "TeleportData_"..player.UserId..".json"

local autoTeleportEnabled = false
local autoTeleportSpeed = 1
local autoTeleportIndex = 1

-- === FILE FUNCTIONS ===
local function canUseFiles()
	return writefile and readfile and isfile
end

local function saveData()
	if not canUseFiles() then return end
	pcall(function()
		writefile(dataFileName, HttpService:JSONEncode(TeleportData))
	end)
end

local function loadData()
	if not canUseFiles() or not isfile(dataFileName) then return end
	pcall(function()
		local data = readfile(dataFileName)
		TeleportData = HttpService:JSONDecode(data)
		teleportCounter = #TeleportData
	end)
end
loadData()

-- === UI UTILS ===
local function makeCapsule(btn)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5,0)
	c.Parent = btn
end

-- === MAIN GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZassXdTeleportManager"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Position = UDim2.new(0.72, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0,255,255)
stroke.Thickness = 2
stroke.Transparency = 0.3

-- === TITLE BAR ===
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = Color3.fromRGB(25,25,35)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,8)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💠 ZassXd Teleport"
Title.TextColor3 = Color3.fromRGB(0,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- === CLOSE & MINIMIZE ===
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-35,0.5,-15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
makeCapsule(CloseBtn)

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0,30,0,30)
MinBtn.Position = UDim2.new(1,-70,0.5,-15)
MinBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(0,0,0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextScaled = true
makeCapsule(MinBtn)

-- === SCROLL LIST ===
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1,-20,0.45,0)
ScrollFrame.Position = UDim2.new(0,10,0,42)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Visible = true

local UIList = Instance.new("UIListLayout", ScrollFrame)
UIList.Padding = UDim.new(0,4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- === BUTTON CONTAINER ===
local BtnFrame = Instance.new("Frame", MainFrame)
BtnFrame.Size = UDim2.new(1,0,0.45,0)
BtnFrame.Position = UDim2.new(0,0,0.55,0)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Visible = true

local function createButton(text, color, pos, size)
	local btn = Instance.new("TextButton")
	btn.Size = size or UDim2.new(0.44,0,0,30)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(0,0,0)
	makeCapsule(btn)
	btn.Parent = BtnFrame
	return btn
end

local AddBtn = createButton("Tambah", Color3.fromRGB(0,200,255), UDim2.new(0.05,0,0.05,0))
local RemoveBtn = createButton("Hapus", Color3.fromRGB(200,50,50), UDim2.new(0.5,0,0.05,0))
local AutoBtn = createButton("Auto Teleport: OFF", Color3.fromRGB(60,60,200), UDim2.new(0.05,0,0.25,0), UDim2.new(0.9,0,0,30))
local SpeedUpBtn = createButton("⚡ + Speed", Color3.fromRGB(0,200,0), UDim2.new(0.05,0,0.45,0))
local SpeedDownBtn = createButton("⚡ - Speed", Color3.fromRGB(200,0,0), UDim2.new(0.5,0,0.45,0))

-- === SPEED DISPLAY (LIVE) ===
local SpeedLabel = Instance.new("TextLabel", BtnFrame)
SpeedLabel.Size = UDim2.new(1,0,0,24)
SpeedLabel.Position = UDim2.new(0,0,0.68,0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚙️ Kecepatan: "..string.format("%.1f", autoTeleportSpeed)
SpeedLabel.TextColor3 = Color3.fromRGB(0,255,255)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextScaled = true

-- === REFRESH BUTTONS ===
local function refreshButtons()
	for _,v in pairs(ScrollFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	for i, pos in ipairs(TeleportData) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,28)
		btn.BackgroundColor3 = Color3.fromRGB(40,40,70)
		btn.TextColor3 = Color3.fromRGB(0,255,255)
		btn.Text = "TP "..i
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.Parent = ScrollFrame
		makeCapsule(btn)
		btn.MouseButton1Click:Connect(function()
			autoTeleportEnabled = false
			AutoBtn.Text = "Auto Teleport: OFF"
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
			end
		end)
	end
	ScrollFrame.CanvasSize = UDim2.new(0,0,0,teleportCounter * 32)
end
refreshButtons()

-- === BUTTON EVENTS ===
AddBtn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		teleportCounter += 1
		TeleportData[teleportCounter] = player.Character.HumanoidRootPart.Position
		refreshButtons()
		saveData()
	end
end)

RemoveBtn.MouseButton1Click:Connect(function()
	if teleportCounter > 0 then
		TeleportData[teleportCounter] = nil
		teleportCounter -= 1
		refreshButtons()
		saveData()
		autoTeleportIndex = math.min(autoTeleportIndex, teleportCounter)
	end
end)

AutoBtn.MouseButton1Click:Connect(function()
	autoTeleportEnabled = not autoTeleportEnabled
	AutoBtn.Text = autoTeleportEnabled and "Auto Teleport: ON" or "Auto Teleport: OFF"
end)

SpeedUpBtn.MouseButton1Click:Connect(function()
	autoTeleportSpeed = math.max(0.1, autoTeleportSpeed - 0.1)
	SpeedLabel.Text = "⚙️ Kecepatan: "..string.format("%.1f", autoTeleportSpeed)
end)

SpeedDownBtn.MouseButton1Click:Connect(function()
	autoTeleportSpeed = autoTeleportSpeed + 0.1
	SpeedLabel.Text = "⚙️ Kecepatan: "..string.format("%.1f", autoTeleportSpeed)
end)

-- === AUTO TELEPORT LOOP ===
local autoTimer = 0
RunService.RenderStepped:Connect(function(dt)
	if autoTeleportEnabled and teleportCounter > 0 and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		autoTimer += dt
		if autoTimer >= autoTeleportSpeed then
			autoTimer = 0
			local pos = TeleportData[autoTeleportIndex]
			if pos then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
			end
			autoTeleportIndex += 1
			if autoTeleportIndex > teleportCounter then
				autoTeleportIndex = 1
			end
		end
	end
end)

-- === SMART MINIMIZE ===
local minimized = false
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 260, 0, 60)}):Play()
		ScrollFrame.Visible = false
		BtnFrame.Visible = false
	else
		TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 260, 0, 360)}):Play()
		task.wait(0.3)
		ScrollFrame.Visible = true
		BtnFrame.Visible = true
	end
end)

-- === CLOSE ===
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
