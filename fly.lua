-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Function to send a message to the chat
local function sendMessage(message)
    local ChatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 5)
    if ChatEvent then
        ChatEvent.SayMessageRequest:FireServer(message, "All")
    else
        warn("ChatEvent not found")
    end
end

-- Inject message
sendMessage("Injecting void hub...")
task.wait(1)
sendMessage("void hub Injected!")

-- Fallback GUI for debugging
local function createFallbackGui(errorMsg)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "void hubFallback"
    screenGui.Parent = player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.4, 0, 0.3, 0)
    frame.Position = UDim2.new(0.3, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -10)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = "void hub Failed to Load\nError: " .. errorMsg .. "\nCheck console for details."
    textLabel.TextSize = 16
    textLabel.TextWrapped = true
    textLabel.Parent = frame

    print("Fallback GUI created with error: " .. errorMsg)
end

-- Load Rayfield with retries
local Rayfield
local function loadRayfield()
    print("Attempting to load Rayfield...")
    local url = 'https://sirius.menu/rayfield'
    for attempt = 1, 3 do
        local success, result = pcall(function()
            local response = game:HttpGet(url)
            if response and response ~= "" then
                return loadstring(response)()
            end
            error("Empty or invalid response")
        end)
        if success then
            print("Rayfield loaded successfully on attempt " .. attempt)
            return result
        end
        warn("Attempt " .. attempt .. " failed: " .. tostring(result))
        task.wait(2)
    end
    error("Failed to load Rayfield after 3 attempts")
end

-- Attempt to load Rayfield with error handling
local success, rayfieldResult = pcall(loadRayfield)
if not success or not rayfieldResult then
    local errorMsg = success and "Rayfield returned nil" or rayfieldResult
    warn("Rayfield load failed: " .. errorMsg)
    StarterGui:SetCore("SendNotification", {
        Title = "void hub Error",
        Text = "Failed to load Rayfield. Use Fluxus or check console.",
        Duration = 10
    })
    createFallbackGui(errorMsg)
    return
else
    Rayfield = rayfieldResult
    print("Rayfield initialized")
end

-- Create GUI with error handling
local Window
local success, guiError = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "void hub",
        LoadingTitle = "void hub",
        LoadingSubtitle = "by void",
        ConfigurationSaving = {Enabled = true, FileName = "voidhubsConfig"}
    })
end)

if not success or not Window then
    local errorMsg = guiError or "Window creation returned nil"
    warn("GUI creation failed: " .. errorMsg)
    createFallbackGui("GUI creation failed: " .. errorMsg)
    return
end

print("GUI window created successfully")

   },

   KeySystem = true, -- Set this to true to use our key system
   KeySettings = {
      Title = "void hub",
      Subtitle = "Key System",
      Note = "nah", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = false, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"https://pastebin.com/raw/utnjFcJy"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Tabs
local HomeTab = Window:CreateTab("🏠 Home")
local CombatTab = Window:CreateTab("⚔️ Combat")
local PlayerTab = Window:CreateTab("👾 Player")
local AntiLockTab = Window:CreateTab("🛡️ Anti-Lock")
local VisualTab = Window:CreateTab("👁️ Visual")
local TrollTab = Window:CreateTab("😈 Troll")
local SettingsTab = Window:CreateTab("⚙️ Settings")

-- Variables
local Multiplier = 1.4
local isMoving = false
local aimbotEnabled = false
local isAimbotActive = false
local targetPlayer = nil
local smoothness = 0.1
local aimbotPrediction = 0.18 -- Default prediction value
local aimbotTargetPart = "HumanoidRootPart" -- Default target part
local orbitEnabled = false
local orbitSpeed = 10
local orbitRadius = 5
local orbitHeight = 3
local flyEnabled = false
local flySpeed = 50
local antiLockEnabled = false
local desyncEnabled = false
local espEnabled = false
local boxEspEnabled = false
local distanceEspEnabled = false
local tracerEspEnabled = false
local nameEspEnabled = false
local infiniteJumpEnabled = false
local flingEnabled = false
local A_2 = false
local espObjects = {}
local boxEspObjects = {}
local distanceEspObjects = {}
local tracerEspObjects = {}
local nameEspObjects = {}
local Config = {
    Select_Color = Color3.fromRGB(0, 255, 0),
    Prediction_Enable = true
}
local SelectionBox = Instance.new("SelectionBox")
SelectionBox.Color3 = Config.Select_Color
SelectionBox.LineThickness = 0.02
SelectionBox.Parent = script

-- Combat Tab: Aimbot
CombatTab:CreateToggle({
    Name = "Aimbot (Q to Lock-On)",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
        print("Aimbot: " .. tostring(Value))
    end
})

CombatTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "Smooth",
    CurrentValue = smoothness,
    Flag = "AimbotSmoothness",
    Callback = function(Value)
        smoothness = Value
        print("Smoothness: " .. Value)
    end
})

