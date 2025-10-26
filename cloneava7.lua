-- 🌟 CHANGE YOUR AVATAR v2.5 (Mini UI + Draggable + Tall Frame + HP Friendly)
-- 💠 By ZassXd | Windows 11 Style Compact Edition

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

local UIState = { isOpen = false, isAnimating = false }
local savedToolsGlobal = {}
local lastLoadedUsername = nil

-- ======================================================
-- 🧩 Fungsi Load Avatar
-- ======================================================
local function loadAvatar(username)
	if not username or username == "" then
		return false, "Username kosong!"
	end

	local char = lp.Character or lp.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false, "Character tidak ditemukan!" end

	-- Simpan tools
	local savedTools, equippedToolNames = {}, {}
	for _, t in ipairs(lp.Backpack:GetChildren()) do
		if t:IsA("Tool") then table.insert(savedTools, t) end
	end
	for _, t in ipairs(char:GetChildren()) do
		if t:IsA("Tool") then
			table.insert(savedTools, t)
			table.insert(equippedToolNames, t.Name)
		end
	end

	-- Ambil avatar dari username
	local ok, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(username)
	end)
	if not ok or not userId then
		return false, "Username tidak ditemukan!"
	end

	local ok2, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not ok2 or not desc then
		return false, "Gagal ambil avatar description!"
	end

	-- Hapus aksesori & pakaian lama
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
			pcall(function() v:Destroy() end)
		end
	end

	task.wait(0.1)
	pcall(function() humanoid:ApplyDescriptionClientServer(desc) end)

	-- Restore tools
	task.wait(0.8)
	for _, t in ipairs(savedTools) do
		if t and t.Parent and t.Parent ~= lp.Backpack then
			pcall(function() t.Parent = lp.Backpack end)
		end
	end
	task.wait(0.25)
	for _, n in ipairs(equippedToolNames) do
		local f = lp.Backpack:FindFirstChild(n)
		if f then pcall(function() humanoid:EquipTool(f) end) end
	end

	lastLoadedUsername = username
	return true, "Avatar diubah ke: " .. username
end

-- ======================================================
-- 🧱 CREATE UI
-- ======================================================
local function createUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "AvatarChangerMini"
	gui.ResetOnSpawn = false
	gui.Parent = lp:WaitForChild("PlayerGui")

	-- Tombol toggle
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0,35,0,35)
	toggle.Position = UDim2.new(0,10,0,10)
	toggle.BackgroundColor3 = Color3.fromRGB(0,120,215)
	toggle.Text = "🎮"
	toggle.TextColor3 = Color3.new(1,1,1)
	toggle.TextScaled = true
	toggle.Font = Enum.Font.GothamBold
	Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,18)
	toggle.Parent = gui

	-- Frame utama
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,280,0,440)
	frame.Position = UDim2.new(1,-300,0.05,0)
	frame.BackgroundColor3 = Color3.fromRGB(32,32,32)
	frame.BackgroundTransparency = 0.05
	frame.Visible = false
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(100,100,100)
	stroke.Transparency = 0.5
	frame.Parent = gui

	-- Title bar
	local titleBar = Instance.new("Frame", frame)
	titleBar.Size = UDim2.new(1,0,0,30)
	titleBar.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)

	local title = Instance.new("TextLabel", titleBar)
	title.Size = UDim2.new(1,-35,1,0)
	title.Position = UDim2.new(0,8,0,0)
	title.BackgroundTransparency = 1
	title.Text = "Change Avatar"
	title.TextColor3 = Color3.new(1,1,1)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left

	local close = Instance.new("TextButton", titleBar)
	close.Size = UDim2.new(0,25,0,25)
	close.Position = UDim2.new(1,-28,0,2)
	close.Text = "✕"
	close.Font = Enum.Font.GothamBold
	close.TextScaled = true
	close.BackgroundColor3 = Color3.fromRGB(196,43,28)
	close.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

	-- Input
	local input = Instance.new("TextBox", frame)
	input.Size = UDim2.new(0.65,-5,0,30)
	input.Position = UDim2.new(0,15,0,45)
	input.PlaceholderText = "Username..."
	input.BackgroundColor3 = Color3.fromRGB(50,50,50)
	input.TextColor3 = Color3.new(1,1,1)
	input.TextScaled = true
	input.Font = Enum.Font.Gotham
	Instance.new("UICorner", input).CornerRadius = UDim.new(0,6)

	local submit = Instance.new("TextButton", frame)
	submit.Size = UDim2.new(0.3,-5,0,30)
	submit.Position = UDim2.new(0.67,0,0,45)
	submit.Text = "SET"
	submit.BackgroundColor3 = Color3.fromRGB(0,120,215)
	submit.TextColor3 = Color3.new(1,1,1)
	submit.TextScaled = true
	submit.Font = Enum.Font.GothamBold
	Instance.new("UICorner", submit).CornerRadius = UDim.new(0,6)

	local status = Instance.new("TextLabel", frame)
	status.Size = UDim2.new(1,-30,0,25)
	status.Position = UDim2.new(0,15,0,85)
	status.Text = "✨ Ready to change avatar"
	status.TextColor3 = Color3.fromRGB(200,200,200)
	status.BackgroundTransparency = 1
	status.TextScaled = true
	status.Font = Enum.Font.GothamBold

	local playerList = Instance.new("ScrollingFrame", frame)
	playerList.Size = UDim2.new(1,-30,0,300)
	playerList.Position = UDim2.new(0,15,0,115)
	playerList.BackgroundColor3 = Color3.fromRGB(40,40,40)
	playerList.BackgroundTransparency = 0.2
	playerList.ScrollBarThickness = 6
	playerList.BorderSizePixel = 0
	Instance.new("UICorner", playerList).CornerRadius = UDim.new(0,8)
	local layout = Instance.new("UIListLayout", playerList)
	layout.Padding = UDim.new(0,4)

	return gui, frame, toggle, close, input, submit, status, playerList
