--[[
    🎨 Enhanced HUD - Themes Module
    
    Handles:
    - Neon theme system management
    - Visual effects and glow triggers
    - Critical alerts with visual feedback
    - Theme switching and persistence
    - Animation system integration
]]

local QBCore = exports['qb-core']:GetCoreObject()

HudThemes = {}
HudThemes.CurrentTheme = 'cyberpunk'
HudThemes.AvailableThemes = {
    cyberpunk = {
        name = 'cyberpunk',
        label = 'Cyberpunk',
        primary = '#00ffff',
        secondary = '#ff0080',
        accent = '#00ff41'
    },
    synthwave = {
        name = 'synthwave',
        label = 'Synthwave',
        primary = '#ff0080',
        secondary = '#8000ff',
        accent = '#00ffff'
    },
    matrix = {
        name = 'matrix',
        label = 'Matrix',
        primary = '#00ff41',
        secondary = '#008f11',
        accent = '#ffffff'
    }
}

-- Effect tracking
local criticalAlertActive = false
local glowEffectQueue = {}
local lastGlowTime = 0

--[[
    🎬 Initialize Theme System
]]
function HudThemes:Initialize()
    print("^2[HUD-THEMES]^7 Initializing theme system...")
    
    -- Load saved theme
    self:LoadSavedTheme()
    
    -- Register theme callbacks
    self:RegisterThemeCallbacks()
    
    -- Register event handlers
    self:RegisterEventHandlers()
    
    -- Start effect processing loop
    self:StartEffectProcessor()
    
    print("^2[HUD-THEMES]^7 Theme system initialized with theme: " .. self.CurrentTheme)
end

--[[
    🎨 Load Saved Theme
]]
function HudThemes:LoadSavedTheme()
    -- Try to get from settings
    if HudSettings and HudSettings.Menu and HudSettings.Menu.currentNeonTheme then
        self.CurrentTheme = HudSettings.Menu.currentNeonTheme
    else
        -- Fallback to stored KVP
        local savedTheme = GetResourceKvpString('currentNeonTheme')
        if savedTheme and self.AvailableThemes[savedTheme] then
            self.CurrentTheme = savedTheme
        end
    end
    
    -- Apply the theme
    self:SetTheme(self.CurrentTheme)
end

--[[
    🎭 Set Active Theme
]]
function HudThemes:SetTheme(themeName)
    if not self.AvailableThemes[themeName] then
        print("^1[HUD-THEMES-ERROR]^7 Invalid theme: " .. tostring(themeName))
        return false
    end
    
    local oldTheme = self.CurrentTheme
    self.CurrentTheme = themeName
    
    -- Send theme change to NUI
    local success, error = pcall(function()
        SendNUIMessage({
            action = 'changeTheme',
            theme = themeName,
            themeData = self.AvailableThemes[themeName],
            oldTheme = oldTheme
        })
    end)
    
    if not success then
        print("^1[HUD-THEMES-ERROR]^7 Failed to send theme to NUI: " .. tostring(error))
        return false
    end
    
    -- Save theme preference
    if HudSettings then
        HudSettings:SetSetting('currentNeonTheme', themeName, true)
    else
        SetResourceKvp('currentNeonTheme', themeName)
    end
    
    -- Trigger theme change effect
    self:TriggerThemeChangeEffect(themeName)
    
    print("^2[HUD-THEMES]^7 Theme changed to: " .. themeName)
    return true
end

--[[
    ✨ Trigger Glow Effect
]]
function HudThemes:TriggerGlow(element, color, intensity, duration)
    intensity = intensity or 1.0
    duration = duration or 2000
    color = color or self.AvailableThemes[self.CurrentTheme].primary
    
    -- Performance check: limit glow effects
    local currentTime = GetGameTimer()
    if currentTime - lastGlowTime < 100 then -- Max 10 glows per second
        return
    end
    lastGlowTime = currentTime
    
    -- Queue the effect
    table.insert(glowEffectQueue, {
        element = element,
        color = color,
        intensity = intensity,
        duration = duration,
        timestamp = currentTime
    })
    
    -- Send to NUI immediately
    local success, error = pcall(function()
        SendNUIMessage({
            action = 'triggerGlow',
            element = element,
            color = color,
            intensity = intensity,
            duration = duration,
            timestamp = currentTime
        })
    end)
    
    if not success then
        print("^1[HUD-THEMES-ERROR]^7 Failed to trigger glow: " .. tostring(error))
    end
end

