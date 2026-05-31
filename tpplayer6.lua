--// DRONE CAMERA v8
--// Elegant UI + Search + Profile Avatar + Minimize + Touch Rotate (HP)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- === THEME ===
local BG_DARK    = Color3.fromRGB(12, 12, 16)
local BG_CARD    = Color3.fromRGB(20, 20, 28)
local BG_ITEM    = Color3.fromRGB(28, 28, 38)
local BG_HOVER   = Color3.fromRGB(38, 38, 52)
local ACCENT     = Color3.fromRGB(110, 86, 220)
local TEXT_PRI   = Color3.fromRGB(230, 230, 240)
local TEXT_SEC   = Color3.fromRGB(140, 140, 160)
local BORDER     = Color3.fromRGB(40, 40, 58)
local RED_BTN    = Color3.fromRGB(180, 60, 60)
local GREEN_BTN  = Color3.fromRGB(50, 180, 80)

-- === HELPER ===
local function corner(r, p) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0,r) c.Parent = p end
local function pad(t,b,l,r,p) local c = Instance.new("UIPadding") c.PaddingTop=UDim.new(0,t) c.PaddingBottom=UDim.new(0,b) c.PaddingLeft=UDim.new(0,l) c.PaddingRight=UDim.new(0,r) c.Parent=p end
local function stroke(t,c,p) local s=Instance.new("UIStroke") s.Thickness=t s.Color=c s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p return s end

-- === GUI ROOT ===
local gui = Instance.new("ScreenGui")
gui.Name = "DroneCamV8"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = lp:WaitForChild("PlayerGui")

-- === MAIN FRAME ===
local FULL_HEIGHT = 386
local MINI_HEIGHT = 36
local isMinimized = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, FULL_HEIGHT)
frame.Position = UDim2.new(0.82, 0, 0.35, 0)
frame.BackgroundColor3 = BG_DARK
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.ClipsDescendants = true
frame.Parent = gui
corner(12, frame)
stroke(1, BORDER, frame)

-- === TITLE BAR ===
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = BG_CARD
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
corner(12, titleBar)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = BG_CARD
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local dot1 = Instance.new("Frame")
dot1.Size = UDim2.new(0, 8, 0, 8)
dot1.Position = UDim2.new(0, 10, 0.5, -4)
dot1.BackgroundColor3 = ACCENT
dot1.BorderSizePixel = 0
dot1.Parent = titleBar
corner(99, dot1)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 24, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ZassXd View"
titleLabel.TextColor3 = TEXT_PRI
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- === MINIMIZE BUTTON ===
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
minimizeBtn.Position = UDim2.new(1, -58, 0.5, -12)
minimizeBtn.BackgroundColor3 = GREEN_BTN
minimizeBtn.Text = "–"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.Parent = titleBar
corner(6, minimizeBtn)

-- === CLOSE BUTTON ===
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = RED_BTN
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = titleBar
corner(6, closeBtn)

closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	local targetHeight = isMinimized and MINI_HEIGHT or FULL_HEIGHT
	TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 220, 0, targetHeight)
	}):Play()
	minimizeBtn.Text = isMinimized and "□" or "–"
	titleFix.Visible = not isMinimized
end)

-- === CONTENT AREA ===
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -36)
content.Position = UDim2.new(0, 0, 0, 36)
content.BackgroundTransparency = 1
content.Parent = frame
pad(8, 8, 8, 8, content)

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = content

-- === SEARCH BOX ===
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, 0, 0, 32)
searchFrame.BackgroundColor3 = BG_ITEM
searchFrame.BorderSizePixel = 0
searchFrame.LayoutOrder = 1
searchFrame.Parent = content
corner(8, searchFrame)
stroke(1, BORDER, searchFrame)

local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0, 28, 1, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextSize = 12
searchIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -32, 1, 0)
searchBox.Position = UDim2.new(0, 28, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Cari username / nama..."
searchBox.PlaceholderColor3 = TEXT_SEC
searchBox.Text = ""
searchBox.TextColor3 = TEXT_PRI
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 12
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchFrame

-- === PLAYER LIST ===
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, 0, 0, 160)
listFrame.BackgroundColor3 = BG_CARD
listFrame.BorderSizePixel = 0
listFrame.LayoutOrder = 2
listFrame.ClipsDescendants = true
listFrame.Parent = content
corner(8, listFrame)
stroke(1, BORDER, listFrame)

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 1, 0)
playerList.BackgroundTransparency = 1
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 3
playerList.ScrollBarImageColor3 = ACCENT
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = listFrame
pad(4, 4, 4, 4, playerList)

