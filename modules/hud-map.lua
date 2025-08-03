--[[
    🗺️ Enhanced HUD - Map & Compass Module
    
    Handles:
    - Map visibility and shape management
    - Compass system and street names
    - Minimap positioning and borders
    - Location tracking and updates
    - FPS optimization for map updates
]]

local QBCore = exports['qb-core']:GetCoreObject()

HudMap = {}
HudMap.MapSettings = {
    shape = 'circle',
    borders = false,
    hidden = false,
    followPlayer = true
}

HudMap.CompassSettings = {
    visible = true,
    showStreets = true,
    showPointer = true,
    showDegrees = true,
    fpsOptimized = false
}

-- Map state tracking
local currentLocation = ''
local lastLocation = ''
local showSquareB = false
local showCircleB = false
local mapInitialized = false

-- Performance settings
local compassUpdateInterval = 100 -- 10 FPS default
local locationUpdateInterval = 1000 -- 1 FPS for location checks

--[[
    🗺️ Initialize Map Module
]]
function HudMap:Initialize()
    print("^2[HUD-MAP]^7 Initializing map systems...")
    
    -- Load map settings
    self:LoadMapSettings()
    
    -- Initialize map configuration
    self:InitializeMap()
    
    -- Start location monitoring
    self:StartLocationMonitoring()
    
    -- Register event handlers
    self:RegisterEventHandlers()
    
    print("^2[HUD-MAP]^7 Map systems initialized")
end

--[[
    📥 Load Map Settings
]]
function HudMap:LoadMapSettings()
    if HudSettings and HudSettings.Menu then
        local menu = HudSettings.Menu
        
        -- Map settings
        HudMap.MapSettings.shape = menu.isToggleMapShapeChecked or 'circle'
        HudMap.MapSettings.borders = menu.isToggleMapBordersChecked or false
        HudMap.MapSettings.hidden = menu.isHideMapChecked or false
        HudMap.MapSettings.followPlayer = menu.isCompassFollowChecked or true
        
        -- Compass settings
        HudMap.CompassSettings.visible = menu.isCompassShowChecked or true
        HudMap.CompassSettings.showStreets = menu.isShowStreetsChecked or true
        HudMap.CompassSettings.showPointer = menu.isPointerShowChecked or true
        HudMap.CompassSettings.showDegrees = menu.isDegreesShowChecked or true
        HudMap.CompassSettings.fpsOptimized = menu.isChangeCompassFPSChecked or false
        
        -- Apply FPS optimization
        if HudMap.CompassSettings.fpsOptimized then
            compassUpdateInterval = 250 -- 4 FPS for performance mode
        end
    end
end

--[[
    🎬 Initialize Map Configuration
]]
function HudMap:InitializeMap()
    CreateThread(function()
        Wait(2000) -- Wait for game to load
        
        -- Set map visibility
        DisplayRadar(not HudMap.MapSettings.hidden)
        
        -- Configure map shape and position
        self:ConfigureMap()
        
        mapInitialized = true
        print("^2[HUD-MAP]^7 Map configuration applied")
    end)
end

--[[
    ⚙️ Configure Map Shape and Position
]]
function HudMap:ConfigureMap()
    local defaultAspectRatio = 1920 / 1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    
    -- Calculate offset for different aspect ratios
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end
    
    -- Map positioning
    RequestStreamedTextureDict("squaremap", false)
    if not HasStreamedTextureDictLoaded("squaremap") then
        Wait(150)
    end
    
    -- Apply map shape
    if HudMap.MapSettings.shape == 'square' then
        self:SetSquareMap(minimapOffset)
    else
        self:SetCircleMap(minimapOffset)
    end
    
    -- Apply borders
    self:UpdateMapBorders()
end

--[[
    🟦 Set Square Map
]]
function HudMap:SetSquareMap(offset)
    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
    
    -- Minimap positioning
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + offset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + offset, 0.09, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + offset, 0.025, 0.262, 0.300)
    
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetRadarZoom(1000)
    
    print("^2[HUD-MAP]^7 Square map applied")
end

