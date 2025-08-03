--[[
    🎮 Enhanced HUD - Core Module
    
    Handles:
    - Player status monitoring (health, armor, hunger, thirst, stress, oxygen)
    - Core update loops
    - Status broadcasting to NUI
    - Critical threshold monitoring
]]

local QBCore = exports['qb-core']:GetCoreObject()

HudCore = {}
HudCore.PlayerData = {}
HudCore.UpdateInterval = 250 -- 4 FPS for main updates
HudCore.FastUpdateInterval = 100 -- 10 FPS for critical stats
HudCore.SlowUpdateInterval = 1000 -- 1 FPS for slow stats

-- Status tracking
local lastStatus = {}
local updateCycleCount = 0

-- Performance monitoring
local lastPerformanceCheck = GetGameTimer()
local frameTimeHistory = {}

--[[
    📊 Initialize Core HUD System
]]
function HudCore:Initialize()
    print("^2[HUD-CORE]^7 Initializing core systems...")
    
    -- Start main update loop
    self:StartUpdateLoop()
    
    -- Start performance monitoring
    self:StartPerformanceMonitoring()
    
    -- Initialize player data when available
    self:WaitForPlayerData()
    
    print("^2[HUD-CORE]^7 Core systems initialized")
end

--[[
    ⏰ Main Update Loop - Handles all status updates
]]
function HudCore:StartUpdateLoop()
    CreateThread(function()
        while true do
            if HudCore.PlayerData and HudCore.PlayerData.citizenid then
                updateCycleCount = updateCycleCount + 1
                
                -- Fast updates (every 100ms) - Critical stats
                if updateCycleCount % 1 == 0 then
                    self:UpdateCriticalStats()
                end
                
                -- Normal updates (every 250ms) - Regular stats  
                if updateCycleCount % 3 == 0 then
                    self:UpdateRegularStats()
                end
                
                -- Slow updates (every 1000ms) - Heavy operations
                if updateCycleCount % 10 == 0 then
                    self:UpdateSlowStats()
                end
                
                -- Performance check every 5 seconds
                if updateCycleCount % 50 == 0 then
                    self:CheckPerformance()
                end
            end
            
            Wait(HudCore.FastUpdateInterval)
        end
    end)
end

--[[
    🚨 Update Critical Stats (Health, Armor - High Priority)
]]
function HudCore:UpdateCriticalStats()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    local health = math.ceil(GetEntityHealth(ped) - 100)
    local armor = GetPedArmour(ped)
    
    -- Health bounds checking
    if health < 0 then health = 0 end
    if health > 100 then health = 100 end
    
    -- Check for critical changes
    local criticalChange = false
    
    if lastStatus.health and math.abs(lastStatus.health - health) >= 10 then
        criticalChange = true
    end
    
    if lastStatus.armor and math.abs(lastStatus.armor - armor) >= 10 then
        criticalChange = true
    end
    
    -- Update last status
    lastStatus.health = health
    lastStatus.armor = armor
    
    -- Send to NUI if critical change or first time
    if criticalChange or not lastStatus.healthSent then
        self:SendStatusToNUI({
            health = health,
            armor = armor,
            isDead = IsEntityDead(ped)
        })
        lastStatus.healthSent = true
    end
    
    -- Trigger critical alerts
    if health <= Config.CriticalThreshold and health ~= lastStatus.lastCriticalHealth then
        HudThemes:TriggerCriticalAlert('health', health)
        lastStatus.lastCriticalHealth = health
    end
    
    if armor <= Config.CriticalThreshold and armor ~= lastStatus.lastCriticalArmor then
        HudThemes:TriggerCriticalAlert('armor', armor)
        lastStatus.lastCriticalArmor = armor
    end
end

