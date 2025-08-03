--[[
    ⚙️ Enhanced HUD - Settings Module
    
    Handles:
    - Settings loading/saving with State Manager integration
    - NUI Callbacks for all settings
    - Server-side persistence
    - Settings validation and defaults
]]

local QBCore = exports['qb-core']:GetCoreObject()

HudSettings = {}
HudSettings.Menu = {}

-- Default settings (fallback if server persistence fails)
local DefaultSettings = {
    -- Display Settings
    isDynamicHealthChecked = true,
    isDynamicArmorChecked = true,
    isDynamicHungerChecked = true,
    isDynamicThirstChecked = true,
    isDynamicStressChecked = true,
    isDynamicOxygenChecked = true,
    
    -- Map Settings
    isOutMapChecked = true,
    isOutCompassChecked = true,
    isCompassFollowChecked = true,
    isToggleMapShapeChecked = 'circle',
    isToggleMapBordersChecked = false,
    isHideMapChecked = false,
    
    -- Compass Settings
    isCompassShowChecked = true,
    isShowStreetsChecked = true,
    isPointerShowChecked = true,
    isDegreesShowChecked = true,
    isChangeCompassFPSChecked = false,
    
    -- Vehicle Settings
    isDynamicEngineChecked = true,
    isDynamicNitroChecked = true,
    
    -- Notification Settings
    isMapNotifChecked = true,
    isLowFuelChecked = true,
    isCinematicNotifChecked = true,
    
    -- Sound Settings
    isOpenMenuSoundsChecked = true,
    isResetSoundsChecked = true,
    isListSoundsChecked = true,
    
    -- Performance Settings
    isChangeFPSChecked = false,
    performanceMode = false,
    
    -- Theme Settings
    currentNeonTheme = 'cyberpunk',
    
    -- Advanced Settings
    isCinematicModeChecked = false,
    debugMode = false
}

--[[
    🎬 Initialize Settings Module
]]
function HudSettings:Initialize()
    print("^2[HUD-SETTINGS]^7 Initializing settings system...")
    
    -- Load settings from server/state manager
    self:LoadSettings()
    
    -- Register all NUI callbacks
    self:RegisterNUICallbacks()
    
    -- Register event handlers
    self:RegisterEventHandlers()
    
    print("^2[HUD-SETTINGS]^7 Settings system initialized")
end

--[[
    📥 Load Settings from Server/State Manager
]]
function HudSettings:LoadSettings()
    -- First load from server (preferred)
    TriggerServerEvent('hud:server:requestInitialState')
    
    -- Fallback: Load from local storage
    CreateThread(function()
        Wait(2000) -- Wait for server response
        
        if not next(HudSettings.Menu) then
            local hudSettings = GetResourceKvpString('hudSettings')
            if hudSettings then
                local success, settings = pcall(json.decode, hudSettings)
                if success and settings then
                    HudSettings.Menu = settings
                    print("^3[HUD-SETTINGS]^7 Loaded from local KVP storage")
                else
                    HudSettings.Menu = DefaultSettings
                    print("^3[HUD-SETTINGS]^7 Using default settings (KVP corrupted)")
                end
            else
                HudSettings.Menu = DefaultSettings
                print("^3[HUD-SETTINGS]^7 Using default settings (no KVP)")
            end
            
            -- Apply loaded settings
            self:ApplySettings(HudSettings.Menu)
        end
    end)
end

--[[
    💾 Save Settings
]]
function HudSettings:SaveSettings()
    -- Save to server/state manager (preferred)
    local success, error = pcall(function()
        TriggerServerEvent('hud:server:batchSaveSettings', {
            updates = HudSettings.Menu,
            timestamp = GetGameTimer()
        })
    end)
    
    if not success then
        print("^1[HUD-SETTINGS-ERROR]^7 Failed to save to server: " .. tostring(error))
    end
    
    -- Fallback: Save locally
    local localSuccess, localError = pcall(function()
        SetResourceKvp('hudSettings', json.encode(HudSettings.Menu))
    end)
    
    if not localSuccess then
        print("^1[HUD-SETTINGS-ERROR]^7 Failed to save locally: " .. tostring(localError))
    end
end

--[[
    ✅ Apply Settings to Game
]]
function HudSettings:ApplySettings(settings)
    for key, value in pairs(settings) do
        if key == 'isToggleMapShapeChecked' then
            HudSettings.Menu[key] = value
            TriggerEvent('hud:client:LoadMap')
        elseif key == 'isCinematicModeChecked' then
            HudSettings.Menu[key] = value
            self:ApplyCinematicMode(value)
        elseif key == 'isChangeFPSChecked' then
            HudSettings.Menu[key] = value
            -- Apply FPS optimization
        elseif key == 'isHideMapChecked' then
            HudSettings.Menu[key] = value
            DisplayRadar(not value)
        else
            HudSettings.Menu[key] = value
        end
        
        -- Send to NUI
        SendNUIMessage({
            action = 'updateSetting',
            key = key,
            value = value
        })
    end