local uiList = Instance.new("UIListLayout")
uiList.Parent = playerList
uiList.Padding = UDim.new(0, 3)

-- === BUTTONS ===
local function makeBtn(text, color, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = color
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.BorderSizePixel = 0
	btn.LayoutOrder = order
	btn.Parent = content
	corner(8, btn)
	return btn
end

-- === STATE ===
local currentTarget = nil
local cameraFollow  = false
local sensitivity   = 0.25
local pitch, yaw    = 15, 0
local zoomDist      = 10
local smoothSpeed   = 0.1
local freeRotate    = false
local allButtons    = {}

local followButton   = makeBtn("🎥  Enable Camera", ACCENT, 3)
local teleportButton = makeBtn("⚡  Teleport", Color3.fromRGB(50, 140, 100), 4)

-- === ZOOM ROW ===
local zoomRow = Instance.new("Frame")
zoomRow.Size = UDim2.new(1, 0, 0, 32)
zoomRow.BackgroundTransparency = 1
zoomRow.LayoutOrder = 5
zoomRow.Parent = content

local zoomLabel = Instance.new("TextLabel")
zoomLabel.Size = UDim2.new(1, -76, 1, 0)
zoomLabel.BackgroundTransparency = 1
zoomLabel.Text = "🔭  Zoom Kamera"
zoomLabel.TextColor3 = TEXT_SEC
zoomLabel.Font = Enum.Font.Gotham
zoomLabel.TextSize = 11
zoomLabel.TextXAlignment = Enum.TextXAlignment.Left
zoomLabel.Parent = zoomRow

local zoomOut = Instance.new("TextButton")
zoomOut.Size = UDim2.new(0, 34, 1, 0)
zoomOut.Position = UDim2.new(1, -74, 0, 0)
zoomOut.BackgroundColor3 = BG_ITEM
zoomOut.Text = "–"
zoomOut.TextColor3 = TEXT_PRI
zoomOut.Font = Enum.Font.GothamBold
zoomOut.TextSize = 16
zoomOut.BorderSizePixel = 0
zoomOut.Parent = zoomRow
corner(8, zoomOut)
stroke(1, BORDER, zoomOut)

local zoomIn = Instance.new("TextButton")
zoomIn.Size = UDim2.new(0, 34, 1, 0)
zoomIn.Position = UDim2.new(1, -36, 0, 0)
zoomIn.BackgroundColor3 = BG_ITEM
zoomIn.Text = "+"
zoomIn.TextColor3 = TEXT_PRI
zoomIn.Font = Enum.Font.GothamBold
zoomIn.TextSize = 16
zoomIn.BorderSizePixel = 0
zoomIn.Parent = zoomRow
corner(8, zoomIn)
stroke(1, BORDER, zoomIn)

local zoomHoldConn = nil
local function startZoom(dir)
	if zoomHoldConn then zoomHoldConn:Disconnect() end
	zoomHoldConn = RunService.RenderStepped:Connect(function()
		if cameraFollow then
			zoomDist = math.clamp(zoomDist + dir * 0.4, 3, 60)
		end
	end)
end
local function stopZoom()
	if zoomHoldConn then zoomHoldConn:Disconnect() zoomHoldConn = nil end
end

zoomOut.MouseButton1Click:Connect(function()
	if cameraFollow then zoomDist = math.clamp(zoomDist + 3, 3, 60) end
end)
zoomIn.MouseButton1Click:Connect(function()
	if cameraFollow then zoomDist = math.clamp(zoomDist - 3, 3, 60) end
end)
zoomOut.MouseButton1Down:Connect(function() startZoom(1) end)
zoomOut.MouseButton1Up:Connect(stopZoom)
zoomIn.MouseButton1Down:Connect(function() startZoom(-1) end)
zoomIn.MouseButton1Up:Connect(stopZoom)
zoomOut.TouchLongPress:Connect(function() startZoom(1) end)
zoomIn.TouchLongPress:Connect(function() startZoom(-1) end)

-- === PLAYER LIST BUILDER ===
local function getDisplayName(p)
	local ok, dn = pcall(function() return p.DisplayName end)
	return ok and dn or p.Name
end

local function buildList(filter)
	for _, c in pairs(playerList:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	allButtons = {}
	filter = filter and filter:lower() or ""

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= lp then
			local dn = getDisplayName(p)
			local nameMatch = p.Name:lower():find(filter, 1, true)
			local dnMatch   = dn:lower():find(filter, 1, true)
			if filter == "" or nameMatch or dnMatch then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 40)
				btn.BackgroundColor3 = BG_ITEM
				btn.BorderSizePixel = 0
				btn.Text = ""
				btn.AutoButtonColor = false
				btn.Parent = playerList
				corner(8, btn)

				local avatarFrame = Instance.new("Frame")
				avatarFrame.Size = UDim2.new(0, 28, 0, 28)
				avatarFrame.Position = UDim2.new(0, 8, 0.5, -14)
				avatarFrame.BackgroundColor3 = BG_HOVER
				avatarFrame.BorderSizePixel = 0
				avatarFrame.ZIndex = btn.ZIndex + 1
				avatarFrame.Parent = btn
				corner(99, avatarFrame)
				stroke(1, ACCENT, avatarFrame)

				local avatarImg = Instance.new("ImageLabel")
				avatarImg.Size = UDim2.new(1, 0, 1, 0)
				avatarImg.BackgroundTransparency = 1
				avatarImg.Image = ""
				avatarImg.ScaleType = Enum.ScaleType.Crop
				avatarImg.ZIndex = btn.ZIndex + 2
				avatarImg.Parent = avatarFrame
				corner(99, avatarImg)

				local initLabel = Instance.new("TextLabel")
				initLabel.Size = UDim2.new(1, 0, 1, 0)
				initLabel.BackgroundTransparency = 1
				initLabel.Text = p.Name:sub(1,1):upper()
				initLabel.TextColor3 = TEXT_PRI
				initLabel.Font = Enum.Font.GothamBold
				initLabel.TextSize = 12
				initLabel.ZIndex = btn.ZIndex + 2
				initLabel.Parent = avatarFrame

				task.spawn(function()
					local ok, thumb = pcall(function()
						return Players:GetUserThumbnailAsync(
							p.UserId,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size48x48
						)
					end)
					if ok and thumb and thumb ~= "" then
						avatarImg.Image = thumb
						initLabel.Visible = false
					end
				end)

				local nameCol = Instance.new("Frame")
				nameCol.Size = UDim2.new(1, -46, 1, 0)
				nameCol.Position = UDim2.new(0, 44, 0, 0)
				nameCol.BackgroundTransparency = 1
				nameCol.ZIndex = btn.ZIndex + 1
				nameCol.Parent = btn

				local usernameL = Instance.new("TextLabel")
				usernameL.Size = UDim2.new(1, -4, 0, 20)
				usernameL.Position = UDim2.new(0, 0, 0.5, dn ~= p.Name and -20 or -8)
				usernameL.BackgroundTransparency = 1
				usernameL.Text = p.Name
				usernameL.TextColor3 = TEXT_PRI
				usernameL.Font = Enum.Font.GothamBold
				usernameL.TextSize = 12
				usernameL.TextXAlignment = Enum.TextXAlignment.Left
				usernameL.TextTruncate = Enum.TextTruncate.AtEnd
				usernameL.ZIndex = btn.ZIndex + 2
				usernameL.Parent = nameCol

				local displayL = Instance.new("TextLabel")
				displayL.Size = UDim2.new(1, -4, 0, 14)
				displayL.Position = UDim2.new(0, 0, 0.5, 2)
				displayL.BackgroundTransparency = 1
				displayL.Text = dn ~= p.Name and dn or ""
				displayL.TextColor3 = TEXT_SEC
				displayL.Font = Enum.Font.Gotham
				displayL.TextSize = 10
				displayL.TextXAlignment = Enum.TextXAlignment.Left
				displayL.TextTruncate = Enum.TextTruncate.AtEnd
				displayL.ZIndex = btn.ZIndex + 2
				displayL.Parent = nameCol

				btn.MouseEnter:Connect(function()
					if currentTarget ~= p then btn.BackgroundColor3 = Color3.fromRGB(33, 33, 46) end
				end)
				btn.MouseLeave:Connect(function()
					if currentTarget ~= p then btn.BackgroundColor3 = BG_ITEM end
				end)

				if currentTarget == p then
					btn.BackgroundColor3 = BG_HOVER
					stroke(1, ACCENT, btn)
				end

				btn.MouseButton1Click:Connect(function()
					currentTarget = p
					for _, b in pairs(allButtons) do
						b.BackgroundColor3 = BG_ITEM
						for _, s in pairs(b:GetChildren()) do
							if s:IsA("UIStroke") then s:Destroy() end
						end
					end
					btn.BackgroundColor3 = BG_HOVER
					stroke(1, ACCENT, btn)
				end)

				table.insert(allButtons, btn)
			end
		end
	end
	playerList.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 8)