--[[
    🔵 Set Circle Map
]]
function HudMap:SetCircleMap(offset)
    SetMinimapClipType(1)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "circlemap", "radarmasksm")
    
    -- Minimap positioning for circle
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + offset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + offset, 0.09, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + offset, 0.025, 0.262, 0.300)
    
    SetBlipAlpha(GetNorthRadarBlip(), 255)
    SetRadarZoom(1100)
    
    print("^2[HUD-MAP]^7 Circle map applied")
end

--[[
    🖼️ Update Map Borders
]]
function HudMap:UpdateMapBorders()
    if HudMap.MapSettings.borders then
        if HudMap.MapSettings.shape == 'square' then
            showSquareB = true
            showCircleB = false
        else
            showCircleB = true
            showSquareB = false
        end
    else
        showSquareB = false
        showCircleB = false
    end
    
    -- Apply border visibility to NUI
    SendNUIMessage({
        action = 'updateMapBorders',
        showSquare = showSquareB,
        showCircle = showCircleB
    })
end

--[[
    📍 Start Location Monitoring
]]
function HudMap:StartLocationMonitoring()
    CreateThread(function()
        while true do
            if HudMap.CompassSettings.visible and HudMap.CompassSettings.showStreets then
                self:UpdateLocation()
            end
            Wait(locationUpdateInterval)
        end
    end)
    
    -- Compass updates (faster)
    CreateThread(function()
        while true do
            if HudMap.CompassSettings.visible then
                self:UpdateCompass()
            end
            Wait(compassUpdateInterval)
        end
    end)
end

--[[
    📍 Update Current Location
]]
function HudMap:UpdateLocation()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    local coords = GetEntityCoords(ped)
    local streetHash1, streetHash2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street1 = GetStreetNameFromHashKey(streetHash1)
    local street2 = GetStreetNameFromHashKey(streetHash2)
    
    local newLocation = street1
    if street2 and street2 ~= "" then
        newLocation = street1 .. " / " .. street2
    end
    
    if newLocation ~= lastLocation then
        lastLocation = newLocation
        currentLocation = newLocation
        
        -- Send location update to compass/GPS systems
        SendNUIMessage({
            action = 'updateLocation',
            location = newLocation,
            coordinates = {
                x = math.floor(coords.x),
                y = math.floor(coords.y),
                z = math.floor(coords.z)
            }
        })
        
        -- Update GPS HUD if active
        TriggerEvent('gps:client:updateLocation', newLocation, coords)
    end
end

--[[
    🧭 Update Compass
]]
function HudMap:UpdateCompass()
    if not HudMap.CompassSettings.visible then return end
    
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    
    -- Get player heading
    local heading = GetEntityHeading(ped)
    local degrees = math.floor(heading)
    
    -- Cardinal directions
    local direction = "N"
    if heading >= 337.5 or heading < 22.5 then
        direction = "N"
    elseif heading >= 22.5 and heading < 67.5 then
        direction = "NE"
    elseif heading >= 67.5 and heading < 112.5 then
        direction = "E"
    elseif heading >= 112.5 and heading < 157.5 then
        direction = "SE"
    elseif heading >= 157.5 and heading < 202.5 then
        direction = "S"
    elseif heading >= 202.5 and heading < 247.5 then
        direction = "SW"
    elseif heading >= 247.5 and heading < 292.5 then
        direction = "W"
    elseif heading >= 292.5 and heading < 337.5 then
        direction = "NW"
    end
    
    -- Send compass update
    SendNUIMessage({
        action = 'updateCompass',
        heading = degrees,
        direction = direction,
        showPointer = HudMap.CompassSettings.showPointer,
        showDegrees = HudMap.CompassSettings.showDegrees
    })
end