--[[
    📊 Update Regular Stats (Hunger, Thirst, Stress)
]]
function HudCore:UpdateRegularStats()
    if not HudCore.PlayerData.metadata then return end
    
    local metadata = HudCore.PlayerData.metadata
    
    local hunger = math.ceil(metadata.hunger or 100)
    local thirst = math.ceil(metadata.thirst or 100)
    local stress = math.ceil(metadata.stress or 0)
    
    -- Bounds checking
    hunger = math.max(0, math.min(100, hunger))
    thirst = math.max(0, math.min(100, thirst))
    stress = math.max(0, math.min(100, stress))
    
    -- Check for significant changes (5% threshold)
    local shouldUpdate = false
    
    if not lastStatus.hunger or math.abs(lastStatus.hunger - hunger) >= 5 then
        shouldUpdate = true
    end
    if not lastStatus.thirst or math.abs(lastStatus.thirst - thirst) >= 5 then
        shouldUpdate = true
    end
    if not lastStatus.stress or math.abs(lastStatus.stress - stress) >= 5 then
        shouldUpdate = true
    end
    
    if shouldUpdate then
        -- Update tracking
        lastStatus.hunger = hunger
        lastStatus.thirst = thirst
        lastStatus.stress = stress
        
        -- Send to NUI
        self:SendStatusToNUI({
            hunger = hunger,
            thirst = thirst,
            stress = stress
        })
        
        -- Critical alerts
        if hunger <= Config.CriticalThreshold then
            HudThemes:TriggerCriticalAlert('hunger', hunger)
        end
        if thirst <= Config.CriticalThreshold then
            HudThemes:TriggerCriticalAlert('thirst', thirst)
        end
        if stress >= Config.StressCriticalThreshold then
            HudThemes:TriggerCriticalAlert('stress', stress)
        end
    end
end

--[[
    🐌 Update Slow Stats (Oxygen, Stamina, etc.)
]]
function HudCore:UpdateSlowStats()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    local oxygen = 100
    local stamina = 100
    
    -- Oxygen calculation (underwater/vehicle)
    if IsPedSwimmingUnderWater(ped) then
        local maxTime = GetPlayerUnderwaterTimeRemaining(PlayerId())
        oxygen = math.ceil((maxTime / 30.0) * 100) -- Assume 30s max underwater time
    end
    
    -- Stamina calculation
    local staminaLevel = GetPlayerSprintStaminaRemaining(PlayerId())
    stamina = math.ceil(staminaLevel)
    
    -- Update if changed significantly
    if not lastStatus.oxygen or math.abs(lastStatus.oxygen - oxygen) >= 10 or
       not lastStatus.stamina or math.abs(lastStatus.stamina - stamina) >= 10 then
        
        lastStatus.oxygen = oxygen
        lastStatus.stamina = stamina
        
        self:SendStatusToNUI({
            oxygen = oxygen,
            stamina = stamina
        })
        
        -- Critical oxygen alert
        if oxygen <= Config.CriticalThreshold then
            HudThemes:TriggerCriticalAlert('oxygen', oxygen)
        end
    end
end

--[[
    📡 Send Status Data to NUI
]]
function HudCore:SendStatusToNUI(data)
    local success, error = pcall(function()
        SendNUIMessage({
            action = 'updateStats',
            stats = data,
            timestamp = GetGameTimer()
        })
    end)
    
    if not success then
        print("^1[HUD-CORE-ERROR]^7 Failed to send NUI message: " .. tostring(error))
    end
end

--[[
    👤 Wait for Player Data to be Available
]]
function HudCore:WaitForPlayerData()
    CreateThread(function()
        while not HudCore.PlayerData.citizenid do
            HudCore.PlayerData = QBCore.Functions.GetPlayerData()
            if HudCore.PlayerData.citizenid then
                print("^2[HUD-CORE]^7 Player data loaded for: " .. HudCore.PlayerData.citizenid)
                
                -- Send initial status
                self:UpdateCriticalStats()
                self:UpdateRegularStats()
                self:UpdateSlowStats()
                break
            end
            Wait(1000)
        end
    end)
