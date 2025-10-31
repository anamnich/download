--// DRONE CAMERA v5
--// Cinematic zoom, free rotation after zoom, follow position, infinite teleport
--// by GPT-5

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- === GUI MINI ===
local gui = Instance.new("ScreenGui")
gui.Name = "DroneCamMini"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 230)
frame.Position = UDim2.new(0.85, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 22)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "ZassXd"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.Parent = frame

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, -10, 1, -90)
playerList.Position = UDim2.new(0, 5, 0, 28)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.Parent = playerList
uiList.Padding = UDim.new(0, 2)

local followButton = Instance.new("TextButton")
followButton.Size = UDim2.new(1, -10, 0, 26)
followButton.Position = UDim2.new(0, 5, 1, -55)
followButton.Text = "🎥 Enable"
followButton.TextColor3 = Color3.new(1, 1, 1)
followButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
followButton.Font = Enum.Font.GothamBold
followButton.TextSize = 12
followButton.Parent = frame

local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(1, -10, 0, 26)
teleportButton.Position = UDim2.new(0, 5, 1, -26)
teleportButton.Text = "Teleport"
teleportButton.TextColor3 = Color3.new(1, 1, 1)
teleportButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
teleportButton.Font = Enum.Font.GothamBold
teleportButton.TextSize = 12
teleportButton.Parent = frame

-- === STATE ===
local currentTarget = nil
local cameraFollow = false
local sensitivity = 0.25
local pitch, yaw = 15, 0
local smoothSpeed = 0.1
local freeRotate = false

-- === PLAYER LIST ===
local function updatePlayerList()
	for _, c in pairs(playerList:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= lp then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -4, 0, 20)
			btn.Text = p.Name
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 11
			btn.Parent = playerList

			btn.MouseButton1Click:Connect(function()
				currentTarget = p
				for _, o in pairs(playerList:GetChildren()) do
					if o:IsA("TextButton") then
						o.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					end
				end
				btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
			end)
		end
	end
	playerList.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- === MOUSE CAMERA CONTROL ===
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and cameraFollow then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		freeRotate = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		freeRotate = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if freeRotate and input.UserInputType == Enum.UserInputType.MouseMovement then
		yaw -= input.Delta.X * sensitivity
		pitch = math.clamp(pitch - input.Delta.Y * sensitivity, -80, 80)
	end
end)

-- === CAMERA FOLLOW LOOP ===
RunService.RenderStepped:Connect(function()
	if cameraFollow and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = currentTarget.Character.HumanoidRootPart
		local rotation = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
		local offset = rotation:VectorToWorldSpace(Vector3.new(0, 4, 10))
		local targetCFrame = CFrame.new(hrp.Position + offset, hrp.Position)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothSpeed)
	end
end)

-- === ENABLE / DISABLE CAMERA ===
followButton.MouseButton1Click:Connect(function()
	if not currentTarget then
		followButton.Text = "❌ Pilih dulu"
		task.wait(1)
		followButton.Text = "View"
		return
	end

	if cameraFollow then
		cameraFollow = false
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = lp.Character:FindFirstChildOfClass("Humanoid")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		followButton.Text = "View"
		followButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	else
		local target = currentTarget
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = target.Character.HumanoidRootPart
			camera.CameraType = Enum.CameraType.Scriptable

			-- Cinematic zoom in
			local startCFrame = CFrame.new(hrp.Position + Vector3.new(0, 80, 100), hrp.Position)
			local endCFrame = hrp.CFrame * CFrame.new(0, 6, 12)
			camera.CFrame = startCFrame

			local tween = TweenService:Create(camera, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = endCFrame})
			tween:Play()
			tween.Completed:Wait()

			pitch, yaw = 15, 0
			cameraFollow = true
			followButton.Text = "Stop View"
			followButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		end
	end
end)

-- === TELEPORT TANPA BATAS ===
teleportButton.MouseButton1Click:Connect(function()
	if not currentTarget then
		teleportButton.Text = "❌ Pilih dulu"
		task.wait(1)
		teleportButton.Text = "Teleport"
		return
	end

	local target = currentTarget
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local targetHRP = target.Character.HumanoidRootPart
		local myChar = lp.Character or lp.CharacterAdded:Wait()
		local myHRP = myChar:WaitForChild("HumanoidRootPart")

		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 10)
		task.wait(0.2)
		workspace.FallenPartsDestroyHeight = -math.huge
		myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)

		teleportButton.Text = "✅ Teleported"
		task.wait(1)
		teleportButton.Text = "⚡ Teleport"
	end
end)
