/**
 * 🧩 Enhanced HUD - Component Manager System
 * 
 * Vue.js component coordination and management:
 * - Component lifecycle management
 * - Props and data synchronization
 * - Menu system coordination
 * - UI state management
 * - Performance optimization
 */

class HudComponentManager {
    constructor(
        stateManager = window.hudState,
        hudController = window.hudController,
        themeManager = window.hudThemeManager,
        eventManager = window.hudEventManager
    ) {
        this.stateManager = stateManager;
        this.hudController = hudController;
        this.themeManager = themeManager;
        this.eventManager = eventManager;
        
        // Component instances
        this.vueApp = null;
        this.components = new Map();
        this.activeMenus = new Set();
        
        // Component data
        this.componentData = {
            // Player stats for HUD
            playerStats: {
                health: 100,
                armor: 0,
                hunger: 100,
                thirst: 100,
                stress: 0,
                stamina: 100,
                oxygen: 100
            },
            
            // Settings for menu
            settings: {
                hudVisible: true,
                showHealth: true,
                showArmor: true,
                showHunger: true,
                showThirst: true,
                showStress: true,
                showStamina: true,
                showOxygen: true,
                hudOpacity: 1.0,
                performanceMode: false,
                animationsEnabled: true,
                debugMode: false
            },
            
            // Theme system
            currentTheme: 'cyberpunk',
            availableThemes: [
                {
                    name: 'cyberpunk',
                    label: 'Cyberpunk Protocol',
                    description: 'High-tech cyan and purple aesthetic',
                    preview: 'linear-gradient(45deg, #00ffff, #a020f0)'
                },
                {
                    name: 'synthwave',
                    label: 'Synthwave Protocol',
                    description: 'Retro-futuristic pink and blue neon',
                    preview: 'linear-gradient(45deg, #ff0080, #8000ff)'
                },
                {
                    name: 'matrix',
                    label: 'Matrix Protocol',
                    description: 'Classic green matrix code aesthetic',
                    preview: 'linear-gradient(45deg, #00ff00, #008000)'
                }
            ],
            
            // Module status for debug
            moduleStatus: {
                stateManager: false,
                themeManager: false,
                eventManager: false,
                hudController: false,
                componentManager: false
            },
            
            // UI state
            menuOpen: false,
            settingsMenuOpen: false,
            tab: 'display',
            splitterModel: 20
        };
        
        // Performance tracking
        this.updateCount = 0;
        this.lastPerformanceCheck = Date.now();
        
        this.initialize();
    }
    
    /**
     * Initialize component manager
     */
    initialize() {
        this.log('Component Manager initializing...');
        
        // Check module status
        this.checkModuleStatus();
        
        // Setup component data reactivity
        this.setupDataReactivity();
        
        // Initialize Vue application
        this.initializeVueApp();
        
        // Setup component event listeners
        this.setupComponentEvents();
        
        // Setup state synchronization
        this.setupStateSynchronization();
        
        this.log('Component Manager initialized');
    }
    
    /**
     * Check module status
     */
    checkModuleStatus() {
        this.componentData.moduleStatus = {
            stateManager: !!this.stateManager,
            themeManager: !!this.themeManager,
            eventManager: !!this.eventManager,
            hudController: !!this.hudController,
            componentManager: true
        };
        
        const loadedModules = Object.values(this.componentData.moduleStatus).filter(Boolean).length;
        this.log(`Module status: ${loadedModules}/5 modules loaded`);
    }
    
    /**
     * Setup data reactivity with state manager
     */
    setupDataReactivity() {
        if (!this.stateManager) return;
        
        // Initialize state with component data
        this.stateManager.initialize({
            playerStats: this.componentData.playerStats,
            settings: this.componentData.settings,
            currentTheme: this.componentData.currentTheme,
            menuOpen: this.componentData.menuOpen,
            settingsMenuOpen: this.componentData.settingsMenuOpen
        });
        
        // Setup bidirectional sync
        this.setupBidirectionalSync();
    }
    
