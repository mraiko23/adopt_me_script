--[[
    🎨 GUI MANAGER MODULE
    Продвинутый интерфейс для Adopt Me Script
--]]

local GUIManager = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Темы оформления
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(35, 35, 50),
        Secondary = Color3.fromRGB(45, 45, 65),
        Accent = Color3.fromRGB(85, 170, 85),
        AccentHover = Color3.fromRGB(170, 85, 85),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200)
    },
    Light = {
        Primary = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(220, 220, 230),
        Accent = Color3.fromRGB(70, 130, 180),
        AccentHover = Color3.fromRGB(180, 70, 70),
        Text = Color3.fromRGB(30, 30, 30),
        TextSecondary = Color3.fromRGB(80, 80, 80)
    },
    Blue = {
        Primary = Color3.fromRGB(25, 35, 55),
        Secondary = Color3.fromRGB(35, 45, 65),
        Accent = Color3.fromRGB(70, 130, 180),
        AccentHover = Color3.fromRGB(180, 130, 70),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 220, 255)
    }
}

function GUIManager:CreateMainGUI(config)
    local theme = Themes[config.GUITheme] or Themes.Dark
    
    -- Основной ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdoptMeAdvancedGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = theme.Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.BackgroundTransparency = config.GUITransparency or 0.1
    
    -- Скругленные углы
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame
    
    -- Тень
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = ScreenGui
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    Shadow.Position = UDim2.new(0, MainFrame.Position.X.Offset - 10, 0, MainFrame.Position.Y.Offset - 10)
    Shadow.Size = UDim2.new(0, MainFrame.Size.X.Offset + 20, 0, MainFrame.Size.Y.Offset + 20)
    Shadow.ZIndex = MainFrame.ZIndex - 1
    
    -- Заголовок
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = theme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🎮 ADOPT ME SCRIPT v3.0 PREMIUM"
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопки управления окном
    local MinimizeButton = GUIManager:CreateButton(TitleBar, "−", UDim2.new(1, -80, 0.2, 0), UDim2.new(0, 25, 0, 25))
    local CloseButton = GUIManager:CreateButton(TitleBar, "×", UDim2.new(1, -45, 0.2, 0), UDim2.new(0, 25, 0, 25))
    
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    
    -- Контейнер для контента
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 0, 0, 60)
    ContentFrame.Size = UDim2.new(1, 0, 1, -60)
    ContentFrame.ScrollBarThickness = 5
    ContentFrame.ScrollBarImageColor3 = theme.Accent
    
    -- Создание вкладок
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    TabContainer.Size = UDim2.new(1, -20, 0, 30)
    
    local tabs = {"Основное", "Питомцы", "Деньги", "Телепорт", "Настройки"}
    local tabButtons = {}
    local tabFrames = {}
    
    -- Создание кнопок вкладок
    for i, tabName in ipairs(tabs) do
        local tabButton = GUIManager:CreateTab(TabContainer, tabName, i, #tabs, theme)
        tabButtons[i] = tabButton
        
        -- Создание фрейма вкладки
        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabName .. "Frame"
        tabFrame.Parent = ContentFrame
        tabFrame.BackgroundTransparency = 1
        tabFrame.Position = UDim2.new(0, 10, 0, 40)
        tabFrame.Size = UDim2.new(1, -20, 1, -50)
        tabFrame.Visible = (i == 1)
        tabFrames[i] = tabFrame
        
        -- Обработчик клика по вкладке
        tabButton.MouseButton1Click:Connect(function()
            GUIManager:SwitchTab(i, tabButtons, tabFrames, theme)
        end)
    end
    
    -- Заполнение вкладок контентом
    GUIManager:CreateMainTab(tabFrames[1], theme, config)
    GUIManager:CreatePetTab(tabFrames[2], theme, config)
    GUIManager:CreateMoneyTab(tabFrames[3], theme, config)
    GUIManager:CreateTeleportTab(tabFrames[4], theme, config)
    GUIManager:CreateSettingsTab(tabFrames[5], theme, config)
    
    -- Обработчики кнопок управления
    CloseButton.MouseButton1Click:Connect(function()
        GUIManager:AnimateClose(ScreenGui)
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        GUIManager:AnimateMinimize(MainFrame)
    end)
    
    -- Анимация появления
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    local openTween = TweenService:Create(
        MainFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 500, 0, 600)}
    )
    openTween:Play()
    
    return ScreenGui, MainFrame
end

