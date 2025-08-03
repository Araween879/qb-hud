--[[
    🔧 Enhanced HUD - Advanced Configuration Example
    
    This configuration includes advanced features and fine-tuning options.
    Recommended for experienced server administrators who want full control.
    
    ⚠️ Warning: Some settings may impact performance or stability.
    Only modify settings you understand!
    
    🎯 Advanced Features:
    - Custom update intervals per system
    - Advanced theme customization
    - Performance monitoring
    - Custom integrations
    - Advanced security settings
    - Detailed logging configuration
    - Custom notification systems
--]]

Config = {}

-- ================================
-- 🏗️ ADVANCED ARCHITECTURE
-- ================================

Config.ServerInfo = {
    Name = "Advanced Gaming Server",
    Environment = "production",            -- "development", "staging", "production"
    Region = "US-WEST",                   -- For performance optimization
    MaxPlayers = 128,                     -- Used for scaling calculations
    Version = "3.1.0-advanced"
}

Config.Debug = {
    Enabled = false,                      -- Master debug toggle
    Level = "INFO",                       -- "DEBUG", "INFO", "WARN", "ERROR"
    LogToFile = true,                     -- Log to server files
    LogToConsole = true,                  -- Log to server console
    LogToPlayer = false,                  -- Log to player console (admin only)
    PerformanceMonitoring = true,         -- Monitor system performance
    DetailedErrors = true                 -- Show detailed error information
}

-- ================================
-- ⚡ PERFORMANCE OPTIMIZATION
-- ================================

Config.Performance = {
    -- Dynamic performance scaling
    DynamicScaling = {
        Enabled = true,
        PlayerThresholds = {
            Low = 16,                     -- < 16 players: High performance
            Medium = 32,                  -- 16-32 players: Medium performance  
            High = 64                     -- > 32 players: Optimized performance
        },
        AutoAdjust = true                 -- Automatically adjust based on player count
    },
    
    -- Update intervals (milliseconds)
    UpdateIntervals = {
        Core = 250,                       -- Main HUD system
        Vehicle = 500,                    -- Vehicle systems
        GPS = 1000,                       -- GPS & navigation
        Compass = 333,                    -- Compass (3 FPS)
        Map = 1000,                       -- Map system
        Money = 2000,                     -- Money display
        Stress = 5000,                    -- Stress system
        Status = 200                      -- Status bars
    },
    
    -- Memory management
    Memory = {
        MaxUsage = 100,                   -- MB limit per player
        CleanupInterval = 30000,          -- Memory cleanup frequency
        GarbageCollection = true,         -- Force garbage collection
        CacheLimit = 1000,                -- Max cached items
        PreloadAssets = true              -- Preload common assets
    },
    
    -- Network optimization
    Network = {
        BatchEvents = true,               -- Group network events
        BatchSize = 10,                   -- Events per batch
        BatchDelay = 50,                  -- Delay between batches (ms)
        Compression = true,               -- Compress network data
        Priority = "normal"               -- "low", "normal", "high"
    },
    
    -- Rendering optimization
    Rendering = {
        MaxFPS = 60,                      -- Cap FPS for consistency
        VSync = false,                    -- Disable VSync for better performance
        ReduceAnimations = false,         -- Reduce complex animations
        SimplifyEffects = false,          -- Use simpler visual effects
        LOD = "high"                      -- Level of detail: "low", "medium", "high"
    }
}

-- ================================
-- 🎨 ADVANCED THEME SYSTEM
-- ================================

Config.Themes = {
    -- Theme management
    Default = 'cyberpunk',
    AllowPlayerChange = true,
    SavePlayerChoice = true,
    
    -- Custom themes (extend beyond default 3)
    Custom = {
        neonblue = {
            name = 'neonblue',
            label = 'Neon Blue Protocol',
            description = 'Electric blue aesthetic',
            colors = {
                primary = '#0080ff',
                secondary = '#004080',
                accent = '#40a0ff'
            }
        },
        darkred = {
            name = 'darkred',
            label = 'Dark Red Protocol', 
            description = 'Deep red military aesthetic',
            colors = {
                primary = '#800000',
                secondary = '#400000',
                accent = '#ff4040'
            }
        }
    },
    
    -- Theme effects
    Effects = {
        ParticleCount = 75,               -- Increased particles for advanced systems
        GlowIntensity = 1.5,              -- Stronger glow effects
        AnimationSpeed = 1.0,             -- Animation speed multiplier
        TransitionDuration = 800,         -- Theme transition time (ms)
        CustomCSS = true                  -- Allow custom CSS injection
    },
    
    -- Time-based theme switching
    TimeBasedThemes = {
        Enabled = false,                  -- Automatically change themes by time
        Schedule = {
            ['06:00'] = 'cyberpunk',      -- Morning
            ['12:00'] = 'synthwave',      -- Afternoon
            ['18:00'] = 'matrix',         -- Evening
            ['00:00'] = 'cyberpunk'       -- Night
        }
    }
}

