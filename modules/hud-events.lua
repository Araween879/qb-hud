--[[
    📡 Enhanced HUD - Events Module
    
    Handles:
    - Server-client event communication
    - NUI callback registration
    - Event routing between modules
    - External resource integration
    - Error handling for events
]]

local QBCore = exports['qb-core']:GetCoreObject()

HudEvents = {}
HudEvents.RegisteredEvents = {}
HudEvents.RegisteredCallbacks = {}

-- Event statistics
local eventStats = {
    totalEvents = 0,
    failedEvents = 0,
    callbacksRegistered = 0
}

--[[
    📡 Initialize Events Module
]]
function HudEvents:Initialize()
    print("^2[HUD-EVENTS]^7 Initializing event systems...")
    
    -- Register core events
    self:RegisterCoreEvents()
    
    -- Register NUI callbacks
    self:RegisterCoreCallbacks()
    
    -- Register external integration events
    self:RegisterExternalEvents()
    
    -- Start event monitoring
    self:StartEventMonitoring()
    
    print("^2[HUD-EVENTS]^7 Event systems initialized")
end

--[[
    🔄 Register Core System Events
]]
function HudEvents:RegisterCoreEvents()
    -- Player lifecycle events
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        eventStats.totalEvents = eventStats.totalEvents + 1
        print("^2[HUD-EVENTS]^7 Player loaded event received")
        
        -- Initialize all modules with player data
        CreateThread(function()
            Wait(2000) -- Wait for data to stabilize
            
            if HudCore then HudCore.PlayerData = QBCore.Functions.GetPlayerData() end
            if HudSettings then HudSettings:LoadSettings() end
            if HudThemes then HudThemes:LoadSavedTheme() end
            if HudMap then HudMap:LoadMapSettings() end
            
            -- Force initial updates
            if HudCore then HudCore:ForceUpdate() end
        end)
    end)
    
    RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
        eventStats.totalEvents = eventStats.totalEvents + 1
        print("^2[HUD-EVENTS]^7 Player unload event received")
        
        -- Reset all module data
        if HudCore then HudCore.PlayerData = {} end
        if HudVehicle then HudVehicle.CurrentVehicle = nil end
    end)
    
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
        eventStats.totalEvents = eventStats.totalEvents + 1
        if HudCore then HudCore.PlayerData = data end
    end)
    
    -- HUD-specific events
    RegisterNetEvent('hud:client:UpdateStatus', function(statusData)
        eventStats.totalEvents = eventStats.totalEvents + 1
        if HudCore then
            TriggerEvent('hud:client:UpdateStatus', statusData)
        end
    end)
    
    RegisterNetEvent('hud:client:ForceUpdate', function()
        eventStats.totalEvents = eventStats.totalEvents + 1
        if HudCore then HudCore:ForceUpdate() end
        if HudVehicle then HudVehicle:ForceVehicleUpdate() end
    end)
end

