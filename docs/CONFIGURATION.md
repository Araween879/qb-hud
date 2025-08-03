# ⚙️ Enhanced HUD - Configuration Guide

<div align="center">

**🛠️ Complete Configuration & Customization Guide**

*Everything you need to know about configuring Enhanced HUD for your server*

</div>

---

## 📋 **Table of Contents**

- [📋 **Table of Contents**](#-table-of-contents)
- [🚀 **Quick Configuration**](#-quick-configuration)
- [⚙️ **Core Configuration**](#️-core-configuration)
- [🎨 **Theme System Configuration**](#-theme-system-configuration)
- [💓 **Player Status Configuration**](#-player-status-configuration)
- [🚗 **Vehicle System Configuration**](#-vehicle-system-configuration)
- [🧭 **GPS & Navigation Configuration**](#-gps--navigation-configuration)
- [💰 **Money & Economy Configuration**](#-money--economy-configuration)
- [🔊 **Audio System Configuration**](#-audio-system-configuration)
- [📱 **Responsive Design Configuration**](#-responsive-design-configuration)
- [⚡ **Performance Optimization**](#-performance-optimization)
- [🛡️ **Security Configuration**](#️-security-configuration)
- [🌍 **Localization Configuration**](#-localization-configuration)
- [🔧 **Advanced Configuration**](#-advanced-configuration)
- [🎮 **Menu System Configuration**](#-menu-system-configuration)
- [📊 **Monitoring & Analytics**](#-monitoring--analytics)
- [🔗 **Integration Configuration**](#-integration-configuration)
- [📱 **Mobile Configuration**](#-mobile-configuration)
- [🧪 **Experimental Features**](#-experimental-features)
- [✅ **Configuration Validation**](#-configuration-validation)

---

## 🚀 **Quick Configuration**

### 📝 **Basic Setup (5 Minutes)**

For a quick setup with recommended settings:

```lua
Config = {
    -- Server Information
    ServerName = "Your Server Name",
    
    -- Performance (recommended for most servers)
    UpdateInterval = 250,                -- 4 FPS update rate
    ReducedAnimations = false,           -- Keep animations
    HighQualityEffects = true,           -- Enable visual effects
    
    -- Theme
    Themes = {
        Default = 'cyberpunk',           -- cyberpunk, synthwave, matrix
        AllowPlayerChange = true         -- Let players choose
    },
    
    -- Features
    StatusSettings = {
        ShowHealth = true,
        ShowArmor = true,
        ShowHunger = true,
        ShowThirst = true,
        ShowStress = true,
        ShowStamina = true,
        ShowOxygen = true
    },
    
    VehicleSettings = {
        Enabled = true,
        SpeedUnit = 'mph'                -- or 'kmh'
    },
    
    GpsHud = {
        Enabled = true,
        DefaultPosition = 'top-right'
    }
}
```

---

## ⚙️ **Core Configuration**

### 🏗️ **Basic Server Settings**

```lua
Config = {
    -- Server Information
    ServerName = "Your Server Name",
    Version = "3.1.0",                  -- Don't change this
    Debug = false,                      -- Enable for troubleshooting
    
    -- Resource Information
    ResourceName = "enhanced-hud",      -- Resource folder name
    Author = "Your Name",               -- Optional customization
    
    -- Environment
    Environment = "production",         -- "development", "staging", "production"
    LogLevel = "INFO"                   -- "DEBUG", "INFO", "WARN", "ERROR"
}
```

### ⚡ **Performance Settings**

```lua
Config.Performance = {
    -- Update Intervals (milliseconds)
    UpdateInterval = 250,               -- Main HUD update rate
    CriticalUpdateInterval = 100,       -- Critical alerts update rate
    VehicleUpdateInterval = 500,        -- Vehicle systems update rate
    
    -- Visual Effects
    ReducedAnimations = false,          -- Disable animations for performance
    HighQualityEffects = true,          -- Enable advanced visual effects
    ParticleCount = 50,                 -- Number of particle effects (0-100)
    
    -- Memory Management
    MaxMemoryUsage = 50,                -- MB per player limit
    GarbageCollectionInterval = 60000,   -- Memory cleanup frequency
    
    -- Network Optimization
    BatchNetworkEvents = true,          -- Group network calls
    NetworkTimeout = 5000               -- Network timeout (ms)
}
```

### 🔄 **Update System Configuration**

```lua
Config.UpdateSystem = {
    -- Different systems can have different update rates
    Core = 250,                         -- Main HUD elements
    Vehicle = 500,                      -- Vehicle-related elements
    GPS = 1000,                         -- GPS and navigation
    Compass = 333,                      -- Compass (3 FPS)
    Map = 1000,                         -- Map system
    Status = 200,                       -- Status bars
    Money = 2000,                       -- Money display
    
    -- Dynamic adjustment based on server load
    DynamicAdjustment = true,           -- Automatically adjust based on performance
    PerformanceThreshold = 0.8          -- Adjust when performance drops below 80%
}
```

---

## 🎨 **Theme System Configuration**

### 🌈 **Basic Theme Settings**

```lua
Config.Themes = {
    -- Default theme for new players
    Default = 'cyberpunk',              -- 'cyberpunk', 'synthwave', 'matrix'
    
    -- Player customization
    AllowPlayerChange = true,           -- Allow players to change themes
    SavePlayerChoice = true,            -- Remember player's choice
    
    -- Theme effects
    EffectsEnabled = true,              -- Enable theme-specific effects
    AnimationsEnabled = true,           -- Enable theme animations
    ParticlesEnabled = true             -- Enable theme particles
}
```

### 🎭 **Advanced Theme Configuration**

```lua
Config.ThemeSystem = {
    -- Available themes
    AvailableThemes = {
        'cyberpunk',                    -- High-tech cyan and purple
        'synthwave',                    -- Retro-futuristic pink and blue
        'matrix',                       -- Classic green matrix code
        'custom'                        -- Custom themes (if defined)
    },
    
    -- Theme-specific settings
    ThemeSettings = {
        cyberpunk = {
            PrimaryColor = '#00ffff',
            SecondaryColor = '#a020f0',
            AccentColor = '#ff9800',
            EffectIntensity = 1.0
        },
        synthwave = {
            PrimaryColor = '#ff0080',
            SecondaryColor = '#8000ff',
            AccentColor = '#00ffff',
            EffectIntensity = 1.2
        },
        matrix = {
            PrimaryColor = '#00ff00',
            SecondaryColor = '#008000',
            AccentColor = '#ffffff',
            EffectIntensity = 0.8
        }
    },
    
    -- Time-based theme switching (optional)
    TimeBasedThemes = {
        Enabled = false,
        Schedule = {
            ['06:00'] = 'cyberpunk',    -- Morning
            ['12:00'] = 'synthwave',    -- Afternoon
            ['18:00'] = 'matrix',       -- Evening
            ['00:00'] = 'cyberpunk'     -- Night
        }
    }
}
```

### 🎨 **Custom Theme Creation**

```lua
Config.CustomThemes = {
    -- Define custom themes
    darkred = {
        name = 'darkred',
        label = 'Dark Red Protocol',
        description = 'Military-inspired red theme',
        colors = {
            primary = '#800000',
            secondary = '#400000',
            accent = '#ff4040'
        },
        effects = {
            glow = true,
            particles = false,
            scanlines = true
        }
    },
    
    neonblue = {
        name = 'neonblue',
        label = 'Neon Blue Protocol',
        description = 'Electric blue aesthetic',
        colors = {
            primary = '#0080ff',
            secondary = '#004080',
            accent = '#40a0ff'
        }
    }
}
```

---

## 💓 **Player Status Configuration**

### 📊 **Basic Status Settings**

```lua
Config.StatusSettings = {
    -- Which status bars to display
    ShowHealth = true,
    ShowArmor = true,
    ShowHunger = true,
    ShowThirst = true,
    ShowStress = true,
    ShowStamina = true,
    ShowOxygen = true,
    
    -- Critical thresholds (when to show warnings)
    CriticalThreshold = 20,             -- Show warning when below 20%
    
    -- Update frequency
    UpdateFrequency = 1000,             -- Update every 1 second
    
    -- Visual settings
    ShowPercentage = false,             -- Show percentage numbers
    AnimateChanges = true,              -- Animate status changes
    ShowTrends = false                  -- Show increase/decrease arrows
}
```

### 🔧 **Advanced Status Configuration**

```lua
Config.AdvancedStatus = {
    -- Individual status settings
    Health = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 15,
        LowThreshold = 30,
        MediumThreshold = 60,
        HighThreshold = 85,
        ShowRegeneration = true,        -- Show health regeneration
        RegenerationRate = 0.5,         -- Health per second
        Color = '#ff4444'
    },
    
    Armor = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 20,
        ShowDegradation = true,         -- Show armor wear
        DegradationRate = 0.1,          -- Degradation per hit
        Color = '#00ffff'
    },
    
    Hunger = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 15,
        AffectsHealth = true,           -- Low hunger affects health
        HealthImpact = 0.5,             -- Health reduction per minute
        Color = '#ff9800'
    },
    
    Thirst = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 15,
        AffectsStamina = true,          -- Low thirst affects stamina
        StaminaImpact = 0.8,
        Color = '#0080ff'
    },
    
    Stress = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 80,         -- High stress is critical
        AffectsAll = true,              -- Stress affects all stats
        ReductionRate = 0.2,            -- Stress reduction per minute
        Color = '#a020f0'
    },
    
    Stamina = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 10,
        RecoveryRate = 1.0,             -- Stamina recovery per second
        Color = '#00ff80'
    },
    
    Oxygen = {
        Min = 0,
        Max = 100,
        CriticalThreshold = 20,
        DepletionRate = 2.0,            -- Underwater depletion rate
        Color = '#40e0d0'
    }
}
```

### 🎯 **Status Effects System**

```lua
Config.StatusEffects = {
    -- Enable status effect interactions
    Enabled = true,
    
    -- Effect rules
    Effects = {
        -- Low health effects
        LowHealth = {
            Threshold = 25,
            Effects = {
                BlurVision = true,          -- Blur screen when low health
                SlowMovement = true,        -- Reduce movement speed
                ReducedStamina = true       -- Lower stamina regeneration
            }
        },
        
        -- High stress effects
        HighStress = {
            Threshold = 75,
            Effects = {
                ShakeScreen = true,         -- Screen shake
                ReducedAccuracy = true,     -- Lower weapon accuracy
                FasterHeartbeat = true      -- Heartbeat sound effect
            }
        },
        
        -- Dehydration effects
        Dehydration = {
            Threshold = 20,
            Effects = {
                BlurVision = true,
                ReducedStamina = true,
                SlowHealthRegen = true
            }
        }
    }
}
```

---

## 🚗 **Vehicle System Configuration**

### 🚗 **Basic Vehicle Settings**

```lua
Config.VehicleSettings = {
    -- Enable/disable vehicle HUD
    Enabled = true,
    
    -- Speed display
    SpeedUnit = 'mph',                  -- 'mph', 'kmh', or 'both'
    ShowSpeedometer = true,
    MaxDisplaySpeed = 300,              -- Maximum speed to display
    
    -- Fuel system
    ShowFuel = true,
    LowFuelThreshold = 20,              -- Warning percentage
    CriticalFuelThreshold = 5,          -- Critical percentage
    LowFuelAlert = true,
    
    -- Vehicle condition
    ShowEngineHealth = true,
    ShowBodyHealth = false,             -- Show body damage
    ShowPetrolTankHealth = false,       -- Show fuel tank damage
    
    -- Racing features
    ShowNitro = true,
    ShowHarness = true,
    ShowTurbo = false,
    
    -- Update frequency
    UpdateInterval = 500                -- Update every 0.5 seconds
}
```

### 🏎️ **Advanced Vehicle Configuration**

```lua
Config.AdvancedVehicle = {
    -- Vehicle detection
    Detection = {
        Method = "advanced",            -- "basic", "advanced"
        UpdateRate = 100,               -- Very fast detection
        PredictiveLoading = true,       -- Preload vehicle UI
        SmoothTransitions = true        -- Smooth enter/exit
    },
    
    -- Speedometer settings
    Speedometer = {
        Precision = 1,                  -- Decimal places
        ColorCoding = true,             -- Color-code by speed
        SpeedLimits = {
            Green = 35,                 -- Speed limit color thresholds
            Yellow = 80,
            Red = 120
        },
        ShowMaxSpeed = false,           -- Show vehicle's max speed
        ShowAverageSpeed = false        -- Show trip average
    },
    
    -- Fuel system integration
    FuelSystem = {
        Integration = "auto",           -- Auto-detect fuel resource
        SupportedSystems = {
            "LegacyFuel",
            "ps-fuel",
            "cdn-fuel",
            "ox_fuel"
        },
        PredictiveRange = true,         -- Show estimated range
        FuelEfficiency = true,          -- Show MPG/L per 100km
        RefuelNotifications = true
    },
    
    -- Vehicle health system
    HealthSystem = {
        ShowEngineHealth = true,
        ShowBodyHealth = true,
        ShowTransmissionHealth = false,
        HealthColorCoding = true,
        DamageAlerts = true,
        RepairNotifications = true,
        HealthThresholds = {
            Critical = 300,             -- Engine health thresholds
            Low = 500,
            Medium = 750,
            Good = 900
        }
    },
    
    -- Racing integration
    Racing = {
        ShowLapTimes = true,
        ShowBestLap = true,
        ShowPosition = true,
        ShowCheckpoints = true,
        SpeedRecords = true,
        ShowNitrousLevel = true,
        ShowTireTemperature = false,    -- Advanced feature
        ShowAerodynamics = false        -- Advanced feature
    },
    
    -- Vehicle-specific shapes
    VehicleShapes = {
        [0] = 'square',                 -- Compacts
        [1] = 'square',                 -- Sedans
        [2] = 'square',                 -- SUVs
        [3] = 'square',                 -- Coupes
        [4] = 'square',                 -- Muscle
        [5] = 'square',                 -- Sports Classics
        [6] = 'square',                 -- Sports
        [7] = 'square',                 -- Super
        [8] = 'circle',                 -- Motorcycles
        [9] = 'square',                 -- Off-road
        [10] = 'square',                -- Industrial
        [11] = 'square',                -- Utility
        [12] = 'square',                -- Vans
        [13] = 'circle',                -- Cycles
        [14] = 'circle',                -- Boats
        [15] = 'circle',                -- Helicopters
        [16] = 'circle',                -- Planes
        [17] = 'square',                -- Service
        [18] = 'square',                -- Emergency
        [19] = 'square',                -- Military
        [20] = 'square',                -- Commercial
        [21] = 'square'                 -- Trains
    }
}
```

---

## 🧭 **GPS & Navigation Configuration**

### 📍 **Basic GPS Settings**

```lua
Config.GpsHud = {
    -- Enable GPS system
    Enabled = true,
    
    -- Display settings
    AutoShow = true,                    -- Show when in vehicle
    AutoHide = true,                    -- Hide when on foot
    DefaultPosition = 'top-right',      -- 'top-right', 'top-left', 'bottom-right', 'bottom-left'
    
    -- Update settings
    UpdateInterval = 1000,              -- Update every 1 second
    FastUpdateInterval = 250,           -- Fast updates while navigating
    
    -- Display options
    ShowStatusIcons = true,             -- Show status icons
    MaxStatusIcons = 6,                 -- Maximum icons to display
    ShowDistance = true,                -- Show distance to destination
    ShowDirection = true,               -- Show direction arrow
    ShowETA = false                     -- Show estimated time of arrival
}
```

### 🗺️ **Advanced GPS Configuration**

```lua
Config.AdvancedGPS = {
    -- Enhanced GPS features
    Enhanced = {
        Enabled = true,
        RealTimeTraffic = false,        -- Traffic simulation (experimental)
        RouteOptimization = true,       -- Optimize routes
        VoiceGuidance = false,          -- Audio directions
        OfflineMode = true              -- Work without internet
    },
    
    -- Map integration
    Map = {
        Provider = "custom",            -- "custom", "google", "mapbox"
        Style = "dark",                 -- "light", "dark", "satellite"
        ZoomLevel = 15,                 -- Default zoom level
        CenterOnPlayer = true,
        ShowPlayerIcon = true,
        TrackingMode = "follow",        -- "follow", "free", "compass"
        MapRotation = true              -- Rotate map with player
    },
    
    -- Navigation features
    Navigation = {
        ShowRoute = true,
        ShowWaypoints = true,
        ShowPOI = true,                 -- Points of Interest
        ShowTraffic = false,            -- Traffic indicators
        ShowSpeedLimits = true,         -- Speed limit signs
        VoiceInstructions = false,      -- Audio navigation
        RouteRecalculation = true,      -- Recalculate if off-route
        AlternativeRoutes = false       -- Show alternative routes
    },
    
    -- Points of Interest
    PointsOfInterest = {
        Enabled = true,
        ShowGasStations = true,
        ShowHospitals = true,
        ShowPoliceStations = true,
        ShowShops = true,
        ShowATMs = true,
        ShowJobCenters = true,
        CustomPOI = {},                 -- Custom POI definitions
        MaxDistance = 1000              -- Maximum distance to show POI
    }
}
```

### 🧭 **Compass Configuration**

```lua
Config.CompassSettings = {
    -- Enable compass
    Enabled = true,
    
    -- Display options
    ShowStreets = true,                 -- Show street names
    ShowPointer = true,                 -- Show direction pointer
    ShowDegrees = true,                 -- Show degree numbers
    ShowCardinalDirections = true,      -- Show N, S, E, W
    
    -- Behavior
    FollowPlayer = true,                -- Follow player rotation
    SmoothRotation = true,              -- Smooth rotation animation
    AutoHide = false,                   -- Auto-hide when not needed
    
    -- Update settings
    UpdateInterval = 333,               -- Update every 333ms (3 FPS)
    SmoothingFactor = 0.1,              -- Rotation smoothing
    
    -- Visual settings
    Size = 'medium',                    -- 'small', 'medium', 'large'
    Transparency = 0.9,                 -- Transparency level
    ShowBackground = true,              -- Show compass background
    
    -- Advanced features
    ShowWaypoints = false,              -- Show waypoints on compass
    ShowNearbyPlayers = false,          -- Show nearby players
    ShowVehicles = false                -- Show nearby vehicles
}
```

---

## 💰 **Money & Economy Configuration**

### 💵 **Basic Money Settings**

```lua
Config.MoneySettings = {
    -- Enable money display
    Enabled = true,
    
    -- Money types to display
    ShowCash = true,
    ShowBank = true,
    ShowCrypto = false,                 -- Cryptocurrency (if supported)
    
    -- Display settings
    Position = 'top-left',              -- Position on screen
    ShowOnHUDOpen = true,               -- Show when HUD menu opens
    ShowOnMoneyChange = true,           -- Show when money changes
    
    -- Animation settings
    AnimateChanges = true,              -- Animate money changes
    ShowChangeAmount = true,            -- Show +/- amount
    ShowDuration = 5000,                -- How long to show (ms)
    
    -- Formatting
    CurrencySymbol = '$',               -- Currency symbol
    ThousandsSeparator = ',',           -- Thousands separator
    ShowDecimals = false                -- Show decimal places
}
```

### 💳 **Advanced Economy Configuration**

```lua
Config.EconomySystem = {
    -- Multiple currency support
    Currencies = {
        cash = {
            Label = 'Cash',
            Symbol = '$',
            Color = '#00ff80',
            Icon = 'fas fa-dollar-sign'
        },
        bank = {
            Label = 'Bank',
            Symbol = '$',
            Color = '#0080ff',
            Icon = 'fas fa-credit-card'
        },
        crypto = {
            Label = 'Bitcoin',
            Symbol = '₿',
            Color = '#ff9800',
            Icon = 'fab fa-bitcoin'
        }
    },
    
    -- Transaction notifications
    Notifications = {
        Enabled = true,
        ShowLargeTransactions = true,   -- Show transactions above threshold
        LargeTransactionThreshold = 1000,
        ShowPaychecks = true,
        ShowBills = true,
        ShowPurchases = true
    },
    
    -- Budget tracking
    BudgetTracking = {
        Enabled = false,                -- Track spending patterns
        Categories = {
            'food', 'vehicles', 'weapons', 'clothes', 'housing'
        },
        ShowWeeklySpending = true,
        ShowMonthlySpending = true
    }
}
```

---

## 🔊 **Audio System Configuration**

### 🎵 **Basic Audio Settings**

```lua
Config.Sounds = {
    -- Enable sound effects
    Enabled = true,
    
    -- Master volume
    MasterVolume = 0.5,                 -- 0.0 to 1.0
    
    -- Sound effects
    MenuActivation = 'neon_activate',
    CriticalAlert = 'critical_beep',
    ThemeChange = 'synth_transition',
    ValueChange = 'digital_blip',
    GlowTrigger = 'energy_pulse',
    
    -- Audio engine
    AudioEngine = 'interact-sound'      -- 'interact-sound', 'custom', 'disabled'
}
```

### 🎚️ **Advanced Audio Configuration**

```lua
Config.AudioSystem = {
    -- Audio engine settings
    Engine = {
        Type = "interact-sound",        -- Audio system to use
        Quality = "high",               -- "low", "medium", "high"
        SpatialAudio = false,           -- 3D positioned audio
        AudioDucking = true             -- Lower game audio during notifications
    },
    
    -- Sound categories
    Categories = {
        UI = {
            Volume = 0.5,
            Enabled = true,
            Sounds = {
                MenuOpen = 'neon_activate',
                MenuClose = 'neon_deactivate',
                ButtonClick = 'ui_click',
                ButtonHover = 'ui_hover',
                ThemeChange = 'synth_transition',
                SettingChange = 'digital_blip'
            }
        },
        
        Alerts = {
            Volume = 0.8,
            Enabled = true,
            Sounds = {
                CriticalHealth = 'critical_beep',
                LowFuel = 'low_fuel_warning',
                StressAlert = 'stress_warning',
                Achievement = 'achievement_sound',
                Emergency = 'emergency_alert'
            }
        },
        
        Vehicle = {
            Volume = 0.4,
            Enabled = true,
            Sounds = {
                EngineStart = 'engine_start',
                EngineStop = 'engine_stop',
                NitroActivate = 'nitro_boost',
                Collision = 'collision_alert',
                LowFuel = 'fuel_warning'
            }
        },
        
        Environment = {
            Volume = 0.3,
            Enabled = false,
            Sounds = {
                Heartbeat = 'heartbeat',
                Breathing = 'heavy_breathing',
                Footsteps = 'footsteps_echo'
            }
        }
    },
    
    -- Dynamic audio
    Dynamic = {
        VolumeBasedOnSpeed = false,     -- Adjust volume based on speed
        EnvironmentalEffects = false,   -- Echo, muffled sounds
        AdaptiveEQ = false,             -- Automatic equalization
        NoiseGate = true,               -- Remove background noise
        VolumeNormalization = true      -- Normalize volume levels
    }
}
```

---

## 📱 **Responsive Design Configuration**

### 📱 **Basic Responsive Settings**

```lua
Config.ResponsiveSettings = {
    -- Enable responsive design
    AutoResize = true,
    
    -- Mobile optimization
    MobileOptimized = true,
    
    -- Scale settings
    MinScale = 0.8,                     -- Minimum UI scale
    MaxScale = 1.2,                     -- Maximum UI scale
    
    -- Breakpoints
    MobileBreakpoint = 768,             -- Mobile breakpoint (pixels)
    TabletBreakpoint = 1024,            -- Tablet breakpoint (pixels)
    DesktopBreakpoint = 1920            -- Desktop breakpoint (pixels)
}
```

### 📐 **Advanced Responsive Configuration**

```lua
Config.ResponsiveDesign = {
    -- Viewport settings
    Viewport = {
        AutoDetect = true,              -- Auto-detect screen size
        CustomBreakpoints = {
            xs = 480,                   -- Extra small devices
            sm = 768,                   -- Small devices
            md = 1024,                  -- Medium devices
            lg = 1440,                  -- Large devices
            xl = 1920                   -- Extra large devices
        }
    },
    
    -- Device-specific settings
    DeviceSettings = {
        Mobile = {
            Enabled = true,
            TouchOptimized = true,
            LargerButtons = true,
            SimplifiedUI = true,
            ReducedAnimations = true,
            BatteryOptimization = true,
            Scale = 0.9
        },
        
        Tablet = {
            Enabled = true,
            TouchOptimized = true,
            MediumButtons = true,
            FullUI = true,
            NormalAnimations = true,
            Scale = 1.0
        },
        
        Desktop = {
            Enabled = true,
            MouseOptimized = true,
            SmallButtons = true,
            FullUI = true,
            FullAnimations = true,
            Scale = 1.1
        },
        
        UltraWide = {
            Enabled = true,
            OptimizedLayout = true,
            ExtraFeatures = true,
            Scale = 1.2
        }
    },
    
    -- Layout adjustments
    Layout = {
        AutoAdjustPositions = true,     -- Auto-adjust element positions
        StackOnSmallScreens = true,     -- Stack elements vertically
        HideNonEssential = true,        -- Hide non-essential elements
        CompactMode = true,             -- Enable compact mode
        
        -- Position adjustments by screen size
        PositionAdjustments = {
            Mobile = {
                HUD = 'bottom-center',
                GPS = 'top-full-width',
                Compass = 'top-center'
            },
            Desktop = {
                HUD = 'bottom-left',
                GPS = 'top-right',
                Compass = 'top-center'
            }
        }
    }
}
```

---

## ⚡ **Performance Optimization**

### 🚀 **Basic Performance Settings**

```lua
Config.Performance = {
    -- Performance mode
    Mode = "balanced",                  -- "high", "balanced", "performance", "maximum"
    
    -- Update intervals
    UpdateInterval = 250,               -- Main update rate (ms)
    CriticalUpdateInterval = 100,       -- Critical alerts rate (ms)
    
    -- Visual effects
    ReducedAnimations = false,          -- Reduce animations
    SimplifiedEffects = false,          -- Simplify visual effects
    ParticleCount = 50,                 -- Number of particles (0-100)
    
    -- Memory management
    MaxMemoryPerPlayer = 50,            -- MB per player
    GarbageCollectionInterval = 60000    -- Cleanup frequency (ms)
}
```

### ⚡ **Advanced Performance Configuration**

```lua
Config.PerformanceOptimization = {
    -- Dynamic performance scaling
    DynamicScaling = {
        Enabled = true,
        PlayerCountThresholds = {
            Low = 16,                   -- < 16 players: High performance
            Medium = 32,                -- 16-32 players: Medium performance
            High = 64,                  -- 32-64 players: Optimized performance
            Maximum = 128               -- > 64 players: Maximum optimization
        },
        AutoAdjust = true,              -- Automatically adjust settings
        AdjustmentDelay = 30000         -- Delay between adjustments (ms)
    },
    
    -- Performance monitoring
    Monitoring = {
        Enabled = true,
        TrackFPS = true,                -- Monitor FPS impact
        TrackMemory = true,             -- Monitor memory usage
        TrackNetworkLatency = true,     -- Monitor network performance
        AlertThresholds = {
            FPSDropBelow = 30,          -- Alert if FPS drops below 30
            MemoryAbove = 100,          -- Alert if memory above 100MB
            LatencyAbove = 100          -- Alert if latency above 100ms
        }
    },
    
    -- Optimization strategies
    Strategies = {
        -- Update rate optimization
        UpdateRateOptimization = {
            Enabled = true,
            BasedOnPlayerCount = true,
            BasedOnServerLoad = true,
            BasedOnClientPerformance = true
        },
        
        -- Visual optimization
        VisualOptimization = {
            DisableAnimationsUnderFPS = 30,
            ReduceParticlesUnderFPS = 45,
            SimplifyEffectsUnderFPS = 40
        },
        
        -- Memory optimization
        MemoryOptimization = {
            AggressiveGarbageCollection = true,
            LimitCacheSize = true,
            UnloadUnusedAssets = true
        }
    }
}
```

### 📊 **Performance Presets**

```lua
Config.PerformancePresets = {
    -- High Performance (for high-end systems)
    High = {
        UpdateInterval = 100,
        ReducedAnimations = false,
        HighQualityEffects = true,
        ParticleCount = 100,
        MaxMemoryPerPlayer = 100
    },
    
    -- Balanced (recommended for most servers)
    Balanced = {
        UpdateInterval = 250,
        ReducedAnimations = false,
        HighQualityEffects = true,
        ParticleCount = 50,
        MaxMemoryPerPlayer = 50
    },
    
    -- Performance (for lower-end systems)
    Performance = {
        UpdateInterval = 500,
        ReducedAnimations = true,
        HighQualityEffects = false,
        ParticleCount = 25,
        MaxMemoryPerPlayer = 25
    },
    
    -- Maximum (for very low-end systems)
    Maximum = {
        UpdateInterval = 1000,
        ReducedAnimations = true,
        HighQualityEffects = false,
        ParticleCount = 0,
        MaxMemoryPerPlayer = 10
    }
}
```

---

## 🛡️ **Security Configuration**

### 🔒 **Basic Security Settings**

```lua
Config.Security = {
    -- Access control
    RequirePermissions = true,          -- Require permissions for admin commands
    LogCommands = true,                 -- Log all command usage
    LogErrors = true,                   -- Log all errors
    
    -- Command permissions
    AdminCommands = {
        'hudstats', 'hud_debug_all', 'hud_maintenance'
    },
    PlayerCommands = {
        'hud', 'hudtheme', 'hud_reset', 'hud_debug'
    }
}
```

### 🛡️ **Advanced Security Configuration**

```lua
Config.SecuritySystem = {
    -- Access control
    AccessControl = {
        Enabled = true,
        WhitelistMode = false,          -- Only allow whitelisted players
        BlacklistMode = true,           -- Block blacklisted players
        RateLimiting = true,            -- Prevent command spam
        MaxCommandsPerMinute = 10       -- Command rate limit
    },
    
    -- Data validation
    DataValidation = {
        Enabled = true,
        ValidatePlayerData = true,      -- Validate all player data
        ValidateNetworkEvents = true,   -- Validate network events
        SanitizeInputs = true,          -- Sanitize user inputs
        MaxDataSize = 1024              -- Maximum data size (KB)
    },
    
    -- Logging and monitoring
    Logging = {
        LogLevel = "INFO",              -- Logging level
        LogCommands = true,             -- Log command usage
        LogErrors = true,               -- Log errors
        LogPerformance = true,          -- Log performance metrics
        LogSecurity = true,             -- Log security events
        RetentionDays = 30,             -- Keep logs for 30 days
        LogToFile = true,               -- Write logs to file
        LogToDatabase = false           -- Store logs in database
    },
    
    -- Anti-cheat integration
    AntiCheat = {
        Enabled = false,                -- Enable basic anti-cheat
        ValidateStatusValues = true,    -- Validate status bar values
        DetectSpeedHacking = false,     -- Detect speed modifications
        DetectHealthHacking = true,     -- Detect health modifications
        AlertAdmins = true,             -- Alert admins of violations
        AutoKick = false                -- Automatically kick cheaters
    }
}
```

---

## 🌍 **Localization Configuration**

### 🗣️ **Basic Language Settings**

```lua
Config.Locale = 'en'                   -- Default language

-- Available languages
Config.AvailableLocales = {
    'en',                               -- English
    'de',                               -- German
    'fr',                               -- French
    'es',                               -- Spanish
    'nl'                                -- Dutch
}
```

### 🌐 **Advanced Localization**

```lua
Config.Localization = {
    -- Language settings
    DefaultLocale = 'en',
    FallbackLocale = 'en',              -- Fallback if translation missing
    AllowPlayerChoice = true,           -- Let players choose language
    
    -- Regional settings
    Regional = {
        DateFormat = "MM/DD/YYYY",      -- Date format
        TimeFormat = "12h",             -- "12h" or "24h"
        CurrencyFormat = "USD",         -- Currency formatting
        NumberFormat = "en-US",         -- Number formatting
        TemperatureUnit = "F"           -- "C" or "F"
    },
    
    -- RTL support
    RTL = {
        Enabled = false,                -- Right-to-left languages
        SupportedLocales = {'ar', 'he', 'fa'},
        AutoDetect = true               -- Auto-detect RTL languages
    },
    
    -- Custom translations
    CustomTranslations = {
        -- Add custom translation keys here
    }
}
```

---

## 🔧 **Advanced Configuration**

### 🎛️ **Module System Configuration**

```lua
Config.ModuleSystem = {
    -- Core modules
    CoreModules = {
        'hud-core',                     -- Core functionality
        'hud-events',                   -- Event system
        'hud-settings',                 -- Settings management
        'hud-themes'                    -- Theme system
    },
    
    -- Optional modules
    OptionalModules = {
        'hud-vehicle',                  -- Vehicle integration
        'hud-map',                      -- Map and GPS
        'hud-persistence'               -- Settings persistence
    },
    
    -- Module loading
    LoadingOrder = {
        'hud-events',                   -- Load first
        'hud-settings',
        'hud-themes',
        'hud-core',
        'hud-vehicle',
        'hud-map'                       -- Load last
    },
    
    -- Module health monitoring
    HealthMonitoring = {
        Enabled = true,
        CheckInterval = 5000,           -- Check every 5 seconds
        AutoRestart = false,            -- Auto-restart failed modules
        NotifyAdmins = true             -- Notify admins of failures
    }
}
```

### 🔄 **Event System Configuration**

```lua
Config.EventSystem = {
    -- Event processing
    Processing = {
        BatchSize = 10,                 -- Events per batch
        BatchDelay = 50,                -- Delay between batches (ms)
        MaxQueueSize = 100,             -- Maximum queued events
        ProcessingTimeout = 5000        -- Event processing timeout
    },
    
    -- Event validation
    Validation = {
        Enabled = true,
        ValidateEventData = true,       -- Validate event data
        ValidateEventSource = true,     -- Validate event source
        MaxEventSize = 1024,            -- Maximum event size (bytes)
        AllowedEvents = {}              -- Whitelist of allowed events
    },
    
    -- Event logging
    Logging = {
        LogAllEvents = false,           -- Log all events (debug only)
        LogErrorEvents = true,          -- Log failed events
        LogPerformanceEvents = true     -- Log slow events
    }
}
```

---

## 🎮 **Menu System Configuration**

### 📋 **Basic Menu Settings**

```lua
Config.Menu = {
    -- Default menu settings (these become defaults for new players)
    hudVisible = true,
    showHealth = true,
    showArmor = true,
    showHunger = true,
    showThirst = true,
    showStress = true,
    showStamina = true,
    showOxygen = true,
    hudOpacity = 1.0,
    
    -- Performance settings
    performanceMode = false,
    animationsEnabled = true,
    debugMode = false,
    
    -- Theme settings
    currentNeonTheme = 'cyberpunk',
    isNeonGlowChecked = true,
    isNeonAnimationsChecked = true,
    isCriticalAlertsChecked = true,
    isThemeParticlesChecked = true
}
```

### 📱 **Advanced Menu Configuration**

```lua
Config.MenuSystem = {
    -- Menu behavior
    Behavior = {
        OpenKey = 'F1',                 -- Key to open menu
        CloseOnEscape = true,           -- Close menu with Escape
        CloseOnClickOutside = false,    -- Close when clicking outside
        SaveOnChange = true,            -- Save settings immediately
        ConfirmChanges = false          -- Require confirmation
    },
    
    -- Menu appearance
    Appearance = {
        Theme = 'auto',                 -- 'auto', 'light', 'dark'
        Size = 'medium',                -- 'small', 'medium', 'large'
        Position = 'center',            -- 'center', 'top', 'bottom'
        Transparency = 0.95,            -- Menu transparency
        BlurBackground = true,          -- Blur background
        ShowAnimations = true           -- Enable menu animations
    },
    
    -- Menu sections
    Sections = {
        Display = {
            Enabled = true,
            Order = 1,
            Icon = 'fas fa-eye'
        },
        Performance = {
            Enabled = true,
            Order = 2,
            Icon = 'fas fa-tachometer-alt'
        },
        Themes = {
            Enabled = true,
            Order = 3,
            Icon = 'fas fa-palette'
        },
        Vehicle = {
            Enabled = true,
            Order = 4,
            Icon = 'fas fa-car'
        },
        GPS = {
            Enabled = true,
            Order = 5,
            Icon = 'fas fa-map-marker-alt'
        },
        Audio = {
            Enabled = true,
            Order = 6,
            Icon = 'fas fa-volume-up'
        },
        Advanced = {
            Enabled = false,            -- Hidden by default
            Order = 7,
            Icon = 'fas fa-cogs',
            RequireAdmin = true         -- Require admin access
        }
    }
}
```

---

## 📊 **Monitoring & Analytics**

### 📈 **Basic Monitoring**

```lua
Config.Monitoring = {
    -- Enable monitoring
    Enabled = true,
    
    -- Performance tracking
    TrackFPS = true,
    TrackMemory = true,
    TrackNetworkLatency = true,
    
    -- Usage analytics
    TrackFeatureUsage = true,
    TrackThemePreferences = true,
    TrackErrorPatterns = true
}
```

### 📊 **Advanced Analytics Configuration**

```lua
Config.Analytics = {
    -- Data collection
    DataCollection = {
        Enabled = true,
        AnonymousReporting = true,      -- Anonymous usage statistics
        PerformanceMetrics = true,      -- Collect performance data
        FeatureUsage = true,            -- Track feature usage
        ErrorReporting = true,          -- Report errors (anonymized)
        UserBehavior = false            -- Track user behavior (opt-in)
    },
    
    -- Reporting
    Reporting = {
        Enabled = true,
        ReportInterval = 3600000,       -- Report every hour (ms)
        ReportEndpoint = "",            -- Custom reporting endpoint
        LocalStorage = true,            -- Store reports locally
        MaxStoredReports = 100          -- Maximum stored reports
    },
    
    -- Privacy settings
    Privacy = {
        HashPlayerIds = true,           -- Hash player identifiers
        ExcludePersonalData = true,     -- Exclude personal information
        DataRetention = 30,             -- Days to retain data
        AllowOptOut = true              -- Allow players to opt out
    }
}
```

---

## 🔗 **Integration Configuration**

### 🔌 **Basic Integration Settings**

```lua
Config.Integrations = {
    -- QBCore integration
    QBCore = {
        Enabled = true,
        StatusIntegration = true,       -- Integrate with QBCore status
        JobIntegration = true,          -- Show job information
        GangIntegration = true          -- Show gang information
    },
    
    -- External resources
    Resources = {
        InteractSound = GetResourceState('interact-sound') == 'started',
        QBInventory = GetResourceState('qb-inventory') == 'started',
        QBVehicleKeys = GetResourceState('qb-vehiclekeys') == 'started'
    }
}
```

### 🔗 **Advanced Integration Configuration**

```lua
Config.AdvancedIntegrations = {
    -- Resource detection
    ResourceDetection = {
        AutoDetect = true,              -- Auto-detect compatible resources
        CheckInterval = 30000,          -- Check every 30 seconds
        NotifyChanges = true            -- Notify when resources change
    },
    
    -- Inventory systems
    Inventory = {
        SupportedSystems = {
            'qb-inventory',
            'ox_inventory',
            'qs-inventory'
        },
        ShowWeight = true,
        ShowSlots = true,
        WeightUnit = 'kg'               -- 'kg' or 'lbs'
    },
    
    -- Job systems
    Jobs = {
        SupportedSystems = {
            'qb-jobs',
            'esx_jobs'
        },
        ShowJobInfo = true,
        ShowDutyStatus = true,
        JobSpecificHUD = true
    },
    
    -- Vehicle systems
    Vehicles = {
        FuelSystems = {
            'LegacyFuel',
            'ps-fuel',
            'cdn-fuel',
            'ox_fuel'
        },
        KeySystems = {
            'qb-vehiclekeys',
            'qs-vehiclekeys'
        },
        RacingSystems = {
            'qb-racing',
            'cw-racing'
        }
    },
    
    -- Communication systems
    Communication = {
        PhoneSystems = {
            'qb-phone',
            'qs-smartphone'
        },
        RadioSystems = {
            'pma-voice',
            'tokovoip'
        }
    }
}
```

---

## 📱 **Mobile Configuration**

### 📱 **Basic Mobile Settings**

```lua
Config.Mobile = {
    -- Enable mobile support
    Enabled = true,
    
    -- Mobile optimizations
    TouchOptimized = true,
    LargerButtons = true,
    SimplifiedUI = true,
    ReducedAnimations = true,
    BatteryOptimization = true
}
```

### 📱 **Advanced Mobile Configuration**

```lua
Config.MobileOptimization = {
    -- Device detection
    Detection = {
        AutoDetect = true,              -- Auto-detect mobile devices
        UserAgentChecking = true,       -- Check user agent string
        TouchSupport = true,            -- Check for touch support
        ScreenSize = true               -- Check screen dimensions
    },
    
    -- Mobile-specific settings
    MobileSettings = {
        -- UI adjustments
        UI = {
            Scale = 0.9,                -- UI scale for mobile
            ButtonSize = 1.2,           -- Button size multiplier
            FontSize = 1.1,             -- Font size multiplier
            TouchTargetSize = 44,       // Minimum touch target size (px)
            Spacing = 1.2               -- Spacing multiplier
        },
        
        -- Performance optimizations
        Performance = {
            ReducedFPS = 30,            -- Cap FPS for mobile
            MinimalEffects = true,      -- Use minimal effects
            SimplifiedThemes = true,    -- Use simplified themes
            ReducedParticles = 10,      // Maximum particles for mobile
            AggressiveMemoryManagement = true
        },
        
        -- Battery optimization
        Battery = {
            Enabled = true,
            ReduceBackgroundActivity = true,
            LowerUpdateRates = true,
            DisableNonEssentialFeatures = true
        }
    },
    
    -- Tablet settings (different from mobile)
    TabletSettings = {
        UI = {
            Scale = 1.0,
            ButtonSize = 1.1,
            FontSize = 1.0
        },
        Performance = {
            ReducedFPS = 45,
            MinimalEffects = false,
            SimplifiedThemes = false
        }
    }
}
```

---

## 🧪 **Experimental Features**

### 🔬 **Experimental Settings**

```lua
Config.Experimental = {
    -- Master toggle for experimental features
    Enabled = false,
    
    -- AI-powered features (very experimental)
    AI = {
        Enabled = false,
        PredictiveAnalytics = false,    -- Predict player behavior
        AutoOptimization = false,       -- Auto-optimize settings
        SmartNotifications = false      -- AI-powered notifications
    },
    
    -- Advanced graphics (experimental)
    Graphics = {
        Enabled = false,
        HDR = false,                    -- High Dynamic Range
        AdvancedShaders = false,        -- Advanced shader effects
        ParticlePhysics = false,        -- Physics-based particles
        DynamicLighting = false         -- Dynamic lighting effects
    },
    
    -- Cloud features (experimental)
    Cloud = {
        Enabled = false,
        CloudSave = false,              -- Save settings to cloud
        CrossServerSync = false,        -- Sync across servers
        CloudAnalytics = false          -- Cloud-based analytics
    }
}
```

**⚠️ Warning:** Experimental features are unstable and may cause issues. Use at your own risk and only in development environments.

---

## ✅ **Configuration Validation**

### 🔍 **Validation System**

The Enhanced HUD includes a comprehensive configuration validation system that automatically checks your settings and provides warnings or errors for invalid configurations.

```lua
Config.Validation = {
    -- Enable configuration validation
    Enabled = true,
    
    -- Validation levels
    StrictMode = false,                 -- Strict validation (recommended for production)
    WarnOnInvalid = true,               -- Show warnings for invalid settings
    ErrorOnCritical = true,             -- Show errors for critical issues
    
    -- Auto-correction
    AutoCorrect = true,                 -- Automatically correct invalid values
    UseDefaults = true,                 -- Use defaults for missing values
    
    -- Validation reporting
    LogValidation = true,               // Log validation results
    ShowValidationInConsole = true      // Show in server console
}
```

### ✅ **Common Validation Checks**

The system automatically validates:

- **Theme Names:** Ensures theme names are valid
- **Update Intervals:** Checks for reasonable update frequencies
- **Percentages:** Validates values are between 0-100
- **Colors:** Ensures color codes are valid hex colors
- **File Paths:** Validates that referenced files exist
- **Dependencies:** Checks that required resources are available
- **Performance Settings:** Warns about settings that may impact performance

### 🔧 **Custom Validation**

You can add custom validation rules:

```lua
Config.CustomValidation = {
    -- Custom validation functions
    Rules = {
        -- Example: Validate server name is not empty
        ServerName = function(value)
            return value and value ~= "" and string.len(value) <= 50
        end,
        
        -- Example: Validate update interval is reasonable
        UpdateInterval = function(value)
            return value >= 100 and value <= 5000
        end
    },
    
    -- Custom error messages
    ErrorMessages = {
        ServerName = "Server name must be between 1-50 characters",
        UpdateInterval = "Update interval must be between 100-5000ms"
    }
}
```

---

## 📚 **Configuration Examples**

### 🏁 **Quick Start Example**

Perfect for most servers:

```lua
Config = {
    ServerName = "My FiveM Server",
    UpdateInterval = 250,
    Themes = { Default = 'cyberpunk', AllowPlayerChange = true },
    StatusSettings = { ShowHealth = true, ShowArmor = true, ShowHunger = true, ShowThirst = true },
    VehicleSettings = { Enabled = true, SpeedUnit = 'mph' },
    GpsHud = { Enabled = true, DefaultPosition = 'top-right' },
    Sounds = { Enabled = true, MasterVolume = 0.5 }
}
```

### ⚡ **Performance Optimized Example**

For high player count servers:

```lua
Config = {
    UpdateInterval = 500,
    ReducedAnimations = true,
    HighQualityEffects = false,
    ParticleCount = 0,
    StatusSettings = { ShowHealth = true, ShowArmor = true, ShowHunger = false, ShowThirst = false },
    VehicleSettings = { Enabled = true, ShowNitro = false, ShowEngineHealth = false },
    GpsHud = { Enabled = false },
    Sounds = { Enabled = false }
}
```

### 🎮 **Feature-Rich Example**

For servers wanting all features:

```lua
Config = {
    UpdateInterval = 200,
    HighQualityEffects = true,
    ParticleCount = 75,
    StatusSettings = { ShowHealth = true, ShowArmor = true, ShowHunger = true, ShowThirst = true, ShowStress = true, ShowStamina = true, ShowOxygen = true },
    VehicleSettings = { Enabled = true, ShowNitro = true, ShowEngineHealth = true, ShowHarness = true },
    GpsHud = { Enabled = true, ShowStatusIcons = true, ShowDistance = true },
    MoneySettings = { Enabled = true, ShowCash = true, ShowBank = true, AnimateChanges = true },
    Sounds = { Enabled = true, MasterVolume = 0.7 }
}
```

---

**📖 For more detailed configuration options, check the individual configuration files in the `examples/` folder:**

- `config-basic.lua` - Simple configuration for beginners
- `config-advanced.lua` - Advanced configuration with all options
- `config-performance.lua` - Performance-optimized configuration

**💡 Need help with configuration? Check our [Troubleshooting Guide](TROUBLESHOOTING.md) or join our [Discord Community](https://discord.gg/your-discord).**