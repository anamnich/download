-- CHANGE YOUR AVATAR v2.3
-- UI + Tool Keeper + Auto Equip + Auto Respawn Restore (Aura removed, Windows 11 Style GUI)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- UI State
local UIState = {
	isOpen = false,
	isAnimating = false
}

-- Global tool storage for respawn restoration
local savedToolsGlobal = {}

-- ======================================================
-- 🔘 UI CREATION (Windows 11 Style: Dark theme, rounded corners, subtle transparency)
-- ======================================================
local function createToggleButton()
	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Name = "ToggleButton"
	ToggleButton.Size = UDim2.new(0, 50, 0, 50)
	ToggleButton.Position = UDim2.new(0, 20, 0, 20)
	ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- Windows 11 accent blue
	ToggleButton.BorderSizePixel = 0
	ToggleButton.Text = "🎮"
	ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToggleButton.TextScaled = true
	ToggleButton.Font = Enum.Font.GothamBold
	ToggleButton.ZIndex = 10
	ToggleButton.BackgroundTransparency = 0.1 -- Subtle transparency for glass effect

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 25)
	ToggleCorner.Parent = ToggleButton

	return ToggleButton
end

local function createUI()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "RobloxAccountLoader"
	ScreenGui.Parent = lp:WaitForChild("PlayerGui")
	ScreenGui.ResetOnSpawn = false

	local ToggleButton = createToggleButton()
	ToggleButton.Parent = ScreenGui

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 400, 0, 140) -- Slightly larger for better spacing
	MainFrame.Position = UDim2.new(0.5, -200, 0.05, 0)
	MainFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32) -- Dark Windows 11 background
	MainFrame.BorderSizePixel = 0
	MainFrame.Visible = false
	MainFrame.BackgroundTransparency = 0.05 -- Subtle transparency
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12) -- More rounded for Windows 11
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(100, 100, 100)
	MainStroke.Thickness = 1
	MainStroke.Transparency = 0.5
	MainStroke.Parent = MainFrame

	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 35) -- Slightly taller
	TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	TitleBar.BorderSizePixel = 0
	TitleBar.BackgroundTransparency = 0.1
	TitleBar.Parent = MainFrame

	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 12)
	TitleCorner.Parent = TitleBar

	local TitleText = Instance.new("TextLabel")
	TitleText.Size = UDim2.new(1, -50, 1, 0) -- Leave space for close button
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = "🎮 CHANGE YOUR AVATAR"
	TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleText.TextScaled = true
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleBar

	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 30, 0, 30)
	CloseButton.Position = UDim2.new(1, -35, 0, 2.5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(196, 43, 28) -- Windows close red
	CloseButton.BorderSizePixel = 0
	CloseButton.Text = "✕"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextScaled = true
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.BackgroundTransparency = 0.2
	CloseButton.Parent = TitleBar

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 4)
	CloseCorner.Parent = CloseButton

	local InputFrame = Instance.new("Frame")
	InputFrame.Size = UDim2.new(1, -30, 0, 40)
	InputFrame.Position = UDim2.new(0, 15, 0, 40)
	InputFrame.BackgroundTransparency = 1
	InputFrame.Parent = MainFrame

	local UsernameInput = Instance.new("TextBox")
	UsernameInput.Size = UDim2.new(0.7, -5, 1, 0)
	UsernameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	UsernameInput.BorderSizePixel = 0
	UsernameInput.PlaceholderText = "Enter username..."
	UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	UsernameInput.TextScaled = true
	UsernameInput.Font = Enum.Font.Gotham
	UsernameInput.BackgroundTransparency = 0.2
	UsernameInput.Parent = InputFrame

	local UsernameCorner = Instance.new("UICorner")
	UsernameCorner.CornerRadius = UDim.new(0, 8)
	UsernameCorner.Parent = UsernameInput

	local SubmitButton = Instance.new("TextButton")
	SubmitButton.Size = UDim2.new(0.3, -5, 1, 0)
	SubmitButton.Position = UDim2.new(0.7, 0, 0, 0)
	SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- Accent blue
	SubmitButton.BorderSizePixel = 0
	SubmitButton.Text = "SUBMIT"
	SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitButton.TextScaled = true
	SubmitButton.Font = Enum.Font.GothamBold
	SubmitButton.BackgroundTransparency = 0.1
	SubmitButton.Parent = InputFrame

	local SubmitCorner = Instance.new("UICorner")
	SubmitCorner.CornerRadius = UDim.new(0, 8)
	SubmitCorner.Parent = SubmitButton

	local StatusFrame = Instance.new("Frame")
	StatusFrame.Size = UDim2.new(1, -30, 0, 45)
	StatusFrame.Position = UDim2.new(0, 15, 0, 85)
	StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	StatusFrame.BorderSizePixel = 0
	StatusFrame.BackgroundTransparency = 0.2
	StatusFrame.Parent = MainFrame

	local StatusCorner = Instance.new("UICorner")
	StatusCorner.CornerRadius = UDim.new(0, 8)
	StatusCorner.Parent = StatusFrame

	local StatusText = Instance.new("TextLabel")
	StatusText.Size = UDim2.new(1, -10, 1, 0)
	StatusText.Position = UDim2.new(0, 5, 0, 0)
	StatusText.BackgroundTransparency = 1
	StatusText.Text = "✨ Ready to change avatar"
	StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
	StatusText.TextScaled = true
	StatusText.Font = Enum.Font.GothamBold
	StatusText.TextXAlignment = Enum.TextXAlignment.Center
	StatusText.Parent = StatusFrame

	return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, CloseButton
