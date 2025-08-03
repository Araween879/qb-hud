--[[
    File: test-runner.lua
    Description: Comprehensive test runner for QBCore Advanced HUD System
    Author: QBCore Development Team
    Version: 3.2.0
    
    Usage:
    - Load this file in your test environment
    - Call TestRunner.runAllTests() to execute all tests
    - Call TestRunner.runTestSuite(suiteName) for specific test suites
    - Use TestRunner.runSingleTest(testName) for individual tests
]]

-- Test Runner Framework
local TestRunner = {
    version = '3.2.0',
    suites = {},
    results = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {}
    },
    config = {
        verbose = true,
        stopOnError = false,
        timeout = 5000,
        enablePerformance = true
    },
    isRunning = false,
    startTime = 0
}

-- Color codes for console output
local Colors = {
    GREEN = '^2',
    RED = '^1', 
    YELLOW = '^3',
    BLUE = '^4',
    CYAN = '^6',
    WHITE = '^7',
    RESET = '^0'
}

-- Utility Functions
local Utils = {
    -- Deep copy table
    deepCopy = function(original)
        local copy = {}
        for k, v in pairs(original) do
            if type(v) == 'table' then
                copy[k] = Utils.deepCopy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end,
    
    -- Format time in milliseconds
    formatTime = function(ms)
        if ms < 1000 then
            return string.format('%.2fms', ms)
        else
            return string.format('%.2fs', ms / 1000)
        end
    end,
    
    -- Check if value is approximately equal (for floating point comparisons)
    isApproxEqual = function(a, b, tolerance)
        tolerance = tolerance or 0.001
        return math.abs(a - b) <= tolerance
    end,
    
    -- Generate test data
    generateTestData = function(dataType)
        if dataType == 'playerStatus' then
            return {
                health = math.random(0, 100),
                armor = math.random(0, 100),
                hunger = math.random(0, 100),
                thirst = math.random(0, 100),
                stress = math.random(0, 100),
                stamina = math.random(0, 100)
            }
        elseif dataType == 'vehicleData' then
            return {
                speed = math.random(0, 200),
                fuel = math.random(0, 100),
                engine = math.random(0, 1000),
                gear = math.random(1, 6),
                rpm = math.random(0, 8000)
            }
        end
        return {}
    end
}

-- Assertion Framework
local Assert = {
    -- Basic equality assertion
    equal = function(actual, expected, message)
        message = message or string.format('Expected %s to equal %s', tostring(actual), tostring(expected))
        if actual ~= expected then
            error(message, 2)
        end
        return true
    end,
    
    -- Inequality assertion
    notEqual = function(actual, expected, message)
        message = message or string.format('Expected %s to not equal %s', tostring(actual), tostring(expected))
        if actual == expected then
            error(message, 2)
        end
        return true
    end,
    
    -- Truth assertion
    isTrue = function(value, message)
        message = message or string.format('Expected %s to be true', tostring(value))
        if value ~= true then
            error(message, 2)
        end
        return true
    end,
    
    -- Falsy assertion
    isFalse = function(value, message)
        message = message or string.format('Expected %s to be false', tostring(value))
        if value ~= false then
            error(message, 2)
        end
        return true
    end,
    
    -- Nil assertion
    isNil = function(value, message)
        message = message or string.format('Expected %s to be nil', tostring(value))
        if value ~= nil then
            error(message, 2)
        end
        return true
    end,
    
    -- Not nil assertion
    isNotNil = function(value, message)
        message = message or string.format('Expected %s to not be nil', tostring(value))
        if value == nil then
            error(message, 2)
        end
        return true
    end,
    
    -- Type assertion
    isType = function(value, expectedType, message)
        local actualType = type(value)
        message = message or string.format('Expected %s to be of type %s, got %s', tostring(value), expectedType, actualType)
        if actualType ~= expectedType then
            error(message, 2)
        end
        return true
    end,
    
    -- Approximate equality for numbers
    isApproxEqual = function(actual, expected, tolerance, message)
        tolerance = tolerance or 0.001
        message = message or string.format('Expected %s to approximately equal %s (tolerance: %s)', tostring(actual), tostring(expected), tostring(tolerance))
        if not Utils.isApproxEqual(actual, expected, tolerance) then
            error(message, 2)
        end
        return true
    end,
    
    -- Greater than assertion
    isGreaterThan = function(actual, expected, message)
        message = message or string.format('Expected %s to be greater than %s', tostring(actual), tostring(expected))
        if actual <= expected then
            error(message, 2)
        end
        return true
    end,
    
    -- Less than assertion
    isLessThan = function(actual, expected, message)
        message = message or string.format('Expected %s to be less than %s', tostring(actual), tostring(expected))
        if actual >= expected then
            error(message, 2)
        end
        return true
    end,
    
    -- Contains assertion for tables/strings
    contains = function(container, item, message)
        message = message or string.format('Expected container to contain %s', tostring(item))
        
        if type(container) == 'table' then
            for _, v in pairs(container) do
                if v == item then
                    return true
                end
            end
            error(message, 2)
        elseif type(container) == 'string' then
            if not string.find(container, item, 1, true) then
                error(message, 2)
            end
        else
            error('Container must be table or string', 2)
        end
        return true
    end,
    
    -- Error assertion
    throws = function(func, expectedError, message)
        local success, error = pcall(func)
        if success then
            error(message or 'Expected function to throw an error', 2)
        end
        if expectedError and not string.find(error, expectedError) then
            error(string.format('Expected error containing "%s", got "%s"', expectedError, error), 2)
        end
        return true
    end,
    
    -- No error assertion
    doesNotThrow = function(func, message)
        local success, error = pcall(func)
        if not success then
            error(message or string.format('Expected function not to throw, but got: %s', error), 2)
        end
        return true
    end
}

