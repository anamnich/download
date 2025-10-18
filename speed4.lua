-- Full integrated script (original + fixed ESP always-on + Jump Height control + universal jump fix + notif)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local VIP_KEY = "VIP"

local speedOptions = {12, 16, 20, 25, 30, 35, 40, 50, 60, 80, 100, 150, 200, 300, 400, 500}
local defaultWalkSpeed = 12
local currentSpeedIndex = 2 -- default index pointing to 16
local infiniteJumpEnabled = false
local jumpConnection = nil
local mainGUI = nil
local verified = false

-- ESP settings
local espEnabled = true
local ESP_DISTANCE = 2000
local espTags = {} -- map player -> {billboard = ..., label = ...}

-- helper: play small sound (non-blocking)
local function safePlaySound(parent, soundId)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = soundId
        s.Volume = 0.9
        s.Parent = parent
        s:Play()
        Debris:AddItem(s, 3)
    end)
end

-- utility: create respawn / short notification bottom-left
local function showRespawnNotification(text, duration)
    duration = duration or 2
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return end

    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "ZassXd_RespawnNotif"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = gui

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 320, 0, 28)
    lbl.Position = UDim2.new(0, 12, 1, -60) -- bottom-left
    lbl.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    lbl.BackgroundTransparency = 0.08
    lbl.BorderSizePixel = 0
    lbl.Text = "⚙️ " .. tostring(text)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.Parent = notifGui
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)

    -- fade in/out
    lbl.TextTransparency = 1
    lbl.BackgroundTransparency = 1
    TweenService:Create(lbl, TweenInfo.new(0.2), {TextTransparency = 0, BackgroundTransparency = 0.08}):Play()
    task.delay(duration, function()
        if lbl and lbl.Parent then
            TweenService:Create(lbl, TweenInfo.new(0.2), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
            task.delay(0.28, function()
                if notifGui and notifGui.Parent then notifGui:Destroy() end
            end)
        end
    end)
end

-- Welcome key GUI (shows only if not verified)
local function createWelcome(onSuccess)
    if verified then
        if onSuccess then pcall(onSuccess) end
        return
    end
    if player.PlayerGui:FindFirstChild("ZassXd_Welcome") then return end

    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "ZassXd_Welcome"
    gui.ResetOnSpawn = false

    local bg = Instance.new("Frame", gui)
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0

    local card = Instance.new("Frame", gui)
    card.Size = UDim2.new(0, 420, 0, 220)
    card.Position = UDim2.new(0.5, -210, 0.5, -110)
    card.BackgroundColor3 = Color3.fromRGB(10,15,20)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(0,255,255)
    stroke.Transparency = 0.5
    stroke.Thickness = 1.6

    local title = Instance.new("TextLabel", card)
    title.Size = UDim2.new(1, -24, 0, 36)
    title.Position = UDim2.new(0, 12, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(170,255,255)
    title.Text = "💠 ZassXd Hub - Premium Access"

    local subtitle = Instance.new("TextLabel", card)
    subtitle.Size = UDim2.new(1, -24, 0, 20)
    subtitle.Position = UDim2.new(0, 12, 0, 46)
    subtitle.BackgroundTransparency = 1
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextColor3 = Color3.fromRGB(200,230,230)
    subtitle.TextSize = 14
    subtitle.Text = "Masukkan key VIP untuk akses : key ( VIP )"

    local input = Instance.new("TextBox", card)
    input.Size = UDim2.new(0, 320, 0, 40)
    input.Position = UDim2.new(0.5, -160, 0, 80)
    input.PlaceholderText = "Enter key..."
    input.Text = ""
    input.ClearTextOnFocus = false
    input.Font = Enum.Font.Gotham
    input.TextSize = 18
    input.TextColor3 = Color3.fromRGB(240,240,240)
    input.BackgroundColor3 = Color3.fromRGB(18, 24, 32)
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

    local verifyBtn = Instance.new("TextButton", card)
    verifyBtn.Size = UDim2.new(0, 140, 0, 40)
    verifyBtn.Position = UDim2.new(0.5, -70, 0, 132)
    verifyBtn.Text = "Verify Key"
    verifyBtn.Font = Enum.Font.GothamBold
    verifyBtn.TextSize = 16
    verifyBtn.BackgroundColor3 = Color3.fromRGB(0,200,150)
    verifyBtn.TextColor3 = Color3.fromRGB(10,10,10)
    Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0,10)

    local feedback = Instance.new("TextLabel", card)
    feedback.Size = UDim2.new(1, -24, 0, 20)
    feedback.Position = UDim2.new(0, 12, 1, -28)
    feedback.BackgroundTransparency = 1
    feedback.Font = Enum.Font.Gotham
    feedback.TextSize = 14
    feedback.TextColor3 = Color3.fromRGB(255,140,140)
    feedback.Text = ""

    verifyBtn.MouseButton1Click:Connect(function()
        local entered = tostring(input.Text or ""):gsub("%s+", "")
        if entered:upper() == VIP_KEY then
            verified = true
            feedback.TextColor3 = Color3.fromRGB(150,255,150)
            feedback.Text = "✅ Key valid — Welcome, "..player.Name.."!"
            safePlaySound(card, "rbxassetid://184357731")
            task.wait(0.6)
            if gui and gui.Parent then gui:Destroy() end
            if onSuccess then pcall(onSuccess) end
        else
            feedback.Text = "❌ Key salah — coba lagi."
            safePlaySound(card, "rbxassetid://138087973")
        end
    end)

    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            verifyBtn:CaptureFocus()
            verifyBtn.MouseButton1Click:Wait()
        end
    end)
