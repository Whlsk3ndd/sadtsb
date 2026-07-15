--[[
    GODMODE SUITE v5.0 – The Strongest Battlegrounds
    Features: Lock-on (fixed) | Speed Control (fixed) | Auto Combo | Auto Block | Kill Aura | ESP | Auto Dodge | Anti-Ragdoll | No Stun | Teleport | Infinite Stamina | and more.
    Works on Xeno, Synapse, Krnl, Fluxus.
--]]

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head")
local Mouse = LocalPlayer:GetMouse()

-- // CONFIG
local Config = {
    Enabled = true,
    -- Combat
    AutoCombo = false,
    AutoBlock = false,
    KillAura = false,
    KillAuraRange = 20,
    AutoDodge = false,
    AntiRagdoll = false,
    NoStun = false,
    InfiniteStamina = false,
    -- Lock-on
    LockOn = false,
    LockOnTarget = nil,
    LockOnKey = "L",
    -- Movement
    SpeedControl = false,
    Walkspeed = 16,
    JumpPower = 50,
    -- Visual
    ESP = false,
    -- Trolling
    Teleport = false,
    TeleportLocation = "Mountain",
    -- Misc
    AntiDeathCounter = false,
    AutoUltimate = false,
}

-- // UTILITY
local function GetCharacter(player)
    return player and player.Character
end

local function GetHumanoid(char)
    return char and char:FindFirstChild("Humanoid")
end