-- Performance Monitoring
local Performance = {
    measurements = {},
    
    start = function(name)
        if not TestRunner.config.enablePerformance then return end
        Performance.measurements[name] = GetGameTimer()
    end,
    
    stop = function(name)
        if not TestRunner.config.enablePerformance then return 0 end
        local startTime = Performance.measurements[name]
        if not startTime then return 0 end
        
        local duration = GetGameTimer() - startTime
        Performance.measurements[name] = nil
        return duration
    end,
    
    measure = function(name, func)
        Performance.start(name)
        local result = func()
        local duration = Performance.stop(name)
        return result, duration
    end
}

-- Mock Framework for Testing
local Mock = {
    mocks = {},
    
    -- Create a mock function
    createFunction = function(returnValue)
        local callCount = 0
        local calls = {}
        
        local mockFunc = function(...)
            callCount = callCount + 1
            table.insert(calls, {...})
            return returnValue
        end
        
        mockFunc.getCallCount = function() return callCount end
        mockFunc.getCalls = function() return calls end
        mockFunc.reset = function() 
            callCount = 0 
            calls = {}
        end
        
        return mockFunc
    end,
    
    -- Mock a global function
    mockGlobal = function(name, mockFunc)
        if not Mock.mocks[name] then
            Mock.mocks[name] = _G[name]
        end
        _G[name] = mockFunc
    end,
    
    -- Restore all mocked globals
    restoreAll = function()
        for name, originalFunc in pairs(Mock.mocks) do
            _G[name] = originalFunc
        end
        Mock.mocks = {}
    end
}

-- Test Suite Management
function TestRunner.createSuite(name, description)
    if TestRunner.suites[name] then
        print(Colors.YELLOW .. '[WARN] Test suite "' .. name .. '" already exists, overwriting' .. Colors.RESET)
    end
    
    TestRunner.suites[name] = {
        name = name,
        description = description or '',
        tests = {},
        setup = nil,
        teardown = nil,
        beforeEach = nil,
        afterEach = nil
    }
    
    return TestRunner.suites[name]
end

function TestRunner.addTest(suiteName, testName, testFunc, description)
    local suite = TestRunner.suites[suiteName]
    if not suite then
        error('Test suite "' .. suiteName .. '" does not exist')
    end
    
    suite.tests[testName] = {
        name = testName,
        func = testFunc,
        description = description or '',
        skip = false,
        timeout = TestRunner.config.timeout
    }
