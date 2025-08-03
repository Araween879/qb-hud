--[[
    File: integration-examples.lua
    Description: Complete integration examples for QBCore Advanced HUD System
    Author: QBCore Development Team
    Version: 3.2.0
    
    This file contains ready-to-use integration examples for:
    - QBCore Framework
    - ESX Framework
    - Custom resources
    - Third-party scripts
    - Popular FiveM resources
    
    Copy and adapt these examples for your specific needs.
]]

-- ========================================
-- QBCore Framework Integration
-- ========================================

--[[
    Basic QBCore Integration
    Place this in your main client.lua file
]]
local QBCoreIntegration = {
    -- Initialize HUD with QBCore
    init = function()
        -- Wait for QBCore to be ready
        local QBCore = exports['qb-core']:GetCoreObject()
        
        -- Initialize HUD system
        HudManager.initialize()
        
        -- Configure for QBCore
        Config.set('Integration.framework', 'qbcore')
        Config.set('Integration.autoUpdate', true)
    end,
    
    -- Handle player loaded event
    onPlayerLoaded = function()
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        
        if PlayerData and PlayerData.metadata then
            -- Update HUD with initial player data
            TriggerEvent('hud:updateStatus', {
                health = PlayerData.metadata.health or 100,
                armor = PlayerData.metadata.armor or 0,
                hunger = PlayerData.metadata.hunger or 100,
                thirst = PlayerData.metadata.thirst or 100,
                stress = PlayerData.metadata.stress or 0,
                stamina = PlayerData.metadata.stamina or 100
            })
        end
        
        -- Load player's HUD preferences
        if PlayerData.citizenid then
            Database.loadPlayerSettings(PlayerData.citizenid, function(settings)
                if settings then
                    if settings.theme then
                        ThemeManager.setTheme(settings.theme)
                    end
                    if settings.performance then
                        PerformanceManager.setMode(settings.performance)
                    end
                end
            end)
        end
    end,
    
    -- Handle player data updates
    onPlayerDataUpdate = function(playerData)
        if playerData.metadata then
            TriggerEvent('hud:updateStatus', {
                health = playerData.metadata.health,
                armor = playerData.metadata.armor,
                hunger = playerData.metadata.hunger,
                thirst = playerData.metadata.thirst,
                stress = playerData.metadata.stress,
                stamina = playerData.metadata.stamina
            })
        end
        
        -- Update job information if available
        if playerData.job then
            TriggerEvent('hud:updateJob', {
                name = playerData.job.name,
                label = playerData.job.label,
                grade = playerData.job.grade.level,
                salary = playerData.job.grade.payment
            })
        end
    end,
    
    -- Handle money updates
    onMoneyChange = function(moneyData)
        TriggerEvent('hud:updateMoney', {
            cash = moneyData.cash,
            bank = moneyData.bank,
            crypto = moneyData.crypto or 0
        })
    end
}

-- Register QBCore events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', QBCoreIntegration.onPlayerLoaded)
RegisterNetEvent('QBCore:Player:SetPlayerData', QBCoreIntegration.onPlayerDataUpdate)
RegisterNetEvent('QBCore:Client:OnMoneyChange', QBCoreIntegration.onMoneyChange)

-- Initialize when resource starts
Citizen.CreateThread(function()
    QBCoreIntegration.init()
end)

-- ========================================
-- ESX Framework Integration
-- ========================================