-- ================================
-- 💓 ADVANCED STATUS SYSTEM
-- ================================

Config.StatusSystem = {
    -- Enhanced status monitoring
    Enhanced = {
        Enabled = true,
        PredictiveAlerts = true,          -- Predict critical states
        TrendAnalysis = true,             -- Analyze status trends
        HistoryTracking = true,           -- Track status history
        AnomalyDetection = true           -- Detect unusual patterns
    },
    
    -- Custom status ranges with multiple thresholds
    Ranges = {
        Health = {
            min = 0, max = 100,
            thresholds = {
                critical = 15,            -- Red alert
                low = 30,                 -- Orange warning
                medium = 60,              -- Yellow caution
                high = 85                 -- Green good
            }
        },
        Armor = {
            min = 0, max = 100,
            thresholds = {critical = 20, low = 40, medium = 70, high = 90}
        },
        Hunger = {
            min = 0, max = 100,
            thresholds = {critical = 15, low = 35, medium = 65, high = 85}
        },
        Thirst = {
            min = 0, max = 100,
            thresholds = {critical = 15, low = 35, medium = 65, high = 85}
        },
        Stress = {
            min = 0, max = 100,
            thresholds = {critical = 85, low = 70, medium = 50, high = 30}  -- Inverted
        },
        Stamina = {
            min = 0, max = 100,
            thresholds = {critical = 10, low = 25, medium = 50, high = 75}
        },
        Oxygen = {
            min = 0, max = 100,
            thresholds = {critical = 20, low = 40, medium = 70, high = 90}
        }
    },
    
    -- Status effects and multipliers
    Effects = {
        HealthRegeneration = true,        -- Visual health regeneration
        ArmorDegradation = true,          -- Show armor wear
        HungerEffects = true,             -- Hunger affects other stats
        ThirstEffects = true,             -- Thirst affects other stats
        StressImpact = true,              -- Stress affects performance
        StaminaRecovery = true,           -- Show stamina recovery
        OxygenDrowning = true             -- Oxygen depletion effects
    }
}

-- ================================
-- 🚗 ADVANCED VEHICLE SYSTEM
-- ================================

Config.VehicleSystem = {
    -- Enhanced vehicle detection
    Detection = {
        Method = "advanced",              -- "basic", "advanced", "custom"
        UpdateRate = 100,                 -- Very fast vehicle detection (ms)
        PredictiveLoading = true,         -- Preload vehicle UI
        SmoothTransitions = true          -- Smooth enter/exit animations
    },
    
    -- Advanced speedometer
    Speedometer = {
        Unit = 'mph',                     -- 'mph', 'kmh', 'both'
        Precision = 1,                    -- Decimal places
        MaxSpeed = 300,                   -- Maximum displayable speed
        ColorCoding = true,               -- Color-code by speed
        SpeedLimits = {
            Green = 35,                   -- Under speed limit
            Yellow = 80,                  -- Over speed limit
            Red = 120                     -- Dangerous speed
        }
    },
    
    -- Advanced fuel system
    FuelSystem = {
        Enabled = true,
        Integration = "auto",             -- "auto", "LegacyFuel", "ps-fuel", "cdn-fuel", "ox_fuel"
        LowFuelThreshold = 15,            -- Warning percentage
        CriticalFuelThreshold = 5,        -- Critical percentage
        PredictiveRange = true,           -- Show estimated range
        FuelEfficiency = true,            -- Show fuel efficiency
        RefuelNotifications = true        -- Notify when refueling
    },
    
    -- Engine and vehicle health
    Health = {
        ShowEngineHealth = true,
        ShowBodyHealth = true,
        ShowPetrolTankHealth = true,
        HealthColorCoding = true,
        DamageAlerts = true,
        RepairNotifications = true
    },
    
    -- Racing features
    Racing = {
        ShowNitro = true,
        ShowHarness = true,
        ShowTurbo = true,
        ShowSuspension = true,
        LapTimes = true,
        SpeedRecords = true
    },
    
    -- Vehicle-specific HUD shapes
    Shapes = {
        Car = 'square',
        Motorcycle = 'circle',
        Truck = 'square',
        Boat = 'circle',
        Plane = 'circle',
        Helicopter = 'circle'
    }
}

