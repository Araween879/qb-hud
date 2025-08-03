--[[
    File: config-performance.lua
    Description: Performance-optimized configuration examples for QBCore Advanced HUD System
    Author: QBCore Development Team
    Version: 3.2.0
    
    This file contains pre-configured performance settings for different scenarios:
    - Low-end systems
    - High-performance systems
    - Large server optimization
    - Mobile/streaming optimization
    
    Copy the appropriate configuration to your config.lua file.
]]

-- ========================================
-- Performance Mode Configurations
-- ========================================

--[[
    Ultra Low Performance Mode
    For very low-end systems or servers with 200+ players
    Minimal visual effects, maximum performance
]]
Config.PerformanceMode = {
    UltraLow = {
        -- Core Performance Settings
        Performance = {
            mode = 'ultra_low',
            enableOptimizations = true,
            reducedDrawCalls = true,
            minimalRendering = true,
            
            -- Update Rates (higher = less frequent updates)
            statusUpdateRate = 2000,        -- 2 seconds
            vehicleUpdateRate = 500,        -- 0.5 seconds
            minimapUpdateRate = 1000,       -- 1 second
            timeUpdateRate = 60000,         -- 1 minute
            weatherUpdateRate = 300000,     -- 5 minutes
            
            -- Threading and Processing
            useThreading = false,           -- Disable threading for simplicity
            maxConcurrentUpdates = 1,       -- Process one update at a time
            enableBatching = true,          -- Batch multiple updates
            batchSize = 10,                 -- Process 10 items per batch
            
            -- Memory Management
            aggressiveGC = true,            -- Force garbage collection frequently
            gcInterval = 30000,             -- GC every 30 seconds
            maxMemoryUsage = 50,            -- 50MB limit
            enableMemoryWarnings = true
        },
        
        -- Animation Settings
        Animation = {
            enabled = false,                -- Disable all animations
            fadeTime = 0,                   -- Instant transitions
            slideTime = 0,
            scaleTime = 0,
            enableGPUAcceleration = false,
            useCSS3Animations = false,
            enableTransitionEffects = false
        },
        
        -- Visual Effects
        Visual = {
            enableShadows = false,
            enableGlow = false,
            enableGradients = false,
            enableBlur = false,
            enableParticles = false,
            maxVisualElements = 5,          -- Limit visual complexity
            useSimpleShapes = true,
            reducedColorDepth = true
        },
        
        -- Component Settings
        Components = {
            enableLazyLoading = true,       -- Load components only when needed
            unloadInactive = true,          -- Unload unused components
            maxActiveComponents = 3,        -- Limit active components
            enableComponentCaching = false, -- Disable caching to save memory
            
            -- Individual component settings
            StatusBars = {
                enabled = true,
                animationType = 'none',
                updateRate = 2000,
                simplifiedView = true
            },
            Minimap = {
                enabled = false,            -- Disable minimap for performance
                updateRate = 2000,
                lowDetail = true
            },
            Speedometer = {
                enabled = true,
                updateRate = 1000,
                showOnlySpeed = true,       -- Hide extra information
                simpleDisplay = true
            },
            Vehicle = {
                enabled = false,            -- Disable vehicle HUD
                updateRate = 1000
            },
            Notifications = {
                enabled = true,
                maxNotifications = 1,       -- Only one notification at a time
                duration = 2000,            -- Shorter duration
                simpleStyle = true
            }
        },
        
        -- NUI Optimization
        NUI = {
            enableVirtualization = false,   -- Disable virtual scrolling
            maxDOMElements = 10,            -- Limit DOM complexity
            enableCSSOptimization = true,
            disableTransitions = true,
            useMinimalCSS = true,
            enableHTMLCaching = false
        },
        
        -- Database Optimization
        Database = {
            enableCaching = false,          -- Disable caching to save memory
            batchOperations = true,
            maxConcurrentQueries = 1,
            queryTimeout = 10000,           -- 10 second timeout
            enableQueryOptimization = true
        }
    },
    
    --[[
        Low Performance Mode
        For low-end systems or servers with 100+ players
        Reduced effects, good performance
    ]]
    Low = {
        Performance = {
            mode = 'low',
            enableOptimizations = true,
            reducedDrawCalls = true,
            
            statusUpdateRate = 1000,        -- 1 second
            vehicleUpdateRate = 250,        -- 0.25 seconds
            minimapUpdateRate = 500,        -- 0.5 seconds
            timeUpdateRate = 30000,         -- 30 seconds
            weatherUpdateRate = 180000,     -- 3 minutes
            
            useThreading = true,
            maxConcurrentUpdates = 2,
            enableBatching = true,
            batchSize = 20,
            
            aggressiveGC = true,
            gcInterval = 60000,             -- GC every minute
            maxMemoryUsage = 100,           -- 100MB limit
            enableMemoryWarnings = true
        },
        
        Animation = {
            enabled = true,
            fadeTime = 150,                 -- Fast animations
            slideTime = 100,
            scaleTime = 75,
            enableGPUAcceleration = true,
            useCSS3Animations = true,
            enableTransitionEffects = false -- Disable complex transitions
        },
        
        Visual = {
            enableShadows = false,
            enableGlow = false,
            enableGradients = true,
            enableBlur = false,
            enableParticles = false,
            maxVisualElements = 8,
            useSimpleShapes = true,
            reducedColorDepth = false
        },
        
        Components = {
            enableLazyLoading = true,
            unloadInactive = true,
            maxActiveComponents = 5,
            enableComponentCaching = true,
            
            StatusBars = {
                enabled = true,
                animationType = 'simple',
                updateRate = 1000,
                simplifiedView = false
            },
            Minimap = {
                enabled = true,
                updateRate = 1000,
                lowDetail = true
            },
            Speedometer = {
                enabled = true,
                updateRate = 500,
                showOnlySpeed = false,
                simpleDisplay = false
            },
            Vehicle = {
                enabled = true,
                updateRate = 500
            },
            Notifications = {
                enabled = true,
                maxNotifications = 3,
                duration = 4000,
                simpleStyle = false
            }
        }
    },
    
    --[[
        Medium Performance Mode
        Balanced settings for average systems
        Good visual quality with decent performance
    ]]
    Medium = {
        Performance = {
            mode = 'medium',
            enableOptimizations = true,
            reducedDrawCalls = false,
            
            statusUpdateRate = 500,         -- 0.5 seconds
            vehicleUpdateRate = 100,        -- 0.1 seconds
            minimapUpdateRate = 250,        -- 0.25 seconds
            timeUpdateRate = 15000,         -- 15 seconds
            weatherUpdateRate = 120000,     -- 2 minutes
            
            useThreading = true,
            maxConcurrentUpdates = 4,
            enableBatching = true,
            batchSize = 50,
            
            aggressiveGC = false,
            gcInterval = 120000,            -- GC every 2 minutes
            maxMemoryUsage = 200,           -- 200MB limit
            enableMemoryWarnings = true
        },
        
        Animation = {
            enabled = true,
            fadeTime = 300,
            slideTime = 250,
            scaleTime = 200,
            enableGPUAcceleration = true,
            useCSS3Animations = true,
            enableTransitionEffects = true
        },
        
        Visual = {
            enableShadows = true,
            enableGlow = false,
            enableGradients = true,
            enableBlur = false,
            enableParticles = false,
            maxVisualElements = 12,
            useSimpleShapes = false,
            reducedColorDepth = false
        },
        
        Components = {
            enableLazyLoading = false,
            unloadInactive = false,
            maxActiveComponents = 8,
            enableComponentCaching = true,
            
            StatusBars = {
                enabled = true,
                animationType = 'smooth',
                updateRate = 500,
                simplifiedView = false
            },
            Minimap = {
                enabled = true,
                updateRate = 500,
                lowDetail = false
            },
            Speedometer = {
                enabled = true,
                updateRate = 250,
                showOnlySpeed = false,
                simpleDisplay = false
            },
            Vehicle = {
                enabled = true,
                updateRate = 250
            },
            Notifications = {
                enabled = true,
                maxNotifications = 5,
                duration = 5000,
                simpleStyle = false
            }
        }
    },
    
    --[[
        High Performance Mode
        For high-end systems
        Best visual quality with good performance
    ]]
    High = {
        Performance = {
            mode = 'high',
            enableOptimizations = false,    -- Disable optimizations for quality
            reducedDrawCalls = false,
            
            statusUpdateRate = 250,         -- 0.25 seconds
            vehicleUpdateRate = 50,         -- 0.05 seconds (20fps)
            minimapUpdateRate = 100,        -- 0.1 seconds
            timeUpdateRate = 5000,          -- 5 seconds
            weatherUpdateRate = 60000,      -- 1 minute
            
            useThreading = true,
            maxConcurrentUpdates = 8,
            enableBatching = false,         -- Process immediately
            batchSize = 100,
            
            aggressiveGC = false,
            gcInterval = 300000,            -- GC every 5 minutes
            maxMemoryUsage = 500,           -- 500MB limit
            enableMemoryWarnings = false
        },
        
        Animation = {
            enabled = true,
            fadeTime = 400,
            slideTime = 350,
            scaleTime = 300,
            enableGPUAcceleration = true,
            useCSS3Animations = true,
            enableTransitionEffects = true
        },
        
        Visual = {
            enableShadows = true,
            enableGlow = true,
            enableGradients = true,
            enableBlur = true,
            enableParticles = true,
            maxVisualElements = 20,
            useSimpleShapes = false,
            reducedColorDepth = false
        },
        
        Components = {
            enableLazyLoading = false,
            unloadInactive = false,
            maxActiveComponents = 15,
            enableComponentCaching = true,
            
            StatusBars = {
                enabled = true,
                animationType = 'smooth',
                updateRate = 250,
                simplifiedView = false
            },
            Minimap = {
                enabled = true,
                updateRate = 250,
                lowDetail = false
            },
            Speedometer = {
                enabled = true,
                updateRate = 100,
                showOnlySpeed = false,
                simpleDisplay = false
            },
            Vehicle = {
                enabled = true,
                updateRate = 100
            },
            Notifications = {
                enabled = true,
                maxNotifications = 8,
                duration = 6000,
                simpleStyle = false
            }
        }
    },
    
    --[[
        Ultra High Performance Mode
        For very high-end systems or streaming setups
        Maximum visual quality
    ]]
    Ultra = {
        Performance = {
            mode = 'ultra',
            enableOptimizations = false,
            reducedDrawCalls = false,
            
            statusUpdateRate = 100,         -- 0.1 seconds (10fps)
            vehicleUpdateRate = 16,         -- 0.016 seconds (60fps)
            minimapUpdateRate = 50,         -- 0.05 seconds
            timeUpdateRate = 1000,          -- 1 second
            weatherUpdateRate = 30000,      -- 30 seconds
            
            useThreading = true,
            maxConcurrentUpdates = 16,
            enableBatching = false,
            batchSize = 200,
            
            aggressiveGC = false,
            gcInterval = 600000,            -- GC every 10 minutes
            maxMemoryUsage = 1000,          -- 1GB limit
            enableMemoryWarnings = false
        },
        
        Animation = {
            enabled = true,
            fadeTime = 500,
            slideTime = 450,
            scaleTime = 400,
            enableGPUAcceleration = true,
            useCSS3Animations = true,
            enableTransitionEffects = true
        },
        
        Visual = {
            enableShadows = true,
            enableGlow = true,
            enableGradients = true,
            enableBlur = true,
            enableParticles = true,
            maxVisualElements = 50,
            useSimpleShapes = false,
            reducedColorDepth = false
        },
        
        Components = {
            enableLazyLoading = false,
            unloadInactive = false,
            maxActiveComponents = 25,
            enableComponentCaching = true,
            
            StatusBars = {
                enabled = true,
                animationType = 'advanced',
                updateRate = 100,
                simplifiedView = false
            },
            Minimap = {
                enabled = true,
                updateRate = 100,
                lowDetail = false
            },
            Speedometer = {
                enabled = true,
                updateRate = 50,
                showOnlySpeed = false,
                simpleDisplay = false
            },
            Vehicle = {
                enabled = true,
                updateRate = 50
            },
            Notifications = {
                enabled = true,
                maxNotifications = 12,
                duration = 8000,
                simpleStyle = false
            }
        }
    }
}

