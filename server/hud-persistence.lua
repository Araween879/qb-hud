--[[
    🗄️ Enhanced HUD - Settings Persistence System
    
    Server-side settings storage and management
    Version: 3.1.0
    
    Features:
    - QBCore player data integration
    - MySQL database storage
    - Automatic backup & recovery
    - Settings validation
    - Cross-session persistence
--]]

local QBCore = exports['qb-core']:GetCoreObject()

-- ================================
-- 📊 STORAGE CONFIGURATION
-- ================================

local HudPersistence = {
    -- Storage settings
    tableExists = false,
    backupInterval = 300000, -- 5 minutes
    
    -- Default settings template
    defaultSettings = {
        -- Display Settings
        hudVisible = true,
        showHealth = true,
        showArmor = true,
        showHunger = true,
        showThirst = true,
        showStress = true,
        showStamina = true,
        showOxygen = true,
        hudOpacity = 1.0,
        
        -- Performance Settings
        performanceMode = false,
        animationsEnabled = true,
        debugMode = false,
        
        -- Theme Settings
        currentNeonTheme = 'cyberpunk',
        isNeonGlowChecked = true,
        isNeonAnimationsChecked = true,
        isCriticalAlertsChecked = true,
        isThemeParticlesChecked = true,
        
        -- GPS & Map Settings
        isGpsHudChecked = true,
        gpsHudPosition = 'top-right',
        isOutMapChecked = true,
        isOutCompassChecked = true,
        isCompassFollowChecked = true,
        isMapNotifChecked = true,
        isHideMapChecked = false,
        isToggleMapBordersChecked = true,
        isToggleMapShapeChecked = 'square',
        isCompassShowChecked = true,
        isShowStreetsChecked = true,
        isPointerShowChecked = true,
        isDegreesShowChecked = true,
        
        -- Vehicle Settings
        isDynamicEngineChecked = true,
        isDynamicNitroChecked = true,
        isLowFuelChecked = true,
        
        -- Audio Settings
        isListSoundsChecked = true,
        isResetSoundsChecked = true,
        
        -- Cinematic Settings
        isCinematicNotifChecked = true,
        isCinematicModeChecked = false,
        
        -- Dynamic Settings
        isDynamicHealthChecked = true,
        isDynamicArmorChecked = true,
        isDynamicHungerChecked = true,
        isDynamicThirstChecked = true,
        isDynamicStressChecked = true,
        isDynamicOxygenChecked = true,
        
        -- FPS Settings
        isChangeFPSChecked = true,
        isChangeCompassFPSChecked = true
    }
}

-- ================================
-- 🗄️ DATABASE MANAGEMENT
-- ================================

function HudPersistence:Initialize()
    print("^2[HUD-PERSISTENCE]^7 Initializing settings persistence system...")
    
    -- Create table if not exists
    self:CreateTable()
    
    -- Start backup routine
    self:StartBackupRoutine()
    
    print("^2[HUD-PERSISTENCE]^7 Settings persistence system ready")
end

function HudPersistence:CreateTable()
    local query = [[
        CREATE TABLE IF NOT EXISTS player_hud_settings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL UNIQUE,
            settings JSON NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_citizenid (citizenid)
        )
    ]]
    
    if type(query) == "string" and query ~= "" then
        if GetResourceState('oxmysql') == 'started' then
            exports.oxmysql:execute(query, {}, function(result)
                if result then
                    HudPersistence.tableExists = true
                    print("^2[HUD-PERSISTENCE]^7 Database table ready")
                else
                    print("^1[HUD-PERSISTENCE-ERROR]^7 Failed to create/verify table")
                end
            end)
        else
            print("^3[HUD-PERSISTENCE-WARNING]^7 oxmysql not available - using memory storage")
        end
    else
        print("^1[HUD-PERSISTENCE-ERROR]^7 Invalid table creation query")
    end
end

-- ================================
-- 💾 SETTINGS OPERATIONS
-- ================================

