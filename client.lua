local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local config = Config
local speedMultiplier = config.UseMPH and 2.23694 or 3.6
local seatbeltOn = false
local cruiseOn = false
local showAltitude = false
local showSeatbelt = false
local nos = 0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local nitroActive = 0
local harness = 0
local hp = 100
local armed = 0
local parachute = -1
local oxygen = 100
local dev = false
local playerDead = false
local showMenu = false
local showCircleB = false
local showSquareB = false
local showGpsHud = false
local showSettingsMenu = false
local Menu = config.Menu
local CinematicHeight = 0.2
local w = 0
local radioActive = false

-- 🔧 GPS HUD SYSTEM VARIABLES
local gpsHudActive = false
local currentLocation = "DOWNTOWN LS"
local currentDirection = 0
local currentDistance = "0.0KM"
local lastLocationUpdate = 0
local streetNames = {}

-- 🔧 SETTINGS MENU VARIABLES
local menuAutoOpenBlocked = true
local firstLogin = true
local hudInitialized = false

-- Neon Theme Variables
local neonGlowActive = false
local criticalAlertActive = false
local currentTheme = 'cyberpunk'

DisplayRadar(false)

-- 🔧 GPS LOCATION SYSTEM
local LocationData = {
    ["Downtown"] = {coords = vector3(-267.0, -955.0, 31.0), name = "DOWNTOWN LS"},
    ["VinewoodHills"] = {coords = vector3(1400.0, 1100.0, 114.0), name = "VINEWOOD HILLS"},
    ["SandyShores"] = {coords = vector3(1900.0, 3700.0, 32.0), name = "SANDY SHORES"},
    ["PaletoBay"] = {coords = vector3(-100.0, 6400.0, 31.0), name = "PALETO BAY"},
    ["VespucciBeach"] = {coords = vector3(-1200.0, -1400.0, 4.0), name = "VESPUCCI BEACH"},
    ["Airport"] = {coords = vector3(-1000.0, -3000.0, 13.0), name = "LOS SANTOS INTL"},
    ["Mirror Park"] = {coords = vector3(1200.0, -600.0, 69.0), name = "MIRROR PARK"},
    ["Davis"] = {coords = vector3(400.0, -1800.0, 29.0), name = "DAVIS"},
    ["Strawberry"] = {coords = vector3(300.0, -1300.0, 29.0), name = "STRAWBERRY"},
    ["Legion Square"] = {coords = vector3(200.0, -900.0, 30.0), name = "LEGION SQUARE"}
}

local function GetCurrentLocationName()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestDistance = math.huge
    local closestLocation = "UNKNOWN AREA"
    
    for _, location in pairs(LocationData) do
        local distance = #(playerCoords - location.coords)
        if distance < closestDistance then
            closestDistance = distance
            closestLocation = location.name
        end
    end
    
    return closestLocation
end

local function GetDirectionToLocation(targetCoords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    
    local deltaX = targetCoords.x - playerCoords.x
    local deltaY = targetCoords.y - playerCoords.y
    
    local targetHeading = math.deg(math.atan2(deltaY, deltaX))
    local relativeHeading = (targetHeading - heading + 360) % 360
    
    -- Convert to direction arrow
    if relativeHeading >= 337.5 or relativeHeading < 22.5 then
        return "→"
    elseif relativeHeading >= 22.5 and relativeHeading < 67.5 then
        return "↗"
    elseif relativeHeading >= 67.5 and relativeHeading < 112.5 then
        return "↑"
    elseif relativeHeading >= 112.5 and relativeHeading < 157.5 then
        return "↖"
    elseif relativeHeading >= 157.5 and relativeHeading < 202.5 then
        return "←"
    elseif relativeHeading >= 202.5 and relativeHeading < 247.5 then
        return "↙"
    elseif relativeHeading >= 247.5 and relativeHeading < 292.5 then
        return "↓"
    else
        return "↘"
    end
end

local function GetDistanceToLocation(targetCoords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - targetCoords)
    
    if distance < 1000 then
        return string.format("%.0fM", distance)
    else
        return string.format("%.1fKM", distance / 1000)
    end
end

local function UpdateGpsLocation()
    if not gpsHudActive then return end
    
    local currentTime = GetGameTimer()
    if currentTime - lastLocationUpdate < 1000 then return end
    
    lastLocationUpdate = currentTime
    currentLocation = GetCurrentLocationName()
    
    -- Get street names
    local playerCoords = GetEntityCoords(PlayerPedId())
    local street1, street2 = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    streetNames = {
        GetStreetNameFromHashKey(street1),
        GetStreetNameFromHashKey(street2)
    }
    
    -- For demo: simulate navigation to random location
    local targetLocation = LocationData["VinewoodHills"]
    currentDirection = GetDirectionToLocation(targetLocation.coords)
    currentDistance = GetDistanceToLocation(targetLocation.coords)
    
    -- Update GPS HUD
    SendNUIMessage({
        action = 'updateGpsLocation',
        location = currentLocation,
        direction = currentDirection,
        distance = currentDistance,
        street1 = streetNames[1] or "",
        street2 = streetNames[2] or ""
    })
end

local function CinematicShow(bool)
    SetBigmapActive(true, false)
    Wait(0)
    SetBigmapActive(false, false)
    if bool then
        for i = CinematicHeight, 0, -1.0 do
            Wait(10)
            w = i
        end
    else
        for i = 0, CinematicHeight, 1.0 do
            Wait(10)
            w = i
        end
    end
end

-- 🔧 ENHANCED LOAD SETTINGS - NO AUTO MENU
local function loadSettings(settings)
    for k, v in pairs(settings) do
        if k == 'isToggleMapShapeChecked' then
            Menu.isToggleMapShapeChecked = v
            SendNUIMessage({ test = true, event = k, toggle = v })
        elseif k == 'isCinematicModeChecked' then
            Menu.isCinematicModeChecked = v
            CinematicShow(v)
            SendNUIMessage({ test = true, event = k, toggle = v })
        elseif k == 'isChangeFPSChecked' then
            Menu[k] = v
            local val = v and 'Optimized' or 'Synced'
            SendNUIMessage({ test = true, event = k, toggle = val })
        else
            Menu[k] = v
            SendNUIMessage({ test = true, event = k, toggle = v })
        end
    end
    
    Wait(1000)
    TriggerEvent('hud:client:LoadMap')
end

local function saveSettings()
    SetResourceKvp('hudSettings', json.encode(Menu))
end

local function hasHarness(items)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local _harness = false
    if items then
        for _, v in pairs(items) do
            if v.name == 'harness' then
                _harness = true
            end
        end
    end

    harness = _harness
end

-- Neon Theme Functions
local function TriggerNeonGlow(element, color, intensity)
    intensity = intensity or 1.0
    SendNUIMessage({
        action = 'triggerGlow',
        element = element,
        color = color,
        intensity = intensity
    })
end

local function TriggerCriticalAlert(statType, value)
    if value <= config.Theme.CriticalThreshold and not criticalAlertActive then
        criticalAlertActive = true
        TriggerNeonGlow(statType, '#ff4444', 1.5)
        
        if Menu.isResetSoundsChecked then
            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'critical_alert', 0.3)
        end
        
        SendNUIMessage({
            action = 'criticalAlert',
            statType = statType,
            value = value
        })
        
        SetTimeout(3000, function()
            criticalAlertActive = false
        end)
    end