end

-- ======================================================
-- 🧩 Fungsi loadAvatar (tetap dengan Tool Keeper, tapi tanpa aura)
-- ======================================================
local function loadAvatar(username)
	if not username or username == "" then
		return false, "Username tidak boleh kosong!"
	end

	local char = lp.Character or lp.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false, "Character / Humanoid tidak ada!"
	end

	-- Simpan semua tool dari Backpack dan Character
	local savedTools, equippedToolNames = {}, {}
	for _, tool in ipairs(lp.Backpack:GetChildren()) do
		if tool:IsA("Tool") then table.insert(savedTools, tool) end
	end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			table.insert(savedTools, tool)
			table.insert(equippedToolNames, tool.Name)
		end
	end

	-- Ambil avatar dari username
	local success, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(username)
	end)
	if not success or not userId then
		return false, "Username tidak ditemukan: " .. tostring(username)
	end

	local success2, humanoidDesc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not success2 or not humanoidDesc then
		return false, "Gagal mendapatkan avatar description"
	end

	-- Hapus accessories & clothing lama (jangan hapus tools)
	for _, item in pairs(char:GetChildren()) do
		if item:IsA("Accessory") or item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
			pcall(function() item:Destroy() end)
		end
	end

	task.wait(0.1)

	-- Terapkan description
	local okApply, err = pcall(function()
		humanoid:ApplyDescriptionClientServer(humanoidDesc)
	end)
	if not okApply then
		return false, "Gagal mengubah avatar: " .. tostring(err)
	end

	-- Tunggu character/humanoid settle
	task.wait(0.8)

	-- Restore tools into Backpack (if any)
	for _, tool in ipairs(savedTools) do
		if tool and tool.Parent and tool.Parent ~= lp.Backpack then
			pcall(function() tool.Parent = lp.Backpack end)
		end
	end

	-- Re-equip previously equipped tools
	task.wait(0.25)
	for _, name in ipairs(equippedToolNames) do
		local found = lp.Backpack:FindFirstChild(name)
		if found and char and char:FindFirstChildOfClass("Humanoid") then
			pcall(function()
				char:FindFirstChildOfClass("Humanoid"):EquipTool(found)
			end)
		end
	end

	return true, "Avatar berhasil diubah ke: " .. username
end

