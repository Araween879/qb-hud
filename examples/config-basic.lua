--[[
    📋 Enhanced HUD - Basic Configuration Example
    
    This is a simple, ready-to-use configuration for most servers.
    Perfect for beginners or small servers with standard requirements.
    
    ✅ Features Enabled:
    - All player status indicators
    - Vehicle integration
    - GPS & compass system
    - Cyberpunk theme by default
    - Standard performance settings
    
    📖 Usage:
    1. Copy this file to config.lua
    2. Adjust server name and basic settings
    3. Start your server - no additional setup needed!
--]]

Config = {}

-- ================================
-- 🎮 BASIC SERVER INFORMATION
-- ================================

Config.ServerName = "Your Server Name"      -- Replace with your server name
Config.Version = "3.1.0"                    -- Don't change this
Config.Debug = false                        -- Set to true for troubleshooting

-- ================================
-- ⚡ PERFORMANCE SETTINGS
-- ================================

-- How often to update the HUD (in milliseconds)
-- Lower = smoother but more CPU usage
-- Higher = less smooth but better performance
Config.UpdateInterval = 250                 -- 4 times per second (recommended)

-- Animation settings
Config.ReducedAnimations = false            -- Set true for low-end servers
Config.HighQualityEffects = true           -- Beautiful visual effects
Config.ParticleCount = 50                   -- Number of particle effects

-- ================================
-- 🎨 THEME SYSTEM
-- ================================

Config.Themes = {
    Default = 'cyberpunk',                  -- Default theme for new players
                                           -- Options: 'cyberpunk', 'synthwave', 'matrix'
    AllowPlayerChange = true,               -- Let players change themes
    SavePlayerChoice = true                 -- Remember player's theme choice
}

