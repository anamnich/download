-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Variables
local recording = false
local coordsList = {}
local minimized = false

-- Keep last frame position (persists while script berjalan)
local lastFramePosition = UDim2.new(0.5, -100, 0.3, -130)

-- Create or ensure ScreenGui (ke PlayerGui)
local function createGui()
	-- If GUI already exists and parented, return it
	local existing = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("CoordRecorderMini")
	if existing then
		return existing
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CoordRecorderMini"
	screenGui.ResetOnSpawn = false -- important so it tries to survive some respawn behaviors
	screenGui.Parent = player:WaitForChild("PlayerGui")

	-- Frame
	local frame = Instance.new("Frame", screenGui)
	frame.Size = UDim2.new(0, 200, 0, 270)
	frame.Position = lastFramePosition
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frame.BorderSizePixel = 0
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	-- Title
	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, -30, 0, 22)
	title.Position = UDim2.new(0, 5, 0, 5)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(0, 255, 255)
	title.Text = "📍 Zass Cordinat Mini"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left

	-- Minimize button
	local minimizeButton = Instance.new("TextButton", frame)
	minimizeButton.Size = UDim2.new(0, 22, 0, 22)
	minimizeButton.Position = UDim2.new(1, -25, 0, 5)
	minimizeButton.Text = "-"
	minimizeButton.Font = Enum.Font.GothamBold
	minimizeButton.TextSize = 16
	minimizeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	minimizeButton.TextColor3 = Color3.fromRGB(0, 255, 255)
	Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 4)

	-- Current coord label
	local coordLabel = Instance.new("TextLabel", frame)
	coordLabel.Size = UDim2.new(1, -10, 0, 18)
	coordLabel.Position = UDim2.new(0, 5, 0, 28)
	coordLabel.BackgroundTransparency = 1
	coordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	coordLabel.Text = "Vector3.new(0,0,0)"
	coordLabel.Font = Enum.Font.Gotham
	coordLabel.TextSize = 12

	-- Scroll list
	local listFrame = Instance.new("ScrollingFrame", frame)
	listFrame.Size = UDim2.new(1, -10, 0, 120)
	listFrame.Position = UDim2.new(0, 5, 0, 50)
	listFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
	listFrame.BorderSizePixel = 0
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.ScrollBarThickness = 4
	Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

	local uiListLayout = Instance.new("UIListLayout", listFrame)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 2)

	-- Button builder
	local function createMiniButton(text, y)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0.45, -5, 0, 24)
	btn.Position = UDim2.new((y % 2 == 0) and 0.05 or 0.5, 0, 0, 180 + math.floor(y / 2) * 28)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- tombol hitam
	btn.TextColor3 = Color3.fromRGB(0, 255, 255) -- teks biru
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
	return btn
end

	-- Buttons
	local btnNames = {"Start", "Stop", "Add", "Clear", "Copy", "Vector3"}
local buttons = {}

for i = 1, #btnNames do
	buttons[i] = createMiniButton(btnNames[i], i - 1)
end

	-- Add coord function (uses outer coordsList variable)
	local function addCoord(pos)
		table.insert(coordsList, pos)
		local lbl = Instance.new("TextLabel", listFrame)
		lbl.Size = UDim2.new(1, -4, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 11
		lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
		lbl.Text = #coordsList..". Vector3.new("..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)..")"
		listFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 5)
		listFrame.CanvasPosition = Vector2.new(0, listFrame.CanvasSize.Y.Offset) -- auto scroll
-- 🌈 Efek warna pelangi lembut untuk teks koordinat
task.spawn(function()
	while lbl and lbl.Parent do
		task.wait(0.05)
		local hue = (tick() * 0.2) % 1 -- kecepatan putar warna lebih lembut
		local color = Color3.fromHSV(hue, 0.6, 1) -- saturasi 0.6 = warna agak pudar
		lbl.TextColor3 = color
	end
end)
	end



	-- Coord update
	local function updateCoord()
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local pos = player.Character.HumanoidRootPart.Position
			coordLabel.Text = "Vector3.new("..math.floor(pos.X)..","..math.floor(pos.Y)..","..math.floor(pos.Z)..")"
			return pos
		end
		return Vector3.new(0, 0, 0)
	end

	-- Buttons behavior
	buttons[1].MouseButton1Click:Connect(function() recording = true end)
	buttons[2].MouseButton1Click:Connect(function() recording = false end)
	buttons[3].MouseButton1Click:Connect(function() addCoord(updateCoord()) end)
	buttons[4].MouseButton1Click:Connect(function()
		coordsList = {}
		for _, c in pairs(listFrame:GetChildren()) do
			if c:IsA("TextLabel") then c:Destroy() end
		end
		listFrame.CanvasSize = UDim2.new(0,0,0,0)
	end)
	buttons[5].MouseButton1Click:Connect(function()
		if #coordsList == 0 then return end
		local str = ""
		for _, pos in ipairs(coordsList) do
			str = str .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. "\n"
		end
		-- setclipboard may fail on some environments; pcall to avoid errors
		pcall(function() setclipboard(str) end)
	end)
	buttons[6].MouseButton1Click:Connect(function()
	if #coordsList == 0 then return end
	local str = "{\n"
	for i, pos in ipairs(coordsList) do
		str = str .. string.format("    Vector3.new(%d, %d, %d)", math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z))
		if i < #coordsList then
			str = str .. ",\n"
		else
			str = str .. "\n"
		end
	end
	str = str .. "}"
	pcall(function() setclipboard(str) end)
end)


	-- Recording loop
	RunService.RenderStepped:Connect(function()
		if recording then
			local pos = updateCoord()
			local last = coordsList[#coordsList]
			if not last or (last - pos).Magnitude > 3 then
				addCoord(pos)
			end
		end
	end)

	-- Minimize behavior
	local elementsToHide = {coordLabel, listFrame}
	for _, b in ipairs(buttons) do table.insert(elementsToHide, b) end

	minimizeButton.MouseButton1Click:Connect(function()
		minimized = not minimized
		for _, element in ipairs(elementsToHide) do
			element.Visible = not minimized
		end
		minimizeButton.Text = minimized and "+" or "-"
		frame.Size = minimized and UDim2.new(0, 200, 0, 32) or UDim2.new(0, 200, 0, 270)
	end)

	-- Save frame position whenever it changes
	frame:GetPropertyChangedSignal("Position"):Connect(function()
		lastFramePosition = frame.Position
	end)

	-- UNIVERSAL DRAGGING (PC + MOBILE)
	local dragging = false
	local dragStart, startPos

	local function updateDrag(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateDrag(input)
		end
	end)

	-- Return created GUI root (screenGui) and frame reference if needed
	return screenGui, frame
end

-- Create GUI now
local screenGui, frame = createGui()

-- Re-apply GUI on respawn (PlayerGui might be cleared)
player.CharacterAdded:Connect(function()
	task.wait(0.8) -- wait a bit so PlayerGui is ready
	-- Recreate or reparent if missing
	local existing = player.PlayerGui:FindFirstChild("CoordRecorderMini")
	if not existing then
		-- recreate
		screenGui, frame = createGui()
	else
		-- re-assign references and restore last position
		screenGui = existing
		frame = existing:FindFirstChildOfClass("Frame") or frame
		if frame and lastFramePosition then
			frame.Position = lastFramePosition
		end
	end
end)