end

buildList("")
Players.PlayerAdded:Connect(function() buildList(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() buildList(searchBox.Text) end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function() buildList(searchBox.Text) end)

-- === MOUSE CAMERA (PC) ===
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
	if cameraFollow and input.UserInputType == Enum.UserInputType.MouseWheel then
		zoomDist = math.clamp(zoomDist - input.Position.Z * 2, 3, 60)
	end
	if freeRotate and input.UserInputType == Enum.UserInputType.MouseMovement then
		yaw   = yaw - input.Delta.X * sensitivity
		pitch = math.clamp(pitch - input.Delta.Y * sensitivity, -80, 80)
	end
end)

-- === TOUCH ROTATE (HP) ===
-- Swipe di area luar GUI = putar kamera kanan/kiri/atas/bawah
local touchStart  = nil
local touchActive = false

UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
	-- gameProcessed = true artinya sentuhan kena tombol/GUI, skip
	if gameProcessed then return end
	if not cameraFollow then return end
	touchStart  = Vector2.new(touch.Position.X, touch.Position.Y)
	touchActive = true
end)

UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
	if not touchActive or not cameraFollow or not touchStart then return end
	local current = Vector2.new(touch.Position.X, touch.Position.Y)
	local delta   = current - touchStart
	touchStart    = current  -- update supaya delta per-frame, bukan akumulasi
	yaw   = yaw - delta.X * sensitivity * 0.5
	pitch = math.clamp(pitch - delta.Y * sensitivity * 0.5, -80, 80)