    /**
     * Setup bidirectional synchronization
     */
    setupBidirectionalSync() {
        // State → Component Data
        this.stateManager.subscribe('playerStats', (newStats) => {
            Object.assign(this.componentData.playerStats, newStats);
            this.updateVueData('playerStats', this.componentData.playerStats);
        });
        
        this.stateManager.subscribe('settings', (newSettings) => {
            Object.assign(this.componentData.settings, newSettings);
            this.updateVueData('settings', this.componentData.settings);
        });
        
        this.stateManager.subscribe('currentTheme', (newTheme) => {
            this.componentData.currentTheme = newTheme;
            this.updateVueData('currentTheme', newTheme);
        });
        
        this.stateManager.subscribe('menuOpen', (isOpen) => {
            this.componentData.menuOpen = isOpen;
            this.handleMenuStateChange('main', isOpen);
        });
        
        this.stateManager.subscribe('settingsMenuOpen', (isOpen) => {
            this.componentData.settingsMenuOpen = isOpen;
            this.handleMenuStateChange('settings', isOpen);
        });
    }
    
    /**
     * Initialize Vue application - COMPLETE VERSION
     */
    initializeVueApp() {
        if (!window.Vue) {
            this.error('Vue.js not loaded');
            return;
        }
        
        const { createApp } = Vue;
        const self = this;
        
        this.vueApp = createApp({
            data() {
                return {
                    // Copy component data to Vue
                    playerStats: { ...self.componentData.playerStats },
                    settings: { ...self.componentData.settings },
                    currentTheme: self.componentData.currentTheme,
                    availableThemes: [...self.componentData.availableThemes],
                    moduleStatus: { ...self.componentData.moduleStatus },
                    menuOpen: self.componentData.menuOpen,
                    settingsMenuOpen: self.componentData.settingsMenuOpen,
                    tab: self.componentData.tab,
                    splitterModel: self.componentData.splitterModel
                };
            },
            
            computed: {
                hudOpacityStyle() {
                    return {
                        opacity: this.settings.hudOpacity
                    };
                },
                
                criticalStats() {
                    const critical = {};
                    Object.keys(this.playerStats).forEach(key => {
                        critical[key] = this.playerStats[key] <= 20;
                    });
                    return critical;
                },
                
                themeClasses() {
                    return `theme-${this.currentTheme}`;
                }
            },
            
            methods: {
                // === MENU METHODS ===
                openMenu() {
                    this.menuOpen = true;
                    self.openMenu('main');
                },
                
                closeMenu() {
                    this.menuOpen = false;
                    self.closeMenu('main');
                },
                
                openSettings() {
                    this.settingsMenuOpen = true;
                    self.openMenu('settings');
                },
                
                closeSettings() {
                    this.settingsMenuOpen = false;
                    self.closeMenu('settings');
                },
                
                // === SETTINGS METHODS ===
                updateSetting(key, value) {
                    this.settings[key] = value;
                    self.updateSettings({ [key]: value });
                },
                
                resetSettings() {
                    self.resetSettings();
                },
                
                saveSettings() {
                    self.saveSettings();
                },
                
                // === THEME METHODS ===
                changeTheme(themeName) {
                    this.currentTheme = themeName;
                    self.updateTheme(themeName);
                    
                    // Apply theme class to body
                    document.body.className = document.body.className.replace(/theme-\w+/, '') + ` theme-${themeName}`;
                },
                
                // === SYSTEM METHODS ===
                restartHud() {
                    self.restartHud();
                },
                
                toggleDebugMode() {
                    this.settings.debugMode = !this.settings.debugMode;
                    self.updateSettings({ debugMode: this.settings.debugMode });
                },
                
                // === UTILITY METHODS ===
                formatValue(value, suffix = '') {
                    return Math.round(value) + suffix;
                },
                
                getStatIcon(statName) {
                    const icons = {
                        health: 'fa-heart',
                        armor: 'fa-shield-alt',
                        hunger: 'fa-hamburger',
                        thirst: 'fa-tint',
                        stress: 'fa-brain',
                        stamina: 'fa-running',
                        oxygen: 'fa-lungs'
                    };
                    return icons[statName] || 'fa-question';
                },
                
                getStatColor(statName, value) {
                    if (value <= 20) return 'var(--neon-red)';
                    if (value <= 50) return 'var(--neon-orange)';
                    return 'var(--neon-cyan)';
                }
            },
            
            mounted() {
                self.onVueMounted();
                self.log('Vue component mounted');
            },
            
            beforeUnmount() {
                self.onVueUnmounted();
                self.log('Vue component unmounted');
            },
            
            watch: {
                // Watch for changes and sync back to component manager
                settings: {
                    handler(newSettings) {
                        self.componentData.settings = { ...newSettings };
                        if (self.stateManager) {
                            self.stateManager.set('settings', newSettings);
                        }
                    },
                    deep: true
                },
                
                currentTheme(newTheme) {
                    self.componentData.currentTheme = newTheme;
                    if (self.stateManager) {
                        self.stateManager.set('currentTheme', newTheme);
                    }
                }
            }
        });
        
        // Use Quasar
        if (window.Quasar) {
            this.vueApp.use(window.Quasar.Quasar, {
                config: {
                    brand: {
                        primary: '#00ffff',
                        secondary: '#a020f0',
                        accent: '#ff9800',
                        dark: '#1a1a1a'
                    }
                }
            });
        }
        
        // Mount the app
        this.vueApp.mount('#app');
        
        this.log('Vue application initialized and mounted');
    }
    