-- ========================================
-- Server-Specific Performance Configurations
-- ========================================

--[[
    Large Server Configuration (100+ players)
    Optimized for servers with many concurrent players
]]
Config.LargeServerMode = {
    -- Network Optimization
    Network = {
        enableRateLimiting = true,
        maxUpdatesPerSecond = 10,
        enableUpdateBatching = true,
        batchTimeout = 100,                 -- 100ms batch window
        enableCompression = true,
        compressionLevel = 6,
        
        -- Event Throttling
        enableEventThrottling = true,
        maxEventsPerPlayer = 5,            -- 5 events per second per player
        eventQueueSize = 50,
        
        -- Data Synchronization
        enableDataSync = true,
        syncInterval = 5000,               -- Sync every 5 seconds
        enableDeltaSync = true,            -- Only sync changes
        maxSyncSize = 1024                 -- 1KB max sync packet
    },
    
    -- Database Optimization for Large Servers
    Database = {
        enableConnectionPooling = true,
        maxConnections = 20,
        connectionTimeout = 5000,
        enableQueryQueuing = true,
        maxQueueSize = 1000,
        
        -- Batch Operations
        enableBatchInserts = true,
        batchSize = 100,
        batchTimeout = 2000,
        
        -- Caching Strategy
        enableResultCaching = true,
        cacheSize = 10000,                 -- Cache 10k results
        cacheTimeout = 300000,             -- 5 minute cache
        enableQueryOptimization = true
    },
    
    -- Memory Management for Large Servers
    Memory = {
        enablePlayerDataCaching = true,
        maxCachedPlayers = 200,
        cacheTimeout = 600000,             -- 10 minute timeout
        enableDataCompression = true,
        
        -- Garbage Collection
        aggressiveGC = true,
        gcInterval = 30000,                -- GC every 30 seconds
        enableMemoryMonitoring = true,
        memoryWarningThreshold = 80,       -- Warn at 80% usage
        memoryLimitThreshold = 90          -- Limit at 90% usage
    }
}