--[[
    🚨 Trigger Critical Alert
]]
function HudThemes:TriggerCriticalAlert(statType, value)
    if criticalAlertActive then return end
    
    local threshold = Config.CriticalThreshold or 20
    local stressThreshold = Config.StressCriticalThreshold or 80
    
    -- Check if it's actually critical
    local isCritical = false
    if statType == 'stress' and value >= stressThreshold then
        isCritical = true
    elseif statType ~= 'stress' and value <= threshold then
        isCritical = true
    end
    
    if not isCritical then return end
    
    criticalAlertActive = true
    
    -- Critical alert colors
    local alertColors = {
        health = '#ff4444',
        armor = '#ff9800',
        hunger = '#ffb74d',
        thirst = '#29b6f6',
        stress = '#a020f0',
        oxygen = '#66bb6a'
    }
    
    local alertColor = alertColors[statType] or '#ff4444'
    
    -- Trigger enhanced glow effect
    self:TriggerGlow(statType, alertColor, 1.5, 3000)
    
    -- Send critical alert to NUI
    local success, error = pcall(function()
        SendNUIMessage({
            action = 'criticalAlert',
            statType = statType,
            value = value,
            color = alertColor,
            threshold = statType == 'stress' and stressThreshold or threshold
        })
    end)
    
    if not success then
        print("^1[HUD-THEMES-ERROR]^7 Failed to send critical alert: " .. tostring(error))
    end
    
    -- Play critical alert sound
    if HudSettings and HudSettings:GetSetting('isResetSoundsChecked', true) then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'critical_alert', 0.3)
    end
    
    -- Screen effect for severe critical states
    if value <= 10 or (statType == 'stress' and value >= 90) then
        self:TriggerScreenEffect(statType, alertColor)
    end
    
    -- Reset critical alert flag after delay
    SetTimeout(3000, function()
        criticalAlertActive = false
    end)
    
    print("^3[HUD-THEMES]^7 Critical alert triggered: " .. statType .. " = " .. value)
end

--[[
    📺 Trigger Screen Effect for Severe Critical States
]]
function HudThemes:TriggerScreenEffect(statType, color)
    local effectName = 'MP_health_loss'
    
    -- Different effects based on stat type
    if statType == 'health' then
        effectName = 'MP_health_loss'
    elseif statType == 'hunger' or statType == 'thirst' then
        effectName = 'MP_corona_switch'
    elseif statType == 'stress' then
        effectName = 'HeistLocate'
    elseif statType == 'oxygen' then
        effectName = 'MP_OrbitalCannon'
    end
    
    -- Trigger screen effect
    CreateThread(function()
        local duration = 2000
        local startTime = GetGameTimer()
        
        while GetGameTimer() - startTime < duration do
            SetTimecycleModifier(effectName)
            SetTimecycleModifierStrength(0.3)
            Wait(100)
        end
        
        ClearTimecycleModifier()
    end)
end

--[[
    🎪 Trigger Theme Change Effect
]]
function HudThemes:TriggerThemeChangeEffect(themeName)
    local themeData = self.AvailableThemes[themeName]
    if not themeData then return end
    
    -- Screen flash effect
    self:TriggerGlow('theme-change', themeData.primary, 2.0, 1500)
    
    -- Sound effect
    if HudSettings and HudSettings:GetSetting('isListSoundsChecked', true) then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'theme_change', 0.4)
    end
    
    -- Particle effect
    SendNUIMessage({
        action = 'themeChangeEffect',
        theme = themeName,
        colors = {
            primary = themeData.primary,
            secondary = themeData.secondary,
            accent = themeData.accent
        }
    })
end