function HudPersistence:LoadPlayerSettings(citizenid, callback)
    if not citizenid or citizenid == "" then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Invalid citizenid for load operation")
        callback(self.defaultSettings)
        return
    end
    
    if GetResourceState('oxmysql') == 'started' and self.tableExists then
        local query = "SELECT settings FROM player_hud_settings WHERE citizenid = ? LIMIT 1"
        
        exports.oxmysql:execute(query, {citizenid}, function(result)
            if result and result[1] and result[1].settings then
                local success, settings = pcall(json.decode, result[1].settings)
                
                if success and type(settings) == "table" then
                    -- Merge with defaults to ensure all keys exist
                    local mergedSettings = self:MergeWithDefaults(settings)
                    callback(mergedSettings)
                    print("^2[HUD-PERSISTENCE]^7 Loaded settings for: " .. citizenid)
                else
                    print("^3[HUD-PERSISTENCE-WARNING]^7 Invalid JSON for " .. citizenid .. ", using defaults")
                    callback(self.defaultSettings)
                end
            else
                print("^3[HUD-PERSISTENCE-INFO]^7 No settings found for " .. citizenid .. ", using defaults")
                callback(self.defaultSettings)
            end
        end)
    else
        print("^3[HUD-PERSISTENCE-WARNING]^7 Database not available, using defaults")
        callback(self.defaultSettings)
    end
end

function HudPersistence:SavePlayerSettings(citizenid, settings, callback)
    if not citizenid or citizenid == "" then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Invalid citizenid for save operation")
        if callback then callback(false) end
        return
    end
    
    if not settings or type(settings) ~= "table" then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Invalid settings data for save operation")
        if callback then callback(false) end
        return
    end
    
    -- Validate settings before saving
    local validatedSettings = self:ValidateSettings(settings)
    
    if GetResourceState('oxmysql') == 'started' and self.tableExists then
        local settingsJson = json.encode(validatedSettings)
        
        local query = [[
            INSERT INTO player_hud_settings (citizenid, settings) 
            VALUES (?, ?) 
            ON DUPLICATE KEY UPDATE 
            settings = VALUES(settings), 
            updated_at = CURRENT_TIMESTAMP
        ]]
        
        exports.oxmysql:execute(query, {citizenid, settingsJson}, function(result)
            local success = result and (result.affectedRows or 0) > 0
            
            if success then
                print("^2[HUD-PERSISTENCE]^7 Saved settings for: " .. citizenid)
            else
                print("^1[HUD-PERSISTENCE-ERROR]^7 Failed to save settings for: " .. citizenid)
            end
            
            if callback then callback(success) end
        end)
    else
        print("^3[HUD-PERSISTENCE-WARNING]^7 Database not available, settings not persisted")
        if callback then callback(false) end
    end
end

function HudPersistence:DeletePlayerSettings(citizenid, callback)
    if not citizenid or citizenid == "" then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Invalid citizenid for delete operation")
        if callback then callback(false) end
        return
    end
    
    if GetResourceState('oxmysql') == 'started' and self.tableExists then
        local query = "DELETE FROM player_hud_settings WHERE citizenid = ?"
        
        exports.oxmysql:execute(query, {citizenid}, function(result)
            local success = result and (result.affectedRows or 0) > 0
            
            if success then
                print("^2[HUD-PERSISTENCE]^7 Deleted settings for: " .. citizenid)
            else
                print("^3[HUD-PERSISTENCE-WARNING]^7 No settings found to delete for: " .. citizenid)
            end
            
            if callback then callback(success) end
        end)
    else
        print("^3[HUD-PERSISTENCE-WARNING]^7 Database not available")
        if callback then callback(false) end
    end
end

-- ================================
-- ✅ VALIDATION SYSTEM
-- ================================

