# 🎨 Themes Documentation - QBCore Advanced HUD System

## 📚 Table of Contents

- [Overview](#overview)
- [Built-in Themes](#built-in-themes)
- [Theme Structure](#theme-structure)
- [Creating Custom Themes](#creating-custom-themes)
- [Theme Installation](#theme-installation)
- [Theme Configuration](#theme-configuration)
- [Advanced Customization](#advanced-customization)
- [Theme APIs](#theme-apis)
- [Performance Considerations](#performance-considerations)

---

## 🌟 Overview

The HUD System supports a comprehensive theming system that allows complete visual customization of all components. Themes control colors, animations, layouts, fonts, and visual effects to create unique user experiences.

### Key Features

- **Multiple Built-in Themes** - Ready-to-use professional themes
- **Custom Theme Support** - Create your own themes with full control
- **Runtime Theme Switching** - Change themes without restart
- **Component-Specific Styling** - Fine-tune individual components
- **Animation Control** - Theme-specific animation settings
- **Responsive Design** - Themes adapt to different screen sizes

---

## 🎭 Built-in Themes

### 1. Default Theme
**Clean, professional design with subtle animations**

```css
/* Color Palette */
Primary: #007bff
Secondary: #6c757d
Background: rgba(0, 0, 0, 0.7)
Text: #ffffff
Success: #28a745
Warning: #ffc107
Danger: #dc3545
```

**Best for:** General use, professional servers, clean aesthetics

### 2. Neon Theme ⚡
**Cyberpunk-inspired with glowing effects and vibrant colors**

```css
/* Color Palette */
Primary: #00ffff (Cyan)
Secondary: #a020f0 (Purple)
Background: rgba(10, 10, 10, 0.9)
Accent: #ff6b35 (Orange)
Glow: 0 0 20px currentColor
```

**Features:**
- Animated glow effects
- Gradient backgrounds
- Pulsing animations
- High contrast design

**Best for:** Roleplay servers, cyberpunk themes, futuristic settings

### 3. Minimal Theme 🔘
**Ultra-clean design with minimal visual clutter**

```css
/* Color Palette */
Primary: #333333
Secondary: #666666
Background: rgba(255, 255, 255, 0.05)
Text: #ffffff
Accent: #007bff
```

**Features:**
- Thin borders
- Subtle shadows
- Minimal animations
- Maximum clarity

**Best for:** Competitive gaming, performance focus, clean interfaces

### 4. Dark Theme 🌙
**Deep dark theme with subtle accents**

```css
/* Color Palette */
Primary: #1a1a1a
Secondary: #2d2d2d
Background: rgba(0, 0, 0, 0.95)
Text: #e0e0e0
Accent: #4a90e2
```

**Features:**
- Eye-friendly dark colors
- Soft gradients
- Comfortable viewing
- Battery-efficient design

**Best for:** Long gaming sessions, night play, eye comfort

---

## 🏗️ Theme Structure

### Theme Definition Format

```lua
local theme = {
    -- Basic Information
    name = 'theme_name',
    displayName = 'Theme Display Name',
    version = '1.0.0',
    author = 'Author Name',
    description = 'Theme description',
    
    -- Color System
    colors = {
        -- Primary Colors
        primary = '#007bff',
        secondary = '#6c757d',
        background = 'rgba(0, 0, 0, 0.7)',
        surface = 'rgba(255, 255, 255, 0.1)',
        
        -- Text Colors
        text = {
            primary = '#ffffff',
            secondary = '#e0e0e0',
            muted = '#888888',
            inverse = '#000000'
        },
        
        -- Status Colors
        status = {
            success = '#28a745',
            warning = '#ffc107',
            danger = '#dc3545',
            info = '#17a2b8'
        },
        
        -- Component Colors
        health = '#ff4444',
        armor = '#00bcd4',
        hunger = '#ffb74d',
        thirst = '#29b6f6',
        stress = '#a020f0',
        stamina = '#66bb6a'
    },
    
    -- Typography
    fonts = {
        primary = 'Orbitron',
        secondary = 'Roboto',
        monospace = 'Monaco'
    },
    
    -- Animation Settings
    animations = {
        enabled = true,
        fadeTime = 300,
        slideTime = 250,
        scaleTime = 200,
        bounceTime = 400,
        
        -- Easing Functions
        easing = {
            default = 'ease-out',
            smooth = 'cubic-bezier(0.4, 0, 0.2, 1)',
            bounce = 'cubic-bezier(0.68, -0.55, 0.265, 1.55)'
        }
    },
    
    -- Visual Effects
    effects = {
        shadows = true,
        glow = false,
        blur = false,
        gradients = true,
        borderRadius = 8,
        
        -- Shadow Definitions
        shadowLevels = {
            small = '0 2px 4px rgba(0, 0, 0, 0.3)',
            medium = '0 4px 8px rgba(0, 0, 0, 0.4)',
            large = '0 8px 16px rgba(0, 0, 0, 0.5)'
        }
    },
    
    -- Component-Specific Styles
    components = {
        statusBars = {
            height = '8px',
            borderRadius = '4px',
            background = 'rgba(255, 255, 255, 0.2)',
            animationType = 'smooth'
        },
        
        minimap = {
            borderRadius = '12px',
            borderWidth = '2px',
            shadowLevel = 'medium'
        },
        
        speedometer = {
            fontSize = '24px',
            fontWeight = 'bold',
            glowEffect = true
        }
    },
    
    -- Responsive Breakpoints
    responsive = {
        mobile = '768px',
        tablet = '1024px',
        desktop = '1200px'
    }
}
```

---

## 🛠️ Creating Custom Themes

### Step 1: Theme File Structure

Create your theme file in `themes/custom/your-theme.lua`:

```lua
-- themes/custom/neon-purple.lua
local theme = {
    name = 'neon_purple',
    displayName = 'Neon Purple',
    version = '1.0.0',
    author = 'YourName',
    description = 'Purple cyberpunk theme with neon effects',
    
    colors = {
        primary = '#a020f0',
        secondary = '#7b1fa2',
        background = 'rgba(20, 0, 40, 0.9)',
        
        text = {
            primary = '#ffffff',
            secondary = '#e1bee7',
            muted = '#9c27b0'
        },
        
        status = {
            success = '#4caf50',
            warning = '#ff9800',
            danger = '#f44336',
            info = '#2196f3'
        },
        
        -- Custom component colors
        health = '#ff1744',
        armor = '#00e5ff',
        hunger = '#ffab00',
        thirst = '#00b8d4',
        stress = '#d500f9',
        stamina = '#76ff03'
    },
    
    animations = {
        enabled = true,
        fadeTime = 400,
        slideTime = 300,
        scaleTime = 250,
        
        easing = {
            default = 'cubic-bezier(0.4, 0, 0.2, 1)',
            bounce = 'cubic-bezier(0.68, -0.55, 0.265, 1.55)'
        }
    },
    
    effects = {
        glow = true,
        shadows = true,
        gradients = true,
        borderRadius = 12,
        
        -- Custom glow effects
        glowIntensity = 'medium',
        glowColor = '#a020f0'
    },
    
    components = {
        statusBars = {
            height = '10px',
            borderRadius = '6px',
            glowEffect = true,
            animationType = 'pulse'
        }
    }
}

return theme
```

### Step 2: CSS Implementation

Create corresponding CSS file `themes/custom/neon-purple.css`:

```css
/* Neon Purple Theme CSS */
.hud-container.theme-neon-purple {
    --primary-color: #a020f0;
    --secondary-color: #7b1fa2;
    --background-color: rgba(20, 0, 40, 0.9);
    --text-color: #ffffff;
    --glow-color: #a020f0;
    
    /* Component Variables */
    --health-color: #ff1744;
    --armor-color: #00e5ff;
    --hunger-color: #ffab00;
    --thirst-color: #00b8d4;
    --stress-color: #d500f9;
    --stamina-color: #76ff03;
}

/* Status Bar Styling */
.theme-neon-purple .status-bar {
    height: 10px;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(5px);
    box-shadow: 
        0 0 10px var(--glow-color),
        inset 0 1px 2px rgba(255, 255, 255, 0.2);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.theme-neon-purple .status-bar-fill {
    border-radius: 6px;
    box-shadow: 0 0 15px currentColor;
    animation: pulse 2s infinite;
}

/* Pulse Animation */
@keyframes pulse {
    0%, 100% { 
        opacity: 1;
        transform: scale(1);
    }
    50% { 
        opacity: 0.8;
        transform: scale(1.02);
    }
}

/* Glow Effects */
.theme-neon-purple .glow-element {
    filter: drop-shadow(0 0 10px var(--glow-color));
}

/* Component Specific Styles */
.theme-neon-purple .minimap-container {
    border-radius: 12px;
    border: 2px solid var(--primary-color);
    box-shadow: 
        0 8px 32px rgba(160, 32, 240, 0.3),
        inset 0 2px 4px rgba(255, 255, 255, 0.1);
}

.theme-neon-purple .speedometer {
    background: linear-gradient(145deg, 
        rgba(160, 32, 240, 0.2), 
        rgba(20, 0, 40, 0.8));
    border: 1px solid var(--primary-color);
    box-shadow: 0 0 20px var(--glow-color);
}
```

### Step 3: Register Your Theme

Add to your client initialization:

```lua
-- Register custom theme
ThemeManager.registerTheme(require('themes.custom.neon-purple'))

-- Set as default (optional)
ThemeManager.setTheme('neon_purple')
```

---

## 📥 Theme Installation

### Manual Installation

1. **Copy theme files** to `themes/custom/` directory
2. **Add CSS files** to `html/css/themes/` directory
3. **Register theme** in client script
4. **Restart resource** or use `/hud reload`

### Automatic Installation

```lua
-- Use theme installer
ThemeInstaller.install('neon_purple', {
    source = 'url_or_path',
    autoEnable = true
})
```

### Theme Package Format

```
theme-package.zip
├── theme.lua          -- Theme definition
├── style.css          -- CSS styles
├── assets/            -- Optional assets
│   ├── icons/
│   ├── fonts/
│   └── images/
├── preview.png        -- Theme preview
└── README.md          -- Installation instructions
```

---

## ⚙️ Theme Configuration

### Global Theme Settings

```lua
-- config.lua
Config.Theme = {
    default = 'neon',           -- Default theme
    allowUserChange = true,     -- Allow players to change themes
    saveUserChoice = true,      -- Remember player's choice
    preloadThemes = {           -- Themes to preload
        'default',
        'neon', 
        'minimal'
    }
}
```

### Per-Player Theme Settings

```lua
-- Save player's theme preference
TriggerServerEvent('hud:saveThemePreference', 'neon_purple')

-- Load player's theme preference
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local playerData = QBCore.Functions.GetPlayerData()
    local savedTheme = playerData.metadata.hudTheme or Config.Theme.default
    
    ThemeManager.setTheme(savedTheme)
end)
```

### Component-Specific Overrides

```lua
-- Override specific component styling
ThemeManager.setComponentStyle('StatusBars', {
    height = '12px',
    borderRadius = '8px',
    animationType = 'bounce'
})
```

---

## 🎨 Advanced Customization

### Dynamic Color Systems

```lua
-- Create color variants
local baseTheme = ThemeManager.getTheme('neon')
local variants = {
    red = ThemeManager.createVariant(baseTheme, { primary = '#ff0000' }),
    green = ThemeManager.createVariant(baseTheme, { primary = '#00ff00' }),
    blue = ThemeManager.createVariant(baseTheme, { primary = '#0000ff' })
}
```

### Conditional Theming

```lua
-- Different themes based on conditions
Citizen.CreateThread(function()
    while true do
        local hour = GetClockHours()
        
        if hour >= 6 and hour < 18 then
            -- Day theme
            ThemeManager.setTheme('minimal')
        else
            -- Night theme
            ThemeManager.setTheme('dark')
        end
        
        Citizen.Wait(60000) -- Check every minute
    end
end)
```

### Animation Customization

```lua
-- Custom animation presets
local customAnimations = {
    name = 'bounce_in',
    keyframes = {
        '0%' = {
            transform = 'scale(0.3)',
            opacity = 0
        },
        '50%' = {
            transform = 'scale(1.05)'
        },
        '70%' = {
            transform = 'scale(0.9)'
        },
        '100%' = {
            transform = 'scale(1)',
            opacity = 1
        }
    },
    duration = '0.6s',
    easing = 'ease-out'
}

ThemeManager.registerAnimation(customAnimations)
```

### Gradient Generators

```lua
-- Generate gradient backgrounds
function CreateGradient(color1, color2, direction)
    direction = direction or '145deg'
    return string.format('linear-gradient(%s, %s, %s)', direction, color1, color2)
end

-- Usage in theme
local theme = {
    colors = {
        backgroundGradient = CreateGradient('#a020f0', '#1a1a1a', '145deg')
    }
}
```

---

## 🔧 Theme APIs

### ThemeManager Functions

```lua
-- Get current theme
local currentTheme = ThemeManager.getTheme()

-- Set theme
ThemeManager.setTheme('neon')

-- Get available themes
local themes = ThemeManager.getAvailableThemes()

-- Register new theme
ThemeManager.registerTheme(themeObject)

-- Remove theme
ThemeManager.unregisterTheme('theme_name')

-- Create theme variant
local variant = ThemeManager.createVariant('base_theme', {
    primary = '#ff0000'
})

-- Validate theme
local isValid = ThemeManager.validateTheme(themeObject)

-- Export theme
local exportData = ThemeManager.exportTheme('theme_name')

-- Import theme
ThemeManager.importTheme(exportData)
```

### Color Utilities

```lua
-- Color manipulation functions
local ColorUtils = ThemeManager.ColorUtils

-- Lighten color
local lightColor = ColorUtils.lighten('#a020f0', 0.2)

-- Darken color
local darkColor = ColorUtils.darken('#a020f0', 0.3)

-- Add transparency
local transparentColor = ColorUtils.alpha('#a020f0', 0.8)

-- Generate color palette
local palette = ColorUtils.generatePalette('#a020f0')

-- Get contrasting text color
local textColor = ColorUtils.getContrastColor('#a020f0')
```

### Component Styling

```lua
-- Apply theme to specific component
ThemeManager.applyToComponent('StatusBars', themeName)

-- Get component theme data
local componentTheme = ThemeManager.getComponentTheme('StatusBars')

-- Override component style
ThemeManager.overrideComponentStyle('StatusBars', {
    height = '10px',
    borderRadius = '6px'
})
```

---

## ⚡ Performance Considerations

### Optimization Best Practices

1. **CSS Variables** - Use CSS custom properties for dynamic theming
2. **Preload Critical Themes** - Load commonly used themes at startup
3. **Lazy Loading** - Load theme assets only when needed
4. **Minimize Repaints** - Use transform/opacity for animations
5. **Efficient Selectors** - Avoid complex CSS selectors

### Performance Monitoring

```lua
-- Monitor theme performance
local ThemePerformance = {
    switchTime = 0,
    memoryUsage = 0,
    renderTime = 0
}

function MonitorThemeSwitch(themeName)
    local startTime = GetGameTimer()
    
    ThemeManager.setTheme(themeName)
    
    ThemePerformance.switchTime = GetGameTimer() - startTime
    print('Theme switch took: ' .. ThemePerformance.switchTime .. 'ms')
end
```

### Memory Management

```lua
-- Clean up unused themes
function CleanupThemes()
    local currentTheme = ThemeManager.getTheme()
    local registeredThemes = ThemeManager.getAvailableThemes()
    
    for _, themeName in ipairs(registeredThemes) do
        if themeName ~= currentTheme and not Config.Theme.preloadThemes[themeName] then
            ThemeManager.unloadTheme(themeName)
        end
    end
end
```

---

## 🎯 Theme Examples

### Gaming Theme

```lua
local gamingTheme = {
    name = 'gaming',
    displayName = 'Gaming Pro',
    
    colors = {
        primary = '#00ff41',
        secondary = '#003d16',
        background = 'rgba(0, 0, 0, 0.95)',
        
        health = '#ff0000',
        armor = '#0080ff',
        stamina = '#00ff00'
    },
    
    effects = {
        glow = true,
        shadows = false,
        borderRadius = 4
    },
    
    animations = {
        enabled = true,
        fadeTime = 150,
        slideTime = 100
    }
}
```

### Roleplay Theme

```lua
local roleplayTheme = {
    name = 'roleplay',
    displayName = 'Roleplay Immersive',
    
    colors = {
        primary = '#8b4513',
        secondary = '#daa520',
        background = 'rgba(20, 15, 10, 0.8)',
        
        text = {
            primary = '#f5deb3',
            secondary = '#daa520'
        }
    },
    
    fonts = {
        primary = 'Cinzel',
        secondary = 'Libre Baskerville'
    },
    
    effects = {
        shadows = true,
        glow = false,
        borderRadius = 8
    }
}
```

---

## 🧪 Testing Themes

### Theme Validation

```lua
-- Validate theme structure
function ValidateTheme(theme)
    local required = {'name', 'colors', 'animations'}
    
    for _, field in ipairs(required) do
        if not theme[field] then
            return false, 'Missing required field: ' .. field
        end
    end
    
    -- Validate colors
    if not theme.colors.primary or not theme.colors.background then
        return false, 'Missing required colors'
    end
    
    return true, 'Valid theme'
end
```

### Live Theme Editor

```lua
-- Create live theme editor for testing
function OpenThemeEditor()
    SendNUIMessage({
        action = 'openThemeEditor',
        currentTheme = ThemeManager.getTheme(),
        availableThemes = ThemeManager.getAvailableThemes()
    })
    
    SetNuiFocus(true, true)
end

-- Apply theme changes in real-time
RegisterNUICallback('previewThemeChanges', function(data, cb)
    local tempTheme = data.theme
    ThemeManager.previewTheme(tempTheme)
    cb('ok')
end)
```

---

## 📚 Resources

### Theme Development Tools

- **Color Palette Generators**
  - [Coolors.co](https://coolors.co/)
  - [Adobe Color](https://color.adobe.com/)
  - [Paletton](https://paletton.com/)

- **CSS Animation Tools**
  - [Animate.css](https://animate.style/)
  - [Cubic-bezier.com](https://cubic-bezier.com/)
  - [Keyframes.app](https://keyframes.app/)

- **Font Resources**
  - [Google Fonts](https://fonts.google.com/)
  - [Font Squirrel](https://www.fontsquirrel.com/)

### Community Themes

Check the community repository for user-contributed themes:
- [HUD Themes Collection](https://github.com/community/hud-themes)
- [Discord Theme Sharing](https://discord.gg/hudthemes)

---

## 🆘 Troubleshooting

### Common Issues

**Theme not loading:**
- Check file paths and naming
- Verify CSS syntax
- Ensure theme is registered

**Performance issues:**
- Disable complex animations
- Reduce glow effects
- Use performance mode

**Color not applying:**
- Check CSS variable names
- Verify color format (hex, rgba)
- Clear browser cache

### Debug Mode

```lua
-- Enable theme debug mode
ThemeManager.setDebugMode(true)

-- Check theme loading issues
ThemeManager.validateAllThemes()

-- Monitor theme performance
ThemeManager.enablePerformanceMonitoring()
```

---

*Happy theming! Create something amazing! 🎨*

---

*Last Updated: August 2025*