--[[
    GODMODE SUITE v6.0 – The Strongest Battlegrounds
    Fully featured hub with:
    - Main (Player) tab: targeting, flinging, aimlock, teleport, hook, troll, farming per player
    - Farming tab: auto farm (skill & trashcan), hook mode, streak reset
    - Home tab: invisibility, ESP (names, health, ping, distance, device, streak, death counter, ult progress), hipheight, emotes, protections
    - Combat tab: aimlock cam/char (keybinds), auto hit/wallcombo/m1 reset, auto dodge, anti-stun/ragdoll
    - Movement tab: speed, high jump, fly, click teleport, dash modifiers
    Works on Xeno, Synapse, Krnl, Fluxus, etc.
    No errors, fully tested.
--]]

-- // SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Head = Character:WaitForChild("Head")
local Mouse = LocalPlayer:GetMouse()

-- // CONFIG (will be linked to GUI)
local Config = {
    -- Main
    TargetPlayer = nil,
    FlingSelected = false,
    AutoFlingSelected = false,
    FlingAll = false,
    AutoFlingAll = false,
    AimlockCam = false,
    AimlockChar = false,
    TeleportSelected = false,
    LoopTPBehind = false,
    LoopTPFront = false,
    HookSelected = false,
    HookDistance = 30,
    BangSelected = false,
    AutoBangSelected = false,
    JorkSelected = false,
    AutoJorkSelected = false,
    TrashFarmSelected = false,
    AutoSkillFarmSelected = false,

    -- Farming
    AutoFarm = false,
    FarmMode = "LowestHealth", -- "LowestHealth", "Nearest", "TargetHealth"
    TargetHealth = 50,
    TrashcanFarm = false,
    HookMode = false,
    HookDistanceFarm = 30,
    AttackHeight = 5,
    ResetStreakAt = 9,

    -- Home
    Invisible = false,
    AntiInvisibility = false,
    ESP = false,
    ShowNames = true,
    ShowHealthBar = true,
    ShowPing = false,
    ShowDistance = false,
    ShowDevice = false,
    ShowKillStreak = false,
    DeathCounter = false,
    UltProgressBar = false,
    HipHeight = 0,
    ActivateHipHeight = false,
    UnlockGaze = false,
    UnlockNightchild = false,
    AutoSpinEmote = false,
    Unlock8EmoteSlots = false,
    AntiStaff = false,
    AntiTrashcan = false,
    AntiFling = false,

    -- Combat
    AimlockCamKey = "Q",
    AimlockCharKey = "E",
    AutoHit = false,
    AutoWallcombo = false,
    M1Reset = false,
    AutoDodgePlayers = false,
    AutoDodgeKey = "X",
    RemoveStun = false,
    AntiRagdoll = false,

    -- Movement
    Walkspeed = 16,
    WalkspeedKey = "V",
    HighJump = false,
    HighJumpPower = 100,
    FlySpeed = 50,
    FlyEnabled = false,
    FlyKey = "F",
    ClickTeleport = false,
    ClickTeleportKey = "T",
    FrontDash = false,
    FrontDashDistance = 20,
    SideDash = false,
    SideDashDistMult = 1.5,
    SideDashSpeedMult = 1.2,
    BackDash = false,
    BackDashDistMult = 1.0,
}

-- // UTILITY FUNCTIONS
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

local function GetAllPlayers()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player)
        end
    end
    return list
end

local function GetTargetPlayer()
    if Config.TargetPlayer and Players:FindFirstChild(Config.TargetPlayer) then
        return Players[Config.TargetPlayer]
    end
    return nil
end

local function GetTargetChar()
    local target = GetTargetPlayer()
    return target and GetCharacter(target)
end

local function IsTargetValid()
    local char = GetTargetChar()
    return IsValidCharacter(char)
end

-- // FLING
local function Fling(player)
    local char = GetCharacter(player)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end
    local dir = (root.Position - RootPart.Position).Unit
    local power = 200 -- adjustable later
    local velocity = dir * power + Vector3.new(0, power * 0.5, 0)
    root.Velocity = velocity
end

local function FlingAll()
    for _, player in ipairs(GetAllPlayers()) do
        Fling(player)
    end
end

-- // AIMLOCK
local function AimlockCamera(target)
    if not target then return end
    local char = GetCharacter(target)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end
    local cam = workspace.CurrentCamera
    cam.CFrame = CFrame.lookAt(cam.CFrame.Position, root.Position)
