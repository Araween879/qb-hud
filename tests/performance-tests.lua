--[[
    File: performance-tests.lua
    Description: Performance benchmarks and stress tests for QBCore Advanced HUD System
    Author: QBCore Development Team
    Version: 3.2.0
    
    Comprehensive performance testing including:
    - Memory usage monitoring
    - Update frequency benchmarks
    - Component loading times
    - Animation performance
    - Database operation speed
    - NUI communication latency
]]

-- Import test framework
local Assert = TestRunner.Assert
local Utils = TestRunner.Utils
local Performance = TestRunner.Performance

-- Performance Testing Utilities
local PerformanceUtils = {
    -- Measure function execution time
    measureTime = function(func, iterations)
        iterations = iterations or 1
        local startTime = GetGameTimer()
        
        for i = 1, iterations do
            func()
        end
        
        local endTime = GetGameTimer()
        return {
            totalTime = endTime - startTime,
            averageTime = (endTime - startTime) / iterations,
            iterations = iterations
        }
    end,
    
    -- Measure memory usage before and after function
    measureMemory = function(func)
        collectgarbage('collect')
        local startMemory = collectgarbage('count')
        
        func()
        
        local endMemory = collectgarbage('count')
        return {
            startMemory = startMemory,
            endMemory = endMemory,
            memoryDelta = endMemory - startMemory
        }
    end,
    
    -- Generate test data of specified size
    generateTestData = function(size)
        local data = {}
        for i = 1, size do
            data[i] = {
                id = i,
                name = 'test_item_' .. i,
                value = math.random(1, 100),
                nested = {
                    property1 = 'value' .. i,
                    property2 = math.random(1, 1000)
                }
            }
        end
        return data
    end,
    
    -- Create performance report
    createReport = function(testName, metrics)
        return {
            testName = testName,
            timestamp = os.date('%Y-%m-%d %H:%M:%S'),
            metrics = metrics,
            system = {
                memoryUsage = collectgarbage('count'),
                gameTimer = GetGameTimer()
            }
        }
    end,
    
    -- Performance thresholds for pass/fail
    thresholds = {
        componentUpdate = 5,        -- 5ms max for component update
        componentLoad = 50,         -- 50ms max for component loading
        themeSwitch = 100,          -- 100ms max for theme switching
        databaseQuery = 200,        -- 200ms max for database operations
        memoryLeak = 1024,          -- 1MB max memory increase per test
        animationFrame = 16.67      -- 60 FPS = 16.67ms per frame
    }
}

-- Performance Monitoring Class
local PerformanceMonitor = {
    metrics = {},
    isRecording = false,
    
    start = function(testName)
        PerformanceMonitor.isRecording = true
        PerformanceMonitor.metrics[testName] = {
            startTime = GetGameTimer(),
            startMemory = collectgarbage('count'),
            samples = {}
        }
    end,
    
    sample = function(testName, label, value)
        if not PerformanceMonitor.isRecording then return end
        
        local metric = PerformanceMonitor.metrics[testName]
        if not metric then return end
        
        table.insert(metric.samples, {
            label = label,
            value = value,
            timestamp = GetGameTimer()
        })
    end,
    
    stop = function(testName)
        if not PerformanceMonitor.isRecording then return nil end
        
        local metric = PerformanceMonitor.metrics[testName]
        if not metric then return nil end
        
        metric.endTime = GetGameTimer()
        metric.endMemory = collectgarbage('count')
        metric.duration = metric.endTime - metric.startTime
        metric.memoryDelta = metric.endMemory - metric.startMemory
        
        PerformanceMonitor.isRecording = false
        return metric
    end,
    
    getReport = function(testName)
        return PerformanceMonitor.metrics[testName]
    end,
    
    clear = function()
        PerformanceMonitor.metrics = {}
        PerformanceMonitor.isRecording = false
    end
}

-- ========================================
-- Component Performance Tests
-- ========================================

local componentPerformanceSuite = TestRunner.createSuite('ComponentPerformance', 'Performance tests for HUD components')

