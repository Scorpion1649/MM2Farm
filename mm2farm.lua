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
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Round corners
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Gradient background
local gradient = Instance.new("UIGradient", frame)
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50,50,50))
}
gradient.Rotation = 90

-- Neon border effect
local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- === Title ===
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "⚡ MM2 AutoFarm ⚡"
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

-- === Slider ===
local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(0, 260, 0, 20)
sliderLabel.Position = UDim2.new(0, 20, 0, 92)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Fly Speed: 0.3s"
sliderLabel.TextColor3 = Color3.fromRGB(180,180,180)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 14

local sliderFrame = Instance.new("Frame", frame)
sliderFrame.Size = UDim2.new(0, 260, 0, 6)
sliderFrame.Position = UDim2.new(0, 20, 0, 115)
sliderFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1, 0)

local knob = Instance.new("Frame", sliderFrame)
knob.Size = UDim2.new(0, 12, 0, 18)
knob.Position = UDim2.new(0, 0, -0.6, 0)
knob.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
knob.BorderSizePixel = 0
knob.Active = true
knob.Draggable = true
Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 6)

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

-- === Fly Speed Value ===
local flySpeed = 0.3
local minSpeed, maxSpeed = 0.1, 1.5
local function updateSpeedFromKnob()
    local percent = math.clamp(knob.Position.X.Offset / (sliderFrame.AbsoluteSize.X - knob.AbsoluteSize.X), 0, 1)
    flySpeed = minSpeed + (maxSpeed - minSpeed) * percent
    sliderLabel.Text = string.format("Fly Speed: %.2fs", flySpeed)
end
knob.Changed:Connect(function(prop)
    if prop == "Position" then updateSpeedFromKnob() end
end)

-- === Coin Finder ===
local function getCoins()
    local coins = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
            table.insert(coins, obj)
        end
    end
    return coins
end

-- === Fly Movement (head under coin) ===
local function flyToPart(part)
    if not part or not hrp then return end
    local goal = {}
    goal.CFrame = part.CFrame * CFrame.new(0, -2.5, 0) -- HEAD under coin
    local tweenInfo = TweenInfo.new(flySpeed, Enum.EasingStyle.Linear)
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
        humanoid.Jump = true -- force jump once
        antiGravityConn = RunService.Stepped:Connect(function()
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z) -- zero out downward velocity
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
                task.wait(0.2)
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

-- Update character reference on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    character = char
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
end)

statusLabel.Text = "Status: Ready — toggle AutoFarm"