--[[
    ESX Framework Integration Example
    Adapt this for ESX-based servers
]]
local ESXIntegration = {
    ESX = nil,
    
    init = function()
        -- Wait for ESX to be ready
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
        
        -- Initialize HUD
        HudManager.initialize()
        Config.set('Integration.framework', 'esx')
        
        -- Get initial player data
        ESX.TriggerServerCallback('esx:getPlayerData', function(playerData)
            ESXIntegration.updatePlayerStatus(playerData)
        end)
    end,
    
    updatePlayerStatus = function(playerData)
        if not playerData then return end
        
        -- Convert ESX status to HUD format
        local hudStatus = {
            health = GetEntityHealth(PlayerPedId()) - 100, -- ESX uses 100-200 range
            armor = GetPedArmour(PlayerPedId())
        }
        
        -- Process ESX status
        if playerData.status then
            for _, status in pairs(playerData.status) do
                if status.name == 'hunger' then
                    hudStatus.hunger = math.floor(status.val / 10000) -- ESX uses 0-1000000 range
                elseif status.name == 'thirst' then
                    hudStatus.thirst = math.floor(status.val / 10000)
                elseif status.name == 'stress' then
                    hudStatus.stress = math.floor(status.val / 10000)
                end
            end
        end
        
        TriggerEvent('hud:updateStatus', hudStatus)
    end,
    
    onStatusUpdate = function(statusName, value)
        local updateData = {}
        
        if statusName == 'hunger' then
            updateData.hunger = math.floor(value / 10000)
        elseif statusName == 'thirst' then
            updateData.thirst = math.floor(value / 10000)
        elseif statusName == 'stress' then
            updateData.stress = math.floor(value / 10000)
        end
        
        if next(updateData) then
            TriggerEvent('hud:updateStatus', updateData)
        end
    end
}

-- ESX Event Handlers
RegisterNetEvent('esx:playerLoaded', ESXIntegration.init)
RegisterNetEvent('esx_status:onTick', ESXIntegration.updatePlayerStatus)
AddEventHandler('esx_status:onTick', function(data)
    for _, status in pairs(data) do
        ESXIntegration.onStatusUpdate(status.name, status.val)
    end
end)

-- ========================================
-- Vehicle Integration Examples
-- ========================================

--[[
    Advanced Vehicle HUD Integration
    Works with most vehicle systems
]]
local VehicleIntegration = {
    currentVehicle = nil,
    updateInterval = 100, -- ms
    
    init = function()
        Citizen.CreateThread(VehicleIntegration.updateLoop)
    end,
    
    updateLoop = function()
        while true do
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if vehicle ~= 0 then
                VehicleIntegration.updateVehicleHUD(vehicle)
                VehicleIntegration.currentVehicle = vehicle
            elseif VehicleIntegration.currentVehicle then
                -- Player exited vehicle
                TriggerEvent('hud:vehicle:exit')
                VehicleIntegration.currentVehicle = nil
            end
            
            Citizen.Wait(VehicleIntegration.updateInterval)
        end
    end,
    
    updateVehicleHUD = function(vehicle)
        local speed = GetEntitySpeed(vehicle) * 3.6 -- Convert to km/h
        local fuel = GetVehicleFuelLevel(vehicle)
        local engine = GetVehicleEngineHealth(vehicle)
        local body = GetVehicleBodyHealth(vehicle)
        local gear = GetVehicleCurrentGear(vehicle)
        local rpm = GetVehicleCurrentRpm(vehicle)
        local maxSpeed = GetVehicleModelMaxSpeed(GetEntityModel(vehicle))
        
        -- Check for additional vehicle systems
        local extras = VehicleIntegration.getVehicleExtras(vehicle)
        
        TriggerEvent('hud:updateVehicle', {
            speed = math.floor(speed),
            fuel = math.floor(fuel),
            engine = math.floor(engine / 10), -- Convert to 0-100 scale
            body = math.floor(body / 10),
            gear = gear,
            rpm = math.floor(rpm * 100),
            maxSpeed = math.floor(maxSpeed * 3.6),
            extras = extras
        })
    end,
    
    getVehicleExtras = function(vehicle)
        local extras = {}
        
        -- Check for common vehicle modifications
        extras.turbo = IsToggleModOn(vehicle, 18)
        extras.xenonLights = IsToggleModOn(vehicle, 22)
        extras.bulletproofTires = GetVehicleTyresCanBurst(vehicle) == false
        
        -- Check vehicle class for specific features
        local vehicleClass = GetVehicleClass(vehicle)
        if vehicleClass == 8 then -- Motorcycles
            extras.wheelie = IsEntityInAir(vehicle)
        elseif vehicleClass == 15 or vehicleClass == 16 then -- Helicopters/Planes
            extras.altitude = GetEntityHeightAboveGround(vehicle)
            extras.landing = IsVehicleOnAllWheels(vehicle)
        end
        
        return extras
    end
}

-- Initialize vehicle integration
VehicleIntegration.init()

-- ========================================
-- Job-Specific HUD Integration
-- ========================================

