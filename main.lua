local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "RIMURU HUB  - Arcane Conquest",
    SubTitle = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    TabWidth = 160,
    Size = UDim2.fromOffset(550, 550),
    Acrylic = false,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({
    Title = "Main",
    Icon = "rbxassetid://123456"
})

local FarmingTab = Window:AddTab({
    Title = "AuToFarm",
    Icon = "rbxassetid://654321"
})

local AutoReJoIn = Window:AddTab({
    Title = "AutoReJoIn",
    Icon = "rbxassetid://654321"
})
Window:SelectTab(1)

local AutoFarmSection = FarmingTab:AddSection("AUTOFARM")
local AutoReJoInSection = AutoReJoIn:AddSection("AUTOREJOIN")
local MainSection = MainTab:AddSection("MAIN SETTINGS")
local BOOSTFPS = MainTab:AddSection("BOOST FPS")

local AutoFarmEnabled = false
local AutoReJoInEnabled = false
local BOOSTFPSEnabled = false

local selectedPartyOption = 1
if pcall(function()
    readfile("PartyOptionConfig.txt")
end) then
    local data = readfile("PartyOptionConfig.txt")
    selectedPartyOption = tonumber(data) or 1
end

local partyDropdown = AutoReJoInSection:AddDropdown("PartyOption", {
    Title = "Party Option",
    Description = "เลือกตัวเลือกปาร์ตี้ (1-5)",
    Values = {"1", "2", "3", "4", "5"},
    Multi = false,
    Default = tostring(selectedPartyOption)
})

partyDropdown:OnChanged(function(value)
    selectedPartyOption = tonumber(value) or 1
    print("เลือก Party Option:", selectedPartyOption)
    writefile("PartyOptionConfig.txt", tostring(selectedPartyOption))
end)

if pcall(function()
    readfile("AutoFarmConfig.txt")
end) then
    AutoFarmEnabled = readfile("AutoFarmConfig.txt") == "true"
end

if pcall(function()
    readfile("AutoReJoInConfig.txt")
end) then
    AutoReJoInEnabled = readfile("AutoReJoInConfig.txt") == "true"
end

if pcall(function()
    readfile("BOOSTFPSE.txt")
end) then
    BOOSTFPSEnabled = readfile("BOOSTFPSE.txt") == "true"
end

AutoReJoInSection:AddToggle("AutoReJoInToggle", {
    Title = "AutoReJoIn",
    Description = "เปิด/ปิดระบบ AutoReJoIn",
    Default = AutoReJoInEnabled,
    Callback = function(state)
        AutoReJoInEnabled = state
        writefile("AutoReJoInConfig.txt", tostring(state))
        if AutoReJoInEnabled then
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local GuiService = game:GetService("GuiService")
            local PlaceId = 125503319883299
            local JobId = ""

            local function rejoinGame()
                if #Players:GetPlayers() <= 1 then
                    Players.LocalPlayer:Kick("\nRejoining...")
                    wait(1)
                    TeleportService:Teleport(PlaceId, Players.LocalPlayer)
                else
                    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
                end
            end

            local function autoRejoin()
                GuiService.ErrorMessageChanged:Connect(function()
                    rejoinGame()
                end)
                print("Auto rejoin enabled")
            end

            autoRejoin()

            local ReplicatedStorage = game:GetService("ReplicatedStorage")

            local function createAndStartParty()

                local args = {
                    [1] = "Corrupted Forest",
                    [2] = selectedPartyOption - 1,
                    [3] = 1,
                    [4] = 0
                }

                local PartyCreate = ReplicatedStorage:FindFirstChild("PartyCreate")
                local PartyStart = ReplicatedStorage:FindFirstChild("PartyStart")

                if PartyCreate and PartyStart then
                    local success, errorMessage = pcall(function()
                        PartyCreate:FireServer(unpack(args))
                        wait(1)
                        PartyStart:FireServer()
                    end)

                    if not success then
                        warn("Error in party creation/start: " .. errorMessage)
                    end
                else
                    warn("PartyCreate or PartyStart not found in ReplicatedStorage!")
                end
            end

            if game.PlaceId == PlaceId then
                createAndStartParty()
            end
        end
    end
})

