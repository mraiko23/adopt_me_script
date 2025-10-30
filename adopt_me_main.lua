--[[
    🎮 ADOPT ME AUTOMATION SCRIPT
    🚀 Автоматизация для игры Adopt Me в Roblox
    ⚡ Функции: авто-кормление, телепорт, фарминг, торговля
--]]

-- Загрузка библиотек
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Переменные
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Настройки
local Config = {
    AutoFeed = false,
    AutoPlay = false,
    AutoCollectMoney = false,
    AutoTrade = false,
    FeedInterval = 30, -- секунды
    PlayInterval = 45,
    WalkSpeed = 50,
    JumpPower = 100,
    Notifications = true
}

-- GUI Создание
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local AutoFeedButton = Instance.new("TextButton")
local AutoPlayButton = Instance.new("TextButton")
local TeleportFrame = Instance.new("Frame")
local SpeedSlider = Instance.new("TextBox")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")

-- GUI Настройки
ScreenGui.Name = "AdoptMeGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Основное окно
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Active = true
MainFrame.Draggable = true

-- Скругленные углы
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 15)
Corner.Parent = MainFrame

-- Заголовок
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎮 ADOPT ME SCRIPT v2.0"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18

-- Кнопка автокормления
AutoFeedButton.Name = "AutoFeedButton"
AutoFeedButton.Parent = MainFrame
AutoFeedButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
AutoFeedButton.Position = UDim2.new(0.05, 0, 0.15, 0)
AutoFeedButton.Size = UDim2.new(0.9, 0, 0, 40)
AutoFeedButton.Font = Enum.Font.Gotham
AutoFeedButton.Text = "🍎 Авто-кормление: ВЫКЛ"
AutoFeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFeedButton.TextSize = 14

local AutoFeedCorner = Instance.new("UICorner")
AutoFeedCorner.CornerRadius = UDim.new(0, 8)
AutoFeedCorner.Parent = AutoFeedButton

-- Кнопка автоигры
AutoPlayButton.Name = "AutoPlayButton"
AutoPlayButton.Parent = MainFrame
AutoPlayButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
AutoPlayButton.Position = UDim2.new(0.05, 0, 0.25, 0)
AutoPlayButton.Size = UDim2.new(0.9, 0, 0, 40)
AutoPlayButton.Font = Enum.Font.Gotham
AutoPlayButton.Text = "🎮 Авто-игра: ВЫКЛ"
AutoPlayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoPlayButton.TextSize = 14

local AutoPlayCorner = Instance.new("UICorner")
AutoPlayCorner.CornerRadius = UDim.new(0, 8)
AutoPlayCorner.Parent = AutoPlayButton

-- Функции уведомлений
local function SendNotification(title, text, duration)
    if not Config.Notifications then return end
    
    local NotificationGui = Instance.new("ScreenGui")
    local NotificationFrame = Instance.new("Frame")
    local NotificationTitle = Instance.new("TextLabel")
    local NotificationText = Instance.new("TextLabel")
    
    NotificationGui.Name = "NotificationGui"
    NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Parent = NotificationGui
    NotificationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Position = UDim2.new(1, 10, 0.8, 0)
    NotificationFrame.Size = UDim2.new(0, 300, 0, 80)
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 10)
    NotifCorner.Parent = NotificationFrame
    
    NotificationTitle.Parent = NotificationFrame
    NotificationTitle.BackgroundTransparency = 1
    NotificationTitle.Size = UDim2.new(1, 0, 0.5, 0)
    NotificationTitle.Font = Enum.Font.GothamBold
    NotificationTitle.Text = title
    NotificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotificationTitle.TextSize = 14
    
    NotificationText.Parent = NotificationFrame
    NotificationText.BackgroundTransparency = 1
    NotificationText.Position = UDim2.new(0, 0, 0.5, 0)
    NotificationText.Size = UDim2.new(1, 0, 0.5, 0)
    NotificationText.Font = Enum.Font.Gotham
    NotificationText.Text = text
    NotificationText.TextColor3 = Color3.fromRGB(200, 200, 200)
    NotificationText.TextSize = 12
    
    -- Анимация появления
    local TweenIn = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.7, 0, 0.8, 0)}
    )
    TweenIn:Play()
    
    -- Автоудаление
    wait(duration or 3)
    local TweenOut = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 10, 0.8, 0)}
    )
    TweenOut:Play()
    TweenOut.Completed:Connect(function()
        NotificationGui:Destroy()
    end)
end

-- Функция поиска питомцев
local function FindPets()
    local pets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Pet" and obj:FindFirstChild("Humanoid") then
            table.insert(pets, obj)
        end
    end
    return pets
end

-- Функция кормления питомцев
local function FeedPets()
    local pets = FindPets()
    for _, pet in pairs(pets) do
        if pet:FindFirstChild("Humanoid") and pet.Humanoid.Health > 0 then
            -- Логика кормления (зависит от игры)
            local args = {
                [1] = "Feed",
                [2] = pet,
                [3] = "Apple" -- или другая еда
            }
            
            pcall(function()
                ReplicatedStorage.API:FindFirstChild("PetAPI/FeedPet"):InvokeServer(unpack(args))
            end)
        end
    end