--[[
    Streaming/Content Creator Configuration
    Optimized for streaming and recording
]]
Config.StreamingMode = {
    -- Visual Enhancement for Streaming
    Visual = {
        enhancedColors = true,
        increasedContrast = 20,             -- 20% more contrast
        enableColorGrading = true,
        colorProfile = 'streaming',
        
        -- Recording Optimization
        enableRecordingMode = true,
        higherFrameRate = true,
        disableDebugInfo = true,
        cleanInterface = true,
        
        -- Overlay Optimization
        enableOverlayMode = true,
        overlayOpacity = 0.8,
        overlayCompatibility = true
    },
    
    -- Performance for Streaming
    Performance = {
        enableStreamingOptimizations = true,
        prioritizeVisualQuality = true,
        reduceCPUUsage = true,
        enableGPUAcceleration = true,
        
        -- Frame Rate Optimization
        targetFrameRate = 60,
        enableFrameRateLimit = false,
        prioritizeSmoothnness = true
    },
    
    -- Audio/Visual Sync
    Synchronization = {
        enableAVSync = true,
        syncTolerance = 16,                 -- 16ms tolerance
        enableTimestampSync = true,
        audioVisualDelay = 0
    }
}

-- ========================================
-- Development and Testing Configurations
-- ========================================