CombatTab:CreateInput({
    Name = "Aimbot Prediction",
    Info = "Enter prediction value (e.g., 0.18)",
    PlaceholderText = "0.18",
    Flag = "AimbotPrediction",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then
            aimbotPrediction = num
            print("Aimbot Prediction: " .. num)
        else
            Rayfield:Notify({
                Title = "Invalid Input",
                Content = "Please enter a valid number >= 0",
                Duration = 5
            })
        end
    end
})

CombatTab:CreateDropdown({
    Name = "Aimbot Target Part",
    Options = {"HumanoidRootPart", "Head", "LeftArm", "RightArm"},
    CurrentOption = "HumanoidRootPart",
    Flag = "AimbotTargetPart",
    Callback = function(Option)
        -- Handle both string and table inputs
        local selectedPart = type(Option) == "table" and Option[1] or Option
        aimbotTargetPart = selectedPart
        print("Aimbot Target Part set to: " .. selectedPart)
    end
})

-- Combat Tab: Orbit
CombatTab:CreateToggle({
    Name = "Orbit (with Aimbot)",
    CurrentValue = false,
    Flag = "OrbitToggle",
    Callback = function(Value)
        orbitEnabled = Value
        if not Value then targetPlayer = nil end
        print("Orbit: " .. tostring(Value))
    end
})

CombatTab:CreateSlider({
    Name = "Orbit Speed",
    Range = {1, 20},
    Increment = 0.1,
    Suffix = "Speed",
    CurrentValue = orbitSpeed,
    Flag = "OrbitSpeedSlider",
    Callback = function(Value)
        orbitSpeed = Value
        print("Orbit Speed: " .. Value)
    end
})

CombatTab:CreateSlider({
    Name = "Orbit Radius",
    Range = {1, 20},
    Increment = 0.1,
    Suffix = "Radius",
    CurrentValue = orbitRadius,
    Flag = "OrbitRadiusSlider",
    Callback = function(Value)
        orbitRadius = Value
        print("Orbit Radius: " .. Value)
    end
})

CombatTab:CreateSlider({
    Name = "Orbit Height",
    Range = {1, 10},
    Increment = 0.1,
    Suffix = "Height",
    CurrentValue = orbitHeight,
    Flag = "OrbitHeightSlider",
    Callback = function(Value)
        orbitHeight = Value
        print("Orbit Height: " .. Value)
    end
})

-- Player Tab: Speed
PlayerTab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Flag = "MovementToggle",
    Callback = function(Value)
        isMoving = Value
        print("Speed: " .. tostring(Value))
    end
})

PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {1, 10},
    Increment = 0.1,
    Suffix = "Multiplier",
    CurrentValue = Multiplier,
    Flag = "MultiplierSlider",
    Callback = function(Value)
        Multiplier = Value
        print("Speed Multiplier: " .. Value)
    end
})

-- Player Tab: Infinite Jump
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        infiniteJumpEnabled = Value
        print("Infinite Jump: " .. tostring(Value))
    end
})

