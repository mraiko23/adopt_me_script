-- Обновленный скрипт с улучшенной совместимостью для Delta-X

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Settings = {
    Enabled = false,
    IsVisible = true,
    FarmSpeed = 10,
    PickupRadius = 25,
    CollectRareItemsOnly = false,
    AutoResetChildren = false,
    ChildrenRadius = 10,
    AutoResetPets = true,
    PetsRadius = 10,
    AntiAfkEnable = true,
    MovementInterval = 5
}

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid")
local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")

-- Функция создания красивого UI меню
local function CreateUI()
    if PlayerGui:FindFirstChild("AutoFarmUI") then
        PlayerGui.AutoFarmUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoFarmUI"
    ScreenGui.DisplayOrder = 1000
    ScreenGui.ResetOnSpellEnabled = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0, 50)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = Settings.IsVisible and 0.1 or 0.9
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- Создание заголовка
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Name = "TitleFrame"
    TitleFrame.Size = UDim2.new(1, 0, 0, 40)
    TitleFrame.Position = UDim2.new(0, 0, 0, 0)
    TitleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleFrame.BorderSizePixel = 0
    TitleFrame.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.FontFace = Font.new("rbxasset://fonts/families/Gotham.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    TitleLabel.Text = "Adopt Me Auto-Farm"
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 0
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.TextStrokeTransparency = 0.5
    TitleLabel.Parent = TitleFrame

    -- Добавление элементов управления
    MainFrame.ChildAdded:Connect(function(child)
        if child.Name == "ToggleButton" or child.Name == "HideButton" then return end

        local offsetY = 0
        for _, existingChild in ipairs(MainFrame:GetChildren()) do
            if existingChild.Name ~= "TitleFrame" and existingChild.Name ~= "UICorner" then
                offsetY = offsetY + existingChild.Size.Y.Offset + 10
            end
        end

        child.Position = UDim2.new(0.05, 0, 0, offsetY)
    end)

    -- Строка настройки скорости
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Name = "SpeedFrame"
    SpeedFrame.Size = UDim2.new(0.9, 0, 0, 50)
    SpeedFrame.Position = UDim2.new(0.05, 0, 0, 50)
    SpeedFrame.BackgroundTransparency = 1
    SpeedFrame.LayoutOrder = 1
    SpeedFrame.Parent = MainFrame

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
    SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
    SpeedLabel.FontFace = Font.new("rbxasset://fonts/families/Gotham.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    SpeedLabel.Text = "Farm Speed:"
    SpeedLabel.TextSize = 14
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Parent = SpeedFrame

    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Size = UDim2.new(0.35, 0, 0, 20)
    SpeedSlider.Position = UDim2.new(0.6, 0, 0.35, 0)
    SpeedSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Parent = SpeedFrame

    local SpeedBar = Instance.new("Frame")
    SpeedBar.Name = "SpeedBar"
    SpeedBar.Size = UDim2.new(0, 10, 0, 20)
    SpeedBar.Position = UDim2.new(0, 0, 0, 0)
    SpeedBar.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
    SpeedBar.BorderSizePixel = 0
    SpeedBar.Parent = SpeedSlider

    local SpeedValueLabel = Instance.new("TextLabel")
    SpeedValueLabel.Name = "SpeedValueLabel"
    SpeedValueLabel.Size = UDim2.new(0.15, 0, 0.9, 0)
    SpeedValueLabel.Position = UDim2.new(0.8, 0, 0.05, 0)
    SpeedValueLabel.FontFace = Font.new("rbxasset://fonts/families/Gotham.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    SpeedValueLabel.Text = "10"
    SpeedValueLabel.TextSize = 12
    SpeedValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedValueLabel.BackgroundTransparency = 1
    SpeedValueLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedValueLabel.Parent = SpeedFrame

    local SpeedIndicator = Instance.new("Frame")
    SpeedIndicator.Name = "SpeedIndicator"
    SpeedIndicator.Size = UDim2.new(0, 15, 0, 15)
    SpeedIndicator.Position = UDim2.new(0.1, 0, 0.2, 0)
    SpeedIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SpeedIndicator.BorderSizePixel = 0
    SpeedIndicator.Parent = SpeedSlider

    -- Создание кнопки включения/выключения
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.85, 0)
    ToggleButton.FontFace = Font.new("rbxasset://fonts/families/Gotham.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    ToggleButton.Text = Settings.Enabled and "FARM DISABLED" or "ENABLE FARM"
    ToggleButton.TextSize = 14
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = MainFrame

    -- Создание кнопки скрытия/показа
    local HideButton = Instance.new("TextButton")
    HideButton.Name = "HideButton"
    HideButton.Size = UDim2.new(0.8, 0, 0, 30)
    HideButton.Position = UDim2.new(0.1, 0, 0.95, 0)
    HideButton.FontFace = Font.new("rbxasset://fonts/families/Gotham.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    HideButton.Text = "HIDE"
    HideButton.TextSize = 14
    HideButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    HideButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    HideButton.BorderSizePixel = 0
    HideButton.Parent = MainFrame

    -- Обработчики событий для кнопок
    ToggleButton.MouseButton1Click:Connect(function()
        Settings.Enabled = not Settings.Enabled
        ToggleButton.Text = Settings.Enabled and "FARM DISABLED" or "ENABLE FARM"
        ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
        
        if Settings.Enabled then
            startAutoFarm()
        end
    end)

    HideButton.MouseButton1Click:Connect(function()
        Settings.IsVisible = not Settings.IsVisible
        MainFrame.BackgroundTransparency = Settings.IsVisible and 0.1 or 0.9
        HideButton.Text = Settings.IsVisible and "HIDE" or "SHOW"
    end)

    -- Обработчики для слайдера скорости
    local dragging = false
    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSpeedSlider(input)
        end
    end)

    SpeedSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("RunService").Heartbeat:Connect(function()
        if dragging then
            dragInput = UserInputService:GetMouseLocation()
            updateSpeedSlider(dragInput)
        end
    end)

    local function updateSpeedSlider(mousePosition)
        local absX = SpeedSlider.AbsolutePosition.X
        local absWidth = SpeedSlider.AbsoluteSize.X
        
        local percentage = math.clamp((mousePosition.X - absX) / absWidth, 0, 1)
        SpeedBar.Size = UDim2.new(percentage, 0, 1, 0)
        
        Settings.FarmSpeed = math.round(1 + percentage * 24)
        SpeedValueLabel.Text = Settings.FarmSpeed
    end
end

-- Основная функция автофарма
local function startAutoFarm()
    if Settings.Enabled then
        spawn(function()
            while Settings.Enabled and Character and Character:IsDescendantOf(workspace) do
                -- Обновление человека и частей тела
                Humanoid = Character:FindFirstChildOfClass("Humanoid")
                RootPart = Character:FindFirstChild("HumanoidRootPart")

                if not Humanoid or not RootPart then wait(1) continue end

                -- Проверка на наличие анти-АФК
                if Settings.AntiAfkEnable then
                    doAntiAfk()
                end

                -- Поиск и сбор предметов
                doCollectItems()

                -- Автоперенос детей
                if Settings.AutoResetChildren then
                    doChildReset()
                end

                -- Автоперенос питомцев
                if Settings.AutoResetPets then
                    doPetReset()
                end

                wait(1)
            end
        end)
    end
end

local function doAntiAfk()
    local randomPos = RootPart.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    Humanoid:MoveTo(randomPos)
    wait(Settings.MovementInterval)
end

local function doCollectItems()
    local collectibles = workspace:FindFirstChild("Collectibles") or workspace:FindFirstChild("Drops")
    
    if collectibles then
        for _, item in ipairs(collectibles:GetChildren()) do
            if item:IsA("BasePart") or item:IsA("MeshPart") then
                local distance = (item.Position - RootPart.Position).Magnitude
                
                if distance <= Settings.PickupRadius then
                    if not Settings.CollectRareItemsOnly or #item:GetChildren() > 0 then
                        Humanoid:MoveTo(item.Position)
                        wait(0.5)
                        Humanoid:MoveTo(RootPart.Position)  -- Возвращаемся в исходное положение
                        wait(0.5)
                    end
                end
            end
        end
    end
end

local function doChildReset()
    local children = workspace:FindFirstChild("Children")
    
    if children then
        for _, child in ipairs(children:GetChildren()) do
            if child.Name:find(Player.Name.."'s Child") and child:IsA("Model") then
                local childRoot = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Torso")
                
                if childRoot then
                    local distance = (childRoot.Position - RootPart.Position).Magnitude
                    
                    if distance > Settings.ChildrenRadius then
                        Humanoid:MoveTo(childRoot.Position)
                        wait(0.5)
                        Humanoid:MoveTo(RootPart.Position)  -- Возвращаемся в исходное положение
                        wait(0.5)
                    end
                end
            end
        end
    end
end

local function doPetReset()
    local pets = workspace:FindFirstChild("Pets")
    
    if pets then
        for _, pet in ipairs(pets:GetChildren()) do
            if pet.Name:find(Player.Name.."'s Pet") and pet:IsA("Model") then
                local petRoot = pet:FindFirstChild("HumanoidRootPart") or pet:FindFirstChild("Torso")
                
                if petRoot then
                    local distance = (petRoot.Position - RootPart.Position).Magnitude
                    
                    if distance > Settings.PetsRadius then
                        Humanoid:MoveTo(petRoot.Position)
                        wait(0.5)
                        Humanoid:MoveTo(RootPart.Position)  -- Возвращаемся в исходное положение
                        wait(0.5)
                    end
                end
            end
        end
    end
end

-- Главная функция инициализации
local function Init()
    CreateUI()
    
    -- Обработчики ввода
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F5 then
            Settings.IsVisible = not Settings.IsVisible
            if PlayerGui:FindFirstChild("AutoFarmUI") then
                local MainFrame = PlayerGui.AutoFarmUI:FindFirstChild("MainFrame")
                if MainFrame then
                    MainFrame.BackgroundTransparency = Settings.IsVisible and 0.1 or 0.9
                    local HideButton = MainFrame:FindFirstChild("HideButton")
                    if HideButton then
                        HideButton.Text = Settings.IsVisible and "HIDE" or "SHOW"
                    end
                end
            end
        elseif input.KeyCode == Enum.KeyCode.F6 then
            Settings.Enabled = not Settings.Enabled
            if PlayerGui:FindFirstChild("AutoFarmUI") then
                local MainFrame = PlayerGui.AutoFarmUI:FindFirstChild("MainFrame")
                local ToggleButton = MainFrame:FindFirstChild("ToggleButton")
                if ToggleButton then
                    ToggleButton.Text = Settings.Enabled and "FARM DISABLED" or "ENABLE FARM"
                    ToggleButton.BackgroundColor3 = Settings.Enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
                end
            end
        end
    end)
    
    -- Обработчик обновления характера
    Player.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        wait(1)
        Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
    
        if Settings.Enabled then
            startAutoFarm()
        end
    end)
end

-- Запуск инициализации
Init()
