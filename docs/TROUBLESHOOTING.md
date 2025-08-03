# 🔧 Troubleshooting Guide - QBCore Advanced HUD System

## 📚 Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Installation Issues](#installation-issues)
- [Performance Problems](#performance-problems)
- [Component Issues](#component-issues)
- [Theme Problems](#theme-problems)
- [Integration Conflicts](#integration-conflicts)
- [Database Issues](#database-issues)
- [Client-Side Problems](#client-side-problems)
- [Server-Side Problems](#server-side-problems)
- [Debug Tools](#debug-tools)
- [Common Error Messages](#common-error-messages)
- [Advanced Diagnostics](#advanced-diagnostics)

---

## 🚀 Quick Diagnostics

### First Steps Checklist

Run through this checklist before diving into specific issues:

1. **Check Resource Status**
   ```bash
   # In server console
   ensure qb-advanced-hud
   ```

2. **Verify Dependencies**
   ```bash
   # Essential dependencies
   ensure qb-core
   ensure oxmysql  # or ghmattimysql
   ```

3. **Check Console Errors**
   - Server console: Look for Lua errors
   - F8 client console: Look for JavaScript errors
   - Browser DevTools: Check for NUI errors

4. **Test Basic Functionality**
   ```lua
   # In client console (F8)
   TriggerEvent('hud:show')
   TriggerEvent('hud:hide')
   ```

### Quick Fix Commands

```bash
# Restart HUD system
restart qb-advanced-hud

# Reload player data
TriggerEvent('QBCore:Client:OnPlayerLoaded')

# Reset HUD configuration
TriggerEvent('hud:resetConfig')

# Force component refresh
TriggerEvent('hud:component:refreshAll')
```

---

## 📦 Installation Issues

### Problem: Resource Won't Start

**Symptoms:**
- Server console shows "Failed to start resource"
- Resource appears as stopped in `status`

**Solutions:**

1. **Check fxmanifest.lua**
   ```lua
   -- Ensure proper structure
   fx_version 'cerulean'
   game 'gta5'
   lua54 'yes'
   
   -- All files must exist
   client_scripts {
       'client/*.lua'
   }
   ```

2. **Verify File Permissions**
   ```bash
   # Linux/Mac
   chmod -R 755 resources/qb-advanced-hud/
   
   # Check file ownership
   chown -R fivem:fivem resources/qb-advanced-hud/
   ```

3. **Check Resource Name**
   - Folder name must match resource name in server.cfg
   - No spaces or special characters in folder name

### Problem: Dependencies Not Found

**Error Message:** `"Could not load dependency 'qb-core'"`

**Solutions:**

1. **Check Dependency Order in server.cfg**
   ```bash
   # Correct order
   ensure qb-core
   ensure oxmysql
   ensure qb-advanced-hud
   ```

2. **Verify QBCore Installation**
   ```lua
   # Test in client console
   print(QBCore)
   # Should not be nil
   ```

3. **Check MySQL Wrapper**
   ```lua
   # Test MySQL connection
   print(GetResourceState('oxmysql'))
   # Should return 'started'
   ```

### Problem: NUI Not Loading

**Symptoms:**
- HUD appears as blank/black screen
- No visual components visible

**Solutions:**

1. **Check HTML File Path**
   ```lua
   -- In fxmanifest.lua
   ui_page 'html/index.html'
   
   -- Verify file exists:
   -- resources/qb-advanced-hud/html/index.html
   ```

2. **Test NUI Message**
   ```lua
   # In client console
   SendNUIMessage({action = 'test'})
   ```

3. **Check Browser Console**
   - Press F12 in game
   - Look for JavaScript errors
   - Check Network tab for failed requests

---

## ⚡ Performance Problems

### Problem: Low FPS/Frame Drops

**Symptoms:**
- Game stuttering when HUD is visible
- FPS drops below 30 with HUD enabled

**Solutions:**

1. **Enable Performance Mode**
   ```lua
   # In client console
   TriggerEvent('hud:setPerformanceMode', 'high')
   ```

2. **Disable Animations**
   ```lua
   Config.Animation.enabled = false
   ```

3. **Reduce Update Frequency**
   ```lua
   Config.Performance.updateRate = 1000  -- Update every 1 second
   ```

4. **Optimize Components**
   ```lua
   # Hide unnecessary components
   TriggerEvent('hud:component:hide', 'Minimap')
   TriggerEvent('hud:component:hide', 'Speedometer')
   ```

### Problem: Memory Leaks

**Symptoms:**
- RAM usage continuously increasing
- Game becomes unstable over time

**Solutions:**

1. **Check Component Cleanup**
   ```lua
   -- Ensure proper component destruction
   ComponentManager.cleanup()
   ```

2. **Monitor Memory Usage**
   ```lua
   # Check memory in client console
   print('Memory: ' .. collectgarbage('count') .. ' KB')
   ```

3. **Force Garbage Collection**
   ```lua
   collectgarbage('collect')
   ```

### Problem: Update Rate Too High

**Symptoms:**
- Constant flickering
- High CPU usage

**Solutions:**

1. **Adjust Update Intervals**
   ```lua
   Config.Performance = {
       statusUpdateRate = 1000,    -- 1 second
       vehicleUpdateRate = 100,    -- 100ms
       minimapUpdateRate = 500     -- 500ms
   }
   ```

2. **Use Event-Driven Updates**
   ```lua
   # Instead of constant polling
   RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
       TriggerEvent('hud:updateStatus', val.metadata)
   end)
   ```

---

## 🧩 Component Issues

### Problem: Status Bars Not Updating

**Symptoms:**
- Health/armor bars stuck at same value
- No visual feedback on status changes

**Solutions:**

1. **Check Event Registration**
   ```lua
   # Verify event is properly registered
   AddEventHandler('hud:updateStatus', function(data)
       print('Status update received:', json.encode(data))
   end)
   ```

2. **Validate Data Format**
   ```lua
   # Correct format:
   TriggerEvent('hud:updateStatus', {
       health = 85,    -- 0-100
       armor = 100,    -- 0-100
       hunger = 67,    -- 0-100
       thirst = 45     -- 0-100
   })
   ```

3. **Test Manual Update**
   ```lua
   # Force update in client console
   ComponentManager.updateComponent('StatusBars', {
       health = 50,
       armor = 75
   })
   ```

### Problem: Minimap Not Visible

**Symptoms:**
- Black square where minimap should be
- Minimap completely missing

**Solutions:**

1. **Check Minimap Settings**
   ```lua
   # Reset minimap
   SetRadarZoom(1000)
   DisplayRadar(true)
   ```

2. **Verify Component Registration**
   ```lua
   # Check if component exists
   local minimap = ComponentManager.get('Minimap')
   print('Minimap component:', minimap)
   ```

3. **Force Minimap Refresh**
   ```lua
   TriggerEvent('hud:component:refresh', 'Minimap')
   ```

### Problem: Speedometer Showing Wrong Values

**Symptoms:**
- Speed displays as 0 while driving
- Incorrect speed units (km/h vs mph)

**Solutions:**

1. **Check Vehicle Detection**
   ```lua
   # Test vehicle detection
   local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
   print('Vehicle:', vehicle)
   ```

2. **Verify Speed Calculation**
   ```lua
   # Manual speed test
   local speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6
   print('Speed (km/h):', speed)
   ```

3. **Fix Unit Conversion**
   ```lua
   Config.Speedometer.unit = 'kmh'  -- or 'mph'
   ```

---

## 🎨 Theme Problems

### Problem: Theme Not Applying

**Symptoms:**
- Theme change command runs but no visual change
- Colors remain default

**Solutions:**

1. **Verify Theme Registration**
   ```lua
   # Check available themes
   local themes = ThemeManager.getAvailableThemes()
   print('Available themes:', json.encode(themes))
   ```

2. **Test Theme Switch**
   ```lua
   # Force theme application
   ThemeManager.setTheme('neon')
   ThemeManager.applyTheme()
   ```

3. **Check CSS Loading**
   ```lua
   # Verify CSS file exists
   -- html/css/themes/neon.css
   ```

### Problem: Custom Theme Colors Wrong

**Symptoms:**
- Custom colors not displaying correctly
- Some elements using default colors

**Solutions:**

1. **Validate CSS Variables**
   ```css
   /* Check CSS custom properties */
   .hud-container {
       --primary-color: #00ffff;
       --secondary-color: #a020f0;
   }
   ```

2. **Test Color Format**
   ```lua
   # Use proper color formats
   colors = {
       primary = '#00ffff',              -- Hex
       secondary = 'rgb(160, 32, 240)',  -- RGB
       background = 'rgba(0, 0, 0, 0.8)' -- RGBA
   }
   ```

3. **Force Theme Reload**
   ```lua
   ThemeManager.reloadTheme('custom_theme')
   ```

---

## 🔄 Integration Conflicts

### Problem: Conflicting HUD Resources

**Symptoms:**
- Multiple HUDs visible simultaneously
- UI elements overlapping

**Solutions:**

1. **Check for Conflicting Resources**
   ```bash
   # Look for other HUD resources
   status | grep -i hud
   ```

2. **Disable Conflicting Resources**
   ```bash
   # In server console
   stop other-hud-resource
   ```

3. **Set Z-Index Priority**
   ```css
   .hud-container {
       z-index: 1000 !important;
   }
   ```

### Problem: QBCore Integration Issues

**Symptoms:**
- Player data not syncing
- Status values not updating from QBCore

**Solutions:**

1. **Check QBCore Events**
   ```lua
   # Test QBCore player data
   local PlayerData = QBCore.Functions.GetPlayerData()
   print('Player metadata:', json.encode(PlayerData.metadata))
   ```

2. **Verify Event Handlers**
   ```lua
   # Ensure proper event registration
   RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
       if val.metadata then
           TriggerEvent('hud:updateStatus', val.metadata)
       end
   end)
   ```

3. **Test Manual Trigger**
   ```lua
   # Force player data reload
   TriggerServerEvent('QBCore:UpdatePlayer')
   ```

---

## 🗄️ Database Issues

### Problem: Settings Not Saving

**Symptoms:**
- HUD settings reset after relog
- Theme preferences not persisting

**Solutions:**

1. **Check Database Table**
   ```sql
   -- Verify table exists
   SHOW TABLES LIKE 'hud_settings';
   
   -- Check table structure
   DESCRIBE hud_settings;
   ```

2. **Test Database Connection**
   ```lua
   # Test MySQL query
   MySQL.query('SELECT 1 as test', {}, function(result)
       print('Database test:', json.encode(result))
   end)
   ```

3. **Verify MySQL Wrapper**
   ```lua
   # Check MySQL resource
   print('MySQL Resource:', GetResourceState('oxmysql'))
   ```

### Problem: Data Corruption

**Symptoms:**
- Invalid data in database
- HUD fails to load saved settings

**Solutions:**

1. **Reset Player HUD Data**
   ```sql
   DELETE FROM hud_settings WHERE citizenid = 'PLAYER_ID';
   ```

2. **Backup and Restore**
   ```sql
   -- Create backup
   CREATE TABLE hud_settings_backup AS SELECT * FROM hud_settings;
   
   -- Restore from backup
   INSERT INTO hud_settings SELECT * FROM hud_settings_backup;
   ```

3. **Validate Data Format**
   ```lua
   # Check data format
   local function validateHudData(data)
       if type(data) ~= 'table' then
           return false, 'Data must be table'
       end
       return true, 'Valid'
   end
   ```

---

## 💻 Client-Side Problems

### Problem: JavaScript Errors in NUI

**Error:** `"Cannot read property of undefined"`

**Solutions:**

1. **Check Browser Console (F12)**
   - Look for specific error line numbers
   - Check if required functions exist

2. **Validate JSON Data**
   ```javascript
   // Add error checking
   window.addEventListener('message', function(event) {
       try {
           const data = event.data;
           if (data && data.action) {
               handleAction(data);
           }
       } catch (error) {
           console.error('NUI Error:', error);
       }
   });
   ```

3. **Test NUI Communication**
   ```lua
   # Test basic NUI message
   SendNUIMessage({
       action = 'test',
       data = { message = 'Hello World' }
   })
   ```

### Problem: Events Not Firing

**Symptoms:**
- No response to HUD commands
- Events appear to be ignored

**Solutions:**

1. **Check Event Registration**
   ```lua
   # Verify event is registered
   AddEventHandler('hud:show', function()
       print('HUD show event triggered')
   end)
   ```

2. **Test Event Triggering**
   ```lua
   # Manual event test
   TriggerEvent('hud:show')
   ```

3. **Check Resource State**
   ```lua
   # Ensure resource is started
   if GetResourceState('qb-advanced-hud') ~= 'started' then
       print('Resource not started')
   end
   ```

---

## 🖥️ Server-Side Problems

### Problem: Server Console Errors

**Error:** `"attempt to index a nil value (global 'MySQL')"`

**Solutions:**

1. **Check MySQL Wrapper**
   ```lua
   # Add proper MySQL initialization
   local MySQL = exports['oxmysql']
   
   # Or conditional loading
   if GetResourceState('oxmysql') == 'started' then
       MySQL = exports.oxmysql
   else
       print('MySQL wrapper not found')
   end
   ```

2. **Verify Export Availability**
   ```lua
   # Test export
   local success, result = pcall(function()
       return exports.oxmysql
   end)
   
   if not success then
       print('MySQL export not available')
   end
   ```

### Problem: Player Data Not Syncing

**Symptoms:**
- Server data differs from client data
- Status updates not reflecting on HUD

**Solutions:**

1. **Check Server Events**
   ```lua
   # Test server event registration
   RegisterServerEvent('hud:server:updateStatus')
   AddEventHandler('hud:server:updateStatus', function(data)
       print('Server received status update:', json.encode(data))
   end)
   ```

2. **Verify Player Source**
   ```lua
   # Check player source validity
   local Player = QBCore.Functions.GetPlayer(source)
   if not Player then
       print('Invalid player source:', source)
       return
   end
   ```

---

## 🛠️ Debug Tools

### Enable Debug Mode

```lua
# Client-side debug
Config.Debug.enabled = true
Config.Debug.level = 'verbose'

# Console debug commands
TriggerEvent('hud:debug:enable')
TriggerEvent('hud:debug:components')
TriggerEvent('hud:debug:performance')
```

### Debug Console Commands

```lua
# Component status
TriggerEvent('hud:debug:listComponents')

# Performance metrics
TriggerEvent('hud:debug:performance')

# Configuration dump
TriggerEvent('hud:debug:config')

# Event history
TriggerEvent('hud:debug:events')
```

### Performance Monitor

```lua
# Enable performance monitoring
local PerformanceMonitor = {
    enabled = true,
    metrics = {},
    
    start = function(name)
        if not PerformanceMonitor.enabled then return end
        PerformanceMonitor.metrics[name] = GetGameTimer()
    end,
    
    stop = function(name)
        if not PerformanceMonitor.enabled then return end
        local startTime = PerformanceMonitor.metrics[name]
        if startTime then
            local duration = GetGameTimer() - startTime
            print(name .. ' took: ' .. duration .. 'ms')
        end
    end
}

# Usage
PerformanceMonitor.start('component_update')
ComponentManager.updateComponent('StatusBars', data)
PerformanceMonitor.stop('component_update')
```

### Memory Monitoring

```lua
# Monitor memory usage
Citizen.CreateThread(function()
    while true do
        if Config.Debug.enabled then
            local memory = collectgarbage('count')
            if memory > 50000 then  -- 50MB threshold
                print('⚠️ High memory usage: ' .. memory .. ' KB')
            end
        end
        Citizen.Wait(30000)  -- Check every 30 seconds
    end
end)
```

---

## ❌ Common Error Messages

### "attempt to call a nil value"

**Cause:** Function or method doesn't exist
**Solution:**
```lua
# Add nil checks
if ComponentManager and ComponentManager.updateComponent then
    ComponentManager.updateComponent('StatusBars', data)
else
    print('ComponentManager not available')
end
```

### "attempt to index a nil value"

**Cause:** Trying to access property of nil object
**Solution:**
```lua
# Add existence checks
if data and data.health then
    -- Process health data
end
```

### "stack overflow"

**Cause:** Infinite recursion or loop
**Solution:**
```lua
# Add recursion protection
local function safeFunction(data, depth)
    depth = depth or 0
    if depth > 10 then
        print('Max recursion depth reached')
        return
    end
    -- Function logic
end
```

### "too many arguments"

**Cause:** Function called with wrong number of parameters
**Solution:**
```lua
# Check function signature
-- Wrong:
ComponentManager.updateComponent('StatusBars', data, extra, params)

-- Correct:
ComponentManager.updateComponent('StatusBars', data)
```

---

## 🔬 Advanced Diagnostics

### Network Diagnostic

```lua
# Check network events
local NetworkDiagnostic = {
    sentEvents = {},
    receivedEvents = {},
    
    logSent = function(eventName, data)
        table.insert(NetworkDiagnostic.sentEvents, {
            event = eventName,
            data = data,
            time = GetGameTimer()
        })
    end,
    
    logReceived = function(eventName, data)
        table.insert(NetworkDiagnostic.receivedEvents, {
            event = eventName,
            data = data,
            time = GetGameTimer()
        })
    end,
    
    report = function()
        print('Sent events:', #NetworkDiagnostic.sentEvents)
        print('Received events:', #NetworkDiagnostic.receivedEvents)
    end
}
```

### Component Health Check

```lua
function DiagnoseComponent(componentName)
    local component = ComponentManager.get(componentName)
    
    if not component then
        print('❌ Component not found: ' .. componentName)
        return false
    end
    
    local health = {
        exists = true,
        visible = component.visible or false,
        element = component.element and true or false,
        methods = {
            show = type(component.show) == 'function',
            hide = type(component.hide) == 'function',
            update = type(component.update) == 'function'
        }
    }
    
    print('Component Health Report for ' .. componentName .. ':')
    print(json.encode(health, {indent = true}))
    
    return health
end
```

### System State Dump

```lua
function DumpSystemState()
    local state = {
        initialized = HudManager.isInitialized(),
        components = ComponentManager.getAll(),
        theme = ThemeManager.getTheme(),
        config = Config,
        performance = PerformanceMonitor.getMetrics(),
        memory = collectgarbage('count')
    }
    
    -- Save to file or print
    SaveResourceFile(GetCurrentResourceName(), 'debug_dump.json', 
                     json.encode(state, {indent = true}))
    
    print('System state dumped to debug_dump.json')
end
```

---

## 🆘 Emergency Recovery

### Complete System Reset

```lua
# Emergency reset command
RegisterCommand('hud_emergency_reset', function()
    print('🚨 Performing emergency HUD reset...')
    
    -- 1. Stop all components
    ComponentManager.stopAll()
    
    -- 2. Clear all data
    SendNUIMessage({action = 'reset'})
    
    -- 3. Reset configuration
    Config.reset()
    
    -- 4. Restart system
    Citizen.Wait(1000)
    HudManager.initialize()
    
    print('✅ Emergency reset completed')
end, false)
```

### Safe Mode

```lua
# Boot in safe mode
function BootSafeMode()
    Config.Performance.mode = 'low'
    Config.Animation.enabled = false
    Config.Theme.default = 'minimal'
    
    -- Only load essential components
    local safeComponents = {'StatusBars', 'Minimap'}
    ComponentManager.loadOnly(safeComponents)
    
    print('🛡️ HUD started in safe mode')
end
```

---

## 📞 Getting Help

### Information to Provide

When reporting issues, please include:

1. **Error Messages** - Complete error text from console
2. **Server Information** - FiveM version, QBCore version
3. **Resource Version** - HUD system version
4. **Reproduction Steps** - How to recreate the issue
5. **Configuration** - Relevant config settings
6. **Other Resources** - List of other HUD/UI resources

### Debug Information Collection

```lua
# Run this command to collect debug info
RegisterCommand('hud_debug_info', function()
    local debugInfo = {
        timestamp = os.date('%Y-%m-%d %H:%M:%S'),
        resource_version = GetResourceMetadata(GetCurrentResourceName(), 'version'),
        fivem_version = GetGameBuildNumber(),
        qbcore_version = QBCore.Config.Server.CheckUpdate and 'Latest' or 'Unknown',
        components = ComponentManager.getAll(),
        config = Config,
        performance = PerformanceMonitor.getMetrics(),
        errors = ErrorLogger.getRecentErrors()
    }
    
    SaveResourceFile(GetCurrentResourceName(), 'debug_info.json', 
                     json.encode(debugInfo, {indent = true}))
    
    print('🔍 Debug information saved to debug_info.json')
    print('Please include this file when reporting issues')
end, false)
```

### Community Support

- **Discord:** [QBCore Community](https://discord.gg/qbcore)
- **GitHub Issues:** [Report Bugs](https://github.com/qbcore/qb-advanced-hud/issues)
- **Documentation:** [Full Documentation](README.md)

---

## 🎯 Prevention Tips

1. **Regular Updates** - Keep the HUD system updated
2. **Backup Configurations** - Save working configurations
3. **Test Changes** - Always test on development server first
4. **Monitor Performance** - Use performance monitoring tools
5. **Clean Installations** - Avoid modifying core files
6. **Resource Management** - Don't run conflicting resources
7. **Database Maintenance** - Regular database cleanup

---

*Need more help? Check our [Discord community](https://discord.gg/qbcore) or [create an issue](https://github.com/qbcore/qb-advanced-hud/issues) on GitHub!*

---

*Last Updated: August 2025*