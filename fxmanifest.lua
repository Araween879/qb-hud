fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Enhanced HUD System'
description 'Professional HUD system with advanced features, performance optimization, and Vue.js frontend'
author 'QBCore Development Team'
version '3.2.0'

-- Dependencies
dependencies {
    'qb-core',
    'oxmysql' -- or 'ghmattimysql'
}

-- Main entry points
client_script 'client.lua'
server_script 'server.lua'

-- Core module system
client_scripts {
    'config.lua',
    'modules/hud-core.lua',
    'modules/hud-events.lua',
    'modules/hud-settings.lua',
    'modules/hud-themes.lua',
    'modules/hud-vehicle.lua',
    'modules/hud-map.lua',
    'qb-hud-compatibility.lua' -- Backward compatibility
}

-- Server-side modules
server_scripts {
    'config.lua',
    'server/hud-persistence.lua'
}

-- NUI Frontend (Vue.js)
ui_page 'html/index.html'

files {
    -- Main HTML
    'html/index.html',
    'html/gps-hud.html',
    
    -- Vue.js Application
    'html/app.js',
    'html/styles.css',
    'html/responsive.css',
    
    -- JavaScript Module System
    'html/js/state-manager.js',
    'html/js/event-manager.js',
    'html/js/theme-manager.js',
    'html/js/hud-controller.js',
    'html/js/component-manager.js',
    
    -- CSS Architecture
    'html/css/design-tokens.css',
    'html/css/core.css',
    'html/css/themes.css',
    'html/css/components.css',
    'html/css/z-index-system.css',
    'html/css/performance-mode.css',
    
    -- Assets
    'html/assets/images/*.png',
    'html/assets/images/*.jpg',
    'html/assets/images/*.svg',
    'html/assets/particles/*.png',
    'html/assets/fonts/*.woff2',
    'html/assets/sounds/*.ogg',
    'html/assets/sounds/*.mp3'
}

-- Localization
client_scripts {
    'locales/en.lua',
    'locales/de.lua',
    'locales/fr.lua',
    'locales/es.lua',
    'locales/nl.lua'
}

-- Development tools (only in debug mode)
if GetConvar('hud_debug', 'false') == 'true' then
    client_scripts {
        'tests/test-runner.lua',
        'tests/module-tests.lua',
        'tests/integration-tests.lua',
        'tests/performance-tests.lua'
    }
end

-- Export system
exports {
    -- Legacy qb-hud compatibility
    'hideHud',
    'showHud',
    'toggleHud',
    'updateStatus',
    'setVisible',
    
    -- Enhanced features
    'getHudCore',
    'getCurrentStatus',
    'forceStatusUpdate',
    'setTheme',
    'getPerformanceMode',
    'registerComponent',
    'updateComponent'
}

-- Provide exports for external resources
provide 'enhanced-hud'

-- Version checking
version_check 'https://api.github.com/repos/qbcore/enhanced-hud/releases/latest'