end

local function UpdateNeonTheme(theme)
    currentTheme = theme
    SendNUIMessage({
        action = 'updateTheme',
        theme = theme
    })
end

-- 🔧 PLAYER LOADED EVENT - NO AUTO MENU
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then 
        loadSettings(json.decode(hudSettings)) 
    end
    
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(3000)
    SetEntityHealth(PlayerPedId(), 200)
    
    UpdateNeonTheme(config.Theme.DefaultTheme or 'cyberpunk')
    
    hudInitialized = true
    firstLogin = false
    
    print('^2[Enhanced HUD]^7 Player loaded - HUD initialized silently')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    showMenu = false
    showSettingsMenu = false
    gpsHudActive = false
    hudInitialized = false
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- 🔧 RESOURCE START - NO AUTO MENU
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then 
        loadSettings(json.decode(hudSettings)) 
    end
    
    print('^2[Enhanced HUD]^7 Resource started - Settings loaded silently')
end)

AddEventHandler('pma-voice:radioActive', function(data)
    radioActive = data
end)

-- 🔧 GPS HUD COMMANDS & EVENTS
RegisterCommand('gps', function()
    if not hudInitialized then
        QBCore.Functions.Notify('HUD not yet initialized', 'error')
        return
    end
    
    gpsHudActive = not gpsHudActive
    showGpsHud = gpsHudActive
    
    SendNUIMessage({
        action = 'toggleGpsHud',
        show = gpsHudActive
    })
    
    if gpsHudActive then
        QBCore.Functions.Notify(Lang:t('notify.gps_activated'), 'success')
        TriggerNeonGlow('gps', '#00ffff', 1.0)
        UpdateGpsLocation()
    else
        QBCore.Functions.Notify(Lang:t('notify.gps_deactivated'), 'error')
    end
end)

RegisterKeyMapping('gps', 'Toggle GPS HUD', 'keyboard', 'G')

-- 🔧 HUD SETTINGS MENU COMMAND
RegisterCommand('hudsettings', function()
    if not hudInitialized then
        QBCore.Functions.Notify('HUD not yet initialized', 'error')
        return
    end
    
    if showSettingsMenu then 
        QBCore.Functions.Notify('Settings menu is already open', 'warning')
        return 
    end
    
    if showMenu then
        QBCore.Functions.Notify('Close main menu first', 'warning')
        return
    end
    
    TriggerEvent('hud:client:playOpenMenuSounds')
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openSettings' })
    showSettingsMenu = true
    
    TriggerNeonGlow('settings', '#a020f0', 1.2)
    
    print('^3[HUD-SETTINGS]^7 Settings menu opened')
end)

RegisterKeyMapping('hudsettings', 'Open HUD Settings', 'keyboard', 'F7')

-- 🔧 MAIN MENU COMMAND - MANUAL ONLY
RegisterCommand('menu', function()
    if not hudInitialized then
        QBCore.Functions.Notify('HUD not yet initialized', 'error')
        return
    end
    
    if showMenu then 
        QBCore.Functions.Notify('Menu is already open', 'warning')
        return 
    end
    
    if showSettingsMenu then
        QBCore.Functions.Notify('Close settings menu first', 'warning')
        return
    end
    
    TriggerEvent('hud:client:playOpenMenuSounds')
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
    showMenu = true
    
    TriggerNeonGlow('menu', '#a020f0', 1.2)
    
    print('^3[HUD-MENU]^7 Main menu opened manually')
end)

RegisterKeyMapping('menu', 'Open HUD Menu', 'keyboard', config.OpenMenu)

-- 🔧 NUI CALLBACKS
RegisterNUICallback('closeMenu', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:playCloseMenuSounds')
    showMenu = false
    SetNuiFocus(false, false)
    cb('ok')
    print('^3[HUD-MENU]^7 Main menu closed')
end)

