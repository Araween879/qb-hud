/**
 * 🎨 Enhanced HUD - Theme Manager System
 * 
 * Comprehensive neon theme management with:
 * - Dynamic theme switching
 * - CSS custom property manipulation
 * - Animation triggers
 * - Performance optimization
 * - GPU acceleration
 */

class HudThemeManager {
    constructor(stateManager = window.hudState) {
        this.stateManager = stateManager;
        this.currentTheme = 'cyberpunk';
        this.neonIntensity = 0.8;
        this.animationsEnabled = true;
        this.performanceMode = false;
        
        // Theme definitions
        this.themes = {
            cyberpunk: {
                name: 'Cyberpunk Protocol',
                description: 'High-tech cyan and purple aesthetic',
                colors: {
                    primary: '#00ffff',
                    secondary: '#a020f0',
                    accent: '#ff9800',
                    critical: '#ff4444',
                    success: '#66bb6a',
                    warning: '#ffb74d',
                    info: '#29b6f6'
                },
                effects: {
                    glowIntensity: 1.0,
                    animationSpeed: 1.0,
                    particleCount: 50
                }
            },
            synthwave: {
                name: 'Synthwave Protocol',
                description: 'Retro-futuristic pink and blue neon',
                colors: {
                    primary: '#ff0080',
                    secondary: '#8000ff',
                    accent: '#00ffff',
                    critical: '#ff4444',
                    success: '#00ff80',
                    warning: '#ffff00',
                    info: '#ff80ff'
                },
                effects: {
                    glowIntensity: 1.2,
                    animationSpeed: 0.8,
                    particleCount: 75
                }
            },
            matrix: {
                name: 'Matrix Protocol',
                description: 'Classic green matrix code aesthetic',
                colors: {
                    primary: '#00ff00',
                    secondary: '#008000',
                    accent: '#ffffff',
                    critical: '#ff4444',
                    success: '#00ff00',
                    warning: '#ffff00',
                    info: '#80ff80'
                },
                effects: {
                    glowIntensity: 0.9,
                    animationSpeed: 1.1,
                    particleCount: 30
                }
            }
        };
        
        // Active animations tracking
        this.activeAnimations = new Set();
        this.glowAnimations = new Map();
        
        // Performance tracking
        this.frameRequests = new Set();
        this.lastFrameTime = 0;
        
        this.initialize();
    }
    
    /**
     * Initialize theme manager
     */
    initialize() {
        this.log('Theme Manager initializing...');
        
        // Subscribe to state changes
        if (this.stateManager) {
            this.stateManager.subscribe('theme', (newTheme) => {
                this.setTheme(newTheme);
            });
            
            this.stateManager.subscribe('neonIntensity', (intensity) => {
                this.setNeonIntensity(intensity);
            });
            
            this.stateManager.subscribe('animationsEnabled', (enabled) => {
                this.setAnimationsEnabled(enabled);
            });
            
            this.stateManager.subscribe('performanceMode', (enabled) => {
                this.setPerformanceMode(enabled);
            });
            
            // Add validators
            this.stateManager.addValidator('theme', (value) => {
                return Object.keys(this.themes).includes(value);
            });
            
            this.stateManager.addValidator('neonIntensity', (value) => {
                return typeof value === 'number' && value >= 0 && value <= 2;
            });
        }
        
        // Apply initial theme
        this.applyTheme(this.currentTheme);
        this.log('Theme Manager initialized');
    }
    
