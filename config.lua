--[[
    Enhanced HUD System - Main Configuration
    Based on our config-basic.lua and config-advanced.lua
    Optimized for the Enhanced Structure with hud-core.lua
]]

Config = {}

--[[
    🎮 Framework Integration
]]
Config.Framework = {
    type = 'qbcore',                    -- 'qbcore', 'esx', 'custom'
    autoDetect = true,                  -- Auto-detect framework
    checkForUpdates = true,
    enableIntegration = true,
    
    -- QBCore specific settings
    qbcore = {
        playerDataEvent = 'QBCore:Player:SetPlayerData',
        playerLoadedEvent = 'QBCore:Client:OnPlayerLoaded',
        jobUpdateEvent = 'QBCore:Client:OnJobUpdate'
    }
}

--[[
    🎨 Theme System (Enhanced from our THEMES.md)
]]
Config.Theme = {
    default = 'cyberpunk',              -- Default theme
    allowUserChange = true,             -- Allow players to change themes
    saveUserPreference = true,          -- Save to database
    enableHotSwap = true,               -- Runtime theme switching
    preloadThemes = {                   -- Preload these themes
        'cyberpunk',
        'synthwave', 
        'matrix',
        'minimal'
    },
    
    -- Theme loading
    enableThemeCache = true,
    cacheTimeout = 600000,              -- 10 minutes
    validateOnLoad = true
}

--[[
    ⚡ Performance System (From our config-performance.lua)
]]
Config.Performance = {
    mode = 'auto',                      -- 'auto', 'low', 'medium', 'high', 'ultra'
    enableOptimizations = true,
    autoDetectPerformance = true,
    
    -- Update intervals (from hud-core.lua pattern)
    updateIntervals = {
        critical = 100,                 -- Health, Armor (10 FPS)
        regular = 250,                  -- Hunger, Thirst, Stress (4 FPS)
        slow = 1000,                    -- Oxygen, Stamina (1 FPS)
        vehicle = 100,                  -- Vehicle stats (10 FPS)
        map = 500                       -- Minimap updates (2 FPS)
    },
    
    -- Performance monitoring
    monitoring = {
        enabled = true,
        fpsThreshold = 30,              -- Warn below 30 FPS
        memoryThreshold = 512,          -- Warn above 512MB
        enableAutoOptimization = true
    }
}

--[[
    🧩 Component System (Based on our ComponentManager)
]]
Config.Components = {
    -- Loading strategy
    loadingStrategy = 'progressive',    -- 'immediate', 'lazy', 'progressive'
    enablePreloading = true,
    maxActiveComponents = 15,
    enableComponentCaching = true,
    
    -- Status Bars (Primary component)
    StatusBars = {
        enabled = true,
        position = { x = 20, y = 20 },
        size = { width = 250, height = 100 },
        updateRate = 250,               -- Sync with hud-core.lua regular updates
        animationType = 'smooth',
        
        -- Individual status settings
        health = {
            enabled = true,
            color = '#ff4444',
            warningThreshold = 25,
            criticalThreshold = 10,
            showEffect = true
        },
        armor = {
            enabled = true,
            color = '#00bcd4',
            showWhenZero = false,
            warningThreshold = 25
        },
        hunger = {
            enabled = true,
            color = '#ffb74d',
            warningThreshold = 20,
            criticalThreshold = 10
        },
        thirst = {
            enabled = true,
            color = '#29b6f6',
            warningThreshold = 20,
            criticalThreshold = 10
        },
        stress = {
            enabled = true,
            color = '#a020f0',
            maxValue = 100,
            criticalThreshold = 80,
            showEffects = true,
            enableVisualEffects = true
        },
        stamina = {
            enabled = true,
            color = '#66bb6a',
            showInVehicle = false,
            showWhenFull = false
        },
        oxygen = {
            enabled = true,
            color = '#87ceeb',
            showOnlyUnderwater = true,
            criticalThreshold = 20
        }
    },
    
    -- Minimap
    Minimap = {
        enabled = true,
        position = { x = 20, y = 140 },
        size = { width = 300, height = 200 },
        updateRate = 500,
        borderRadius = 15,
        showStreetNames = true,
        showPlayerBlips = true,
        enableZoom = true,
        zoomLevels = { min = 100, max = 2000, default = 500 }
    },
    
    -- Vehicle Speedometer
    Speedometer = {
        enabled = true,
        position = { x = -20, y = 20 },  -- Right side
        size = { width = 200, height = 150 },
        updateRate = 100,               -- Sync with hud-core.lua fast updates
        unit = 'kmh',                   -- 'kmh', 'mph'
        showGear = true,
        showRPM = true,
        showFuel = true,
        digitalDisplay = false,
        enableEffects = true
    },
    
    -- Notifications
    Notifications = {
        enabled = true,
        position = { x = -20, y = 20 },
        maxNotifications = 5,
        spacing = 10,
        defaultDuration = 5000,
        enableSounds = true,
        enableAnimations = true,
        
        -- Notification types
        types = {
            success = { color = '#4caf50', icon = 'check', duration = 3000 },
            error = { color = '#f44336', icon = 'error', duration = 5000 },
            warning = { color = '#ff9800', icon = 'warning', duration = 4000 },
            info = { color = '#2196f3', icon = 'info', duration = 4000 }
        }
    }
}

