/**
 * 🎛️ Enhanced HUD - Event Manager System
 * 
 * Central event coordination hub for:
 * - FiveM ↔ NUI communication
 * - Inter-component messaging
 * - Error handling & recovery
 * - Performance monitoring
 * - Event validation & security
 */

class HudEventManager {
    constructor(stateManager = window.hudState, themeManager = window.hudThemeManager) {
        this.stateManager = stateManager;
        this.themeManager = themeManager;
        
        // Event tracking
        this.registeredEvents = new Map();
        this.activeListeners = new Map();
        this.eventQueue = [];
        this.processing = false;
        
        // Performance tracking
        this.eventCount = 0;
        this.errorCount = 0;
        this.lastPerformanceCheck = Date.now();
        this.eventHistory = [];
        this.maxHistorySize = 1000;
        
        // Security & validation
        this.trustedOrigins = new Set(['nui-game-internal']);
        this.eventWhitelist = new Set();
        this.rateLimits = new Map();
        
        // Resource detection
        this.resourceName = this.getResourceName();
        this.isNuiEnvironment = this.detectNuiEnvironment();
        
        this.initialize();
    }
    
    /**
     * Initialize event manager
     */
    initialize() {
        this.log('Event Manager initializing...');
        
        // Setup core event listeners
        this.setupMessageListener();
        this.setupKeyboardEvents();
        this.setupThemeEvents();
        this.setupErrorHandling();
        
        // Setup event whitelist
        this.initializeEventWhitelist();
        
        // Setup rate limiting
        this.initializeRateLimits();
        
        this.log('Event Manager initialized');
    }
    
    /**
     * Setup main message listener for FiveM communication
     */
    setupMessageListener() {
        if (typeof window === 'undefined') return;
        
        window.addEventListener('message', (event) => {
            this.handleIncomingMessage(event);
        });
        
        this.log('Message listener setup complete');
    }
    
    /**
     * Handle incoming messages from FiveM
     * @param {MessageEvent} event - Message event
     */
    handleIncomingMessage(event) {
        try {
            // Security check
            if (!this.validateMessageOrigin(event)) {
                this.warn('Message from untrusted origin:', event.origin);
                return;
            }
            
            const data = event.data;
            if (!data || typeof data !== 'object') {
                this.warn('Invalid message data:', data);
                return;
            }
            
            // Rate limiting check
            if (!this.checkRateLimit(data.action)) {
                this.warn('Rate limit exceeded for action:', data.action);
                return;
            }
            
            // Add to event queue
            this.queueEvent({
                type: 'incoming',
                action: data.action,
                data: data,
                timestamp: Date.now(),
                source: 'fivem'
            });
            
            // Process queue
            this.processEventQueue();
            
        } catch (error) {
            this.handleEventError('incoming_message', error, event);
        }
    }
    
    /**
     * Queue an event for processing
     * @param {Object} eventData - Event data
     */
    queueEvent(eventData) {
        this.eventQueue.push(eventData);
        this.eventCount++;
        
        // Add to history
        this.addToHistory(eventData);
        
        // Performance check
        if (this.eventCount % 100 === 0) {
            this.performanceCheck();
        }
    }
    
    /**
     * Process queued events
     */
    async processEventQueue() {
        if (this.processing || this.eventQueue.length === 0) {
            return;
        }
        
        this.processing = true;
        
        try {
            while (this.eventQueue.length > 0) {
                const event = this.eventQueue.shift();
                await this.processEvent(event);
            }
        } catch (error) {
            this.handleEventError('queue_processing', error);
        } finally {
            this.processing = false;
        }
    }
    