TestRunner.addTest('ComponentPerformance', 'should_update_components_efficiently', function()
    local testData = {
        health = 85,
        armor = 100,
        hunger = 67,
        thirst = 45
    }
    
    -- Register test component
    local updateCount = 0
    local testComponent = {
        name = 'PerfTestComponent',
        element = '#perf-test',
        visible = true,
        show = function() end,
        hide = function() end,
        update = function(self, data)
            updateCount = updateCount + 1
        end
    }
    
    ComponentManager.register('PerfTestComponent', testComponent)
    
    -- Measure update performance
    local metrics = PerformanceUtils.measureTime(function()
        ComponentManager.updateComponent('PerfTestComponent', testData)
    end, 1000)
    
    -- Performance assertions
    Assert.isLessThan(metrics.averageTime, PerformanceUtils.thresholds.componentUpdate, 
        'Component updates should be fast enough')
    Assert.equal(updateCount, 1000, 'All updates should be processed')
    
    ComponentManager.unregister('PerfTestComponent')
end, 'Component updates should be performant')

TestRunner.addTest('ComponentPerformance', 'should_handle_mass_component_registration', function()
    local componentCount = 100
    
    -- Measure registration performance
    local metrics = PerformanceUtils.measureTime(function()
        for i = 1, componentCount do
            local component = {
                name = 'MassComponent' .. i,
                element = '#mass-' .. i,
                visible = true,
                show = function() end,
                hide = function() end,
                update = function() end
            }
            ComponentManager.register('MassComponent' .. i, component)
        end
    end)
    
    Assert.isLessThan(metrics.totalTime, 1000, 'Mass registration should complete quickly')
    
    -- Verify all components registered
    for i = 1, componentCount do
        Assert.isNotNil(ComponentManager.get('MassComponent' .. i), 'Component should be registered')
    end
    
    -- Cleanup
    for i = 1, componentCount do
        ComponentManager.unregister('MassComponent' .. i)
    end
end, 'Mass component registration should be efficient')

TestRunner.addTest('ComponentPerformance', 'should_handle_rapid_visibility_changes', function()
    local component = {
        name = 'VisibilityPerfTest',
        element = '#visibility-perf',
        visible = true,
        showCount = 0,
        hideCount = 0,
        show = function(self) self.showCount = self.showCount + 1 end,
        hide = function(self) self.hideCount = self.hideCount + 1 end,
        update = function() end
    }
    
    ComponentManager.register('VisibilityPerfTest', component)
    
    -- Measure rapid show/hide performance
    local metrics = PerformanceUtils.measureTime(function()
        for i = 1, 500 do
            ComponentManager.hide('VisibilityPerfTest')
            ComponentManager.show('VisibilityPerfTest')
        end
    end)
    
    Assert.isLessThan(metrics.totalTime, 500, 'Rapid visibility changes should be fast')
    
    local registeredComponent = ComponentManager.get('VisibilityPerfTest')
    Assert.equal(registeredComponent.showCount, 500, 'All show calls should be processed')
    Assert.equal(registeredComponent.hideCount, 500, 'All hide calls should be processed')
    
    ComponentManager.unregister('VisibilityPerfTest')
end, 'Rapid visibility changes should be performant')

-- ========================================
-- Theme Performance Tests
-- ========================================

local themePerformanceSuite = TestRunner.createSuite('ThemePerformance', 'Performance tests for theme system')

TestRunner.addTest('ThemePerformance', 'should_switch_themes_quickly', function()
    -- Register test themes
    local themes = {}
    for i = 1, 5 do
        themes[i] = {
            name = 'perf_theme_' .. i,
            displayName = 'Performance Theme ' .. i,
            colors = {
                primary = '#' .. string.format('%06x', math.random(0, 0xFFFFFF)),
                secondary = '#' .. string.format('%06x', math.random(0, 0xFFFFFF)),
                background = 'rgba(0, 0, 0, 0.8)'
            },
            animations = {
                enabled = true,
                fadeTime = 300
            }
        }
        ThemeManager.registerTheme(themes[i])
    end
    
    -- Measure theme switching performance
    local metrics = PerformanceUtils.measureTime(function()
        for i = 1, 5 do
            ThemeManager.setTheme('perf_theme_' .. i)
        end
    end)
    
    Assert.isLessThan(metrics.averageTime, PerformanceUtils.thresholds.themeSwitch, 
        'Theme switching should be fast enough')
    
    -- Cleanup
    for i = 1, 5 do
        ThemeManager.unregisterTheme('perf_theme_' .. i)
    end
end, 'Theme switching should be performant')

