--[[
    File: module-tests.lua
    Description: Unit tests for individual HUD system components
    Author: QBCore Development Team
    Version: 3.2.0
    
    Tests all core modules and components individually to ensure
    proper functionality and error handling.
]]

-- Import test framework (should be loaded by test-runner.lua)
local Assert = TestRunner.Assert
local Utils = TestRunner.Utils
local Mock = TestRunner.Mock

-- Test Data Generators
local TestData = {
    validPlayerStatus = function()
        return {
            health = 85,
            armor = 100,
            hunger = 67,
            thirst = 45,
            stress = 23,
            stamina = 89
        }
    end,
    
    invalidPlayerStatus = function()
        return {
            health = "invalid",
            armor = -10,
            hunger = 150,
            thirst = nil,
            stress = {},
            stamina = function() end
        }
    end,
    
    validVehicleData = function()
        return {
            speed = 65,
            fuel = 78,
            engine = 850,
            gear = 3,
            rpm = 4500,
            maxSpeed = 180
        }
    end,
    
    validTheme = function()
        return {
            name = 'test_theme',
            displayName = 'Test Theme',
            colors = {
                primary = '#00ffff',
                secondary = '#a020f0',
                background = 'rgba(0, 0, 0, 0.8)',
                text = '#ffffff'
            },
            animations = {
                enabled = true,
                fadeTime = 300
            }
        }
    end
}

-- ========================================
-- Component Manager Tests
-- ========================================

local componentManagerSuite = TestRunner.createSuite('ComponentManager', 'Tests for the component management system')

TestRunner.addTest('ComponentManager', 'should_initialize_successfully', function()
    -- Test ComponentManager initialization
    local result = ComponentManager.initialize()
    Assert.isTrue(result, 'ComponentManager should initialize successfully')
    Assert.isTrue(ComponentManager.isInitialized(), 'ComponentManager should be marked as initialized')
end, 'ComponentManager should initialize without errors')

TestRunner.addTest('ComponentManager', 'should_register_valid_component', function()
    local testComponent = {
        name = 'TestComponent',
        element = '#test-component',
        visible = true,
        priority = 100,
        show = function() end,
        hide = function() end,
        update = function() end
    }
    
    local success = ComponentManager.register('TestComponent', testComponent)
    Assert.isTrue(success, 'Should successfully register valid component')
    
    local retrieved = ComponentManager.get('TestComponent')
    Assert.isNotNil(retrieved, 'Should be able to retrieve registered component')
    Assert.equal(retrieved.name, 'TestComponent', 'Retrieved component should have correct name')
end, 'Valid components should register successfully')

TestRunner.addTest('ComponentManager', 'should_reject_invalid_component', function()
    local invalidComponent = {
        name = 'InvalidComponent'
        -- Missing required methods and properties
    }
    
    Assert.throws(function()
        ComponentManager.register('InvalidComponent', invalidComponent)
    end, 'Missing required', 'Should throw error for invalid component')
end, 'Invalid components should be rejected')

TestRunner.addTest('ComponentManager', 'should_unregister_component', function()
    -- First register a component
    local testComponent = {
        name = 'TempComponent',
        element = '#temp',
        visible = true,
        show = function() end,
        hide = function() end,
        update = function() end
    }
    
    ComponentManager.register('TempComponent', testComponent)
    Assert.isNotNil(ComponentManager.get('TempComponent'), 'Component should be registered')
    
    -- Now unregister it
    local success = ComponentManager.unregister('TempComponent')
    Assert.isTrue(success, 'Should successfully unregister component')
    Assert.isNil(ComponentManager.get('TempComponent'), 'Component should no longer exist')
end, 'Components should be unregisterable')

TestRunner.addTest('ComponentManager', 'should_update_component_with_valid_data', function()
    local updateCalled = false
    local receivedData = nil
    
    local testComponent = {
        name = 'UpdateTestComponent',
        element = '#update-test',
        visible = true,
        show = function() end,
        hide = function() end,
        update = function(self, data)
            updateCalled = true
            receivedData = data
        end
    }
    
    ComponentManager.register('UpdateTestComponent', testComponent)
    
    local testData = { test = 'value' }
    ComponentManager.updateComponent('UpdateTestComponent', testData)
    
    Assert.isTrue(updateCalled, 'Component update method should be called')
    Assert.equal(receivedData.test, 'value', 'Component should receive correct data')
end, 'Component updates should work with valid data')