--[[
    🎮 Register Core NUI Callbacks
]]
function HudEvents:RegisterCoreCallbacks()
    -- HUD Menu callbacks
    RegisterNUICallback('closeMenu', function(_, cb)
        self:SafeCallback('closeMenu', function()
            SetNuiFocus(false, false)
            if HudThemes then
                HudThemes:TriggerGlow('menu-close', '#ff4444', 0.8)
            end
        end)
        cb('ok')
    end)
    
    RegisterNUICallback('openMenu', function(_, cb)
        self:SafeCallback('openMenu', function()
            SetNuiFocus(true, true)
            if HudThemes then
                HudThemes:TriggerGlow('menu-open', '#00ffff', 1.0)
            end
        end)
        cb('ok')
    end)
    
    -- Settings callbacks
    RegisterNUICallback('requestSettings', function(_, cb)
        self:SafeCallback('requestSettings', function()
            local settings = {}
            if HudSettings then
                settings = HudSettings.Menu
            end
            cb(settings)
        end)
    end)
    
    -- Theme callbacks
    RegisterNUICallback('requestThemes', function(_, cb)
        self:SafeCallback('requestThemes', function()
            local themes = {}
            if HudThemes then
                themes = HudThemes:GetAvailableThemes()
            end
            cb(themes)
        end)
    end)
    
    RegisterNUICallback('changeTheme', function(data, cb)
        self:SafeCallback('changeTheme', function()
            if HudThemes and data.theme then
                HudThemes:SetTheme(data.theme)
            end
        end)
        cb('ok')
    end)
    
    -- Status request callback
    RegisterNUICallback('requestStatus', function(_, cb)
        self:SafeCallback('requestStatus', function()
            local status = {}
            if HudCore then
                status = HudCore:GetCurrentStatus()
            end
            cb(status)
        end)
    end)
    
    -- Vehicle data request
    RegisterNUICallback('requestVehicleData', function(_, cb)
        self:SafeCallback('requestVehicleData', function()
            local vehicleData = {}
            if HudVehicle then
                vehicleData = HudVehicle:GetCurrentVehicleData()
            end
            cb(vehicleData)
        end)
    end)
    
    -- Debug commands
    RegisterNUICallback('debugCommand', function(data, cb)
        self:SafeCallback('debugCommand', function()
            if data.command then
                self:HandleDebugCommand(data.command, data.params)
            end
        end)
        cb('ok')
    end)
    
    eventStats.callbacksRegistered = eventStats.callbacksRegistered + 8
end

--[[
    🔗 Register External Resource Integration Events
]]
function HudEvents:RegisterExternalEvents()
    -- QBCore inventory events
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        -- Trigger harness check after inventory loads
        CreateThread(function()
            Wait(5000)
            local PlayerData = QBCore.Functions.GetPlayerData()
            if PlayerData and PlayerData.items and HudVehicle then
                HudVehicle:UpdateHarnessStatus(PlayerData.items)
            end
        end)
    end)
    
    -- Inventory update events
    RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
        if data.items and HudVehicle then
            HudVehicle:UpdateHarnessStatus(data.items)
        end
    end)
    
    -- Fuel system events
    RegisterNetEvent('LegacyFuel:SetFuel', function(fuel)
        TriggerEvent('fuel:client:UpdateFuel', fuel)
    end)
    
    RegisterNetEvent('ps-fuel:client:SetFuel', function(fuel)
        TriggerEvent('fuel:client:UpdateFuel', fuel)
    end)
    
    -- Status events from other resources
    RegisterNetEvent('hud:client:UpdateNeeds', function(hunger, thirst)
        if HudCore then
            local statusData = {}
            if hunger then statusData.hunger = hunger end
            if thirst then statusData.thirst = thirst end
            TriggerEvent('hud:client:UpdateStatus', statusData)
        end
    end)
    
    RegisterNetEvent('hud:client:UpdateStress', function(stress)
        if HudCore then
            TriggerEvent('hud:client:UpdateStatus', { stress = stress })
        end
    end)
    
    -- Voice/proximity events
    RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
        SendNUIMessage({
            action = 'updateVoiceMode',
            mode = mode
        })
    end)
    
    -- Job/duty events
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
        SendNUIMessage({
            action = 'updateJob',
            job = jobInfo
        })
    end)
    
    -- Money update events
    RegisterNetEvent('hud:client:OnMoneyChange', function(moneyType, amount)
        if HudThemes then
            local color = '#66bb6a'
            if amount < 0 then color = '#ff4444' end
            HudThemes:TriggerGlow('money-' .. moneyType, color, 1.0)
        end
    end)
end

--[[
    🛡️ Safe Callback Execution
]]
function HudEvents:SafeCallback(name, callback)
    local success, error = pcall(callback)
    if not success then
        eventStats.failedEvents = eventStats.failedEvents + 1
        print("^1[HUD-EVENTS-ERROR]^7 Callback '" .. name .. "' failed: " .. tostring(error))
        
        -- Send error to debug system if enabled
        if HudSettings and HudSettings:GetSetting('debugMode', false) then
            SendNUIMessage({
                action = 'debugError',
                callback = name,
                error = tostring(error),
                timestamp = GetGameTimer()
            })
        end
    end
end

