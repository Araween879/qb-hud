/**
 * 🧠 Enhanced HUD - State Manager System
 * 
 * Critical Fix: localStorage Replacement für FiveM Artifacts
 * - Memory-only State Management
 * - Event-driven Architecture
 * - Type-safe Operations
 * - Error Boundaries
 * - Performance Optimized
 */

class HudStateManager {
    constructor() {
        this.state = new Map();
        this.changeListeners = new Map();
        this.validators = new Map();
        this.initialized = false;
        this.debugMode = false;
        
        // Performance tracking
        this.operationCount = 0;
        this.lastPerformanceCheck = Date.now();
        
        // Error tracking
        this.errorCount = 0;
        this.maxErrors = 50;
        
        this.log('State Manager initialized');
    }
    
    /**
     * Initialize state with default values
     * @param {Object} initialState - Default state object
     * @param {boolean} merge - Whether to merge with existing state
     */
    initialize(initialState = {}, merge = false) {
        if (this.initialized && !merge) {
            this.warn('State Manager already initialized');
            return false;
        }
        
        try {
            if (merge && this.initialized) {
                // Merge new state with existing
                Object.entries(initialState).forEach(([key, value]) => {
                    if (!this.state.has(key)) {
                        this.state.set(key, this.deepClone(value));
                    }
                });
            } else {
                // Full initialization
                this.state.clear();
                Object.entries(initialState).forEach(([key, value]) => {
                    this.state.set(key, this.deepClone(value));
                });
            }
            
            this.initialized = true;
            this.log('State initialized with', Object.keys(initialState).length, 'keys');
            return true;
        } catch (error) {
            this.error('Failed to initialize state:', error);
            return false;
        }
    }
    
    /**
     * Set a state value with validation and change notification
     * @param {string} key - State key
     * @param {*} value - Value to set
     * @param {boolean} silent - Skip change notifications
     * @returns {boolean} Success status
     */
    set(key, value, silent = false) {
        if (!this.isValidKey(key)) {
            this.error('Invalid key:', key);
            return false;
        }
        
        try {
            const oldValue = this.state.get(key);
            const clonedValue = this.deepClone(value);
            
            // Validate if validator exists
            if (this.validators.has(key)) {
                const validator = this.validators.get(key);
                if (!validator(clonedValue, oldValue)) {
                    this.warn('Validation failed for key:', key);
                    return false;
                }
            }
            
            // Check if value actually changed
            if (this.deepEqual(oldValue, clonedValue)) {
                return true; // No change needed
            }
            
            this.state.set(key, clonedValue);
            this.incrementOperationCount();
            
            if (!silent) {
                this.notifyChange(key, clonedValue, oldValue);
            }
            
            this.log('State updated:', key, '=', clonedValue);
            return true;
        } catch (error) {
            this.error('Failed to set state for key:', key, error);
            return false;
        }
    }
    
    /**
     * Get a state value with optional default
     * @param {string} key - State key
     * @param {*} defaultValue - Default value if key doesn't exist
     * @returns {*} State value or default
     */
    get(key, defaultValue = null) {
        if (!this.isValidKey(key)) {
            this.warn('Invalid key for get:', key);
            return defaultValue;
        }
        
        try {
            const value = this.state.get(key);
            return value !== undefined ? this.deepClone(value) : defaultValue;
        } catch (error) {
            this.error('Failed to get state for key:', key, error);
            return defaultValue;
        }
    }
    
    /**
     * Check if a key exists in state
     * @param {string} key - State key to check
     * @returns {boolean} Whether key exists
     */
    has(key) {
        return this.state.has(key);
    }
    
    /**
     * Delete a state key
     * @param {string} key - Key to delete
     * @param {boolean} silent - Skip change notifications
     * @returns {boolean} Success status
     */
    delete(key, silent = false) {
        if (!this.state.has(key)) {
            return true; // Already doesn't exist
        }
        
        try {
            const oldValue = this.state.get(key);
            this.state.delete(key);
            this.incrementOperationCount();
            
            if (!silent) {
                this.notifyChange(key, undefined, oldValue);
            }
            
            this.log('State key deleted:', key);
            return true;
        } catch (error) {
            this.error('Failed to delete state key:', key, error);
            return false;
        }
    }
    