--[[
    Police Job HUD Integration
    Shows police-specific information
]]
local PoliceIntegration = {
    isPolice = false,
    
    checkJob = function()
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        
        PoliceIntegration.isPolice = PlayerData.job and PlayerData.job.name == 'police'
        
        if PoliceIntegration.isPolice then
            PoliceIntegration.enablePoliceHUD()
        else
            PoliceIntegration.disablePoliceHUD()
        end
    end,
    
    enablePoliceHUD = function()
        -- Register custom police component
        ComponentManager.register('PoliceStatus', {
            name = 'PoliceStatus',
            element = '#police-status',
            visible = true,
            show = function()
                SendNUIMessage({
                    action = 'showComponent',
                    component = 'PoliceStatus'
                })
            end,
            hide = function()
                SendNUIMessage({
                    action = 'hideComponent',
                    component = 'PoliceStatus'
                })
            end,
            update = function(self, data)
                SendNUIMessage({
                    action = 'updatePoliceStatus',
                    data = data
                })
            end
        })
        
        -- Show police-specific information
        ComponentManager.show('PoliceStatus')
        PoliceIntegration.startPoliceUpdates()
    end,
    
    disablePoliceHUD = function()
        ComponentManager.hide('PoliceStatus')
        ComponentManager.unregister('PoliceStatus')
    end,
    
    startPoliceUpdates = function()
        Citizen.CreateThread(function()
            while PoliceIntegration.isPolice do
                -- Update police-specific data
                local dutyStatus = exports['qb-policejob']:GetDutyStatus()
                local callsCount = exports['qb-policejob']:GetActiveCalls()
                
                ComponentManager.updateComponent('PoliceStatus', {
                    onDuty = dutyStatus,
                    activeCalls = callsCount,
                    rank = 'Officer', -- Get from job data
                    badge = '1234'    -- Get from player data
                })
                
                Citizen.Wait(5000) -- Update every 5 seconds
            end
        end)
    end
}

-- Register job update events
RegisterNetEvent('QBCore:Client:OnJobUpdate', PoliceIntegration.checkJob)
RegisterNetEvent('QBCore:Client:SetDuty', PoliceIntegration.checkJob)

--[[
    EMS Job Integration
    Similar pattern for EMS/Hospital job
]]
local EMSIntegration = {
    -- Similar structure to PoliceIntegration
    -- Implement EMS-specific HUD elements
}

-- ========================================
-- Inventory Integration Examples
-- ========================================

--[[
    QB-Inventory Integration
    Shows inventory weight and notifications
]]
local InventoryIntegration = {
    init = function()
        -- Register inventory component
        ComponentManager.register('InventoryWeight', {
            name = 'InventoryWeight',
            element = '#inventory-weight',
            visible = true,
            show = function()
                SendNUIMessage({
                    action = 'showInventoryWeight'
                })
            end,
            hide = function()
                SendNUIMessage({
                    action = 'hideInventoryWeight'
                })
            end,
            update = function(self, data)
                SendNUIMessage({
                    action = 'updateInventoryWeight',
                    data = data
                })
            end
        })
    end,
    
    onWeightUpdate = function(weight, maxWeight)
        local percentage = math.floor((weight / maxWeight) * 100)
        
        ComponentManager.updateComponent('InventoryWeight', {
            current = weight,
            max = maxWeight,
            percentage = percentage,
            overweight = weight > maxWeight
        })
    end,
    
    onItemAdd = function(item, amount)
        -- Show item notification
        TriggerEvent('hud:notification', {
            type = 'item_add',
            item = item,
            amount = amount,
            duration = 3000
        })
    end,
    
    onItemRemove = function(item, amount)
        TriggerEvent('hud:notification', {
            type = 'item_remove',
            item = item,
            amount = amount,
            duration = 3000
        })
    end
}

-- QB-Inventory events
RegisterNetEvent('inventory:client:ItemBox', InventoryIntegration.onItemAdd)
RegisterNetEvent('qb-inventory:client:UpdateWeight', InventoryIntegration.onWeightUpdate)

-- ox_inventory events (alternative)
RegisterNetEvent('ox_inventory:updateWeight', InventoryIntegration.onWeightUpdate)

-- ========================================
-- Phone Integration Examples
-- ========================================