-- ================================
-- 🧭 ADVANCED GPS & NAVIGATION
-- ================================

Config.GPS = {
    -- Enhanced GPS system
    Enhanced = {
        Enabled = true,
        RealTimeTraffic = false,          -- Traffic simulation (experimental)
        RouteOptimization = true,         -- Optimize routes
        VoiceGuidance = false,            -- Audio directions (requires extra setup)
        OfflineMode = true                -- Work without internet
    },
    
    -- Position and display
    Display = {
        Position = 'top-right',
        Size = 'medium',                  -- 'small', 'medium', 'large'
        AutoShow = true,
        AutoHide = true,
        Transparency = 0.9,
        BorderRadius = 12
    },
    
    -- Navigation features
    Navigation = {
        ShowRoute = true,
        ShowWaypoints = true,
        ShowPOI = true,                   -- Points of Interest
        ShowTraffic = false,              -- Traffic indicators
        ShowSpeedLimits = true,           -- Speed limit signs
        VoiceInstructions = false         -- Audio navigation
    },
    
    -- Map integration
    Map = {
        Provider = "custom",              -- "custom", "google", "mapbox"
        Style = "dark",                   -- "light", "dark", "satellite"
        ZoomLevel = 15,                   -- Default zoom
        CenterOnPlayer = true,
        ShowPlayerIcon = true,
        TrackingMode = "follow"           -- "follow", "free", "compass"
    }
}

-- ================================
-- 🔊 ADVANCED AUDIO SYSTEM
-- ================================

Config.Audio = {
    -- Sound engine
    Engine = "interact-sound",            -- "interact-sound", "custom", "disabled"
    
    -- Master audio settings
    Master = {
        Enabled = true,
        Volume = 0.6,                     -- Global volume multiplier
        Ducking = true,                   -- Lower game audio during notifications
        SpatialAudio = false,             -- 3D positioned audio (experimental)
        AudioQuality = "high"             -- "low", "medium", "high"
    },
    
    -- Sound categories with individual settings
    Categories = {
        UI = {
            Volume = 0.5,
            Enabled = true,
            Sounds = {
                MenuOpen = 'neon_activate',
                MenuClose = 'neon_deactivate',
                ButtonClick = 'ui_click',
                ButtonHover = 'ui_hover',
                ThemeChange = 'synth_transition'
            }
        },
        Alerts = {
            Volume = 0.8,
            Enabled = true,
            Sounds = {
                CriticalHealth = 'critical_beep',
                LowFuel = 'low_fuel_warning',
                StressAlert = 'stress_warning',
                Achievement = 'achievement_sound'
            }
        },
        Vehicle = {
            Volume = 0.4,
            Enabled = true,
            Sounds = {
                EngineStart = 'engine_start',
                EngineStop = 'engine_stop',
                NitroActivate = 'nitro_boost',
                Collision = 'collision_alert'
            }
        }
    },
    
    -- Dynamic audio
    Dynamic = {
        VolumeBasedOnSpeed = true,        -- Adjust volume based on vehicle speed
        EnvironmentalEffects = true,      -- Echo in tunnels, muffled underwater
        AdaptiveEQ = false,               -- Automatic audio equalization
        NoiseGate = true                  -- Remove background noise
    }
}

-- ================================
-- 🛡️ ADVANCED SECURITY
-- ================================

Config.Security = {
    -- Access control
    AccessControl = {
        Enabled = true,
        WhitelistMode = false,            -- Only allow whitelisted players
        BlacklistMode = true,             -- Block blacklisted players
        RateLimiting = true,              -- Prevent spam/abuse
        AntiCheat = true                  -- Basic anti-cheat measures
    },
    
    -- Command permissions
    Commands = {
        AdminRequired = {
            'hudstats', 'hud_debug_all', 'hud_force_update',
            'hud_maintenance', 'hud_backup', 'hud_restore'
        },
        ModeratorRequired = {
            'hud_monitor', 'hud_check_player'
        },
        PlayerAllowed = {
            'hud', 'hudtheme', 'hud_reset', 'hud_debug'
        }
    },
    
    -- Logging and monitoring
    Logging = {
        LogCommands = true,               -- Log all command usage
        LogErrors = true,                 -- Log all errors
        LogPerformance = true,            -- Log performance metrics
        LogSecurity = true,               -- Log security events
        RetentionDays = 30                -- Keep logs for 30 days
    },
    
    -- Data protection
    DataProtection = {
        EncryptSettings = false,          -- Encrypt player settings (experimental)
        GDPR = true,                      -- GDPR compliance features
        DataMinimization = true,          -- Only store necessary data
        RightToDelete = true              -- Allow players to delete their data
    }
}

