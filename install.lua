--[[
    📦 АВТОМАТИЧЕСКИЙ УСТАНОВЩИК
    Скрипт для быстрой установки Adopt Me Script
--]]

local Installer = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Конфигурация установщика
local INSTALL_CONFIG = {
    version = "3.0",
    repository = "https://raw.githubusercontent.com/yourrepo/adopt_me_script/main/",
    files = {
        "adopt_me_main.lua",
        "config.lua",
        "pet_manager.lua",
        "money_manager.lua",
        "gui_manager.lua",
        "loader.lua"
    },
    dependencies = {
        "TweenService",
        "UserInputService",
        "ReplicatedStorage",
        "RunService"
    }
}

-- Создание GUI установщика
local function createInstallerGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local ProgressBar = Instance.new("Frame")
    local ProgressFill = Instance.new("Frame")
    local StatusLabel = Instance.new("TextLabel")
    local InstallButton = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")
    
    ScreenGui.Name = "AdoptMeInstaller"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = MainFrame
    
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = MainFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, 0, 0, 60)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🎮 ADOPT ME SCRIPT INSTALLER v" .. INSTALL_CONFIG.version
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Parent = MainFrame
    ProgressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Position = UDim2.new(0.1, 0, 0.3, 0)
    ProgressBar.Size = UDim2.new(0.8, 0, 0, 20)
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 10)
    ProgressCorner.Parent = ProgressBar
    
    ProgressFill.Name = "ProgressFill"
    ProgressFill.Parent = ProgressBar
    ProgressFill.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = ProgressFill
    
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.1, 0, 0.45, 0)
    StatusLabel.Size = UDim2.new(0.8, 0, 0, 100)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Готов к установке...\n\n📋 Что будет установлено:\n• Основной скрипт\n• Модули управления\n• GUI интерфейс\n• Система конфигурации"
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.TextSize = 12
    StatusLabel.TextWrapped = true
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    InstallButton.Name = "InstallButton"
    InstallButton.Parent = MainFrame
    InstallButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
    InstallButton.BorderSizePixel = 0
    InstallButton.Position = UDim2.new(0.1, 0, 0.8, 0)
    InstallButton.Size = UDim2.new(0.35, 0, 0, 40)
    InstallButton.Font = Enum.Font.GothamBold
    InstallButton.Text = "🚀 УСТАНОВИТЬ"
    InstallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    InstallButton.TextSize = 14
    
    local InstallCorner = Instance.new("UICorner")
    InstallCorner.CornerRadius = UDim.new(0, 8)
    InstallCorner.Parent = InstallButton
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.BackgroundColor3 = Color3.fromRGB(170, 85, 85)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(0.55, 0, 0.8, 0)
    CloseButton.Size = UDim2.new(0.35, 0, 0, 40)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "❌ ОТМЕНА"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    return ScreenGui, MainFrame, ProgressFill, StatusLabel, InstallButton, CloseButton
end

-- Обновление прогресса
local function updateProgress(progressFill, statusLabel, progress, status)
    local TweenService = game:GetService("TweenService")
    
    local progressTween = TweenService:Create(
        progressFill,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        {Size = UDim2.new(progress, 0, 1, 0)}
    )
    progressTween:Play()
    
    statusLabel.Text = status
end

-- Проверка зависимостей
local function checkDependencies()
    local missing = {}
    
    for _, service in ipairs(INSTALL_CONFIG.dependencies) do
        local success = pcall(function()
            game:GetService(service)
        end)
        
        if not success then
            table.insert(missing, service)
        end
    end
    
    return #missing == 0, missing
end

-- Загрузка файла
local function downloadFile(filename)
    local url = INSTALL_CONFIG.repository .. filename
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and response then
        return response
    else
        error("Не удалось загрузить файл: " .. filename)
    end
end