end)

UserInputService.TouchEnded:Connect(function()
	touchActive = false
	touchStart  = nil
end)

-- === CAMERA LOOP ===
RunService.RenderStepped:Connect(function()
	if cameraFollow and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = currentTarget.Character.HumanoidRootPart
		local rotation = CFrame.Angles(0, math.rad(yaw), 0) * CFrame.Angles(math.rad(pitch), 0, 0)
		local offset = rotation:VectorToWorldSpace(Vector3.new(0, zoomDist * 0.4, zoomDist))
		local targetCF = CFrame.new(hrp.Position + offset, hrp.Position)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = camera.CFrame:Lerp(targetCF, smoothSpeed)
	end
end)

-- === ENABLE/DISABLE CAMERA ===
followButton.MouseButton1Click:Connect(function()
	if not currentTarget then
		followButton.Text = "❌  Pilih target dulu"
		task.wait(1.2)
		followButton.Text = "🎥  Enable Camera"
		return
	end

	if cameraFollow then
		cameraFollow = false
		camera.CameraType = Enum.CameraType.Custom
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if hum then camera.CameraSubject = hum end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		followButton.Text = "🎥  Enable Camera"
		followButton.BackgroundColor3 = ACCENT
	else
		local target = currentTarget
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = target.Character.HumanoidRootPart
			camera.CameraType = Enum.CameraType.Scriptable

			local startCF = CFrame.new(hrp.Position + Vector3.new(0, 80, 100), hrp.Position)
			local endCF   = hrp.CFrame * CFrame.new(0, 6, 12)
			camera.CFrame  = startCF

			local tw = TweenService:Create(camera, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = endCF})
			tw:Play()
			tw.Completed:Wait()

			pitch, yaw, zoomDist = 15, 0, 10
			cameraFollow = true
			followButton.Text = "🚁  Disable Camera"
			followButton.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
		end
	end
end)

-- === TELEPORT ===
teleportButton.MouseButton1Click:Connect(function()
	if not currentTarget then
		teleportButton.Text = "❌  Pilih target dulu"
		task.wait(1.2)
		teleportButton.Text = "⚡  Teleport"
		return
	end

	local target = currentTarget
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local targetHRP = target.Character.HumanoidRootPart
		local myChar = lp.Character or lp.CharacterAdded:Wait()
		local myHRP  = myChar:WaitForChild("HumanoidRootPart")

		workspace.FallenPartsDestroyHeight = -math.huge
		myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)

		if cameraFollow then
			camera.CameraType = Enum.CameraType.Scriptable
		end

		teleportButton.Text = "✅  Teleported!"
		task.wait(1.2)
		teleportButton.Text = "⚡  Teleport"
	end
end)