end

-- Create main UI (ZassXd Hub)
local function createMainUI()
    if mainGUI then return mainGUI end

    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "ZassXd_Hub"
    gui.ResetOnSpawn = false
    mainGUI = gui

    local frame = Instance.new("Frame", gui)
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -10, 0.15, 0) -- kanan atas
    frame.BackgroundColor3 = Color3.fromRGB(10,15,20)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 220, 255)
    stroke.Transparency = 0.45
    stroke.Thickness = 1.8

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(160,255,255)
    title.Text = "💠 ZassXd Hub"

    local usernameLabel = Instance.new("TextLabel", frame)
    usernameLabel.Size = UDim2.new(1, -20, 0, 20)
    usernameLabel.Position = UDim2.new(0, 10, 0, 38)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextSize = 14
    usernameLabel.TextColor3 = Color3.fromRGB(220,220,220)
    usernameLabel.Text = "User: " .. player.Name

    local powerBtn = Instance.new("TextButton", frame)
    powerBtn.Size = UDim2.new(0.9, 0, 0, 30)
    powerBtn.Position = UDim2.new(0.05, 0, 0, 64)
    powerBtn.BackgroundColor3 = Color3.fromRGB(0,220,255)
    powerBtn.Text = "🟢 SYSTEM: ON"
    powerBtn.Font = Enum.Font.GothamBold
    powerBtn.TextSize = 14
    powerBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", powerBtn).CornerRadius = UDim.new(0, 8)

    local systemEnabled = true

    local speedLabel = Instance.new("TextLabel", frame)
    speedLabel.Size = UDim2.new(1, -20, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 100)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 14
    speedLabel.TextColor3 = Color3.fromRGB(240,240,240)
    speedLabel.Text = "Speed: " .. tostring(speedOptions[currentSpeedIndex])

    local btnUp = Instance.new("TextButton", frame)
    btnUp.Size = UDim2.new(0.44, 0, 0, 32)
    btnUp.Position = UDim2.new(0.05, 0, 0, 130)
    btnUp.Text = "⬆️ Faster"
    btnUp.Font = Enum.Font.GothamBold
    btnUp.TextSize = 14
    btnUp.BackgroundColor3 = Color3.fromRGB(0,200,120)
    Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 8)

    local btnDown = Instance.new("TextButton", frame)
    btnDown.Size = UDim2.new(0.44, 0, 0, 32)
    btnDown.Position = UDim2.new(0.5, 0, 0, 130)
    btnDown.Text = "⬇️ Slower"
    btnDown.Font = Enum.Font.GothamBold
    btnDown.TextSize = 14
    btnDown.BackgroundColor3 = Color3.fromRGB(235, 80, 80)
    Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 8)

    -- INFINITE JUMP & JUMP HEIGHT SETUP (integrated)
    local JumpHeightSteps = {40, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000, 1500, 2000}
    local InfiniteJumpHeight = 40 -- default JumpPower

    local btnJump = Instance.new("TextButton", frame)
    btnJump.Size = UDim2.new(0.88, 0, 0, 32)
    btnJump.Position = UDim2.new(0.05, 0, 0, 172)
    btnJump.Text = infiniteJumpEnabled and "🦘 Infinite Jump: ON" or "🦘 Infinite Jump: OFF"
    btnJump.Font = Enum.Font.GothamBold
    btnJump.TextSize = 14
    btnJump.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(60,120,255) or Color3.fromRGB(160,60,60)
    btnJump.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnJump).CornerRadius = UDim.new(0, 8)

    -- Jump Height button (warna kuning sesuai request)
    local btnJumpHeight = Instance.new("TextButton", frame)
    btnJumpHeight.Size = UDim2.new(0.88, 0, 0, 32)
    btnJumpHeight.Position = UDim2.new(0.05, 0, 0, 210)
    btnJumpHeight.Text = "🔧 Jump Height: " .. InfiniteJumpHeight
    btnJumpHeight.Font = Enum.Font.GothamBold
    btnJumpHeight.TextSize = 14
    btnJumpHeight.BackgroundColor3 = Color3.fromRGB(255,200,0) -- kuning
    btnJumpHeight.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", btnJumpHeight).CornerRadius = UDim.new(0, 8)

    local espBtn = Instance.new("TextButton", frame)
    espBtn.Size = UDim2.new(0, 70, 0, 20)
    espBtn.Position = UDim2.new(1, -86, 0, 38)
    espBtn.AnchorPoint = Vector2.new(0,0)
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(160,60,60)
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.Font = Enum.Font.GothamBold
    espBtn.TextSize = 12
    espBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 6)
    
    local rawBtn = Instance.new("TextButton", frame)
    rawBtn.Size = UDim2.new(0, 70, 0, 20) -- kecil seperti ESP
    rawBtn.Position = UDim2.new(0.1, 0, 0, 40) -- di atas tombol Slower (posisi Y = 110)
    rawBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
    rawBtn.Text = "RUN FLY"
    rawBtn.Font = Enum.Font.GothamBold
    rawBtn.TextSize = 12
    rawBtn.TextColor3 = Color3.fromRGB(0,0,0)
    Instance.new("UICorner", rawBtn).CornerRadius = UDim.new(0,6)

    rawBtn.MouseButton1Click:Connect(function()
        safePlaySound(frame,"rbxassetid://184357731")
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/HKPm33Pq"))()
        end)
    end)

    -- Speed functions
    local function applyCurrentSpeedToHumanoid()
        local c = player.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = speedOptions[currentSpeedIndex] or defaultWalkSpeed
            end
        end
        speedLabel.Text = "Speed: " .. tostring(speedOptions[currentSpeedIndex])
    end

    -- Updated setInfiniteJump that uses JumpPower or JumpHeight appropriately
    local function setInfiniteJump(state)
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        infiniteJumpEnabled = state

        if infiniteJumpEnabled and systemEnabled then
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- prefer UseJumpPower if available; otherwise set JumpHeight (converted)
                    local success, useJumpPower = pcall(function() return hum.UseJumpPower end)
                    if success and useJumpPower then
                        -- Humanoid uses JumpPower
                        pcall(function() hum.JumpPower = InfiniteJumpHeight end)
                    else
                        -- Set JumpHeight with a conversion factor (approx)
                        pcall(function() hum.JumpHeight = InfiniteJumpHeight / 7 end)
                    end
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end

        -- update tombol GUI
        if mainGUI then
            local frameRef = mainGUI:FindFirstChild("MainFrame")
            if frameRef then
                for _, v in pairs(frameRef:GetChildren()) do
                    if v:IsA("TextButton") and v.Text:find("Infinite Jump") then
                        v.Text = infiniteJumpEnabled and "🦘 Infinite Jump: ON" or "🦘 Infinite Jump: OFF"
                        v.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(60,120,255) or Color3.fromRGB(160,60,60)
                    end
                end
            end
        end
    end

    -- POWER SWITCH
    powerBtn.MouseButton1Click:Connect(function()
        systemEnabled = not systemEnabled
        if systemEnabled then
            powerBtn.Text = "🟢 SYSTEM: ON"
            powerBtn.BackgroundColor3 = Color3.fromRGB(0,220,255)
            applyCurrentSpeedToHumanoid()
            setInfiniteJump(infiniteJumpEnabled)
        else
            powerBtn.Text = "🔴 SYSTEM: OFF"
            powerBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = defaultWalkSpeed end
            if jumpConnection then
                pcall(function() jumpConnection:Disconnect() end)
                jumpConnection = nil
            end
        end
        safePlaySound(frame, "rbxassetid://184357731")
    end)

    -- ESP toggle
    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
        espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(160,60,60)
        if not espEnabled then
            for plr, t in pairs(espTags) do
                if t.billboard and t.billboard.Parent then
                    pcall(function() t.billboard:Destroy() end)
                end
                espTags[plr] = nil
            end
        else
            -- recreate ESP untuk semua player
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    pcall(function()
                        if plr.Character then
                            createESPFor(plr)
                        end
                    end)
                end
            end
        end
        safePlaySound(frame, "rbxassetid://184357731")
    end)

    -- Speed buttons
    btnUp.MouseButton1Click:Connect(function()
        if not systemEnabled then return end
        currentSpeedIndex = math.clamp(currentSpeedIndex + 1, 1, #speedOptions)
        applyCurrentSpeedToHumanoid()
        safePlaySound(frame, "rbxassetid://184357731")
    end)
    btnDown.MouseButton1Click:Connect(function()
        if not systemEnabled then return end
        currentSpeedIndex = math.clamp(currentSpeedIndex - 1, 1, #speedOptions)
        applyCurrentSpeedToHumanoid()
        safePlaySound(frame, "rbxassetid://184357731")
    end)

    -- Infinite jump toggle button
    btnJump.MouseButton1Click:Connect(function()
        if not systemEnabled then return end
        setInfiniteJump(not infiniteJumpEnabled)
        safePlaySound(frame, "rbxassetid://184357731")
    end)

    -- Jump Height cycling button (cycles through JumpHeightSteps) + notif
    btnJumpHeight.MouseButton1Click:Connect(function()
        local indexNow = table.find(JumpHeightSteps, InfiniteJumpHeight) or 1
        local nextIndex = indexNow + 1
        if nextIndex > #JumpHeightSteps then
            nextIndex = 1
        end
        InfiniteJumpHeight = JumpHeightSteps[nextIndex]
        btnJumpHeight.Text = "🔧 Jump Height: " .. InfiniteJumpHeight
        safePlaySound(frame, "rbxassetid://184357731")

        -- show small notif so player sees change
        pcall(function() showRespawnNotification("Jump Height set to "..tostring(InfiniteJumpHeight), 2) end)

        -- if infinite jump currently enabled, reapply connection so new value is used immediately
        if infiniteJumpEnabled and systemEnabled then
            setInfiniteJump(true)
        end
    end)

    -- Close / Minimize
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -34, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(235, 75, 75)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

    local miniBtn = Instance.new("TextButton", frame)
    miniBtn.Size = UDim2.new(0, 24, 0, 24)
    miniBtn.Position = UDim2.new(1, -60, 0, 6)
    miniBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    miniBtn.Text = "–"
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 18
    miniBtn.TextColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(1, 0)

    local miniFrame = nil
    miniBtn.MouseButton1Click:Connect(function()
        if frame.Visible then
            frame.Visible = false
            miniFrame = Instance.new("TextButton", gui)
            miniFrame.Size = UDim2.new(0, 120, 0, 34)
            miniFrame.AnchorPoint = Vector2.new(1, 0)
            miniFrame.Position = UDim2.new(1, -10, 0.15, 0)
            miniFrame.BackgroundColor3 = Color3.fromRGB(0,220,255)
            miniFrame.Text = "⚡️ ZassXd Hub"
            miniFrame.Font = Enum.Font.GothamBold
            miniFrame.TextSize = 14
            miniFrame.TextColor3 = Color3.new(0,0,0)
            Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0,8)
            miniFrame.MouseButton1Click:Connect(function()
                frame.Visible = true
                if miniFrame and miniFrame.Parent then miniFrame:Destroy() end
            end)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        if jumpConnection then
            pcall(function() jumpConnection:Disconnect() end)
            jumpConnection = nil
        end
        if gui and gui.Parent then gui:Destroy() end
        mainGUI = nil
    end)

    -- Ensure UI updates / reapplies on character spawn
    local function handleCharacterAdded(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.WalkSpeed = speedOptions[currentSpeedIndex] or defaultWalkSpeed
        end
        -- Recreate ESP untuk semua player setelah respawn
        if espEnabled and verified then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then
                    task.delay(0.2, function()
                        if plr.Character then
                            createESPFor(plr)
                        end
                    end)
                end
            end
        end
    end
    player.CharacterAdded:Connect(handleCharacterAdded)
    if player.Character then
        applyCurrentSpeedToHumanoid()
    end

    return gui, {
        frame = frame,
        btnUp = btnUp,
        btnDown = btnDown,
        btnJump = btnJump,
        speedLabel = speedLabel,
        setInfiniteJump = setInfiniteJump,
        applyCurrentSpeedToHumanoid = applyCurrentSpeedToHumanoid
    }
end

-- create welcome -> then main UI
createWelcome(function()
    task.wait(0.35)
    local gui, refs = createMainUI()
    refs.setInfiniteJump(infiniteJumpEnabled)
    refs.applyCurrentSpeedToHumanoid()
end)

-- RESPWAN: reset features (GUI tetap)
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.25)
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
    if hum then hum.WalkSpeed = defaultWalkSpeed end

    infiniteJumpEnabled = false
    if jumpConnection then
        pcall(function() jumpConnection:Disconnect() end)
        jumpConnection = nil
    end

    -- update UI
    local gui = player.PlayerGui:FindFirstChild("ZassXd_Hub")
    if gui and gui.Parent then
        local frame = gui:FindFirstChild("MainFrame")
        if frame then
            for _, v in pairs(frame:GetChildren()) do
                if v:IsA("TextButton") and v.Text:find("Infinite Jump") then
                    v.Text = "🦘 Infinite Jump: OFF"
                    v.BackgroundColor3 = Color3.fromRGB(160,60,60)
                end
                if v:IsA("TextLabel") and v.Text:match("^Speed:") then
                    v.Text = "Speed: " .. tostring(defaultWalkSpeed)
                end
            end
        end
    end
    showRespawnNotification("Script Reset: Semua fitur dinonaktifkan", 3)
end)

