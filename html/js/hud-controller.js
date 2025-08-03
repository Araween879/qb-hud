/**
 * 🎮 Enhanced HUD - HUD Controller System
 * 
 * Core HUD data management and UI coordination:
 * - Player stats tracking & validation
 * - Vehicle data management
 * - Critical threshold monitoring
 * - UI state synchronization
 * - Performance optimized updates
 */

class HudController {
    constructor(
        stateManager = window.hudState,
        themeManager = window.hudThemeManager,
        eventManager = window.hudEventManager
    ) {
        this.stateManager = stateManager;
        this.themeManager = themeManager;
        this.eventManager = eventManager;
        
        // HUD Data
        this.playerStats = {
            health: 100,
            armor: 0,
            hunger: 100,
            thirst: 100,
            stress: 0,
            oxygen: 100,
            stamina: 100
        };
        
        this.vehicleStats = {
            speed: 0,
            fuel: 100,
            engine: 100,
            altitude: 0,
            seatbelt: false,
            cruise: false,
            nos: 0,
            nitroActive: false
        };
        
        this.hudState = {
            visible: true,
            inVehicle: false,
            playerDead: false,
            armed: false,
            talking: false,
            radio: 0,
            voice: 0,
            parachute: -1,
            dev: false
        };
        
        this.compassData = {
            visible: false,
            heading: 0,
            street1: '',
            street2: '',
            showCompass: true,
            showStreets: true,
            showPointer: true,
            showDegrees: true
        };
        
        this.moneyData = {
            cash: 0,
            bank: 0,
            showCash: false,
            showBank: false
        };
        
        // Settings
        this.settings = {
            opacity: 1.0,
            showHealth: true,
            showArmor: true,
            showHunger: true,
            showThirst: true,
            showStress: true,
            showStamina: true,
            showOxygen: true,
            dynamicVisibility: true,
            performanceMode: false,
            animationsEnabled: true,
            criticalThreshold: 20,
            stressCriticalThreshold: 80
        };
        
        // Performance tracking
        this.lastUpdate = 0;
        this.updateInterval = 50; // 20 FPS max
        this.pendingUpdates = new Set();
        this.batchUpdates = new Map();
        
        // Critical alerts tracking
        this.criticalAlerts = new Set();
        this.lastCriticalCheck = 0;
        this.criticalCheckInterval = 1000; // Check every second
        
        this.initialize();
    }
    
    /**
     * Initialize HUD controller
     */
    initialize() {
        this.log('HUD Controller initializing...');
        
        // Load settings from state
        this.loadSettings();
        
        // Setup event listeners
        this.setupEventListeners();
        
        // Setup state subscriptions
        this.setupStateSubscriptions();
        
        // Initialize UI
        this.initializeUI();
        
        // Start update loops
        this.startUpdateLoops();
        
        this.log('HUD Controller initialized');
    }
    
    /**
     * Load settings from state manager
     */
    loadSettings() {
        if (!this.stateManager) return;
        
        const savedSettings = this.stateManager.get('hudSettings', {});
        this.settings = { ...this.settings, ...savedSettings };
        
        // Apply settings
        this.applySettings();
        
        this.log('Settings loaded:', this.settings);
    }
    
    /**
     * Apply current settings to UI
     */
    applySettings() {
        // Update CSS custom properties
        document.documentElement.style.setProperty('--hud-opacity', this.settings.opacity);
        
        // Update body classes for performance mode
        document.body.classList.toggle('performance-mode', this.settings.performanceMode);
        document.body.classList.toggle('animations-disabled', !this.settings.animationsEnabled);
        
        // Update update interval based on performance mode
        this.updateInterval = this.settings.performanceMode ? 100 : 50;
    }
    
    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Listen for data update events
        document.addEventListener('hudDataUpdated', (event) => {
            this.handleHudDataUpdate(event.detail);
        });
        
        document.addEventListener('vehicleDataUpdated', (event) => {
            this.handleVehicleDataUpdate(event.detail);
        });
        