function HudPersistence:ValidateSettings(settings)
    local validated = {}
    
    -- Validate each setting with type checking
    for key, defaultValue in pairs(self.defaultSettings) do
        local userValue = settings[key]
        
        -- Type validation
        if type(userValue) == type(defaultValue) then
            -- Additional validation based on setting type
            if type(defaultValue) == "number" then
                -- Clamp numeric values to reasonable ranges
                if key:find("Opacity") then
                    validated[key] = math.max(0, math.min(1, userValue))
                elseif key:find("FPS") then
                    validated[key] = math.max(1, math.min(60, userValue))
                else
                    validated[key] = userValue
                end
            elseif type(defaultValue) == "string" then
                -- Validate string values
                if key == "currentNeonTheme" then
                    local validThemes = {cyberpunk = true, synthwave = true, matrix = true}
                    validated[key] = validThemes[userValue] and userValue or "cyberpunk"
                elseif key == "gpsHudPosition" then
                    local validPositions = {
                        ['top-right'] = true, ['top-left'] = true,
                        ['bottom-right'] = true, ['bottom-left'] = true
                    }
                    validated[key] = validPositions[userValue] and userValue or "top-right"
                elseif key == "isToggleMapShapeChecked" then
                    local validShapes = {square = true, circle = true}
                    validated[key] = validShapes[userValue] and userValue or "square"
                else
                    validated[key] = userValue
                end
            else
                validated[key] = userValue
            end
        else
            -- Use default if type mismatch
            validated[key] = defaultValue
            print("^3[HUD-PERSISTENCE-WARNING]^7 Type mismatch for setting: " .. key)
        end
    end
    
    return validated
end

function HudPersistence:MergeWithDefaults(userSettings)
    local merged = {}
    
    -- Start with defaults
    for key, value in pairs(self.defaultSettings) do
        merged[key] = value
    end
    
    -- Override with user settings
    for key, value in pairs(userSettings) do
        if self.defaultSettings[key] ~= nil then
            merged[key] = value
        end
    end
    
    return merged
end

-- ================================
-- 🔄 BACKUP SYSTEM
-- ================================

function HudPersistence:StartBackupRoutine()
    if not self.tableExists then return end
    
    SetTimeout(self.backupInterval, function()
        self:CreateBackup()
        self:StartBackupRoutine() -- Recursive scheduling
    end)
end

function HudPersistence:CreateBackup()
    if GetResourceState('oxmysql') ~= 'started' or not self.tableExists then
        return
    end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupQuery = string.format([[
        CREATE TABLE IF NOT EXISTS player_hud_settings_backup_%s 
        AS SELECT * FROM player_hud_settings
    ]], timestamp)
    
    exports.oxmysql:execute(backupQuery, {}, function(result)
        if result then
            print("^2[HUD-PERSISTENCE]^7 Backup created: " .. timestamp)
            
            -- Cleanup old backups (keep last 10)
            self:CleanupOldBackups()
        end
    end)
end

function HudPersistence:CleanupOldBackups()
    local query = [[
        SELECT TABLE_NAME 
        FROM INFORMATION_SCHEMA.TABLES 
        WHERE TABLE_NAME LIKE 'player_hud_settings_backup_%' 
        ORDER BY CREATE_TIME DESC
    ]]
    
    exports.oxmysql:execute(query, {}, function(result)
        if result and #result > 10 then
            -- Delete oldest backups
            for i = 11, #result do
                local dropQuery = "DROP TABLE IF EXISTS " .. result[i].TABLE_NAME
                exports.oxmysql:execute(dropQuery, {})
            end
            print("^2[HUD-PERSISTENCE]^7 Cleaned up old backups")
        end
    end)
end

-- ================================
-- 📊 STATISTICS & MONITORING
-- ================================

function HudPersistence:GetStatistics(callback)
    if not self.tableExists then
        callback({error = "Database not available"})
        return
    end
    
    local query = [[
        SELECT 
            COUNT(*) as total_players,
            AVG(JSON_EXTRACT(settings, '$.hudOpacity')) as avg_opacity,
            COUNT(CASE WHEN JSON_EXTRACT(settings, '$.performanceMode') = true THEN 1 END) as performance_mode_users,
            COUNT(CASE WHEN JSON_EXTRACT(settings, '$.currentNeonTheme') = 'cyberpunk' THEN 1 END) as cyberpunk_users,
            COUNT(CASE WHEN JSON_EXTRACT(settings, '$.currentNeonTheme') = 'synthwave' THEN 1 END) as synthwave_users,
            COUNT(CASE WHEN JSON_EXTRACT(settings, '$.currentNeonTheme') = 'matrix' THEN 1 END) as matrix_users
        FROM player_hud_settings
    ]]
    
    exports.oxmysql:execute(query, {}, function(result)
        if result and result[1] then
            callback(result[1])
        else
            callback({error = "Failed to retrieve statistics"})
        end
    end)