--[[
    Development Mode Configuration
    For testing and development
]]
Config.DevelopmentMode = {
    -- Debug Settings
    Debug = {
        enabled = true,
        level = 'verbose',
        enableConsoleLogging = true,
        enableFileLogging = true,
        logFilePath = 'debug_hud.log',
        
        -- Performance Monitoring
        enablePerformanceMonitoring = true,
        performanceLogInterval = 10000,    -- Log every 10 seconds
        enableMemoryTracking = true,
        enableFrameTimeTracking = true,
        
        -- Error Handling
        enableDetailedErrors = true,
        enableStackTraces = true,
        enableErrorReporting = true
    },
    
    -- Testing Features
    Testing = {
        enableTestMode = true,
        enableMockData = true,
        enableTestCommands = true,
        enableUITesting = true,
        
        -- Performance Testing
        enableStressTesting = false,
        enableLoadTesting = false,
        enableBenchmarking = true,
        
        -- Debugging Tools
        enableInspector = true,
        enableProfiler = true,
        enableComponentMonitor = true
    },
    
    -- Rapid Development
    Development = {
        enableHotReload = true,
        enableAutoRestart = true,
        enableThemeReload = true,
        enableConfigReload = true,
        
        -- Build Optimization
        enableMinification = false,
        enableSourceMaps = true,
        enableLiveReload = true
    }
}