-- Player Tab: Fly
PlayerTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "FlyMode_Toggle",
    Callback = function(Value)
        flyEnabled = Value
        local char = player.Character
        if char then
            local humanoid = char:WaitForChild("Humanoid")
            local hrp = char:WaitForChild("HumanoidRootPart")
            if flyEnabled then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
                bodyVelocity.Parent = hrp
                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
                bodyGyro.CFrame = hrp.CFrame
                bodyGyro.Parent = hrp
                humanoid.PlatformStand = true
                print("Fly enabled")
            else
                local velocity = hrp:FindFirstChildOfClass("BodyVelocity")
                local gyro = hrp:FindFirstChildOfClass("BodyGyro")
                if velocity then velocity:Destroy() end
                if gyro then gyro:Destroy() end
                humanoid.PlatformStand = false
                print("Fly disabled")
            end
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {0, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = flySpeed,
    Flag = "FlySpeedSlider",
    Callback = function(Value)
        flySpeed = Value
        print("Fly Speed: " .. Value)
    end
})

-- Anti-Lock Tab
AntiLockTab:CreateToggle({
    Name = "Anti-Lock",
    CurrentValue = false,
    Flag = "AntiLockToggle",
    Callback = function(Value)
        antiLockEnabled = Value
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if antiLockEnabled then
                hrp.Anchored = true
                hrp.LocalTransparencyModifier = 1
                hrp:ClearAllChildren()
            else
                hrp.Anchored = false
                hrp.LocalTransparencyModifier = 0
            end
            print("Anti-Lock: " .. tostring(Value))
        end
    end
})

AntiLockTab:CreateToggle({
    Name = "Desync",
    CurrentValue = false,
    Flag = "DesyncToggle",
    Callback = function(Value)
        desyncEnabled = Value
        print("Desync: " .. tostring(Value))
        Rayfield:Notify({
            Title = "Desync",
            Content = Value and "Desync enabled! Your character will appear laggy to others." or "Desync disabled.",
            Duration = 5
        })
    end
})

-- Desync Logic
local desyncConnection
local function setupDesync()
    if desyncConnection then
        desyncConnection:Disconnect()
        desyncConnection = nil
    end
    if desyncEnabled then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local lastCFrame = hrp.CFrame
            desyncConnection = RunService.Heartbeat:Connect(function()
                if desyncEnabled and hrp and hrp.Parent then
                    local success, err = pcall(function()
                        -- Store original position
                        lastCFrame = hrp.CFrame
                        -- Random offset for desync (small to avoid detection)
                        local offset = Vector3.new(
                            math.random(-5, 5),
                            math.random(-2, 2),
                            math.random(-5, 5)
                        )
                        -- Teleport to offset position briefly
                        hrp.CFrame = lastCFrame + offset
                        -- Immediately revert to original position locally
                        task.wait(0.01)
                        if hrp and hrp.Parent then
                            hrp.CFrame = lastCFrame
                        end
                    end)
                    if not success then
                        warn("Desync error: " .. err)
                        Rayfield:Notify({
                            Title = "Desync Error",
                            Content = "Desync failed: " .. err,
                            Duration = 5
                        })
                        desyncEnabled = false
                    end
                end
            end)
        end
    end
end

player.CharacterAdded:Connect(function(char)
    setupDesync()
    char:WaitForChild("HumanoidRootPart")
    if desyncEnabled then
        setupDesync()
    end
end)

if player.Character then
    setupDesync()
end

-- Visual Tab: ESP
VisualTab:CreateToggle({
    Name = "Highlight ESP",
    CurrentValue = false,
    Flag = "EspToggle",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hl = Instance.new("Highlight", char)
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.OutlineTransparency = 0
                        espObjects[plr] = hl
                    end
                end
            end
        else
            for _, hl in pairs(espObjects) do
                if hl then hl:Destroy() end
            end
            espObjects = {}
        end
        print("Highlight ESP: " .. tostring(Value))
    end
})

VisualTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "BoxEspToggle",
    Callback = function(Value)
        boxEspEnabled = Value
        if boxEspEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local box = Drawing.new("Square")
                        box.Visible = false
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 2
                        box.Transparency = 1
                        box.Filled = false
                        boxEspObjects[plr] = box
                    end
                end
            end
        else
            for _, box in pairs(boxEspObjects) do
                if box then box:Remove() end
            end
            boxEspObjects = {}
        end
        print("Box ESP: " .. tostring(Value))
    end
})

VisualTab:CreateToggle({
    Name = "Distance ESP",
    CurrentValue = false,
    Flag = "DistanceEspToggle",
    Callback = function(Value)
        distanceEspEnabled = Value
        if distanceEspEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local text = Drawing.new("Text")
                        text.Visible = false
                        text.Size = 16
                        text.Color = Color3.fromRGB(255, 255, 255)
                        text.Transparency = 1
                        text.Center = true
                        text.Outline = true
                        distanceEspObjects[plr] = text
                    end
                end
            end
        else
            for _, text in pairs(distanceEspObjects) do
                if text then text:Remove() end
            end
            distanceEspObjects = {}
        end
        print("Distance ESP: " .. tostring(Value))
    end
})

VisualTab:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = false,
    Flag = "TracerEspToggle",
    Callback = function(Value)
        tracerEspEnabled = Value
        if tracerEspEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local line = Drawing.new("Line")
                        line.Visible = false
                        line.Color = Color3.fromRGB(255, 0, 0)
                        line.Thickness = 2
                        line.Transparency = 1
                        tracerEspObjects[plr] = line
                    end
                end
            end
        else
            for _, line in pairs(tracerEspObjects) do
                if line then line:Remove() end
            end
            tracerEspObjects = {}
        end
        print("Tracer ESP: " .. tostring(Value))
    end
})

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "NameEspToggle",
    Callback = function(Value)
        nameEspEnabled = Value
        if nameEspEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player then
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local text = Drawing.new("Text")
                        text.Visible = false
                        text.Size = 16
                        text.Color = Color3.fromRGB(255, 255, 255)
                        text.Transparency = 1
                        text.Center = true
                        text.Outline = true
                        nameEspObjects[plr] = text
                    end
                end
            end
        else
            for _, text in pairs(nameEspObjects) do
                if text then text:Remove() end
            end
            nameEspObjects = {}
        end
        print("Name ESP: " .. tostring(Value))
    end
})

-- Troll Tab: Fling Toggle
TrollTab:CreateToggle({
    Name = "Fling (Click to Fling)",
    CurrentValue = false,
    Flag = "FlingToggle",
    Callback = function(Value)
        flingEnabled = Value
        A_2 = false
        SelectionBox.Adornee = nil
        print("Fling: " .. tostring(Value))
        Rayfield:Notify({
            Title = "Fling",
            Content = Value and "Click a player to fling!" or "Fling disabled.",
            Duration = 5
        })
    end
})

