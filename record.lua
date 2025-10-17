-- 💠 ZassXd Smooth Recorder v3 Mini (Professional UI + Key System + Minimize + Compact)
-- Semua fitur tetap berfungsi | Tampilan modern & rapi

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
local gui = Instance.new("ScreenGui")
gui.Name = "ZassXdRecorderUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- FRAME UTAMA (Mini)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 220)
frame.Position = UDim2.new(0, 20, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active, frame.Draggable = true, true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255))
}
gradient.Rotation = 45

-- MINIMIZE
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "—"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Size = UDim2.new(0, 20, 0, 20)
minimizeBtn.Position = UDim2.new(1, -25, 0, 4)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)
minimizeBtn.Parent = frame

local title = Instance.new("TextLabel", frame)
title.Text = "💠 Recorder"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- FUNGSI BUAT BUTTON KECIL
local function makeBtn(text, posY, emoji)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.9, 0, 0, 26)
	b.Position = UDim2.new(0.05, 0, 0, posY)
	b.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Text = emoji .. " " .. text
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	b.Parent = frame
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}):Play()
	end)
	return b
end

local recordBtn = makeBtn("Record", 35, "⏺️")
local stopBtn   = makeBtn("Stop", 70, "💾")
local replayBtn = makeBtn("Replay", 105, "🎞️")
local clearBtn  = makeBtn("Clear", 140, "🧹")
local copyBtn   = makeBtn("Copy", 175, "📋")

-- BUTTON OPEN (Mini)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 25, 1, -70)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
openBtn.Text = "📂"
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
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

-- === PROFESSIONAL KEY FRAME ===
local keyFrame = Instance.new("Frame", gui)
keyFrame.Size = UDim2.new(0, 260, 0, 160)
keyFrame.Position = UDim2.new(0.5, -130, 0.5, -80)
keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
keyFrame.BackgroundTransparency = 0.2
keyFrame.BorderSizePixel = 0
keyFrame.Active, keyFrame.Draggable = true, true
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 14)

local blur = Instance.new("UIStroke", keyFrame)
blur.Thickness = 1.2
blur.Color = Color3.fromRGB(0, 180, 255)
blur.Transparency = 0.4

local shadow = Instance.new("ImageLabel", keyFrame)
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = 0
shadow.Image = "rbxassetid://5028857084"
shadow.ImageTransparency = 0.45
shadow.ImageColor3 = Color3.fromRGB(0, 160, 255)

local keyHeader = Instance.new("Frame", keyFrame)
keyHeader.Size = UDim2.new(1, 0, 0, 35)
keyHeader.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
keyHeader.BackgroundTransparency = 0.2
keyHeader.BorderSizePixel = 0
Instance.new("UICorner", keyHeader).CornerRadius = UDim.new(0, 14)
local headStroke = Instance.new("UIStroke", keyHeader)
headStroke.Thickness = 1
headStroke.Color = Color3.fromRGB(0, 200, 255)
headStroke.Transparency = 0.4

local keyTitle = Instance.new("TextLabel", keyHeader)
keyTitle.Text = "🔐  ZassXd Key Access"
keyTitle.Size = UDim2.new(1, 0, 1, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.TextColor3 = Color3.new(1, 1, 1)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 15

local closeKeyBtn = Instance.new("TextButton", keyHeader)
closeKeyBtn.Text = "✖"
closeKeyBtn.Font = Enum.Font.GothamBold
closeKeyBtn.TextSize = 14
closeKeyBtn.Size = UDim2.new(0, 25, 0, 25)
closeKeyBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
closeKeyBtn.TextColor3 = Color3.new(1, 1, 1)
closeKeyBtn.BorderSizePixel = 0
Instance.new("UICorner", closeKeyBtn).CornerRadius = UDim.new(1, 0)
closeKeyBtn.MouseEnter:Connect(function()
	TweenService:Create(closeKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
end)
closeKeyBtn.MouseLeave:Connect(function()
	TweenService:Create(closeKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
end)
closeKeyBtn.MouseButton1Click:Connect(function()
	TweenService:Create(keyFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	task.wait(0.3)
	keyFrame.Visible = false
end)

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.PlaceholderText = "Enter your access key..."
keyBox.Size = UDim2.new(0.9, 0, 0, 30)
keyBox.Position = UDim2.new(0.05, 0, 0, 55)
keyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.ClearTextOnFocus = false
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 13
keyBox.BorderSizePixel = 0
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", keyBox)
stroke.Color = Color3.fromRGB(0, 180, 255)
stroke.Thickness = 1

local confirmBtn = Instance.new("TextButton", keyFrame)
confirmBtn.Size = UDim2.new(0.9, 0, 0, 30)
confirmBtn.Position = UDim2.new(0.05, 0, 0, 95)
confirmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
confirmBtn.Text = "✅ Verify Key"
confirmBtn.TextColor3 = Color3.new(1, 1, 1)
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.TextSize = 13
confirmBtn.BorderSizePixel = 0
Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)
confirmBtn.MouseEnter:Connect(function()
	TweenService:Create(confirmBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 255)}):Play()
end)
confirmBtn.MouseLeave:Connect(function()
	TweenService:Create(confirmBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
end)

local statusLabel = Instance.new("TextLabel", keyFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 1, -25)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Text = "Enter the key to unlock features"

confirmBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == CORRECT_KEY then
		authenticated = true
		statusLabel.Text = "✅ Key verified successfully!"
		statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		TweenService:Create(keyFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
		task.wait(0.3)
		keyFrame:Destroy()
		frame.Visible = true
	else
		statusLabel.Text = "❌ Invalid key. Try again."
		statusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		TweenService:Create(keyBox, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 3, true), {Position = keyBox.Position + UDim2.new(0, 5, 0, 0)}):Play()
	end
end)

-- === RECORDING LOGIC ===
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	return char, hum
end

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
	recordBtn.Text = "⏸️ Rec..."
	task.spawn(recordMovement)
end)

stopBtn.MouseButton1Click:Connect(function()
	if not authenticated or not recording then return end
	recording = false
	recordBtn.Text = "⏺️ Record"
end)

clearBtn.MouseButton1Click:Connect(function()
	if authenticated then movementData = {} end
end)

copyBtn.MouseButton1Click:Connect(function()
	if not authenticated or #movementData == 0 then return end
	local export = {}
	for _, d in ipairs(movementData) do
		table.insert(export, {
			t = d.t,
			cf = {d.cf:GetComponents()},
			state = d.state.Value,
			dir = {x = d.dir.X, y = d.dir.Y, z = d.dir.Z},
			speed = d.speed
		})
	end
	setclipboard(HttpService:JSONEncode(export))
end)

replayBtn.MouseButton1Click:Connect(function()
	if not authenticated or #movementData < 2 or replaying then return end
	replaying = true
	local char, hum = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	controls:Disable()
	hum.PlatformStand = true
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

player.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid").Died:Connect(function()
		task.wait(2)
		player:LoadCharacter()
	end)
end)
