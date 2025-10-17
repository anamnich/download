-- 💠 ZassXd FPS Booster Modular Version
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- ================= SETTINGS =================
if not _G.Settings then
    _G.Settings = {
        Graphics = {
            FPS = 120,
            QualityLevel = 1,
            MeshPartDetail = 1,
            WaterQuality = 0,
            RemoveSky = true,
            RemoveAtmosphere = true,
            RemoveClouds = true
        },
        Optimizations = {
            RemoveClothing = true,
            RemoveAccessories = true,
            RemoveParticles = true,
            RemoveEffects = true,
            RemoveTextures = true,
            RemoveMeshes = false,
            RemoveExplosions = true,
            RemovePostEffects = true,
            RemoveLights = true,
            RemoveDecals = true
        },
        Notifications = true
    }
end

-- ================= NOTIFICATIONS =================
local function showNotification(title, text, duration)
    if not _G.Settings.Notifications then return end
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5,
        Button1 = "Okay"
    })
end

-- ================= GRAPHICS OPTIMIZATION =================
local function optimizeGraphics()
    showNotification("FPS Booster", "Starting graphics optimizations...", 2)
    task.wait(0.5)

    -- Set FPS (executor dependent)
    pcall(function()
        if setfpscap then
            setfpscap(_G.Settings.Graphics.FPS)
            showNotification("FPS Booster", "FPS set to ".._G.Settings.Graphics.FPS, 2)
        else
            showNotification("FPS Booster", "FPS cap not supported by executor.", 2)
        end
    end)
    task.wait(0.5)

    -- Rendering settings
    settings().Rendering.QualityLevel = _G.Settings.Graphics.QualityLevel
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    task.wait(0.5)

    -- Lighting
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd = 9e9
    task.wait(0.5)

    -- Terrain
    if Terrain then
        Terrain.WaterWaveSize = _G.Settings.Graphics.WaterQuality
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
        pcall(sethiddenproperty, Terrain, "Decoration", false)
        task.wait(0.5)
    end

    -- Remove Sky, Atmosphere, Clouds
    if _G.Settings.Graphics.RemoveSky then
        for _, obj in pairs(Lighting:GetDescendants()) do
            if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                obj:Destroy()
            end
        end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Sky") or obj:IsA("Atmosphere") or obj:IsA("Clouds") then
                obj:Destroy()
            end
        end
        task.wait(0.5)
    end
end

-- ================= INSTANCE OPTIMIZATION =================
local function optimizeInstance(instance)
    if not instance then return end

    -- Clothing & Accessories
    if _G.Settings.Optimizations.RemoveClothing and (instance:IsA("Clothing") or instance:IsA("SurfaceAppearance")) then
        instance:Destroy()
        return
    end

    -- Particles & Effects
    if _G.Settings.Optimizations.RemoveParticles and (instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles")) then
        instance.Enabled = false
        return
    end

    -- Textures & Meshes
    if _G.Settings.Optimizations.RemoveTextures and instance:IsA("Texture") then
        instance.Transparency = 1
        return
    end
    if _G.Settings.Optimizations.RemoveMeshes and instance:IsA("SpecialMesh") then
        instance.MeshId = ""
        return
    end

    -- Explosions
    if _G.Settings.Optimizations.RemoveExplosions and instance:IsA("Explosion") then
        instance.BlastPressure = 1
        instance.BlastRadius = 1
        instance.Visible = false
        return
    end

    -- Post Effects
    if _G.Settings.Optimizations.RemovePostEffects and instance:IsA("PostEffect") then
        instance.Enabled = false
        return
    end

    -- Lights
    if _G.Settings.Optimizations.RemoveLights and (instance:IsA("SpotLight") or instance:IsA("PointLight") or instance:IsA("SurfaceLight")) then
        instance.Enabled = false
        instance:Destroy()
        return
    end

    -- Beams
    if _G.Settings.Optimizations.RemoveEffects and instance:IsA("Beam") then
        instance.Enabled = false
        return
    end

    -- Decals
    if _G.Settings.Optimizations.RemoveDecals and instance:IsA("Decal") then
        instance.Transparency = 1
        instance:Destroy()
        return
    end

    -- Base Parts
    if instance:IsA("BasePart") then
        instance.Material = Enum.Material.Plastic
        instance.Reflectance = 0
    end

    -- Sky, Atmosphere, Clouds
    if _G.Settings.Graphics.RemoveSky and (instance:IsA("Sky") or instance:IsA("Atmosphere") or instance:IsA("Clouds")) then
        instance:Destroy()
        return
    end
end

-- ================= AUDIO OPTIMIZATION =================
local function optimizeAudio()
    showNotification("FPS Booster", "Removing audio...", 2)
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound:Stop()
            sound.Volume = 0
        end
    end
end

-- ================= INITIALIZE =================
local function initialize()
    optimizeAudio()
    task.wait(2)
    showNotification("FPS Booster", "Loading FPS Booster...", math.huge)
    task.wait(3)

    local success, err = pcall(function()
        optimizeGraphics()

        showNotification("FPS Booster", "Optimizing existing objects...", 2)
        for _, instance in pairs(game:GetDescendants()) do
            optimizeInstance(instance)
        end
        task.wait(0.5)

        showNotification("FPS Booster", "Monitoring new objects...", 2)
        game.DescendantAdded:Connect(optimizeInstance)
        task.wait(0.5)

        showNotification("FPS Booster", "Optimizations completed!", 2)
        task.wait(2)

        showNotification("FPS Booster", "ZassXd", math.huge)
    end)

    if not success then
        showNotification("FPS Booster", "Script Failed: "..err, 5)
    end
end

-- ================= START =================
initialize()
