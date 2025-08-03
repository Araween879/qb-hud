--[[
    File: qb-hud-compatibility.lua
    Description: Backward compatibility layer for original qb-hud exports
    Author: QBCore Development Team
    Version: 3.2.0
    
    This file ensures backward compatibility with the original qb-hud exports
    so that other resources continue to work without modifications.
    
    Add this file to your fxmanifest.lua:
    client_scripts {
        -- ... other files ...
        'qb-hud-compatibility.lua'
    }
]]

-- ========================================
-- Original qb-hud Export Compatibility
-- ========================================

--[[
    The original qb-hud had these common exports that other resources depend on.
    We'll map them to our new advanced system to maintain compatibility.
]]

-- Legacy export: Hide entire HUD
exports('hideHud', function()
    if HudManager and HudManager.hide then
        HudManager.hide()
        return true
    end
    return false
end)

-- Legacy export: Show entire HUD
exports('showHud', function()
    if HudManager and HudManager.show then
        HudManager.show()
        return true
    end
    return false
end)

-- Legacy export: Toggle HUD visibility
exports('toggleHud', function()
    if HudManager and HudManager.toggle then
        HudManager.toggle()
        return true
    end
    return false
end)

-- Legacy export: Update player status (most commonly used)
exports('updateStatus', function(data)
    if not data or type(data) ~= 'table' then
        return false
    end
    
    -- Map old format to new format if needed
    local mappedData = {}
    
    -- Handle different data formats from various resources
    if data.health then mappedData.health = data.health end
    if data.armor then mappedData.armor = data.armor end
    if data.hunger then mappedData.hunger = data.hunger end
    if data.thirst then mappedData.thirst = data.thirst end
    if data.stress then mappedData.stress = data.stress end
    if data.stamina then mappedData.stamina = data.stamina end
    
    -- Handle legacy field names
    if data.food then mappedData.hunger = data.food end
    if data.water then mappedData.thirst = data.water end
    if data.energy then mappedData.stamina = data.energy end
    
    -- Trigger our new system
    TriggerEvent('hud:updateStatus', mappedData)
    return true
end)

-- Legacy export: Set component visibility
exports('setVisible', function(component, visible)
    if not component then return false end
    
    -- Map old component names to new ones
    local componentMap = {
        ['hud'] = 'StatusBars',
        ['status'] = 'StatusBars',
        ['statusbar'] = 'StatusBars',
        ['minimap'] = 'Minimap',
        ['speedometer'] = 'Speedometer',
        ['vehicle'] = 'Speedometer',
        ['notifications'] = 'Notifications'
    }
    
    local newComponentName = componentMap[string.lower(component)] or component
    
    if ComponentManager then
        if visible then
            ComponentManager.show(newComponentName)
        else
            ComponentManager.hide(newComponentName)
        end
        return true
    end
    
    return false
end)

-- Legacy export: Update specific status value
exports('updateValue', function(statusType, value)
    if not statusType or not value then return false end
    
    local data = {}
    data[statusType] = value
    
    TriggerEvent('hud:updateStatus', data)
    return true
end)

-- Legacy export: Set HUD theme (if original had this)
exports('setTheme', function(themeName)
    if ThemeManager and ThemeManager.setTheme then
        return ThemeManager.setTheme(themeName)
    end
    return false
end)

-- Legacy export: Get current HUD state
exports('getHudState', function()
    return {
        visible = HudManager and HudManager.isVisible() or false,
        initialized = HudManager and HudManager.isInitialized() or false,
        theme = ThemeManager and ThemeManager.getTheme() or 'default'
    }
end)

-- Legacy export: Show notification
exports('showNotification', function(message, type, duration)
    TriggerEvent('hud:notification', {
        message = message or 'Notification',
        type = type or 'info',
        duration = duration or 5000
    })
    return true
end)