function GUIManager:CreateButton(parent, text, position, size, theme)
    local button = Instance.new("TextButton")
    button.Parent = parent
    button.BackgroundColor3 = (theme and theme.Accent) or Color3.fromRGB(70, 130, 180)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = size
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Эффект наведения
    button.MouseEnter:Connect(function()
        local hoverTween = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = (theme and theme.AccentHover) or Color3.fromRGB(180, 70, 70)}
        )
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local leaveTween = TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {BackgroundColor3 = (theme and theme.Accent) or Color3.fromRGB(70, 130, 180)}
        )
        leaveTween:Play()
    end)
    
    return button
end

function GUIManager:CreateTab(parent, text, index, total, theme)
    local tabWidth = 1 / total
    local tabButton = Instance.new("TextButton")
    tabButton.Name = text .. "Tab"
    tabButton.Parent = parent
    tabButton.BackgroundColor3 = theme.Secondary
    tabButton.BorderSizePixel = 0
    tabButton.Position = UDim2.new(tabWidth * (index - 1), 2, 0, 0)
    tabButton.Size = UDim2.new(tabWidth, -4, 1, 0)
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = text
    tabButton.TextColor3 = theme.Text
    tabButton.TextSize = 12
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    return tabButton
end

function GUIManager:SwitchTab(activeIndex, tabButtons, tabFrames, theme)
    for i, button in ipairs(tabButtons) do
        local frame = tabFrames[i]
        if i == activeIndex then
            button.BackgroundColor3 = theme.Accent
            frame.Visible = true
        else
            button.BackgroundColor3 = theme.Secondary
            frame.Visible = false
        end
    end
end

function GUIManager:CreateMainTab(parent, theme, config)
    local yPos = 0
    
    -- Статистика
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Parent = parent
    statsFrame.BackgroundColor3 = theme.Secondary
    statsFrame.BorderSizePixel = 0
    statsFrame.Position = UDim2.new(0, 0, 0, yPos)
    statsFrame.Size = UDim2.new(1, 0, 0, 100)
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 10)
    statsCorner.Parent = statsFrame
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Name = "StatsTitle"
    statsTitle.Parent = statsFrame
    statsTitle.BackgroundTransparency = 1
    statsTitle.Size = UDim2.new(1, 0, 0, 30)
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.Text = "📊 СТАТИСТИКА"
    statsTitle.TextColor3 = theme.Text
    statsTitle.TextSize = 14
    
    yPos = yPos + 120
    
    -- Основные кнопки
    local buttons = {
        {"🍎 Авто-кормление", "AutoFeed"},
        {"🎮 Авто-игра", "AutoPlay"},
        {"💰 Авто-сбор денег", "AutoMoney"},
        {"🎁 Авто-сбор подарков", "AutoGifts"}
    }
    
    for i, buttonData in ipairs(buttons) do
        local button = GUIManager:CreateButton(
            parent,
            buttonData[1] .. ": ВЫКЛ",
            UDim2.new(0, 0, 0, yPos),
            UDim2.new(1, 0, 0, 40),
            theme
        )
        
        yPos = yPos + 50
    end
end

function GUIManager:CreatePetTab(parent, theme, config)
    -- Контент для вкладки питомцев
    local petList = Instance.new("ScrollingFrame")
    petList.Name = "PetList"
    petList.Parent = parent
    petList.BackgroundColor3 = theme.Secondary
    petList.BorderSizePixel = 0
    petList.Size = UDim2.new(1, 0, 0.7, 0)
    petList.ScrollBarThickness = 5
    
    local petCorner = Instance.new("UICorner")
    petCorner.CornerRadius = UDim.new(0, 10)
    petCorner.Parent = petList
end

function GUIManager:CreateMoneyTab(parent, theme, config)
    -- Контент для вкладки денег
end

function GUIManager:CreateTeleportTab(parent, theme, config)
    -- Контент для вкладки телепортации
end

function GUIManager:CreateSettingsTab(parent, theme, config)
    -- Контент для настроек
end

function GUIManager:AnimateClose(gui)
    local closeTween = TweenService:Create(
        gui,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0)}
    )
    closeTween:Play()
    closeTween.Completed:Connect(function()
        gui:Destroy()
    end)
end

function GUIManager:AnimateMinimize(frame)
    local isMinimized = frame:GetAttribute("Minimized") or false
    
    if isMinimized then
        -- Развернуть
        local expandTween = TweenService:Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 500, 0, 600)}
        )
        expandTween:Play()
        frame:SetAttribute("Minimized", false)
    else
        -- Свернуть
        local minimizeTween = TweenService:Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 500, 0, 50)}
        )
        minimizeTween:Play()
        frame:SetAttribute("Minimized", true)
    end
end

return GUIManager