    /**
     * Process individual event
     * @param {Object} event - Event to process
     */
    async processEvent(event) {
        try {
            switch (event.action) {
                // === HUD DISPLAY EVENTS ===
                case 'hudtick':
                    this.handleHudTick(event.data);
                    break;
                
                case 'car':
                    this.handleVehicleHud(event.data);
                    break;
                
                case 'baseplate':
                    this.handleCompassUpdate(event.data);
                    break;
                
                case 'update':
                    this.handleCompassDirectionUpdate(event.data);
                    break;
                
                // === MENU EVENTS ===
                case 'open':
                    this.handleMenuOpen(event.data);
                    break;
                
                case 'openSettings':
                    this.handleSettingsOpen(event.data);
                    break;
                
                // === THEME EVENTS ===
                case 'updateTheme':
                    this.handleThemeUpdate(event.data);
                    break;
                
                case 'triggerGlow':
                    this.handleGlowEffect(event.data);
                    break;
                
                case 'criticalAlert':
                    this.handleCriticalAlert(event.data);
                    break;
                
                case 'valueChanged':
                    this.handleValueChanged(event.data);
                    break;
                
                // === GPS EVENTS ===
                case 'toggleGpsHud':
                    this.handleGpsToggle(event.data);
                    break;
                
                case 'updateGpsLocation':
                    this.handleGpsLocationUpdate(event.data);
                    break;
                
                case 'updateGpsStats':
                    this.handleGpsStatsUpdate(event.data);
                    break;
                
                case 'setGpsPosition':
                    this.handleGpsPositionSet(event.data);
                    break;
                
                case 'setGpsTheme':
                    this.handleGpsThemeSet(event.data);
                    break;
                
                // === MONEY EVENTS ===
                case 'show':
                    this.handleMoneyShow(event.data);
                    break;
                
                case 'updatemoney':
                    this.handleMoneyUpdate(event.data);
                    break;
                
                // === SETTINGS EVENTS ===
                case 'setEffectsEnabled':
                    this.handleEffectsToggle(event.data);
                    break;
                
                case 'setNeonIntensity':
                    this.handleNeonIntensityChange(event.data);
                    break;
                
                case 'syncTheme':
                    this.handleThemeSync(event.data);
                    break;
                
                default:
                    this.handleUnknownEvent(event);
                    break;
            }
        } catch (error) {
            this.handleEventError(event.action, error, event);
        }
    }
    
    // === EVENT HANDLERS ===
    
