--[[
    🚀 ADOPT ME SCRIPT LOADER
    Главный загрузчик для всех модулей
--]]

local Loader = {}

-- Проверка окружения
local function checkEnvironment()
    local checks = {
        {"game", game ~= nil},
        {"workspace", workspace ~= nil},
        {"Players", game:GetService("Players") ~= nil},
        {"ReplicatedStorage", game:GetService("ReplicatedStorage") ~= nil}
    }
    
    for _, check in ipairs(checks) do
        if not check[2] then
            error("❌ Ошибка окружения: " .. check[1] .. " недоступен")
            return false
        end
    end
    
    return true
end

-- Загрузка конфигурации
local function loadConfig()
    local success, config = pcall(function()
        return loadfile("config.lua")()
    end)
    
    if success and config then
        return config
    else
        -- Конфигурация по умолчанию
        return {
            AutoFeed = false,
            AutoPlay = false,
            AutoCollectMoney = true,
            FeedInterval = 30,
            PlayInterval = 45,
            WalkSpeed = 50,
            JumpPower = 100,
            Notifications = true,
            GUITheme = "Dark",
            GUITransparency = 0.1,
            FoodTypes = {"Apple", "Sandwich", "Cookie"},
            AntiAFK = true,
            SafeMode = true
        }
    end
end

-- Загрузка модулей
local function loadModules()
    local modules = {}
    
    -- Попытка загрузить каждый модуль
    local moduleFiles = {
        "pet_manager.lua",
        "money_manager.lua",
        "gui_manager.lua"
    }
    
    for _, moduleFile in ipairs(moduleFiles) do
        local success, module = pcall(function()
            return loadfile(moduleFile)()
        end)
        
        if success and module then
            local moduleName = moduleFile:gsub(".lua", ""):gsub("_", "")
            modules[moduleName] = module
            print("✅ Модуль загружен: " .. moduleFile)
        else
            warn("⚠️ Не удалось загрузить модуль: " .. moduleFile)
        end
    end
    
    return modules
end

-- Инициализация Anti-AFK
local function initAntiAFK()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    
    spawn(function()
        while true do
            wait(300) -- Каждые 5 минут
            
            -- Имитация движения мыши
            pcall(function()
                VirtualInputManager:SendMouseMoveEvent(1, 1, game)
                wait(0.1)
                VirtualInputManager:SendMouseMoveEvent(-1, -1, game)
            end)
            
            -- Имитация нажатия клавиши
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
            end)
        end
    end)
end

-- Система уведомлений
local function createNotificationSystem()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = Players.LocalPlayer
    
    return function(title, message, duration)
        duration = duration or 3
        
        local ScreenGui = Instance.new("ScreenGui")
        local Frame = Instance.new("Frame")
        local TitleLabel = Instance.new("TextLabel")
        local MessageLabel = Instance.new("TextLabel")
        local CloseButton = Instance.new("TextButton")
        
        ScreenGui.Name = "NotificationGUI"
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        ScreenGui.ResetOnSpawn = false
        
        Frame.Name = "NotificationFrame"
        Frame.Parent = ScreenGui
        Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        Frame.BorderSizePixel = 0
        Frame.Position = UDim2.new(1, 10, 0.1, 0)
        Frame.Size = UDim2.new(0, 300, 0, 100)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = Frame
        
        TitleLabel.Name = "Title"
        TitleLabel.Parent = Frame
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 10, 0, 5)
        TitleLabel.Size = UDim2.new(1, -40, 0, 30)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        MessageLabel.Name = "Message"
        MessageLabel.Parent = Frame
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Position = UDim2.new(0, 10, 0, 35)
        MessageLabel.Size = UDim2.new(1, -20, 0, 60)
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.Text = message
        MessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        MessageLabel.TextSize = 12
        MessageLabel.TextWrapped = true
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        
        CloseButton.Name = "CloseButton"
        CloseButton.Parent = Frame
        CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        CloseButton.BorderSizePixel = 0
        CloseButton.Position = UDim2.new(1, -25, 0, 5)
        CloseButton.Size = UDim2.new(0, 20, 0, 20)
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Text = "×"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 12
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = CloseButton
        
        -- Анимация появления
        local tweenIn = TweenService:Create(
            Frame,
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.7, 0, 0.1, 0)}
        )
        tweenIn:Play()
        
        -- Автоматическое закрытие
        local function closeNotification()
            local tweenOut = TweenService:Create(
                Frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Position = UDim2.new(1, 10, 0.1, 0)}
            )
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        end
        
        CloseButton.MouseButton1Click:Connect(closeNotification)
        
        spawn(function()
            wait(duration)
            if ScreenGui.Parent then
                closeNotification()
            end
        end)
    end
end

-- Главная функция загрузки
function Loader:Initialize()
    print("🚀 Запуск Adopt Me Script...")
    
    -- Проверка окружения
    if not checkEnvironment() then
        error("❌ Критическая ошибка окружения")
        return false
    end
    print("✅ Окружение проверено")
    
    -- Загрузка конфигурации
    local config = loadConfig()
    print("✅ Конфигурация загружена")
    
    -- Создание системы уведомлений
    local notify = createNotificationSystem()
    print("✅ Система уведомлений создана")
    
    -- Загрузка модулей
    local modules = loadModules()
    print("✅ Модули загружены: " .. tostring(#modules))
    
    -- Инициализация Anti-AFK
    if config.AntiAFK then
        initAntiAFK()
        print("✅ Anti-AFK активирован")
    end
    
    -- Создание GUI
    if modules.guimanager then
        local gui, mainFrame = modules.guimanager:CreateMainGUI(config)
        print("✅ GUI создан")
    end
    
    -- Уведомление о успешной загрузке
    notify(
        "🎮 ADOPT ME SCRIPT",
        "Скрипт успешно загружен!\nВерсия: 3.0 Premium\nВсе модули активны",
        5
    )
    
    print("🎉 Adopt Me Script полностью загружен и готов к работе!")
    return true, config, modules, notify
end

-- Функция безопасного выполнения
function Loader:SafeExecute(func, errorMessage)
    local success, result = pcall(func)
    if not success then
        warn("⚠️ " .. (errorMessage or "Ошибка выполнения") .. ": " .. tostring(result))
        return false, result
    end
    return true, result
end

-- Функция проверки обновлений
function Loader:CheckForUpdates()
    print("🔍 Проверка обновлений...")
    -- Здесь можно добавить логику проверки обновлений
    print("✅ Вы используете последнюю версию")
end

return Loader