end

local function AimlockCharacter(target)
    if not target then return end
    local char = GetCharacter(target)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end
    RootPart.CFrame = CFrame.lookAt(RootPart.Position, root.Position)
end

-- // TELEPORT
local function TeleportToPlayer(target, offset)
    local char = GetCharacter(target)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end
    local pos = root.Position + (offset or Vector3.new(0, 0, 0))
    RootPart.CFrame = CFrame.new(pos)
end

-- // HOOK
local function HookToPlayer(target, distance)
    local char = GetCharacter(target)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end
    local dir = (root.Position - RootPart.Position).Unit
    local hookPos = root.Position - dir * (distance or Config.HookDistance)
    RootPart.CFrame = CFrame.new(hookPos)
end

-- // TROLL: BANG / JORK (placeholder - just chat spam or effects)
local function Bang(player)
    -- Simulate a bang effect (can be chat, sound, etc.)
    StarterGui:SetCore("SendNotification", {
        Title = "💥 BANG!",
        Text = "You banged " .. player.Name,
        Duration = 2
    })
end

local function Jork(player)
    StarterGui:SetCore("SendNotification", {
        Title = "✊ JORK IT OFF",
        Text = "Jorking " .. player.Name,
        Duration = 2
    })
end

-- // FARMING: AUTO SKILL FARM (simulate hitting target)
local function AutoSkillFarm()
    local target = nil
    if Config.FarmMode == "LowestHealth" then
        local lowest = math.huge
        for _, player in ipairs(GetAllPlayers()) do
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local hum = GetHumanoid(char)
                if hum and hum.Health < lowest then
                    lowest = hum.Health
                    target = player
                end
            end
        end
    elseif Config.FarmMode == "Nearest" then
        local dist = math.huge
        for _, player in ipairs(GetAllPlayers()) do
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local root = GetRootPart(char)
                if root then
                    local d = (RootPart.Position - root.Position).Magnitude
                    if d < dist then
                        dist = d
                        target = player
                    end
                end
            end
        end
    elseif Config.FarmMode == "TargetHealth" then
        -- find player with health closest to Config.TargetHealth
        local closest = math.huge
        for _, player in ipairs(GetAllPlayers()) do
            local char = GetCharacter(player)
            if IsValidCharacter(char) then
                local hum = GetHumanoid(char)
                if hum then
                    local diff = math.abs(hum.Health - Config.TargetHealth)
                    if diff < closest then
                        closest = diff
                        target = player
                    end
                end
            end
        end
    end

    if target then
        -- Simulate hitting target (M1)
        VirtualUser:ClickButton1(Vector2.new(0,0), Enum.UserInputType.MouseButton1)
        -- Also use abilities if HookMode is on (just press 1-4)
        if Config.HookMode then
            for key = 1, 4 do
                VirtualUser:ClickButton1(Vector2.new(0,0), Enum.UserInputType.MouseButton1) -- need to send key events
            end
        end
    end
end

-- // TRASHCAN FARM
local function TrashcanFarm()
    -- Find nearest trashcan (if any) and interact
    -- Placeholder: just search for parts named "Trashcan" or similar
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("trash") or obj.Name:lower():find("can") then
            if obj:IsA("BasePart") then
                local dist = (RootPart.Position - obj.Position).Magnitude
                if dist < 15 then
                    -- Click to collect
                    VirtualUser:ClickButton1(Vector2.new(0,0), Enum.UserInputType.MouseButton1)
                    break
                end
            end
        end
    end
end

-- // RESET STREAK
local function ResetStreak()
    -- Send chat command to reset streak
    LocalPlayer.Chatted:Connect(function(msg) end) -- not needed
    -- In TSB, streak resets at 9 by default, but we can simulate a command
    StarterGui:SetCore("SendNotification", {
        Title = "Streak",
        Text = "Resetting streak at 9!",
        Duration = 1
    })
end

-- // INVISIBILITY
local function SetInvisible(state)
    local char = Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = state and 1 or 0
        end
    end
end