    /**
     * Handle HUD tick update
     * @param {Object} data - HUD data
     */
    handleHudTick(data) {
        if (!data || typeof data !== 'object') return;
        
        // Update state
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                playerStats: {
                    health: data.health || 100,
                    armor: data.armor || 0,
                    hunger: data.hunger || 100,
                    thirst: data.thirst || 100,
                    stress: data.stress || 0,
                    oxygen: data.oxygen || 100,
                    stamina: data.oxygen || 100 // Fallback
                },
                vehicleStats: {
                    speed: data.speed || 0,
                    engine: data.engine || 100,
                    nos: data.nos || 0
                },
                hudVisible: data.show !== false
            }, true);
        }
        
        // Trigger critical alerts if needed
        if (this.themeManager) {
            this.checkCriticalValues(data);
        }
        
        // Dispatch to HUD controller
        this.dispatchEvent('hudDataUpdated', data);
    }
    
    /**
     * Handle vehicle HUD update
     * @param {Object} data - Vehicle data
     */
    handleVehicleHud(data) {
        if (!data || typeof data !== 'object') return;
        
        // Update vehicle state
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                inVehicle: data.show === true,
                vehicleStats: {
                    speed: data.speed || 0,
                    fuel: data.fuel || 100,
                    altitude: data.altitude || 0,
                    seatbelt: data.seatbelt === true
                }
            }, true);
        }
        
        // Check for fuel alerts
        if (data.fuel <= 20 && this.themeManager) {
            this.themeManager.triggerCriticalAlert('.fuel-indicator', data.fuel);
        }
        
        this.dispatchEvent('vehicleDataUpdated', data);
    }
    
    /**
     * Handle compass update
     * @param {Object} data - Compass data
     */
    handleCompassUpdate(data) {
        if (!data || typeof data !== 'object') return;
        
        // Update compass state
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                compassVisible: data.show === true,
                streetNames: {
                    street1: data.street1 || '',
                    street2: data.street2 || ''
                },
                compassSettings: {
                    showCompass: data.showCompass,
                    showStreets: data.showStreets,
                    showPointer: data.showPointer,
                    showDegrees: data.showDegrees
                }
            }, true);
        }
        
        this.dispatchEvent('compassUpdated', data);
    }
    
    /**
     * Handle compass direction update
     * @param {Object} data - Direction data
     */
    handleCompassDirectionUpdate(data) {
        if (!data || typeof data.value === 'undefined') return;
        
        // Update compass direction
        if (this.stateManager) {
            this.stateManager.set('compassHeading', data.value, true);
        }
        
        this.dispatchEvent('compassDirectionUpdated', data);
    }
    
    /**
     * Handle menu open
     * @param {Object} data - Menu data
     */
    handleMenuOpen(data) {
        if (this.stateManager) {
            this.stateManager.set('menuOpen', true);
        }
        
        // Trigger theme effect
        if (this.themeManager) {
            const theme = this.themeManager.getCurrentTheme();
            const themeConfig = this.themeManager.getThemeConfig(theme);
            this.themeManager.triggerGlow('.main-menu-container', themeConfig.colors.secondary, 1.2);
        }
        
        this.dispatchEvent('menuOpened', data);
    }
    
    /**
     * Handle settings menu open
     * @param {Object} data - Settings data
     */
    handleSettingsOpen(data) {
        if (this.stateManager) {
            this.stateManager.set('settingsMenuOpen', true);
        }
        
        this.dispatchEvent('settingsMenuOpened', data);
    }
    
    /**
     * Handle theme update
     * @param {Object} data - Theme data
     */
    handleThemeUpdate(data) {
        if (!data.theme) return;
        
        if (this.themeManager) {
            this.themeManager.setTheme(data.theme, true);
        }
        
        if (this.stateManager) {
            this.stateManager.set('theme', data.theme);
        }
        
        this.dispatchEvent('themeUpdated', data);
    }
    
    /**
     * Handle glow effect
     * @param {Object} data - Glow data
     */
    handleGlowEffect(data) {
        if (!data.element || !data.color) return;
        
        if (this.themeManager) {
            this.themeManager.triggerGlow(
                data.element, 
                data.color, 
                data.intensity || 1.0
            );
        }
        
        this.dispatchEvent('glowTriggered', data);
    }
    
    /**
     * Handle critical alert
     * @param {Object} data - Alert data
     */
    handleCriticalAlert(data) {
        if (!data.statType || typeof data.value === 'undefined') return;
        
        if (this.themeManager) {
            this.themeManager.triggerCriticalAlert(
                `.${data.statType}-indicator`, 
                data.value
            );
        }
        
        this.dispatchEvent('criticalAlertTriggered', data);
    }
    
    /**
     * Handle value change animation
     * @param {Object} data - Value change data
     */
    handleValueChanged(data) {
        if (!data.statType || typeof data.newValue === 'undefined') return;
        
        if (this.themeManager) {
            this.themeManager.animateValueChange(
                `.${data.statType}-value`,
                data.oldValue || 0,
                data.newValue,
                500 / (data.animationSpeed || 1.0)
            );
        }
        
        this.dispatchEvent('valueChanged', data);
    }
    
    /**
     * Handle GPS toggle
     * @param {Object} data - GPS toggle data
     */
    handleGpsToggle(data) {
        const isActive = data.show === true;
        
        if (this.stateManager) {
            this.stateManager.set('gpsActive', isActive);
        }
        
        this.dispatchEvent('gpsToggled', { active: isActive });
    }
    
    /**
     * Handle GPS location update
     * @param {Object} data - GPS location data
     */
    handleGpsLocationUpdate(data) {
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                gpsLocation: data.location || 'UNKNOWN',
                gpsDirection: data.direction || '↑',
                gpsDistance: data.distance || '0.0KM',
                gpsStreets: {
                    street1: data.street1 || '',
                    street2: data.street2 || ''
                }
            }, true);
        }
        
        this.dispatchEvent('gpsLocationUpdated', data);
    }
    
    /**
     * Handle GPS stats update
     * @param {Object} data - GPS stats data
     */
    handleGpsStatsUpdate(data) {
        if (this.stateManager) {
            this.stateManager.set('gpsStats', data, true);
        }
        
        this.dispatchEvent('gpsStatsUpdated', data);
    }
    
    /**
     * Handle GPS position set
     * @param {Object} data - GPS position data
     */
    handleGpsPositionSet(data) {
        if (this.stateManager) {
            this.stateManager.set('gpsPosition', data.position || 'top-right');
        }
        
        this.dispatchEvent('gpsPositionChanged', data);
    }
    
    /**
     * Handle GPS theme set
     * @param {Object} data - GPS theme data
     */
    handleGpsThemeSet(data) {
        if (this.stateManager) {
            this.stateManager.set('gpsTheme', data.theme || 'cyberpunk');
        }
        
        this.dispatchEvent('gpsThemeChanged', data);
    }
    
    /**
     * Handle money display
     * @param {Object} data - Money data
     */
    handleMoneyShow(data) {
        if (this.stateManager) {
            const moneyData = {};
            moneyData[data.type] = data[data.type];
            this.stateManager.updateMultiple(moneyData, true);
        }
        
        this.dispatchEvent('moneyShown', data);
    }
    
    /**
     * Handle money update
     * @param {Object} data - Money update data
     */
    handleMoneyUpdate(data) {
        if (this.stateManager) {
            this.stateManager.updateMultiple({
                cash: data.cash || 0,
                bank: data.bank || 0
            }, true);
        }
        
        // Trigger money glow effect
        if (this.themeManager && data.type) {
            const color = data.minus ? '#ff4444' : '#66bb6a';
            this.themeManager.triggerGlow(`#${data.type}`, color, 1.2);
        }
        
        this.dispatchEvent('moneyUpdated', data);
    }
    
    /**
     * Handle effects toggle
     * @param {Object} data - Effects data
     */
    handleEffectsToggle(data) {
        if (this.themeManager) {
            this.themeManager.setAnimationsEnabled(data.enabled === true);
        }
        
        this.dispatchEvent('effectsToggled', data);
    }
    
    /**
     * Handle neon intensity change
     * @param {Object} data - Intensity data
     */
    handleNeonIntensityChange(data) {
        if (this.themeManager && typeof data.intensity === 'number') {
            this.themeManager.setNeonIntensity(data.intensity);
        }
        
        this.dispatchEvent('neonIntensityChanged', data);
    }
    
    /**
     * Handle theme sync
     * @param {Object} data - Sync data
     */
    handleThemeSync(data) {
        if (this.themeManager && data.theme) {
            this.themeManager.setTheme(data.theme, false); // No animation for sync
        }
        
        this.dispatchEvent('themeSync', data);
    }
    
    /**
     * Handle unknown event
     * @param {Object} event - Unknown event
     */
    handleUnknownEvent(event) {
        this.warn('Unknown event action:', event.action, event);
        this.dispatchEvent('unknownEvent', event);
    }
    
    // === UTILITY METHODS ===
    
    /**
     * Check critical values and trigger alerts
     * @param {Object} data - HUD data
     */
    checkCriticalValues(data) {
        if (!this.themeManager) return;
        
        const criticalThreshold = 20;
        const criticalStats = [
            { key: 'health', value: data.health },
            { key: 'armor', value: data.armor },
            { key: 'hunger', value: data.hunger },
            { key: 'thirst', value: data.thirst },
            { key: 'oxygen', value: data.oxygen }
        ];
        
        criticalStats.forEach(stat => {
            if (typeof stat.value === 'number' && stat.value <= criticalThreshold) {
                this.themeManager.triggerCriticalAlert(`.${stat.key}-indicator`, stat.value);
            }
        });
        
        // Special case for stress (high is critical)
        if (typeof data.stress === 'number' && data.stress >= 80) {
            this.themeManager.triggerCriticalAlert('.stress-indicator', data.stress);
        }
    }
    
    /**
     * Validate message origin
     * @param {MessageEvent} event - Message event
     * @returns {boolean} Is valid
     */
    validateMessageOrigin(event) {
        // In NUI environment, allow game internal origin
        if (this.isNuiEnvironment) {
            return true;
        }
        
        // For development, allow localhost
        if (event.origin.includes('localhost') || event.origin.includes('127.0.0.1')) {
            return true;
        }
        
        return this.trustedOrigins.has(event.origin);
    }
    
    /**
     * Check rate limit for action
     * @param {string} action - Action to check
     * @returns {boolean} Is within limit
     */
    checkRateLimit(action) {
        if (!action || !this.rateLimits.has(action)) {
            return true; // No limit defined
        }
        
        const limit = this.rateLimits.get(action);
        const now = Date.now();
        const windowStart = now - limit.windowMs;
        
        // Count recent events
        const recentEvents = this.eventHistory.filter(event => 
            event.action === action && event.timestamp > windowStart
        );
        
        return recentEvents.length < limit.maxEvents;
    }
    
    /**
     * Add event to history
     * @param {Object} eventData - Event data
     */
    addToHistory(eventData) {
        this.eventHistory.push(eventData);
        
        // Trim history to max size
        if (this.eventHistory.length > this.maxHistorySize) {
            this.eventHistory = this.eventHistory.slice(-this.maxHistorySize);
        }
    }
    
    /**
     * Setup keyboard event handlers
     */
    setupKeyboardEvents() {
        document.addEventListener('keydown', (event) => {
            this.handleKeyDown(event);
        });
        
        document.addEventListener('keyup', (event) => {
            this.handleKeyUp(event);
        });
    }
    
    /**
     * Handle key down events
     * @param {KeyboardEvent} event - Keyboard event
     */
    handleKeyDown(event) {
        // Handle escape key for menu closing
        if (event.key === 'Escape') {
            this.sendToFiveM('closeAllMenus', {});
            this.dispatchEvent('escapePressed', {});
        }
        
        // Handle other development keys
        if (!this.isNuiEnvironment) {
            switch (event.key) {
                case 'F1':
                    event.preventDefault();
                    this.sendToFiveM('toggleHud', {});
                    break;
                case 'F2':
                    event.preventDefault();
                    this.sendToFiveM('openMenu', {});
                    break;
                case 'F3':
                    event.preventDefault();
                    this.sendToFiveM('toggleGps', {});
                    break;
            }
        }
    }
    
    /**
     * Handle key up events
     * @param {KeyboardEvent} event - Keyboard event
     */
    handleKeyUp(event) {
        // Handle key releases if needed
        this.dispatchEvent('keyReleased', { key: event.key });
    }
    
    /**
     * Setup theme event listeners
     */
    setupThemeEvents() {
        document.addEventListener('themeChanged', (event) => {
            this.log('Theme changed:', event.detail);
        });
        
        document.addEventListener('criticalAlert', (event) => {
            this.log('Critical alert:', event.detail);
        });
    }
    
    /**
     * Setup error handling
     */
    setupErrorHandling() {
        window.addEventListener('error', (event) => {
            this.handleGlobalError(event);
        });
        
        window.addEventListener('unhandledrejection', (event) => {
            this.handleUnhandledRejection(event);
        });
    }
    
    /**
     * Handle global errors
     * @param {ErrorEvent} event - Error event
     */
    handleGlobalError(event) {
        this.handleEventError('global_error', event.error, {
            filename: event.filename,
            lineno: event.lineno,
            colno: event.colno
        });
    }
    
    /**
     * Handle unhandled promise rejections
     * @param {PromiseRejectionEvent} event - Rejection event
     */
    handleUnhandledRejection(event) {
        this.handleEventError('unhandled_rejection', event.reason);
    }
    
    /**
     * Handle event errors
     * @param {string} context - Error context
     * @param {Error} error - Error object
     * @param {*} data - Additional data
     */
    handleEventError(context, error, data = null) {
        this.errorCount++;
        
        const errorInfo = {
            context,
            message: error?.message || String(error),
            stack: error?.stack,
            data,
            timestamp: Date.now()
        };
        
        this.error('Event error:', errorInfo);
        
        // Dispatch error event
        this.dispatchEvent('eventError', errorInfo);
        
        // Recovery mechanism for critical errors
        if (this.errorCount > 50) {
            this.warn('Too many errors, attempting recovery...');
            this.attemptRecovery();
        }
    }
    
    /**
     * Attempt error recovery
     */
    attemptRecovery() {
        try {
            // Clear event queue
            this.eventQueue = [];
            this.processing = false;
            
            // Reset error count
            this.errorCount = 0;
            
            // Reinitialize if needed
            this.initialize();
            
            this.log('Error recovery completed');
        } catch (recoveryError) {
            this.error('Recovery failed:', recoveryError);
        }
    }
    
    /**
     * Initialize event whitelist
     */
    initializeEventWhitelist() {
        const allowedEvents = [
            'hudtick', 'car', 'baseplate', 'update',
            'open', 'openSettings',
            'updateTheme', 'triggerGlow', 'criticalAlert', 'valueChanged',
            'toggleGpsHud', 'updateGpsLocation', 'updateGpsStats', 
            'setGpsPosition', 'setGpsTheme',
            'show', 'updatemoney',
            'setEffectsEnabled', 'setNeonIntensity', 'syncTheme'
        ];
        
        allowedEvents.forEach(event => {
            this.eventWhitelist.add(event);
        });
    }
    
    /**
     * Initialize rate limits
     */
    initializeRateLimits() {
        // Set rate limits for high-frequency events
        this.rateLimits.set('hudtick', { maxEvents: 100, windowMs: 1000 });
        this.rateLimits.set('update', { maxEvents: 60, windowMs: 1000 });
        this.rateLimits.set('triggerGlow', { maxEvents: 10, windowMs: 1000 });
        this.rateLimits.set('valueChanged', { maxEvents: 20, windowMs: 1000 });
    }
    
    /**
     * Performance check
     */
    performanceCheck() {
        const now = Date.now();
        const timeDiff = now - this.lastPerformanceCheck;
        const eventsPerSecond = (this.eventCount / (timeDiff / 1000)).toFixed(2);
        
        if (eventsPerSecond > 1000) {
            this.warn('High event rate detected:', eventsPerSecond, 'events/sec');
        }
        
        this.lastPerformanceCheck = now;
    }
    
    /**
     * Send message to FiveM
     * @param {string} action - Action name
     * @param {Object} data - Data to send
     * @returns {Promise} Fetch promise
     */
    sendToFiveM(action, data = {}) {
        if (!this.isNuiEnvironment && typeof fetch === 'undefined') {
            this.warn('Cannot send to FiveM: not in NUI environment');
            return Promise.resolve();
        }
        
        const payload = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        };
        
        return fetch(`https://${this.resourceName}/${action}`, payload)
            .catch(error => {
                this.warn('Failed to send to FiveM:', action, error);
            });
    }
    
    /**
     * Dispatch custom event
     * @param {string} eventName - Event name
     * @param {*} detail - Event detail
     */
    dispatchEvent(eventName, detail) {
        const event = new CustomEvent(eventName, { detail });
        document.dispatchEvent(event);
    }
    
    /**
     * Get resource name
     * @returns {string} Resource name
     */
    getResourceName() {
        if (typeof GetParentResourceName === 'function') {
            return GetParentResourceName();
        }
        return 'qb-hud';
    }
    
    /**
     * Detect NUI environment
     * @returns {boolean} Is NUI environment
     */
    detectNuiEnvironment() {
        return window.location.hostname === 'nui-game-internal';
    }
    
    /**
     * Get event statistics
     * @returns {Object} Event statistics
     */
    getStats() {
        return {
            eventCount: this.eventCount,
            errorCount: this.errorCount,
            queueLength: this.eventQueue.length,
            activeListeners: this.activeListeners.size,
            registeredEvents: this.registeredEvents.size,
            historySize: this.eventHistory.length,
            isProcessing: this.processing,
            isNuiEnvironment: this.isNuiEnvironment,
            resourceName: this.resourceName
        };
    }
    
    /**
     * Logging functions
     */
    log(...args) {
        console.log('[EventManager]', ...args);
    }
    
    warn(...args) {
        console.warn('[EventManager]', ...args);
    }
    
    error(...args) {
        console.error('[EventManager]', ...args);
    }
}

// === GLOBAL INITIALIZATION ===

if (typeof window !== 'undefined') {
    // Initialize global event manager
    window.hudEventManager = new HudEventManager();
    
    // Auto-initialize when dependencies are ready
    document.addEventListener('DOMContentLoaded', () => {
        if (window.hudEventManager) {
            window.hudEventManager.initialize();
        }
    });
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { HudEventManager };
}