end

-- Функция игры с питомцами
local function PlayWithPets()
    local pets = FindPets()
    for _, pet in pairs(pets) do
        if pet:FindFirstChild("Humanoid") and pet.Humanoid.Health > 0 then
            local args = {
                [1] = "Play",
                [2] = pet
            }
            
            pcall(function()
                ReplicatedStorage.API:FindFirstChild("PetAPI/PlayWithPet"):InvokeServer(unpack(args))
            end)
        end
    end
end

-- Функция сбора денег
local function CollectMoney()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Money" or obj.Name == "Cash" then
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
            end
        end
    end
end

-- Телепорт функции
local TeleportLocations = {
    ["Дом"] = Vector3.new(-250, 3, -30),
    ["Магазин"] = Vector3.new(-120, 3, -450),
    ["Школа"] = Vector3.new(-650, 20, 250),
    ["Больница"] = Vector3.new(320, 15, 470),
    ["Парк"] = Vector3.new(-950, 3, -500),
    ["Пляж"] = Vector3.new(-1600, 3, -100)
}

local function TeleportTo(position)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(position)
        SendNotification("Телепорт", "Перемещение выполнено!", 2)
    end
end

-- Создание кнопок телепортации
local yPos = 0.35
for locationName, position in pairs(TeleportLocations) do
    local TeleportButton = Instance.new("TextButton")
    TeleportButton.Name = locationName .. "Button"
    TeleportButton.Parent = MainFrame
    TeleportButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    TeleportButton.Position = UDim2.new(0.05, 0, yPos, 0)
    TeleportButton.Size = UDim2.new(0.42, 0, 0, 35)
    TeleportButton.Font = Enum.Font.Gotham
    TeleportButton.Text = "📍 " .. locationName
    TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportButton.TextSize = 12
    
    local TeleportCorner = Instance.new("UICorner")
    TeleportCorner.CornerRadius = UDim.new(0, 6)
    TeleportCorner.Parent = TeleportButton
    
    TeleportButton.MouseButton1Click:Connect(function()
        TeleportTo(position)
    end)
    
    yPos = yPos + 0.08
    if yPos > 0.7 then
        yPos = 0.35
        -- Создаем вторую колонку
        TeleportButton.Position = UDim2.new(0.53, 0, 0.35, 0)
    end
end

-- Обработчики событий кнопок
AutoFeedButton.MouseButton1Click:Connect(function()
    Config.AutoFeed = not Config.AutoFeed
    if Config.AutoFeed then
        AutoFeedButton.Text = "🍎 Авто-кормление: ВКЛ"
        AutoFeedButton.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
        SendNotification("Авто-кормление", "Включено!", 2)
    else
        AutoFeedButton.Text = "🍎 Авто-кормление: ВЫКЛ"
        AutoFeedButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
        SendNotification("Авто-кормление", "Выключено!", 2)
    end
end)

AutoPlayButton.MouseButton1Click:Connect(function()
    Config.AutoPlay = not Config.AutoPlay
    if Config.AutoPlay then
        AutoPlayButton.Text = "🎮 Авто-игра: ВКЛ"
        AutoPlayButton.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
        SendNotification("Авто-игра", "Включено!", 2)
    else
        AutoPlayButton.Text = "🎮 Авто-игра: ВЫКЛ"
        AutoPlayButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
        SendNotification("Авто-игра", "Выключено!", 2)
    end
end)

-- Основные циклы автоматизации
spawn(function()
    while true do
        if Config.AutoFeed then
            FeedPets()
        end
        wait(Config.FeedInterval)
    end
end)

spawn(function()
    while true do
        if Config.AutoPlay then
            PlayWithPets()
        end
        wait(Config.PlayInterval)
    end
end)

spawn(function()
    while true do
        if Config.AutoCollectMoney then
            CollectMoney()
        end
        wait(5)
    end
end)

-- Улучшение персонажа
if Character and Character:FindFirstChild("Humanoid") then
    Character.Humanoid.WalkSpeed = Config.WalkSpeed
    Character.Humanoid.JumpPower = Config.JumpPower
end

-- Обновление при респавне
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    
    Humanoid.WalkSpeed = Config.WalkSpeed
    Humanoid.JumpPower = Config.JumpPower
end)

-- Клавиши быстрого доступа
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.AutoFeed = not Config.AutoFeed
        AutoFeedButton:Fire() -- Имитируем клик
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Config.AutoPlay = not Config.AutoPlay
        AutoPlayButton:Fire()
    elseif input.KeyCode == Enum.KeyCode.H then
        TeleportTo(TeleportLocations["Дом"])
    end
end)

-- Приветственное сообщение
SendNotification("🎮 ADOPT ME SCRIPT", "Скрипт успешно загружен! F1/F2 - быстрые клавиши", 5)

print("🚀 Adopt Me Script загружен успешно!")
print("📋 Горячие клавиши:")
print("   F1 - Переключить авто-кормление")
print("   F2 - Переключить авто-игру")
print("   H  - Телепорт домой")