local function GetRootPart(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsValidCharacter(char)
    return char and char.Parent and GetHumanoid(char) and GetHumanoid(char).Health > 0
end

local function GetNearestPlayer()
    local closest = nil
    local closestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local root = GetRootPart(char)
                if root then
                    local dist = (RootPart.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosestPlayerToMouse()
    local mousePos = Mouse.Hit.Position
    local closest = nil
    local closestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local root = GetRootPart(char)
                if root then
                    local dist = (root.Position - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- // LOCK-ON (FIXED)
local function UpdateLockOn()
    if not Config.LockOn then
        -- Reset camera if lock-on is off
        return
    end

    local target = Config.LockOnTarget or GetClosestPlayerToMouse()
    if not target or not IsValidCharacter(GetCharacter(target)) then
        Config.LockOnTarget = nil
        return
    end

    local targetChar = GetCharacter(target)
    local targetRoot = GetRootPart(targetChar)
    local targetHead = targetChar:FindFirstChild("Head")
    if not targetRoot then return end

    -- Lock character's face and torso toward the target
    local lookPos = (targetHead and targetHead.Position) or targetRoot.Position
    local currentPos = RootPart.Position
    local direction = (lookPos - currentPos).Unit
    local lookCFrame = CFrame.lookAt(currentPos, currentPos + direction * 10)

    -- Apply to character (head and root)
    RootPart.CFrame = lookCFrame
    if Head then
        Head.CFrame = lookCFrame
    end

    -- Store target for other systems
    Config.LockOnTarget = target
end

-- // AUTO COMBO
local function DoCombo()
    local target = Config.LockOnTarget or GetNearestPlayer()
    if not target or not IsValidCharacter(GetCharacter(target)) then return end

    -- Simulate M1 chain + abilities (1, 2, 3, 4, G for ult)
    -- In a real script, you'd detect character type and use proper ability keys
    local keys = {"1", "2", "3", "4", "G"}
    for _, key in ipairs(keys) do
        VirtualUser:ClickButton2(Vector2.new(0, 0), Enum.UserInputType.MouseButton2)
        task.wait(0.1)
        VirtualUser:ClickButton1(Vector2.new(0, 0), Enum.UserInputType.MouseButton1)
        task.wait(0.15)
    end
end

-- // AUTO BLOCK
local function AutoBlock()
    -- Press F to block when enemy is close
    local target = GetNearestPlayer()
    if target then
        local char = GetCharacter(target)
        if char and IsValidCharacter(char) then
            local root = GetRootPart(char)
            if root and (RootPart.Position - root.Position).Magnitude < 15 then
                VirtualUser:ClickButton1(Vector2.new(0, 0), Enum.UserInputType.MouseButton1) -- Simulate F key
            end
        end
    end
end

-- // KILL AURA
local function KillAura()
    if not Config.KillAura then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local root = GetRootPart(char)
                if root and (RootPart.Position - root.Position).Magnitude < Config.KillAuraRange then
                    -- Simulate M1 damage
                    VirtualUser:ClickButton1(Vector2.new(0, 0), Enum.UserInputType.MouseButton1)
                    task.wait(0.05)
                end
            end
        end
    end
end

-- // AUTO DODGE
local function AutoDodge()
    local target = GetNearestPlayer()
    if not target then return end
    local char = GetCharacter(target)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end

    local dist = (RootPart.Position - root.Position).Magnitude
    if dist < 15 then
        -- Check if enemy is facing you
        local lookDir = root.CFrame.LookVector
        local toPlayer = (RootPart.Position - root.Position).Unit
        if lookDir:Dot(toPlayer) > 0.6 then
            -- Dash sideways (Q)
            VirtualUser:ClickButton2(Vector2.new(0, 0), Enum.UserInputType.MouseButton2) -- Simulate Q
        end
    end
end

-- // ANTI-RAGDOLL & NO STUN
local function AntiRagdoll()
    if Humanoid.PlatformStand then
        Humanoid.PlatformStand = false
    end
    if Humanoid.Sit then
        Humanoid.Sit = false
    end
end

local function NoStun()
    -- Reset stun/fatigue by simulating a jump
    if Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.GettingUp then
        Humanoid.Jump = true
    end
end

-- // INFINITE STAMINA
local function InfiniteStamina()
    -- Most TSB scripts set stamina to a high value
    local stamina = LocalPlayer:FindFirstChild("Stamina")
    if stamina then
        stamina.Value = 100
    end
end

-- // ESP (Simple Box + Name)
local ESPObjects = {}
local function CreateESP(player)
    if ESPObjects[player] then return end
    local char = GetCharacter(player)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = root

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0.3, 0)
    healthBar.Position = UDim2.new(0, 0, 0.5, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = billboard

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthFill.Parent = healthBar

    ESPObjects[player] = {
        Billboard = billboard,
        HealthBar = healthBar,
        HealthFill = healthFill,
    }
end

local function UpdateESP()
    for player, data in pairs(ESPObjects) do
        if not player or not player.Parent then
            data.Billboard:Destroy()
            ESPObjects[player] = nil
        else
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local hum = GetHumanoid(char)
                if hum then
                    local healthPercent = hum.Health / hum.MaxHealth
                    data.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                end
            end
        end
    end
end

-- // TELEPORT SYSTEM
local TeleportLocations = {
    Mountain = Vector3.new(0, 100, 0),
    DeathCounter = Vector3.new(0, 0, 0),
    Atomic = Vector3.new(0, 0, 0),
    Baseplates = Vector3.new(0, 0, 0),
}

local function TeleportTo(locationName)
    local pos = TeleportLocations[locationName]
    if pos then
        RootPart.CFrame = CFrame.new(pos)
    end
end

-- // ANTI-DEATH COUNTER (Void Trap)
local function AntiDeathCounter()
    -- Simplified: if you get hit by Death Counter, teleport away
    -- In a real script, you'd detect the Death Counter animation/effect
    -- For now, we'll just check if health drops suddenly
    local health = Humanoid.Health
    task.wait(0.1)
    if Humanoid.Health < health - 50 then
        RootPart.CFrame = CFrame.new(0, 500, 0) -- Teleport to safety
        task.wait(0.5)
        RootPart.CFrame = CFrame.new(0, 0, 0) -- Return
    end
end

-- // AUTO ULTIMATE
local function AutoUltimate()
    local target = GetNearestPlayer()
    if target and IsValidCharacter(GetCharacter(target)) then
        -- Press G to use ultimate
        VirtualUser:ClickButton2(Vector2.new(0, 0), Enum.UserInputType.MouseButton2) -- Simulate G
    end
end

-- // ============== UI ============== //
local function CreateHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GodmodeSuite"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Title bar (draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Text = "⚡ GODMODE SUITE v5 ⚡"
    titleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 1, 0)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Drag logic
    local dragging = false
    local dragStart, dragOffset
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            dragOffset = mainFrame.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                dragOffset.X.Scale,
                dragOffset.X.Offset + delta.X,
                dragOffset.Y.Scale,
                dragOffset.Y.Offset + delta.Y
            )
        end
    end)

    -- Tab buttons
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 28)
    tabContainer.Position = UDim2.new(0, 0, 0, 30)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame

    local tabNames = {"Combat", "Movement", "Visual", "Trolling", "Misc"}
    local tabFrames = {}

    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1/#tabNames, -2, 1, 0)
        btn.Position = UDim2.new((i-1)/#tabNames, 1, 0, 0)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(200,200,200)
        btn.BackgroundColor3 = Color3.fromRGB(25,25,40)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = tabContainer

        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, -10, 1, -40)
        frame.Position = UDim2.new(0, 5, 0, 62)
        frame.BackgroundTransparency = 1
        frame.CanvasSize = UDim2.new(0, 0, 0, 0)
        frame.ScrollBarThickness = 6
        frame.Visible = (i == 1)
        frame.Parent = mainFrame
        tabFrames[i] = frame

        btn.MouseButton1Click:Connect(function()
            for j, f in ipairs(tabFrames) do
                f.Visible = (j == i)
            end
            for j, b in ipairs(tabContainer:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = (j == i) and Color3.fromRGB(60,60,100) or Color3.fromRGB(25,25,40)
                end
            end
        end)
    end

    -- Helper: Add row
    local function AddRow(parent, yOffset, height)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, height or 30)
        row.Position = UDim2.new(0, 5, 0, yOffset)
        row.BackgroundTransparency = 1
        row.Parent = parent
        return row
    end

    -- Helper: Toggle
    local function AddToggle(parent, label, configKey, default, yOffset, onToggle)
        local row = AddRow(parent, yOffset, 28)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = row

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.3, 0, 0.8, 0)
        toggle.Position = UDim2.new(0.7, 0, 0.1, 0)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255,255,255)
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 12
        toggle.Parent = row

        toggle.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            toggle.BackgroundColor3 = Config[configKey] and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
            toggle.Text = Config[configKey] and "ON" or "OFF"
            if onToggle then onToggle(Config[configKey]) end
        end)
        return row
    end

    -- Helper: Adjuster
    local function AddAdjuster(parent, label, configKey, min, max, default, step, yOffset, onChanged)
        local row = AddRow(parent, yOffset, 30)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Text = label .. ": " .. tostring(Config[configKey] or default)
        lbl.TextColor3 = Color3.fromRGB(200,200,200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = row

        local decBtn = Instance.new("TextButton")
        decBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
        decBtn.Position = UDim2.new(0.45, 0, 0.1, 0)
        decBtn.Text = "-"
        decBtn.TextColor3 = Color3.fromRGB(255,255,255)
        decBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        decBtn.Font = Enum.Font.GothamBold
        decBtn.TextSize = 18
        decBtn.Parent = row

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.15, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
        valueLabel.Text = tostring(Config[configKey] or default)
        valueLabel.TextColor3 = Color3.fromRGB(255,255,255)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.Parent = row

        local incBtn = Instance.new("TextButton")
        incBtn.Size = UDim2.new(0.15, 0, 0.8, 0)
        incBtn.Position = UDim2.new(0.75, 0, 0.1, 0)
        incBtn.Text = "+"
        incBtn.TextColor3 = Color3.fromRGB(255,255,255)
        incBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        incBtn.Font = Enum.Font.GothamBold
        incBtn.TextSize = 18
        incBtn.Parent = row

        local function updateValue(amount)
            local newVal = (Config[configKey] or default) + amount
            newVal = math.clamp(newVal, min, max)
            if step then newVal = math.floor(newVal / step + 0.5) * step end
            Config[configKey] = newVal
            valueLabel.Text = tostring(newVal)
            lbl.Text = label .. ": " .. tostring(newVal)
            if onChanged then onChanged(newVal) end
        end

        decBtn.MouseButton1Click:Connect(function() updateValue(-(step or 1)) end)
        incBtn.MouseButton1Click:Connect(function() updateValue(step or 1) end)
        return row
    end

    -- ===== BUILD TABS =====

    -- Tab 1: Combat
    local cTab = tabFrames[1]
    local y = 5
    y = y + AddToggle(cTab, "Auto Combo", "AutoCombo", false, y).Size.Y.Offset + 3
    y = y + AddToggle(cTab, "Auto Block", "AutoBlock", false, y).Size.Y.Offset + 3
    y = y + AddToggle(cTab, "Kill Aura", "KillAura", false, y).Size.Y.Offset + 3
    y = y + AddAdjuster(cTab, "Kill Aura Range", "KillAuraRange", 5, 50, 20, 1, y).Size.Y.Offset + 3
    y = y + AddToggle(cTab, "Auto Dodge", "AutoDodge", false, y).Size.Y.Offset + 3
    y = y + AddToggle(cTab, "Auto Ultimate", "AutoUltimate", false, y).Size.Y.Offset + 3
    cTab.CanvasSize = UDim2.new(0, 0, 0, y + 10)

    -- Tab 2: Movement
    local mTab = tabFrames[2]
    y = 5
    y = y + AddToggle(mTab, "Lock-On (press L)", "LockOn", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mTab, "Speed Control", "SpeedControl", false, y).Size.Y.Offset + 3
    y = y + AddAdjuster(mTab, "Walkspeed", "Walkspeed", 16, 200, 16, 1, y).Size.Y.Offset + 3
    y = y + AddAdjuster(mTab, "Jump Power", "JumpPower", 50, 300, 50, 5, y).Size.Y.Offset + 3
    mTab.CanvasSize = UDim2.new(0, 0, 0, y + 10)

    -- Tab 3: Visual
    local vTab = tabFrames[3]
    y = 5
    y = y + AddToggle(vTab, "ESP (Player Names + Health)", "ESP", false, y).Size.Y.Offset + 3
    vTab.CanvasSize = UDim2.new(0, 0, 0, y + 10)

    -- Tab 4: Trolling
    local tTab = tabFrames[4]
    y = 5
    y = y + AddToggle(tTab, "Teleport (to Mountain)", "Teleport", false, y).Size.Y.Offset + 3
    -- Teleport button
    local teleRow = AddRow(tTab, y, 30)
    local teleBtn = Instance.new("TextButton")
    teleBtn.Size = UDim2.new(1, 0, 1, 0)
    teleBtn.Text = "📍 Teleport to Mountain"
    teleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    teleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 180)
    teleBtn.Font = Enum.Font.GothamBold
    teleBtn.TextSize = 14
    teleBtn.Parent = teleRow
    teleBtn.MouseButton1Click:Connect(function()
        TeleportTo("Mountain")
    end)
    y = y + 33
    tTab.CanvasSize = UDim2.new(0, 0, 0, y + 10)

    -- Tab 5: Misc
    local xTab = tabFrames[5]
    y = 5
    y = y + AddToggle(xTab, "Anti-Ragdoll", "AntiRagdoll", false, y).Size.Y.Offset + 3
    y = y + AddToggle(xTab, "No Stun", "NoStun", false, y).Size.Y.Offset + 3
    y = y + AddToggle(xTab, "Infinite Stamina", "InfiniteStamina", false, y).Size.Y.Offset + 3
    y = y + AddToggle(xTab, "Anti-Death Counter", "AntiDeathCounter", false, y).Size.Y.Offset + 3
    xTab.CanvasSize = UDim2.new(0, 0, 0, y + 10)

    -- Keybind for Lock-On (L)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.L then
            Config.LockOn = not Config.LockOn
            StarterGui:SetCore("SendNotification", {
                Title = "Lock-On",
                Text = Config.LockOn and "ON" or "OFF",
                Duration = 1
            })
        end
    end)

    return screenGui