    /**
     * Vue mounted callback
     */
    onVueMounted() {
        // Setup post-mount initialization
        this.setupMenuHandlers();
        this.syncInitialData();
        
        // Mark component manager as ready
        this.componentData.moduleStatus.componentManager = true;
        
        // Trigger initial updates
        this.updateAllComponents();
    }
    
    /**
     * Vue unmounted callback
     */
    onVueUnmounted() {
        // Cleanup
        this.cleanup();
    }
    
    /**
     * Setup menu handlers
     */
    setupMenuHandlers() {
        // Setup close menu handlers
        document.querySelectorAll('.closeMenu').forEach(button => {
            button.addEventListener('click', () => {
                this.closeMenu('main');
            });
        });
        
        document.querySelectorAll('.closeSettings').forEach(button => {
            button.addEventListener('click', () => {
                this.closeMenu('settings');
            });
        });
        
        // Setup escape key handler
        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                this.closeAllMenus();
            }
        });
    }
    
    /**
     * Sync initial data
     */
    syncInitialData() {
        if (this.hudController) {
            const hudData = this.hudController.getAllData();
            
            // Update player stats
            if (hudData.playerStats) {
                this.updatePlayerStats(hudData.playerStats);
            }
            
            // Update settings
            if (hudData.settings) {
                this.updateSettings(hudData.settings);
            }
        }
        
        if (this.themeManager) {
            const currentTheme = this.themeManager.getCurrentTheme();
            this.updateTheme(currentTheme);
        }
    }
    
    /**
     * Setup component event listeners
     */
    setupComponentEvents() {
        // Listen for HUD data updates
        document.addEventListener('hudDataUpdated', (event) => {
            this.handleHudDataUpdate(event.detail);
        });
        
        // Listen for theme changes
        document.addEventListener('themeChanged', (event) => {
            this.handleThemeChanged(event.detail);
        });
        
        // Listen for menu events
        document.addEventListener('menuOpened', (event) => {
            this.handleMenuOpened(event.detail);
        });
        
        document.addEventListener('settingsMenuOpened', (event) => {
            this.handleSettingsMenuOpened(event.detail);
        });
    }
    
    /**
     * Setup state synchronization
     */
    setupStateSynchronization() {
        // Sync with HUD Controller
        if (this.hudController) {
            setInterval(() => {
                this.syncWithHudController();
            }, 1000); // Sync every second
        }
        
        // Sync with Theme Manager
        if (this.themeManager) {
            setInterval(() => {
                this.syncWithThemeManager();
            }, 2000); // Sync every 2 seconds
        }
    }
    
    // === UPDATE METHODS ===
    
    /**
     * Update Vue data
     * @param {string} key - Data key
     * @param {*} value - New value
     */
    updateVueData(key, value) {
        if (!this.vueApp || !this.vueApp._instance) return;
        
        try {
            const instance = this.vueApp._instance;
            if (instance.data && typeof instance.data[key] !== 'undefined') {
                instance.data[key] = value;
                this.updateCount++;
            }
        } catch (error) {
            this.error('Failed to update Vue data:', error);
        }
    }
    
    /**
     * Update player stats
     * @param {Object} stats - Player stats
     */
    updatePlayerStats(stats) {
        Object.assign(this.componentData.playerStats, stats);
        this.updateVueData('playerStats', this.componentData.playerStats);
        
        // Update state manager
        if (this.stateManager) {
            this.stateManager.set('playerStats', this.componentData.playerStats, true);
        }
    }
    
    /**
     * Update settings
     * @param {Object} settings - Settings object
     */
    updateSettings(settings) {
        Object.assign(this.componentData.settings, settings);
        this.updateVueData('settings', this.componentData.settings);
        
        // Update state manager
        if (this.stateManager) {
            this.stateManager.set('settings', this.componentData.settings);
        }
    }
    
    /**
     * Update theme
     * @param {string} themeName - Theme name
     */
    updateTheme(themeName) {
        this.componentData.currentTheme = themeName;
        this.updateVueData('currentTheme', themeName);
        
        // Apply theme to body
        document.body.className = document.body.className.replace(/theme-\w+/, '') + ` theme-${themeName}`;
        
        // Update state manager
        if (this.stateManager) {
            this.stateManager.set('currentTheme', themeName);
        }
        
        // Trigger theme effects
        if (this.themeManager) {
            this.themeManager.setTheme(themeName);
        }
    }
    
    /**
     * Update all components
     */
    updateAllComponents() {
        this.updateVueData('playerStats', this.componentData.playerStats);
        this.updateVueData('settings', this.componentData.settings);
        this.updateVueData('currentTheme', this.componentData.currentTheme);
        this.updateVueData('moduleStatus', this.componentData.moduleStatus);
    }
    
    // === MENU METHODS ===
    
    /**
     * Open menu
     * @param {string} menuType - Menu type ('main' or 'settings')
     */
    openMenu(menuType) {
        if (menuType === 'main') {
            this.componentData.menuOpen = true;
            this.updateVueData('menuOpen', true);
        } else if (menuType === 'settings') {
            this.componentData.settingsMenuOpen = true;
            this.updateVueData('settingsMenuOpen', true);
        }
        
        this.activeMenus.add(menuType);
        this.handleMenuStateChange(menuType, true);
        
        this.log('Menu opened:', menuType);
    }
    
    /**
     * Close menu
     * @param {string} menuType - Menu type ('main' or 'settings')
     */
    closeMenu(menuType) {
        if (menuType === 'main') {
            this.componentData.menuOpen = false;
            this.updateVueData('menuOpen', false);
        } else if (menuType === 'settings') {
            this.componentData.settingsMenuOpen = false;
            this.updateVueData('settingsMenuOpen', false);
        }
        
        this.activeMenus.delete(menuType);
        this.handleMenuStateChange(menuType, false);
        
        this.log('Menu closed:', menuType);
    }
    
    /**
     * Close all menus
     */
    closeAllMenus() {
        Array.from(this.activeMenus).forEach(menuType => {
            this.closeMenu(menuType);
        });
    }
    
    /**
     * Handle menu state changes
     * @param {string} menuType - Menu type
     * @param {boolean} isOpen - Is menu open
     */
    handleMenuStateChange(menuType, isOpen) {
        // Set NUI focus
        this.setNuiFocus(isOpen, isOpen);
        
        // Trigger visual effects
        if (this.themeManager && isOpen) {
            this.themeManager.triggerGlow('.hud-container', '#00ffff', 1.5);
        }
    }
    
    /**
     * Set NUI focus
     * @param {boolean} hasFocus - Has focus
     * @param {boolean} hasCursor - Has cursor
     */
    setNuiFocus(hasFocus, hasCursor) {
        if (this.eventManager) {
            this.eventManager.sendToFiveM('setNuiFocus', {
                focus: hasFocus,
                cursor: hasCursor
            });
        }
    }
    
    // === SYSTEM METHODS ===
    
    /**
     * Restart HUD
     */
    restartHud() {
        if (this.eventManager) {
            this.eventManager.sendToFiveM('restartHud', {});
        }
        
        // Trigger visual feedback
        if (this.themeManager) {
            this.themeManager.triggerGlow('.hud-container', '#00ffff', 2.0);
            this.themeManager.enableScanLines();
        }
        
        this.log('HUD restart requested');
    }
    
    /**
     * Reset settings to defaults
     */
    resetSettings() {
        const defaultSettings = {
            hudVisible: true,
            showHealth: true,
            showArmor: true,
            showHunger: true,
            showThirst: true,
            showStress: true,
            showStamina: true,
            showOxygen: true,
            hudOpacity: 1.0,
            performanceMode: false,
            animationsEnabled: true,
            debugMode: false
        };
        
        this.updateSettings(defaultSettings);
        this.log('Settings reset to defaults');
    }
    
    /**
     * Save settings
     */
    saveSettings() {
        if (this.eventManager) {
            this.eventManager.sendToFiveM('saveSettings', this.componentData.settings);
        }
        
        this.log('Settings saved');
    }
    
    // === EVENT HANDLERS ===
    
    /**
     * Handle HUD data updates
     * @param {Object} data - HUD data
     */
    handleHudDataUpdate(data) {
        if (data.playerStats) {
            this.updatePlayerStats(data.playerStats);
        }
        
        if (data.settings) {
            this.updateSettings(data.settings);
        }
    }
    
    /**
     * Handle theme changes
     * @param {string} themeName - Theme name
     */
    handleThemeChanged(themeName) {
        this.updateTheme(themeName);
    }
    
    /**
     * Handle menu opened events
     * @param {Object} data - Menu data
     */
    handleMenuOpened(data) {
        if (data.menuType) {
            this.openMenu(data.menuType);
        }
    }
    
    /**
     * Handle settings menu opened events
     * @param {Object} data - Menu data
     */
    handleSettingsMenuOpened(data) {
        this.openMenu('settings');
    }
    
    // === SYNC METHODS ===
    
    /**
     * Sync with HUD Controller
     */
    syncWithHudController() {
        if (!this.hudController) return;
        
        const hudData = this.hudController.getAllData();
        if (hudData) {
            this.handleHudDataUpdate(hudData);
        }
    }
    
    /**
     * Sync with Theme Manager
     */
    syncWithThemeManager() {
        if (!this.themeManager) return;
        
        const currentTheme = this.themeManager.getCurrentTheme();
        if (currentTheme !== this.componentData.currentTheme) {
            this.updateTheme(currentTheme);
        }
    }
    
    /**
     * Get component status
     * @returns {Object} Component status
     */
    getStatus() {
        return {
            initialized: !!this.vueApp,
            activeMenus: Array.from(this.activeMenus),
            componentCount: this.components.size,
            updateCount: this.updateCount,
            moduleStatus: { ...this.componentData.moduleStatus }
        };
    }
    
    /**
     * Cleanup resources
     */
    cleanup() {
        // Close all menus
        this.closeAllMenus();
        
        // Clear active components
        this.components.clear();
        this.activeMenus.clear();
        
        // Unmount Vue app
        if (this.vueApp) {
            this.vueApp.unmount();
            this.vueApp = null;
        }
        
        this.log('Component manager cleaned up');
    }
    
    /**
     * Logging functions
     */
    log(...args) {
        console.log('[ComponentManager]', ...args);
    }
    
    warn(...args) {
        console.warn('[ComponentManager]', ...args);
    }
    
    error(...args) {
        console.error('[ComponentManager]', ...args);
    }
}

// === GLOBAL INITIALIZATION ===

if (typeof window !== 'undefined') {
    // Initialize global component manager
    window.hudComponentManager = new HudComponentManager();
    
    // Auto-initialize when dependencies are ready
    document.addEventListener('DOMContentLoaded', () => {
        if (window.hudComponentManager) {
            window.hudComponentManager.initialize();
        }
    });
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { HudComponentManager };
}