TestRunner.addTest('ComponentManager', 'should_handle_component_show_hide', function()
    local showCalled = false
    local hideCalled = false
    
    local testComponent = {
        name = 'VisibilityTestComponent',
        element = '#visibility-test',
        visible = true,
        show = function() showCalled = true end,
        hide = function() hideCalled = true end,
        update = function() end
    }
    
    ComponentManager.register('VisibilityTestComponent', testComponent)
    
    ComponentManager.hide('VisibilityTestComponent')
    Assert.isTrue(hideCalled, 'Hide method should be called')
    
    ComponentManager.show('VisibilityTestComponent')
    Assert.isTrue(showCalled, 'Show method should be called')
end, 'Component visibility controls should work')

-- ========================================
-- Status Manager Tests
-- ========================================

local statusManagerSuite = TestRunner.createSuite('StatusManager', 'Tests for player status management')

TestRunner.addTest('StatusManager', 'should_update_status_with_valid_data', function()
    local validStatus = TestData.validPlayerStatus()
    
    local success = StatusManager.updateStatus(validStatus)
    Assert.isTrue(success, 'Should accept valid status data')
    
    local currentStatus = StatusManager.getCurrentStatus()
    Assert.equal(currentStatus.health, validStatus.health, 'Health should be updated')
    Assert.equal(currentStatus.armor, validStatus.armor, 'Armor should be updated')
end, 'Valid status data should be processed correctly')

TestRunner.addTest('StatusManager', 'should_validate_status_data', function()
    local invalidStatus = TestData.invalidPlayerStatus()
    
    Assert.throws(function()
        StatusManager.updateStatus(invalidStatus)
    end, 'Invalid', 'Should reject invalid status data')
end, 'Invalid status data should be rejected')

TestRunner.addTest('StatusManager', 'should_clamp_status_values', function()
    local extremeStatus = {
        health = 150,  -- Over 100
        armor = -50,   -- Below 0
        hunger = 200,  -- Over 100
        thirst = -10   -- Below 0
    }
    
    StatusManager.updateStatus(extremeStatus)
    local currentStatus = StatusManager.getCurrentStatus()
    
    Assert.equal(currentStatus.health, 100, 'Health should be clamped to 100')
    Assert.equal(currentStatus.armor, 0, 'Armor should be clamped to 0')
    Assert.equal(currentStatus.hunger, 100, 'Hunger should be clamped to 100')
    Assert.equal(currentStatus.thirst, 0, 'Thirst should be clamped to 0')
end, 'Status values should be clamped to valid ranges')

TestRunner.addTest('StatusManager', 'should_calculate_status_changes', function()
    local initialStatus = { health = 100, armor = 50 }
    StatusManager.updateStatus(initialStatus)
    
    local newStatus = { health = 85, armor = 75 }
    StatusManager.updateStatus(newStatus)
    
    local changes = StatusManager.getLastChanges()
    Assert.equal(changes.health, -15, 'Health change should be calculated correctly')
    Assert.equal(changes.armor, 25, 'Armor change should be calculated correctly')
end, 'Status changes should be tracked correctly')

-- ========================================
-- Theme Manager Tests
-- ========================================

local themeManagerSuite = TestRunner.createSuite('ThemeManager', 'Tests for theme management system')

TestRunner.addTest('ThemeManager', 'should_register_valid_theme', function()
    local validTheme = TestData.validTheme()
    
    local success = ThemeManager.registerTheme(validTheme)
    Assert.isTrue(success, 'Should register valid theme')
    
    local themes = ThemeManager.getAvailableThemes()
    Assert.contains(themes, 'test_theme', 'Theme should appear in available themes list')
end, 'Valid themes should register successfully')

TestRunner.addTest('ThemeManager', 'should_reject_invalid_theme', function()
    local invalidTheme = {
        name = 'invalid_theme'
        -- Missing required properties
    }
    
    Assert.throws(function()
        ThemeManager.registerTheme(invalidTheme)
    end, 'Invalid theme', 'Should reject invalid theme')
end, 'Invalid themes should be rejected')

TestRunner.addTest('ThemeManager', 'should_switch_themes', function()
    -- Register test theme first
    local testTheme = TestData.validTheme()
    ThemeManager.registerTheme(testTheme)
    
    local success = ThemeManager.setTheme('test_theme')
    Assert.isTrue(success, 'Should switch to valid theme')
    
    local currentTheme = ThemeManager.getTheme()
    Assert.equal(currentTheme, 'test_theme', 'Current theme should be updated')
end, 'Theme switching should work correctly')

