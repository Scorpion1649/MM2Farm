--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- === Character References ===
local function getChar()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, humanoid
end
local character, hrp, humanoid = getChar()

-- === GUI Parent ===
local parentGui
pcall(function()
    parentGui = game:GetService("CoreGui")
end)
if not parentGui then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- === ScreenGui ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2AutoFarmGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = parentGui

-- === Main Frame ===
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 160)
frame.Position = UDim2.new(0.5, -150, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50,50,50))
}
gradient.Rotation = 90

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- === Title ===
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🏖️MM2 Summer AutoFarm💰"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- === Buttons ===
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Text = "AutoFarm: OFF"
autoBtn.Size = UDim2.new(0, 130, 0, 38)
autoBtn.Position = UDim2.new(0, 14, 0, 45)
autoBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 16
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 8)

local afkBtn = Instance.new("TextButton", frame)
afkBtn.Text = "Anti-AFK: OFF"
afkBtn.Size = UDim2.new(0, 130, 0, 38)
afkBtn.Position = UDim2.new(0, 156, 0, 45)
afkBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
afkBtn.Font = Enum.Font.GothamBold
afkBtn.TextSize = 16
Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0, 8)

local espBtn = Instance.new("TextButton", frame)
espBtn.Text = "Coin ESP: OFF"
espBtn.Size = UDim2.new(0, 260, 0, 36)
espBtn.Position = UDim2.new(0, 20, 0, 90)
espBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 16
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)

-- === Status Label ===
local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -12, 0, 18)
statusLabel.Position = UDim2.new(0, 8, 1, -28)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180,180,180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Status: Ready"

-- === Open/Close Button ===
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -60, 0.05, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toggleBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
toggleBtn.Text = "Open AutoFarm"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
frame.Visible = false
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    toggleBtn.Text = frame.Visible and "Close AutoFarm" or "Open AutoFarm"
end)

-- === Fly Speed ===
local flySpeed = 28 -- updated fly speed

-- === Coin Finder ===
local function getCoins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") and obj.Transparency < 0.01 then
            table.insert(coins, obj)
        end
    end
    return coins
end

-- === Fly Movement (head slightly below coin) ===
local function flyToPart(part)
    if not part or not hrp or not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local offset = head.Position - hrp.Position
    local targetPos = part.Position - offset - Vector3.new(0, 1, 0)
    local distance = (hrp.Position - targetPos).Magnitude
    local time = distance / flySpeed

    local goal = {CFrame = CFrame.new(targetPos)}
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- === Noclip ===
local noclipConn
local function enableNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if character then
            for _, v in ipairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end
local function disableNoclip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

-- === Anti-Gravity ===
local antiGravityConn
local function enableAntiGravity()
    if antiGravityConn then return end
    if humanoid and hrp then
        humanoid.Jump = true
        antiGravityConn = RunService.Stepped:Connect(function()
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
        end)
    end
end
local function disableAntiGravity()
    if antiGravityConn then
        antiGravityConn:Disconnect()
        antiGravityConn = nil
    end
end

-- === AutoFarm ===
local farming = false
local function startFarm()
    farming = true
    enableNoclip()
    enableAntiGravity()

    task.spawn(function()
        while farming do
            local coins = getCoins()
            if #coins > 0 then
                local closest = coins[1]
                local dist = (closest.Position - hrp.Position).Magnitude
                for _, c in ipairs(coins) do
                    local d = (c.Position - hrp.Position).Magnitude
                    if d < dist then
                        closest = c
                        dist = d
                    end
                end
                flyToPart(closest)
            else
                -- stay slightly underground if no coins
                if hrp then
                    hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 0.1, hrp.Position.Z)
                end
                task.wait(0.05)
            end
            task.wait(0.05)
        end
    end)
end

local function stopFarm()
    farming = false
    disableNoclip()
    disableAntiGravity()
end

-- === Anti-AFK ===
local AntiAFK = false
local afkConn
local function startAFK()
    AntiAFK = true
    afkConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
local function stopAFK()
    AntiAFK = false
    if afkConn then
        afkConn:Disconnect()
    end
end

-- === Coin ESP ===
local espEnabled = false
local espConnections = {}
local hue = 0

local function createESP(part)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = part
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Parent = part
    table.insert(espConnections, highlight)
end

local function enableESP()
    espEnabled = true
    for _, part in ipairs(getCoins()) do
        createESP(part)
    end
    task.spawn(function()
        while espEnabled do
            hue = (hue + 1) % 360
            local color = Color3.fromHSV(hue / 360, 1, 1)
            for _, h in ipairs(espConnections) do
                if h.Parent then
                    h.OutlineColor = color
                end
            end
            task.wait(0.05)
        end
    end)
end

local function disableESP()
    espEnabled = false
    for _, h in ipairs(espConnections) do
        h:Destroy()
    end
    table.clear(espConnections)
end

-- === Button Logic ===
autoBtn.MouseButton1Click:Connect(function()
    if farming then
        stopFarm()
        autoBtn.Text = "AutoFarm: OFF"
        statusLabel.Text = "Status: AutoFarm stopped"
    else
        startFarm()
        autoBtn.Text = "AutoFarm: ON"
        statusLabel.Text = "Status: AutoFarm running"
    end
end)

afkBtn.MouseButton1Click:Connect(function()
    if AntiAFK then
        stopAFK()
        afkBtn.Text = "Anti-AFK: OFF"
        statusLabel.Text = "Status: Anti-AFK stopped"
    else
        startAFK()
        afkBtn.Text = "Anti-AFK: ON"
        statusLabel.Text = "Status: Anti-AFK running"
    end
end)

espBtn.MouseButton1Click:Connect(function()
    if espEnabled then
        disableESP()
        espBtn.Text = "Coin ESP: OFF"
        statusLabel.Text = "Status: ESP disabled"
    else
        enableESP()
        espBtn.Text = "Coin ESP: ON"
        statusLabel.Text = "Status: Coin ESP active"
    end
end)

-- Auto resume AutoFarm after respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
    task.wait(1)
    if farming then
        startFarm()
        statusLabel.Text = "Status: AutoFarm resumed"
    end
end)

statusLabel.Text = "Status: Ready — toggle AutoFarm"