-- ========================================
-- Automatic Performance Detection
-- ========================================

--[[
    Auto-detect optimal performance settings based on system
]]
Config.AutoPerformanceDetection = {
    enabled = true,
    
    -- Detection Criteria
    detection = {
        enableSystemDetection = true,
        enablePlayerCountDetection = true,
        enableFrameRateDetection = true,
        enableMemoryDetection = true,
        
        -- Thresholds
        lowEndMemoryThreshold = 4096,      -- 4GB RAM
        lowEndPlayerThreshold = 64,        -- 64 players
        lowEndFrameThreshold = 30,         -- 30 FPS
        
        highEndMemoryThreshold = 16384,    -- 16GB RAM
        highEndPlayerThreshold = 32,       -- 32 players
        highEndFrameThreshold = 60         -- 60 FPS
    },
    
    -- Auto-adjustment
    adjustment = {
        enableAutoAdjustment = true,
        adjustmentInterval = 60000,        -- Check every minute
        enableAdaptiveSettings = true,
        
        -- Performance Targets
        targetFrameRate = 60,
        minimumFrameRate = 30,
        targetMemoryUsage = 70,            -- 70% max memory usage
        
        -- Auto-scaling
        enableComponentScaling = true,
        enableVisualScaling = true,
        enableUpdateRateScaling = true
    }
}

-- ========================================
-- Performance Monitoring Configuration
-- ========================================

--[[
    Comprehensive performance monitoring
]]
Config.PerformanceMonitoring = {
    enabled = true,
    
    -- Monitoring Metrics
    metrics = {
        enableFrameRateMonitoring = true,
        enableMemoryMonitoring = true,
        enableCPUMonitoring = true,
        enableNetworkMonitoring = true,
        
        -- Collection Intervals
        frameRateInterval = 1000,          -- Check FPS every second
        memoryInterval = 5000,             -- Check memory every 5 seconds
        cpuInterval = 10000,               -- Check CPU every 10 seconds
        networkInterval = 5000,            -- Check network every 5 seconds
        
        -- Data Retention
        retentionPeriod = 300000,          -- Keep 5 minutes of data
        maxDataPoints = 1000,              -- Max 1000 data points
        enableDataExport = true
    },
    
    -- Alerting
    alerts = {
        enableAlerts = true,
        
        -- Thresholds
        lowFrameRateThreshold = 25,        -- Alert below 25 FPS
        highMemoryThreshold = 80,          -- Alert above 80% memory
        highCPUThreshold = 90,             -- Alert above 90% CPU
        highNetworkLatency = 100,          -- Alert above 100ms latency
        
        -- Alert Actions
        enableAutoOptimization = true,
        enableUserNotification = false,
        enableLogging = true
    },
    
    -- Reporting
    reporting = {
        enablePerformanceReports = true,
        reportInterval = 3600000,          -- Generate report every hour
        enableExportToFile = true,
        reportFormat = 'json',
        
        -- Report Content
        includeFrameRateStats = true,
        includeMemoryStats = true,
        includeCPUStats = true,
        includeNetworkStats = true,
        includeUserStats = true
    }
}