--[[
    QB-Phone Integration
    Shows phone notifications and status
]]
local PhoneIntegration = {
    phoneOpen = false,
    
    onPhoneOpen = function()
        PhoneIntegration.phoneOpen = true
        -- Optionally hide some HUD elements when phone is open
        ComponentManager.hide('Speedometer')
    end,
    
    onPhoneClose = function()
        PhoneIntegration.phoneOpen = false
        ComponentManager.show('Speedometer')
    end,
    
    onNotification = function(notificationData)
        -- Show phone notification in HUD
        TriggerEvent('hud:notification', {
            type = 'phone',
            title = notificationData.title,
            message = notificationData.message,
            app = notificationData.app,
            duration = 5000
        })
    end,
    
    onCallStart = function(callData)
        ComponentManager.updateComponent('PhoneCall', {
            active = true,
            caller = callData.name,
            number = callData.number,
            duration = 0
        })
    end,
    
    onCallEnd = function()
        ComponentManager.updateComponent('PhoneCall', {
            active = false
        })
    end
}

-- QB-Phone events
RegisterNetEvent('qb-phone:client:CustomNotification', PhoneIntegration.onNotification)
RegisterNetEvent('qb-phone:client:CallStart', PhoneIntegration.onCallStart)
RegisterNetEvent('qb-phone:client:CallEnd', PhoneIntegration.onCallEnd)

-- ========================================
-- Banking Integration
-- ========================================

--[[
    QB-Banking Integration
    Shows banking notifications and balance updates
]]
local BankingIntegration = {
    onBalanceUpdate = function(newBalance)
        TriggerEvent('hud:updateMoney', {
            bank = newBalance
        })
    end,
    
    onTransaction = function(transactionData)
        local notificationType = transactionData.amount > 0 and 'bank_deposit' or 'bank_withdraw'
        
        TriggerEvent('hud:notification', {
            type = notificationType,
            amount = math.abs(transactionData.amount),
            account = transactionData.account,
            balance = transactionData.newBalance,
            duration = 4000
        })
    end,
    
    onATMUse = function(atmData)
        ComponentManager.updateComponent('ATMInterface', {
            active = true,
            location = atmData.location,
            balance = atmData.balance
        })
    end
}

-- Banking events
RegisterNetEvent('qb-banking:client:OnBalanceChange', BankingIntegration.onBalanceUpdate)
RegisterNetEvent('qb-banking:client:OnTransaction', BankingIntegration.onTransaction)

-- ========================================
-- Weather and Time Integration
-- ========================================

--[[
    Weather System Integration
    Updates HUD based on weather and time
]]
local WeatherIntegration = {
    currentWeather = 'CLEAR',
    currentTime = { hour = 12, minute = 0 },
    
    init = function()
        Citizen.CreateThread(WeatherIntegration.updateLoop)
    end,
    
    updateLoop = function()
        while true do
            local hour = GetClockHours()
            local minute = GetClockMinutes()
            local weather = GetPrevWeatherTypeHashName()
            
            WeatherIntegration.updateTime(hour, minute)
            WeatherIntegration.updateWeather(weather)
            
            Citizen.Wait(30000) -- Update every 30 seconds
        end
    end,
    
    updateTime = function(hour, minute)
        WeatherIntegration.currentTime = { hour = hour, minute = minute }
        
        TriggerEvent('hud:updateTime', {
            hour = hour,
            minute = minute,
            timeString = string.format('%02d:%02d', hour, minute),
            period = hour >= 12 and 'PM' or 'AM'
        })
        
        -- Dynamic theme based on time
        if hour >= 6 and hour < 18 then
            -- Day theme
            if ThemeManager.getTheme() == 'night' then
                ThemeManager.setTheme('day')
            end
        else
            -- Night theme
            if ThemeManager.getTheme() == 'day' then
                ThemeManager.setTheme('night')
            end
        end
    end,
    
    updateWeather = function(weather)
        if weather ~= WeatherIntegration.currentWeather then
            WeatherIntegration.currentWeather = weather
            
            TriggerEvent('hud:updateWeather', {
                type = weather,
                icon = WeatherIntegration.getWeatherIcon(weather),
                description = WeatherIntegration.getWeatherDescription(weather)
            })
        end
    end,
    
    getWeatherIcon = function(weather)
        local icons = {
            CLEAR = 'sun',
            RAIN = 'rain',
            CLOUDS = 'cloud',
            OVERCAST = 'cloud',
            THUNDER = 'thunderstorm',
            CLEARING = 'partly-cloudy',
            NEUTRAL = 'cloud',
            SNOW = 'snow',
            BLIZZARD = 'snow',
            SNOWLIGHT = 'snow',
            XMAS = 'snow',
            HALLOWEEN = 'cloud'
        }
        return icons[weather] or 'cloud'
    end,
    
    getWeatherDescription = function(weather)
        local descriptions = {
            CLEAR = 'Clear Sky',
            RAIN = 'Rainy',
            CLOUDS = 'Cloudy',
            OVERCAST = 'Overcast',
            THUNDER = 'Thunderstorm',
            CLEARING = 'Clearing',
            NEUTRAL = 'Neutral',
            SNOW = 'Snowy',
            BLIZZARD = 'Blizzard',
            SNOWLIGHT = 'Light Snow',
            XMAS = 'Christmas',
            HALLOWEEN = 'Spooky'
        }
        return descriptions[weather] or 'Unknown'
    end
}

