--[[
    🚗 Enhanced HUD - Vehicle Module
    
    Handles:
    - Vehicle status monitoring (fuel, engine, speed)
    - Harness system integration
    - Nitro system monitoring
    - Vehicle-specific HUD elements
    - Fuel alerts and warnings
]]

local QBCore = exports['qb-core']:GetCoreObject()

HudVehicle = {}
HudVehicle.CurrentVehicle = nil
HudVehicle.VehicleData = {}
HudVehicle.UpdateInterval = 500 -- 2 FPS for vehicle updates
HudVehicle.FastUpdateInterval = 250 -- 4 FPS for critical vehicle stats

-- Vehicle state tracking
local lastVehicleData = {}
local inVehicle = false
local harness = false
local lastFuelWarning = 0

-- Performance tracking
local vehicleUpdateCount = 0

--[[
    🚗 Initialize Vehicle Module
]]
function HudVehicle:Initialize()
    print("^2[HUD-VEHICLE]^7 Initializing vehicle systems...")
    
    -- Start vehicle monitoring loop
    self:StartVehicleMonitoring()
    
    -- Register event handlers
    self:RegisterEventHandlers()
    
    print("^2[HUD-VEHICLE]^7 Vehicle systems initialized")
end

--[[
    🔄 Start Vehicle Monitoring Loop
]]
function HudVehicle:StartVehicleMonitoring()
    CreateThread(function()
        while true do
            local ped = PlayerPedId()
            if ped and DoesEntityExist(ped) then
                vehicleUpdateCount = vehicleUpdateCount + 1
                
                -- Check if player is in vehicle
                local currentVehicle = GetVehiclePedIsIn(ped, false)
                
                if currentVehicle ~= 0 then
                    -- Player is in vehicle
                    if not inVehicle or currentVehicle ~= HudVehicle.CurrentVehicle then
                        self:OnEnterVehicle(currentVehicle)
                    end
                    
                    -- Fast updates (every 250ms) - Critical vehicle stats
                    if vehicleUpdateCount % 1 == 0 then
                        self:UpdateCriticalVehicleStats(currentVehicle)
                    end
                    
                    -- Normal updates (every 500ms) - Regular vehicle stats
                    if vehicleUpdateCount % 2 == 0 then
                        self:UpdateRegularVehicleStats(currentVehicle)
                    end
                    
                    -- Slow updates (every 1000ms) - Heavy operations
                    if vehicleUpdateCount % 4 == 0 then
                        self:UpdateSlowVehicleStats(currentVehicle)
                    end
                    
                else
                    -- Player not in vehicle
                    if inVehicle then
                        self:OnExitVehicle()
                    end
                end
            end
            
            Wait(HudVehicle.FastUpdateInterval)
        end
    end)
end

--[[
    🚪 Handle Vehicle Entry
]]
function HudVehicle:OnEnterVehicle(vehicle)
    inVehicle = true
    HudVehicle.CurrentVehicle = vehicle
    
    -- Get vehicle info
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
    
    print("^2[HUD-VEHICLE]^7 Entered vehicle: " .. vehicleName)
    
    -- Send vehicle entry event to NUI
    SendNUIMessage({
        action = 'vehicleEntered',
        vehicle = {
            entity = vehicle,
            model = vehicleModel,
            name = vehicleName,
            class = GetVehicleClass(vehicle)
        }
    })
    
    -- Initial vehicle data update
    self:UpdateCriticalVehicleStats(vehicle)
    self:UpdateRegularVehicleStats(vehicle)
    
    -- Trigger vehicle entry effect
    if HudThemes then
        HudThemes:TriggerGlow('vehicle', '#ff9800', 1.0)
    end
end

--[[
    🚪 Handle Vehicle Exit
]]
function HudVehicle:OnExitVehicle()
    print("^2[HUD-VEHICLE]^7 Exited vehicle")
    
    inVehicle = false
    HudVehicle.CurrentVehicle = nil
    HudVehicle.VehicleData = {}
    lastVehicleData = {}
    harness = false
    
    -- Send vehicle exit event to NUI
    SendNUIMessage({
        action = 'vehicleExited'
    })
end