TestRunner.addTest('ThemeManager', 'should_validate_theme_colors', function()
    local themeWithInvalidColors = {
        name = 'invalid_colors',
        displayName = 'Invalid Colors',
        colors = {
            primary = 'not-a-color',
            secondary = '#invalid-hex',
            background = 123
        }
    }
    
    Assert.throws(function()
        ThemeManager.registerTheme(themeWithInvalidColors)
    end, 'Invalid color', 'Should reject themes with invalid colors')
end, 'Theme color validation should work')

-- ========================================
-- Animation Manager Tests
-- ========================================

local animationManagerSuite = TestRunner.createSuite('AnimationManager', 'Tests for animation system')

TestRunner.addTest('AnimationManager', 'should_enable_disable_animations', function()
    AnimationManager.setEnabled(false)
    Assert.isFalse(AnimationManager.isEnabled(), 'Animations should be disabled')
    
    AnimationManager.setEnabled(true)
    Assert.isTrue(AnimationManager.isEnabled(), 'Animations should be enabled')
end, 'Animation toggle should work')

TestRunner.addTest('AnimationManager', 'should_set_animation_speed', function()
    AnimationManager.setSpeed(2.0)
    Assert.equal(AnimationManager.getSpeed(), 2.0, 'Animation speed should be set correctly')
    
    AnimationManager.setSpeed(0.5)
    Assert.equal(AnimationManager.getSpeed(), 0.5, 'Animation speed should update')
end, 'Animation speed control should work')

TestRunner.addTest('AnimationManager', 'should_validate_animation_speed', function()
    Assert.throws(function()
        AnimationManager.setSpeed(-1)
    end, 'Invalid speed', 'Should reject negative animation speed')
    
    Assert.throws(function()
        AnimationManager.setSpeed(0)
    end, 'Invalid speed', 'Should reject zero animation speed')
end, 'Animation speed validation should work')

-- ========================================
-- Configuration Manager Tests
-- ========================================

local configManagerSuite = TestRunner.createSuite('ConfigManager', 'Tests for configuration management')

TestRunner.addTest('ConfigManager', 'should_get_set_config_values', function()
    Config.set('test.value', 'test_data')
    local value = Config.get('test.value')
    Assert.equal(value, 'test_data', 'Should be able to set and get config values')
end, 'Configuration get/set should work')

TestRunner.addTest('ConfigManager', 'should_provide_default_values', function()
    local value = Config.get('nonexistent.key', 'default_value')
    Assert.equal(value, 'default_value', 'Should return default value for nonexistent keys')
end, 'Default values should be returned for missing keys')

TestRunner.addTest('ConfigManager', 'should_validate_config_types', function()
    -- Set up type validation
    Config.setTypeValidation('test.number', 'number')
    
    Config.set('test.number', 42)
    Assert.equal(Config.get('test.number'), 42, 'Should accept valid type')
    
    Assert.throws(function()
        Config.set('test.number', 'not-a-number')
    end, 'Invalid type', 'Should reject invalid type')
end, 'Configuration type validation should work')

-- ========================================
-- Event Handler Tests
-- ========================================

local eventHandlerSuite = TestRunner.createSuite('EventHandler', 'Tests for event handling system')

TestRunner.addTest('EventHandler', 'should_register_and_trigger_events', function()
    local eventTriggered = false
    local receivedData = nil
    
    EventHandler.register('test:event', function(data)
        eventTriggered = true
        receivedData = data
    end)
    
    EventHandler.trigger('test:event', { test = 'data' })
    
    Assert.isTrue(eventTriggered, 'Event handler should be triggered')
    Assert.equal(receivedData.test, 'data', 'Event handler should receive correct data')
end, 'Event registration and triggering should work')

TestRunner.addTest('EventHandler', 'should_handle_multiple_handlers', function()
    local handler1Called = false
    local handler2Called = false
    
    EventHandler.register('test:multiple', function() handler1Called = true end)
    EventHandler.register('test:multiple', function() handler2Called = true end)
    
    EventHandler.trigger('test:multiple')
    
    Assert.isTrue(handler1Called, 'First handler should be called')
    Assert.isTrue(handler2Called, 'Second handler should be called')
end, 'Multiple event handlers should work')

TestRunner.addTest('EventHandler', 'should_unregister_events', function()
    local eventTriggered = false
    
    local handlerId = EventHandler.register('test:unregister', function()
        eventTriggered = true
    end)
    
    EventHandler.unregister('test:unregister', handlerId)
    EventHandler.trigger('test:unregister')
    
    Assert.isFalse(eventTriggered, 'Unregistered handler should not be called')
end, 'Event unregistration should work')