RegisterNUICallback('closeSettings', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:playCloseMenuSounds')
    showSettingsMenu = false
    SetNuiFocus(false, false)
    cb('ok')
    print('^3[HUD-SETTINGS]^7 Settings menu closed')
end)

RegisterNUICallback('toggleGpsHud', function(data, cb)
    gpsHudActive = data.show or false
    showGpsHud = gpsHudActive
    
    if gpsHudActive then
        UpdateGpsLocation()
        TriggerNeonGlow('gps', '#00ffff', 1.0)
    end
    
    cb('ok')
end)

RegisterNUICallback('updateGpsPosition', function(data, cb)
    local position = data.position or 'top-right'
    SendNUIMessage({
        action = 'setGpsPosition',
        position = position
    })
    cb('ok')
end)

RegisterNUICallback('setGpsTheme', function(data, cb)
    local theme = data.theme or 'cyberpunk'
    SendNUIMessage({
        action = 'setGpsTheme',
        theme = theme
    })
    cb('ok')
end)

-- Neon Theme Events
RegisterNetEvent('hud:client:TriggerGlow', function(element, color, intensity)
    TriggerNeonGlow(element, color, intensity)
end)

RegisterNetEvent('hud:client:CriticalAlert', function(statType, value)
    TriggerCriticalAlert(statType, value)
end)

RegisterNetEvent('hud:client:ChangeTheme', function(theme)
    UpdateNeonTheme(theme)
end)

RegisterNetEvent('hud:client:ValueChanged', function(statType, oldValue, newValue)
    SendNUIMessage({
        action = 'valueChanged',
        statType = statType,
        oldValue = oldValue,
        newValue = newValue,
        animationSpeed = config.Theme.AnimationSpeed or 1.0
    })
end)

RegisterNetEvent('hud:client:ToggleGpsHud', function()
    ExecuteCommand('gps')
end)

-- 🔧 HUD RESTART FUNCTION
local function restartHud()
    TriggerEvent('hud:client:playResetHudSounds')
    TriggerNeonGlow('hud', '#00ffff', 2.0)
    QBCore.Functions.Notify(Lang:t('notify.hud_restart'), 'error')
    
    if IsPedInAnyVehicle(PlayerPedId()) then
        Wait(2600)
        SendNUIMessage({ action = 'car', show = false })
        SendNUIMessage({ action = 'car', show = true })
    end
    Wait(2600)
    SendNUIMessage({ action = 'hudtick', show = false })
    SendNUIMessage({ action = 'hudtick', show = true })
    
    -- Reset GPS HUD
    if gpsHudActive then
        SendNUIMessage({ action = 'toggleGpsHud', show = false })
        Wait(500)
        SendNUIMessage({ action = 'toggleGpsHud', show = true })
        UpdateGpsLocation()
    end
    
    Wait(2600)
    QBCore.Functions.Notify(Lang:t('notify.hud_start'), 'success')
end

RegisterNUICallback('restartHud', function(_, cb)
    Wait(50)
    restartHud()
    cb('ok')
end)

RegisterCommand('resethud', function()
    Wait(50)
    restartHud()
end)

RegisterNUICallback('resetStorage', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:resetStorage')
    cb('ok')
end)

RegisterNetEvent('hud:client:resetStorage', function()
    Wait(50)
    if Menu.isResetSoundsChecked then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'airwrench', 0.1)
    end
    QBCore.Functions.TriggerCallback('hud:server:getMenu', function(menu)
        loadSettings(menu)
        SetResourceKvp('hudSettings', json.encode(menu))
    end)
end)

-- Theme Commands
RegisterCommand('hudtheme', function(source, args)
    if args[1] then
        local theme = args[1]:lower()
        if theme == 'cyberpunk' or theme == 'synthwave' or theme == 'matrix' then
            UpdateNeonTheme(theme)
            QBCore.Functions.Notify('HUD Theme changed to: '..theme, 'success')
        else
            QBCore.Functions.Notify('Available themes: cyberpunk, synthwave, matrix', 'error')
        end
    else
        QBCore.Functions.Notify('Usage: /hudtheme [cyberpunk/synthwave/matrix]', 'primary')
    end
end)

-- 🔧 ALL EXISTING MENU CALLBACKS (keeping all original functionality)
RegisterNUICallback('openMenuSounds', function(_, cb)
    Wait(50)
    Menu.isOpenMenuSoundsChecked = not Menu.isOpenMenuSoundsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('checkbox', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:playOpenMenuSounds', function()
    Wait(50)
    if not Menu.isOpenMenuSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'monkeyopening', 0.5)
end)

RegisterNetEvent('hud:client:playCloseMenuSounds', function()
    Wait(50)
    if not Menu.isOpenMenuSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'catclosing', 0.05)
end)

RegisterNUICallback('resetHudSounds', function(_, cb)
    Wait(50)
    Menu.isResetSoundsChecked = not Menu.isResetSoundsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('checkbox', '#ff9800', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:playResetHudSounds', function()
    Wait(50)
    if not Menu.isResetSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'airwrench', 0.1)
end)

RegisterNUICallback('checklistSounds', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:checklistSounds')
    cb('ok')
end)

RegisterNetEvent('hud:client:checklistSounds', function()
    Wait(50)
    Menu.isListSoundsChecked = not Menu.isListSoundsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('checkbox', '#a020f0', 0.8)
    saveSettings()
end)

RegisterNetEvent('hud:client:playHudChecklistSound', function()
    Wait(50)
    if not Menu.isListSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'shiftyclick', 0.5)
end)

