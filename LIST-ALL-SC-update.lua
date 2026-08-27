-- ========================================================
-- NOTIFIKASI "SCRIPT SEDANG UPDATE" + TOMBOL CANCEL
-- Untuk: Executor (KRNL, Synapse, Arceus X, dll)
-- Cara pakai: Copy semua, paste di executor, Execute
-- ========================================================

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Hapus GUI lama jika sudah ada
local old = playerGui:FindFirstChild("UpdateNotifGui")
if old then old:Destroy() end

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UpdateNotifGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 210)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -105)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(126, 232, 154)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Garis atas (aksen warna)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 5)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(126, 232, 154)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

-- Icon + Judul
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 45)
titleLabel.Position = UDim2.new(0, 10, 0, 15)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚠️  Script Sedang Di-Update"
titleLabel.TextColor3 = Color3.fromRGB(126, 232, 154)
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

-- Pesan
local msgLabel = Instance.new("TextLabel")
msgLabel.Size = UDim2.new(1, -40, 0, 75)
msgLabel.Position = UDim2.new(0, 20, 0, 65)
msgLabel.BackgroundTransparency = 1
msgLabel.Text = "Maaf, script ini sedang dalam proses update.\nSilakan coba lagi beberapa saat lagi.\n\nTerima kasih atas pengertiannya! 🙏"
msgLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
msgLabel.TextSize = 15
msgLabel.Font = Enum.Font.Gotham
msgLabel.TextWrapped = true
msgLabel.TextXAlignment = Enum.TextXAlignment.Center
msgLabel.TextYAlignment = Enum.TextYAlignment.Top
msgLabel.Parent = mainFrame

-- Tombol Cancel
local cancelBtn = Instance.new("TextButton")
cancelBtn.Size = UDim2.new(0, 150, 0, 42)
cancelBtn.Position = UDim2.new(0.5, -75, 1, -58)
cancelBtn.BackgroundColor3 = Color3.fromRGB(210, 55, 55)
cancelBtn.Text = "✖  Cancel"
cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelBtn.TextSize = 17
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.AutoButtonColor = true
cancelBtn.Parent = mainFrame
Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 10)

-- Animasi muncul
local TweenService = game:GetService("TweenService")
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1

TweenService:Create(
    mainFrame,
    TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = UDim2.new(0, 400, 0, 210), BackgroundTransparency = 0 }
):Play()

-- Tombol Cancel: tutup GUI
cancelBtn.MouseButton1Click:Connect(function()
    local closeTween = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }
    )
    closeTween:Play()
    closeTween.Completed:Wait()
    screenGui:Destroy()
end)

print("[UpdateNotif] Notifikasi berhasil ditampilkan!")
