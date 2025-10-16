-- 💠 ZassXd Smooth Recorder v3 (Professional UI + Key System + Minimize)
-- Semua fitur lama tetap berfungsi | Dibuat dengan gaya profesional dan modern

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- === CONFIG ===
local CORRECT_KEY = "ZASSTOD"
local authenticated = false

local recording, replaying = false, false
local movementData = {}
local heartbeatConn

-- === UI UTAMA ===
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ZassXdRecorderUI"
gui.ResetOnSpawn = false

-- FRAME UTAMA
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 320)
frame.Position = UDim2.new(0, 20, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active, frame.Draggable = true, true

-- ROUNDED CORNER
local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 12)

-- GRADIENT BACKGROUND
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255))
}
gradient.Rotation = 45

-- SHADOW EFFECT
local shadow = Instance.new("ImageLabel", frame)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.ZIndex = -1
shadow.BackgroundTransparency = 1

-- MINIMIZE BUTTON
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Text = "—"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Text = "💠 ZassXd Recorder"
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextYAlignment = Enum.TextYAlignment.Center

-- FUNGSI PEMBUAT TOMBOL
local function makeBtn(text, posY, emoji)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0.9, 0, 0, 38)
	b.Position = UDim2.new(0.05, 0, 0, posY)
	b.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.Text = emoji .. "  " .. text
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		}):Play()
	end)

	return b
end

local recordBtn = makeBtn("Start Record", 50, "⏺️")
local stopBtn   = makeBtn("Stop & Save", 95, "💾")
local replayBtn = makeBtn("Smooth Replay", 140, "🎞️")
local clearBtn  = makeBtn("Clear Data", 185, "🧹")
local copyBtn   = makeBtn("Copy Record", 230, "📋")

-- === OPEN BUTTON (KETIKA MINIMIZE) ===
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 25, 1, -70)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
openBtn.Text = "📂"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 24
openBtn.TextColor3 = Color3.new(1, 1, 1)
openBtn.Visible = false
openBtn.BorderSizePixel = 0
openBtn.Active, openBtn.Draggable = true, true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

minimizeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	openBtn.Visible = false
end)

-- === KEY FRAME ===
local keyFrame = Instance.new("Frame", gui)
keyFrame.Size = UDim2.new(0, 280, 0, 180)
keyFrame.Position = UDim2.new(0.5, -140, 0.5, -90)
keyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
keyFrame.BorderSizePixel = 0
keyFrame.Active, keyFrame.Draggable = true, true
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)

local keyGrad = Instance.new("UIGradient", keyFrame)
keyGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
}
keyGrad.Rotation = 45

local keyTitle = Instance.new("TextLabel", keyFrame)
keyTitle.Text = "🔐 Enter Access Key"
keyTitle.Size = UDim2.new(1, 0, 0, 30)
keyTitle.BackgroundTransparency = 1
keyTitle.TextColor3 = Color3.new(1, 1, 1)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 18

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.PlaceholderText = "Masukkan key di sini..."
keyBox.Size = UDim2.new(0.9, 0, 0, 35)
keyBox.Position = UDim2.new(0.05, 0, 0, 50)
keyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.ClearTextOnFocus = false
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.BorderSizePixel = 0
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local confirmBtn = Instance.new("TextButton", keyFrame)
confirmBtn.Size = UDim2.new(0.9, 0, 0, 35)
confirmBtn.Position = UDim2.new(0.05, 0, 0, 100)
confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
confirmBtn.Text = "Verify Key"
confirmBtn.TextColor3 = Color3.new(1, 1, 1)
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.TextSize = 15
confirmBtn.BorderSizePixel = 0
Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)

local statusLabel = Instance.new("TextLabel", keyFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 25)
statusLabel.Position = UDim2.new(0, 0, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13

confirmBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == CORRECT_KEY then
		authenticated = true
		TweenService:Create(keyFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		task.wait(0.4)
		keyFrame:Destroy()
		frame.Visible = true
		print("✅ Key benar, akses diberikan!")
	else
		statusLabel.Text = "❌ Key salah!"
		statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

-- === UTIL ===
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	return char, hum
end

-- === RECORD ===
local function recordMovement()
	local char, hum = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local start = os.clock()
	while recording do
		table.insert(movementData, {
			t = os.clock() - start,
			cf = hrp.CFrame,
			state = hum:GetState(),
			dir = hum.MoveDirection,
			speed = hum.WalkSpeed
		})
		task.wait(0.05)
	end
end

recordBtn.MouseButton1Click:Connect(function()
	if not authenticated or recording then return end
	recording = true
	movementData = {}
	recordBtn.Text = "⏸️ Recording..."
	task.spawn(recordMovement)
end)

stopBtn.MouseButton1Click:Connect(function()
	if not authenticated or not recording then return end
	recording = false
	recordBtn.Text = "⏺️ Start Record"
	print("🎬 Rekaman selesai:", #movementData, "frame")
end)

clearBtn.MouseButton1Click:Connect(function()
	if not authenticated then return end
	movementData = {}
	print("🧹 Data rekaman dihapus")
end)

-- === COPY RECORD ===
copyBtn.MouseButton1Click:Connect(function()
	if not authenticated or #movementData == 0 then
		print("⚠️ Tidak ada data untuk disalin!")
		return
	end
	local exportData = {}
	for _, d in ipairs(movementData) do
		table.insert(exportData, {
			t = d.t,
			cf = {d.cf:GetComponents()},
			state = d.state.Value,
			dir = {x = d.dir.X, y = d.dir.Y, z = d.dir.Z},
			speed = d.speed
		})
	end
	setclipboard(HttpService:JSONEncode(exportData))
	print("✅ Data rekaman disalin ke clipboard!")
end)

-- === REPLAY ===
replayBtn.MouseButton1Click:Connect(function()
	if not authenticated or #movementData < 2 or replaying then return end
	replaying = true
	local char, hum = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	controls:Disable()
	hum.PlatformStand = true

	print("▶️ Smooth replay dimulai...")
	local start = os.clock()
	local total = movementData[#movementData].t

	if heartbeatConn then heartbeatConn:Disconnect() end
	heartbeatConn = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - start
		if elapsed >= total then
			heartbeatConn:Disconnect()
			hum.PlatformStand = false
			controls:Enable()
			replaying = false
			print("✅ Replay selesai")
			return
		end
		local i = 1
		while i < #movementData and movementData[i+1].t < elapsed do
			i += 1
		end
		local a, b = movementData[i], movementData[i+1]
		if not a or not b then return end
		local alpha = (elapsed - a.t) / math.max((b.t - a.t), 0.0001)
		local cf = a.cf:Lerp(b.cf, alpha)
		hum:ChangeState(a.state)
		hum.WalkSpeed = a.speed
		hum:Move(a.dir, true)
		hrp.CFrame = cf
	end)
end)

-- === AUTO RESPAWN ===
player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").Died:Connect(function()
		task.wait(2)
		player:LoadCharacter()
	end)
end)
