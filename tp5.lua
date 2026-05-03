-- 💠 ZassXd Teleport Manager v3.0 (Save/Load File + Speed Display + Smart Minimize)
-- ✨ Fitur: Custom File Name, Save File, Load File, Auto Teleport, Speed Control (Live), Smart Minimize, Neon Capsule UI

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

local autoTeleportEnabled = false
local autoTeleportSpeed = 1
local autoTeleportIndex = 1

-- === FILE FUNCTIONS ===
local function canUseFiles()
	return writefile and readfile and isfile
end

local function saveDataToFile(fileName)
	if not canUseFiles() then
		return false, "Executor tidak support file"
	end
	local ok, err = pcall(function()
		-- Konversi Vector3 → {x, y, z} array supaya JSON bisa encode
		local serialized = {}
		for i, v3 in ipairs(TeleportData) do
			serialized[i] = {v3.X, v3.Y, v3.Z}
		end
		writefile(fileName, HttpService:JSONEncode(serialized))
	end)
	if ok then
		return true, "Berhasil disimpan ke: "..fileName
	else
		return false, "Gagal simpan: "..tostring(err)
	end
end

local function loadDataFromFile(fileName)
	if not canUseFiles() then
		return false, "Executor tidak support file"
	end
	if not isfile(fileName) then
		return false, "File tidak ditemukan: "..fileName
	end
	local ok, err = pcall(function()
		local data = readfile(fileName)
		local decoded = HttpService:JSONDecode(data)
		-- Konversi {x, y, z} array → Vector3
		TeleportData = {}
		for i, entry in ipairs(decoded) do
			if type(entry) == "table" then
				-- Format array [x, y, z]
				local x = entry[1] or entry.X or entry.x or 0
				local y = entry[2] or entry.Y or entry.y or 0
				local z = entry[3] or entry.Z or entry.z or 0
				TeleportData[i] = Vector3.new(x, y, z)
			end
		end
		teleportCounter = #TeleportData
	end)
	if ok then
		return true, "Berhasil dimuat dari: "..fileName
	else
		return false, "Gagal load: "..tostring(err)
	end
end

-- === UI UTILS ===
local function makeCapsule(btn)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = btn
end