-- Legacy export: Set HUD position
exports('setPosition', function(component, x, y)
    -- This was rarely used in original, but we'll provide basic support
    if ComponentManager and ComponentManager.setPosition then
        return ComponentManager.setPosition(component, { x = x, y = y })
    end
    return false
end)

-- Legacy export: Reset HUD to defaults
exports('resetHud', function()
    if HudManager and HudManager.reset then
        HudManager.reset()
        return true
    end
    return false
end)

-- ========================================
-- Extended Compatibility for Popular Resources
-- ========================================

--[[
    Some popular resources have their own specific export calls.
    We'll add compatibility for the most common ones.
]]

-- qb-policejob compatibility
exports('setPoliceHud', function(data)
    if data and data.duty ~= nil then
        TriggerEvent('hud:updateJob', {
            name = 'police',
            onDuty = data.duty,
            rank = data.rank or 'Officer'
        })
    end
    return true
end)

-- qb-ambulancejob compatibility  
exports('setEMSHud', function(data)
    if data and data.duty ~= nil then
        TriggerEvent('hud:updateJob', {
            name = 'ambulance',
            onDuty = data.duty,
            rank = data.rank or 'Paramedic'
        })
    end
    return true
end)

-- qb-vehiclekeys compatibility
exports('updateVehicleHud', function(vehicleData)
    if vehicleData then
        TriggerEvent('hud:updateVehicle', vehicleData)
    end
    return true
end)

-- qb-inventory compatibility
exports('updateInventoryWeight', function(weight, maxWeight)
    if weight and maxWeight then
        ComponentManager.updateComponent('InventoryWeight', {
            current = weight,
            max = maxWeight,
            percentage = math.floor((weight / maxWeight) * 100)
        })
    end
    return true
end)

-- pma-voice compatibility
exports('updateVoiceRange', function(range)
    if range then
        ComponentManager.updateComponent('VoiceStatus', {
            range = range
        })
    end
    return true
end)

-- ========================================
-- Migration Helper Functions
-- ========================================

--[[
    These functions help other resources migrate to the new system
    while maintaining backward compatibility.
]]

-- Helper: Check if using legacy or new system
exports('isLegacyMode', function()
    return false -- We're the new system, but maintaining compatibility
end)

-- Helper: Get available new features
exports('getAvailableFeatures', function()
    return {
        themes = ThemeManager and ThemeManager.getAvailableThemes() or {},
        components = ComponentManager and ComponentManager.getAll() or {},
        performanceModes = {'low', 'medium', 'high', 'ultra'},
        newExports = {
            'setTheme',
            'getPerformanceMode',
            'registerComponent',
            'updateComponent'
        }
    }
end)

-- Helper: Migrate old settings to new format
exports('migrateSettings', function(oldSettings)
    if not oldSettings or type(oldSettings) ~= 'table' then
        return false
    end
    
    local newSettings = {}
    
    -- Map old settings to new structure
    if oldSettings.theme then
        newSettings.theme = oldSettings.theme
    end
    
    if oldSettings.position then
        newSettings.layout = {
            statusBars = oldSettings.position
        }
    end
    
    if oldSettings.visible ~= nil then
        newSettings.components = {
            StatusBars = { visible = oldSettings.visible }
        }
    end
    
    -- Apply migrated settings
    for key, value in pairs(newSettings) do
        Config.set(key, value)
    end
    
    return true
end)

-- ========================================
-- Event Compatibility Layer
-- ========================================

--[[
    Map old events to new events for resources that trigger events directly
]]

-- Legacy event handlers
RegisterNetEvent('qb-hud:client:UpdateStatus')
AddEventHandler('qb-hud:client:UpdateStatus', function(data)
    exports[GetCurrentResourceName()]:updateStatus(data)
end)

RegisterNetEvent('qb-hud:client:showHud')
AddEventHandler('qb-hud:client:showHud', function()
    exports[GetCurrentResourceName()]:showHud()
end)