--[[
    📡 Register Event Handlers
]]
function HudMap:RegisterEventHandlers()
    -- Map reload event
    RegisterNetEvent('hud:client:LoadMap', function()
        if mapInitialized then
            self:ConfigureMap()
        end
    end)
    
    -- Map shape toggle
    RegisterNetEvent('hud:client:ToggleMapShape', function()
        HudMap.MapSettings.shape = HudMap.MapSettings.shape == 'circle' and 'square' or 'circle'
        if HudSettings then
            HudSettings:SetSetting('isToggleMapShapeChecked', HudMap.MapSettings.shape)
        end
        self:ConfigureMap()
        
        if HudThemes then
            HudThemes:TriggerGlow('mapshape', '#a020f0', 0.8)
        end
    end)
    
    -- Map visibility toggle
    RegisterNetEvent('hud:client:ToggleMap', function()
        HudMap.MapSettings.hidden = not HudMap.MapSettings.hidden
        DisplayRadar(not HudMap.MapSettings.hidden)
        
        if HudSettings then
            HudSettings:SetSetting('isHideMapChecked', HudMap.MapSettings.hidden)
        end
        
        if HudThemes then
            HudThemes:TriggerGlow('map', '#a020f0', 0.8)
        end
    end)
    
    -- Map borders toggle
    RegisterNetEvent('hud:client:ToggleMapBorders', function()
        HudMap.MapSettings.borders = not HudMap.MapSettings.borders
        self:UpdateMapBorders()
        
        if HudSettings then
            HudSettings:SetSetting('isToggleMapBordersChecked', HudMap.MapSettings.borders)
        end
        
        if HudThemes then
            HudThemes:TriggerGlow('mapborder', '#00ffff', 0.8)
        end
    end)
    
    -- Compass visibility toggle
    RegisterNetEvent('hud:client:ToggleCompass', function()
        HudMap.CompassSettings.visible = not HudMap.CompassSettings.visible
        
        if HudSettings then
            HudSettings:SetSetting('isCompassShowChecked', HudMap.CompassSettings.visible)
        end
        
        if HudThemes then
            HudThemes:TriggerGlow('compass', '#00ffff', 0.8)
        end
    end)
    
    -- Street names toggle
    RegisterNetEvent('hud:client:ToggleStreetNames', function()
        HudMap.CompassSettings.showStreets = not HudMap.CompassSettings.showStreets
        
        if HudSettings then
            HudSettings:SetSetting('isShowStreetsChecked', HudMap.CompassSettings.showStreets)
        end
        
        if HudThemes then
            HudThemes:TriggerGlow('streets', '#00ffff', 0.8)
        end
    end)
    
    -- Compass FPS optimization toggle
    RegisterNetEvent('hud:client:ToggleCompassFPS', function()
        HudMap.CompassSettings.fpsOptimized = not HudMap.CompassSettings.fpsOptimized
        
        -- Update compass update interval
        if HudMap.CompassSettings.fpsOptimized then
            compassUpdateInterval = 250 -- 4 FPS
        else
            compassUpdateInterval = 100 -- 10 FPS
        end
        
        if HudSettings then
            HudSettings:SetSetting('isChangeCompassFPSChecked', HudMap.CompassSettings.fpsOptimized)
        end
        
        if HudThemes then
            HudThemes:TriggerGlow('compass-fps', '#00ffff', 0.8)
        end
    end)
end

--[[
    🔧 Utility Functions
]]
function HudMap:GetCurrentLocation()
    return currentLocation
end

function HudMap:GetMapSettings()
    return HudMap.MapSettings
end

function HudMap:GetCompassSettings()
    return HudMap.CompassSettings
end

function HudMap:SetMapShape(shape)
    if shape == 'circle' or shape == 'square' then
        HudMap.MapSettings.shape = shape
        self:ConfigureMap()
        return true
    end
    return false
end

function HudMap:SetMapVisibility(visible)
    HudMap.MapSettings.hidden = not visible
    DisplayRadar(visible)
end

function HudMap:ForceMapReload()
    self:ConfigureMap()
end

function HudMap:SetCompassFPS(optimized)
    HudMap.CompassSettings.fpsOptimized = optimized
    compassUpdateInterval = optimized and 250 or 100
end

--[[
    🔧 Exports
]]
exports('GetHudMap', function()
    return HudMap
end)

exports('GetCurrentLocation', function()
    return HudMap:GetCurrentLocation()
end)

exports('GetMapSettings', function()
    return HudMap:GetMapSettings()
end)

exports('SetMapShape', function(shape)
    return HudMap:SetMapShape(shape)
end)

exports('ToggleMapVisibility', function()
    TriggerEvent('hud:client:ToggleMap')
end)

exports('ForceMapReload', function()
    HudMap:ForceMapReload()
end)

print("^2[HUD-MAP]^7 Module loaded successfully")