-- ========================================
-- Utility Function Tests
-- ========================================

local utilsSuite = TestRunner.createSuite('Utils', 'Tests for utility functions')

TestRunner.addTest('Utils', 'should_validate_data_types', function()
    Assert.isTrue(Utils.isValidNumber(42), 'Should recognize valid numbers')
    Assert.isFalse(Utils.isValidNumber('not-a-number'), 'Should reject invalid numbers')
    
    Assert.isTrue(Utils.isValidString('hello'), 'Should recognize valid strings')
    Assert.isFalse(Utils.isValidString(123), 'Should reject invalid strings')
    
    Assert.isTrue(Utils.isValidTable({}), 'Should recognize valid tables')
    Assert.isFalse(Utils.isValidTable('not-a-table'), 'Should reject invalid tables')
end, 'Data type validation should work')

TestRunner.addTest('Utils', 'should_clamp_values', function()
    Assert.equal(Utils.clamp(50, 0, 100), 50, 'Should not change values within range')
    Assert.equal(Utils.clamp(-10, 0, 100), 0, 'Should clamp to minimum')
    Assert.equal(Utils.clamp(150, 0, 100), 100, 'Should clamp to maximum')
end, 'Value clamping should work correctly')

TestRunner.addTest('Utils', 'should_format_values', function()
    Assert.equal(Utils.formatPercentage(0.5), '50%', 'Should format percentages correctly')
    Assert.equal(Utils.formatTime(65), '1:05', 'Should format time correctly')
    Assert.equal(Utils.formatNumber(1234.56), '1,234.56', 'Should format numbers correctly')
end, 'Value formatting should work')

TestRunner.addTest('Utils', 'should_deep_copy_tables', function()
    local original = {
        a = 1,
        b = { c = 2, d = { e = 3 } }
    }
    
    local copy = Utils.deepCopy(original)
    
    -- Modify original
    original.a = 99
    original.b.c = 99
    original.b.d.e = 99
    
    -- Copy should be unchanged
    Assert.equal(copy.a, 1, 'Top level should be copied')
    Assert.equal(copy.b.c, 2, 'Second level should be copied')
    Assert.equal(copy.b.d.e, 3, 'Third level should be copied')
end, 'Deep copying should work correctly')

-- ========================================
-- Error Handler Tests
-- ========================================

local errorHandlerSuite = TestRunner.createSuite('ErrorHandler', 'Tests for error handling system')

TestRunner.addTest('ErrorHandler', 'should_catch_and_log_errors', function()
    local errorLogged = false
    local loggedMessage = ''
    
    -- Mock the logging function
    local originalLog = ErrorHandler.log
    ErrorHandler.log = function(message)
        errorLogged = true
        loggedMessage = message
    end
    
    ErrorHandler.safeCall(function()
        error('Test error message')
    end)
    
    -- Restore original function
    ErrorHandler.log = originalLog
    
    Assert.isTrue(errorLogged, 'Error should be logged')
    Assert.contains(loggedMessage, 'Test error message', 'Error message should be logged')
end, 'Error logging should work')

TestRunner.addTest('ErrorHandler', 'should_provide_fallback_values', function()
    local result = ErrorHandler.safeCall(function()
        error('Test error')
    end, 'fallback_value')
    
    Assert.equal(result, 'fallback_value', 'Should return fallback value on error')
end, 'Error fallback should work')

-- ========================================
-- Performance Monitor Tests
-- ========================================

local performanceMonitorSuite = TestRunner.createSuite('PerformanceMonitor', 'Tests for performance monitoring')

TestRunner.addTest('PerformanceMonitor', 'should_measure_execution_time', function()
    PerformanceMonitor.start('test_operation')
    
    -- Simulate some work
    Citizen.Wait(10)
    
    local duration = PerformanceMonitor.stop('test_operation')
    
    Assert.isGreaterThan(duration, 8, 'Should measure execution time')
    Assert.isLessThan(duration, 50, 'Duration should be reasonable')
end, 'Performance measurement should work')

TestRunner.addTest('PerformanceMonitor', 'should_track_memory_usage', function()
    local initialMemory = PerformanceMonitor.getMemoryUsage()
    
    -- Create some memory usage
    local largeTable = {}
    for i = 1, 1000 do
        largeTable[i] = string.rep('x', 100)
    end
    
    local finalMemory = PerformanceMonitor.getMemoryUsage()
    
    Assert.isGreaterThan(finalMemory, initialMemory, 'Should detect memory usage increase')
end, 'Memory tracking should work')

