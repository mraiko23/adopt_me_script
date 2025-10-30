--[[
    🐾 PET MANAGER MODULE
    Модуль для управления питомцами
--]]

local PetManager = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- 🔍 Поиск всех питомцев игрока
function PetManager:FindPlayerPets()
    local pets = {}
    local character = LocalPlayer.Character
    if not character then return pets end
    
    -- Поиск в workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("Pet") and obj:FindFirstChild("Humanoid") then
            -- Проверяем, принадлежит ли питомец игроку
            local owner = obj:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer then
                table.insert(pets, {
                    model = obj,
                    name = obj.Name,
                    humanoid = obj.Humanoid,
                    rootPart = obj:FindFirstChild("HumanoidRootPart"),
                    stats = PetManager:GetPetStats(obj)
                })
            end
        end
    end
    
    return pets
end

-- 📊 Получение статистики питомца
function PetManager:GetPetStats(petModel)
    local stats = {
        hunger = 100,
        happiness = 100,
        health = 100,
        energy = 100,
        age = "Newborn",
        type = "Unknown"
    }
    
    -- Попытка получить реальные статы
    local statsFolder = petModel:FindFirstChild("Stats")
    if statsFolder then
        for statName, defaultValue in pairs(stats) do
            local statValue = statsFolder:FindFirstChild(statName)
            if statValue and statValue.Value then
                stats[statName] = statValue.Value
            end
        end
    end
    
    return stats
end

-- 🍎 Кормление питомца
function PetManager:FeedPet(pet, foodType)
    if not pet or not pet.model then return false end
    
    local success = false
    
    -- Различные способы кормления
    local feedMethods = {
        function()
            -- Метод 1: RemoteEvent
            local feedEvent = ReplicatedStorage:FindFirstChild("FeedPet")
            if feedEvent then
                feedEvent:FireServer(pet.model, foodType or "Apple")
                return true
            end
        end,
        
        function()
            -- Метод 2: API система
            local api = ReplicatedStorage:FindFirstChild("API")
            if api then
                local petAPI = api:FindFirstChild("PetAPI")
                if petAPI then
                    local feedFunction = petAPI:FindFirstChild("FeedPet")
                    if feedFunction then
                        feedFunction:InvokeServer(pet.model, foodType or "Apple")
                        return true
                    end
                end
            end
        end,
        
        function()
            -- Метод 3: Прямое взаимодействие
            local clickDetector = pet.model:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
                return true
            end
        end
    }
    
    -- Пробуем каждый метод
    for _, method in ipairs(feedMethods) do
        pcall(function()
            if method() then
                success = true
            end
        end)
        if success then break end
    end
    
    return success
end

-- 🎮 Игра с питомцем
function PetManager:PlayWithPet(pet, gameType)
    if not pet or not pet.model then return false end
    
    local success = false
    gameType = gameType or "Ball"
    
    local playMethods = {
        function()
            local playEvent = ReplicatedStorage:FindFirstChild("PlayWithPet")
            if playEvent then
                playEvent:FireServer(pet.model, gameType)
                return true
            end
        end,
        
        function()
            local api = ReplicatedStorage:FindFirstChild("API")
            if api then
                local petAPI = api:FindFirstChild("PetAPI")
                if petAPI then
                    local playFunction = petAPI:FindFirstChild("PlayWithPet")
                    if playFunction then
                        playFunction:InvokeServer(pet.model, gameType)
                        return true
                    end
                end
            end
        end
    }
    
    for _, method in ipairs(playMethods) do
        pcall(function()
            if method() then
                success = true
            end
        end)
        if success then break end
    end
    
    return success
end

-- 🏥 Лечение питомца
function PetManager:HealPet(pet)
    if not pet or not pet.model then return false end
    
    -- Телепорт к больнице и лечение
    local hospitalPosition = Vector3.new(320, 15, 470)
    local character = LocalPlayer.Character
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(hospitalPosition)
        
        wait(1)
        
        -- Поиск доктора или лечебного объекта
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("doctor") or obj.Name:lower():find("heal") then
                local clickDetector = obj:FindFirstChild("ClickDetector")
                if clickDetector then
                    fireclickdetector(clickDetector)
                    return true
                end
            end
        end
    end
    
    return false
end

-- 🎓 Обучение питомца
function PetManager:TrainPet(pet, skill)
    if not pet or not pet.model then return false end
    
    skill = skill or "Sit"
    
    local trainMethods = {
        function()
            local trainEvent = ReplicatedStorage:FindFirstChild("TrainPet")
            if trainEvent then
                trainEvent:FireServer(pet.model, skill)
                return true
            end
        end
    }
    
    for _, method in ipairs(trainMethods) do
        pcall(function()
            if method() then
                return true
            end
        end)
    end
    
    return false
end

-- 🔄 Автоматический уход за всеми питомцами
function PetManager:AutoCareForAllPets(config)
    local pets = PetManager:FindPlayerPets()
    local actionsPerformed = 0
    
    for _, pet in ipairs(pets) do
        local stats = pet.stats
        
        -- Кормление если голоден
        if stats.hunger < 50 then
            if PetManager:FeedPet(pet, config.FoodTypes[1]) then
                actionsPerformed = actionsPerformed + 1
            end
        end
        
        -- Игра если скучно
        if stats.happiness < 50 then
            if PetManager:PlayWithPet(pet) then
                actionsPerformed = actionsPerformed + 1
            end
        end
        
        -- Лечение если болен
        if stats.health < 30 then
            if PetManager:HealPet(pet) then
                actionsPerformed = actionsPerformed + 1
            end
        end
        
        wait(0.5) -- Небольшая задержка между действиями
    end
    
    return actionsPerformed, #pets
end

-- 📈 Получение общей статистики всех питомцев
function PetManager:GetAllPetsStats()
    local pets = PetManager:FindPlayerPets()
    local totalStats = {
        count = #pets,
        avgHunger = 0,
        avgHappiness = 0,
        avgHealth = 0,
        needCare = 0
    }
    
    if #pets == 0 then return totalStats end
    
    local hungerSum, happinessSum, healthSum = 0, 0, 0
    
    for _, pet in ipairs(pets) do
        local stats = pet.stats
        hungerSum = hungerSum + stats.hunger
        happinessSum = happinessSum + stats.happiness
        healthSum = healthSum + stats.health
        
        if stats.hunger < 50 or stats.happiness < 50 or stats.health < 50 then
            totalStats.needCare = totalStats.needCare + 1
        end
    end
    
    totalStats.avgHunger = math.floor(hungerSum / #pets)
    totalStats.avgHappiness = math.floor(happinessSum / #pets)
    totalStats.avgHealth = math.floor(healthSum / #pets)
    
    return totalStats
end

return PetManager