    /**
     * Subscribe to state changes for a specific key
     * @param {string} key - Key to watch
     * @param {Function} callback - Change callback (newValue, oldValue, key)
     * @returns {Function} Unsubscribe function
     */
    subscribe(key, callback) {
        if (!this.isValidKey(key) || typeof callback !== 'function') {
            this.error('Invalid subscription parameters');
            return () => {}; // No-op unsubscribe
        }
        
        try {
            if (!this.changeListeners.has(key)) {
                this.changeListeners.set(key, new Set());
            }
            
            this.changeListeners.get(key).add(callback);
            this.log('Subscribed to key:', key);
            
            // Return unsubscribe function
            return () => {
                const listeners = this.changeListeners.get(key);
                if (listeners) {
                    listeners.delete(callback);
                    if (listeners.size === 0) {
                        this.changeListeners.delete(key);
                    }
                }
                this.log('Unsubscribed from key:', key);
            };
        } catch (error) {
            this.error('Failed to subscribe to key:', key, error);
            return () => {};
        }
    }
    
    /**
     * Subscribe to all state changes
     * @param {Function} callback - Global change callback
     * @returns {Function} Unsubscribe function
     */
    subscribeAll(callback) {
        return this.subscribe('*', callback);
    }
    
    /**
     * Add a validator for a specific key
     * @param {string} key - Key to validate
     * @param {Function} validator - Validation function (newValue, oldValue) => boolean
     */
    addValidator(key, validator) {
        if (!this.isValidKey(key) || typeof validator !== 'function') {
            this.error('Invalid validator parameters');
            return false;
        }
        
        this.validators.set(key, validator);
        this.log('Validator added for key:', key);
        return true;
    }
    
    /**
     * Remove validator for a key
     * @param {string} key - Key to remove validator from
     */
    removeValidator(key) {
        return this.validators.delete(key);
    }
    
    /**
     * Get all state keys
     * @returns {Array} Array of all keys
     */
    keys() {
        return Array.from(this.state.keys());
    }
    
    /**
     * Get all state values
     * @returns {Array} Array of all values
     */
    values() {
        return Array.from(this.state.values()).map(value => this.deepClone(value));
    }
    
    /**
     * Get entire state as object (deep cloned)
     * @returns {Object} Complete state object
     */
    getAll() {
        const result = {};
        this.state.forEach((value, key) => {
            result[key] = this.deepClone(value);
        });
        return result;
    }
    
    /**
     * Clear all state
     * @param {boolean} silent - Skip change notifications
     */
    clear(silent = false) {
        try {
            const oldState = this.getAll();
            this.state.clear();
            this.incrementOperationCount();
            
            if (!silent) {
                // Notify all listeners of the clear
                Object.keys(oldState).forEach(key => {
                    this.notifyChange(key, undefined, oldState[key]);
                });
            }
            
            this.log('State cleared');
        } catch (error) {
            this.error('Failed to clear state:', error);
        }
    }
    
    /**
     * Update multiple state values atomically
     * @param {Object} updates - Object with key-value pairs to update
     * @param {boolean} silent - Skip change notifications
     * @returns {boolean} Success status
     */
    updateMultiple(updates, silent = false) {
        if (!updates || typeof updates !== 'object') {
            this.error('Invalid updates object');
            return false;
        }
        
        try {
            const changes = [];
            
            // First pass: validate all changes
            for (const [key, value] of Object.entries(updates)) {
                if (!this.isValidKey(key)) {
                    this.error('Invalid key in batch update:', key);
                    return false;
                }
                
                const oldValue = this.state.get(key);
                const clonedValue = this.deepClone(value);
                
                // Validate if validator exists
                if (this.validators.has(key)) {
                    const validator = this.validators.get(key);
                    if (!validator(clonedValue, oldValue)) {
                        this.warn('Validation failed for key in batch:', key);
                        return false;
                    }
                }
                
                changes.push({ key, newValue: clonedValue, oldValue });
            }
            
            // Second pass: apply all changes
            changes.forEach(({ key, newValue }) => {
                this.state.set(key, newValue);
            });
            
            this.incrementOperationCount();
            
            // Third pass: notify changes
            if (!silent) {
                changes.forEach(({ key, newValue, oldValue }) => {
                    if (!this.deepEqual(newValue, oldValue)) {
                        this.notifyChange(key, newValue, oldValue);
                    }
                });
            }
            
            this.log('Batch update completed:', Object.keys(updates).length, 'keys');
            return true;
        } catch (error) {
            this.error('Failed batch update:', error);
            return false;
        }
    }
    
