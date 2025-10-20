local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- === CONFIG ===
local recording, replaying = false, false
local movementData = {}
local heartbeatConn
local key = "Z"  -- Ubah key di sini sesuai keinginan Anda

-- === GUI VERIFIKASI KEY ===
local guiVerify = Instance.new("ScreenGui")
guiVerify.Name = "ZassXdKeyVerify"
guiVerify.ResetOnSpawn = false
guiVerify.Parent = player:WaitForChild("PlayerGui")

local verifyFrame = Instance.new("Frame")
verifyFrame.Size = UDim2.new(0, 300, 0, 150)
verifyFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
verifyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
verifyFrame.BorderSizePixel = 0
verifyFrame.Active, verifyFrame.Draggable = true, true
verifyFrame.Parent = guiVerify
Instance.new("UICorner", verifyFrame).CornerRadius = UDim.new(0, 10)

local verifyGradient = Instance.new("UIGradient", verifyFrame)
verifyGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 255))
}
verifyGradient.Rotation = 45

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.Parent = verifyFrame

local verifyTitle = Instance.new("TextLabel", verifyFrame)
verifyTitle.Text = "🔐 Enter Key"
verifyTitle.Size = UDim2.new(1, 0, 0, 30)
verifyTitle.BackgroundTransparency = 1
verifyTitle.TextColor3 = Color3.new(1, 1, 1)
verifyTitle.Font = Enum.Font.GothamBold
verifyTitle.TextSize = 16

local keyTextBox = Instance.new("TextBox")
keyTextBox.Size = UDim2.new(0.9, 0, 0, 30)
keyTextBox.Position = UDim2.new(0.05, 0, 0.3, 0)
keyTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
keyTextBox.TextColor3 = Color3.new(1, 1, 1)
keyTextBox.Font = Enum.Font.Gotham
keyTextBox.TextSize = 14
keyTextBox.PlaceholderText = "Enter key here..."
keyTextBox.BorderSizePixel = 0
keyTextBox.ClearTextOnFocus = false
Instance.new("UICorner", keyTextBox).CornerRadius = UDim.new(0, 6)
keyTextBox.Parent = verifyFrame

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.9, 0, 0, 30)
submitBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
submitBtn.TextColor3 = Color3.new(1, 1, 1)
submitBtn.Font = Enum.Font.GothamBold
submitBtn.TextSize = 14
submitBtn.Text = "Submit"
submitBtn.BorderSizePixel = 0
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)
submitBtn.Parent = verifyFrame

local errorLabel = Instance.new("TextLabel", verifyFrame)
errorLabel.Size = UDim2.new(1, 0, 0, 20)
errorLabel.Position = UDim2.new(0, 0, 1, -20)
errorLabel.BackgroundTransparency = 1
errorLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
errorLabel.Font = Enum.Font.Gotham
errorLabel.TextSize = 12
errorLabel.Text = ""
errorLabel.Visible = false

closeBtn.MouseButton1Click:Connect(function()
	guiVerify:Destroy()
end)

submitBtn.MouseEnter:Connect(function()
	TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
end)
submitBtn.MouseLeave:Connect(function()
	TweenService:Create(submitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 255)}):Play()
end)

submitBtn.MouseButton1Click:Connect(function()
	if keyTextBox.Text == key then
		guiVerify:Destroy()
		-- Sekarang buat dan tampilkan GUI utama
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
		local saveBtn   = makeBtn("Save JSON", 175, "💾") -- tombol baru

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

		-- === RECORD & REPLAY ===
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
			if recording then return end
			recording = true
			movementData = {}
			recordBtn.Text = "⏸️ Rec..."
			task.spawn(recordMovement)
		end)

		stopBtn.MouseButton1Click:Connect(function()
			if not recording then return end
			recording = false
			recordBtn.Text = "⏺️ Record"
		end)

		clearBtn.MouseButton1Click:Connect(function()
			movementData = {}
		end)

		-- === SAVE JSON OTOMATIS ===
		saveBtn.MouseButton1Click:Connect(function()
			if #movementData == 0 then return end

			-- Buat data JSON
			local export = {}
			for _, d in ipairs(movementData) do
				table.insert(export, {
					t = d.t,
					cf = {d.cf:GetComponents()},
					state = tostring(d.state),
					dir = {x = d.dir.X, y = d.dir.Y, z = d.dir.Z},
					speed = d.speed
				})
			end

			local jsonData = HttpService:JSONEncode(export)

			-- Simpan ke file lokal
			local fileName = "ZassXd_Recording.json"
			local success, err = pcall(function()
				writefile(fileName, jsonData)
			end)

			if success then
				print("[✅] Movement saved to:", fileName)
			else
				warn("[❌] Failed to save file:", err)
			end
		end)

		-- === AUTO REPLAY LOOP ===
		replayBtn.MouseButton1Click:Connect(function()
			if #movementData < 2 then return end
			if replaying then
				replaying = false
				replayBtn.Text = "🎞️ Replay"
				return
			end
			replaying = true
			replayBtn.Text = "⏹️ Stop"

			local function playReplay(callback)
				local char, hum = getChar()
				local hrp = char:WaitForChild("HumanoidRootPart")
				local controls
				pcall(function()
					local pm = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
					if pm and pm.GetControls then
						controls = pm:GetControls()
					end
				end)
				if controls then controls:Disable() end
				hum.PlatformStand = true
				local start = os.clock()
				local total = movementData[#movementData].t
				if heartbeatConn then heartbeatConn:Disconnect() end
				heartbeatConn = RunService.Heartbeat:Connect(function()
					if not replaying then
						if heartbeatConn then heartbeatConn:Disconnect() end
						if controls then controls:Enable() end
						hum.PlatformStand = false
						return
					end
					local elapsed = os.clock() - start
					if elapsed >= total then
						if heartbeatConn then heartbeatConn:Disconnect() end
						hum.PlatformStand = false
						if controls then controls:Enable() end
						if callback then callback() end
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
			end

			task.spawn(function()
				while replaying do
					playReplay(function()
						if replaying then
							task.wait(0.3)
						end
					end)
					repeat task.wait() until not heartbeatConn or not heartbeatConn.Connected
				end
			end)
		end)
	else
		errorLabel.Text = "Invalid key! Try again."
		errorLabel.Visible = true
		task.wait(2)
		errorLabel.Visible = false
	end
end)