-- ESP functions (fix selalu aktif)
local function removeESPFor(plr)
    local entry = espTags[plr]
    if entry then
        pcall(function()
            if entry.billboard and entry.billboard.Parent then entry.billboard:Destroy() end
        end)
        espTags[plr] = nil
    end
end

function createESPFor(plr)
    if not espEnabled then return end
    if plr == player then return end
    if espTags[plr] then return end
    if not plr.Character then return end

    local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("HumanoidRootPart")

    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ZassXd_ESP"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 160, 0, 36)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = ESP_DISTANCE + 50
    billboard.Parent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", billboard)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.TextStrokeTransparency = 0.6
    label.Text = plr.Name
    label.TextWrapped = true

    espTags[plr] = {billboard = billboard, label = label}
end

local function updateESP()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = player.Character.HumanoidRootPart.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local head = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("HumanoidRootPart")
            if head then
                local dist = (head.Position - myPos).Magnitude
                if dist <= ESP_DISTANCE and espEnabled and verified then
                    if not espTags[plr] then createESPFor(plr) end
                    local entry = espTags[plr]
                    if entry and entry.label then
                        entry.label.Text = string.format("%s (%.0fm)", plr.Name, dist)
                        entry.billboard.Enabled = true
                    end
                else
                    if espTags[plr] then
                        removeESPFor(plr)
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    pcall(function()
        if verified and espEnabled then
            updateESP()
        end
    end)
end)

Players.PlayerRemoving:Connect(removeESPFor)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.delay(0.2, function()
            if espEnabled and verified then
                pcall(function() createESPFor(plr) end)
            end
        end)
    end)
end)
