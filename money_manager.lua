--[[
    💰 MONEY MANAGER MODULE
    Модуль для управления деньгами и экономикой
--]]

local MoneyManager = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- 💵 Сбор денег с земли
function MoneyManager:CollectGroundMoney()
    local collected = 0
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return collected
    end
    
    local playerPosition = character.HumanoidRootPart.Position
    
    -- Поиск денег в радиусе
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("money") or 
           obj.Name:lower():find("cash") or 
           obj.Name:lower():find("coin") or
           obj.Name == "Bucks" then
            
            -- Проверяем расстояние
            if obj:FindFirstChild("Position") or obj:IsA("Part") then
                local objPosition = obj:IsA("Part") and obj.Position or obj.Position.Value
                local distance = (playerPosition - objPosition).Magnitude
                
                if distance <= 50 then -- В радиусе 50 единиц
                    -- Пытаемся собрать
                    if obj:FindFirstChild("ClickDetector") then
                        fireclickdetector(obj.ClickDetector)
                        collected = collected + 1
                    elseif obj:FindFirstChild("ProximityPrompt") then
                        fireproximityprompt(obj.ProximityPrompt)
                        collected = collected + 1
                    end
                end
            end
        end
    end
    
    return collected
end

-- 🎁 Сбор подарков и бонусов
function MoneyManager:CollectGifts()
    local collected = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("gift") or 
           obj.Name:lower():find("present") or 
           obj.Name:lower():find("reward") or
           obj.Name:lower():find("bonus") then
            
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
                collected = collected + 1
            elseif obj:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(obj.ProximityPrompt)
                collected = collected + 1
            end
        end
    end
    
    return collected
end

-- 🏪 Автоматическая покупка еды
function MoneyManager:AutoBuyFood(foodTypes, maxAmount)
    local purchased = {}
    maxAmount = maxAmount or 10
    
    -- Телепорт к магазину
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local shopPosition = Vector3.new(-120, 3, -450)
        character.HumanoidRootPart.CFrame = CFrame.new(shopPosition)
        wait(2)
        
        -- Поиск магазина еды
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("food") and obj.Name:lower():find("shop") then
                local clickDetector = obj:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    wait(1)
                    
                    -- Покупка каждого типа еды
                    for _, foodType in ipairs(foodTypes) do
                        for i = 1, maxAmount do
                            pcall(function()
                                local buyEvent = ReplicatedStorage:FindFirstChild("BuyFood")
                                if buyEvent then
                                    buyEvent:FireServer(foodType, 1)
                                    if not purchased[foodType] then
                                        purchased[foodType] = 0
                                    end
                                    purchased[foodType] = purchased[foodType] + 1
                                end
                            end)
                            wait(0.1)
                        end
                    end
                    break
                end
            end
        end
    end
    
    return purchased
end

-- 💎 Сбор бриллиантов (премиум валюта)
function MoneyManager:CollectDiamonds()
    local collected = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("diamond") or 
           obj.Name:lower():find("gem") or 
           obj.Name == "Robux" then
            
            if obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
                collected = collected + 1
            end
        end
    end
    
    return collected
end

-- 🎰 Автоматическое вращение рулетки (если доступно)
function MoneyManager:AutoSpin()
    local spins = 0
    
    -- Поиск рулеток или игровых автоматов
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("wheel") or 
           obj.Name:lower():find("spin") or 
           obj.Name:lower():find("roulette") then
            
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                spins = spins + 1
                wait(1)
            end
        end
    end
    
    return spins
end

-- 📊 Получение текущего баланса
function MoneyManager:GetPlayerMoney()
    local money = {
        cash = 0,
        diamonds = 0
    }
    
    -- Поиск в PlayerGui
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") then
                local text = gui.Text:lower()
                
                -- Поиск денег
                if text:find("cash") or text:find("money") or text:find("$") then
                    local amount = text:match("%d+")
                    if amount then
                        money.cash = tonumber(amount)
                    end
                end
                
                -- Поиск бриллиантов
                if text:find("diamond") or text:find("gem") or text:find("💎") then
                    local amount = text:match("%d+")
                    if amount then
                        money.diamonds = tonumber(amount)
                    end
                end
            end
        end
    end
    
    -- Альтернативный поиск в leaderstats
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local cashStat = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money")
        local diamondStat = leaderstats:FindFirstChild("Diamonds") or leaderstats:FindFirstChild("Gems")
        
        if cashStat then money.cash = cashStat.Value end
        if diamondStat then money.diamonds = diamondStat.Value end
    end
    
    return money
end

-- 🔄 Автоматический сбор всех ресурсов
function MoneyManager:AutoCollectAll()
    local results = {
        money = 0,
        gifts = 0,
        diamonds = 0,
        spins = 0
    }
    
    -- Сбор денег
    results.money = MoneyManager:CollectGroundMoney()
    wait(0.5)
    
    -- Сбор подарков
    results.gifts = MoneyManager:CollectGifts()
    wait(0.5)
    
    -- Сбор бриллиантов
    results.diamonds = MoneyManager:CollectDiamonds()
    wait(0.5)
    
    -- Автоспин
    results.spins = MoneyManager:AutoSpin()
    
    return results
end

-- 💰 Умная покупка (покупает только если нужно)
function MoneyManager:SmartBuy(itemType, maxPrice)
    local currentMoney = MoneyManager:GetPlayerMoney()
    
    if currentMoney.cash >= maxPrice then
        -- Логика покупки в зависимости от типа предмета
        if itemType == "food" then
            return MoneyManager:AutoBuyFood({"Apple", "Sandwich"}, 5)
        elseif itemType == "toy" then
            -- Покупка игрушек для питомцев
            return MoneyManager:BuyToys()
        end
    end
    
    return false
end

-- 🧸 Покупка игрушек
function MoneyManager:BuyToys()
    local purchased = 0
    
    -- Телепорт к магазину игрушек
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local toyShopPosition = Vector3.new(-200, 3, -400)
        character.HumanoidRootPart.CFrame = CFrame.new(toyShopPosition)
        wait(2)
        
        -- Поиск и покупка игрушек
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("toy") and obj:FindFirstChild("ClickDetector") then
                fireclickdetector(obj.ClickDetector)
                purchased = purchased + 1
                wait(1)
            end
        end
    end
    
    return purchased
end

return MoneyManager