--[[
    🎮 Process Effect Queue
]]
function HudThemes:StartEffectProcessor()
    CreateThread(function()
        while true do
            local currentTime = GetGameTimer()
            
            -- Clean up expired effects
            for i = #glowEffectQueue, 1, -1 do
                local effect = glowEffectQueue[i]
                if currentTime - effect.timestamp >= effect.duration then
                    table.remove(glowEffectQueue, i)
                end
            end
            
            -- Performance monitoring
            if #glowEffectQueue > 20 then
                print("^3[HUD-THEMES-WARNING]^7 Too many glow effects queued: " .. #glowEffectQueue)
                -- Clear oldest effects
                for i = 1, 10 do
                    table.remove(glowEffectQueue, 1)
                end
            end
            
            Wait(500) -- Check every 500ms
        end
    end)
end

--[[
    📡 Register Theme NUI Callbacks
]]
function HudThemes:RegisterThemeCallbacks()
    -- Theme selection
    RegisterNUICallback('selectTheme', function(data, cb)
        if data.theme and self.AvailableThemes[data.theme] then
            self:SetTheme(data.theme)
            HudThemes:TriggerGlow('theme-select', self.AvailableThemes[data.theme].primary, 1.0)
        end
        cb('ok')
    end)
    
    -- Manual glow trigger (for testing/effects)
    RegisterNUICallback('triggerManualGlow', function(data, cb)
        if data.element and data.color then
            self:TriggerGlow(data.element, data.color, data.intensity or 1.0, data.duration or 2000)
        end
        cb('ok')
    end)
    
    -- Get current theme info
    RegisterNUICallback('getCurrentTheme', function(_, cb)
        cb({
            currentTheme = self.CurrentTheme,
            themeData = self.AvailableThemes[self.CurrentTheme],
            availableThemes = self.AvailableThemes
        })
    end)
end

--[[
    📡 Register Event Handlers
]]
function HudThemes:RegisterEventHandlers()
    -- Theme change from server/other sources
    RegisterNetEvent('hud:client:ChangeTheme', function(themeName)
        self:SetTheme(themeName)
    end)
    
    -- Manual glow trigger from server
    RegisterNetEvent('hud:client:TriggerGlow', function(element, color, intensity)
        self:TriggerGlow(element, color, intensity)
    end)
    
    -- Critical alert from server
    RegisterNetEvent('hud:client:CriticalAlert', function(statType, value)
        self:TriggerCriticalAlert(statType, value)
    end)
    
    -- Theme sync request
    RegisterNetEvent('hud:client:SyncTheme', function(themeName)
        if themeName and self.AvailableThemes[themeName] then
            self.CurrentTheme = themeName
            SendNUIMessage({
                action = 'syncTheme',
                theme = themeName,
                themeData = self.AvailableThemes[themeName]
            })
        end
    end)
    
    -- Value change animations
    RegisterNetEvent('hud:client:AnimateValueChange', function(statType, oldValue, newValue, speed)
        speed = speed or 'normal'
        
        SendNUIMessage({
            action = 'animateValueChange',
            statType = statType,
            oldValue = oldValue,
            newValue = newValue,
            speed = speed
        })
        
        -- Trigger glow for significant changes
        local difference = math.abs(newValue - oldValue)
        if difference >= 20 then
            local color = self.AvailableThemes[self.CurrentTheme].primary
            if newValue < oldValue then
                color = '#ff4444' -- Red for decrease
            else
                color = '#00ff41' -- Green for increase
            end
            self:TriggerGlow(statType, color, 0.8)
        end
    end)
end

--[[
    🔧 Utility Functions
]]
function HudThemes:GetCurrentTheme()
    return {
        name = self.CurrentTheme,
        data = self.AvailableThemes[self.CurrentTheme]
    }
end

function HudThemes:GetThemeColor(colorType)
    colorType = colorType or 'primary'
    local theme = self.AvailableThemes[self.CurrentTheme]
    return theme[colorType] or theme.primary
end

function HudThemes:IsValidTheme(themeName)
    return self.AvailableThemes[themeName] ~= nil
end

function HudThemes:GetAvailableThemes()
    local themes = {}
    for name, data in pairs(self.AvailableThemes) do
        themes[name] = {
            name = data.name,
            label = data.label
        }
    end
    return themes
end

--[[
    🎯 Animation Helpers
]]
function HudThemes:AnimateStatChange(statType, oldValue, newValue)
    local animationSpeed = 'normal'
    
    -- Determine animation speed based on change magnitude
    local difference = math.abs(newValue - oldValue)
    if difference >= 30 then
        animationSpeed = 'fast'
    elseif difference <= 5 then
        animationSpeed = 'slow'
    end
    
    TriggerEvent('hud:client:AnimateValueChange', statType, oldValue, newValue, animationSpeed)
end

function HudThemes:TriggerStatGlow(statType, value)
    local colors = {
        health = '#ff4444',
        armor = '#00bcd4',
        hunger = '#ffb74d',
        thirst = '#29b6f6',
        stress = '#a020f0',
        oxygen = '#66bb6a',
        stamina = '#66bb6a'
    }
    
    local color = colors[statType] or self:GetThemeColor('primary')
    self:TriggerGlow(statType, color, 0.8)
end

--[[
    🔧 Exports
]]
exports('GetHudThemes', function()
    return HudThemes
end)

exports('TriggerGlow', function(element, color, intensity, duration)
    HudThemes:TriggerGlow(element, color, intensity, duration)
end)

exports('SetTheme', function(themeName)
    return HudThemes:SetTheme(themeName)
end)

exports('GetCurrentTheme', function()
    return HudThemes:GetCurrentTheme()
end)

exports('TriggerCriticalAlert', function(statType, value)
    HudThemes:TriggerCriticalAlert(statType, value)
end)

print("^2[HUD-THEMES]^7 Module loaded successfully")