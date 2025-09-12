-- MM2 Auto Farm Script (Fly + Speed Slider + Open/Close Button)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- === Character References ===
local function getChar()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    return char, hrp
end
local character, hrp = getChar()

-- === GUI Parent ===
local parentGui
pcall(function() parentGui = game:GetService("CoreGui") end)
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
frame.Size = UDim2.new(0, 280, 0, 160)
frame.Position = UDim2.new(0.5, -140, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "MM2 AutoFarm"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local autoBtn = Instance.new("TextButton", frame)
autoBtn.Text = "AutoFarm: OFF"
autoBtn.Size = UDim2.new(0, 120, 0, 36)
autoBtn.Position = UDim2.new(0, 12, 0, 40)
autoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local afkBtn = Instance.new("TextButton", frame)
afkBtn.Text = "Anti-AFK: OFF"
afkBtn.Size = UDim2.new(0, 120, 0, 36)
afkBtn.Position = UDim2.new(0, 148, 0, 40)
afkBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(0, 240, 0, 20)
sliderLabel.Position = UDim2.new(0, 20, 0, 86)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Fly Speed: 0.3s"
sliderLabel.TextColor3 = Color3.fromRGB(200,200,200)
sliderLabel.Font = Enum.Font.SourceSans
sliderLabel.TextSize = 14

-- Speed slider background
local sliderFrame = Instance.new("Frame", frame)
sliderFrame.Size = UDim2.new(0, 240, 0, 6)
sliderFrame.Position = UDim2.new(0, 20, 0, 110)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

-- Slider knob
local knob = Instance.new("Frame", sliderFrame)
knob.Size = UDim2.new(0, 10, 0, 16)
knob.Position = UDim2.new(0, 0, -0.5, 0)
knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
knob.BorderSizePixel = 0
knob.Active = true
knob.Draggable = true

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, -12, 0, 18)
statusLabel.Position = UDim2.new(0, 6, 1, -26)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200,200,200)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "Status: Ready"

-- === Open/Close Button ===
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -60, 0.05, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Open AutoFarm"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 16
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

frame.Visible = false
toggleBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    toggleBtn.Text = frame.Visible and "Close AutoFarm" or "Open AutoFarm"
end)

-- === Fly Speed Value ===
local flySpeed = 0.3 -- default tween time
local minSpeed, maxSpeed = 0.1, 1.5

local function updateSpeedFromKnob()
    local percent = math.clamp(knob.Position.X.Offset / (sliderFrame.AbsoluteSize.X - knob.AbsoluteSize.X), 0, 1)
    flySpeed = minSpeed + (maxSpeed - minSpeed) * percent
    sliderLabel.Text = string.format("Fly Speed: %.2fs", flySpeed)
end

knob.Changed:Connect(function(prop)
    if prop == "Position" then
        updateSpeedFromKnob()
    end
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

-- === Fly Movement ===
local function flyToPart(part)
    if not part or not hrp then return end
    local goal = {}
    goal.CFrame = part.CFrame + Vector3.new(0, 3, 0)
    local tweenInfo = TweenInfo.new(flySpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- === AutoFarm ===
local farming = false
local function startFarm()
    farming = true
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
local function stopFarm() farming = false end

-- === Anti-AFK ===
local AntiAFK = false
local afkConn
local function startAFK()
    AntiAFK = true
    afkConn = LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end
local function stopAFK()
    AntiAFK = false
    if afkConn then afkConn:Disconnect() end
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
end)

statusLabel.Text = "Status: Ready — toggle AutoFarm"