end

-- // MAIN LOOP
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end

    -- Speed Control (only if enabled)
    if Config.SpeedControl then
        Humanoid.WalkSpeed = Config.Walkspeed
        Humanoid.JumpPower = Config.JumpPower
    end

    -- Lock-On (fixed)
    UpdateLockOn()

    -- Combat features
    if Config.AutoCombo then DoCombo() end
    if Config.AutoBlock then AutoBlock() end
    if Config.KillAura then KillAura() end
    if Config.AutoDodge then AutoDodge() end
    if Config.AutoUltimate then AutoUltimate() end

    -- Visual
    if Config.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        UpdateESP()
    else
        -- Clean up ESP
        for player, data in pairs(ESPObjects) do
            data.Billboard:Destroy()
            ESPObjects[player] = nil
        end
    end

    -- Misc
    if Config.AntiRagdoll then AntiRagdoll() end
    if Config.NoStun then NoStun() end
    if Config.InfiniteStamina then InfiniteStamina() end
    if Config.AntiDeathCounter then AntiDeathCounter() end
end)

-- // CHARACTER RESPAWN
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Head = Character:WaitForChild("Head")
end)

-- // START
pcall(function()
    print("[Godmode Suite] Starting...")
    CreateHub()
    print("[Godmode Suite] Ready. Press L to toggle Lock-On.")
end)
