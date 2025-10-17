-- CHANGE YOUR AVATAR
-- Auto-detect avatar type, tanpa keycode, UI lengkap
-- Load avatar berdasarkan username dengan semua item (baju, aksesoris, dll)
-- UI Open/Close System dengan animasi smooth

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- UI State Management
local UIState = {
    isOpen = false,
    isAnimating = false
}

-- Toggle Button Creation Function
local function createToggleButton()
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 20, 0, 20)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = "🎮"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.ZIndex = 10
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 25)
    ToggleCorner.Parent = ToggleButton
    
    return ToggleButton
end

-- Clean and Organized UI Creation Function
local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RobloxAccountLoader"
    ScreenGui.Parent = lp.PlayerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Toggle Button
    local ToggleButton = createToggleButton()
    ToggleButton.Parent = ScreenGui
    
    -- Main Frame - Clean and organized (initially hidden)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 380, 0, 120)
    MainFrame.Position = UDim2.new(0.5, -190, 0.05, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false -- Initially hidden
    
    -- Main Frame Corner
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -20, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "🎮 CHANGE YOUR AVATAR"
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextScaled = true
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Username Input Section
    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "InputFrame"
    InputFrame.Size = UDim2.new(1, -20, 0, 35)
    InputFrame.Position = UDim2.new(0, 10, 0, 35)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = MainFrame
    
    -- Username Input
    local UsernameInput = Instance.new("TextBox")
    UsernameInput.Name = "UsernameInput"
    UsernameInput.Size = UDim2.new(0.7, -5, 1, 0)
    UsernameInput.Position = UDim2.new(0, 0, 0, 0)
    UsernameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    UsernameInput.BorderSizePixel = 0
    UsernameInput.Text = ""
    UsernameInput.PlaceholderText = "Enter username..."
    UsernameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    UsernameInput.TextScaled = true
    UsernameInput.Font = Enum.Font.Gotham
    UsernameInput.Parent = InputFrame
    
    local UsernameCorner = Instance.new("UICorner")
    UsernameCorner.CornerRadius = UDim.new(0, 8)
    UsernameCorner.Parent = UsernameInput
    
    -- Submit Button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Size = UDim2.new(0.3, -5, 1, 0)
    SubmitButton.Position = UDim2.new(0.7, 0, 0, 0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Text = "SUBMIT"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextScaled = true
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Parent = InputFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitButton
    
    -- Status Display Section
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Name = "StatusFrame"
    StatusFrame.Size = UDim2.new(1, -20, 0, 40)
    StatusFrame.Position = UDim2.new(0, 10, 0, 75)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    StatusFrame.BorderSizePixel = 0
    StatusFrame.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    -- Status Display
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(1, -10, 1, 0)
    StatusText.Position = UDim2.new(0, 5, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "✨ Ready to change avatar"
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusText.TextScaled = true
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextXAlignment = Enum.TextXAlignment.Center
    StatusText.Parent = StatusFrame
    
    return ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton
end

-- Advanced Avatar Loading Function
local function loadAvatar(username)
    if not username or username == "" then
        return false, "Username tidak boleh kosong!"
    end
    
    -- Get User ID
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    
    if not success then
        return false, "Username tidak ditemukan: " .. username
    end
    
    if not lp.Character then
        return false, "Character tidak ada!"
    end
    
    -- Get Humanoid Description
    local success2, humanoidDesc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success2 then
        return false, "Gagal mendapatkan avatar description"
    end
    
    -- Clear existing accessories first to prevent head glitches
    local success_clear = pcall(function()
        -- Remove all existing accessories
        for _, accessory in pairs(lp.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end
        
        -- Clear existing clothing
        for _, clothing in pairs(lp.Character:GetChildren()) do
            if clothing:IsA("Shirt") or clothing:IsA("Pants") or clothing:IsA("ShirtGraphic") then
                clothing:Destroy()
            end
        end
        
        -- Wait a moment for cleanup
        wait(0.1)
    end)
    
    if not success_clear then
        return false, "Gagal membersihkan avatar lama"
    end
    
    -- Auto-detect and apply avatar type
    local success3 = pcall(function()
        -- Apply the complete avatar description (includes all items)
        lp.Character.Humanoid:ApplyDescriptionClientServer(humanoidDesc)
        
        -- Wait for avatar to fully load
        wait(0.5)
    end)
    
    if not success3 then
        return false, "Gagal mengubah avatar"
    end
    
    return true, "Avatar berhasil diubah ke: " .. username
end

-- Reset Avatar Function
local function resetAvatar()
    if not lp.Character then
        return false, "Character tidak ada!"
    end
    
    local success = pcall(function()
        -- Reset to default avatar
        local defaultDesc = lp.Character.Humanoid.HumanoidDescription
        lp.Character.Humanoid:ApplyDescriptionClientServer(defaultDesc)
    end)
    
    if not success then
        return false, "Gagal reset avatar"
    end
    
    return true, "Avatar berhasil direset"
end

-- Respawn Character Function untuk memastikan avatar baru load sempurna
local function respawnCharacter()
    if not lp.Character then
        return false, "Character tidak ada!"
    end
    
    local success = pcall(function()
        -- Respawn character untuk memastikan avatar baru load sempurna
        lp.Character:BreakJoints()
        wait(1) -- Wait for respawn
    end)
    
    if not success then
        return false, "Gagal respawn character"
    end
    
    return true, "Character berhasil direspawn"
end

-- Animation Functions
local function animateUI(frame, isOpening)
    if UIState.isAnimating then return end
    
    UIState.isAnimating = true
    
    local targetSize, targetPosition, targetVisible
    
    if isOpening then
        targetSize = UDim2.new(0, 380, 0, 120)
        targetPosition = UDim2.new(0.5, -190, 0.05, 0)
        targetVisible = true
        frame.Visible = true
    else
        targetSize = UDim2.new(0, 0, 0, 0)
        targetPosition = UDim2.new(0.5, -190, 0.05, 0)
        targetVisible = false
    end
    
    local tweenInfo = TweenInfo.new(
        0.3, -- Duration
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out,
        0, -- RepeatCount
        false, -- Reverses
        0 -- DelayTime
    )
    
    local sizeTween = TweenService:Create(frame, tweenInfo, {Size = targetSize})
    local positionTween = TweenService:Create(frame, tweenInfo, {Position = targetPosition})
    
    sizeTween:Play()
    positionTween:Play()
    
    if not isOpening then
        sizeTween.Completed:Connect(function()
            frame.Visible = false
            UIState.isAnimating = false
        end)
    else
        sizeTween.Completed:Connect(function()
            UIState.isAnimating = false
        end)
    end
end

-- Toggle UI Function
local function toggleUI(mainFrame, toggleButton)
    if UIState.isAnimating then return end
    
    UIState.isOpen = not UIState.isOpen
    
    if UIState.isOpen then
        animateUI(mainFrame, true)
        toggleButton.Text = "❌"
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    else
        animateUI(mainFrame, false)
        toggleButton.Text = "🎮"
        toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end

-- Drag Function
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Main Script
local ScreenGui, MainFrame, UsernameInput, StatusText, ToggleButton, SubmitButton = createUI()

-- Make draggable
makeDraggable(MainFrame)

-- Toggle Button Functionality
ToggleButton.MouseButton1Click:Connect(function()
    toggleUI(MainFrame, ToggleButton)
end)

-- Hover Effects for Toggle Button
ToggleButton.MouseEnter:Connect(function()
    if not UIState.isOpen then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

ToggleButton.MouseLeave:Connect(function()
    if not UIState.isOpen then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

-- Submit Button Functionality
SubmitButton.MouseButton1Click:Connect(function()
    local username = UsernameInput.Text
    if username and username ~= "" then
        -- Show loading
        UsernameInput.PlaceholderText = "Loading avatar..."
        UsernameInput.Text = ""
        StatusText.Text = "⏳ Loading avatar..."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        local success, message = loadAvatar(username)
        
        if success then
            -- Update UI dengan success
            UsernameInput.PlaceholderText = "✓ Loaded: " .. username
            StatusText.Text = "✅ Avatar changed successfully!"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            -- Clear after 3 seconds
            wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "✨ Ready to change avatar"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        else
            UsernameInput.PlaceholderText = "✗ Error: " .. message
            StatusText.Text = "❌ Failed to load avatar"
            StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
            
            -- Clear after 3 seconds
            wait(3)
            UsernameInput.PlaceholderText = "Enter username..."
            StatusText.Text = "✨ Ready to change avatar"
            StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)

-- Hover Effects for Submit Button
SubmitButton.MouseEnter:Connect(function()
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
end)

SubmitButton.MouseLeave:Connect(function()
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)


-- Auto load avatar saat Enter ditekan
UsernameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local username = UsernameInput.Text
        if username and username ~= "" then
            -- Show loading
            UsernameInput.PlaceholderText = "Loading avatar..."
            UsernameInput.Text = ""
            StatusText.Text = "⏳ Loading avatar..."
            StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            local success, message = loadAvatar(username)
            
            if success then
                -- Update UI dengan success
                UsernameInput.PlaceholderText = "✓ Loaded: " .. username
                StatusText.Text = "✅ Avatar changed successfully!"
                StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                -- Clear after 3 seconds
                wait(3)
                UsernameInput.PlaceholderText = "Enter username... (Press Enter to load avatar)"
                StatusText.Text = "✨ Ready to change avatar"
                StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
            else
                UsernameInput.PlaceholderText = "✗ Error: " .. message
                StatusText.Text = "❌ Failed to load avatar"
                StatusText.TextColor3 = Color3.fromRGB(255, 0, 0)
                
                -- Clear after 3 seconds
                wait(3)
                UsernameInput.PlaceholderText = "Enter username... (Press Enter to load avatar)"
                StatusText.Text = "✨ Ready to change avatar"
                StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end
end)

-- Keyboard Shortcut untuk Toggle UI (F1)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        toggleUI(MainFrame, ToggleButton)
    end
end)

-- Auto-focus username input - DISABLED untuk menghindari gangguan layar
-- UsernameInput:CaptureFocus()

print("=== CHANGE YOUR AVATAR - TOGGLE UI ===")
print("✓ UI rapi dan terorganisir")
print("✓ Toggle button dengan animasi smooth")
print("✓ Keyboard shortcut F1 untuk toggle")
print("✓ Submit button untuk Android/mobile")
print("✓ Enter key support untuk PC")
print("✓ Title bar dengan branding")
print("✓ Input section yang clean")
print("✓ Status display yang informatif")
print("✓ Auto-detect avatar type")
print("✓ Bersihkan kepala bekas avatar")
print("✓ Hover effects pada semua button")
print("✓ Mobile-friendly design")
print("===============================")