--[[
    🚨 Update Critical Vehicle Stats (Speed, Engine)
]]
function HudVehicle:UpdateCriticalVehicleStats(vehicle)
    if not vehicle or vehicle == 0 then return end
    
    local speed = GetEntitySpeed(vehicle)
    local speedKmh = math.ceil(speed * 3.6)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local engineOn = GetIsVehicleEngineRunning(vehicle)
    
    -- RPM calculation
    local rpm = GetVehicleCurrentRpm(vehicle)
    
    -- Check for significant changes
    local shouldUpdate = false
    
    if not lastVehicleData.speed or math.abs(lastVehicleData.speed - speedKmh) >= 5 then
        shouldUpdate = true
    end
    if not lastVehicleData.engineHealth or math.abs(lastVehicleData.engineHealth - engineHealth) >= 50 then
        shouldUpdate = true
    end
    if lastVehicleData.engineOn ~= engineOn then
        shouldUpdate = true
    end
    
    if shouldUpdate then
        -- Update tracking
        lastVehicleData.speed = speedKmh
        lastVehicleData.engineHealth = engineHealth
        lastVehicleData.engineOn = engineOn
        lastVehicleData.rpm = rpm
        
        -- Send to NUI
        SendNUIMessage({
            action = 'updateVehicleStats',
            stats = {
                speed = speedKmh,
                engineHealth = math.ceil(engineHealth / 10), -- Convert to 0-100 scale
                engineOn = engineOn,
                rpm = rpm
            }
        })
        
        -- Critical engine health alert
        if engineHealth <= 300 and HudSettings and HudSettings:GetSetting('isDynamicEngineChecked', true) then
            if HudThemes then
                HudThemes:TriggerCriticalAlert('engine', math.ceil(engineHealth / 10))
            end
        end
    end
end

--[[
    ⛽ Update Regular Vehicle Stats (Fuel, etc.)
]]
function HudVehicle:UpdateRegularVehicleStats(vehicle)
    if not vehicle or vehicle == 0 then return end
    
    -- Fuel system integration
    local fuel = 100 -- Default value
    
    -- Try different fuel systems
    if exports['LegacyFuel'] then
        fuel = exports['LegacyFuel']:GetFuel(vehicle) or 100
    elseif exports['ps-fuel'] then
        fuel = exports['ps-fuel']:GetFuel(vehicle) or 100
    elseif exports['cdn-fuel'] then
        fuel = exports['cdn-fuel']:GetFuel(vehicle) or 100
    else
        -- Fallback to game fuel
        fuel = GetVehicleFuelLevel(vehicle)
    end
    
    fuel = math.ceil(fuel)
    
    -- Body health
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    
    -- Check for changes
    local shouldUpdate = false
    
    if not lastVehicleData.fuel or math.abs(lastVehicleData.fuel - fuel) >= 2 then
        shouldUpdate = true
    end
    if not lastVehicleData.bodyHealth or math.abs(lastVehicleData.bodyHealth - bodyHealth) >= 50 then
        shouldUpdate = true
    end
    
    if shouldUpdate then
        -- Update tracking
        lastVehicleData.fuel = fuel
        lastVehicleData.bodyHealth = bodyHealth
        
        -- Send to NUI
        SendNUIMessage({
            action = 'updateVehicleStats',
            stats = {
                fuel = fuel,
                bodyHealth = math.ceil(bodyHealth / 10) -- Convert to 0-100 scale
            }
        })
        
        -- Fuel warning
        self:CheckFuelWarning(fuel)
    end
end

--[[
    🐌 Update Slow Vehicle Stats (Harness, Nitro, etc.)
]]
function HudVehicle:UpdateSlowVehicleStats(vehicle)
    if not vehicle or vehicle == 0 then return end
    
    -- Check for nitro system
    local hasNitro = false
    local nitroLevel = 0
    
    -- Try different nitro systems
    if exports['SonoranCAD'] then
        -- SonoranCAD Nitro
        hasNitro = true
        nitroLevel = 100 -- Placeholder
    elseif exports['ps-nitro'] then
        -- PS Nitro
        hasNitro = true
        nitroLevel = exports['ps-nitro']:GetNitroLevel(vehicle) or 0
    end
    
    -- Vehicle lights status
    local lightsOn = IsVehicleLightOn(vehicle, 0) or IsVehicleLightOn(vehicle, 1)
    local highbeamsOn = IsVehicleHighBeamOn(vehicle)
    
    -- Update if changed
    local shouldUpdate = false
    
    if lastVehicleData.hasNitro ~= hasNitro then
        shouldUpdate = true
    end
    if hasNitro and (not lastVehicleData.nitroLevel or math.abs(lastVehicleData.nitroLevel - nitroLevel) >= 5) then
        shouldUpdate = true
    end
    if lastVehicleData.lightsOn ~= lightsOn then
        shouldUpdate = true
    end
    if lastVehicleData.harness ~= harness then
        shouldUpdate = true
    end
    
    if shouldUpdate then
        -- Update tracking
        lastVehicleData.hasNitro = hasNitro
        lastVehicleData.nitroLevel = nitroLevel
        lastVehicleData.lightsOn = lightsOn
        lastVehicleData.highbeamsOn = highbeamsOn
        lastVehicleData.harness = harness
        
        -- Send to NUI
        SendNUIMessage({
            action = 'updateVehicleStats',
            stats = {
                hasNitro = hasNitro,
                nitroLevel = nitroLevel,
                lightsOn = lightsOn,
                highbeamsOn = highbeamsOn,
                harness = harness
            }
        })
    end
end