--[[
    🎭 Animation System (Enhanced from our Animation config)
]]
Config.Animation = {
    enabled = true,
    globalSpeed = 1.0,
    enableGPUAcceleration = true,
    
    -- Timing functions
    easing = {
        default = 'ease-out',
        smooth = 'cubic-bezier(0.4, 0, 0.2, 1)',
        bounce = 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
        elastic = 'cubic-bezier(0.175, 0.885, 0.32, 1.275)'
    },
    
    -- Durations
    durations = {
        fade = 300,
        slide = 250,
        scale = 200,
        bounce = 400,
        glow = 500
    },
    
    -- Component-specific animations
    components = {
        statusBars = {
            fillAnimation = 'smooth',
            changeAnimation = 'bounce',
            criticalAnimation = 'pulse',
            warningAnimation = 'glow'
        },
        notifications = {
            enterAnimation = 'slideInRight',
            exitAnimation = 'slideOutRight',
            stackAnimation = 'slideDown'
        }
    }
}

--[[
    💾 Database System (From our hud-persistence.lua)
]]
Config.Database = {
    enabled = true,
    
    -- Connection
    type = 'oxmysql',                   -- 'oxmysql', 'ghmattimysql'
    
    -- Tables
    tables = {
        playerSettings = 'hud_player_settings',
        customThemes = 'hud_custom_themes'
    },
    
    -- Settings to save
    saveSettings = {
        'theme',
        'performanceMode',
        'componentVisibility',
        'positions',
        'customization'
    },
    
    -- Auto-save
    autoSave = true,
    autoSaveInterval = 300000,          -- 5 minutes
    
    -- Backup
    enableBackup = true,
    backupInterval = 86400000           -- 24 hours
}

--[[
    🔊 Audio System
]]
Config.Audio = {
    enabled = true,
    volume = 0.5,                       -- 0.0 - 1.0
    
    sounds = {
        criticalAlert = 'critical_beep.ogg',
        notification = 'digital_blip.ogg',
        themeChange = 'synth_transition.ogg',
        menuOpen = 'neon_activate.ogg',
        menuClose = 'airwrench.ogg',
        click = 'shiftyclick.ogg',
        error = 'critical_beep.ogg'
    },
    
    -- Audio settings
    enableSpatialAudio = false,         -- 2D UI sounds
    enableDucking = true,               -- Lower game audio during alerts
    fadeTime = 250
}