-- ========================================
-- Configuration Helper Functions
-- ========================================

--[[
    Helper functions to apply performance configurations
]]
local PerformanceConfigHelper = {
    -- Apply a specific performance mode
    applyPerformanceMode = function(mode)
        local modeConfig = Config.PerformanceMode[mode]
        if not modeConfig then
            print('[ERROR] Unknown performance mode: ' .. tostring(mode))
            return false
        end
        
        -- Apply the configuration
        for category, settings in pairs(modeConfig) do
            for key, value in pairs(settings) do
                Config.set(category .. '.' .. key, value)
            end
        end
        
        print('[INFO] Applied performance mode: ' .. mode)
        return true
    end,
    
    -- Auto-detect and apply optimal settings
    autoDetectAndApply = function()
        if not Config.AutoPerformanceDetection.enabled then
            return
        end
        
        local detection = Config.AutoPerformanceDetection.detection
        local mode = 'medium' -- Default
        
        -- Simple detection logic (expand as needed)
        local playerCount = GetNumberOfPlayers()
        
        if playerCount > detection.lowEndPlayerThreshold then
            mode = 'low'
        elseif playerCount < detection.highEndPlayerThreshold then
            mode = 'high'
        end
        
        PerformanceConfigHelper.applyPerformanceMode(mode)
        print('[INFO] Auto-detected performance mode: ' .. mode)
    end,
    
    -- Get current performance metrics
    getCurrentMetrics = function()
        return {
            frameRate = GetFrameTime() and (1.0 / GetFrameTime()) or 0,
            memoryUsage = collectgarbage('count'),
            playerCount = GetNumberOfPlayers(),
            resourceCount = GetNumResources()
        }
    end,
    
    -- Validate configuration
    validateConfig = function(config)
        local required = {
            'Performance.mode',
            'Animation.enabled',
            'Components.StatusBars.enabled'
        }
        
        for _, path in ipairs(required) do
            local value = Config.get(path)
            if value == nil then
                print('[WARN] Missing required config: ' .. path)
                return false
            end
        end
        
        return true
    end
}

-- ========================================
-- Export Performance Helper
-- ========================================

-- Export helper functions for other scripts
exports('applyPerformanceMode', PerformanceConfigHelper.applyPerformanceMode)
exports('autoDetectPerformance', PerformanceConfigHelper.autoDetectAndApply)
exports('getCurrentMetrics', PerformanceConfigHelper.getCurrentMetrics)
exports('validateConfig', PerformanceConfigHelper.validateConfig)

-- ========================================
-- Initialize Performance Configuration
-- ========================================

Citizen.CreateThread(function()
    -- Wait for main config to load
    Citizen.Wait(1000)
    
    -- Apply auto-detection if enabled
    if Config.AutoPerformanceDetection and Config.AutoPerformanceDetection.enabled then
        PerformanceConfigHelper.autoDetectAndApply()
    end
    
    -- Start monitoring if enabled
    if Config.PerformanceMonitoring and Config.PerformanceMonitoring.enabled then
        PerformanceMonitor.initialize()
    end
    
    print('[INFO] Performance configuration system initialized')
end)

print('[INFO] Performance configuration examples loaded')
print('[INFO] Available modes: UltraLow, Low, Medium, High, Ultra')
print('[INFO] Use exports to apply performance modes programmatically')