--[[
    ⛽ Check Fuel Warning
]]
function HudVehicle:CheckFuelWarning(fuel)
    local currentTime = GetGameTimer()
    
    -- Low fuel threshold
    local lowFuelThreshold = 15
    
    if fuel <= lowFuelThreshold and HudSettings and HudSettings:GetSetting('isLowFuelChecked', true) then
        -- Don't spam warnings
        if currentTime - lastFuelWarning > 30000 then -- 30 seconds cooldown
            lastFuelWarning = currentTime
            
            -- Trigger fuel warning
            if HudThemes then
                HudThemes:TriggerCriticalAlert('fuel', fuel)
            end
            
            -- Play warning sound
            if HudSettings:GetSetting('isResetSoundsChecked', true) then
                TriggerServerEvent('InteractSound_SV:PlayOnSource', 'fuel_warning', 0.4)
            end
            
            -- Notification
            QBCore.Functions.Notify('Low Fuel Warning: ' .. fuel .. '%', 'error', 3000)
            
            print("^3[HUD-VEHICLE]^7 Low fuel warning: " .. fuel .. "%")
        end
    end
end

--[[
    🔧 Harness System Integration
]]
function HudVehicle:UpdateHarnessStatus(items)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        harness = false
        return
    end
    
    local hasHarness = false
    if items then
        for _, item in pairs(items) do
            if item.name == 'harness' then
                hasHarness = true
                break
            end
        end
    end
    
    if harness ~= hasHarness then
        harness = hasHarness
        
        -- Send harness status update
        SendNUIMessage({
            action = 'updateVehicleStats',
            stats = {
                harness = harness
            }
        })
        
        -- Harness effect
        if HudThemes then
            local color = harness and '#00ff41' or '#ff4444'
            HudThemes:TriggerGlow('harness', color, 1.0)
        end
        
        print("^2[HUD-VEHICLE]^7 Harness status: " .. (harness and "equipped" or "not equipped"))
    end
end

--[[
    📡 Register Event Handlers
]]
function HudVehicle:RegisterEventHandlers()
    -- Harness update from inventory
    RegisterNetEvent('hud:client:UpdateHarness', function(items)
        self:UpdateHarnessStatus(items)
    end)
    
    -- Manual vehicle update
    RegisterNetEvent('hud:client:UpdateVehicle', function()
        if inVehicle and HudVehicle.CurrentVehicle then
            self:UpdateCriticalVehicleStats(HudVehicle.CurrentVehicle)
            self:UpdateRegularVehicleStats(HudVehicle.CurrentVehicle)
            self:UpdateSlowVehicleStats(HudVehicle.CurrentVehicle)
        end
    end)
    
    -- Fuel system events
    RegisterNetEvent('fuel:client:UpdateFuel', function(newFuel)
        if inVehicle and newFuel then
            lastVehicleData.fuel = math.ceil(newFuel)
            SendNUIMessage({
                action = 'updateVehicleStats',
                stats = {
                    fuel = lastVehicleData.fuel
                }
            })
            
            self:CheckFuelWarning(lastVehicleData.fuel)
        end
    end)
    
    -- Nitro system events
    RegisterNetEvent('nitro:client:UpdateNitro', function(level)
        if inVehicle and level then
            lastVehicleData.nitroLevel = level
            SendNUIMessage({
                action = 'updateVehicleStats',
                stats = {
                    nitroLevel = level
                }
            })
        end
    end)
    
    -- Engine damage events
    RegisterNetEvent('vehicle:client:EngineWarning', function(damage)
        if inVehicle and HudThemes then
            HudThemes:TriggerCriticalAlert('engine', damage)
        end
    end)
end

--[[
    🔧 Utility Functions
]]
function HudVehicle:GetCurrentVehicleData()
    return {
        inVehicle = inVehicle,
        vehicle = HudVehicle.CurrentVehicle,
        data = lastVehicleData,
        harness = harness
    }
end

function HudVehicle:IsInVehicle()
    return inVehicle
end

function HudVehicle:GetCurrentVehicle()
    return HudVehicle.CurrentVehicle
end

function HudVehicle:ForceVehicleUpdate()
    if inVehicle and HudVehicle.CurrentVehicle then
        self:UpdateCriticalVehicleStats(HudVehicle.CurrentVehicle)
        self:UpdateRegularVehicleStats(HudVehicle.CurrentVehicle)
        self:UpdateSlowVehicleStats(HudVehicle.CurrentVehicle)
    end
end

--[[
    🔧 Exports
]]
exports('GetHudVehicle', function()
    return HudVehicle
end)

exports('GetCurrentVehicleData', function()
    return HudVehicle:GetCurrentVehicleData()
end)

exports('IsInVehicle', function()
    return HudVehicle:IsInVehicle()
end)

exports('UpdateHarness', function(items)
    HudVehicle:UpdateHarnessStatus(items)
end)

exports('ForceVehicleUpdate', function()
    HudVehicle:ForceVehicleUpdate()
end)

print("^2[HUD-VEHICLE]^7 Module loaded successfully")