end

--[[
    ⚡ Performance Monitoring
]]
function HudCore:StartPerformanceMonitoring()
    CreateThread(function()
        while true do
            local frameTime = GetFrameTime()
            table.insert(frameTimeHistory, frameTime)
            
            -- Keep only last 100 frames
            if #frameTimeHistory > 100 then
                table.remove(frameTimeHistory, 1)
            end
            
            Wait(HudCore.UpdateInterval)
        end
    end)
end

function HudCore:CheckPerformance()
    local currentTime = GetGameTimer()
    local timeDiff = currentTime - lastPerformanceCheck
    lastPerformanceCheck = currentTime
    
    -- Calculate average FPS
    local avgFrameTime = 0
    for _, frameTime in ipairs(frameTimeHistory) do
        avgFrameTime = avgFrameTime + frameTime
    end
    avgFrameTime = avgFrameTime / #frameTimeHistory
    local avgFPS = 1.0 / avgFrameTime
    
    -- Performance warning
    if avgFPS < 30 then
        print("^3[HUD-CORE-WARNING]^7 Low FPS detected: " .. math.ceil(avgFPS) .. " FPS")
        
        -- Suggest performance mode
        if HudSettings and HudSettings.Menu and not HudSettings.Menu.performanceMode then
            SendNUIMessage({
                action = 'suggestPerformanceMode',
                reason = 'low_fps',
                currentFPS = math.ceil(avgFPS)
            })
        end
    end
    
    -- Debug info
    if HudSettings and HudSettings.Menu and HudSettings.Menu.debugMode then
        print("^3[HUD-CORE-DEBUG]^7 Performance: " .. math.ceil(avgFPS) .. " FPS, Update cycles: " .. updateCycleCount)
    end
end

--[[
    🎛️ External Interface
]]
function HudCore:GetCurrentStatus()
    return {
        health = lastStatus.health or 100,
        armor = lastStatus.armor or 0,
        hunger = lastStatus.hunger or 100,
        thirst = lastStatus.thirst or 100,
        stress = lastStatus.stress or 0,
        oxygen = lastStatus.oxygen or 100,
        stamina = lastStatus.stamina or 100
    }
end

function HudCore:SetUpdateInterval(interval)
    if interval >= 50 and interval <= 1000 then
        HudCore.UpdateInterval = interval
        print("^2[HUD-CORE]^7 Update interval set to: " .. interval .. "ms")
    else
        print("^1[HUD-CORE-ERROR]^7 Invalid update interval: " .. tostring(interval))
    end
end

function HudCore:ForceUpdate()
    self:UpdateCriticalStats()
    self:UpdateRegularStats()
    self:UpdateSlowStats()
end

--[[
    📡 Event Handlers
]]
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    HudCore.PlayerData = QBCore.Functions.GetPlayerData()
    print("^2[HUD-CORE]^7 Player loaded event received")
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    HudCore.PlayerData = {}
    lastStatus = {}
    print("^2[HUD-CORE]^7 Player unloaded")
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    HudCore.PlayerData = data
end)

RegisterNetEvent('hud:client:UpdateStatus', function(statusData)
    if statusData then
        for key, value in pairs(statusData) do
            if lastStatus[key] ~= value then
                lastStatus[key] = value
            end
        end
        
        HudCore:SendStatusToNUI(statusData)
    end
end)

RegisterNetEvent('hud:client:ForceUpdate', function()
    HudCore:ForceUpdate()
end)

--[[
    🔧 Exports for other modules
]]
exports('GetHudCore', function()
    return HudCore
end)

exports('GetCurrentStatus', function()
    return HudCore:GetCurrentStatus()
end)

exports('ForceStatusUpdate', function()
    HudCore:ForceUpdate()
end)

print("^2[HUD-CORE]^7 Module loaded successfully")