-- Fling Logic
local function setupFling(Character)
    local Root = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")
    local Mouse = player:GetMouse()
    local moveConnection, clickConnection

    local function connectEvents()
        if moveConnection then moveConnection:Disconnect() end
        if clickConnection then clickConnection:Disconnect() end
        moveConnection = Mouse.Move:Connect(function()
            if flingEnabled and Mouse.Target and Mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
                SelectionBox.Adornee = Mouse.Target.Parent
            else
                SelectionBox.Adornee = nil
            end
        end)
        clickConnection = Mouse.Button1Down:Connect(function()
            if flingEnabled and not A_2 and SelectionBox.Adornee then
                A_2 = true
                local TargetCharacter = SelectionBox.Adornee
                local success, err = pcall(function()
                    local BodyThrust = Instance.new('BodyGyro', Root)
                    BodyThrust.CFrame = CFrame.Angles(math.huge, math.huge, math.huge)
                    local LastPos = Root.CFrame
                    while Root and TargetCharacter.HumanoidRootPart do
                        RunService.Heartbeat:Wait()
                        if TargetCharacter.HumanoidRootPart.Velocity.Magnitude <= 100 then
                            Root.CFrame = TargetCharacter.HumanoidRootPart.CFrame * Root.CFrame.Rotation
                            Root.Velocity = Vector3.new()
                        else
                            break
                        end
                    end
                    BodyThrust:Destroy()
                    Root.AssemblyLinearVelocity = Vector3.new()
                    Root.AssemblyAngularVelocity = Vector3.new()
                    Root.CFrame = LastPos
                    Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                end)
                if not success then
                    warn("Fling error: " .. err)
                    Rayfield:Notify({
                        Title = "Fling Error",
                        Content = "Failed to fling: " .. err,
                        Duration = 5
                    })
                end
                A_2 = false
            end
        end)
    end

    connectEvents()
    local toggleConnection = RunService.Heartbeat:Connect(function()
        if flingEnabled and not moveConnection.Connected then
            connectEvents()
        elseif not flingEnabled and moveConnection then
            moveConnection:Disconnect()
            clickConnection:Disconnect()
        end
    end)
    Character.AncestryChanged:Connect(function()
        if moveConnection then moveConnection:Disconnect() end
        if clickConnection then clickConnection:Disconnect() end
        toggleConnection:Disconnect()
    end)
end

player.CharacterAdded:Connect(setupFling)
if player.Character then
    setupFling(player.Character)
end

-- Movement Logic
local function moveCharacter()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        hrp.CFrame = hrp.CFrame + char.Humanoid.MoveDirection * Multiplier
    end
end

RunService.Stepped:Connect(function()
    if isMoving then
        moveCharacter()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftBracket then
        Multiplier = Multiplier + 0.01
        print("Multiplier: " .. Multiplier)
    elseif input.KeyCode == Enum.KeyCode.RightBracket then
        Multiplier = Multiplier - 0.01
        print("Multiplier: " .. Multiplier)
    elseif input.KeyCode == Enum.KeyCode.X then
        isMoving = not isMoving
        print("Speed toggle: " .. tostring(isMoving))
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ESP Player Handling
Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then
        if espEnabled then
            local char = plr.Character or plr.CharacterAdded:Wait()
            if char:FindFirstChild("HumanoidRootPart") then
                local hl = Instance.new("Highlight", char)
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.new(1, 1, 1)
                hl.OutlineTransparency = 0
                espObjects[plr] = hl
            end
        end
        if boxEspEnabled then
            local char = plr.Character or plr.CharacterAdded:Wait()
            if char:FindFirstChild("HumanoidRootPart") then
                local box = Drawing.new("Square")
                box.Visible = false
                box.Color = Color3.fromRGB(255, 0, 0)
                box.Thickness = 2
                box.Transparency = 1
                box.Filled = false
                boxEspObjects[plr] = box
            end
        end
        if distanceEspEnabled then
            local char = plr.Character or plr.CharacterAdded:Wait()
            if char:FindFirstChild("HumanoidRootPart") then
                local text = Drawing.new("Text")
                text.Visible = false
                text.Size = 16
                text.Color = Color3.fromRGB(255, 255, 255)
                text.Transparency = 1
                text.Center = true
                text.Outline = true
                distanceEspObjects[plr] = text
            end
        end
        if tracerEspEnabled then
            local char = plr.Character or plr.CharacterAdded:Wait()
            if char:FindFirstChild("HumanoidRootPart") then
                local line = Drawing.new("Line")
                line.Visible = false
                line.Color = Color3.fromRGB(255, 0, 0)
                line.Thickness = 2
                line.Transparency = 1
                tracerEspObjects[plr] = line
            end
        end
        if nameEspEnabled then
            local char = plr.Character or plr.CharacterAdded:Wait()
            if char:FindFirstChild("HumanoidRootPart") then
                local text = Drawing.new("Text")
                text.Visible = false
                text.Size = 16
                text.Color = Color3.fromRGB(255, 255, 255)
                text.Transparency = 1
                text.Center = true
                text.Outline = true
                nameEspObjects[plr] = text
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if espObjects[plr] then
        espObjects[plr]:Destroy()
        espObjects[plr] = nil
    end
    if boxEspObjects[plr] then
        boxEspObjects[plr]:Remove()
        boxEspObjects[plr] = nil
    end
    if distanceEspObjects[plr] then
        distanceEspObjects[plr]:Remove()
        distanceEspObjects[plr] = nil
    end
    if tracerEspObjects[plr] then
        tracerEspObjects[plr]:Remove()
        tracerEspObjects[plr] = nil
    end
    if nameEspObjects[plr] then
        nameEspObjects[plr]:Remove()
        nameEspObjects[plr] = nil
    end
end)