end

function TestRunner.skipTest(suiteName, testName, reason)
    local suite = TestRunner.suites[suiteName]
    if suite and suite.tests[testName] then
        suite.tests[testName].skip = true
        suite.tests[testName].skipReason = reason or 'No reason provided'
    end
end

-- Test Execution
function TestRunner.runSingleTest(suiteName, testName)
    local suite = TestRunner.suites[suiteName]
    if not suite then
        print(Colors.RED .. '[ERROR] Test suite "' .. suiteName .. '" not found' .. Colors.RESET)
        return false
    end
    
    local test = suite.tests[testName]
    if not test then
        print(Colors.RED .. '[ERROR] Test "' .. testName .. '" not found in suite "' .. suiteName .. '"' .. Colors.RESET)
        return false
    end
    
    return TestRunner._executeTest(suite, test)
end

function TestRunner.runTestSuite(suiteName)
    local suite = TestRunner.suites[suiteName]
    if not suite then
        print(Colors.RED .. '[ERROR] Test suite "' .. suiteName .. '" not found' .. Colors.RESET)
        return false
    end
    
    print(Colors.CYAN .. '\n=== Running Test Suite: ' .. suiteName .. ' ===' .. Colors.RESET)
    if suite.description ~= '' then
        print(Colors.WHITE .. suite.description .. Colors.RESET)
    end
    
    -- Run setup
    if suite.setup then
        TestRunner._runWithTimeout('Setup', suite.setup, TestRunner.config.timeout)
    end
    
    local suiteResults = { passed = 0, failed = 0, skipped = 0 }
    
    -- Run tests
    for testName, test in pairs(suite.tests) do
        local success = TestRunner._executeTest(suite, test)
        if test.skip then
            suiteResults.skipped = suiteResults.skipped + 1
        elseif success then
            suiteResults.passed = suiteResults.passed + 1
        else
            suiteResults.failed = suiteResults.failed + 1
        end
    end
    
    -- Run teardown
    if suite.teardown then
        TestRunner._runWithTimeout('Teardown', suite.teardown, TestRunner.config.timeout)
    end
    
    -- Print suite results
    print(Colors.CYAN .. '\n--- Suite Results ---' .. Colors.RESET)
    print(Colors.GREEN .. 'Passed: ' .. suiteResults.passed .. Colors.RESET)
    print(Colors.RED .. 'Failed: ' .. suiteResults.failed .. Colors.RESET)
    print(Colors.YELLOW .. 'Skipped: ' .. suiteResults.skipped .. Colors.RESET)
    
    return suiteResults.failed == 0
end

function TestRunner._executeTest(suite, test)
    if test.skip then
        print(Colors.YELLOW .. '[SKIP] ' .. test.name .. ' - ' .. (test.skipReason or 'No reason') .. Colors.RESET)
        TestRunner.results.skipped = TestRunner.results.skipped + 1
        return true
    end
    
    TestRunner.results.total = TestRunner.results.total + 1
    
    local startTime = GetGameTimer()
    local success = false
    local errorMessage = ''
    
    -- Run beforeEach if it exists
    if suite.beforeEach then
        TestRunner._runWithTimeout('BeforeEach', suite.beforeEach, TestRunner.config.timeout)
    end
    
    -- Execute test with timeout and error handling
    success, errorMessage = pcall(function()
        TestRunner._runWithTimeout(test.name, test.func, test.timeout or TestRunner.config.timeout)
    end)
    
    -- Run afterEach if it exists
    if suite.afterEach then
        TestRunner._runWithTimeout('AfterEach', suite.afterEach, TestRunner.config.timeout)
    end
    
    local duration = GetGameTimer() - startTime
    
    -- Record results
    if success then
        TestRunner.results.passed = TestRunner.results.passed + 1
        if TestRunner.config.verbose then
            print(Colors.GREEN .. '[PASS] ' .. test.name .. ' (' .. Utils.formatTime(duration) .. ')' .. Colors.RESET)
        end
    else
        TestRunner.results.failed = TestRunner.results.failed + 1
        table.insert(TestRunner.results.errors, {
            suite = suite.name,
            test = test.name,
            error = errorMessage,
            duration = duration
        })
        
        print(Colors.RED .. '[FAIL] ' .. test.name .. ' (' .. Utils.formatTime(duration) .. ')' .. Colors.RESET)
        print(Colors.RED .. '       ' .. errorMessage .. Colors.RESET)
        
        if TestRunner.config.stopOnError then
            return false
        end
    end
    
    return success
