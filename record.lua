local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local recording, replaying = false, false
local movementData = {}
local heartbeatConn

-- === GUI ===
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ZassXdRecorderUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 270)
frame.Position = UDim2.new(0, 20, 0.65, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 0
frame.Active, frame.Draggable = true, true

local title = Instance.new("TextLabel", frame)
title.Text = "Smooth Recorder"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local function makeBtn(text, posY)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0.9, 0, 0, 35)
	b.Position = UDim2.new(0.05, 0, 0, posY)
	b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.Text = text
	b.AutoButtonColor = true
	b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(0, 200, 255) end)
	b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(0, 170, 255) end)
	return b
end

local recordBtn = makeBtn("Start Record", 40)
local stopBtn   = makeBtn("Stop & Save", 80)
local replayBtn = makeBtn("Smooth Replay", 120)
local clearBtn  = makeBtn("Clear Data", 160)
local copyBtn   = makeBtn("Copy Record", 200)

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
	if recording then return end
	recording = true
	movementData = {}
	recordBtn.Text = "⏸️ Recording..."
	task.spawn(recordMovement)
end)

stopBtn.MouseButton1Click:Connect(function()
	if not recording then return end
	recording = false
	recordBtn.Text = "▶️ Start Record"
	print("🎬 Rekaman selesai:", #movementData, "frame")
end)

clearBtn.MouseButton1Click:Connect(function()
	movementData = {}
	print("🧹 Data rekaman dihapus")
end)

-- === COPY RECORD ===
copyBtn.MouseButton1Click:Connect(function()
	if #movementData == 0 then
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

	local json = HttpService:JSONEncode(exportData)
	setclipboard(json)
	print("✅ Data rekaman berhasil disalin ke clipboard!")
end)

-- === REPLAY ===
replayBtn.MouseButton1Click:Connect(function()
	if #movementData < 2 or replaying then return end
	replaying = true

	local char, hum = getChar()
	local hrp = char:WaitForChild("HumanoidRootPart")

	local controls = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls()
	controls:Disable()

	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	cam.CameraSubject = hum

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
		local a = movementData[i]
		local b = movementData[i+1]
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
	local hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		task.wait(2)
		player:LoadCharacter()
	end)
end)