-- Render Loop
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local localChar = player.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    -- Orbit
    if orbitEnabled and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local targetPos = targetPlayer.Character.HumanoidRootPart.Position
            local angle = tick() * orbitSpeed
            local xOffset = math.cos(angle) * orbitRadius
            local zOffset = math.sin(angle) * orbitRadius
            hrp.CFrame = CFrame.new(targetPos) * CFrame.new(xOffset, orbitHeight, zOffset)
        end
    end

    -- Aimbot
    if isAimbotActive and targetPlayer and targetPlayer.Character then
        local success, err = pcall(function()
            local targetPart = targetPlayer.Character:FindFirstChild(aimbotTargetPart)
            if targetPart then
                local targetVelocity = targetPart.Velocity
                local predictedPos = targetPart.Position + (targetVelocity * aimbotPrediction)
                local newCFrame = CFrame.new(cam.CFrame.Position, predictedPos)
                cam.CFrame = cam.CFrame:Lerp(newCFrame, smoothness)
            else
                error("Target part " .. aimbotTargetPart .. " not found on character")
            end
        end)
        if not success then
            warn("Aimbot error: " .. err)
            Rayfield:Notify({
                Title = "Aimbot Error",
                Content = "Invalid target part: " .. aimbotTargetPart .. ". Please select another part.",
                Duration = 5
            })
            isAimbotActive = false -- Disable aimbot to prevent further errors
            targetPlayer = nil
        end
    end

    -- ESP Updates
    for plr, box in pairs(boxEspObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local head = char:FindFirstChild("Head")
            if head then
                local headPos, onScreen = cam:WorldToViewportPoint(head.Position)
                local bottomPos = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                if onScreen then
                    local height = math.abs(headPos.Y - bottomPos.Y)
                    local width = height * 0.6
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(headPos.X - width / 2, headPos.Y - height / 2)
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end

    for plr, text in pairs(distanceEspObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and localHrp then
            local hrp = char.HumanoidRootPart
            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance = (localHrp.Position - hrp.Position).Magnitude
                text.Text = string.format("%.1f studs", distance)
                text.Position = Vector2.new(pos.X, pos.Y)
                text.Visible = true
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end

    for plr, line in pairs(tracerEspObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and localHrp then
            local hrp = char.HumanoidRootPart
            local targetPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local fromPos = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                line.From = fromPos
                line.To = Vector2.new(targetPos.X, targetPos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end

    for plr, text in pairs(nameEspObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local head = char:FindFirstChild("Head")
            if head then
                local headPos, onScreen = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
                if onScreen then
                    local displayName = plr.DisplayName or plr.Name
                    text.Text = displayName
                    text.Position = Vector2.new(headPos.X, headPos.Y)
                    text.Visible = true
                else
                    text.Visible = false
                end
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end
end)

-- Aimbot Logic
local function getClosestPlayer()
    local closest, minDist = nil, math.huge
    local cam = workspace.CurrentCamera
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild(aimbotTargetPart) and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local pos, onScreen = cam:WorldToViewportPoint(plr.Character[aimbotTargetPart].Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and aimbotEnabled and input.KeyCode == Enum.KeyCode.Q then
        isAimbotActive = not isAimbotActive
        targetPlayer = isAimbotActive and getClosestPlayer() or nil
        print("Aimbot lock: " .. tostring(isAimbotActive))
    end
end)