TestRunner.addTest('ThemePerformance', 'should_load_complex_themes_efficiently', function()
    local complexTheme = {
        name = 'complex_perf_theme',
        displayName = 'Complex Performance Theme',
        colors = {
            primary = '#00ffff',
            secondary = '#a020f0',
            background = 'rgba(0, 0, 0, 0.9)',
            text = {
                primary = '#ffffff',
                secondary = '#e0e0e0',
                muted = '#888888'
            },
            status = {
                success = '#28a745',
                warning = '#ffc107',
                danger = '#dc3545'
            }
        },
        animations = {
            enabled = true,
            fadeTime = 300,
            slideTime = 250,
            scaleTime = 200
        },
        effects = {
            glow = true,
            shadows = true,
            gradients = true
        },
        components = {}
    }
    
    -- Add complex component styles
    for i = 1, 50 do
        complexTheme.components['Component' .. i] = {
            backgroundColor = '#' .. string.format('%06x', math.random(0, 0xFFFFFF)),
            borderColor = '#' .. string.format('%06x', math.random(0, 0xFFFFFF)),
            fontSize = math.random(12, 24) .. 'px',
            padding = math.random(5, 15) .. 'px'
        }
    end
    
    -- Measure complex theme registration
    local metrics = PerformanceUtils.measureTime(function()
        ThemeManager.registerTheme(complexTheme)
    end)
    
    Assert.isLessThan(metrics.totalTime, 200, 'Complex theme loading should be reasonable')
    
    ThemeManager.unregisterTheme('complex_perf_theme')
end, 'Complex themes should load efficiently')

-- ========================================
-- Memory Performance Tests
-- ========================================

local memoryPerformanceSuite = TestRunner.createSuite('MemoryPerformance', 'Memory usage and leak tests')

TestRunner.addTest('MemoryPerformance', 'should_not_leak_memory_on_component_updates', function()
    local component = {
        name = 'MemoryTestComponent',
        element = '#memory-test',
        visible = true,
        show = function() end,
        hide = function() end,
        update = function() end
    }
    
    ComponentManager.register('MemoryTestComponent', component)
    
    -- Measure memory usage during updates
    local memoryMetrics = PerformanceUtils.measureMemory(function()
        for i = 1, 1000 do
            ComponentManager.updateComponent('MemoryTestComponent', {
                data = 'test_data_' .. i,
                timestamp = GetGameTimer(),
                randomValue = math.random(1, 100)
            })
        end
        collectgarbage('collect') -- Force garbage collection
    end)
    
    Assert.isLessThan(memoryMetrics.memoryDelta, PerformanceUtils.thresholds.memoryLeak,
        'Memory usage should not increase significantly')
    
    ComponentManager.unregister('MemoryTestComponent')
end, 'Component updates should not leak memory')

TestRunner.addTest('MemoryPerformance', 'should_cleanup_resources_on_shutdown', function()
    -- Register multiple components
    for i = 1, 20 do
        local component = {
            name = 'CleanupTest' .. i,
            element = '#cleanup-' .. i,
            visible = true,
            data = PerformanceUtils.generateTestData(100), -- Add some data
            show = function() end,
            hide = function() end,
            update = function() end
        }
        ComponentManager.register('CleanupTest' .. i, component)
    end
    
    local startMemory = collectgarbage('count')
    
    -- Shutdown and cleanup
    HudManager.shutdown()
    collectgarbage('collect')
    
    local endMemory = collectgarbage('count')
    local memoryReduction = startMemory - endMemory
    
    -- Memory should be freed (or at least not increased significantly)
    Assert.isGreaterThan(memoryReduction, -500, 'Memory should be cleaned up properly')
    
    -- Reinitialize for other tests
    HudManager.initialize()
end, 'System shutdown should cleanup memory')

