# 🔧 API Documentation - QBCore Advanced HUD System

## 📚 Table of Contents

- [Core Manager APIs](#core-manager-apis)
- [HUD Component System](#hud-component-system)
- [Event System](#event-system)
- [Configuration APIs](#configuration-apis)
- [Utility Functions](#utility-functions)
- [Client-Side Integration](#client-side-integration)
- [Server-Side Integration](#server-side-integration)

---

## 🎯 Core Manager APIs

### HudManager

#### `HudManager.initialize()`
Initializes the complete HUD system including all components.

```lua
-- Basic initialization
HudManager.initialize()

-- With custom config
HudManager.initialize({
    enableAnimations = true,
    performanceMode = false
})
```

#### `HudManager.shutdown()`
Safely shuts down all HUD components and saves states.

```lua
HudManager.shutdown()
```

#### `HudManager.reload()`
Reloads the entire HUD system with current configuration.

```lua
HudManager.reload()
```

#### `HudManager.isInitialized()`
Returns current initialization status.

```lua
local status = HudManager.isInitialized()
-- Returns: boolean
```

---

### ComponentManager

#### `ComponentManager.register(name, component)`
Registers a new HUD component.

```lua
ComponentManager.register('CustomStatus', {
    name = 'CustomStatus',
    element = '#custom-status',
    visible = true,
    priority = 50,
    
    show = function()
        -- Show logic
    end,
    
    hide = function()
        -- Hide logic
    end,
    
    update = function(data)
        -- Update logic
    end
})
```

#### `ComponentManager.unregister(name)`
Removes a component from the system.

```lua
ComponentManager.unregister('CustomStatus')
```

#### `ComponentManager.get(name)`
Retrieves a registered component.

```lua
local component = ComponentManager.get('StatusBars')
```

#### `ComponentManager.getAll()`
Returns all registered components.

```lua
local allComponents = ComponentManager.getAll()
```

#### `ComponentManager.show(name)`
Shows a specific component.

```lua
ComponentManager.show('Minimap')
```

#### `ComponentManager.hide(name)`
Hides a specific component.

```lua
ComponentManager.hide('Minimap')
```

#### `ComponentManager.toggle(name)`
Toggles component visibility.

```lua
ComponentManager.toggle('StatusBars')
```

#### `ComponentManager.updateComponent(name, data)`
Updates component with new data.

```lua
ComponentManager.updateComponent('StatusBars', {
    health = 85,
    armor = 100,
    hunger = 67,
    thirst = 45
})
```

---

## 🧩 HUD Component System

### Component Structure

Every HUD component must implement this interface:

```lua
local Component = {
    name = "ComponentName",          -- Unique identifier
    element = "#selector",           -- CSS selector
    visible = true,                  -- Initial visibility
    priority = 100,                  -- Z-index priority (higher = front)
    
    -- Required Methods
    show = function(self)
        -- Implementation for showing component
    end,
    
    hide = function(self)
        -- Implementation for hiding component
    end,
    
    update = function(self, data)
        -- Implementation for updating component data
    end,
    
    -- Optional Methods
    initialize = function(self)
        -- Custom initialization logic
    end,
    
    cleanup = function(self)
        -- Custom cleanup logic
    end,
    
    onEvent = function(self, eventName, data)
        -- Handle custom events
    end
}
```

### Built-in Components

#### StatusBars Component
```lua
-- Update status bars
ComponentManager.updateComponent('StatusBars', {
    health = 85,      -- 0-100
    armor = 50,       -- 0-100
    hunger = 67,      -- 0-100
    thirst = 45,      -- 0-100
    stress = 23,      -- 0-100
    stamina = 89      -- 0-100
})
```

#### Minimap Component
```lua
-- Show/hide minimap
ComponentManager.show('Minimap')
ComponentManager.hide('Minimap')

-- Update minimap settings
ComponentManager.updateComponent('Minimap', {
    zoom = 1.2,
    followPlayer = true
})
```

#### Speedometer Component
```lua
-- Update speed display
ComponentManager.updateComponent('Speedometer', {
    speed = 65,           -- Current speed
    maxSpeed = 120,       -- Vehicle max speed
    unit = 'kmh',         -- 'kmh' or 'mph'
    gear = 3,             -- Current gear
    rpm = 4500,           -- Engine RPM
    fuel = 78             -- Fuel percentage
})
```

---

## ⚡ Event System

### Core Events

#### `hud:show`
Shows the entire HUD system.

```lua
-- Client side
TriggerEvent('hud:show')

-- Server side (to specific player)
TriggerClientEvent('hud:show', source)
```

#### `hud:hide`
Hides the entire HUD system.

```lua
TriggerEvent('hud:hide')
```

#### `hud:toggle`
Toggles HUD visibility.

```lua
TriggerEvent('hud:toggle')
```

#### `hud:updateStatus`
Updates player status information.

```lua
TriggerEvent('hud:updateStatus', {
    health = GetEntityHealth(PlayerPedId()),
    armor = GetPedArmour(PlayerPedId()),
    hunger = 67,
    thirst = 45
})
```

#### `hud:updateVehicle`
Updates vehicle information.

```lua
TriggerEvent('hud:updateVehicle', {
    speed = 65,
    fuel = 78,
    engine = 850,
    gear = 3
})
```

### Component-Specific Events

#### `hud:component:show`
Shows specific component.

```lua
TriggerEvent('hud:component:show', 'StatusBars')
```

#### `hud:component:hide`
Hides specific component.

```lua
TriggerEvent('hud:component:hide', 'Minimap')
```

#### `hud:component:update`
Updates specific component.

```lua
TriggerEvent('hud:component:update', 'StatusBars', {
    health = 85,
    armor = 100
})
```

### Custom Events

#### `hud:stress:add`
Adds stress to player.

```lua
TriggerEvent('hud:stress:add', 15) -- Add 15 stress points
```

#### `hud:stress:remove`
Removes stress from player.

```lua
TriggerEvent('hud:stress:remove', 10) -- Remove 10 stress points
```

---

## ⚙️ Configuration APIs

### `Config.get(key, default)`
Retrieves configuration value.

```lua
local value = Config.get('Animation.fadeTime', 300)
```

### `Config.set(key, value)`
Sets configuration value at runtime.

```lua
Config.set('Performance.enableAnimations', false)
```

### `Config.save()`
Saves current configuration to persistence.

```lua
Config.save()
```

### `Config.load()`
Loads configuration from persistence.

```lua
Config.load()
```

### `Config.reset()`
Resets configuration to defaults.

```lua
Config.reset()
```

---

## 🔧 Utility Functions

### Theme Management

#### `ThemeManager.setTheme(themeName)`
Changes the active theme.

```lua
ThemeManager.setTheme('neon')
-- Available: 'default', 'neon', 'minimal', 'dark'
```

#### `ThemeManager.getTheme()`
Returns current theme name.

```lua
local currentTheme = ThemeManager.getTheme()
```

#### `ThemeManager.getAvailableThemes()`
Returns list of available themes.

```lua
local themes = ThemeManager.getAvailableThemes()
```

### Animation Control

#### `AnimationManager.setEnabled(enabled)`
Enables/disables animations globally.

```lua
AnimationManager.setEnabled(false)
```

#### `AnimationManager.setSpeed(speed)`
Sets animation speed multiplier.

```lua
AnimationManager.setSpeed(1.5) -- 1.5x speed
```

### Performance Management

#### `PerformanceManager.setMode(mode)`
Sets performance mode.

```lua
PerformanceManager.setMode('high')
-- Modes: 'low', 'medium', 'high', 'ultra'
```

#### `PerformanceManager.getMetrics()`
Returns current performance metrics.

```lua
local metrics = PerformanceManager.getMetrics()
-- Returns: { fps, memory, drawCalls, updateRate }
```

---

## 💻 Client-Side Integration

### Basic Integration

```lua
-- In your client script
Citizen.CreateThread(function()
    -- Wait for HUD system to be ready
    while not HudManager.isInitialized() do
        Citizen.Wait(100)
    end
    
    -- Now safe to interact with HUD
    TriggerEvent('hud:updateStatus', {
        health = 100,
        armor = 100
    })
end)
```

### Player Data Updates

```lua
-- Update player status continuously
Citizen.CreateThread(function()
    while true do
        if HudManager.isInitialized() then
            local playerPed = PlayerPedId()
            
            TriggerEvent('hud:updateStatus', {
                health = GetEntityHealth(playerPed),
                armor = GetPedArmour(playerPed)
            })
        end
        
        Citizen.Wait(1000) -- Update every second
    end
end)
```

### Vehicle Integration

```lua
-- Vehicle HUD updates
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        
        if vehicle ~= 0 and HudManager.isInitialized() then
            local speed = GetEntitySpeed(vehicle) * 3.6 -- Convert to km/h
            local fuel = GetVehicleFuelLevel(vehicle)
            local gear = GetVehicleCurrentGear(vehicle)
            
            TriggerEvent('hud:updateVehicle', {
                speed = math.floor(speed),
                fuel = math.floor(fuel),
                gear = gear
            })
        end
        
        Citizen.Wait(100)
    end
end)
```

---

## 🖥️ Server-Side Integration

### Player Status Management

```lua
-- Update all players' HUD
function UpdateAllPlayersHUD(data)
    TriggerClientEvent('hud:updateStatus', -1, data)
end

-- Update specific player's HUD
function UpdatePlayerHUD(playerId, data)
    TriggerClientEvent('hud:updateStatus', playerId, data)
end
```

### QBCore Integration

```lua
-- Using QBCore player data
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    -- Update HUD with player metadata
    TriggerEvent('hud:updateStatus', {
        hunger = PlayerData.metadata.hunger,
        thirst = PlayerData.metadata.thirst,
        stress = PlayerData.metadata.stress
    })
end)

-- Listen for metadata changes
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    if val.metadata then
        TriggerEvent('hud:updateStatus', {
            hunger = val.metadata.hunger,
            thirst = val.metadata.thirst,
            stress = val.metadata.stress
        })
    end
end)
```

---

## 🔍 Debug APIs

### Debug Mode

#### `DebugManager.enable()`
Enables debug mode with console logging.

```lua
DebugManager.enable()
```

#### `DebugManager.disable()`
Disables debug mode.

```lua
DebugManager.disable()
```

#### `DebugManager.log(message, level)`
Logs debug message.

```lua
DebugManager.log('Component updated', 'info')
-- Levels: 'info', 'warn', 'error', 'debug'
```

### Performance Monitoring

#### `PerformanceMonitor.start()`
Starts performance monitoring.

```lua
PerformanceMonitor.start()
```

#### `PerformanceMonitor.getReport()`
Returns performance report.

```lua
local report = PerformanceMonitor.getReport()
-- Returns detailed performance metrics
```

---

## 🎨 Theme API

### Creating Custom Themes

```lua
local customTheme = {
    name = 'custom',
    displayName = 'Custom Theme',
    
    colors = {
        primary = '#ff6b35',
        secondary = '#004e89',
        background = 'rgba(0, 0, 0, 0.8)',
        text = '#ffffff',
        success = '#28a745',
        warning = '#ffc107',
        danger = '#dc3545'
    },
    
    animations = {
        fadeTime = 300,
        slideTime = 250,
        scaleTime = 200
    },
    
    components = {
        statusBars = {
            width = '200px',
            height = '8px',
            borderRadius = '4px'
        }
    }
}

-- Register custom theme
ThemeManager.registerTheme(customTheme)
```

---

## 🧪 Testing APIs

### Component Testing

```lua
-- Test component functionality
function TestComponent(componentName)
    local component = ComponentManager.get(componentName)
    
    if not component then
        print('❌ Component not found: ' .. componentName)
        return false
    end
    
    -- Test show/hide
    component:hide()
    Citizen.Wait(500)
    component:show()
    
    -- Test update
    component:update({ test = true })
    
    print('✅ Component test passed: ' .. componentName)
    return true
end
```

### Integration Testing

```lua
-- Test full system integration
function TestHUDIntegration()
    -- Initialize
    HudManager.initialize()
    
    -- Wait for initialization
    while not HudManager.isInitialized() do
        Citizen.Wait(100)
    end
    
    -- Test events
    TriggerEvent('hud:updateStatus', { health = 100 })
    TriggerEvent('hud:hide')
    TriggerEvent('hud:show')
    
    print('✅ Integration test completed')
end
```

---

## 📱 NUI Communication

### SendNUIMessage Examples

```lua
-- Update status bars via NUI
SendNUIMessage({
    action = 'updateStatus',
    data = {
        health = 85,
        armor = 100,
        hunger = 67,
        thirst = 45
    }
})

-- Change theme via NUI
SendNUIMessage({
    action = 'setTheme',
    theme = 'neon'
})

-- Toggle component via NUI
SendNUIMessage({
    action = 'toggleComponent',
    component = 'Minimap',
    visible = false
})
```

### NUI Callbacks

```lua
-- Register NUI callback for settings
RegisterNUICallback('saveSettings', function(data, cb)
    -- Save settings to config
    Config.set('theme', data.theme)
    Config.set('Performance.mode', data.performanceMode)
    Config.save()
    
    cb('ok')
end)

-- Register NUI callback for component toggle
RegisterNUICallback('toggleComponent', function(data, cb)
    ComponentManager.toggle(data.component)
    cb('ok')
end)
```

---

## 🚨 Error Handling

### Try-Catch Pattern

```lua
function SafeComponentUpdate(componentName, data)
    local success, error = pcall(function()
        ComponentManager.updateComponent(componentName, data)
    end)
    
    if not success then
        print('❌ Error updating component ' .. componentName .. ': ' .. error)
        return false
    end
    
    return true
end
```

### Validation Helpers

```lua
function ValidateComponentData(data)
    if type(data) ~= 'table' then
        return false, 'Data must be a table'
    end
    
    -- Validate specific fields
    if data.health and (type(data.health) ~= 'number' or data.health < 0 or data.health > 100) then
        return false, 'Health must be a number between 0 and 100'
    end
    
    return true, 'Valid'
end
```

---

## 📋 API Response Formats

### Standard Response Format

```lua
-- Success response
{
    success = true,
    data = { ... },
    message = 'Operation completed successfully'
}

-- Error response
{
    success = false,
    error = 'Error description',
    code = 'ERROR_CODE'
}
```

### Component Status Format

```lua
{
    name = 'StatusBars',
    visible = true,
    initialized = true,
    lastUpdate = timestamp,
    data = { health = 85, armor = 100 }
}
```

---

## 🔗 External Integration Examples

### ESX Integration

```lua
-- ESX status integration
AddEventHandler('esx_status:onTick', function(data)
    local status = {}
    
    for i = 1, #data do
        if data[i].name == 'hunger' then
            status.hunger = math.floor(data[i].percent)
        elseif data[i].name == 'thirst' then
            status.thirst = math.floor(data[i].percent)
        end
    end
    
    TriggerEvent('hud:updateStatus', status)
end)
```

### ox_inventory Integration

```lua
-- ox_inventory weight integration
RegisterNetEvent('ox_inventory:updateWeight', function(weight, maxWeight)
    local percentage = math.floor((weight / maxWeight) * 100)
    
    ComponentManager.updateComponent('InventoryWeight', {
        current = weight,
        max = maxWeight,
        percentage = percentage
    })
end)
```

---

## 🎯 Best Practices

1. **Always check initialization status** before calling HUD functions
2. **Use event-driven updates** instead of constant polling when possible
3. **Validate data** before passing to components
4. **Handle errors gracefully** with try-catch patterns
5. **Use appropriate update intervals** to balance responsiveness and performance
6. **Clean up resources** when components are no longer needed
7. **Follow the component interface** when creating custom components
8. **Test integrations thoroughly** before production use

---

## 📞 Support

For additional API questions or custom integration support:
- Check the [Troubleshooting Guide](TROUBLESHOOTING.md)
- Review [Configuration Documentation](CONFIGURATION.md)  
- See [Integration Examples](../examples/integration-examples.lua)

---

*Last Updated: August 2025*