WeatherIntegration.init()

-- ========================================
-- Radio Integration
-- ========================================

--[[
    PMA-Voice/SaltyChat Integration
    Shows voice/radio status
]]
local VoiceIntegration = {
    voiceMode = 1, -- 1 = whisper, 2 = normal, 3 = shout
    radioChannel = 0,
    radioActive = false,
    
    init = function()
        -- Register voice component
        ComponentManager.register('VoiceStatus', {
            name = 'VoiceStatus',
            element = '#voice-status',
            visible = true,
            show = function()
                SendNUIMessage({
                    action = 'showVoiceStatus'
                })
            end,
            hide = function()
                SendNUIMessage({
                    action = 'hideVoiceStatus'
                })
            end,
            update = function(self, data)
                SendNUIMessage({
                    action = 'updateVoiceStatus',
                    data = data
                })
            end
        })
    end,
    
    onVoiceModeChange = function(mode)
        VoiceIntegration.voiceMode = mode
        
        local modes = {
            [1] = { range = 3, label = 'Whisper', color = '#ffeb3b' },
            [2] = { range = 8, label = 'Normal', color = '#4caf50' },
            [3] = { range = 15, label = 'Shout', color = '#f44336' }
        }
        
        ComponentManager.updateComponent('VoiceStatus', {
            mode = mode,
            range = modes[mode].range,
            label = modes[mode].label,
            color = modes[mode].color
        })
    end,
    
    onRadioConnect = function(channel)
        VoiceIntegration.radioChannel = channel
        
        ComponentManager.updateComponent('VoiceStatus', {
            radioConnected = true,
            radioChannel = channel
        })
    end,
    
    onRadioDisconnect = function()
        VoiceIntegration.radioChannel = 0
        
        ComponentManager.updateComponent('VoiceStatus', {
            radioConnected = false,
            radioChannel = 0
        })
    end,
    
    onRadioTalk = function(talking)
        VoiceIntegration.radioActive = talking
        
        ComponentManager.updateComponent('VoiceStatus', {
            radioTalking = talking
        })
    end
}

-- PMA-Voice events
RegisterNetEvent('pma-voice:setTalkingMode', VoiceIntegration.onVoiceModeChange)
RegisterNetEvent('pma-voice:radioActive', VoiceIntegration.onRadioTalk)

-- SaltyChat events (alternative)
RegisterNetEvent('SaltyChat_OnTalkStateChanged', VoiceIntegration.onRadioTalk)

VoiceIntegration.init()

-- ========================================
-- Custom Resource Integration Template
-- ========================================