-- Сохранение файла
local function saveFile(filename, content)
    -- В реальном executor'е здесь была бы функция сохранения файла
    -- Для демонстрации просто выполняем код
    if filename == "adopt_me_main.lua" then
        loadstring(content)()
    end
end

-- Процесс установки
local function performInstallation(progressFill, statusLabel)
    local totalFiles = #INSTALL_CONFIG.files
    
    -- Проверка зависимостей
    updateProgress(progressFill, statusLabel, 0.1, "🔍 Проверка зависимостей...")
    wait(1)
    
    local depsOk, missingDeps = checkDependencies()
    if not depsOk then
        updateProgress(progressFill, statusLabel, 0, "❌ Ошибка: отсутствуют зависимости: " .. table.concat(missingDeps, ", "))
        return false
    end
    
    -- Загрузка файлов
    for i, filename in ipairs(INSTALL_CONFIG.files) do
        local progress = 0.1 + (i / totalFiles) * 0.8
        updateProgress(progressFill, statusLabel, progress, "📥 Загрузка: " .. filename .. " (" .. i .. "/" .. totalFiles .. ")")
        
        local success, content = pcall(function()
            return downloadFile(filename)
        end)
        
        if success then
            saveFile(filename, content)
        else
            updateProgress(progressFill, statusLabel, 0, "❌ Ошибка загрузки: " .. filename)
            return false
        end
        
        wait(0.5)
    end
    
    -- Финализация
    updateProgress(progressFill, statusLabel, 0.95, "⚙️ Настройка конфигурации...")
    wait(1)
    
    updateProgress(progressFill, statusLabel, 1.0, "✅ Установка завершена!\n\n🎉 Adopt Me Script готов к использованию!\nЗакройте это окно и наслаждайтесь игрой!")
    
    return true
end

-- Главная функция установщика
function Installer:Run()
    print("🚀 Запуск установщика Adopt Me Script...")
    
    local gui, mainFrame, progressFill, statusLabel, installButton, closeButton = createInstallerGUI()
    
    -- Обработчик кнопки установки
    installButton.MouseButton1Click:Connect(function()
        installButton.Visible = false
        
        local success = performInstallation(progressFill, statusLabel)
        
        if success then
            -- Изменяем кнопку закрытия на "Готово"
            closeButton.Text = "✅ ГОТОВО"
            closeButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
        else
            installButton.Visible = true
            installButton.Text = "🔄 ПОПРОБОВАТЬ СНОВА"
        end
    end)
    
    -- Обработчик кнопки закрытия
    closeButton.MouseButton1Click:Connect(function()
        local TweenService = game:GetService("TweenService")
        local closeTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0)}
        )
        closeTween:Play()
        closeTween.Completed:Connect(function()
            gui:Destroy()
        end)
    end)
    
    print("✅ Установщик готов к работе")
end

-- Быстрая установка (одной командой)
function Installer:QuickInstall()
    print("⚡ Быстрая установка Adopt Me Script...")
    
    -- Прямая загрузка основного файла
    local success, mainScript = pcall(function()
        return downloadFile("adopt_me_main.lua")
    end)
    
    if success then
        loadstring(mainScript)()
        print("✅ Скрипт успешно загружен и запущен!")
    else
        warn("❌ Ошибка быстрой установки. Используйте полный установщик.")
        Installer:Run()
    end
end

-- Проверка обновлений
function Installer:CheckUpdates(currentVersion)
    local success, latestVersion = pcall(function()
        local versionData = game:HttpGet(INSTALL_CONFIG.repository .. "version.txt")
        return versionData:match("%d+%.%d+")
    end)
    
    if success and latestVersion then
        if latestVersion ~= currentVersion then
            print("🔄 Доступна новая версия: " .. latestVersion)
            return true, latestVersion
        else
            print("✅ У вас последняя версия: " .. currentVersion)
            return false, currentVersion
        end
    else
        warn("⚠️ Не удалось проверить обновления")
        return false, currentVersion
    end
end

return Installer