    /**
     * Set active theme
     * @param {string} themeName - Theme to activate
     * @param {boolean} animate - Whether to animate transition
     * @returns {boolean} Success status
     */
    setTheme(themeName, animate = true) {
        if (!this.themes[themeName]) {
            this.error('Unknown theme:', themeName);
            return false;
        }
        
        if (this.currentTheme === themeName) {
            return true; // Already active
        }
        
        this.log('Changing theme from', this.currentTheme, 'to', themeName);
        
        const oldTheme = this.currentTheme;
        this.currentTheme = themeName;
        
        // Update state
        if (this.stateManager) {
            this.stateManager.set('theme', themeName, true); // Silent to avoid recursion
        }
        
        // Apply theme
        this.applyTheme(themeName, animate);
        
        // Trigger transition animation
        if (animate && this.animationsEnabled) {
            this.triggerThemeTransition(oldTheme, themeName);
        }
        
        // Notify components
        this.dispatchThemeChange(themeName, oldTheme);
        
        return true;
    }
    
    /**
     * Get current theme
     * @returns {string} Current theme name
     */
    getCurrentTheme() {
        return this.currentTheme;
    }
    
    /**
     * Get theme configuration
     * @param {string} themeName - Theme name (current if not specified)
     * @returns {Object} Theme configuration
     */
    getThemeConfig(themeName = this.currentTheme) {
        return this.themes[themeName] || null;
    }
    
    /**
     * Get all available themes
     * @returns {Object} All themes
     */
    getAvailableThemes() {
        return { ...this.themes };
    }
    
    /**
     * Apply theme to DOM
     * @param {string} themeName - Theme to apply
     * @param {boolean} animate - Whether to animate
     */
    applyTheme(themeName, animate = false) {
        const theme = this.themes[themeName];
        if (!theme) return;
        
        const root = document.documentElement;
        
        // Remove old theme classes
        Object.keys(this.themes).forEach(name => {
            document.body.classList.remove(`theme-${name}`);
        });
        
        // Add new theme class
        document.body.classList.add(`theme-${themeName}`);
        
        // Update CSS custom properties
        Object.entries(theme.colors).forEach(([key, value]) => {
            root.style.setProperty(`--theme-${key}`, value);
            root.style.setProperty(`--color-${key}`, value); // Legacy support
        });
        
        // Update effect properties
        Object.entries(theme.effects).forEach(([key, value]) => {
            root.style.setProperty(`--effect-${key}`, value);
        });
        
        // Update neon intensity
        this.updateNeonIntensity();
        
        // Update performance mode styles
        this.updatePerformanceMode();
        
        this.log('Theme applied:', themeName);
    }
    
    /**
     * Set neon glow intensity
     * @param {number} intensity - Intensity (0-2)
     */
    setNeonIntensity(intensity) {
        if (typeof intensity !== 'number' || intensity < 0 || intensity > 2) {
            this.error('Invalid neon intensity:', intensity);
            return;
        }
        
        this.neonIntensity = intensity;
        
        if (this.stateManager) {
            this.stateManager.set('neonIntensity', intensity, true);
        }
        
        this.updateNeonIntensity();
        this.log('Neon intensity set to:', intensity);
    }
    
    /**
     * Update neon intensity in CSS
     */
    updateNeonIntensity() {
        const root = document.documentElement;
        const theme = this.themes[this.currentTheme];
        
        if (!theme) return;
        
        // Calculate intensity-based values
        const baseIntensity = theme.effects.glowIntensity * this.neonIntensity;
        const shadowIntensity = Math.round(baseIntensity * 20);
        const blurIntensity = Math.round(baseIntensity * 10);
        
        // Update CSS variables
        root.style.setProperty('--neon-intensity', baseIntensity);
        root.style.setProperty('--shadow-intensity', `${shadowIntensity}px`);
        root.style.setProperty('--blur-intensity', `${blurIntensity}px`);
        
        // Update theme-specific glow shadows
        Object.entries(theme.colors).forEach(([key, color]) => {
            const glowShadow = `0 0 ${shadowIntensity}px ${color}, 0 0 ${shadowIntensity * 2}px ${color}`;
            root.style.setProperty(`--glow-${key}`, glowShadow);
        });
    }
    