--[[
    Template for integrating custom resources
    Adapt this template for your specific needs
]]
local CustomResourceIntegration = {
    resourceName = 'your-custom-resource',
    enabled = false,
    
    init = function()
        -- Check if custom resource is running
        if GetResourceState(CustomResourceIntegration.resourceName) == 'started' then
            CustomResourceIntegration.enabled = true
            CustomResourceIntegration.setupIntegration()
        end
    end,
    
    setupIntegration = function()
        -- Register custom events
        RegisterNetEvent('custom-resource:dataUpdate', CustomResourceIntegration.onDataUpdate)
        RegisterNetEvent('custom-resource:statusChange', CustomResourceIntegration.onStatusChange)
        
        -- Register custom component
        ComponentManager.register('CustomComponent', {
            name = 'CustomComponent',
            element = '#custom-component',
            visible = true,
            show = function()
                SendNUIMessage({
                    action = 'showCustomComponent'
                })
            end,
            hide = function()
                SendNUIMessage({
                    action = 'hideCustomComponent'
                })
            end,
            update = function(self, data)
                SendNUIMessage({
                    action = 'updateCustomComponent',
                    data = data
                })
            end
        })
        
        -- Get initial data from custom resource
        local initialData = exports[CustomResourceIntegration.resourceName]:GetData()
        if initialData then
            CustomResourceIntegration.onDataUpdate(initialData)
        end
    end,
    
    onDataUpdate = function(data)
        ComponentManager.updateComponent('CustomComponent', data)
    end,
    
    onStatusChange = function(status)
        TriggerEvent('hud:notification', {
            type = 'custom',
            message = 'Status changed to: ' .. status,
            duration = 3000
        })
    end,
    
    cleanup = function()
        if CustomResourceIntegration.enabled then
            ComponentManager.unregister('CustomComponent')
            CustomResourceIntegration.enabled = false
        end
    end
}

-- Initialize custom resource integration
CustomResourceIntegration.init()

-- Handle resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == CustomResourceIntegration.resourceName then
        CustomResourceIntegration.cleanup()
    end
end)

-- ========================================
-- Settings and Preferences Integration
-- ========================================

--[[
    Player Settings Management
    Saves and loads player HUD preferences
]]
local SettingsIntegration = {
    init = function()
        -- Register settings menu command
        RegisterCommand('hudsettings', SettingsIntegration.openSettingsMenu, false)
        
        -- Register keybind for settings
        RegisterKeyMapping('hudsettings', 'Open HUD Settings', 'keyboard', 'F9')
        
        -- Auto-save settings periodically
        Citizen.CreateThread(SettingsIntegration.autoSaveLoop)
    end,
    
    openSettingsMenu = function()
        -- Open settings menu using qb-menu or custom NUI
        if exports['qb-menu'] then
            exports['qb-menu']:openMenu({
                {
                    header = 'HUD Settings',
                    isMenuHeader = true
                },
                {
                    header = 'Theme',
                    txt = 'Change HUD theme',
                    params = {
                        event = 'hud:settings:theme'
                    }
                },
                {
                    header = 'Performance',
                    txt = 'Adjust performance settings',
                    params = {
                        event = 'hud:settings:performance'
                    }
                },
                {
                    header = 'Components',
                    txt = 'Toggle HUD components',
                    params = {
                        event = 'hud:settings:components'
                    }
                }
            })
        else
            -- Fallback to custom NUI
            SendNUIMessage({
                action = 'openSettingsMenu',
                themes = ThemeManager.getAvailableThemes(),
                components = ComponentManager.getAll(),
                currentSettings = SettingsIntegration.getCurrentSettings()
            })
            SetNuiFocus(true, true)
        end
    end,
    
    getCurrentSettings = function()
        return {
            theme = ThemeManager.getTheme(),
            performanceMode = PerformanceManager.getMode(),
            animationsEnabled = AnimationManager.isEnabled(),
            components = ComponentManager.getVisibilityStates()
        }
    end,
    
    saveSettings = function(settings)
        local QBCore = exports['qb-core']:GetCoreObject()
        local PlayerData = QBCore.Functions.GetPlayerData()
        
        if PlayerData and PlayerData.citizenid then
            Database.savePlayerSettings(PlayerData.citizenid, settings)
        end
    end,
    
    autoSaveLoop = function()
        while true do
            Citizen.Wait(300000) -- Auto-save every 5 minutes
            
            local settings = SettingsIntegration.getCurrentSettings()
            SettingsIntegration.saveSettings(settings)
        end
    end
}