    /**
     * Enable/disable debug mode
     * @param {boolean} enabled - Debug mode state
     */
    setDebugMode(enabled) {
        this.debugMode = !!enabled;
        this.log('Debug mode:', this.debugMode ? 'enabled' : 'disabled');
    }
    
    /**
     * Get performance statistics
     * @returns {Object} Performance stats
     */
    getStats() {
        const now = Date.now();
        const uptime = now - (this.lastPerformanceCheck || now);
        
        return {
            keysCount: this.state.size,
            listenersCount: Array.from(this.changeListeners.values()).reduce((sum, set) => sum + set.size, 0),
            validatorsCount: this.validators.size,
            operationCount: this.operationCount,
            errorCount: this.errorCount,
            uptime: uptime,
            operationsPerSecond: uptime > 0 ? (this.operationCount / (uptime / 1000)).toFixed(2) : 0,
            memoryEstimate: this.estimateMemoryUsage()
        };
    }
    
    /**
     * Reset performance counters
     */
    resetStats() {
        this.operationCount = 0;
        this.errorCount = 0;
        this.lastPerformanceCheck = Date.now();
        this.log('Stats reset');
    }
    
    // === PRIVATE METHODS ===
    
    /**
     * Validate key format
     * @param {string} key - Key to validate
     * @returns {boolean} Is valid
     */
    isValidKey(key) {
        return typeof key === 'string' && key.length > 0 && key.length < 256;
    }
    
    /**
     * Deep clone a value
     * @param {*} value - Value to clone
     * @returns {*} Cloned value
     */
    deepClone(value) {
        if (value === null || typeof value !== 'object') {
            return value;
        }
        
        if (value instanceof Date) {
            return new Date(value.getTime());
        }
        
        if (Array.isArray(value)) {
            return value.map(item => this.deepClone(item));
        }
        
        const cloned = {};
        Object.keys(value).forEach(key => {
            cloned[key] = this.deepClone(value[key]);
        });
        
        return cloned;
    }
    
    /**
     * Deep equality check
     * @param {*} a - First value
     * @param {*} b - Second value
     * @returns {boolean} Are equal
     */
    deepEqual(a, b) {
        if (a === b) return true;
        if (a === null || b === null) return false;
        if (typeof a !== typeof b) return false;
        
        if (typeof a === 'object') {
            if (Array.isArray(a) !== Array.isArray(b)) return false;
            
            const keysA = Object.keys(a);
            const keysB = Object.keys(b);
            
            if (keysA.length !== keysB.length) return false;
            
            return keysA.every(key => this.deepEqual(a[key], b[key]));
        }
        
        return false;
    }
    
    /**
     * Notify change listeners
     * @param {string} key - Changed key
     * @param {*} newValue - New value
     * @param {*} oldValue - Old value
     */
    notifyChange(key, newValue, oldValue) {
        try {
            // Notify specific key listeners
            const listeners = this.changeListeners.get(key);
            if (listeners) {
                listeners.forEach(callback => {
                    try {
                        callback(newValue, oldValue, key);
                    } catch (error) {
                        this.error('Listener error for key:', key, error);
                    }
                });
            }
            
            // Notify global listeners
            const globalListeners = this.changeListeners.get('*');
            if (globalListeners) {
                globalListeners.forEach(callback => {
                    try {
                        callback(newValue, oldValue, key);
                    } catch (error) {
                        this.error('Global listener error:', error);
                    }
                });
            }
        } catch (error) {
            this.error('Failed to notify change:', error);
        }
    }
    