    /**
     * Enable/disable animations
     * @param {boolean} enabled - Animation state
     */
    setAnimationsEnabled(enabled) {
        this.animationsEnabled = !!enabled;
        
        if (this.stateManager) {
            this.stateManager.set('animationsEnabled', enabled, true);
        }
        
        // Update CSS class
        document.body.classList.toggle('animations-disabled', !enabled);
        
        // Clear active animations if disabled
        if (!enabled) {
            this.clearAllAnimations();
        }
        
        this.log('Animations', enabled ? 'enabled' : 'disabled');
    }
    
    /**
     * Enable/disable performance mode
     * @param {boolean} enabled - Performance mode state
     */
    setPerformanceMode(enabled) {
        this.performanceMode = !!enabled;
        
        if (this.stateManager) {
            this.stateManager.set('performanceMode', enabled, true);
        }
        
        this.updatePerformanceMode();
        this.log('Performance mode', enabled ? 'enabled' : 'disabled');
    }
    
    /**
     * Update performance mode styles
     */
    updatePerformanceMode() {
        const root = document.documentElement;
        
        if (this.performanceMode) {
            document.body.classList.add('performance-mode');
            
            // Reduce animation durations
            root.style.setProperty('--duration-fast', '50ms');
            root.style.setProperty('--duration-normal', '100ms');
            root.style.setProperty('--duration-slow', '150ms');
            
            // Reduce glow effects
            this.neonIntensity *= 0.5;
            this.updateNeonIntensity();
        } else {
            document.body.classList.remove('performance-mode');
            
            // Restore normal durations
            root.style.setProperty('--duration-fast', '150ms');
            root.style.setProperty('--duration-normal', '300ms');
            root.style.setProperty('--duration-slow', '500ms');
        }
    }
    
    /**
     * Trigger glow effect on element
     * @param {string|Element} element - Element selector or element
     * @param {string} color - Glow color
     * @param {number} intensity - Glow intensity
     * @param {number} duration - Effect duration (ms)
     */
    triggerGlow(element, color, intensity = 1.0, duration = 1000) {
        if (!this.animationsEnabled) return;
        
        const targetElement = typeof element === 'string' 
            ? document.querySelector(element) 
            : element;
            
        if (!targetElement) {
            this.warn('Glow target not found:', element);
            return;
        }
        
        const effectIntensity = intensity * this.neonIntensity;
        const glowId = `glow-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        
        // Clear existing glow on this element
        const existingGlow = this.glowAnimations.get(targetElement);
        if (existingGlow) {
            this.clearGlow(targetElement);
        }
        
        // Apply glow effect
        const shadowSize = Math.round(20 * effectIntensity);
        const shadowBlur = Math.round(40 * effectIntensity);
        const glowShadow = `0 0 ${shadowSize}px ${color}, 0 0 ${shadowBlur}px ${color}`;
        
        targetElement.style.boxShadow = glowShadow;
        targetElement.style.transform = `scale(${1 + (0.05 * effectIntensity)})`;
        targetElement.style.transition = `all ${Math.min(duration * 0.1, 200)}ms ease-out`;
        
        // Store animation reference
        this.glowAnimations.set(targetElement, glowId);
        
        // Clear glow after duration
        setTimeout(() => {
            if (this.glowAnimations.get(targetElement) === glowId) {
                this.clearGlow(targetElement);
            }
        }, duration);
        
        this.log('Glow triggered on', element, 'with color', color);
    }
    
    /**
     * Clear glow effect from element
     * @param {Element} element - Target element
     */
    clearGlow(element) {
        if (!element) return;
        
        element.style.boxShadow = '';
        element.style.transform = '';
        
        this.glowAnimations.delete(element);
    }
    
    /**
     * Trigger critical alert animation
     * @param {string|Element} element - Target element
     * @param {number} value - Critical value
     * @param {number} threshold - Critical threshold
     */
    triggerCriticalAlert(element, value, threshold = 20) {
        if (!this.animationsEnabled || value > threshold) return;
        
        const targetElement = typeof element === 'string' 
            ? document.querySelector(element) 
            : element;
            
        if (!targetElement) return;
        
        const theme = this.themes[this.currentTheme];
        const criticalColor = theme.colors.critical;
        
        // Add critical class
        targetElement.classList.add('critical-state');
        
        // Trigger intense glow
        this.triggerGlow(targetElement, criticalColor, 1.5, 3000);
        
        // Play critical sound if available
        this.dispatchCriticalAlert(element, value);
        
        // Remove critical class after animation
        setTimeout(() => {
            targetElement.classList.remove('critical-state');
        }, 3000);
        
        this.log('Critical alert triggered for', element, 'value:', value);
    }
    
    /**
     * Trigger theme transition animation
     * @param {string} oldTheme - Previous theme
     * @param {string} newTheme - New theme
     */
    triggerThemeTransition(oldTheme, newTheme) {
        if (!this.animationsEnabled) return;
        
        const overlay = document.createElement('div');
        overlay.className = 'theme-transition-overlay';
        
        const newThemeConfig = this.themes[newTheme];
        const gradient = `linear-gradient(45deg, ${newThemeConfig.colors.primary}, ${newThemeConfig.colors.secondary})`;
        
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: ${gradient};
            opacity: 0;
            z-index: var(--z-theme-transition, 9998);
            pointer-events: none;
            transition: opacity 0.5s ease;
        `;
        
        document.body.appendChild(overlay);
        
        // Animate transition
        requestAnimationFrame(() => {
            overlay.style.opacity = '0.3';
        });
        
        setTimeout(() => {
            overlay.style.opacity = '0';
        }, 300);
        
        setTimeout(() => {
            if (overlay.parentNode) {
                document.body.removeChild(overlay);
            }
        }, 800);
        
        this.log('Theme transition animated from', oldTheme, 'to', newTheme);
    }
    