end

--[[
    🎭 Apply Cinematic Mode
]]
function HudSettings:ApplyCinematicMode(enabled)
    if enabled then
        SetTimecycleModifier('cinema')
        HudThemes:TriggerGlow('cinematic', '#a020f0', 1.2)
    else
        ClearTimecycleModifier()
    end
end

--[[
    📡 Register All NUI Callbacks
]]
function HudSettings:RegisterNUICallbacks()
    -- Display Settings Callbacks
    self:RegisterDisplayCallbacks()
    
    -- Map Settings Callbacks  
    self:RegisterMapCallbacks()
    
    -- Vehicle Settings Callbacks
    self:RegisterVehicleCallbacks()
    
    -- Sound Settings Callbacks
    self:RegisterSoundCallbacks()
    
    -- Performance Settings Callbacks
    self:RegisterPerformanceCallbacks()
    
    -- Advanced Settings Callbacks
    self:RegisterAdvancedCallbacks()
end

--[[
    📺 Display Settings NUI Callbacks
]]
function HudSettings:RegisterDisplayCallbacks()
    -- Dynamic Health
    RegisterNUICallback('dynamicHealth', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicHealthChecked = not HudSettings.Menu.isDynamicHealthChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('health', '#ff4444', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Dynamic Armor
    RegisterNUICallback('dynamicArmor', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicArmorChecked = not HudSettings.Menu.isDynamicArmorChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('armor', '#00bcd4', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Dynamic Hunger
    RegisterNUICallback('dynamicHunger', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicHungerChecked = not HudSettings.Menu.isDynamicHungerChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('hunger', '#ffb74d', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Dynamic Thirst
    RegisterNUICallback('dynamicThirst', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicThirstChecked = not HudSettings.Menu.isDynamicThirstChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('thirst', '#29b6f6', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Dynamic Stress
    RegisterNUICallback('dynamicStress', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicStressChecked = not HudSettings.Menu.isDynamicStressChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('stress', '#a020f0', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Dynamic Oxygen
    RegisterNUICallback('dynamicOxygen', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicOxygenChecked = not HudSettings.Menu.isDynamicOxygenChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('oxygen', '#66bb6a', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
end

--[[
    🗺️ Map Settings NUI Callbacks
]]
function HudSettings:RegisterMapCallbacks()
    -- Show Out Map
    RegisterNUICallback('showOutMap', function(_, cb)
        Wait(50)
        HudSettings.Menu.isOutMapChecked = not HudSettings.Menu.isOutMapChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('toggle', '#00ffff', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Hide Map
    RegisterNUICallback('HideMap', function(_, cb)
        Wait(50)
        HudSettings.Menu.isHideMapChecked = not HudSettings.Menu.isHideMapChecked
        DisplayRadar(not HudSettings.Menu.isHideMapChecked)
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('map', '#a020f0', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Toggle Map Shape
    RegisterNUICallback('ToggleMapShape', function(_, cb)
        Wait(50)
        if not HudSettings.Menu.isHideMapChecked then
            HudSettings.Menu.isToggleMapShapeChecked = HudSettings.Menu.isToggleMapShapeChecked == 'circle' and 'square' or 'circle'
            Wait(50)
            TriggerEvent('hud:client:LoadMap')
        end
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('mapshape', '#a020f0', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Toggle Map Borders
    RegisterNUICallback('ToggleMapBorders', function(_, cb)
        Wait(50)
        HudSettings.Menu.isToggleMapBordersChecked = not HudSettings.Menu.isToggleMapBordersChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('mapborder', '#00ffff', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Compass Settings
    RegisterNUICallback('showCompassBase', function(_, cb)
        Wait(50)
        HudSettings.Menu.isCompassShowChecked = not HudSettings.Menu.isCompassShowChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('compass', '#00ffff', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    RegisterNUICallback('showStreetsNames', function(_, cb)
        Wait(50)
        HudSettings.Menu.isShowStreetsChecked = not HudSettings.Menu.isShowStreetsChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('streets', '#00ffff', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
end

--[[
    🚗 Vehicle Settings NUI Callbacks
]]
function HudSettings:RegisterVehicleCallbacks()
    -- Dynamic Engine
    RegisterNUICallback('dynamicEngine', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicEngineChecked = not HudSettings.Menu.isDynamicEngineChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('engine', '#ff9800', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Dynamic Nitro
    RegisterNUICallback('dynamicNitro', function(_, cb)
        Wait(50)
        HudSettings.Menu.isDynamicNitroChecked = not HudSettings.Menu.isDynamicNitroChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('nitro', '#a020f0', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Low Fuel Alert
    RegisterNUICallback('showFuelAlert', function(_, cb)
        Wait(50)
        HudSettings.Menu.isLowFuelChecked = not HudSettings.Menu.isLowFuelChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('toggle', '#ff4444', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
end

--[[
    🔊 Sound Settings NUI Callbacks
]]
function HudSettings:RegisterSoundCallbacks()
    -- Menu Sounds
    RegisterNUICallback('openMenuSounds', function(_, cb)
        Wait(50)
        HudSettings.Menu.isOpenMenuSoundsChecked = not HudSettings.Menu.isOpenMenuSoundsChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('checkbox', '#ff9800', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Reset Sounds
    RegisterNUICallback('resetHudSounds', function(_, cb)
        Wait(50)
        HudSettings.Menu.isResetSoundsChecked = not HudSettings.Menu.isResetSoundsChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('checkbox', '#ff9800', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Checklist Sounds
    RegisterNUICallback('checklistSounds', function(_, cb)
        Wait(50)
        HudSettings.Menu.isListSoundsChecked = not HudSettings.Menu.isListSoundsChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('checkbox', '#a020f0', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
end

--[[
    ⚡ Performance Settings NUI Callbacks
]]
function HudSettings:RegisterPerformanceCallbacks()
    -- Change FPS
    RegisterNUICallback('changeFPS', function(_, cb)
        Wait(50)
        HudSettings.Menu.isChangeFPSChecked = not HudSettings.Menu.isChangeFPSChecked
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('fps', '#00ffff', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Performance Mode
    RegisterNUICallback('performanceMode', function(_, cb)
        Wait(50)
        HudSettings.Menu.performanceMode = not HudSettings.Menu.performanceMode
        
        -- Apply performance mode
        SendNUIMessage({
            action = 'setPerformanceMode',
            enabled = HudSettings.Menu.performanceMode
        })
        
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('performance', '#00ffff', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
end

--[[
    🎛️ Advanced Settings NUI Callbacks
]]
function HudSettings:RegisterAdvancedCallbacks()
    -- Cinematic Mode
    RegisterNUICallback('cinematicMode', function(_, cb)
        Wait(50)
        HudSettings.Menu.isCinematicModeChecked = not HudSettings.Menu.isCinematicModeChecked
        HudSettings:ApplyCinematicMode(HudSettings.Menu.isCinematicModeChecked)
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('cinematic', '#a020f0', 1.2)
        HudSettings:SaveSettings()
        cb('ok')
    end)
    
    -- Debug Mode
    RegisterNUICallback('debugMode', function(_, cb)
        Wait(50)
        HudSettings.Menu.debugMode = not HudSettings.Menu.debugMode
        TriggerEvent('hud:client:playHudChecklistSound')
        HudThemes:TriggerGlow('debug', '#ff9800', 0.8)
        HudSettings:SaveSettings()
        cb('ok')
    end)
end

--[[
    📡 Event Handlers
]]
function HudSettings:RegisterEventHandlers()
    -- Settings loaded from server
    RegisterNetEvent('hud:client:loadInitialState', function(serverSettings)
        if serverSettings then
            print("^2[HUD-SETTINGS]^7 Loaded settings from server")
            HudSettings.Menu = serverSettings
            HudSettings:ApplySettings(serverSettings)
        end
    end)
    
    -- Settings saved confirmation
    RegisterNetEvent('hud:client:settingsSaved', function(data)
        if HudSettings.Menu.debugMode then
            print("^2[HUD-SETTINGS]^7 Setting saved: " .. data.key)
        end
    end)
    
    -- Settings error
    RegisterNetEvent('hud:client:settingsError', function(data)
        print("^1[HUD-SETTINGS-ERROR]^7 " .. data.error)
    end)
    
    -- Sound Events
    RegisterNetEvent('hud:client:playHudChecklistSound', function()
        Wait(50)
        if not HudSettings.Menu.isListSoundsChecked then return end
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'shiftyclick', 0.5)
    end)
    
    RegisterNetEvent('hud:client:playResetHudSounds', function()
        Wait(50)
        if not HudSettings.Menu.isResetSoundsChecked then return end
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'airwrench', 0.1)
    end)
end

--[[
    🔧 Utility Functions
]]
function HudSettings:GetSetting(key, default)
    return HudSettings.Menu[key] or default
end

function HudSettings:SetSetting(key, value, save)
    HudSettings.Menu[key] = value
    if save then
        HudSettings:SaveSettings()
    end
end

function HudSettings:ResetToDefaults()
    HudSettings.Menu = DefaultSettings
    HudSettings:ApplySettings(HudSettings.Menu)
    HudSettings:SaveSettings()
    print("^2[HUD-SETTINGS]^7 Settings reset to defaults")
end

--[[
    🔧 Exports
]]
exports('GetHudSettings', function()
    return HudSettings
end)

exports('GetSetting', function(key, default)
    return HudSettings:GetSetting(key, default)
end)

exports('SetSetting', function(key, value, save)
    HudSettings:SetSetting(key, value, save or true)
end)

print("^2[HUD-SETTINGS]^7 Module loaded successfully")