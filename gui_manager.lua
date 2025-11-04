-- Combined executor script
-- Run this in a Roblox executor (synapse/other) on the client to monitor PlayerGui Seeds/Gears
-- and POST changes directly to an external API URL.

local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')

-- CONFIG
local API_URL = 'http://localhost:3000/api/stock' -- change to your site URL
local API_KEY = nil -- optional: set API key if your server requires it
local TARGET_PLAYER_NAME = nil -- nil = use LocalPlayer (executor attached player). Or set exact player name
local POLL_INTERVAL = 5 -- seconds, periodic scan fallback

-- Helpers
local function parseStockText(txt)
  if not txt then return 0 end
  local num = string.match(txt, 'x(%d+)') or string.match(txt, '(%d+)')
  return tonumber(num) or 0
end

local function scanItemsInScrolling(scrollingFrame)
  local result = {}
  for _, child in ipairs(scrollingFrame:GetChildren()) do
    if child:IsA('Frame') or child:IsA('TextButton') or child:IsA('ImageButton') then
      -- robust descendant search for Title/Stock/Rarity labels
      local function findLabel(root, name)
        for _, d in ipairs(root:GetDescendants()) do
          if d.Name == name and (d:IsA('TextLabel') or d:IsA('TextButton')) then return d end
        end
        return nil
      end

      local nameLabel = findLabel(child, 'Title') or findLabel(child, 'Name')
      -- fallback: first TextLabel/TextButton descendant
      if not nameLabel then
        for _, d in ipairs(child:GetDescendants()) do
          if d:IsA('TextLabel') or d:IsA('TextButton') then
            nameLabel = d
            break
          end
        end
      end
      local stockLabel = findLabel(child, 'Stock') or findLabel(child, 'stock')
      local rarityLabel = findLabel(child, 'Rarity') or findLabel(child, 'rarity')
      local itemName = nil
      if nameLabel and nameLabel.Text then itemName = nameLabel.Text end
      if not itemName then itemName = child.Name end
      local stockText = (stockLabel and stockLabel.Text) or ''
      local stock = parseStockText(stockText)
      local rarity = (rarityLabel and rarityLabel.Text) or nil
      result[string.lower(itemName)] = { displayName = itemName, stock = stock, rarity = rarity }
    end
  end
  return result
end

local function findScrolling(playerGui, containerName)
  if not playerGui then return nil end
  local main = playerGui:FindFirstChild('Main') or playerGui:FindFirstChildWhichIsA('ScreenGui')
  if not main then return nil end
  local container = main:FindFirstChild(containerName)
  if not container then return nil end
  local frame = container:FindFirstChild('Frame') or container
  local scrolling = frame:FindFirstChild('ScrollingFrame')
  return scrolling
end

local function getTargetPlayer()
  if TARGET_PLAYER_NAME and TARGET_PLAYER_NAME ~= '' then
    return Players:FindFirstChild(TARGET_PLAYER_NAME)
  end
  return Players.LocalPlayer or Players:GetPlayers()[1]
end

-- HTTP POST using executor-provided functions
local function httpPost(url, body, headers)
  local bodyStr = HttpService:JSONEncode(body)
  headers = headers or {}
  headers['Content-Type'] = 'application/json'
  if API_KEY then headers['x-api-key'] = API_KEY end

  local ok, res
  -- Detect available request function and use it. Log method used for debugging.
  if syn and syn.request then
    print('[debug] using syn.request for HTTP POST')
    ok, res = pcall(function() return syn.request({ Url = url, Method = 'POST', Headers = headers, Body = bodyStr }) end)
    if not ok then warn('[debug] syn.request pcall failed', res) end
    if ok and res and (res.StatusCode == 200 or res.StatusCode == 201) then return true, res end
    return false, res
  end

  if http_request then
    print('[debug] using http_request for HTTP POST')
    ok, res = pcall(function() return http_request({ Url = url, Method = 'POST', Headers = headers, Body = bodyStr }) end)
    if not ok then warn('[debug] http_request pcall failed', res) end
    return ok, res
  end

  if request then
    print('[debug] using request for HTTP POST')
    ok, res = pcall(function() return request({ Url = url, Method = 'POST', Headers = headers, Body = bodyStr }) end)
    if not ok then warn('[debug] request pcall failed', res) end
    return ok, res
  end

  -- As last resort, try to use HttpService.PostAsync (may fail on client)
  print('[debug] using HttpService:PostAsync for HTTP POST (fallback)')
  ok, res = pcall(function() return HttpService:PostAsync(url, bodyStr, Enum.HttpContentType.ApplicationJson, false, headers) end)
  if not ok then warn('[debug] HttpService:PostAsync pcall failed', res) end
  return ok, res