end

function TestRunner._runWithTimeout(name, func, timeout)
    local startTime = GetGameTimer()
    
    -- Simple timeout implementation
    local timeoutThread = Citizen.CreateThread(function()
        Citizen.Wait(timeout)
        error('Test "' .. name .. '" timed out after ' .. timeout .. 'ms')
    end)
    
    local success, result = pcall(func)
    
    -- Cancel timeout thread (FiveM doesn't have direct thread cancellation, but this prevents the error)
    local currentTime = GetGameTimer()
    if currentTime - startTime < timeout then
        -- Test completed within timeout
    end
    
    if not success then
        error(result)
    end
    
    return result
end

-- Main Test Runner Functions
function TestRunner.runAllTests()
    if TestRunner.isRunning then
        print(Colors.YELLOW .. '[WARN] Tests are already running' .. Colors.RESET)
        return false
    end
    
    TestRunner.isRunning = true
    TestRunner.startTime = GetGameTimer()
    
    -- Reset results
    TestRunner.results = {
        total = 0,
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {}
    }
    
    print(Colors.BLUE .. '\n' .. string.rep('=', 60) .. Colors.RESET)
    print(Colors.BLUE .. '    QBCore Advanced HUD System - Test Runner v' .. TestRunner.version .. Colors.RESET)
    print(Colors.BLUE .. string.rep('=', 60) .. Colors.RESET)
    
    local allPassed = true
    
    -- Run all test suites
    for suiteName, suite in pairs(TestRunner.suites) do
        local suitePassed = TestRunner.runTestSuite(suiteName)
        allPassed = allPassed and suitePassed
    end
    
    TestRunner._printFinalResults()
    TestRunner.isRunning = false
    
    return allPassed
end

function TestRunner._printFinalResults()
    local totalTime = GetGameTimer() - TestRunner.startTime
    
    print(Colors.BLUE .. '\n' .. string.rep('=', 60) .. Colors.RESET)
    print(Colors.BLUE .. '                    FINAL TEST RESULTS' .. Colors.RESET)
    print(Colors.BLUE .. string.rep('=', 60) .. Colors.RESET)
    
    print(Colors.WHITE .. 'Total Tests: ' .. TestRunner.results.total .. Colors.RESET)
    print(Colors.GREEN .. 'Passed: ' .. TestRunner.results.passed .. Colors.RESET)
    print(Colors.RED .. 'Failed: ' .. TestRunner.results.failed .. Colors.RESET)
    print(Colors.YELLOW .. 'Skipped: ' .. TestRunner.results.skipped .. Colors.RESET)
    print(Colors.WHITE .. 'Total Time: ' .. Utils.formatTime(totalTime) .. Colors.RESET)
    
    if TestRunner.results.failed > 0 then
        print(Colors.RED .. '\nFAILED TESTS:' .. Colors.RESET)
        for _, error in ipairs(TestRunner.results.errors) do
            print(Colors.RED .. '  • ' .. error.suite .. '.' .. error.test .. Colors.RESET)
            print(Colors.RED .. '    ' .. error.error .. Colors.RESET)
        end
    end
    
    local successRate = TestRunner.results.total > 0 and (TestRunner.results.passed / TestRunner.results.total * 100) or 0
    print(Colors.WHITE .. '\nSuccess Rate: ' .. string.format('%.1f%%', successRate) .. Colors.RESET)
    
    if TestRunner.results.failed == 0 then
        print(Colors.GREEN .. '\n🎉 ALL TESTS PASSED! 🎉' .. Colors.RESET)
    else
        print(Colors.RED .. '\n❌ SOME TESTS FAILED ❌' .. Colors.RESET)
    end
    
    print(Colors.BLUE .. string.rep('=', 60) .. Colors.RESET)
end

-- Configuration Functions
function TestRunner.setConfig(config)
    for key, value in pairs(config) do
        if TestRunner.config[key] ~= nil then
            TestRunner.config[key] = value
        end
    end
end

function TestRunner.getResults()
    return Utils.deepCopy(TestRunner.results)
end

-- Utility Commands for In-Game Testing
RegisterCommand('hud_test_all', function()
    TestRunner.runAllTests()
end, false)

RegisterCommand('hud_test_suite', function(source, args)
    local suiteName = args[1]
    if not suiteName then
        print(Colors.RED .. '[ERROR] Please specify a test suite name' .. Colors.RESET)
        return
    end
    
    TestRunner.runTestSuite(suiteName)
end, false)

RegisterCommand('hud_test_single', function(source, args)
    local suiteName = args[1]
    local testName = args[2]
    
    if not suiteName or not testName then
        print(Colors.RED .. '[ERROR] Please specify both suite name and test name' .. Colors.RESET)
        return
    end
    
    TestRunner.runSingleTest(suiteName, testName)
end, false)

RegisterCommand('hud_test_config', function(source, args)
    local setting = args[1]
    local value = args[2]
    
    if not setting then
        print(Colors.BLUE .. 'Current Test Configuration:' .. Colors.RESET)
        for k, v in pairs(TestRunner.config) do
            print(Colors.WHITE .. '  ' .. k .. ': ' .. tostring(v) .. Colors.RESET)
        end
        return
    end
    
    if TestRunner.config[setting] ~= nil then
        if value == 'true' then
            TestRunner.config[setting] = true
        elseif value == 'false' then
            TestRunner.config[setting] = false
        elseif tonumber(value) then
            TestRunner.config[setting] = tonumber(value)
        else
            TestRunner.config[setting] = value
        end
        print(Colors.GREEN .. 'Set ' .. setting .. ' to ' .. tostring(TestRunner.config[setting]) .. Colors.RESET)
    else
        print(Colors.RED .. '[ERROR] Unknown configuration setting: ' .. setting .. Colors.RESET)
    end
end, false)

-- Export the test framework
TestRunner.Assert = Assert
TestRunner.Utils = Utils
TestRunner.Performance = Performance
TestRunner.Mock = Mock

-- Load test modules
if GetResourceState('qb-advanced-hud') == 'started' then
    -- Load module tests
    local moduleTestsFile = LoadResourceFile('qb-advanced-hud', 'tests/module-tests.lua')
    if moduleTestsFile then
        local chunk = load(moduleTestsFile)
        if chunk then
            chunk()
        end
    end
    
    -- Load integration tests
    local integrationTestsFile = LoadResourceFile('qb-advanced-hud', 'tests/integration-tests.lua')
    if integrationTestsFile then
        local chunk = load(integrationTestsFile)
        if chunk then
            chunk()
        end
    end
    
    -- Load performance tests
    local performanceTestsFile = LoadResourceFile('qb-advanced-hud', 'tests/performance-tests.lua')
    if performanceTestsFile then
        local chunk = load(performanceTestsFile)
        if chunk then
            chunk()
        end
    end
end

-- Initialize test runner
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait for other resources to load
    
    print(Colors.GREEN .. '[INFO] HUD Test Runner initialized' .. Colors.RESET)
    print(Colors.WHITE .. 'Available commands:' .. Colors.RESET)
    print(Colors.WHITE .. '  /hud_test_all - Run all tests' .. Colors.RESET)
    print(Colors.WHITE .. '  /hud_test_suite <suite> - Run specific test suite' .. Colors.RESET)
    print(Colors.WHITE .. '  /hud_test_single <suite> <test> - Run single test' .. Colors.RESET)
    print(Colors.WHITE .. '  /hud_test_config [setting] [value] - View/set test configuration' .. Colors.RESET)
end)

return TestRunner