-- Settings event handlers
RegisterNetEvent('hud:settings:theme', function()
    -- Theme selection submenu
    local themes = ThemeManager.getAvailableThemes()
    local themeMenu = {
        {
            header = 'Select Theme',
            isMenuHeader = true
        }
    }
    
    for _, theme in ipairs(themes) do
        table.insert(themeMenu, {
            header = theme,
            txt = 'Apply ' .. theme .. ' theme',
            params = {
                event = 'hud:settings:applyTheme',
                args = { theme = theme }
            }
        })
    end
    
    exports['qb-menu']:openMenu(themeMenu)
end)

RegisterNetEvent('hud:settings:applyTheme', function(data)
    ThemeManager.setTheme(data.theme)
    TriggerEvent('hud:notification', {
        type = 'success',
        message = 'Theme changed to ' .. data.theme,
        duration = 3000
    })
end)

SettingsIntegration.init()

-- ========================================
-- Export Integration Functions
-- ========================================

--[[
    Export functions for other resources to use
]]
exports('updateHudStatus', function(data)
    TriggerEvent('hud:updateStatus', data)
end)

exports('showHudComponent', function(componentName)
    ComponentManager.show(componentName)
end)

exports('hideHudComponent', function(componentName)
    ComponentManager.hide(componentName)
end)

exports('setHudTheme', function(themeName)
    ThemeManager.setTheme(themeName)
end)

exports('addHudNotification', function(data)
    TriggerEvent('hud:notification', data)
end)

exports('isHudInitialized', function()
    return HudManager.isInitialized()
end)

-- ========================================
-- Debugging and Development Tools
-- ========================================

--[[
    Development tools for testing integrations
]]
local DevTools = {
    enabled = false,
    
    init = function()
        if Config.Debug and Config.Debug.enabled then
            DevTools.enabled = true
            DevTools.registerCommands()
        end
    end,
    
    registerCommands = function()
        RegisterCommand('hud_test_integration', function(source, args)
            local testType = args[1]
            
            if testType == 'qbcore' then
                DevTools.testQBCoreIntegration()
            elseif testType == 'vehicle' then
                DevTools.testVehicleIntegration()
            elseif testType == 'voice' then
                DevTools.testVoiceIntegration()
            else
                print('Available tests: qbcore, vehicle, voice')
            end
        end, false)
        
        RegisterCommand('hud_debug_data', function()
            DevTools.dumpIntegrationData()
        end, false)
    end,
    
    testQBCoreIntegration = function()
        print('[DEBUG] Testing QBCore integration...')
        
        -- Simulate player data update
        QBCoreIntegration.onPlayerDataUpdate({
            metadata = {
                health = 75,
                armor = 50,
                hunger = 80,
                thirst = 60,
                stress = 25
            }
        })
        
        print('[DEBUG] QBCore integration test completed')
    end,
    
    testVehicleIntegration = function()
        print('[DEBUG] Testing vehicle integration...')
        
        -- Simulate vehicle data
        TriggerEvent('hud:updateVehicle', {
            speed = 65,
            fuel = 78,
            engine = 85,
            gear = 3,
            rpm = 45
        })
        
        print('[DEBUG] Vehicle integration test completed')
    end,
    
    testVoiceIntegration = function()
        print('[DEBUG] Testing voice integration...')
        
        VoiceIntegration.onVoiceModeChange(2)
        VoiceIntegration.onRadioConnect(1)
        
        print('[DEBUG] Voice integration test completed')
    end,
    
    dumpIntegrationData = function()
        local data = {
            qbcore = {
                loaded = QBCoreIntegration ~= nil,
                playerDataExists = exports['qb-core']:GetCoreObject().Functions.GetPlayerData() ~= nil
            },
            vehicle = {
                currentVehicle = VehicleIntegration.currentVehicle,
                updateInterval = VehicleIntegration.updateInterval
            },
            voice = {
                mode = VoiceIntegration.voiceMode,
                radioChannel = VoiceIntegration.radioChannel
            },
            components = ComponentManager.getAll(),
            settings = SettingsIntegration.getCurrentSettings()
        }
        
        print('[DEBUG] Integration Data:')
        print(json.encode(data, { indent = true }))
    end
}

DevTools.init()

print('[INFO] Integration examples loaded successfully')
print('[INFO] Available integrations: QBCore, ESX, Vehicle, Police, Phone, Banking, Voice')
print('[INFO] Use exports to integrate with custom resources')