    /**
     * Increment operation counter
     */
    incrementOperationCount() {
        this.operationCount++;
        
        // Performance check every 1000 operations
        if (this.operationCount % 1000 === 0) {
            this.performanceCheck();
        }
    }
    
    /**
     * Perform periodic performance checks
     */
    performanceCheck() {
        const stats = this.getStats();
        
        if (stats.operationsPerSecond > 10000) {
            this.warn('High operation rate detected:', stats.operationsPerSecond, 'ops/sec');
        }
        
        if (stats.keysCount > 10000) {
            this.warn('Large state size detected:', stats.keysCount, 'keys');
        }
        
        if (stats.memoryEstimate > 100) {
            this.warn('High memory usage estimated:', stats.memoryEstimate, 'MB');
        }
    }
    
    /**
     * Estimate memory usage
     * @returns {number} Estimated MB
     */
    estimateMemoryUsage() {
        try {
            const jsonSize = JSON.stringify(this.getAll()).length;
            return (jsonSize / (1024 * 1024)).toFixed(2);
        } catch {
            return 0;
        }
    }
    
    /**
     * Logging functions with debug control
     */
    log(...args) {
        if (this.debugMode) {
            console.log('[HudState]', ...args);
        }
    }
    
    warn(...args) {
        console.warn('[HudState]', ...args);
    }
    
    error(...args) {
        console.error('[HudState]', ...args);
        this.errorCount++;
        
        if (this.errorCount > this.maxErrors) {
            console.error('[HudState] Too many errors, resetting...');
            this.initialize({}, false);
            this.errorCount = 0;
        }
    }
}

// === VALIDATORS LIBRARY ===

/**
 * Common validators for HUD state
 */
const HudValidators = {
    /**
     * Validate number within range
     */
    numberRange: (min, max) => (value) => {
        return typeof value === 'number' && value >= min && value <= max;
    },
    
    /**
     * Validate string with max length
     */
    stringMaxLength: (maxLength) => (value) => {
        return typeof value === 'string' && value.length <= maxLength;
    },
    
    /**
     * Validate boolean
     */
    boolean: (value) => {
        return typeof value === 'boolean';
    },
    
    /**
     * Validate theme name
     */
    themeName: (value) => {
        const validThemes = ['cyberpunk', 'synthwave', 'matrix'];
        return validThemes.includes(value);
    },
    
    /**
     * Validate HUD position
     */
    hudPosition: (value) => {
        const validPositions = ['top-left', 'top-right', 'bottom-left', 'bottom-right'];
        return validPositions.includes(value);
    },
    
    /**
     * Validate percentage (0-100)
     */
    percentage: (value) => {
        return typeof value === 'number' && value >= 0 && value <= 100;
    },
    
    /**
     * Validate opacity (0-1)
     */
    opacity: (value) => {
        return typeof value === 'number' && value >= 0 && value <= 1;
    }
};

// === GLOBAL INITIALIZATION ===

// Create global state manager instance
if (typeof window !== 'undefined') {
    // Browser environment
    window.hudState = new HudStateManager();
    window.HudValidators = HudValidators;
    
    // Debug access in development
    if (window.location.hostname !== 'nui-game-internal') {
        window.hudState.setDebugMode(true);
        window.hudState.log('Development mode detected - debug enabled');
    }
    
    // Prevent accidental localStorage usage
    if (typeof localStorage !== 'undefined') {
        const originalSetItem = localStorage.setItem;
        localStorage.setItem = function(key, value) {
            if (key.startsWith('hud') || key.includes('settings')) {
                console.warn('❌ localStorage blocked! Use hudState.set() instead');
                return;
            }
            return originalSetItem.call(this, key, value);
        };
    }
} else {
    // Node.js environment (for testing)
    global.HudStateManager = HudStateManager;
    global.HudValidators = HudValidators;
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { HudStateManager, HudValidators };
}