-- ================================
-- 📊 MONITORING & ANALYTICS
-- ================================

Config.Monitoring = {
    -- Performance monitoring
    Performance = {
        Enabled = true,
        TrackFPS = true,                  -- Monitor FPS impact
        TrackMemory = true,               -- Monitor memory usage
        TrackNetworkLatency = true,       -- Monitor network performance
        TrackUserInteractions = true,     -- Monitor user behavior
        AlertThresholds = {
            FPSDropBelow = 30,            -- Alert if FPS drops below 30
            MemoryAbove = 150,            -- Alert if memory usage above 150MB
            LatencyAbove = 100            -- Alert if latency above 100ms
        }
    },
    
    -- Usage analytics
    Analytics = {
        Enabled = true,
        TrackFeatureUsage = true,         -- Which features are used most
        TrackThemePreferences = true,     -- Popular themes
        TrackPerformanceModes = true,     -- Performance mode usage
        TrackErrors = true,               -- Error patterns
        AnonymousReporting = true         -- Anonymous usage statistics
    },
    
    -- Health monitoring
    HealthCheck = {
        Enabled = true,
        CheckInterval = 60000,            -- Health check every minute
        AutoRestart = false,              -- Auto-restart on critical errors
        NotifyAdmins = true,              -- Notify admins of issues
        FailureThreshold = 5              -- Failures before alert
    }
}

-- ================================
-- 🔄 INTEGRATION SYSTEM
-- ================================

Config.Integrations = {
    -- External resource integration
    Resources = {
        -- Job system integration
        Jobs = {
            Enabled = true,
            ShowJobInfo = true,
            JobSpecificHUD = true,
            SupportedJobs = {
                'police', 'ambulance', 'mechanic', 'taxi', 'reporter'
            }
        },
        
        -- Inventory integration
        Inventory = {
            Enabled = true,
            ShowWeight = true,
            ShowSlots = true,
            Resource = "qb-inventory"     -- "qb-inventory", "ox_inventory", "qs-inventory"
        },
        
        -- Housing integration
        Housing = {
            Enabled = true,
            ShowInHouse = true,
            Resource = "qb-houses"       -- "qb-houses", "ox_housing"
        },
        
        -- Gang integration
        Gangs = {
            Enabled = true,
            ShowGangInfo = true,
            ShowTerritory = true,
            Resource = "qb-gangs"        -- "qb-gangs", "ox_gangs"
        }
    },
    
    -- API endpoints
    API = {
        Enabled = false,                  -- Enable external API
        Authentication = true,            -- Require API authentication
        RateLimit = 100,                  -- Requests per minute
        Endpoints = {
            '/hud/status',                -- Get player HUD status
            '/hud/theme',                 -- Get/set player theme
            '/hud/settings'               -- Get/set player settings
        }
    }
}

-- ================================
-- 📱 MOBILE & ACCESSIBILITY
-- ================================

Config.Accessibility = {
    -- Mobile optimization
    Mobile = {
        Enabled = true,
        TouchOptimized = true,            -- Optimize for touch screens
        LargerButtons = true,             -- Bigger buttons for mobile
        SimplifiedUI = true,              -- Simpler interface
        ReducedAnimations = true,         -- Less animations on mobile
        BatteryOptimization = true        -- Optimize for battery life
    },
    
    -- Accessibility features
    Features = {
        HighContrast = true,              -- High contrast mode
        LargeText = true,                 -- Large text option
        ReducedMotion = true,             -- Reduced motion option
        ColorBlindSupport = true,         -- Color blind friendly
        ScreenReader = false,             -- Screen reader support (experimental)
        KeyboardNavigation = true        -- Navigate with keyboard
    },
    
    -- Language and localization
    Localization = {
        RTL = false,                      -- Right-to-left languages
        CurrencyFormat = "USD",           -- Currency formatting
        DateFormat = "MM/DD/YYYY",        -- Date formatting
        TimeFormat = "12h",               -- "12h" or "24h"
        NumberFormat = "en-US"            -- Number formatting
    }
}

-- ================================
-- 🚀 EXPERIMENTAL FEATURES
-- ================================