--[[
    🌍 Localization (Multi-language support)
]]
Config.Localization = {
    enabled = true,
    defaultLanguage = 'en',
    autoDetectLanguage = true,
    
    -- Available languages
    availableLanguages = {
        'en', 'de', 'fr', 'es', 'nl'
    },
    
    -- Language detection
    detectFrom = 'client'               -- 'client', 'server', 'manual'
}

--[[
    🛠️ Development & Debug (From our debug configs)
]]
Config.Debug = {
    enabled = GetConvar('hud_debug', 'false') == 'true',
    level = 'info',                     -- 'error', 'warn', 'info', 'debug', 'verbose'
    
    -- Logging
    enableConsoleLogging = true,
    enableFileLogging = false,
    
    -- Performance monitoring
    enablePerformanceMonitoring = true,
    enableMemoryTracking = true,
    performanceLogInterval = 30000,     -- 30 seconds
    
    -- Testing
    enableTestMode = false,
    enableMockData = false,
    enableTestCommands = true
}

--[[
    🔧 Critical Thresholds (Used by hud-core.lua)
]]
Config.CriticalThreshold = 20           -- Health, Armor, Hunger, Thirst
Config.StressCriticalThreshold = 80     -- Stress (high = bad)
Config.OxygenCriticalThreshold = 30     -- Oxygen

--[[
    📱 NUI Settings
]]
Config.NUI = {
    enableFocus = true,
    enableCursor = false,
    enableKeepInput = false,
    
    -- Vue.js settings
    vue = {
        devMode = Config.Debug.enabled,
        enableVueDevtools = Config.Debug.enabled,
        enableTransitions = true
    },
    
    -- Communication
    maxMessageQueueSize = 100,
    messageTimeout = 5000,
    enableCompression = true
}

--[[
    📊 Vehicle Integration
]]
Config.Vehicle = {
    enabled = true,
    updateRate = 100,                   -- High frequency for smooth speedometer
    
    -- What to show
    showSpeed = true,
    showGear = true,
    showRPM = true,
    showFuel = true,
    showEngine = true,
    showBody = false,                   -- Vehicle damage
    
    -- Units
    speedUnit = 'kmh',                  -- 'kmh', 'mph'
    fuelUnit = 'percentage',            -- 'percentage', 'liters'
    
    -- Visual settings
    enableNeonEffects = true,
    showOnlyInVehicle = true,
    hideWithSeatbelt = false
}

--[[
    🗺️ Map & GPS Integration
]]
Config.Map = {
    enabled = true,
    updateRate = 500,
    
    -- GPS
    enableGPS = true,
    showStreetNames = true,
    showDirection = true,
    enableWaypoints = true,
    
    -- Compass
    enableCompass = true,
    compassPosition = 'top',            -- 'top', 'bottom'
    showDegrees = true
}

--[[
    🔌 Integration Settings (From our integration-examples.lua)
]]
Config.Integration = {
    -- QBCore resources
    enableQBIntegration = true,
    qbResources = {
        'qb-inventory',
        'qb-vehiclekeys',
        'qb-policejob',
        'qb-ambulancejob',
        'pma-voice'
    },
    
    -- Auto-detect integrations
    autoDetectResources = true,
    
    -- Custom integrations
    customIntegrations = {}
}

--[[
    🎮 Keybinds
]]
Config.Keybinds = {
    toggleHUD = 'F1',
    openSettings = 'F9',
    togglePerformanceMode = '',         -- Disabled by default
    resetPositions = '',                -- Disabled by default
    
    -- Enable keybind registration
    enableKeybinds = true,
    enableCustomKeybinds = true
}

--[[
    📋 Exports Configuration
]]
Config.Exports = {
    -- Legacy compatibility (from our qb-hud-compatibility.lua)
    enableLegacyExports = true,
    
    -- Enhanced exports
    enableEnhancedExports = true,
    
    -- Export validation
    validateExports = true
}

print("^2[ENHANCED-HUD]^7 Configuration loaded successfully")