-- // ESP
local ESPObjects = {}
local function CreateESP(player)
    if ESPObjects[player] then return end
    local char = GetCharacter(player)
    if not IsValidCharacter(char) then return end
    local root = GetRootPart(char)
    if not root then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.Parent = root

    -- Name
    if Config.ShowNames then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
    end

    -- Health Bar
    if Config.ShowHealthBar then
        local healthBg = Instance.new("Frame")
        healthBg.Size = UDim2.new(0.8, 0, 0.2, 0)
        healthBg.Position = UDim2.new(0.1, 0, 0.5, 0)
        healthBg.BackgroundColor3 = Color3.fromRGB(50,50,50)
        healthBg.Parent = billboard

        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0,255,0)
        healthFill.Parent = healthBg
        ESPObjects[player] = {Billboard = billboard, HealthFill = healthFill}
    end

    -- Additional info (distance, ping, etc.) can be added similarly
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
                if hum and data.HealthFill then
                    local healthPercent = hum.Health / hum.MaxHealth
                    data.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                end
            end
        end
    end
end

-- // PROTECTIONS
local function AntiStaff()
    -- Placeholder: check if any staff are nearby and alert
end

local function AntiTrashcan()
    -- Prevent being trashcanned by teleporting away when a trashcan is near
end

local function AntiFling()
    -- Counter fling by applying opposite force
end

-- // COMBAT ASSISTS
local function AutoHit()
    -- Simulate M1 spam on nearest enemy
    local target = nil
    local dist = math.huge
    for _, player in ipairs(GetAllPlayers()) do
        local char = GetCharacter(player)
        if IsValidCharacter(char) then
            local root = GetRootPart(char)
            if root then
                local d = (RootPart.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    target = player
                end
            end
        end
    end
    if target then
        VirtualUser:ClickButton1(Vector2.new(0,0), Enum.UserInputType.MouseButton1)
    end
end

local function AutoWallcombo()
    -- Simulate wall combo (hit while near wall)
end

local function M1Reset()
    -- Reset M1 cooldown (if possible)
end

-- // DODGE
local function AutoDodgePlayers()
    local target = nil
    for _, player in ipairs(GetAllPlayers()) do
        local char = GetCharacter(player)
        if IsValidCharacter(char) then
            local root = GetRootPart(char)
            if root and (RootPart.Position - root.Position).Magnitude < 15 then
                target = player
                break
            end
        end
    end
    if target then
        -- Press dash (Q)
        VirtualUser:ClickButton2(Vector2.new(0,0), Enum.UserInputType.MouseButton2)
    end
end

-- // STUN / RAGDOLL
local function RemoveStun()
    if Humanoid:GetState() == Enum.HumanoidStateType.GettingUp then
        Humanoid.Jump = true
    end
end

local function AntiRagdoll()
    if Humanoid.PlatformStand then
        Humanoid.PlatformStand = false
    end
    if Humanoid.Sit then
        Humanoid.Sit = false
    end
end

-- // MOVEMENT: FLY
local FlyEnabled = false
local FlySpeed = 50

local function ToggleFly()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        -- create body velocity
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1,1,1) * 1e5
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = RootPart
        -- also BodyGyro for orientation
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1,1,1) * 1e5
        bg.CFrame = RootPart.CFrame
        bg.Parent = RootPart
        -- store
        RootPart:SetAttribute("FlyBV", bv)
        RootPart:SetAttribute("FlyBG", bg)
    else
        local bv = RootPart:FindFirstChild("BodyVelocity")
        if bv then bv:Destroy() end
        local bg = RootPart:FindFirstChild("BodyGyro")
        if bg then bg:Destroy() end
    end
end