-- ======================================================
-- UI Animation & Events (tetap seperti sebelum, tambah close button)
-- ======================================================
local function animateUI(frame, isOpening)
	if UIState.isAnimating then return end
	UIState.isAnimating = true

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	if isOpening then frame.Visible = true end

	local goal = isOpening and {Size = UDim2.new(0,400,0,140)} or {Size = UDim2.new(0,0,0,0)}
	local tween = TweenService:Create(frame, tweenInfo, goal)
	tween:Play()
	tween.Completed:Connect(function()
		if not isOpening then frame.Visible = false end
		UIState.isAnimating = false
	end)
end

local function toggleUI(mainFrame, toggleButton)
	if UIState.isAnimating then return end
	UIState.isOpen = not UIState.isOpen
	if UIState.isOpen then
		animateUI(mainFrame, true)
		toggleButton.Text = "❌"
		toggleButton.BackgroundColor3 = Color3.fromRGB(196, 43, 28)
	else
		animateUI(mainFrame, false)
		toggleButton.Text = "🎮"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	end
end

-- ======================================================
-- MAIN Initialization & Connections
-- ======================================================
local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton, CloseButton = createUI()

ToggleButton.MouseButton1Click:Connect(function()
	toggleUI(MainFrame, ToggleButton)
end)

CloseButton.MouseButton1Click:Connect(function()
	toggleUI(MainFrame, ToggleButton)
end)

SubmitButton.MouseButton1Click:Connect(function()
	local username = UsernameInput.Text
	if username == "" then return end
	UsernameInput.PlaceholderText = "Loading avatar..."
	UsernameInput.Text = ""
	StatusText.Text = "⏳ sabar jirr masi proses"
	StatusText.TextColor3 = Color3.fromRGB(255,255,0)

	local ok, msg = loadAvatar(username)
	if ok then
		UsernameInput.PlaceholderText = "✓ Loaded: " .. username
		StatusText.Text = "✅ berhasil berganti avatar"
		StatusText.TextColor3 = Color3.fromRGB(0,255,0)
	else
		UsernameInput.PlaceholderText = "✗ Error: " .. msg
		StatusText.Text = "❌ masukin username bego, bkn nama"
		StatusText.TextColor3 = Color3.fromRGB(255,0,0)
	end
	task.wait(3)
	UsernameInput.PlaceholderText = "Enter username..."
	StatusText.Text = "✨ Ready to change avatar"
	StatusText.TextColor3 = Color3.fromRGB(200,200,200)
end)

UsernameInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then SubmitButton:Activate() end
end)

-- Auto reload avatar after respawn (preserve last username) and restore tools
local lastLoadedUsername = nil
local oldLoadAvatar = loadAvatar
loadAvatar = function(username)
	local ok, msg = oldLoadAvatar(username)
	if ok then lastLoadedUsername = username end
	return ok, msg
end

-- Save tools before character removal (for respawn restoration)
lp.CharacterRemoving:Connect(function(char)
	savedToolsGlobal = {}
	for _, tool in ipairs(lp.Backpack:GetChildren()) do
		if tool:IsA("Tool") then table.insert(savedToolsGlobal, tool) end
	end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then table.insert(savedToolsGlobal, tool) end
	end
end)

lp.CharacterAdded:Connect(function(char)
	-- small delay so character is ready
	task.wait(1.0)
	
	-- Restore tools from global storage
	for _, tool in ipairs(savedToolsGlobal) do
		if tool and tool.Parent then
			pcall(function() tool.Parent = lp.Backpack end)
		end
	end
	task.wait(0.25)
	-- Re-equip all restored tools (assuming they were equipped before)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		for _, tool in ipairs(lp.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				pcall(function() humanoid:EquipTool(tool) end)
			end
		end
	end
	
	-- If lastLoadedUsername exists, reload avatar
	if lastLoadedUsername then
		local ok, _ = pcall(function() oldLoadAvatar(lastLoadedUsername) end)
		if ok then
			print("[AvatarLoader] Auto-restored:", lastLoadedUsername)
		end
	end
end)
