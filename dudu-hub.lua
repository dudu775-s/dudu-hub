local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🔥 Fling Nuclear Hub",
    LoadingTitle = "Carregando Fling Nuclear...",
    LoadingSubtitle = "Versão mais forte",
    ConfigurationSaving = { Enabled = true, FolderName = "NuclearFling", FileName = "Config" }
})

local MainTab = Window:CreateTab("Main", 4483362458)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local ESPHighlights = {}
local FlingTarget = nil
local AutoFling = false

-- ==================== ESP HIGHLIGHTS ====================
local function CreateESP(plr)
    if ESPHighlights[plr] or plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 100)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    ESPHighlights[plr] = highlight
end

local function UpdateESP()
    for _, plr in Players:GetPlayers() do
        if plr \~= LocalPlayer then
            if plr.Character then
                CreateESP(plr)
            end
        end
    end
end

-- ==================== ANTI FLING (Forte) ====================
local AntiFlingEnabled = false
local function AntiFling()
    if not AntiFlingEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Velocity = Vector3.new(0,0,0)
            part.RotVelocity = Vector3.new(0,0,0)
            part.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
    end
end

-- ==================== ANTI SIT ====================
local AntiSitEnabled = false
local function AntiSit()
    if not AntiSitEnabled then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.Sit = false
        hum.PlatformStand = false
    end
end

-- ==================== FLING NUCLEAR (Mais Forte) ====================
local function NuclearFling(target)
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHum = LocalPlayer.Character:FindFirstChild("Humanoid")
    
    if not targetRoot or not myRoot or not myHum then return end

    local originalCFrame = myRoot.CFrame
    
    myHum.PlatformStand = true
    
    -- Posicionamento + impulso nuclear
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(0, math.rad(180), 0)
    
    task.wait(0.07)

    -- BodyVelocity
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = (targetRoot.Position - myRoot.Position).Unit * 650 + Vector3.new(0, 120, 0)
    bv.Parent = myRoot

    -- AssemblyLinearVelocity (mais forte)
    local alv = Instance.new("AssemblyLinearVelocity")
    alv.MaxForce = math.huge
    alv.VectorVelocity = bv.Velocity * 2.2
    alv.Parent = myRoot

    -- Extra force
    myRoot.AssemblyLinearVelocity = alv.VectorVelocity

    task.wait(0.4)

    bv:Destroy()
    alv:Destroy()
    myHum.PlatformStand = false
    myRoot.CFrame = originalCFrame
end

-- ==================== UI ====================

MainTab:CreateToggle({
    Name = "ESP Highlights",
    CurrentValue = true,
    Callback = function(v)
        if v then
            UpdateESP()
        else
            for _, h in pairs(ESPHighlights) do h:Destroy() end
            ESPHighlights = {}
        end
    end
})

MainTab:CreateToggle({
    Name = "Anti Fling (Proteção)",
    CurrentValue = false,
    Callback = function(v) AntiFlingEnabled = v end
})

MainTab:CreateToggle({
    Name = "Anti Sit",
    CurrentValue = false,
    Callback = function(v) AntiSitEnabled = v end
})

MainTab:CreateDropdown({
    Name = "Selecionar Alvo",
    Options = (function()
        local list = {}
        for _, p in Players:GetPlayers() do
            if p \~= LocalPlayer then table.insert(list, p.Name) end
        end
        return list
    end)(),
    Callback = function(opt)
        FlingTarget = Players:FindFirstChild(opt[1])
    end
})

MainTab:CreateButton({
    Name = "🚀 Nuclear Fling (Único)",
    Callback = function()
        if FlingTarget then NuclearFling(FlingTarget) end
    end
})

MainTab:CreateToggle({
    Name = "Auto Nuclear Fling",
    CurrentValue = false,
    Callback = function(v)
        AutoFling = v
        while AutoFling and FlingTarget do
            NuclearFling(FlingTarget)
            task.wait(0.55)
        end
    end
})

MainTab:CreateButton({
    Name = "Fling Todos (Cuidado)",
    Callback = function()
        for _, plr in Players:GetPlayers() do
            if plr \~= LocalPlayer and plr.Character then
                task.spawn(function()
                    NuclearFling(plr)
                end)
            end
        end
    end
})

-- Atualizações em loop
RunService.Heartbeat:Connect(function()
    AntiFling()
    AntiSit()
    UpdateESP()
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(1) UpdateESP() end)
end)

Rayfield:Notify({
    Title = "Nuclear Fling Carregado",
    Content = "Versão mais forte disponível.",
    Duration = 6
})