TestRunner.addTest('MemoryPerformance', 'should_handle_large_data_efficiently', function()
    local largeData = PerformanceUtils.generateTestData(1000)
    
    local component = {
        name = 'LargeDataComponent',
        element = '#large-data',
        visible = true,
        processedData = nil,
        show = function() end,
        hide = function() end,
        update = function(self, data)
            self.processedData = data
        end
    }
    
    ComponentManager.register('LargeDataComponent', component)
    
    -- Measure memory and time for large data processing
    local memoryMetrics = PerformanceUtils.measureMemory(function()
        ComponentManager.updateComponent('LargeDataComponent', largeData)
    end)
    
    Assert.isLessThan(memoryMetrics.memoryDelta, 5000, 'Large data processing should be memory efficient')
    
    ComponentManager.unregister('LargeDataComponent')
end, 'Large data processing should be memory efficient')

-- ========================================
-- Animation Performance Tests
-- ========================================

local animationPerformanceSuite = TestRunner.createSuite('AnimationPerformance', 'Animation system performance tests')

TestRunner.addTest('AnimationPerformance', 'should_maintain_smooth_animations', function()
    local frameCount = 0
    local frameDrops = 0
    local lastFrameTime = GetGameTimer()
    
    -- Simulate animation frames
    local animationTime = 1000 -- 1 second
    local startTime = GetGameTimer()
    
    while GetGameTimer() - startTime < animationTime do
        local currentTime = GetGameTimer()
        local frameTime = currentTime - lastFrameTime
        
        if frameTime > PerformanceUtils.thresholds.animationFrame * 1.5 then
            frameDrops = frameDrops + 1
        end
        
        frameCount = frameCount + 1
        lastFrameTime = currentTime
        
        -- Simulate animation work
        AnimationManager.processFrame()
        
        Citizen.Wait(0) -- Yield to next frame
    end
    
    local fps = frameCount / (animationTime / 1000)
    local dropRate = frameDrops / frameCount
    
    Assert.isGreaterThan(fps, 30, 'Should maintain reasonable FPS during animations')
    Assert.isLessThan(dropRate, 0.1, 'Frame drop rate should be acceptable')
end, 'Animations should maintain smooth frame rate')

TestRunner.addTest('AnimationPerformance', 'should_handle_multiple_simultaneous_animations', function()
    local animationCount = 10
    local animations = {}
    
    -- Create multiple animations
    for i = 1, animationCount do
        animations[i] = {
            id = 'perf_anim_' .. i,
            duration = 500,
            startTime = GetGameTimer(),
            property = 'opacity',
            from = 0,
            to = 1
        }
        AnimationManager.startAnimation(animations[i])
    end
    
    local startTime = GetGameTimer()
    
    -- Let animations run
    while GetGameTimer() - startTime < 600 do
        AnimationManager.update()
        Citizen.Wait(0)
    end
    
    local processingTime = GetGameTimer() - startTime
    
    Assert.isLessThan(processingTime, 700, 'Multiple animations should process efficiently')
    
    -- Cleanup
    for i = 1, animationCount do
        AnimationManager.stopAnimation('perf_anim_' .. i)
    end
end, 'Multiple simultaneous animations should be performant')

-- ========================================
-- Database Performance Tests
-- ========================================

local databasePerformanceSuite = TestRunner.createSuite('DatabasePerformance', 'Database operation performance tests')