    /**
     * Enable scan line effect
     */
    enableScanLines() {
        if (!this.animationsEnabled) return;
        
        const scanLine = document.createElement('div');
        scanLine.className = 'scan-line-effect';
        
        const theme = this.themes[this.currentTheme];
        
        scanLine.style.cssText = `
            position: fixed;
            top: 0;
            left: -100%;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, transparent, ${theme.colors.primary}, transparent);
            z-index: var(--z-effects, 9997);
            pointer-events: none;
            animation: dataScan 4s linear;
        `;
        
        document.body.appendChild(scanLine);
        
        setTimeout(() => {
            if (scanLine.parentNode) {
                document.body.removeChild(scanLine);
            }
        }, 4000);
        
        this.log('Scan lines enabled');
    }
    
    /**
     * Animate value change with smooth transitions
     * @param {string|Element} element - Target element
     * @param {number} oldValue - Previous value
     * @param {number} newValue - New value
     * @param {number} duration - Animation duration
     */
    animateValueChange(element, oldValue, newValue, duration = 500) {
        if (!this.animationsEnabled) return;
        
        const targetElement = typeof element === 'string' 
            ? document.querySelector(element) 
            : element;
            
        if (!targetElement) return;
        
        const startTime = performance.now();
        const difference = newValue - oldValue;
        
        const animate = (currentTime) => {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            
            // Easing function (ease-out cubic)
            const easedProgress = 1 - Math.pow(1 - progress, 3);
            const currentValue = oldValue + (difference * easedProgress);
            
            // Update element content
            if (targetElement.textContent !== undefined) {
                targetElement.textContent = Math.round(currentValue);
            }
            
            // Continue animation
            if (progress < 1) {
                const frameId = requestAnimationFrame(animate);
                this.frameRequests.add(frameId);
            }
        };
        
        const frameId = requestAnimationFrame(animate);
        this.frameRequests.add(frameId);
        
        this.log('Value animation started for', element);
    }
    