--[[
    🔧 Handle Debug Commands
]]
function HudEvents:HandleDebugCommand(command, params)
    if not HudSettings or not HudSettings:GetSetting('debugMode', false) then
        return
    end
    
    print("^3[HUD-EVENTS-DEBUG]^7 Command: " .. command)
    
    if command == 'forceUpdate' then
        if HudCore then HudCore:ForceUpdate() end
        if HudVehicle then HudVehicle:ForceVehicleUpdate() end
        print("^3[HUD-EVENTS-DEBUG]^7 Force update executed")
        
    elseif command == 'resetSettings' then
        if HudSettings then HudSettings:ResetToDefaults() end
        print("^3[HUD-EVENTS-DEBUG]^7 Settings reset to defaults")
        
    elseif command == 'reloadMap' then
        if HudMap then HudMap:ForceMapReload() end
        print("^3[HUD-EVENTS-DEBUG]^7 Map reloaded")
        
    elseif command == 'testCriticalAlert' then
        if HudThemes and params and params.stat then
            HudThemes:TriggerCriticalAlert(params.stat, params.value or 10)
        end
        print("^3[HUD-EVENTS-DEBUG]^7 Critical alert triggered")
        
    elseif command == 'testGlow' then
        if HudThemes and params then
            HudThemes:TriggerGlow(params.element or 'test', params.color or '#00ffff', params.intensity or 1.0)
        end
        print("^3[HUD-EVENTS-DEBUG]^7 Glow effect triggered")
        
    elseif command == 'getStats' then
        local stats = {
            events = eventStats,
            modules = {
                core = HudCore ~= nil,
                settings = HudSettings ~= nil,
                themes = HudThemes ~= nil,
                vehicle = HudVehicle ~= nil,
                map = HudMap ~= nil
            }
        }
        SendNUIMessage({
            action = 'debugStats',
            stats = stats
        })
        print("^3[HUD-EVENTS-DEBUG]^7 Stats sent to NUI")
        
    else
        print("^1[HUD-EVENTS-DEBUG]^7 Unknown debug command: " .. command)
    end
end

--[[
    📊 Start Event Monitoring
]]
function HudEvents:StartEventMonitoring()
    CreateThread(function()
        while true do
            Wait(60000) -- Check every minute
            
            -- Log event statistics if debug mode is enabled
            if HudSettings and HudSettings:GetSetting('debugMode', false) then
                print("^3[HUD-EVENTS-DEBUG]^7 Event Stats - Total: " .. eventStats.totalEvents .. 
                      ", Failed: " .. eventStats.failedEvents .. 
                      ", Callbacks: " .. eventStats.callbacksRegistered)
            end
            
            -- Alert if too many failed events
            if eventStats.failedEvents > 10 then
                print("^1[HUD-EVENTS-WARNING]^7 High number of failed events: " .. eventStats.failedEvents)
                -- Reset counter to avoid spam
                eventStats.failedEvents = 0
            end
        end
    end)
end

--[[
    🔧 Utility Functions
]]
function HudEvents:GetEventStats()
    return eventStats
end

function HudEvents:TriggerSafeEvent(eventName, ...)
    local success, error = pcall(TriggerEvent, eventName, ...)
    
    if not success then
        eventStats.failedEvents = eventStats.failedEvents + 1
        print("^1[HUD-EVENTS-ERROR]^7 Failed to trigger event '" .. eventName .. "': " .. tostring(error))
    end
    
    return success
end

function HudEvents:SendSafeNUIMessage(data)
    local success, error = pcall(SendNUIMessage, data)
    
    if not success then
        eventStats.failedEvents = eventStats.failedEvents + 1
        print("^1[HUD-EVENTS-ERROR]^7 Failed to send NUI message: " .. tostring(error))
    end
    
    return success
end

--[[
    🔧 Exports
]]
exports('GetHudEvents', function()
    return HudEvents
end)

exports('GetEventStats', function()
    return HudEvents:GetEventStats()
end)

exports('TriggerSafeEvent', function(eventName, ...)
    return HudEvents:TriggerSafeEvent(eventName, ...)
end)

exports('SendSafeNUIMessage', function(data)
    return HudEvents:SendSafeNUIMessage(data)
end)

print("^2[HUD-EVENTS]^7 Module loaded successfully")