TestRunner.addTest('DatabasePerformance', 'should_execute_queries_efficiently', function()
    local queryCount = 100
    local completedQueries = 0
    
    -- Mock fast database
    local originalQuery = MySQL.query
    MySQL.query = function(query, params, callback)
        -- Simulate database processing time
        Citizen.SetTimeout(math.random(1, 5), function()
            completedQueries = completedQueries + 1
            if callback then callback(true) end
        end)
    end
    
    local startTime = GetGameTimer()
    
    -- Execute multiple queries
    for i = 1, queryCount do
        Database.savePlayerSettings('perf_test_' .. i, {
            theme = 'test',
            setting = i
        })
    end
    
    -- Wait for completion
    while completedQueries < queryCount and GetGameTimer() - startTime < 5000 do
        Citizen.Wait(10)
    end
    
    local processingTime = GetGameTimer() - startTime
    
    Assert.equal(completedQueries, queryCount, 'All queries should complete')
    Assert.isLessThan(processingTime, 1000, 'Database queries should complete quickly')
    
    MySQL.query = originalQuery
end, 'Database queries should be performant')

TestRunner.addTest('DatabasePerformance', 'should_handle_large_data_saves', function()
    local largeSettings = {
        theme = 'test_theme',
        customization = PerformanceUtils.generateTestData(500),
        preferences = {
            animations = true,
            sounds = false,
            notifications = true
        }
    }
    
    local startTime = GetGameTimer()
    local completed = false
    
    -- Mock database with realistic delay for large data
    local originalQuery = MySQL.query
    MySQL.query = function(query, params, callback)
        Citizen.SetTimeout(50, function() -- 50ms delay
            completed = true
            if callback then callback(true) end
        end)
    end
    
    Database.savePlayerSettings('large_data_test', largeSettings)
    
    -- Wait for completion
    while not completed and GetGameTimer() - startTime < 1000 do
        Citizen.Wait(10)
    end
    
    local processingTime = GetGameTimer() - startTime
    
    Assert.isTrue(completed, 'Large data save should complete')
    Assert.isLessThan(processingTime, PerformanceUtils.thresholds.databaseQuery, 
        'Large data saves should complete within threshold')
    
    MySQL.query = originalQuery
end, 'Large data saves should be performant')

-- ========================================
-- NUI Performance Tests
-- ========================================

local nuiPerformanceSuite = TestRunner.createSuite('NUIPerformance', 'NUI communication performance tests')

TestRunner.addTest('NUIPerformance', 'should_send_messages_efficiently', function()
    local messageCount = 1000
    local messagesSent = 0
    
    -- Mock SendNUIMessage
    local originalSendNUI = SendNUIMessage
    SendNUIMessage = function(data)
        messagesSent = messagesSent + 1
    end
    
    local metrics = PerformanceUtils.measureTime(function()
        for i = 1, messageCount do
            NUIManager.updateStatus({
                health = math.random(0, 100),
                armor = math.random(0, 100),
                iteration = i
            })
        end
    end)
    
    Assert.equal(messagesSent, messageCount, 'All NUI messages should be sent')
    Assert.isLessThan(metrics.totalTime, 500, 'NUI messages should be sent quickly')
    
    SendNUIMessage = originalSendNUI
end, 'NUI message sending should be performant')

TestRunner.addTest('NUIPerformance', 'should_handle_rapid_callbacks', function()
    local callbackCount = 100
    local callbacksReceived = 0
    
    -- Register callback handler
    RegisterNUICallback('perf_test_callback', function(data, cb)
        callbacksReceived = callbacksReceived + 1
        cb('ok')
    end)
    
    local startTime = GetGameTimer()
    
    -- Simulate rapid callbacks
    for i = 1, callbackCount do
        TriggerEvent('__cfx_nui:perf_test_callback', { index = i }, function() end)
    end
    
    -- Wait for callbacks to process
    while callbacksReceived < callbackCount and GetGameTimer() - startTime < 2000 do
        Citizen.Wait(1)
    end
    
    local processingTime = GetGameTimer() - startTime
    
    Assert.equal(callbacksReceived, callbackCount, 'All callbacks should be processed')
    Assert.isLessThan(processingTime, 1000, 'Callbacks should process quickly')
end, 'Rapid NUI callbacks should be handled efficiently')

-- ========================================
-- Stress Tests
-- ========================================

