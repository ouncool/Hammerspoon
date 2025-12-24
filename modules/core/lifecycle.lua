-- **************************************************
-- Module Lifecycle Manager
-- Handles initialization, starting, stopping, and cleanup of modules
-- **************************************************

local Lifecycle = {}
local Logger = require('modules.core.logger')

-- Module registry
local modules = {
  loaded = {},
  started = {},
  failed = {}
}

-- Module dependencies
local dependencies = {}

-- Register a module with its dependencies
-- @param name string Module name
-- @param module table The module table
-- @param deps table Optional list of module names this module depends on
function Lifecycle.register(name, module, deps)
  if not name or type(name) ~= 'string' then
    error('Lifecycle.register: Invalid module name')
  end

  if not module or type(module) ~= 'table' then
    error('Lifecycle.register: Invalid module')
  end

  modules.loaded[name] = module
  dependencies[name] = deps or {}
  
  Logger.info('Lifecycle', 'Module registered: ' .. name)
end

-- Initialize a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.init(name)
  if not modules.loaded[name] then
    Logger.error('Lifecycle', 'Module not found: ' .. name)
    return false
  end

  if modules.started[name] then
    Logger.warn('Lifecycle', 'Module already started: ' .. name)
    return true
  end

  local module = modules.loaded[name]

  -- Check dependencies
  for _, dep in ipairs(dependencies[name] or {}) do
    if not modules.started[dep] then
      Logger.error('Lifecycle', string.format('Module %s depends on %s which is not started', name, dep))
      return false
    end
  end

  -- Call init if exists
  if module.init and type(module.init) == 'function' then
    local ok, err = pcall(module.init)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to init module %s: %s', name, tostring(err)))
      modules.failed[name] = err
      return false
    end
    Logger.debug('Lifecycle', 'Module initialized: ' .. name)
  end

  return true
end

-- Start a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.start(name)
  if not modules.loaded[name] then
    Logger.error('Lifecycle', 'Module not found: ' .. name)
    return false
  end

  if modules.started[name] then
    Logger.warn('Lifecycle', 'Module already started: ' .. name)
    return true
  end

  -- Initialize first
  if not Lifecycle.init(name) then
    return false
  end

  local module = modules.loaded[name]

  -- Call start if exists
  if module.start and type(module.start) == 'function' then
    local ok, err = pcall(module.start)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to start module %s: %s', name, tostring(err)))
      modules.failed[name] = err
      return false
    end
    Logger.info('Lifecycle', 'Module started: ' .. name)
  end

  modules.started[name] = true
  return true
end

-- Stop a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.stop(name)
  if not modules.started[name] then
    Logger.warn('Lifecycle', 'Module not started: ' .. name)
    return true
  end

  local module = modules.loaded[name]

  -- Call stop if exists
  if module.stop and type(module.stop) == 'function' then
    local ok, err = pcall(module.stop)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to stop module %s: %s', name, tostring(err)))
      return false
    end
    Logger.info('Lifecycle', 'Module stopped: ' .. name)
  end

  modules.started[name] = nil
  return true
end

-- Cleanup a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.cleanup(name)
  -- Stop first
  Lifecycle.stop(name)

  local module = modules.loaded[name]
  if not module then
    Logger.warn('Lifecycle', 'Module not found: ' .. name)
    return false
  end

  -- Call cleanup if exists
  if module.cleanup and type(module.cleanup) == 'function' then
    local ok, err = pcall(module.cleanup)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to cleanup module %s: %s', name, tostring(err)))
      return false
    end
    Logger.debug('Lifecycle', 'Module cleaned up: ' .. name)
  end

  -- Remove from registry
  modules.loaded[name] = nil
  modules.failed[name] = nil
  dependencies[name] = nil

  return true
end

-- Get module status
-- @param name string Module name
-- @return string status: 'loaded', 'started', 'failed', or nil
function Lifecycle.getStatus(name)
  if modules.failed[name] then
    return 'failed'
  elseif modules.started[name] then
    return 'started'
  elseif modules.loaded[name] then
    return 'loaded'
  end
  return nil
end

-- Get all modules
-- @param status string Optional filter by status
-- @return table List of module names
function Lifecycle.getModules(status)
  local result = {}
  
  for name, _ in pairs(modules.loaded) do
    if not status or Lifecycle.getStatus(name) == status then
      table.insert(result, name)
    end
  end
  
  return result
end

-- Get module
-- @param name string Module name
-- @return table Module or nil
function Lifecycle.getModule(name)
  return modules.loaded[name]
end

-- Print status of all modules
function Lifecycle.printStatus()
  print('📦 Module Lifecycle Status:')
  print('')
  
  local started = Lifecycle.getModules('started')
  local loaded = Lifecycle.getModules('loaded')
  local failed = {}
  
  for name, err in pairs(modules.failed) do
    table.insert(failed, name)
  end
  
  print('✅ Started (' .. #started .. '):')
  for _, name in ipairs(started) do
    print('  - ' .. name)
  end
  print('')
  
  if #loaded > 0 then
    print('⏳ Loaded but not started (' .. #loaded .. '):')
    for _, name in ipairs(loaded) do
      print('  - ' .. name)
    end
    print('')
  end
  
  if #failed > 0 then
    print('❌ Failed (' .. #failed .. '):')
    for _, name in ipairs(failed) do
      print('  - ' .. name .. ': ' .. tostring(modules.failed[name]))
    end
    print('')
  end
end

return Lifecycle
