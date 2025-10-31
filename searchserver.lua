local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local placeId = game.PlaceId

-- === GUI CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerFinder"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 220)
frame.Position = UDim2.new(0.5, -175, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🛰️ Server Finder"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 50)
infoLabel.Position = UDim2.new(0, 10, 0, 40)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextScaled = true
infoLabel.TextWrapped = true
infoLabel.Text = "Klik 'Cari Server Sepi' untuk menemukan server dengan pemain paling sedikit."
infoLabel.Parent = frame

local findButton = Instance.new("TextButton")
findButton.Size = UDim2.new(0, 140, 0, 40)
findButton.Position = UDim2.new(0.5, -70, 0, 100)
findButton.Text = "🔍 Cari Server Sepi"
findButton.Font = Enum.Font.GothamBold
findButton.TextScaled = true
findButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
findButton.TextColor3 = Color3.fromRGB(255, 255, 255)
findButton.Parent = frame

local joinButton = Instance.new("TextButton")
joinButton.Size = UDim2.new(0, 140, 0, 40)
joinButton.Position = UDim2.new(0.5, -70, 0, 160)
joinButton.Text = "🚀 Join Server"
joinButton.Font = Enum.Font.GothamBold
joinButton.TextScaled = true
joinButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
joinButton.Visible = false
joinButton.Parent = frame

-- === FIND SERVER ===
local lowestServerId = nil
local lowestPlayerCount = math.huge

local function findLowestServer()
	infoLabel.Text = "🔍 Mencari server dengan pemain paling sedikit..."
	findButton.Active = false
	findButton.Text = "⏳ Sedang mencari..."

	local cursor = ""
	while true do
		local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor ~= "" and "&cursor="..cursor or "")
		local success, response = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if success and response and response.data then
			for _, server in ipairs(response.data) do
				if server.playing < lowestPlayerCount and server.id ~= game.JobId then
					lowestServerId = server.id
					lowestPlayerCount = server.playing
				end
			end
			if response.nextPageCursor then
				cursor = response.nextPageCursor
			else
				break
			end
		else
			break
		end
		task.wait(0.2)
	end

	if lowestServerId then
		infoLabel.Text = "✅ Server ditemukan!\nPemain: "..lowestPlayerCount.." orang"
		joinButton.Visible = true
	else
		infoLabel.Text = "❌ Tidak dapat menemukan server lain."
	end

	findButton.Active = true
	findButton.Text = "🔍 Cari Server Sepi"
end

findButton.MouseButton1Click:Connect(findLowestServer)

-- === JOIN SERVER ===
joinButton.MouseButton1Click:Connect(function()
	if lowestServerId then
		infoLabel.Text = "🚀 Bergabung ke server..."
		TeleportService:TeleportToPlaceInstance(placeId, lowestServerId, localPlayer)
	else
		infoLabel.Text = "❌ Server tidak ditemukan!"
	end
end)