local function makeRounded(frame, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = frame
end

-- === MAIN GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZassXdTeleportManager"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 460)
MainFrame.Position = UDim2.new(0.70, 0, 0.20, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
makeRounded(MainFrame, 12)

local stroke = Instance.new("UIStroke", MainFrame)
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 2
stroke.Transparency = 0.3

-- === TITLE BAR ===
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
makeRounded(TitleBar, 8)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "💠 ZassXd Teleport"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true

-- === CLOSE & MINIMIZE ===
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
makeCapsule(CloseBtn)

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextScaled = true
makeCapsule(MinBtn)

-- === FILE NAME SECTION ===
local FileSection = Instance.new("Frame", MainFrame)
FileSection.Size = UDim2.new(1, -20, 0, 78)
FileSection.Position = UDim2.new(0, 10, 0, 42)
FileSection.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
FileSection.BorderSizePixel = 0
makeRounded(FileSection, 8)

local fileStroke = Instance.new("UIStroke", FileSection)
fileStroke.Color = Color3.fromRGB(0, 150, 200)
fileStroke.Thickness = 1
fileStroke.Transparency = 0.5

local FileSectionTitle = Instance.new("TextLabel", FileSection)
FileSectionTitle.Size = UDim2.new(1, -8, 0, 18)
FileSectionTitle.Position = UDim2.new(0, 8, 0, 4)
FileSectionTitle.BackgroundTransparency = 1
FileSectionTitle.Text = "💾 Nama File Simpan/Muat"
FileSectionTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
FileSectionTitle.Font = Enum.Font.GothamBold
FileSectionTitle.TextSize = 11
FileSectionTitle.TextXAlignment = Enum.TextXAlignment.Left

local FileTextBox = Instance.new("TextBox", FileSection)
FileTextBox.Size = UDim2.new(1, -16, 0, 26)
FileTextBox.Position = UDim2.new(0, 8, 0, 22)
FileTextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
FileTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FileTextBox.PlaceholderText = "Masukkan nama file..."
FileTextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
FileTextBox.Text = ""
FileTextBox.Font = Enum.Font.Gotham
FileTextBox.TextSize = 13
FileTextBox.ClearTextOnFocus = false
makeRounded(FileTextBox, 6)
local tbStroke = Instance.new("UIStroke", FileTextBox)
tbStroke.Color = Color3.fromRGB(0, 200, 255)
tbStroke.Thickness = 1
tbStroke.Transparency = 0.4

-- Save & Load Buttons
local SaveFileBtn = Instance.new("TextButton", FileSection)
SaveFileBtn.Size = UDim2.new(0.46, 0, 0, 22)
SaveFileBtn.Position = UDim2.new(0.02, 0, 0, 52)
SaveFileBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
SaveFileBtn.Text = "💾 Save"
SaveFileBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
SaveFileBtn.Font = Enum.Font.GothamBold
SaveFileBtn.TextSize = 12
makeCapsule(SaveFileBtn)

local LoadFileBtn = Instance.new("TextButton", FileSection)
LoadFileBtn.Size = UDim2.new(0.46, 0, 0, 22)
LoadFileBtn.Position = UDim2.new(0.52, 0, 0, 52)
LoadFileBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
LoadFileBtn.Text = "📂 Load"
LoadFileBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
LoadFileBtn.Font = Enum.Font.GothamBold
LoadFileBtn.TextSize = 12
makeCapsule(LoadFileBtn)

-- === STATUS LABEL ===
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 10, 0, 124)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.ClipsDescendants = true

-- === SCROLL LIST ===
local ScrollFrame = Instance.new("ScrollingFrame", MainFrame)
ScrollFrame.Size = UDim2.new(1, -20, 0, 145)
ScrollFrame.Position = UDim2.new(0, 10, 0, 145)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Visible = true
makeRounded(ScrollFrame, 6)

local UIList = Instance.new("UIListLayout", ScrollFrame)
UIList.Padding = UDim.new(0, 4)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- === BUTTON CONTAINER ===
local BtnFrame = Instance.new("Frame", MainFrame)
BtnFrame.Size = UDim2.new(1, 0, 0, 165)
BtnFrame.Position = UDim2.new(0, 0, 0, 295)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Visible = true

local function createButton(text, color, pos, size)
	local btn = Instance.new("TextButton")
	btn.Size = size or UDim2.new(0.44, 0, 0, 30)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(0, 0, 0)
	btn.TextSize = 12
	makeCapsule(btn)
	btn.Parent = BtnFrame
	return btn
end

local AddBtn    = createButton("➕ Tambah",        Color3.fromRGB(0, 200, 255),  UDim2.new(0.05, 0, 0.02, 0))
local RemoveBtn = createButton("🗑️ Hapus",          Color3.fromRGB(200, 50, 50),   UDim2.new(0.51, 0, 0.02, 0))
local AutoBtn   = createButton("🔄 Auto TP: OFF",   Color3.fromRGB(60, 60, 200),   UDim2.new(0.05, 0, 0.24, 0), UDim2.new(0.90, 0, 0, 30))
local SpeedUpBtn   = createButton("⚡ + Speed",     Color3.fromRGB(0, 200, 0),    UDim2.new(0.05, 0, 0.48, 0))
local SpeedDownBtn = createButton("🔻 - Speed",     Color3.fromRGB(200, 0, 0),    UDim2.new(0.51, 0, 0.48, 0))

local SpeedLabel = Instance.new("TextLabel", BtnFrame)
SpeedLabel.Size = UDim2.new(1, 0, 0, 22)
SpeedLabel.Position = UDim2.new(0, 0, 0.72, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚙️ Kecepatan: " .. string.format("%.1f", autoTeleportSpeed) .. "s"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextScaled = true

-- === STATUS FLASH ===
local statusConn
local function showStatus(msg, color)
	StatusLabel.Text = msg
	StatusLabel.TextColor3 = color or Color3.fromRGB(0, 255, 150)
	if statusConn then statusConn:Disconnect() end
	local t = 0
	statusConn = RunService.RenderStepped:Connect(function(dt)
		t += dt
		if t >= 3 then
			StatusLabel.Text = ""
			statusConn:Disconnect()
		end
	end)
end

-- === REFRESH BUTTONS ===
local function refreshList()
	for _, v in pairs(ScrollFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end
	for i, pos in ipairs(TeleportData) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 28)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
		btn.TextColor3 = Color3.fromRGB(0, 255, 255)
		btn.Text = "📍 TP " .. i .. "  (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")"
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 11
		btn.Parent = ScrollFrame
		makeCapsule(btn)
		btn.MouseButton1Click:Connect(function()
			autoTeleportEnabled = false
			AutoBtn.Text = "🔄 Auto TP: OFF"
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
			end
		end)
	end
	ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, teleportCounter * 32 + 4)