        document.addEventListener('compassUpdated', (event) => {
            this.handleCompassUpdate(event.detail);
        });
        
        document.addEventListener('compassDirectionUpdated', (event) => {
            this.handleCompassDirectionUpdate(event.detail);
        });
        
        document.addEventListener('moneyShown', (event) => {
            this.handleMoneyShow(event.detail);
        });
        
        document.addEventListener('moneyUpdated', (event) => {
            this.handleMoneyUpdate(event.detail);
        });
        
        // Listen for settings changes
        document.addEventListener('settingsChanged', (event) => {
            this.handleSettingsChange(event.detail);
        });
        
        // Listen for theme changes
        document.addEventListener('themeChanged', (event) => {
            this.handleThemeChange(event.detail);
        });
    }
    
    /**
     * Setup state manager subscriptions
     */
    setupStateSubscriptions() {
        if (!this.stateManager) return;
        
        // Subscribe to settings changes
        this.stateManager.subscribe('hudSettings', (newSettings) => {
            this.settings = { ...this.settings, ...newSettings };
            this.applySettings();
        });
        
        // Subscribe to performance mode changes
        this.stateManager.subscribe('performanceMode', (enabled) => {
            this.settings.performanceMode = enabled;
            this.applySettings();
        });
        
        // Subscribe to animations toggle
        this.stateManager.subscribe('animationsEnabled', (enabled) => {
            this.settings.animationsEnabled = enabled;
            this.applySettings();
        });
    }
    
    /**
     * Initialize UI elements
     */
    initializeUI() {
        // Setup initial UI state
        this.updateHudVisibility();
        this.updatePlayerStatsUI();
        this.updateVehicleStatsUI();
        this.updateCompassUI();
        this.updateMoneyUI();
    }
    
    /**
     * Start update loops
     */
    startUpdateLoops() {
        // Main update loop
        this.startMainUpdateLoop();
        
        // Critical check loop
        this.startCriticalCheckLoop();
        
        // Performance monitoring loop
        this.startPerformanceLoop();
    }
    
    /**
     * Start main update loop
     */
    startMainUpdateLoop() {
        const updateLoop = () => {
            const now = Date.now();
            
            if (now - this.lastUpdate >= this.updateInterval) {
                this.processQueuedUpdates();
                this.lastUpdate = now;
            }
            
            requestAnimationFrame(updateLoop);
        };
        
        requestAnimationFrame(updateLoop);
    }
    
    /**
     * Start critical check loop
     */
    startCriticalCheckLoop() {
        setInterval(() => {
            this.checkCriticalValues();
        }, this.criticalCheckInterval);
    }
    
    /**
     * Start performance monitoring loop
     */
    startPerformanceLoop() {
        setInterval(() => {
            this.performanceCheck();
        }, 5000); // Every 5 seconds
    }
    
    // === DATA UPDATE HANDLERS ===
    
    /**
     * Handle HUD data update
     * @param {Object} data - HUD update data
     */
    handleHudDataUpdate(data) {
        if (!data || typeof data !== 'object') return;
        
        // Update player stats
        const statsUpdated = this.updatePlayerStats({
            health: this.validateStat(data.health, 0, 100, this.playerStats.health),
            armor: this.validateStat(data.armor, 0, 100, this.playerStats.armor),
            hunger: this.validateStat(data.hunger, 0, 100, this.playerStats.hunger),
            thirst: this.validateStat(data.thirst, 0, 100, this.playerStats.thirst),
            stress: this.validateStat(data.stress, 0, 100, this.playerStats.stress),
            oxygen: this.validateStat(data.oxygen, 0, 100, this.playerStats.oxygen),
            stamina: this.validateStat(data.oxygen, 0, 100, this.playerStats.stamina) // Fallback
        });
        
        // Update HUD state
        const stateUpdated = this.updateHudState({
            visible: data.show !== false,
            playerDead: data.playerDead === true,
            armed: data.armed === true,
            talking: data.talking === true,
            radio: this.validateStat(data.radio, 0, 999, this.hudState.radio),
            voice: this.validateStat(data.voice, 0, 3, this.hudState.voice),
            parachute: this.validateStat(data.parachute, -1, 3, this.hudState.parachute),
            dev: data.dev === true
        });
        
        // Update vehicle stats if relevant
        if (data.speed !== undefined || data.engine !== undefined || data.nos !== undefined) {
            this.updateVehicleStats({
                speed: this.validateStat(data.speed, 0, 999, this.vehicleStats.speed),
                engine: this.validateStat(data.engine, 0, 100, this.vehicleStats.engine),
                nos: this.validateStat(data.nos, 0, 100, this.vehicleStats.nos),
                nitroActive: data.nitroActive === true,
                cruise: data.cruise === true
            });
        }
        
        // Queue UI updates if data changed
        if (statsUpdated || stateUpdated) {
            this.queueUpdate('playerStats');
            this.queueUpdate('hudState');
        }
    }
    
    /**
     * Handle vehicle data update
     * @param {Object} data - Vehicle update data
     */
    handleVehicleDataUpdate(data) {
        if (!data || typeof data !== 'object') return;
        
        const updated = this.updateVehicleStats({
            speed: this.validateStat(data.speed, 0, 999, this.vehicleStats.speed),
            fuel: this.validateStat(data.fuel, 0, 100, this.vehicleStats.fuel),
            altitude: this.validateStat(data.altitude, 0, 9999, this.vehicleStats.altitude),
            seatbelt: data.seatbelt === true,
            cruise: data.cruise === true
        });
        
        const stateUpdated = this.updateHudState({
            inVehicle: data.show === true
        });
        
        if (updated || stateUpdated) {
            this.queueUpdate('vehicleStats');
        }
    }
    
    /**
     * Handle compass update
     * @param {Object} data - Compass update data
     */
    handleCompassUpdate(data) {
        if (!data || typeof data !== 'object') return;
        
        const updated = this.updateCompassData({
            visible: data.show === true,
            street1: String(data.street1 || ''),
            street2: String(data.street2 || ''),
            showCompass: data.showCompass !== false,
            showStreets: data.showStreets !== false,
            showPointer: data.showPointer !== false,
            showDegrees: data.showDegrees !== false
        });
        
        if (updated) {
            this.queueUpdate('compass');
        }
    }
    
    /**
     * Handle compass direction update
     * @param {Object} data - Direction update data
     */
    handleCompassDirectionUpdate(data) {
        if (!data || typeof data.value !== 'string') return;
        
        const heading = parseInt(data.value) || 0;
        const updated = this.updateCompassData({ heading });
        
        if (updated) {
            this.queueUpdate('compassDirection');
        }
    }
    
    /**
     * Handle money display
     * @param {Object} data - Money display data
     */
    handleMoneyShow(data) {
        if (!data || typeof data !== 'object') return;
        
        const updates = {};
        if (data.type === 'cash' && typeof data.cash === 'number') {
            updates.cash = data.cash;
            updates.showCash = true;
        } else if (data.type === 'bank' && typeof data.bank === 'number') {
            updates.bank = data.bank;
            updates.showBank = true;
        }
        
        if (Object.keys(updates).length > 0) {
            this.updateMoneyData(updates);
            this.queueUpdate('money');
            
            // Auto-hide after delay
            setTimeout(() => {
                const hideUpdates = {};
                if (data.type === 'cash') hideUpdates.showCash = false;
                if (data.type === 'bank') hideUpdates.showBank = false;
                
                this.updateMoneyData(hideUpdates);
                this.queueUpdate('money');
            }, 3500);
        }
    }
    
    /**
     * Handle money update
     * @param {Object} data - Money update data
     */
    handleMoneyUpdate(data) {
        if (!data || typeof data !== 'object') return;
        
        const updates = {};
        if (typeof data.cash === 'number') updates.cash = data.cash;
        if (typeof data.bank === 'number') updates.bank = data.bank;
        
        if (Object.keys(updates).length > 0) {
            this.updateMoneyData(updates);
            this.queueUpdate('money');
        }
    }
    
    /**
     * Handle settings change
     * @param {Object} data - Settings change data
     */
    handleSettingsChange(data) {
        if (!data || typeof data !== 'object') return;
        
        this.settings = { ...this.settings, ...data };
        this.applySettings();
        
        // Save to state
        if (this.stateManager) {
            this.stateManager.set('hudSettings', this.settings);
        }
        
        this.queueUpdate('all');
    }
    
    /**
     * Handle theme change
     * @param {Object} data - Theme change data
     */
    handleThemeChange(data) {
        // Refresh UI to apply new theme
        this.queueUpdate('all');
    }
    
    // === DATA UPDATE METHODS ===
    
    /**
     * Update player stats
     * @param {Object} newStats - New stats
     * @returns {boolean} Whether data changed
     */
    updatePlayerStats(newStats) {
        let changed = false;
        
        Object.entries(newStats).forEach(([key, value]) => {
            if (this.playerStats[key] !== value) {
                this.playerStats[key] = value;
                changed = true;
            }
        });
        
        return changed;
    }
    
    /**
     * Update vehicle stats
     * @param {Object} newStats - New stats
     * @returns {boolean} Whether data changed
     */
    updateVehicleStats(newStats) {
        let changed = false;
        
        Object.entries(newStats).forEach(([key, value]) => {
            if (this.vehicleStats[key] !== value) {
                this.vehicleStats[key] = value;
                changed = true;
            }
        });
        
        return changed;
    }
    
    /**
     * Update HUD state
     * @param {Object} newState - New state
     * @returns {boolean} Whether data changed
     */
    updateHudState(newState) {
        let changed = false;
        
        Object.entries(newState).forEach(([key, value]) => {
            if (this.hudState[key] !== value) {
                this.hudState[key] = value;
                changed = true;
            }
        });
        
        return changed;
    }
    
    /**
     * Update compass data
     * @param {Object} newData - New compass data
     * @returns {boolean} Whether data changed
     */
    updateCompassData(newData) {
        let changed = false;
        
        Object.entries(newData).forEach(([key, value]) => {
            if (this.compassData[key] !== value) {
                this.compassData[key] = value;
                changed = true;
            }
        });
        
        return changed;
    }
    
    /**
     * Update money data
     * @param {Object} newData - New money data
     * @returns {boolean} Whether data changed
     */
    updateMoneyData(newData) {
        let changed = false;
        
        Object.entries(newData).forEach(([key, value]) => {
            if (this.moneyData[key] !== value) {
                this.moneyData[key] = value;
                changed = true;
            }
        });
        
        return changed;
    }
    
    // === UI UPDATE METHODS ===
    
    /**
     * Queue UI update
     * @param {string} component - Component to update
     */
    queueUpdate(component) {
        this.pendingUpdates.add(component);
    }
    
    /**
     * Process queued UI updates
     */
    processQueuedUpdates() {
        if (this.pendingUpdates.size === 0) return;
        
        // Batch updates for performance
        const updates = Array.from(this.pendingUpdates);
        this.pendingUpdates.clear();
        
        // Process updates
        if (updates.includes('all')) {
            this.updateAllUI();
        } else {
            updates.forEach(component => {
                switch (component) {
                    case 'playerStats':
                        this.updatePlayerStatsUI();
                        break;
                    case 'vehicleStats':
                        this.updateVehicleStatsUI();
                        break;
                    case 'hudState':
                        this.updateHudVisibility();
                        break;
                    case 'compass':
                    case 'compassDirection':
                        this.updateCompassUI();
                        break;
                    case 'money':
                        this.updateMoneyUI();
                        break;
                }
            });
        }
    }
    
    /**
     * Update all UI components
     */
    updateAllUI() {
        this.updateHudVisibility();
        this.updatePlayerStatsUI();
        this.updateVehicleStatsUI();
        this.updateCompassUI();
        this.updateMoneyUI();
    }
    
    /**
     * Update HUD visibility
     */
    updateHudVisibility() {
        const hudContainer = document.querySelector('.hud-container');
        if (!hudContainer) return;
        
        // Update visibility
        hudContainer.style.display = this.hudState.visible ? 'block' : 'none';
        hudContainer.style.opacity = this.settings.opacity;
        
        // Update classes based on state
        document.body.classList.toggle('player-dead', this.hudState.playerDead);
        document.body.classList.toggle('in-vehicle', this.hudState.inVehicle);
        document.body.classList.toggle('armed', this.hudState.armed);
        document.body.classList.toggle('talking', this.hudState.talking);
        document.body.classList.toggle('dev-mode', this.hudState.dev);
    }
    
    /**
     * Update player stats UI
     */
    updatePlayerStatsUI() {
        const stats = ['health', 'armor', 'hunger', 'thirst', 'stress', 'stamina', 'oxygen'];
        
        stats.forEach(stat => {
            const element = document.querySelector(`.hud-item.${stat}`);
            if (!element) return;
            
            const value = this.playerStats[stat];
            const showStat = this.settings[`show${stat.charAt(0).toUpperCase() + stat.slice(1)}`];
            
            // Update visibility
            if (this.settings.dynamicVisibility) {
                // Dynamic visibility logic
                let shouldShow = showStat;
                
                if (stat === 'armor' && value === 0) shouldShow = false;
                if (stat === 'hunger' && value >= 100) shouldShow = false;
                if (stat === 'thirst' && value >= 100) shouldShow = false;
                if (stat === 'stress' && value === 0) shouldShow = false;
                if (stat === 'oxygen' && value >= 100) shouldShow = false;
                
                element.style.display = shouldShow ? 'flex' : 'none';
            } else {
                element.style.display = showStat ? 'flex' : 'none';
            }
            
            // Update value
            const textElement = element.querySelector('.stat-text span');
            if (textElement) {
                textElement.textContent = Math.round(value);
            }
            
            // Update progress bar
            const progressElement = element.querySelector('.stat-progress');
            if (progressElement) {
                progressElement.style.width = `${value}%`;
            }
            
            // Update critical state
            const isCritical = this.isStatCritical(stat, value);
            element.classList.toggle('critical', isCritical);
            
            // Update state manager
            if (this.stateManager) {
                this.stateManager.set(`${stat}Value`, value, true);
                this.stateManager.set(`${stat}Critical`, isCritical, true);
            }
        });
    }
    
    /**
     * Update vehicle stats UI
     */
    updateVehicleStatsUI() {
        // Vehicle HUD is handled by separate component
        // Update state for vehicle components
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                vehicleSpeed: this.vehicleStats.speed,
                vehicleFuel: this.vehicleStats.fuel,
                vehicleEngine: this.vehicleStats.engine,
                vehicleAltitude: this.vehicleStats.altitude,
                seatbeltStatus: this.vehicleStats.seatbelt,
                cruiseStatus: this.vehicleStats.cruise,
                nosLevel: this.vehicleStats.nos,
                nitroActive: this.vehicleStats.nitroActive
            }, true);
        }
    }
    
    /**
     * Update compass UI
     */
    updateCompassUI() {
        // Compass is handled by separate component
        // Update state for compass component
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                compassVisible: this.compassData.visible,
                compassHeading: this.compassData.heading,
                street1: this.compassData.street1,
                street2: this.compassData.street2,
                compassSettings: {
                    showCompass: this.compassData.showCompass,
                    showStreets: this.compassData.showStreets,
                    showPointer: this.compassData.showPointer,
                    showDegrees: this.compassData.showDegrees
                }
            }, true);
        }
    }
    
    /**
     * Update money UI
     */
    updateMoneyUI() {
        // Money HUD is handled by separate component
        // Update state for money component
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                cashAmount: this.moneyData.cash,
                bankAmount: this.moneyData.bank,
                showCash: this.moneyData.showCash,
                showBank: this.moneyData.showBank
            }, true);
        }
    }
    
    // === UTILITY METHODS ===
    
    /**
     * Validate stat value
     * @param {*} value - Value to validate
     * @param {number} min - Minimum value
     * @param {number} max - Maximum value
     * @param {number} fallback - Fallback value
     * @returns {number} Validated value
     */
    validateStat(value, min, max, fallback) {
        if (typeof value !== 'number' || isNaN(value)) {
            return fallback;
        }
        return Math.max(min, Math.min(max, value));
    }
    
    /**
     * Check if stat is critical
     * @param {string} stat - Stat name
     * @param {number} value - Stat value
     * @returns {boolean} Is critical
     */
    isStatCritical(stat, value) {
        if (stat === 'stress') {
            return value >= this.settings.stressCriticalThreshold;
        }
        return value <= this.settings.criticalThreshold;
    }
    
    /**
     * Check critical values and trigger alerts
     */
    checkCriticalValues() {
        const now = Date.now();
        if (now - this.lastCriticalCheck < this.criticalCheckInterval) {
            return;
        }
        
        this.lastCriticalCheck = now;
        
        const stats = ['health', 'armor', 'hunger', 'thirst', 'stress', 'oxygen'];
        
        stats.forEach(stat => {
            const value = this.playerStats[stat];
            const isCritical = this.isStatCritical(stat, value);
            const alertKey = `${stat}_${value}`;
            
            if (isCritical && !this.criticalAlerts.has(alertKey)) {
                this.criticalAlerts.add(alertKey);
                
                // Trigger critical alert
                if (this.themeManager) {
                    this.themeManager.triggerCriticalAlert(`.hud-item.${stat}`, value);
                }
                
                // Clean up old alerts
                setTimeout(() => {
                    this.criticalAlerts.delete(alertKey);
                }, 5000);
            }
        });
        
        // Check vehicle fuel
        if (this.vehicleStats.fuel <= 20 && this.hudState.inVehicle) {
            const fuelAlertKey = `fuel_${this.vehicleStats.fuel}`;
            if (!this.criticalAlerts.has(fuelAlertKey)) {
                this.criticalAlerts.add(fuelAlertKey);
                
                if (this.themeManager) {
                    this.themeManager.triggerCriticalAlert('.fuel-indicator', this.vehicleStats.fuel);
                }
                
                setTimeout(() => {
                    this.criticalAlerts.delete(fuelAlertKey);
                }, 5000);
            }
        }
    }
    
    /**
     * Performance check
     */
    performanceCheck() {
        const stats = this.getPerformanceStats();
        
        if (stats.updateRate > 30) {
            this.warn('High update rate detected:', stats.updateRate, 'updates/sec');
        }
        
        if (stats.pendingUpdates > 10) {
            this.warn('High pending updates:', stats.pendingUpdates);
        }
    }
    
    /**
     * Get performance statistics
     * @returns {Object} Performance stats
     */
    getPerformanceStats() {
        return {
            updateInterval: this.updateInterval,
            pendingUpdates: this.pendingUpdates.size,
            criticalAlerts: this.criticalAlerts.size,
            lastUpdate: this.lastUpdate,
            updateRate: 1000 / this.updateInterval
        };
    }
    
    /**
     * Get current HUD data
     * @returns {Object} Complete HUD data
     */
    getAllData() {
        return {
            playerStats: { ...this.playerStats },
            vehicleStats: { ...this.vehicleStats },
            hudState: { ...this.hudState },
            compassData: { ...this.compassData },
            moneyData: { ...this.moneyData },
            settings: { ...this.settings }
        };
    }
    
    /**
     * Logging functions
     */
    log(...args) {
        console.log('[HudController]', ...args);
    }
    
    warn(...args) {
        console.warn('[HudController]', ...args);
    }
    
    error(...args) {
        console.error('[HudController]', ...args);
    }
}

// === GLOBAL INITIALIZATION ===

if (typeof window !== 'undefined') {
    // Initialize global HUD controller
    window.hudController = new HudController();
    
    // Auto-initialize when dependencies are ready
    document.addEventListener('DOMContentLoaded', () => {
        if (window.hudController) {
            window.hudController.initialize();
        }
    });
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { HudController };
}