-- ========================================
-- Database Integration Tests
-- ========================================

local databaseSuite = TestRunner.createSuite('Database', 'Tests for database operations')

TestRunner.addTest('Database', 'should_save_player_settings', function()
    local testSettings = {
        theme = 'neon',
        animations = true,
        performanceMode = 'high'
    }
    
    local success = Database.savePlayerSettings('test_player', testSettings)
    Assert.isTrue(success, 'Should save player settings successfully')
end, 'Player settings should save to database')

TestRunner.addTest('Database', 'should_load_player_settings', function()
    -- First save some settings
    local testSettings = {
        theme = 'dark',
        animations = false,
        performanceMode = 'low'
    }
    
    Database.savePlayerSettings('test_player2', testSettings)
    
    -- Then load them back
    local loadedSettings = Database.loadPlayerSettings('test_player2')
    
    Assert.equal(loadedSettings.theme, 'dark', 'Theme should be loaded correctly')
    Assert.isFalse(loadedSettings.animations, 'Animation setting should be loaded correctly')
    Assert.equal(loadedSettings.performanceMode, 'low', 'Performance mode should be loaded correctly')
end, 'Player settings should load from database')

TestRunner.addTest('Database', 'should_handle_database_errors', function()
    -- Mock database failure
    local originalExecute = MySQL.query
    MySQL.query = function(query, params, callback)
        callback(false) -- Simulate failure
    end
    
    local success = Database.savePlayerSettings('test_player3', {})
    Assert.isFalse(success, 'Should handle database errors gracefully')
    
    -- Restore original function
    MySQL.query = originalExecute
end, 'Database errors should be handled gracefully')

-- ========================================
-- Stress Tests
-- ========================================

local stressSuite = TestRunner.createSuite('StressTests', 'Stress tests for system limits')

TestRunner.addTest('StressTests', 'should_handle_rapid_component_updates', function()
    local testComponent = {
        name = 'StressTestComponent',
        element = '#stress-test',
        visible = true,
        updateCount = 0,
        show = function() end,
        hide = function() end,
        update = function(self, data)
            self.updateCount = self.updateCount + 1
        end
    }
    
    ComponentManager.register('StressTestComponent', testComponent)
    
    -- Perform rapid updates
    for i = 1, 100 do
        ComponentManager.updateComponent('StressTestComponent', { value = i })
    end
    
    local component = ComponentManager.get('StressTestComponent')
    Assert.equal(component.updateCount, 100, 'Should handle all rapid updates')
end, 'System should handle rapid updates')

TestRunner.addTest('StressTests', 'should_handle_many_components', function()
    local componentCount = 50
    
    -- Register many components
    for i = 1, componentCount do
        local component = {
            name = 'MassTestComponent' .. i,
            element = '#mass-test-' .. i,
            visible = true,
            show = function() end,
            hide = function() end,
            update = function() end
        }
        ComponentManager.register('MassTestComponent' .. i, component)
    end
    
    -- Verify all components are registered
    for i = 1, componentCount do
        local component = ComponentManager.get('MassTestComponent' .. i)
        Assert.isNotNil(component, 'Component ' .. i .. ' should be registered')
    end
end, 'System should handle many components')

-- ========================================
-- Test Setup and Teardown
-- ========================================

-- Setup functions for test suites
componentManagerSuite.setup = function()
    -- Initialize ComponentManager for testing
    if not ComponentManager.isInitialized() then
        ComponentManager.initialize()
    end
end

componentManagerSuite.teardown = function()
    -- Clean up test components
    local testComponents = {
        'TestComponent',
        'TempComponent', 
        'UpdateTestComponent',
        'VisibilityTestComponent',
        'StressTestComponent'
    }
    
    for _, name in ipairs(testComponents) do
        ComponentManager.unregister(name)
    end
end

statusManagerSuite.setup = function()
    -- Reset status manager state
    StatusManager.reset()
end

themeManagerSuite.setup = function()
    -- Backup current theme
    TestData.originalTheme = ThemeManager.getTheme()
end

themeManagerSuite.teardown = function()
    -- Restore original theme and clean up test themes
    if TestData.originalTheme then
        ThemeManager.setTheme(TestData.originalTheme)
    end
    ThemeManager.unregisterTheme('test_theme')
end

print('[INFO] Module tests loaded successfully')

-- Export test data for use in other test files
_G.TestData = TestData