AutoFarmSection:AddToggle("AutoFarmToggle", {
    Title = "AutoFarm",
    Description = "เปิด/ปิดระบบ AutoFarm",
    Default = AutoFarmEnabled,
    Callback = function(state)
        AutoFarmEnabled = state
        writefile("AutoFarmConfig.txt", tostring(state))
    end
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = nil
local blackFrame = nil

BOOSTFPS:AddToggle("AutoFarmToggle", {
    Title = "BOOSTFPS",
    Description = "เปิด/ปิดระบบ BOOSTFPS",
    Default = BOOSTFPSEnabled,
    Callback = function(state)
        BOOSTFPSEnabled = state
        writefile("BOOSTFPSE.txt", tostring(state))

        if BOOSTFPSEnabled then
            screenGui = Instance.new("ScreenGui")
            screenGui.Name = "BlackScreenGui"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = PlayerGui

            blackFrame = Instance.new("Frame")
            blackFrame.Name = "BlackFrame"
            blackFrame.Size = UDim2.new(1, 0, 10000000000, 0)
            blackFrame.Position = UDim2.new(0, 0, 0, 0)
            blackFrame.BackgroundColor3 = Color3.new(0, 0, 0)
            blackFrame.BorderSizePixel = 0
            blackFrame.Parent = screenGui

            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
        else
            if screenGui then
                screenGui:Destroy()
            end

            game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        end
    end
})

MainSection:AddButton({
    Title = "GOTO LOBBY",
    Description = "ไปหน้า LOBBY",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = 125503319883299

        local function teleportToPlace()
            local success, errorMessage = pcall(function()
                TeleportService:Teleport(placeId, game.Players.LocalPlayer)
            end)

            if not success then
                warn("Teleport failed: " .. errorMessage)
            else
                print("Successfully teleported to place: " .. placeId)
            end
        end

        teleportToPlace()

    end
})

local Player = Players.LocalPlayer

local function waitForCharacter()
    local success, result = pcall(function()
        return Player.Character or Player.CharacterAdded:Wait()
    end)

    if success then
        local HRP = result:WaitForChild("HumanoidRootPart")
        return result, HRP
    else
        warn("Error in waitForCharacter: " .. result)
        return nil, nil
    end
end

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local smoothness = 0.3

local Character, HRP = waitForCharacter()

local ATTACK_INTERVAL = 0
local lastAttackTime = tick()
local currentTarget = nil
local lastTargetPosition = nil

local fallbackPosition = Vector3.new(226.298584, 12.8325548, -920.831055)
local forbiddenPosition = Vector3.new(-280.000122, 185.000092, -1599.99976)

function getGroundY()
    local success, result = pcall(function()
        local rayOrigin = HRP.Position
        local rayDirection = Vector3.new(0, -50, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        if rayResult then
            return rayResult.Position.Y + 1
        else
            return HRP.Position.Y + (240 - HRP.Position.Y) * smoothness
        end
    end)

    if success then
        return result
    else
        warn("Error in getGroundY: " .. result)
        return HRP.Position.Y
    end
end

function TP(targetPosition)
    if not AutoFarmEnabled then
        return
    end

    if lastTargetPosition and (targetPosition - lastTargetPosition).Magnitude < 1 then
        return
    end

    lastTargetPosition = targetPosition

    local success, errorMessage = pcall(function()
        local targetY = getGroundY()
        local finalTarget = Vector3.new(targetPosition.X, targetY, targetPosition.Z)

        if (finalTarget - forbiddenPosition).Magnitude < 5 and
            (not currentTarget or currentTarget.Name ~= "Corrupting Crystal") then
            return
        end

        local Distance = (finalTarget - HRP.Position).Magnitude
        local Speed = 125
        local duration = Distance / Speed

        if duration < 1 then
            duration = 2
        end

        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tweenGoal = {
            CFrame = CFrame.new(finalTarget)
        }

        local tween = TweenService:Create(HRP, tweenInfo, tweenGoal)
        tween:Play()

    end)

    if not success then
        warn("Error in TP function: " .. errorMessage)
    end
end

function atk()
    if not AutoFarmEnabled then
        return
    end

    if tick() - lastAttackTime >= ATTACK_INTERVAL then
        local success, errorMessage = pcall(function()
            ReplicatedStorage:WaitForChild("Click"):FireServer(true)
            ReplicatedStorage:WaitForChild("Spell"):FireServer("Spell1", Vector3.new(0, 67.8, 0), Vector3.zero, 0)
            ReplicatedStorage:WaitForChild("Spell"):FireServer("Spell2", Vector3.new(0, 67.8, 0), Vector3.zero, 0)
            ReplicatedStorage:WaitForChild("Spell"):FireServer("Spell3", Vector3.new(0, 67.8, 0), Vector3.zero, 0)
        end)

        if not success then
            warn("Error in atk function: " .. errorMessage)
        end

        lastAttackTime = tick()
    end
end

function findClosestEnemy()
    if not AutoFarmEnabled then
        return nil
    end

    local closestEnemy = nil
    local closestDistance = math.huge

    local success, errorMessage = pcall(function()
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:IsA("Model") then
                local humanoid = v:FindFirstChildOfClass("Humanoid")
                local rootPart = v:FindFirstChild("HumanoidRootPart")

                if humanoid and humanoid.Health > 0 and rootPart and not v.Name:find("Defeated") then
                    local enemyPos = rootPart.Position
                    local distance = (HRP.Position - enemyPos).Magnitude

                    if (enemyPos - forbiddenPosition).Magnitude > 5 and distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = v
                    end
                end

                if v.Name == "Timelost Sorcerer" then
                    local targetPosition = Vector3.new(346.67984, 134.3526 + 10, -1260.32996)
                    local distance = (HRP.Position - targetPosition).Magnitude
                    local speed = 125
                    local duration = distance / speed

                    if duration < 0.5 then
                        duration = 0.5
                    end

                    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                    local tweenGoal = {
                        CFrame = CFrame.new(targetPosition)
                    }

                    local tween = TweenService:Create(HRP, tweenInfo, tweenGoal)
                    tween:Play()

                    closestEnemy = v
                end

                if v.Name == "Corrupting Crystal" and v:FindFirstChild("HumanoidRootPart") and
                    not v.Name:find("Defeated") then
                    local crystalPos = v.HumanoidRootPart.Position
                    local distance = (HRP.Position - crystalPos).Magnitude

                    if distance < closestDistance then
                        closestDistance = distance
                        closestEnemy = v
                    end
                end
            end
        end
    end)

    if not success then
        warn("Error in findClosestEnemy function: " .. errorMessage)
    end

    return closestEnemy
end

RunService.RenderStepped:Connect(function()
    if not AutoFarmEnabled then
        return
    end
    local targetY = getGroundY()
    HRP.CFrame = HRP.CFrame:Lerp(CFrame.new(HRP.Position.X, targetY, HRP.Position.Z), 0.1)
end)

Player.CharacterAdded:Connect(function()
    Character, HRP = waitForCharacter()
end)

RunService.Heartbeat:Connect(function()
    if AutoFarmEnabled then
        ReplicatedStorage:WaitForChild("Start"):FireServer()
        local target = findClosestEnemy()
        if target then
            local targetPosition = target:FindFirstChild("HumanoidRootPart") and target.HumanoidRootPart.Position or nil
            if targetPosition and (not lastTargetPosition or (targetPosition - lastTargetPosition).Magnitude > 1) then
                TP(targetPosition)
            end
        else
            TP(fallbackPosition)
        end

        atk()
    end
end)

-- Remote Blocker
local blocklist = {}
local blockTime = 1
local canBlock = true

local function BlockRemote(remote)
    assert(typeof(remote) == "Instance" or typeof(remote) == "string",
        "Instance | string expected, got " .. typeof(remote))
    blocklist[remote] = true
end

local function UnblockRemote(remote)
    blocklist[remote] = nil
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if blocklist[self] and (method == "FireServer" or method == "InvokeServer") then
        return
    end

    return old(self, ...)
end)

setreadonly(mt, true)

BlockRemote(game:GetService("ReplicatedStorage"):WaitForChild("Damage"))
BlockRemote("Spell")

local function startBlocking()
    if canBlock then
        canBlock = false
        BlockRemote(game:GetService("ReplicatedStorage"):WaitForChild("Damage"))
        BlockRemote("Spell")

        task.wait(blockTime)

        UnblockRemote(game:GetService("ReplicatedStorage"):WaitForChild("Damage"))
        UnblockRemote("Spell")
        canBlock = true
    end
end

while true do
    task.wait(0.1)
    startBlocking()
end