-- All existing callbacks remain the same...
RegisterNUICallback('showOutMap', function(_, cb)
    Wait(50)
    Menu.isOutMapChecked = not Menu.isOutMapChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('toggle', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showOutCompass', function(_, cb)
    Wait(50)
    Menu.isOutCompassChecked = not Menu.isOutCompassChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('toggle', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showFollowCompass', function(_, cb)
    Wait(50)
    Menu.isCompassFollowChecked = not Menu.isCompassFollowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('toggle', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showMapNotif', function(_, cb)
    Wait(50)
    Menu.isMapNotifChecked = not Menu.isMapNotifChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('toggle', '#ff9800', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showFuelAlert', function(_, cb)
    Wait(50)
    Menu.isLowFuelChecked = not Menu.isLowFuelChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('toggle', '#ff4444', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showCinematicNotif', function(_, cb)
    Wait(50)
    Menu.isCinematicNotifChecked = not Menu.isCinematicNotifChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('toggle', '#a020f0', 0.8)
    saveSettings()
    cb('ok')
end)

-- Status callbacks with critical monitoring
RegisterNUICallback('dynamicHealth', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:ToggleHealth')
    cb('ok')
end)

RegisterNetEvent('hud:client:ToggleHealth', function()
    Wait(50)
    Menu.isDynamicHealthChecked = not Menu.isDynamicHealthChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('health', '#ff4444', 0.8)
    saveSettings()
end)

RegisterNUICallback('dynamicArmor', function(_, cb)
    Wait(50)
    Menu.isDynamicArmorChecked = not Menu.isDynamicArmorChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('armor', '#00bcd4', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicHunger', function(_, cb)
    Wait(50)
    Menu.isDynamicHungerChecked = not Menu.isDynamicHungerChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('hunger', '#ffb74d', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicThirst', function(_, cb)
    Wait(50)
    Menu.isDynamicThirstChecked = not Menu.isDynamicThirstChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('thirst', '#29b6f6', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicStress', function(_, cb)
    Wait(50)
    Menu.isDynamicStressChecked = not Menu.isDynamicStressChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('stress', '#a020f0', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicOxygen', function(_, cb)
    Wait(50)
    Menu.isDynamicOxygenChecked = not Menu.isDynamicOxygenChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('oxygen', '#66bb6a', 0.8)
    saveSettings()
    cb('ok')
end)

-- Vehicle callbacks remain the same structure
RegisterNUICallback('changeFPS', function(_, cb)
    Wait(50)
    Menu.isChangeFPSChecked = not Menu.isChangeFPSChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('fps', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('HideMap', function(_, cb)
    Wait(50)
    Menu.isHideMapChecked = not Menu.isHideMapChecked
    DisplayRadar(not Menu.isHideMapChecked)
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('map', '#a020f0', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:LoadMap', function()
    Wait(50)
    local defaultAspectRatio = 1920 / 1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end
    if Menu.isToggleMapShapeChecked == 'square' then
        RequestStreamedTextureDict('squaremap', false)
        if not HasStreamedTextureDictLoaded('squaremap') then
            Wait(150)
        end
        if Menu.isMapNotifChecked then
            QBCore.Functions.Notify(Lang:t('notify.load_square_map'))
        end
        SetMinimapClipType(0)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
        SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetBigmapActive(true, false)
        SetMinimapClipType(0)
        Wait(50)
        SetBigmapActive(false, false)
        if Menu.isToggleMapBordersChecked then
            showCircleB = false
            showSquareB = true
        end
        Wait(1200)
        if Menu.isMapNotifChecked then
            QBCore.Functions.Notify(Lang:t('notify.loaded_square_map'))
        end
    elseif Menu.isToggleMapShapeChecked == 'circle' then
        RequestStreamedTextureDict('circlemap', false)
        if not HasStreamedTextureDictLoaded('circlemap') then
            Wait(150)
        end
        if Menu.isMapNotifChecked then
            QBCore.Functions.Notify(Lang:t('notify.load_circle_map'))
        end
        SetMinimapClipType(1)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'circlemap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'circlemap', 'radarmasksm')
        SetMinimapComponentPosition('minimap', 'L', 'B', -0.0100 + minimapOffset, -0.030, 0.180, 0.258)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.200 + minimapOffset, 0.0, 0.065, 0.20)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.015, 0.252, 0.338)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetMinimapClipType(1)
        SetBigmapActive(true, false)
        Wait(50)
        SetBigmapActive(false, false)
        if Menu.isToggleMapBordersChecked then
            showSquareB = false
            showCircleB = true
        end
        Wait(1200)
        if Menu.isMapNotifChecked then
            QBCore.Functions.Notify(Lang:t('notify.loaded_circle_map'))
        end
    end
end)

-- Rest of callbacks (keeping all existing functionality)...
RegisterNUICallback('ToggleMapShape', function(_, cb)
    Wait(50)
    if not Menu.isHideMapChecked then
        Menu.isToggleMapShapeChecked = Menu.isToggleMapShapeChecked == 'circle' and 'square' or 'circle'
        Wait(50)
        TriggerEvent('hud:client:LoadMap')
    end
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('mapshape', '#a020f0', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('ToggleMapBorders', function(_, cb)
    Wait(50)
    Menu.isToggleMapBordersChecked = not Menu.isToggleMapBordersChecked
    if Menu.isToggleMapBordersChecked then
        if Menu.isToggleMapShapeChecked == 'square' then
            showSquareB = true
        else
            showCircleB = true
        end
    else
        showSquareB = false
        showCircleB = false
    end
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('mapborder', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicEngine', function(_, cb)
    Wait(50)
    Menu.isDynamicEngineChecked = not Menu.isDynamicEngineChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('engine', '#ff9800', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicNitro', function(_, cb)
    Wait(50)
    Menu.isDynamicNitroChecked = not Menu.isDynamicNitroChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('nitro', '#a020f0', 0.8)
    saveSettings()
    cb('ok')
end)

-- Compass callbacks
RegisterNUICallback('showCompassBase', function(_, cb)
    Wait(50)
    Menu.isCompassShowChecked = not Menu.isCompassShowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('compass', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showStreetsNames', function(_, cb)
    Wait(50)
    Menu.isShowStreetsChecked = not Menu.isShowStreetsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('streets', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showPointerIndex', function(_, cb)
    Wait(50)
    Menu.isPointerShowChecked = not Menu.isPointerShowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('pointer', '#ff9800', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showDegreesNum', function(_, cb)
    Wait(50)
    Menu.isDegreesShowChecked = not Menu.isDegreesShowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('degrees', '#ff9800', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('changeCompassFPS', function(_, cb)
    Wait(50)
    Menu.isChangeCompassFPSChecked = not Menu.isChangeCompassFPSChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('compassfps', '#00ffff', 0.8)
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('cinematicMode', function(_, cb)
    Wait(50)
    if Menu.isCinematicModeChecked then
        CinematicShow(false)
        Menu.isCinematicModeChecked = false
        if Menu.isCinematicNotifChecked then
            QBCore.Functions.Notify(Lang:t('notify.cinematic_off'), 'error')
        end
        DisplayRadar(1)
    else
        CinematicShow(true)
        Menu.isCinematicModeChecked = true
        if Menu.isCinematicNotifChecked then
            QBCore.Functions.Notify(Lang:t('notify.cinematic_on'))
        end
    end
    TriggerEvent('hud:client:playHudChecklistSound')
    TriggerNeonGlow('cinematic', '#a020f0', 1.2)
    saveSettings()
    cb('ok')
end)

-- All existing events remain the same
RegisterNetEvent('hud:client:ToggleAirHud', function()
    showAltitude = not showAltitude
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    local oldHunger = hunger
    local oldThirst = thirst
    hunger = newHunger
    thirst = newThirst
    
    -- Update GPS HUD with current stats
    if gpsHudActive then
        SendNUIMessage({
            action = 'updateGpsStats',
            hunger = newHunger,
            thirst = newThirst
        })
    end
    
    -- Trigger critical alerts for low values
    if newHunger <= config.Theme.CriticalThreshold then
        TriggerCriticalAlert('hunger', newHunger)
    end
    if newThirst <= config.Theme.CriticalThreshold then
        TriggerCriticalAlert('thirst', newThirst)
    end
    
    -- Trigger value change animations
    TriggerEvent('hud:client:ValueChanged', 'hunger', oldHunger, newHunger)
    TriggerEvent('hud:client:ValueChanged', 'thirst', oldThirst, newThirst)
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    local oldStress = stress
    stress = newStress
    
    -- Update GPS HUD
    if gpsHudActive then
        SendNUIMessage({
            action = 'updateGpsStats',
            stress = newStress
        })
    end
    
    -- Trigger stress effects at high levels
    if newStress >= 80 and not neonGlowActive then
        neonGlowActive = true
        TriggerNeonGlow('stress', '#ff4444', 2.0)
        SetTimeout(5000, function()
            neonGlowActive = false
        end)
    end
    
    TriggerEvent('hud:client:ValueChanged', 'stress', oldStress, newStress)
end)

RegisterNetEvent('hud:client:ToggleShowSeatbelt', function()
    showSeatbelt = not showSeatbelt
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    seatbeltOn = not seatbeltOn
    if seatbeltOn then
        TriggerNeonGlow('seatbelt', '#66bb6a', 1.0)
    else
        TriggerNeonGlow('seatbelt', '#ff4444', 1.0)
    end
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function()
    cruiseOn = not cruiseOn
    if cruiseOn then
        TriggerNeonGlow('cruise', '#00ffff', 1.0)
    end
end)

RegisterNetEvent('hud:client:UpdateNitrous', function(nitroLevel, bool)
    nos = nitroLevel
    nitroActive = bool
    if bool then
        TriggerNeonGlow('nitro', '#a020f0', 1.5)
    end
end)

RegisterNetEvent('hud:client:UpdateHarness', function(harnessHp)
    hp = harnessHp
end)

RegisterNetEvent('qb-admin:client:ToggleDevmode', function()
    dev = not dev
    if dev then
        TriggerNeonGlow('dev', '#00ffff', 1.2)
        QBCore.Functions.Notify('Developer Mode: ACTIVATED', 'success')
    else
        QBCore.Functions.Notify('Developer Mode: DEACTIVATED', 'error')
    end
end)

-- 🔧 GPS LOCATION UPDATE THREAD
CreateThread(function()
    while true do
        if gpsHudActive and hudInitialized then
            UpdateGpsLocation()
        end
        Wait(2000) -- Update every 2 seconds
    end
end)

-- Enhanced HUD update functions with critical monitoring and GPS integration
local prevPlayerStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updatePlayerHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevPlayerStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevPlayerStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'hudtick',
            show = data[1],
            dynamicHealth = data[2],
            dynamicArmor = data[3],
            dynamicHunger = data[4],
            dynamicThirst = data[5],
            dynamicStress = data[6],
            dynamicOxygen = data[7],
            dynamicEngine = data[8],
            dynamicNitro = data[9],
            health = data[10],
            playerDead = data[11],
            armor = data[12],
            thirst = data[13],
            hunger = data[14],
            stress = data[15],
            voice = data[16],
            radio = data[17],
            talking = data[18],
            armed = data[19],
            oxygen = data[20],
            parachute = data[21],
            nos = data[22],
            cruise = data[23],
            nitroActive = data[24],
            harness = data[25],
            hp = data[26],
            speed = data[27],
            engine = data[28],
            cinematic = data[29],
            dev = data[30],
            radioActive = data[31],
            neonIntensity = config.Theme.NeonIntensity or 0.8,
            currentTheme = currentTheme
        })
        
        -- Update GPS HUD with current stats
        if gpsHudActive then
            SendNUIMessage({
                action = 'updateGpsStats',
                health = data[10],
                armor = data[12],
                hunger = data[14],
                thirst = data[13],
                stress = data[15],
                stamina = data[20]
            })
        end
    end
end

local prevVehicleStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updateVehicleHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevVehicleStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevVehicleStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'car',
            show = data[1],
            isPaused = data[2],
            seatbelt = data[3],
            speed = data[4],
            fuel = data[5],
            altitude = data[6],
            showAltitude = data[7],
            showSeatbelt = data[8],
            showSquareB = data[9],
            showCircleB = data[10],
            currentTheme = currentTheme
        })
    end
end

local lastFuelUpdate = 0
local lastFuelCheck = {}

local function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    end
    return lastFuelCheck
end

-- Main HUD Update loop with enhanced neon effects
CreateThread(function()
    local wasInVehicle = false
    while true do
        if Menu.isChangeFPSChecked then
            Wait(500)
        else
            Wait(50)
        end
        if LocalPlayer.state.isLoggedIn then
            local show = true
            local player = PlayerPedId()
            local playerId = PlayerId()
            local weapon = GetSelectedPedWeapon(player)
            
            -- Player hud with critical monitoring
            if not config.WhitelistedWeaponArmed[weapon] then
                if weapon ~= `WEAPON_UNARMED` then
                    armed = true
                else
                    armed = false
                end
            end
            playerDead = IsEntityDead(player) or PlayerData.metadata['inlaststand'] or PlayerData.metadata['isdead'] or false
            parachute = GetPedParachuteState(player)
            
            -- Stamina with critical check
            if not IsEntityInWater(player) then
                oxygen = 100 - GetPlayerSprintStaminaRemaining(playerId)
                if oxygen <= config.Theme.CriticalThreshold then
                    TriggerCriticalAlert('stamina', oxygen)
                end
            end
            
            -- Oxygen
            if IsEntityInWater(player) then
                oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
                if oxygen <= config.Theme.CriticalThreshold then
                    TriggerCriticalAlert('oxygen', oxygen)
                end
            end
            
            local talking = NetworkIsPlayerTalking(playerId)
            local voice = 0
            if LocalPlayer.state['proximity'] then
                voice = LocalPlayer.state['proximity'].distance
            end
            if IsPauseMenuActive() then
                show = false
            end
            
            local vehicle = GetVehiclePedIsIn(player)
            if not (IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle)) then
                updatePlayerHud({
                    show,
                    Menu.isDynamicHealthChecked,
                    Menu.isDynamicArmorChecked,
                    Menu.isDynamicHungerChecked,
                    Menu.isDynamicThirstChecked,
                    Menu.isDynamicStressChecked,
                    Menu.isDynamicOxygenChecked,
                    Menu.isDynamicEngineChecked,
                    Menu.isDynamicNitroChecked,
                    GetEntityHealth(player) - 100,
                    playerDead,
                    GetPedArmour(player),
                    thirst,
                    hunger,
                    stress,
                    voice,
                    LocalPlayer.state['radioChannel'],
                    talking,
                    armed,
                    oxygen,
                    parachute,
                    -1,
                    cruiseOn,
                    nitroActive,
                    harness,
                    hp,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    -1,
                    Menu.isCinematicModeChecked,
                    dev,
                    radioActive,
                })
            end
            
            -- Vehicle hud with enhanced effects
            if IsPedInAnyHeli(player) or IsPedInAnyPlane(player) then
                showAltitude = true
                showSeatbelt = false
            end
            if IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) then
                if not wasInVehicle then
                    DisplayRadar(true)
                    TriggerNeonGlow('vehicle', '#00ffff', 1.0)
                end
                wasInVehicle = true
                local engineHealth = GetVehicleEngineHealth(vehicle)
                if engineHealth ~= engineHealth then
                    engineHealth = 0
                end
                
                -- Critical engine health check
                if engineHealth <= config.Theme.CriticalThreshold then
                    TriggerCriticalAlert('engine', engineHealth)
                end
                
                updatePlayerHud({
                    show,
                    Menu.isDynamicHealthChecked,
                    Menu.isDynamicArmorChecked,
                    Menu.isDynamicHungerChecked,
                    Menu.isDynamicThirstChecked,
                    Menu.isDynamicStressChecked,
                    Menu.isDynamicOxygenChecked,
                    Menu.isDynamicEngineChecked,
                    Menu.isDynamicNitroChecked,
                    GetEntityHealth(player) - 100,
                    playerDead,
                    GetPedArmour(player),
                    thirst,
                    hunger,
                    stress,
                    voice,
                    LocalPlayer.state['radioChannel'],
                    talking,
                    armed,
                    oxygen,
                    GetPedParachuteState(player),
                    nos,
                    cruiseOn,
                    nitroActive,
                    harness,
                    hp,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    (engineHealth / 10),
                    Menu.isCinematicModeChecked,
                    dev,
                    radioActive,
                })
                
                local fuelLevel = getFuelLevel(vehicle)
                updateVehicleHud({
                    show,
                    IsPauseMenuActive(),
                    seatbeltOn,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    fuelLevel,
                    math.ceil(GetEntityCoords(player).z * 0.5),
                    showAltitude,
                    showSeatbelt,
                    showSquareB,
                    showCircleB,
                })
                
                -- Critical fuel check
                if fuelLevel <= config.Theme.CriticalThreshold then
                    TriggerCriticalAlert('fuel', fuelLevel)
                end
                
                showAltitude = false
                showSeatbelt = true
            else
                if wasInVehicle then
                    wasInVehicle = false
                    SendNUIMessage({
                        action = 'car',
                        show = false,
                        seatbelt = false,
                        cruise = false,
                    })
                    seatbeltOn = false
                    cruiseOn = false
                    harness = false
                end
                DisplayRadar(Menu.isOutMapChecked)
            end
        else
            SendNUIMessage({
                action = 'hudtick',
                show = false
            })
        end
    end
end)

-- Enhanced Low fuel alert with neon effects
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) and not IsThisModelABicycle(GetEntityModel(GetVehiclePedIsIn(ped, false))) then
                local fuelLevel = exports['LegacyFuel']:GetFuel(GetVehiclePedIsIn(ped, false))
                if fuelLevel <= 20 then
                    if Menu.isLowFuelChecked then
                        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'pager', 0.10)
                        TriggerNeonGlow('fuel', '#ff4444', 2.0)
                        QBCore.Functions.Notify(Lang:t('notify.low_fuel'), 'error')
                        Wait(60000)
                    end
                end
            end
        end
        Wait(10000)
    end
end)

-- Money HUD with neon effects
local Round = math.floor

RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        TriggerNeonGlow('cash', '#66bb6a', 1.0)
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = Round(amount)
        })
    else
        TriggerNeonGlow('bank', '#00ffff', 1.0)
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = Round(amount)
        })
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    cashAmount = PlayerData.money['cash']
    bankAmount = PlayerData.money['bank']
    
    local glowColor = isMinus and '#ff4444' or '#66bb6a'
    TriggerNeonGlow('money', glowColor, 1.2)
    
    SendNUIMessage({
        action = 'updatemoney',
        cash = Round(cashAmount),
        bank = Round(bankAmount),
        amount = Round(amount),
        minus = isMinus,
        type = type,
        neonIntensity = config.Theme.NeonIntensity or 0.8
    })
end)

-- Harness Check remains the same
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            hasHarness(PlayerData.items)
        end
    end
end)

-- Enhanced Stress System with neon effects
if not config.DisableStress then
    CreateThread(function()
        while true do
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                if IsPedInAnyVehicle(ped, false) then
                    local veh = GetVehiclePedIsIn(ped, false)
                    local vehClass = GetVehicleClass(veh)
                    local speed = GetEntitySpeed(veh) * speedMultiplier
                    local vehHash = GetEntityModel(veh)
                    if config.VehClassStress[tostring(vehClass)] and not config.WhitelistedVehicles[vehHash] then
                        local stressSpeed
                        if vehClass == 8 then
                            stressSpeed = config.MinimumSpeed
                        else
                            stressSpeed = seatbeltOn and config.MinimumSpeed or config.MinimumSpeedUnbuckled
                        end
                        if speed >= stressSpeed then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                end
            end
            Wait(10000)
        end
    end)

    CreateThread(function()
        while true do
            if LocalPlayer.state.isLoggedIn then
                local ped = PlayerPedId()
                local weapon = GetSelectedPedWeapon(ped)
                if weapon ~= `WEAPON_UNARMED` then
                    if IsPedShooting(ped) and not config.WhitelistedWeaponStress[weapon] then
                        if math.random() < config.StressChance then
                            TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        end
                    end
                else
                    Wait(1000)
                end
            end
            Wait(0)
        end
    end)
end

-- Enhanced Stress Screen Effects with neon elements
local function GetBlurIntensity(stresslevel)
    for _, v in pairs(config.Intensity['blur']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local effectInterval = GetEffectInterval(stress)
        if stress >= 100 then
            TriggerNeonGlow('stress', '#ff4444', 3.0)
            local BlurIntensity = GetBlurIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = FallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(1000)
            for _ = 1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= config.MinimumStress then
            local BlurIntensity = GetBlurIntensity(stress)
            TriggerNeonGlow('stress', '#a020f0', 1.5)
            TriggerScreenblurFadeIn(1000.0)
            Wait(BlurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)

-- Minimap update remains the same
CreateThread(function()
    while true do
        SetBigmapActive(false, false)
        SetRadarZoom(1000)
        Wait(500)
    end
end)

local function BlackBars()
    DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
end

CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do
            Wait(1)
        end
    end
    while true do
        if w > 0 then
            BlackBars()
            DisplayRadar(0)
            SendNUIMessage({
                action = 'hudtick',
                show = false,
            })
            SendNUIMessage({
                action = 'car',
                show = false,
            })
        end
        Wait(0)
    end
end)

-- Enhanced Compass with neon elements
local prevBaseplateStats = { nil, nil, nil, nil, nil, nil, nil }

local function updateBaseplateHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevBaseplateStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevBaseplateStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'baseplate',
            show = data[1],
            street1 = data[2],
            street2 = data[3],
            showCompass = data[4],
            showStreets = data[5],
            showPointer = data[6],
            showDegrees = data[7],
            currentTheme = currentTheme
        })
    end
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

local function getCrossroads(player)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(player)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return lastCrossroadCheck
end

-- Enhanced Compass Update loop
CreateThread(function()
    local lastHeading = 1
    local heading
    while true do
        if Menu.isChangeCompassFPSChecked then
            Wait(50)
        else
            Wait(0)
        end
        local show = true
        local player = PlayerPedId()
        local camRot = GetGameplayCamRot(0)
        if Menu.isCompassFollowChecked then
            heading = tostring(QBCore.Shared.Round(360.0 - ((camRot.z + 360.0) % 360.0)))
        else
            heading = tostring(QBCore.Shared.Round(360.0 - GetEntityHeading(player)))
        end
        if heading == '360' then heading = '0' end
        if heading ~= lastHeading then
            if IsPedInAnyVehicle(player) then
                local crossroads = getCrossroads(player)
                SendNUIMessage({
                    action = 'update',
                    value = heading,
                    neonIntensity = config.Theme.NeonIntensity or 0.8
                })
                updateBaseplateHud({
                    show,
                    crossroads[1],
                    crossroads[2],
                    Menu.isCompassShowChecked,
                    Menu.isShowStreetsChecked,
                    Menu.isPointerShowChecked,
                    Menu.isDegreesShowChecked,
                })
            else
                if Menu.isOutCompassChecked then
                    SendNUIMessage({
                        action = 'update',
                        value = heading,
                        neonIntensity = config.Theme.NeonIntensity or 0.8
                    })
                    SendNUIMessage({
                        action = 'baseplate',
                        show = true,
                        showCompass = true,
                        currentTheme = currentTheme
                    })
                else
                    SendNUIMessage({
                        action = 'baseplate',
                        show = false,
                    })
                end
            end
        end
        lastHeading = heading
    end
end)

--[[
    🎮 Enhanced HUD - Main Client Entry Point
    
    Modular Architecture Entry Point (50-100 lines)
    - Module loading and initialization
    - Global coordination
    - Error handling and recovery
    - Performance monitoring
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- Global module references
_G.HudCore = nil
_G.HudSettings = nil
_G.HudThemes = nil
_G.HudVehicle = nil
_G.HudMap = nil
_G.HudEvents = nil

-- Initialization state
local modulesLoaded = false
local initializationStartTime = GetGameTimer()

--[[
    🚀 Main Initialization Function
]]
local function InitializeHUD()
    print("^6[Enhanced HUD]^7 Starting modular initialization...")
    
    local success, error = pcall(function()
        -- Load all modules in correct order (dependencies first)
        print("^2[Enhanced HUD]^7 Loading modules...")
        
        -- 1. Events module (core communication)
        if HudEvents then
            HudEvents:Initialize()
        end
        
        -- 2. Settings module (configuration)
        if HudSettings then
            HudSettings:Initialize()
        end
        
        -- 3. Themes module (visual system)
        if HudThemes then
            HudThemes:Initialize()
        end
        
        -- 4. Core module (status monitoring)
        if HudCore then
            HudCore:Initialize()
        end
        
        -- 5. Vehicle module (vehicle systems)
        if HudVehicle then
            HudVehicle:Initialize()
        end
        
        -- 6. Map module (navigation)
        if HudMap then
            HudMap:Initialize()
        end
        
        modulesLoaded = true
        local initTime = GetGameTimer() - initializationStartTime
        print("^2[Enhanced HUD]^7 All modules loaded successfully in " .. initTime .. "ms")
        
    end)
    
    if not success then
        print("^1[Enhanced HUD ERROR]^7 Initialization failed: " .. tostring(error))
        -- Attempt recovery
        SetTimeout(5000, InitializeHUD)
    end
end

--[[
    🛡️ Module Health Check
]]
local function CheckModuleHealth()
    CreateThread(function()
        while true do
            Wait(30000) -- Check every 30 seconds
            
            if modulesLoaded then
                local unhealthyModules = {}
                
                -- Check each module's health
                if not HudCore then table.insert(unhealthyModules, 'HudCore') end
                if not HudSettings then table.insert(unhealthyModules, 'HudSettings') end
                if not HudThemes then table.insert(unhealthyModules, 'HudThemes') end
                if not HudVehicle then table.insert(unhealthyModules, 'HudVehicle') end
                if not HudMap then table.insert(unhealthyModules, 'HudMap') end
                if not HudEvents then table.insert(unhealthyModules, 'HudEvents') end
                
                if #unhealthyModules > 0 then
                    print("^1[Enhanced HUD WARNING]^7 Unhealthy modules: " .. table.concat(unhealthyModules, ", "))
                end
            end
        end
    end)
end

--[[
    🎬 Startup Sequence
]]
CreateThread(function()
    -- Wait for QBCore to be ready
    while not QBCore do
        Wait(100)
        QBCore = exports['qb-core']:GetCoreObject()
    end
    
    print("^6[Enhanced HUD]^7 QBCore ready, starting initialization...")
    
    -- Initialize the HUD system
    InitializeHUD()
    
    -- Start health monitoring
    CheckModuleHealth()
end)

--[[
    📡 Global Events (Module Coordination)
]]
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if not modulesLoaded then
        print("^3[Enhanced HUD]^7 Player loaded before modules - retrying initialization...")
        SetTimeout(2000, InitializeHUD)
    end
end)

--[[
    🔧 Global Exports (External Access)
]]
exports('GetHudModule', function(moduleName)
    local modules = {
        core = HudCore,
        settings = HudSettings,
        themes = HudThemes,
        vehicle = HudVehicle,
        map = HudMap,
        events = HudEvents
    }
    return modules[moduleName:lower()]
end)

exports('IsHudReady', function()
    return modulesLoaded
end)

exports('GetHudStatus', function()
    return {
        ready = modulesLoaded,
        modules = {
            core = HudCore ~= nil,
            settings = HudSettings ~= nil,
            themes = HudThemes ~= nil,
            vehicle = HudVehicle ~= nil,
            map = HudMap ~= nil,
            events = HudEvents ~= nil
        },
        initTime = GetGameTimer() - initializationStartTime
    }
end)

print("^2[Enhanced HUD]^7 Main client.lua loaded successfully")