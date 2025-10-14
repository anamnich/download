-- 💠 ZassXd Teleport Hub (Full version: Smooth minimize + reopen button + distance)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- GUI utama
local gui = Instance.new("ScreenGui")
gui.Name = "ZassXdTeleportHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

-- Frame utama
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 260)
frame.Position = UDim2.new(0.7, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "💠Tp Player"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Tombol minimize dan close
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0, 3)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 3)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = frame

-- Scroll area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -45)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.ScrollingEnabled = true
scroll.Active = true
scroll.ClipsDescendants = true
scroll.BackgroundTransparency = 1
scroll.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

-- Fungsi tombol player
local function createPlayerButton(plr)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 45)
	btn.BackgroundColor3 = Color3.fromRGB(0, 25, 40)
	btn.Text = ""
	btn.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 22)
	nameLabel.Position = UDim2.new(0, 5, 0, 2)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.Name
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = btn

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Size = UDim2.new(1, -10, 0, 18)
	distanceLabel.Position = UDim2.new(0, 5, 0, 24)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.TextSize = 14
	distanceLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Left
	distanceLabel.Text = "(-- studs)"
	distanceLabel.Parent = btn

	btn.MouseButton1Click:Connect(function()
		local char = LocalPlayer.Character
		local target = plr.Character
		if char and target and target:FindFirstChild("HumanoidRootPart") then
			char:MoveTo(target.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
		end
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 60, 90)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 25, 40)}):Play()
	end)

	-- Update jarak
	RunService.RenderStepped:Connect(function()
		local char = LocalPlayer.Character
		local target = plr.Character
		if char and target and target:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
			local dist = (char.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
			distanceLabel.Text = string.format("(%.0f studs)", dist)
		else
			distanceLabel.Text = "(offline)"
		end
	end)

	btn.Parent = scroll
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

-- Refresh daftar player
local function refreshList()
	for _, c in ipairs(scroll:GetChildren()) do
		if c:IsA("TextButton") then
			c:Destroy()
		end
	end
	task.wait(0.1)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			createPlayerButton(plr)
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
task.wait(0.3)
refreshList()

-- Tombol reopen kecil
local reopenBtn = Instance.new("TextButton")
reopenBtn.Size = UDim2.new(0, 40, 0, 40)
reopenBtn.Position = UDim2.new(1, -50, 0.13, 0)
reopenBtn.BackgroundColor3 = Color3.fromRGB(0, 40, 60)
reopenBtn.Text = "💠"
reopenBtn.Font = Enum.Font.GothamBold
reopenBtn.TextSize = 20
reopenBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
reopenBtn.Visible = false
reopenBtn.Active = true
reopenBtn.Draggable = true
reopenBtn.Parent = gui

local rc = Instance.new("UICorner")
rc.CornerRadius = UDim.new(1, 0)
rc.Parent = reopenBtn

-- Animasi minimize / reopen
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	if minimized then return end
	minimized = true
	TweenService:Create(frame, TweenInfo.new(0.4), {Position = UDim2.new(0.7, 0, 1.3, 0), BackgroundTransparency = 1}):Play()
	task.wait(0.4)
	frame.Visible = false
	reopenBtn.Visible = true
end)

reopenBtn.MouseButton1Click:Connect(function()
	reopenBtn.Visible = false
	frame.Visible = true
	frame.BackgroundTransparency = 1
	TweenService:Create(frame, TweenInfo.new(0.4), {Position = UDim2.new(0.7, 0, 0.15, 0), BackgroundTransparency = 0.15}):Play()
	task.wait(0.4)
	minimized = false
end)

-- Close GUI
closeBtn.MouseButton1Click:Connect(function()
	TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(1, 300, 0.15, 0)}):Play()
	task.wait(0.3)
	gui:Destroy()
end)