end

-- ================================
-- 🔄 EVENT HANDLERS
-- ================================

RegisterNetEvent('hud:server:loadSettings', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Player not found for settings load")
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    HudPersistence:LoadPlayerSettings(citizenid, function(settings)
        TriggerClientEvent('hud:client:settingsLoaded', src, settings)
    end)
end)

RegisterNetEvent('hud:server:saveSettings', function(settings)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Player not found for settings save")
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    HudPersistence:SavePlayerSettings(citizenid, settings, function(success)
        TriggerClientEvent('hud:client:settingsSaved', src, {success = success})
    end)
end)

RegisterNetEvent('hud:server:resetSettings', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        print("^1[HUD-PERSISTENCE-ERROR]^7 Player not found for settings reset")
        return
    end
    
    local citizenid = Player.PlayerData.citizenid
    
    HudPersistence:SavePlayerSettings(citizenid, HudPersistence.defaultSettings, function(success)
        if success then
            TriggerClientEvent('hud:client:settingsLoaded', src, HudPersistence.defaultSettings)
            TriggerClientEvent('QBCore:Notify', src, "HUD settings reset to defaults", "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Failed to reset HUD settings", "error")
        end
    end)
end)

-- ================================
-- 🎮 PLAYER EVENT HANDLERS
-- ================================

RegisterNetEvent('QBCore:Server:PlayerLoaded', function(Player)
    local src = Player.PlayerData.source
    local citizenid = Player.PlayerData.citizenid
    
    -- Load settings with delay to ensure client is ready
    SetTimeout(2000, function()
        HudPersistence:LoadPlayerSettings(citizenid, function(settings)
            TriggerClientEvent('hud:client:settingsLoaded', src, settings)
        end)
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    -- Could add cleanup logic here if needed
    print("^3[HUD-PERSISTENCE]^7 Player disconnected: " .. src)
end)

-- ================================
-- 📊 ADMIN COMMANDS
-- ================================

QBCore.Commands.Add('hudstats', 'Get HUD usage statistics (Admin Only)', {}, false, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    if not QBCore.Functions.HasPermission(source, 'admin') then
        TriggerClientEvent('QBCore:Notify', source, "No permission", "error")
        return
    end
    
    HudPersistence:GetStatistics(function(stats)
        if stats.error then
            TriggerClientEvent('QBCore:Notify', source, stats.error, "error")
        else
            local message = string.format(
                "HUD Stats: %d players, %.2f avg opacity, %d performance mode, Themes: %d cyberpunk, %d synthwave, %d matrix",
                stats.total_players or 0,
                stats.avg_opacity or 0,
                stats.performance_mode_users or 0,
                stats.cyberpunk_users or 0,
                stats.synthwave_users or 0,
                stats.matrix_users or 0
            )
            TriggerClientEvent('chat:addMessage', source, {
                color = {0, 255, 255},
                multiline = true,
                args = {"HUD System", message}
            })
        end
    end)
end, 'admin')

-- ================================
-- 🚀 INITIALIZATION
-- ================================

-- Initialize the persistence system
CreateThread(function()
    Wait(1000) -- Wait for other resources to load
    HudPersistence:Initialize()
end)

-- Export functions for external access
exports('LoadPlayerSettings', function(citizenid, callback)
    HudPersistence:LoadPlayerSettings(citizenid, callback)
end)

exports('SavePlayerSettings', function(citizenid, settings, callback)
    HudPersistence:SavePlayerSettings(citizenid, settings, callback)
end)

exports('GetDefaultSettings', function()
    return HudPersistence.defaultSettings
end)

print("^2[HUD-PERSISTENCE]^7 Module loaded successfully")