end

-- Snapshot and change detection
local lastSnapshot = { seeds = {}, gears = {} }
local debounce = 0

local function detectChangesAndSend(seedsScroll, gearsScroll)
  if tick() < debounce then return end
  debounce = tick() + 0.5

  local seeds = seedsScroll and scanItemsInScrolling(seedsScroll) or {}
  local gears = gearsScroll and scanItemsInScrolling(gearsScroll) or {}

  local changed = false
  for k,v in pairs(seeds) do
    local prev = lastSnapshot.seeds[k]
    if not prev or prev.stock ~= v.stock then changed = true; break end
  end
  if not changed then
    for k,v in pairs(gears) do
      local prev = lastSnapshot.gears[k]
      if not prev or prev.stock ~= v.stock then changed = true; break end
    end
  end

  if changed then
    lastSnapshot.seeds = seeds
    lastSnapshot.gears = gears
    local payload = { seeds = seeds, gears = gears, ts = os.time() }
    local ok, res = httpPost(API_URL, payload)
    if ok then
      print('[stock] Posted update to', API_URL)
    else
      warn('[stock] Failed to post update', res)
    end
  end
end

-- Main setup
local function start()
  local player = getTargetPlayer()
  if not player then warn('Target player not found') return end
  local playerGui = player:FindFirstChild('PlayerGui') or player:WaitForChild('PlayerGui')
  local seedsScroll = findScrolling(playerGui, 'Seeds')
  local gearsScroll = findScrolling(playerGui, 'Gears')

  if not seedsScroll and not gearsScroll then
    warn('No Seeds or Gears scrolling frames found for player', player.Name)
  end

  if seedsScroll then
    seedsScroll.ChildAdded:Connect(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
    seedsScroll.ChildRemoved:Connect(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
    seedsScroll.DescendantAdded:Connect(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
  end
  if gearsScroll then
    gearsScroll.ChildAdded:Connect(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
    gearsScroll.ChildRemoved:Connect(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
    gearsScroll.DescendantAdded:Connect(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
  end

  -- debug info
  pcall(function()
    print('[stock] Executor monitor starting for player', player.Name)
    print('[stock] CONFIG:', 'API_URL=' .. tostring(API_URL), 'API_KEY=' .. tostring(API_KEY), 'TARGET_PLAYER_NAME=' .. tostring(TARGET_PLAYER_NAME), 'POLL_INTERVAL=' .. tostring(POLL_INTERVAL))
    print('[stock] http functions availability:', 'syn=' .. tostring(type(syn) ~= 'nil'), 'http_request=' .. tostring(type(http_request) ~= 'nil'), 'request=' .. tostring(type(request) ~= 'nil'))
    if seedsScroll then print('[stock] seeds scrolling found with child count', #seedsScroll:GetChildren()) end
    if gearsScroll then print('[stock] gears scrolling found with child count', #gearsScroll:GetChildren()) end
  end)

  -- periodic scan
  spawn(function()
    while true do
      local ok, err = pcall(function() detectChangesAndSend(seedsScroll, gearsScroll) end)
      if not ok then warn('[stock] detectChangesAndSend error', err) end
      wait(POLL_INTERVAL)
    end
  end)

  print('[stock] Executor monitor started for player', player.Name)
end

start()