    /**
     * Clear all active animations
     */
    clearAllAnimations() {
        // Clear frame requests
        this.frameRequests.forEach(frameId => {
            cancelAnimationFrame(frameId);
        });
        this.frameRequests.clear();
        
        // Clear glow animations
        this.glowAnimations.forEach((glowId, element) => {
            this.clearGlow(element);
        });
        
        // Remove animation classes
        document.querySelectorAll('.critical-state, .theme-transition-overlay, .scan-line-effect').forEach(el => {
            el.remove();
        });
        
        this.log('All animations cleared');
    }
    
    /**
     * Dispatch theme change event
     * @param {string} newTheme - New theme
     * @param {string} oldTheme - Previous theme
     */
    dispatchThemeChange(newTheme, oldTheme) {
        const event = new CustomEvent('themeChanged', {
            detail: { newTheme, oldTheme, themeConfig: this.themes[newTheme] }
        });
        document.dispatchEvent(event);
    }
    
    /**
     * Dispatch critical alert event
     * @param {string|Element} element - Target element
     * @param {number} value - Critical value
     */
    dispatchCriticalAlert(element, value) {
        const event = new CustomEvent('criticalAlert', {
            detail: { element, value, threshold: 20 }
        });
        document.dispatchEvent(event);
    }
    
    /**
     * Get theme performance stats
     * @returns {Object} Performance statistics
     */
    getStats() {
        return {
            currentTheme: this.currentTheme,
            neonIntensity: this.neonIntensity,
            animationsEnabled: this.animationsEnabled,
            performanceMode: this.performanceMode,
            activeAnimations: this.activeAnimations.size,
            activeGlows: this.glowAnimations.size,
            frameRequests: this.frameRequests.size
        };
    }
    
    /**
     * Logging functions
     */
    log(...args) {
        console.log('[ThemeManager]', ...args);
    }
    
    warn(...args) {
        console.warn('[ThemeManager]', ...args);
    }
    
    error(...args) {
        console.error('[ThemeManager]', ...args);
    }
}

// === THEME UTILITIES ===

/**
 * Theme utility functions
 */
const ThemeUtils = {
    /**
     * Convert hex color to rgba
     * @param {string} hex - Hex color
     * @param {number} alpha - Alpha value
     * @returns {string} RGBA color
     */
    hexToRgba(hex, alpha = 1) {
        const r = parseInt(hex.slice(1, 3), 16);
        const g = parseInt(hex.slice(3, 5), 16);
        const b = parseInt(hex.slice(5, 7), 16);
        return `rgba(${r}, ${g}, ${b}, ${alpha})`;
    },
    
    /**
     * Generate glow CSS for color
     * @param {string} color - Base color
     * @param {number} intensity - Glow intensity
     * @returns {string} CSS box-shadow
     */
    generateGlow(color, intensity = 1) {
        const size = Math.round(20 * intensity);
        const blur = Math.round(40 * intensity);
        return `0 0 ${size}px ${color}, 0 0 ${blur}px ${color}`;
    },
    
    /**
     * Get contrast color (black or white)
     * @param {string} hexColor - Background color
     * @returns {string} Contrast color
     */
    getContrastColor(hexColor) {
        const r = parseInt(hexColor.slice(1, 3), 16);
        const g = parseInt(hexColor.slice(3, 5), 16);
        const b = parseInt(hexColor.slice(5, 7), 16);
        const brightness = (r * 299 + g * 587 + b * 114) / 1000;
        return brightness > 128 ? '#000000' : '#ffffff';
    }
};

// === GLOBAL INITIALIZATION ===

if (typeof window !== 'undefined') {
    // Initialize global theme manager
    window.hudThemeManager = new HudThemeManager();
    window.ThemeUtils = ThemeUtils;
    
    // Auto-initialize when state manager is ready
    if (window.hudState && window.hudState.initialized) {
        window.hudThemeManager.initialize();
    } else {
        // Wait for state manager
        document.addEventListener('DOMContentLoaded', () => {
            if (window.hudState) {
                window.hudThemeManager.initialize();
            }
        });
    }
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { HudThemeManager, ThemeUtils };
}