local stressTestSuite = TestRunner.createSuite('StressTests', 'System stress and load tests')

TestRunner.addTest('StressTests', 'should_survive_extreme_load', function()
    local operations = 0
    local errors = 0
    local startTime = GetGameTimer()
    local testDuration = 5000 -- 5 seconds
    
    -- Create multiple components
    for i = 1, 10 do
        local component = {
            name = 'StressComponent' .. i,
            element = '#stress-' .. i,
            visible = true,
            show = function() end,
            hide = function() end,
            update = function() end
        }
        ComponentManager.register('StressComponent' .. i, component)
    end
    
    -- Apply extreme load
    while GetGameTimer() - startTime < testDuration do
        for i = 1, 10 do
            local success, error = pcall(function()
                ComponentManager.updateComponent('StressComponent' .. i, {
                    value = math.random(1, 100),
                    timestamp = GetGameTimer()
                })
                ComponentManager.toggle('StressComponent' .. i)
                operations = operations + 2
            end)
            
            if not success then
                errors = errors + 1
            end
        end
        
        Citizen.Wait(0)
    end
    
    local errorRate = errors / operations
    
    Assert.isLessThan(errorRate, 0.01, 'Error rate should be very low under stress')
    Assert.isGreaterThan(operations, 1000, 'Should complete many operations under stress')
    
    -- Cleanup
    for i = 1, 10 do
        ComponentManager.unregister('StressComponent' .. i)
    end
end, 'System should survive extreme load conditions')

TestRunner.addTest('StressTests', 'should_recover_from_errors', function()
    local component = {
        name = 'ErrorRecoveryComponent',
        element = '#error-recovery',
        visible = true,
        errorCount = 0,
        show = function() end,
        hide = function() end,
        update = function(self, data)
            if data and data.causeError then
                self.errorCount = self.errorCount + 1
                error('Intentional test error')
            end
        end
    }
    
    ComponentManager.register('ErrorRecoveryComponent', component)
    
    local successfulUpdates = 0
    local errors = 0
    
    -- Mix successful updates with error-causing ones
    for i = 1, 100 do
        local success, error = pcall(function()
            if i % 10 == 0 then
                ComponentManager.updateComponent('ErrorRecoveryComponent', { causeError = true })
            else
                ComponentManager.updateComponent('ErrorRecoveryComponent', { value = i })
                successfulUpdates = successfulUpdates + 1
            end
        end)
        
        if not success then
            errors = errors + 1
        end
    end
    
    Assert.equal(errors, 10, 'Should have correct number of intentional errors')
    Assert.equal(successfulUpdates, 90, 'Should complete all non-error updates')
    
    -- System should still be functional
    Assert.isTrue(ComponentManager.isInitialized(), 'System should remain initialized')
    Assert.isNotNil(ComponentManager.get('ErrorRecoveryComponent'), 'Component should still exist')
    
    ComponentManager.unregister('ErrorRecoveryComponent')
end, 'System should recover gracefully from errors')

-- ========================================
-- Benchmark Reporting
-- ========================================

local benchmarkSuite = TestRunner.createSuite('Benchmarks', 'Performance benchmarks and reporting')