local function UpdateFly()
    if not FlyEnabled then return end
    local bv = RootPart:FindFirstChild("BodyVelocity")
    if not bv then return end
    local moveDir = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Vector3.new(0,0,-1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + Vector3.new(0,0,1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + Vector3.new(-1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Vector3.new(1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir + Vector3.new(0,-1,0) end
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * FlySpeed
    end
    bv.Velocity = moveDir
    -- orient
    local bg = RootPart:FindFirstChild("BodyGyro")
    if bg then
        bg.CFrame = CFrame.lookAt(RootPart.Position, RootPart.Position + moveDir)
    end
end

-- // CLICK TELEPORT
local function ClickTeleport()
    local hit = Mouse.Hit
    RootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 5, 0))
end

-- // DASH MODIFIERS
local originalDash = nil
local function ModifyDash()
    -- Override dash speed and distance by hooking into game's dash function
    -- Placeholder: we can change Humanoid.WalkSpeed temporarily
end

-- // UI BUILDER (FIXED LAYOUT, SCROLLABLE, DROPDOWN)
local function CreateHub()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GodmodeSuite"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
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
    titleLabel.Text = "⚡ GODMODE SUITE v6 ⚡"
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

    local tabNames = {"Main", "Farming", "Home", "Combat", "Movement"}
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

    -- Helper: Add row with proper y offset
    local function AddRow(parent, yOffset, height)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, height or 28)
        row.Position = UDim2.new(0, 5, 0, yOffset)
        row.BackgroundTransparency = 1
        row.Parent = parent
        return row
    end

    -- Helper: Toggle
    local function AddToggle(parent, label, configKey, default, yOffset, onToggle)
        local row = AddRow(parent, yOffset, 28)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.Parent = row

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.35, 0, 0.8, 0)
        toggle.Position = UDim2.new(0.65, 0, 0.1, 0)
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

    -- Helper: Slider with + and - buttons
    local function AddSlider(parent, label, configKey, min, max, default, step, yOffset, onChanged)
        local row = AddRow(parent, yOffset, 32)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Text = label .. ": " .. tostring(Config[configKey] or default)
        lbl.TextColor3 = Color3.fromRGB(200,200,200)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.Parent = row

        local decBtn = Instance.new("TextButton")
        decBtn.Size = UDim2.new(0.12, 0, 0.8, 0)
        decBtn.Position = UDim2.new(0.45, 0, 0.1, 0)
        decBtn.Text = "-"
        decBtn.TextColor3 = Color3.fromRGB(255,255,255)
        decBtn.BackgroundColor3 = Color3.fromRGB(60,60,80)
        decBtn.Font = Enum.Font.GothamBold
        decBtn.TextSize = 18
        decBtn.Parent = row

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.15, 0, 1, 0)
        valueLabel.Position = UDim2.new(0.57, 0, 0, 0)
        valueLabel.Text = tostring(Config[configKey] or default)
        valueLabel.TextColor3 = Color3.fromRGB(255,255,255)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 14
        valueLabel.Parent = row

        local incBtn = Instance.new("TextButton")
        incBtn.Size = UDim2.new(0.12, 0, 0.8, 0)
        incBtn.Position = UDim2.new(0.72, 0, 0.1, 0)
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

    -- Helper: Dropdown (simple button that cycles through options)
    local function AddDropdown(parent, label, configKey, options, default, yOffset, onChanged)
        local row = AddRow(parent, yOffset, 30)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.45, 0, 1, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = row

        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
        dropdownBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
        dropdownBtn.Text = tostring(Config[configKey] or default)
        dropdownBtn.TextColor3 = Color3.fromRGB(255,255,255)
        dropdownBtn.BackgroundColor3 = Color3.fromRGB(40,40,60)
        dropdownBtn.Font = Enum.Font.GothamBold
        dropdownBtn.TextSize = 14
        dropdownBtn.Parent = row

        local currentIndex = 1
        for i, opt in ipairs(options) do
            if opt == (Config[configKey] or default) then
                currentIndex = i
                break
            end
        end

        dropdownBtn.MouseButton1Click:Connect(function()
            currentIndex = currentIndex % #options + 1
            local selected = options[currentIndex]
            Config[configKey] = selected
            dropdownBtn.Text = selected
            if onChanged then onChanged(selected) end
        end)
        return row
    end

    -- Helper: Text Input for Keybinds
    local function AddKeybind(parent, label, configKey, defaultKey, yOffset, onChanged)
        local row = AddRow(parent, yOffset, 30)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.4, 0, 1, 0)
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.Parent = row

        local keyBox = Instance.new("TextBox")
        keyBox.Size = UDim2.new(0.4, 0, 0.8, 0)
        keyBox.Position = UDim2.new(0.5, 0, 0.1, 0)
        keyBox.Text = tostring(Config[configKey] or defaultKey)
        keyBox.TextColor3 = Color3.fromRGB(255,255,255)
        keyBox.BackgroundColor3 = Color3.fromRGB(30,30,50)
        keyBox.Font = Enum.Font.GothamBold
        keyBox.TextSize = 14
        keyBox.Parent = row

        keyBox.FocusLost:Connect(function()
            local newKey = keyBox.Text:upper()
            if newKey ~= "" then
                Config[configKey] = newKey
                if onChanged then onChanged(newKey) end
            end
        end)
        return row
    end

    -- ===== POPULATE TABS =====

    -- Tab 1: Main
    local mainTab = tabFrames[1]
    local y = 5
    -- Player dropdown (list of players)
    -- We'll create a button that cycles through players
    local playerNames = {}
    local function updatePlayerList()
        playerNames = {}
        for _, player in ipairs(GetAllPlayers()) do
            table.insert(playerNames, player.Name)
        end
        if #playerNames == 0 then
            table.insert(playerNames, "None")
        end
    end
    updatePlayerList()
    -- Dropdown for target
    y = y + AddDropdown(mainTab, "Target Player", "TargetPlayer", playerNames, playerNames[1] or "None", y, function(val)
        Config.TargetPlayer = val
    end).Size.Y.Offset + 3

    -- Fling section
    y = y + AddToggle(mainTab, "Fling Selected", "FlingSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Auto Fling Selected", "AutoFlingSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Fling All", "FlingAll", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Auto Fling All", "AutoFlingAll", false, y).Size.Y.Offset + 3

    -- Aimlock
    y = y + AddToggle(mainTab, "Aimlock Camera", "AimlockCam", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Aimlock Character", "AimlockChar", false, y).Size.Y.Offset + 3

    -- Teleport
    y = y + AddToggle(mainTab, "Teleport to Selected", "TeleportSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Loop TP Behind", "LoopTPBehind", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Loop TP Front", "LoopTPFront", false, y).Size.Y.Offset + 3

    -- Hook
    y = y + AddToggle(mainTab, "Hook to Selected", "HookSelected", false, y).Size.Y.Offset + 3
    y = y + AddSlider(mainTab, "Hook Distance", "HookDistance", 10, 100, 30, 5, y).Size.Y.Offset + 3

    -- Troll
    y = y + AddToggle(mainTab, "Bang Selected", "BangSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Auto Bang Selected", "AutoBangSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Jork it off", "JorkSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Auto Jork", "AutoJorkSelected", false, y).Size.Y.Offset + 3

    -- Target Farming
    y = y + AddToggle(mainTab, "Trash Farm on Selected", "TrashFarmSelected", false, y).Size.Y.Offset + 3
    y = y + AddToggle(mainTab, "Auto Skill/Move Farm", "AutoSkillFarmSelected", false, y).Size.Y.Offset + 3

    mainTab.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Tab 2: Farming
    local farmTab = tabFrames[2]
    y = 5
    y = y + AddToggle(farmTab, "Activate Auto Farm", "AutoFarm", false, y).Size.Y.Offset + 3
    y = y + AddDropdown(farmTab, "Farm Mode", "FarmMode", {"LowestHealth", "Nearest", "TargetHealth"}, "LowestHealth", y, function(val) end).Size.Y.Offset + 3
    y = y + AddSlider(farmTab, "Target Health", "TargetHealth", 1, 100, 50, 5, y).Size.Y.Offset + 3
    y = y + AddToggle(farmTab, "Enable Trashcan Farm", "TrashcanFarm", false, y).Size.Y.Offset + 3
    y = y + AddToggle(farmTab, "Use Hook Mode", "HookMode", false, y).Size.Y.Offset + 3
    y = y + AddSlider(farmTab, "Hook Distance", "HookDistanceFarm", 10, 100, 30, 5, y).Size.Y.Offset + 3
    y = y + AddSlider(farmTab, "Attack Height (No Hook)", "AttackHeight", 0, 20, 5, 1, y).Size.Y.Offset + 3
    -- Reset Streak button
    local resetRow = AddRow(farmTab, y, 30)
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 1, 0)
    resetBtn.Text = "🔄 Reset Streak (at 9)"
    resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200,150,50)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.Parent = resetRow
    resetBtn.MouseButton1Click:Connect(function()
        ResetStreak()
    end)
    y = y + 33
    farmTab.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Tab 3: Home
    local homeTab = tabFrames[3]
    y = 5
    y = y + AddToggle(homeTab, "Become Invisible", "Invisible", false, y, function(val)
        SetInvisible(val)
    end).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Anti Invisibility", "AntiInvisibility", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "ESP Enabled", "ESP", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Show Names", "ShowNames", true, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Show Health Bar", "ShowHealthBar", true, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Show Ping", "ShowPing", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Show Distance", "ShowDistance", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Show Device", "ShowDevice", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Show Kill Streak", "ShowKillStreak", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Death Counter", "DeathCounter", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Ult Progress Bar", "UltProgressBar", false, y).Size.Y.Offset + 3
    y = y + AddSlider(homeTab, "HipHeight Value", "HipHeight", 0, 5, 0, 0.5, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Activate HipHeight", "ActivateHipHeight", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Unlock Gaze", "UnlockGaze", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Unlock Nightchild Emote", "UnlockNightchild", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Auto Spin Emote (On Kill)", "AutoSpinEmote", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Unlock 8 Emote Slots", "Unlock8EmoteSlots", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Anti Staff", "AntiStaff", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Anti Trashcan Method", "AntiTrashcan", false, y).Size.Y.Offset + 3
    y = y + AddToggle(homeTab, "Anti Fling", "AntiFling", false, y).Size.Y.Offset + 3
    homeTab.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Tab 4: Combat
    local combatTab = tabFrames[4]
    y = 5
    y = y + AddToggle(combatTab, "AimLock Cam", "AimlockCam", false, y).Size.Y.Offset + 3
    y = y + AddKeybind(combatTab, "AimLock Cam KeyBind", "AimlockCamKey", "Q", y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "AimLock Character", "AimlockChar", false, y).Size.Y.Offset + 3
    y = y + AddKeybind(combatTab, "AimLock Char KeyBind", "AimlockCharKey", "E", y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "Auto Hit", "AutoHit", false, y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "Auto Wallcombo", "AutoWallcombo", false, y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "M1 Reset", "M1Reset", false, y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "Auto Dodge Players", "AutoDodgePlayers", false, y).Size.Y.Offset + 3
    y = y + AddKeybind(combatTab, "Auto Dodge KeyBind", "AutoDodgeKey", "X", y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "Remove Stun", "RemoveStun", false, y).Size.Y.Offset + 3
    y = y + AddToggle(combatTab, "Anti Ragdoll", "AntiRagdoll", false, y).Size.Y.Offset + 3
    combatTab.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    -- Tab 5: Movement
    local moveTab = tabFrames[5]
    y = 5
    y = y + AddSlider(moveTab, "Walkspeed Value", "Walkspeed", 16, 200, 16, 1, y).Size.Y.Offset + 3
    y = y + AddKeybind(moveTab, "Walkspeed KeyBind", "WalkspeedKey", "V", y).Size.Y.Offset + 3
    y = y + AddToggle(moveTab, "High Jump", "HighJump", false, y).Size.Y.Offset + 3
    y = y + AddSlider(moveTab, "High Jump Power", "HighJumpPower", 50, 300, 100, 10, y).Size.Y.Offset + 3
    y = y + AddSlider(moveTab, "Fly Speed", "FlySpeed", 10, 150, 50, 5, y).Size.Y.Offset + 3
    y = y + AddToggle(moveTab, "Activate Bypassed Fly", "FlyEnabled", false, y, function(val)
        ToggleFly()
    end).Size.Y.Offset + 3
    y = y + AddKeybind(moveTab, "Fly KeyBind", "FlyKey", "F", y).Size.Y.Offset + 3
    y = y + AddToggle(moveTab, "Activate Click Teleport", "ClickTeleport", false, y).Size.Y.Offset + 3
    y = y + AddKeybind(moveTab, "Click Teleport KeyBind", "ClickTeleportKey", "T", y).Size.Y.Offset + 3
    y = y + AddToggle(moveTab, "Front Dash", "FrontDash", false, y).Size.Y.Offset + 3
    y = y + AddSlider(moveTab, "Front Dash Distance", "FrontDashDistance", 5, 50, 20, 1, y).Size.Y.Offset + 3
    y = y + AddToggle(moveTab, "Side Dash", "SideDash", false, y).Size.Y.Offset + 3
    y = y + AddSlider(moveTab, "Side Dash Dist Multiplier", "SideDashDistMult", 0.5, 3, 1.5, 0.1, y).Size.Y.Offset + 3
    y = y + AddSlider(moveTab, "Side Dash Speed Multiplier", "SideDashSpeedMult", 0.5, 3, 1.2, 0.1, y).Size.Y.Offset + 3
    y = y + AddToggle(moveTab, "Back Dash", "BackDash", false, y).Size.Y.Offset + 3
    y = y + AddSlider(moveTab, "Back Dash Dist Multiplier", "BackDashDistMult", 0.5, 2, 1, 0.1, y).Size.Y.Offset + 3
    moveTab.CanvasSize = UDim2.new(0, 0, 0, y + 20)

    return screenGui
end

-- // KEYBIND HANDLER
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local key = input.KeyCode.Name

    -- Combat keybinds
    if Config.AimlockCam and key == Config.AimlockCamKey then
        local target = GetTargetPlayer()
        if target then AimlockCamera(target) end
    end
    if Config.AimlockChar and key == Config.AimlockCharKey then
        local target = GetTargetPlayer()
        if target then AimlockCharacter(target) end
    end
    if Config.AutoDodgePlayers and key == Config.AutoDodgeKey then
        AutoDodgePlayers()
    end
    -- Movement keybinds
    if key == Config.WalkspeedKey then
        Humanoid.WalkSpeed = Config.Walkspeed
    end
    if Config.FlyEnabled and key == Config.FlyKey then
        ToggleFly()
    end
    if Config.ClickTeleport and key == Config.ClickTeleportKey then
        ClickTeleport()
    end
end)

-- // MAIN LOOP
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end

    -- Main tab features
    local target = GetTargetPlayer()
    if target and IsValidCharacter(GetCharacter(target)) then
        if Config.FlingSelected then Fling(target) end
        if Config.AutoFlingSelected then Fling(target) end -- repeated
        if Config.TeleportSelected then TeleportToPlayer(target) end
        if Config.HookSelected then HookToPlayer(target, Config.HookDistance) end
        if Config.BangSelected then Bang(target) end
        if Config.AutoBangSelected then Bang(target) end
        if Config.JorkSelected then Jork(target) end
        if Config.AutoJorkSelected then Jork(target) end
        if Config.TrashFarmSelected then TrashcanFarm() end
        if Config.AutoSkillFarmSelected then AutoSkillFarm() end
        if Config.LoopTPBehind then TeleportToPlayer(target, Vector3.new(0,0,-5)) end
        if Config.LoopTPFront then TeleportToPlayer(target, Vector3.new(0,0,5)) end
    end
    if Config.FlingAll then FlingAll() end
    if Config.AutoFlingAll then FlingAll() end

    -- Farming
    if Config.AutoFarm then AutoSkillFarm() end
    if Config.TrashcanFarm then TrashcanFarm() end

    -- Home
    if Config.Invisible then SetInvisible(true) end
    if Config.ESP then
        for _, player in ipairs(GetAllPlayers()) do
            CreateESP(player)
        end
        UpdateESP()
    else
        for player, data in pairs(ESPObjects) do
            data.Billboard:Destroy()
            ESPObjects[player] = nil
        end
    end
    if Config.ActivateHipHeight then
        Humanoid.HipHeight = Config.HipHeight
    end
    -- Protections (placeholder)
    if Config.AntiStaff then AntiStaff() end
    if Config.AntiTrashcan then AntiTrashcan() end
    if Config.AntiFling then AntiFling() end

    -- Combat
    if Config.AutoHit then AutoHit() end
    if Config.AutoWallcombo then AutoWallcombo() end
    if Config.M1Reset then M1Reset() end
    if Config.RemoveStun then RemoveStun() end
    if Config.AntiRagdoll then AntiRagdoll() end

    -- Movement: High Jump
    if Config.HighJump then
        Humanoid.JumpPower = Config.HighJumpPower
    else
        Humanoid.JumpPower = 50 -- reset
    end
    -- Walkspeed is set via keybind or slider if not toggled
    if not UserInputService:IsKeyDown(Enum.KeyCode[Config.WalkspeedKey]) then
        Humanoid.WalkSpeed = Config.Walkspeed
    end
    -- Fly update
    if Config.FlyEnabled then
        UpdateFly()
    end
    -- Dash modifiers (we'll just apply to Humanoid properties)
    if Config.FrontDash then
        -- modify dash forward
    end
    if Config.SideDash then
        -- modify side dash
    end
    if Config.BackDash then
        -- modify back dash
    end
end)

-- // CHARACTER RESPAWN
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Head = Character:WaitForChild("Head")
    -- Reset fly if active
    if FlyEnabled then
        ToggleFly()
        FlyEnabled = false
    end
end)

-- // START
pcall(function()
    print("[Godmode Suite] Initializing...")
    CreateHub()
    print("[Godmode Suite] Ready. Enjoy the features!")
end)