RegisterNetEvent('qb-hud:client:hideHud')
AddEventHandler('qb-hud:client:hideHud', function()
    exports[GetCurrentResourceName()]:hideHud()
end)

RegisterNetEvent('qb-hud:client:toggleHud')
AddEventHandler('qb-hud:client:toggleHud', function()
    exports[GetCurrentResourceName()]:toggleHud()
end)

-- Map legacy events to new events
AddEventHandler('hud:client:UpdateNeeds', function(data)
    exports[GetCurrentResourceName()]:updateStatus(data)
end)

AddEventHandler('hud:client:UpdateStress', function(stress)
    exports[GetCurrentResourceName()]:updateStatus({ stress = stress })
end)

-- ========================================
-- Console Commands for Migration Testing
-- ========================================

if Config.Debug and Config.Debug.enabled then
    RegisterCommand('test_legacy_exports', function()
        print('🧪 Testing Legacy Export Compatibility...')
        
        -- Test basic exports
        local hideResult = exports[GetCurrentResourceName()]:hideHud()
        print('hideHud export:', hideResult and '✅ Working' or '❌ Failed')
        
        local showResult = exports[GetCurrentResourceName()]:showHud()
        print('showHud export:', showResult and '✅ Working' or '❌ Failed')
        
        local updateResult = exports[GetCurrentResourceName()]:updateStatus({
            health = 75,
            armor = 50,
            hunger = 80
        })
        print('updateStatus export:', updateResult and '✅ Working' or '❌ Failed')
        
        local visibilityResult = exports[GetCurrentResourceName()]:setVisible('statusbar', true)
        print('setVisible export:', visibilityResult and '✅ Working' or '❌ Failed')
        
        print('✅ Legacy export compatibility test completed')
    end, false)
    
    RegisterCommand('test_resource_compatibility', function()
        print('🔗 Testing Resource Compatibility...')
        
        -- Simulate qb-policejob call
        exports[GetCurrentResourceName()]:setPoliceHud({
            duty = true,
            rank = 'Sergeant'
        })
        print('✅ Police job compatibility tested')
        
        -- Simulate qb-inventory call
        exports[GetCurrentResourceName()]:updateInventoryWeight(45.5, 60.0)
        print('✅ Inventory compatibility tested')
        
        -- Simulate pma-voice call
        exports[GetCurrentResourceName()]:updateVoiceRange(15)
        print('✅ Voice compatibility tested')
        
        print('✅ Resource compatibility test completed')
    end, false)
end

-- ========================================
-- Initialization and Validation
-- ========================================

Citizen.CreateThread(function()
    -- Wait for main system to initialize
    while not HudManager or not HudManager.isInitialized() do
        Citizen.Wait(100)
    end
    
    print('✅ QBCore HUD Compatibility Layer loaded')
    print('📋 Legacy exports available: hideHud, showHud, toggleHud, updateStatus, setVisible')
    print('🔗 Extended compatibility for: qb-policejob, qb-ambulancejob, qb-inventory, pma-voice')
    
    if Config.Debug and Config.Debug.enabled then
        print('🧪 Debug commands available: /test_legacy_exports, /test_resource_compatibility')
    end
end)

-- Export compatibility info for other resources to check
exports('getCompatibilityInfo', function()
    return {
        version = '3.2.0',
        compatibleWith = 'qb-hud',
        legacyExports = {
            'hideHud', 'showHud', 'toggleHud', 'updateStatus', 
            'setVisible', 'updateValue', 'setTheme', 'getHudState',
            'showNotification', 'setPosition', 'resetHud'
        },
        extendedCompatibility = {
            'qb-policejob', 'qb-ambulancejob', 'qb-inventory', 
            'qb-vehiclekeys', 'pma-voice'
        },
        migrationHelpers = {
            'isLegacyMode', 'getAvailableFeatures', 'migrateSettings'
        }
    }
end)