# QBCore HUD - Neon UI Export Examples

## 🚀 Verfügbare Exports

### 1. SetNavigationData(destination, distance)
Setzt Zielort und Entfernung in der Navigation UI.

```lua
-- Beispiel: GPS Navigation
RegisterCommand('setnav', function(source, args)
    if #args >= 2 then
        local destination = args[1]
        local distance = args[2] .. "KM"
        exports['qb-hud']:SetNavigationData(destination, distance)
    end
end)

-- Beispiel: Automatische Wegpunkt-Integration
CreateThread(function()
    while true do
        Wait(5000)
        if IsWaypointActive() then
            local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - waypointCoords)
            local distanceKM = string.format("%.1fKM", distance / 1000)
            
            -- Bestimme Zielbereich basierend auf Koordinaten
            local destination = GetLabelText(GetNameOfZone(waypointCoords.x, waypointCoords.y, waypointCoords.z))
            exports['qb-hud']:SetNavigationData(destination, distanceKM)
        end
    end
end)
```

### 2. UpdateServerTime(time)
Aktualisiert die Serverzeit in der UI.

```lua
-- Beispiel: Custom Zeitzone
CreateThread(function()
    while true do
        Wait(60000) -- Jede Minute
        local hour = GetClockHours()
        local minute = GetClockMinutes()
        local timeString = string.format("%02d:%02d", hour, minute)
        exports['qb-hud']:UpdateServerTime(timeString)
    end
end)

-- Beispiel: Event-basierte Zeit Updates
RegisterNetEvent('qb-weathersync:client:SyncTime', function(hour, minute)
    local timeString = string.format("%02d:%02d", hour, minute)
    exports['qb-hud']:UpdateServerTime(timeString)
end)
```

### 3. ToggleMapInterface(show)
Zeigt/versteckt den Map-Interface Bereich.

```lua
-- Beispiel: Map Interface Toggle
RegisterCommand('togglemap', function()
    local showMap = not GetResourceKvpInt('mapInterfaceVisible')
    exports['qb-hud']:ToggleMapInterface(showMap)
    SetResourceKvpInt('mapInterfaceVisible', showMap and 1 or 0)
end)

-- Beispiel: Automatisches Verstecken in bestimmten Bereichen
CreateThread(function()
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Verstecke Map in Interiors
        if GetInteriorFromEntity(ped) ~= 0 then
            exports['qb-hud']:ToggleMapInterface(false)
        else
            exports['qb-hud']:ToggleMapInterface(true)
        end
    end
end)
```

### 4. SetMapMode(mode)
Ändert den Map-Anzeigemodus.

```lua
-- Verfügbare Modi: "navigation", "standard", "hidden"

-- Beispiel: Fahrzeug-abhängiger Modus
CreateThread(function()
    local wasInVehicle = false
    while true do
        Wait(1000)
        local ped = PlayerPedId()
        local inVehicle = IsPedInAnyVehicle(ped, false)
        
        if inVehicle and not wasInVehicle then
            exports['qb-hud']:SetMapMode("navigation")
            wasInVehicle = true
        elseif not inVehicle and wasInVehicle then
            exports['qb-hud']:SetMapMode("standard")
            wasInVehicle = false
        end
    end
end)

-- Beispiel: Job-spezifische Modi
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    if JobInfo.name == 'police' or JobInfo.name == 'ambulance' then
        exports['qb-hud']:SetMapMode("navigation")
    else
        exports['qb-hud']:SetMapMode("standard")
    end
end)
```

## 🎯 Praktische Anwendungsbeispiele

### GPS Navigation System Integration
```lua
-- client.lua eines GPS Scripts
local function UpdateGPSNavigation()
    if not IsWaypointActive() then return end
    
    local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - waypointCoords)
    
    local street1, street2 = GetStreetNameAtCoord(waypointCoords.x, waypointCoords.y, waypointCoords.z)
    local destination = GetStreetNameFromHashKey(street1)
    local distanceText = string.format("%.1fKM", distance / 1000)
    
    exports['qb-hud']:SetNavigationData(destination, distanceText)
    exports['qb-hud']:SetMapMode("navigation")
end

CreateThread(function()
    while true do
        Wait(2000)
        UpdateGPSNavigation()
    end
end)
```

### Job-spezifische HUD Modi
```lua
-- Polizei/EMS Integration
RegisterNetEvent('police:client:onDuty', function()
    exports['qb-hud']:SetMapMode("navigation")
    QBCore.Functions.Notify("Navigation Modus aktiviert", "success")
end)

RegisterNetEvent('police:client:offDuty', function()
    exports['qb-hud']:SetMapMode("standard")
    QBCore.Functions.Notify("Standard Modus aktiviert", "primary")
end)
```

### Rennsport/Event Integration
```lua
-- Race Script Integration
RegisterNetEvent('racing:client:raceStart', function(raceData)
    exports['qb-hud']:SetNavigationData("RENNSTRECKE", "0.0KM")
    exports['qb-hud']:SetMapMode("navigation")
end)

RegisterNetEvent('racing:client:updateCheckpoint', function(checkpointData)
    local distance = string.format("%.1fKM", checkpointData.distance / 1000)
    exports['qb-hud']:SetNavigationData("CHECKPOINT " .. checkpointData.number, distance)
end)

RegisterNetEvent('racing:client:raceEnd', function()
    exports['qb-hud']:SetNavigationData("ZIEL ERREICHT", "0.0KM")
    exports['qb-hud']:SetMapMode("standard")
end)
```

## 🎨 Styling Anpassungen

Das Neon-UI folgt dem definierten Design-System:

- **Orbitron Font** für alle Titel und wichtige Texte
- **Roboto Font** für Beschreibungen und sekundäre Texte
- **Neon-Farben**: Cyan (#00ffff), Purple (#a020f0), Orange (#FF9800)
- **Hover-Animationen** mit Scale-Effekten und Glows
- **Responsive Design** für alle Bildschirmgrößen
- **12px Border-Radius** für alle UI-Elemente

## 🔧 Integration in bestehende Scripts

Die Exports sind so designed, dass sie problemlos in bestehende QBCore-Scripts integriert werden können, ohne die ursprüngliche HUD-Funktionalität zu beeinträchtigen.

### Kompatibilität
- ✅ Vollständig kompatibel mit allen bestehenden qb-hud Features
- ✅ Keine Änderungen an bestehenden Exports
- ✅ Rückwärtskompatibel mit allen QBCore Scripts
- ✅ Alle ursprünglichen Settings und Menü-Optionen bleiben erhalten