-- Available theme colors for reference:
-- cyberpunk: Cyan (#00ffff) + Purple (#a020f0)
-- synthwave: Pink (#ff0080) + Blue (#8000ff) 
-- matrix: Green (#00ff00) + Dark Green (#008000)

-- ================================
-- 💓 PLAYER STATUS SETTINGS
-- ================================

Config.StatusSettings = {
    -- Which status bars to show
    ShowHealth = true,
    ShowArmor = true,
    ShowHunger = true,
    ShowThirst = true,
    ShowStress = true,
    ShowStamina = true,
    ShowOxygen = true,
    
    -- When to show critical warnings (percentage)
    CriticalThreshold = 20,                 -- Show warning when below 20%
    
    -- Status bar ranges
    Health = { min = 0, max = 100 },
    Armor = { min = 0, max = 100 },
    Hunger = { min = 0, max = 100 },
    Thirst = { min = 0, max = 100 },
    Stress = { min = 0, max = 100 },
    Stamina = { min = 0, max = 100 },
    Oxygen = { min = 0, max = 100 }
}

-- ================================
-- 🚗 VEHICLE SYSTEM
-- ================================

Config.VehicleSettings = {
    -- Enable vehicle HUD
    Enabled = true,
    
    -- Speed settings
    SpeedUnit = 'mph',                      -- 'mph' or 'kmh'
    ShowSpeedometer = true,
    
    -- Fuel system
    ShowFuel = true,
    LowFuelThreshold = 20,                  -- Warning at 20%
    LowFuelAlert = true,
    
    -- Additional features
    ShowNitro = true,                       -- Show nitro if available
    ShowEngineHealth = true,                -- Show engine condition
    ShowHarness = true,                     -- Show racing harness
    
    -- Vehicle shapes for different types
    CarShape = 'square',                    -- 'square' or 'circle'
    BikeShape = 'circle'                    -- 'square' or 'circle'
}

-- ================================
-- 🧭 GPS & COMPASS SYSTEM
-- ================================

Config.GpsHud = {
    -- Enable GPS system
    Enabled = true,
    
    -- Automatic display
    AutoShow = true,                        -- Show when in vehicle
    AutoHide = true,                        -- Hide when on foot
    
    -- GPS position on screen
    DefaultPosition = 'top-right',          -- 'top-right', 'top-left', 'bottom-right', 'bottom-left'
    
    -- Update frequency
    UpdateInterval = 1000,                  -- Update every 1 second
    
    -- Display settings
    ShowStatusIcons = true,                 -- Show status icons
    MaxStatusIcons = 6,                     -- Maximum icons to show
    ShowDistance = true,                    -- Show distance to destination
    ShowDirection = true                    -- Show direction arrow
}

Config.CompassSettings = {
    -- Enable compass
    Enabled = true,
    
    -- Display options
    ShowStreets = true,                     -- Show street names
    ShowPointer = true,                     -- Show direction pointer
    ShowDegrees = true,                     -- Show degree numbers
    
    -- Follow player rotation
    FollowPlayer = true,
    
    -- Update frequency
    UpdateInterval = 500                    -- Update every 0.5 seconds
}

-- ================================
-- 💰 MONEY DISPLAY
-- ================================

Config.MoneySettings = {
    -- Enable money display
    Enabled = true,
    
    -- Show different money types
    ShowCash = true,
    ShowBank = true,
    
    -- Animation settings
    AnimateChanges = true,                  -- Animate when money changes
    ShowChangeAmount = true,                -- Show +/- amount briefly
    
    -- Display duration
    ShowDuration = 5000                     -- How long to show money (milliseconds)
}

-- ================================
-- 🔊 SOUND SYSTEM
-- ================================

Config.Sounds = {
    -- Enable sound effects (requires interact-sound)
    Enabled = true,
    
    -- Sound volume (0.0 to 1.0)
    MasterVolume = 0.5,
    
    -- Individual sound settings
    MenuActivation = 'neon_activate',
    CriticalAlert = 'critical_beep',
    ThemeChange = 'synth_transition',
    ValueChange = 'digital_blip',
    GlowTrigger = 'energy_pulse'
}

-- ================================
-- 📱 RESPONSIVE DESIGN
-- ================================

Config.ResponsiveSettings = {
    -- Automatically adjust for different screen sizes
    AutoResize = true,
    
    -- Mobile optimization
    MobileOptimized = true,
    
    -- Scale settings
    MinScale = 0.8,                         -- Minimum UI scale
    MaxScale = 1.2,                         -- Maximum UI scale
    
    -- Breakpoints for different screen sizes
    MobileBreakpoint = 768,                 -- Pixels
    TabletBreakpoint = 1024                 -- Pixels
}

-- ================================
-- 🛡️ SECURITY SETTINGS
-- ================================

Config.Security = {
    -- Admin commands
    AdminCommands = {
        'hudstats',                         -- Server statistics
        'hud_debug_all'                     -- Global debug toggle
    },
    
    -- Player commands (available to everyone)
    PlayerCommands = {
        'hud',                              -- Open HUD menu
        'hudtheme',                         -- Change theme
        'hud_reset',                        -- Reset personal settings
        'hud_debug'                         -- Personal debug mode
    },
    
    -- Command permissions
    RequireAdmin = false,                   -- Set true to restrict some commands
    LogCommands = true                      -- Log command usage
}

-- ================================
-- 💾 DATA STORAGE
-- ================================

Config.Storage = {
    -- Automatic settings saving
    AutoSave = true,
    
    -- Save interval (milliseconds)
    SaveInterval = 30000,                   -- Save every 30 seconds
    
    -- Backup settings
    CreateBackups = true,
    BackupInterval = 300000,                -- Backup every 5 minutes
    MaxBackups = 10                         -- Keep last 10 backups
}

-- ================================
-- 🌍 LANGUAGE SETTINGS
-- ================================

Config.Locale = 'en'                       -- Default language
                                           -- Available: 'en', 'de', 'fr', 'es', 'nl'

-- ================================
-- 🎛️ MENU CONFIGURATION
-- ================================

Config.Menu = {
    -- Default menu settings (these become the default for new players)
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
    currentNeonTheme = Config.Themes.Default,
    isNeonGlowChecked = true,
    isNeonAnimationsChecked = true,
    isCriticalAlertsChecked = true,
    isThemeParticlesChecked = true,
    
    -- GPS settings
    isGpsHudChecked = Config.GpsHud.Enabled,
    gpsHudPosition = Config.GpsHud.DefaultPosition,
    
    -- Map settings
    isOutMapChecked = true,
    isOutCompassChecked = Config.CompassSettings.Enabled,
    isCompassFollowChecked = Config.CompassSettings.FollowPlayer,
    isMapNotifChecked = true,
    isHideMapChecked = false,
    isToggleMapBordersChecked = true,
    isToggleMapShapeChecked = Config.VehicleSettings.CarShape,
    
    -- Compass settings
    isCompassShowChecked = Config.CompassSettings.Enabled,
    isShowStreetsChecked = Config.CompassSettings.ShowStreets,
    isPointerShowChecked = Config.CompassSettings.ShowPointer,
    isDegreesShowChecked = Config.CompassSettings.ShowDegrees,
    
    -- Vehicle settings
    isDynamicEngineChecked = Config.VehicleSettings.ShowEngineHealth,
    isDynamicNitroChecked = Config.VehicleSettings.ShowNitro,
    isLowFuelChecked = Config.VehicleSettings.LowFuelAlert,
    
    -- Sound settings
    isListSoundsChecked = Config.Sounds.Enabled,
    isResetSoundsChecked = Config.Sounds.Enabled,
    
    -- Cinematic settings
    isCinematicNotifChecked = true,
    isCinematicModeChecked = false,
    
    -- Dynamic status settings
    isDynamicHealthChecked = true,
    isDynamicArmorChecked = true,
    isDynamicHungerChecked = true,
    isDynamicThirstChecked = true,
    isDynamicStressChecked = true,
    isDynamicOxygenChecked = true,
    
    -- FPS settings
    isChangeFPSChecked = true,
    isChangeCompassFPSChecked = true
}

-- ================================
-- 🔧 ADVANCED SETTINGS
-- ================================

-- Only change these if you know what you're doing!

Config.Advanced = {
    -- Update intervals for different systems
    CoreUpdateInterval = 250,               -- Main HUD updates
    VehicleUpdateInterval = 500,            -- Vehicle system updates
    GpsUpdateInterval = 1000,               -- GPS system updates
    CompassUpdateInterval = 500,            -- Compass updates
    
    -- Memory management
    MemoryCleanupInterval = 60000,          -- Cleanup every minute
    MaxMemoryUsage = 50,                    -- MB limit
    
    -- Error handling
    MaxRetries = 3,                         -- Retry failed operations
    RetryDelay = 1000,                      -- Delay between retries
    
    -- Network optimization
    BatchNetworkEvents = true,              -- Group network calls
    NetworkTimeout = 5000                   -- Network timeout
}

-- ================================
-- ✅ VALIDATION
-- ================================

-- Don't change this section - it validates your config
CreateThread(function()
    Wait(1000)
    
    -- Validate theme
    local validThemes = {cyberpunk = true, synthwave = true, matrix = true}
    if not validThemes[Config.Themes.Default] then
        print("^1[CONFIG ERROR]^7 Invalid default theme: " .. Config.Themes.Default)
        Config.Themes.Default = 'cyberpunk'
    end
    
    -- Validate update interval
    if Config.UpdateInterval < 100 then
        print("^3[CONFIG WARNING]^7 Very low update interval may cause performance issues")
    elseif Config.UpdateInterval > 1000 then
        print("^3[CONFIG WARNING]^7 High update interval may cause choppy animations")
    end
    
    -- Validate GPS position
    local validPositions = {
        ['top-right'] = true, ['top-left'] = true,
        ['bottom-right'] = true, ['bottom-left'] = true
    }
    if not validPositions[Config.GpsHud.DefaultPosition] then
        print("^1[CONFIG ERROR]^7 Invalid GPS position: " .. Config.GpsHud.DefaultPosition)
        Config.GpsHud.DefaultPosition = 'top-right'
    end
    
    print("^2[Enhanced HUD]^7 Basic configuration loaded successfully")
end)

--[[
    📝 QUICK CUSTOMIZATION GUIDE:
    
    🎨 To change default theme:
    Config.Themes.Default = 'synthwave'  -- or 'matrix'
    
    ⚡ To improve performance:
    Config.UpdateInterval = 500
    Config.ReducedAnimations = true
    
    🚗 To disable vehicle HUD:
    Config.VehicleSettings.Enabled = false
    
    🧭 To disable GPS:
    Config.GpsHud.Enabled = false
    
    💰 To disable money display:
    Config.MoneySettings.Enabled = false
    
    🔊 To disable sounds:
    Config.Sounds.Enabled = false
    
    📱 For mobile servers:
    Config.ResponsiveSettings.MobileOptimized = true
    Config.ReducedAnimations = true
    
    For more advanced configuration, see:
    - config-advanced.lua (Advanced features)
    - config-performance.lua (Performance optimization)
--]]