Config.Experimental = {
    -- Warning: These features are experimental and may not work properly!
    
    -- AI-powered features
    AI = {
        Enabled = false,                  -- Master toggle for AI features
        PredictiveAnalytics = false,      -- Predict player behavior
        AutoOptimization = false,         -- Automatically optimize settings
        SmartNotifications = false,       -- AI-powered notifications
        PersonalizedUI = false            -- Personalize UI based on usage
    },
    
    -- Advanced graphics
    Graphics = {
        Enabled = false,
        HDR = false,                      -- High Dynamic Range
        RTX = false,                      -- Ray tracing effects (very experimental)
        ParticlePhysics = false,          -- Physics-based particles
        DynamicLighting = false,          -- Dynamic lighting effects
        PostProcessing = false            -- Post-processing effects
    },
    
    -- Cloud features
    Cloud = {
        Enabled = false,
        CloudSave = false,                -- Save settings to cloud
        CrossServerSync = false,          -- Sync across servers
        BackupToCloud = false,            -- Backup to cloud storage
        CloudAnalytics = false            -- Cloud-based analytics
    }
}

-- ================================
-- 📝 CUSTOM SCRIPTING
-- ================================

Config.CustomScripting = {
    -- Custom Lua code execution
    Enabled = false,                      -- Enable custom scripting (dangerous!)
    
    -- Custom event handlers
    Events = {
        OnHUDLoad = nil,                  -- function() end
        OnThemeChange = nil,              -- function(oldTheme, newTheme) end
        OnStatusUpdate = nil,             -- function(statusType, value) end
        OnVehicleEnter = nil,             -- function(vehicle) end
        OnVehicleExit = nil,              -- function(vehicle) end
        OnCriticalStatus = nil            -- function(statusType, value) end
    },
    
    -- Custom calculations
    Calculations = {
        CustomHealthCalc = nil,           -- function(currentHealth) return newHealth end
        CustomStressCalc = nil,           -- function(currentStress) return newStress end
        CustomFuelCalc = nil              -- function(currentFuel) return newFuel end
    }
}

-- ================================
-- ✅ ADVANCED VALIDATION
-- ================================

-- Advanced configuration validation
CreateThread(function()
    Wait(2000)
    
    local errors = {}
    local warnings = {}
    
    -- Validate performance settings
    if Config.Performance.UpdateIntervals.Core < 50 then
        table.insert(warnings, "Very low core update interval may cause performance issues")
    end
    
    -- Validate memory settings
    if Config.Performance.Memory.MaxUsage > 200 then
        table.insert(warnings, "High memory limit may impact server performance")
    end
    
    -- Validate experimental features
    local experimentalEnabled = 0
    for k, v in pairs(Config.Experimental) do
        if type(v) == "table" then
            for _, enabled in pairs(v) do
                if enabled then experimentalEnabled = experimentalEnabled + 1 end
            end
        end
    end
    
    if experimentalEnabled > 0 then
        table.insert(warnings, experimentalEnabled .. " experimental features enabled - use with caution!")
    end
    
    -- Validate integrations
    if Config.Integrations.API.Enabled and not Config.Integrations.API.Authentication then
        table.insert(errors, "API enabled without authentication - security risk!")
    end
    
    -- Report validation results
    if #errors > 0 then
        print("^1[CONFIG ERRORS]^7")
        for _, error in ipairs(errors) do
            print("^1  - " .. error .. "^7")
        end
    end
    
    if #warnings > 0 then
        print("^3[CONFIG WARNINGS]^7")
        for _, warning in ipairs(warnings) do
            print("^3  - " .. warning .. "^7")
        end
    end
    
    if #errors == 0 and #warnings == 0 then
        print("^2[Enhanced HUD]^7 Advanced configuration validated successfully")
    end
end)

--[[
    🎓 ADVANCED CONFIGURATION NOTES:
    
    ⚠️ Performance Impact:
    - Lower update intervals = smoother but more CPU usage
    - Higher particle counts = prettier but more GPU usage
    - More integrations = more features but more memory usage
    
    🔒 Security Considerations:
    - Enable logging in production environments
    - Restrict admin commands appropriately
    - Regular backup of player settings
    
    🧪 Experimental Features:
    - Test thoroughly before enabling in production
    - May cause stability issues
    - Performance impact not fully tested
    
    📊 Monitoring:
    - Check server console regularly for warnings
    - Monitor server performance metrics
    - Review logs for unusual patterns
    
    🔄 Updates:
    - Backup config before updating
    - Check changelog for breaking changes
    - Test new features in development environment first
--]]