end

-- ======================================================
-- 🧍‍♂️ PLAYER LIST BUILDER
-- ======================================================
local function refreshPlayerList(playerFrame, statusLabel)
	playerFrame:ClearAllChildren()
	local layout = Instance.new("UIListLayout", playerFrame)
	layout.Padding = UDim.new(0,4)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, -10, 0, 28)
			item.BackgroundColor3 = Color3.fromRGB(55,55,55)
			Instance.new("UICorner", item).CornerRadius = UDim.new(0,6)
			item.Parent = playerFrame

			local nameLabel = Instance.new("TextLabel", item)
			nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
			nameLabel.Position = UDim2.new(0, 8, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = plr.Name
			nameLabel.Font = Enum.Font.Gotham
			nameLabel.TextColor3 = Color3.new(1,1,1)
			nameLabel.TextScaled = true
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left

			local btn = Instance.new("TextButton", item)
			btn.Size = UDim2.new(0.25, 0, 1, -4)
			btn.Position = UDim2.new(0.73, 0, 0, 2)
			btn.Text = "COPY"
			btn.Font = Enum.Font.GothamBold
			btn.TextScaled = true
			btn.BackgroundColor3 = Color3.fromRGB(0,120,215)
			btn.TextColor3 = Color3.new(1,1,1)
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

			btn.MouseButton1Click:Connect(function()
				statusLabel.Text = "⏳ Copying " .. plr.Name
				statusLabel.TextColor3 = Color3.fromRGB(255,255,0)
				local ok,msg = loadAvatar(plr.Name)
				if ok then
					statusLabel.Text = "✅ Copied " .. plr.Name
					statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
				else
					statusLabel.Text = "❌ " .. msg
					statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
				end
				task.wait(2)
				statusLabel.Text = "✨ Ready to change avatar"
				statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
			end)
		end
	end
end

-- ======================================================
-- 🪟 TOGGLE + DRAG
-- ======================================================
local function makeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

local gui, frame, toggle, close, input, submit, status, playerList = createUI()

toggle.MouseButton1Click:Connect(function()
	UIState.isOpen = not UIState.isOpen
	frame.Visible = UIState.isOpen
	toggle.Text = UIState.isOpen and "❌" or "🎮"
	toggle.BackgroundColor3 = UIState.isOpen and Color3.fromRGB(196,43,28) or Color3.fromRGB(0,120,215)
	if UIState.isOpen then refreshPlayerList(playerList, status) end
end)

close.MouseButton1Click:Connect(function()
	UIState.isOpen = false
	frame.Visible = false
	toggle.Text = "🎮"
	toggle.BackgroundColor3 = Color3.fromRGB(0,120,215)
end)

submit.MouseButton1Click:Connect(function()
	local username = input.Text
	if username == "" then return end
	status.Text = "⏳ Loading avatar..."
	status.TextColor3 = Color3.fromRGB(255,255,0)
	local ok,msg = loadAvatar(username)
	if ok then
		status.Text = "✅ Avatar changed!"
		status.TextColor3 = Color3.fromRGB(0,255,0)
	else
		status.Text = "❌ " .. msg
		status.TextColor3 = Color3.fromRGB(255,0,0)
	end
	task.wait(3)
	status.Text = "✨ Ready to change avatar"
	status.TextColor3 = Color3.fromRGB(200,200,200)
end)

input.FocusLost:Connect(function(enter)
	if enter then submit:Activate() end
end)

Players.PlayerAdded:Connect(function() refreshPlayerList(playerList, status) end)
Players.PlayerRemoving:Connect(function() refreshPlayerList(playerList, status) end)

makeDraggable(frame, frame:WaitForChild("Frame",1) or frame:FindFirstChildWhichIsA("Frame"))