TestRunner.addTest('Benchmarks', 'should_generate_performance_report', function()
    local benchmarks = {}
    
    -- Component update benchmark
    benchmarks.componentUpdate = PerformanceUtils.measureTime(function()
        local component = {
            name = 'BenchmarkComponent',
            element = '#benchmark',
            visible = true,
            show = function() end,
            hide = function() end,
            update = function() end
        }
        ComponentManager.register('BenchmarkComponent', component)
        ComponentManager.updateComponent('BenchmarkComponent', { test = true })
        ComponentManager.unregister('BenchmarkComponent')
    end, 100)
    
    -- Theme switch benchmark
    local testTheme = {
        name = 'benchmark_theme',
        displayName = 'Benchmark Theme',
        colors = { primary = '#00ffff', background = 'rgba(0,0,0,0.8)' }
    }
    ThemeManager.registerTheme(testTheme)
    
    benchmarks.themeSwitch = PerformanceUtils.measureTime(function()
        ThemeManager.setTheme('benchmark_theme')
    end, 10)
    
    ThemeManager.unregisterTheme('benchmark_theme')
    
    -- Memory usage benchmark
    benchmarks.memoryUsage = {
        currentUsage = collectgarbage('count'),
        peakUsage = collectgarbage('count') -- Simplified for test
    }
    
    -- Create performance report
    local report = PerformanceUtils.createReport('HUD_System_Benchmark', benchmarks)
    
    Assert.isNotNil(report, 'Should generate performance report')
    Assert.isNotNil(report.metrics.componentUpdate, 'Should include component update metrics')
    Assert.isNotNil(report.metrics.themeSwitch, 'Should include theme switch metrics')
    Assert.isNotNil(report.metrics.memoryUsage, 'Should include memory usage metrics')
    
    -- Log report for manual review
    print('\n=== PERFORMANCE BENCHMARK REPORT ===')
    print('Component Update: ' .. string.format('%.2fms avg (%d iterations)', 
          benchmarks.componentUpdate.averageTime, benchmarks.componentUpdate.iterations))
    print('Theme Switch: ' .. string.format('%.2fms avg (%d iterations)', 
          benchmarks.themeSwitch.averageTime, benchmarks.themeSwitch.iterations))
    print('Memory Usage: ' .. string.format('%.2f KB', benchmarks.memoryUsage.currentUsage))
    print('=====================================\n')
end, 'Performance benchmarks should be measurable')

-- ========================================
-- Test Setup and Configuration
-- ========================================

-- Performance test configuration
local perfConfig = {
    enableDetailedLogging = true,
    benchmarkIterations = 100,
    stressTestDuration = 5000,
    memoryThreshold = 1024,
    timeThreshold = 100
}

-- Setup for performance tests
componentPerformanceSuite.setup = function()
    -- Ensure clean state
    PerformanceMonitor.clear()
    collectgarbage('collect')
    
    -- Initialize system if needed
    if not HudManager.isInitialized() then
        HudManager.initialize()
    end
end

componentPerformanceSuite.teardown = function()
    -- Cleanup test components
    collectgarbage('collect')
end

themePerformanceSuite.setup = function()
    PerformanceMonitor.clear()
end

memoryPerformanceSuite.setup = function()
    collectgarbage('collect') -- Start with clean memory state
end

memoryPerformanceSuite.afterEach = function()
    collectgarbage('collect') -- Clean up after each test
end

-- Performance test commands
RegisterCommand('hud_perf_test', function(source, args)
    local testType = args[1] or 'all'
    
    if testType == 'all' then
        TestRunner.runAllTests()
    elseif testType == 'component' then
        TestRunner.runTestSuite('ComponentPerformance')
    elseif testType == 'memory' then
        TestRunner.runTestSuite('MemoryPerformance')
    elseif testType == 'stress' then
        TestRunner.runTestSuite('StressTests')
    elseif testType == 'benchmark' then
        TestRunner.runTestSuite('Benchmarks')
    else
        print('Available performance test types: all, component, memory, stress, benchmark')
    end
end, false)

RegisterCommand('hud_perf_monitor', function(source, args)
    local duration = tonumber(args[1]) or 10000 -- 10 seconds default
    
    print('Starting performance monitoring for ' .. duration .. 'ms...')
    
    PerformanceMonitor.start('live_monitoring')
    
    Citizen.SetTimeout(duration, function()
        local report = PerformanceMonitor.stop('live_monitoring')
        
        print('\n=== LIVE PERFORMANCE MONITORING ===')
        print('Duration: ' .. report.duration .. 'ms')
        print('Memory Delta: ' .. string.format('%.2f KB', report.memoryDelta))
        print('Samples: ' .. #report.samples)
        print('===================================\n')
    end)
end, false)

print('[INFO] Performance tests loaded successfully')

-- Export performance utilities for external use
_G.PerformanceUtils = PerformanceUtils
_G.PerformanceMonitor = PerformanceMonitor