end
refreshList()

-- === BUTTON EVENTS ===
AddBtn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		teleportCounter += 1
		TeleportData[teleportCounter] = player.Character.HumanoidRootPart.Position
		refreshList()
		showStatus("✅ TP " .. teleportCounter .. " ditambahkan!")
	end
end)

RemoveBtn.MouseButton1Click:Connect(function()
	if teleportCounter > 0 then
		TeleportData[teleportCounter] = nil
		teleportCounter -= 1
		refreshList()
		autoTeleportIndex = math.min(autoTeleportIndex, math.max(1, teleportCounter))
		showStatus("🗑️ TP terakhir dihapus", Color3.fromRGB(255, 100, 100))
	else
		showStatus("⚠️ Tidak ada TP untuk dihapus", Color3.fromRGB(255, 200, 0))
	end
end)

AutoBtn.MouseButton1Click:Connect(function()
	autoTeleportEnabled = not autoTeleportEnabled
	AutoBtn.Text = autoTeleportEnabled and "🔄 Auto TP: ON" or "🔄 Auto TP: OFF"
	AutoBtn.BackgroundColor3 = autoTeleportEnabled and Color3.fromRGB(0, 180, 60) or Color3.fromRGB(60, 60, 200)
end)

SpeedUpBtn.MouseButton1Click:Connect(function()
	autoTeleportSpeed = math.max(0.1, autoTeleportSpeed - 0.1)
	SpeedLabel.Text = "⚙️ Kecepatan: " .. string.format("%.1f", autoTeleportSpeed) .. "s"
end)

SpeedDownBtn.MouseButton1Click:Connect(function()
	autoTeleportSpeed = autoTeleportSpeed + 0.1
	SpeedLabel.Text = "⚙️ Kecepatan: " .. string.format("%.1f", autoTeleportSpeed) .. "s"
end)

-- === SAVE FILE EVENT ===
SaveFileBtn.MouseButton1Click:Connect(function()
	local name = FileTextBox.Text:match("^%s*(.-)%s*$") -- trim whitespace
	if name == "" then
		showStatus("⚠️ Isi nama file terlebih dahulu!", Color3.fromRGB(255, 220, 0))
		-- Flash textbox border merah
		tbStroke.Color = Color3.fromRGB(255, 60, 60)
		task.delay(1.5, function()
			tbStroke.Color = Color3.fromRGB(0, 200, 255)
		end)
		return
	end
	-- Tambahkan .json jika belum ada
	if not name:match("%.json$") then
		name = name .. ".json"
	end
	local ok, msg = saveDataToFile(name)
	showStatus(ok and ("💾 " .. msg) or ("❌ " .. msg), ok and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80))
end)

-- === LOAD FILE EVENT ===
LoadFileBtn.MouseButton1Click:Connect(function()
	local name = FileTextBox.Text:match("^%s*(.-)%s*$") -- trim whitespace
	if name == "" then
		showStatus("⚠️ Isi nama file terlebih dahulu!", Color3.fromRGB(255, 220, 0))
		tbStroke.Color = Color3.fromRGB(255, 60, 60)
		task.delay(1.5, function()
			tbStroke.Color = Color3.fromRGB(0, 200, 255)
		end)
		return
	end
	if not name:match("%.json$") then
		name = name .. ".json"
	end
	local ok, msg = loadDataFromFile(name)
	if ok then
		refreshList()
		showStatus("📂 " .. msg, Color3.fromRGB(0, 255, 200))
	else
		showStatus("❌ Load gagal: " .. msg, Color3.fromRGB(255, 80, 80))
	end
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
		TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 280, 0, 60)}):Play()
		FileSection.Visible = false
		StatusLabel.Visible = false
		ScrollFrame.Visible = false
		BtnFrame.Visible = false
	else
		TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 280, 0, 460)}):Play()
		task.wait(0.3)
		FileSection.Visible = true
		StatusLabel.Visible = true
		ScrollFrame.Visible = true
		BtnFrame.Visible = true
	end
end)

-- === CLOSE ===
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
