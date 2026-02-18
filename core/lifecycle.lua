local Lifecycle = {}

local Logger = require('core.logger')
local log = Logger.scope('Lifecycle')

local registry = {}
local order = {}
local context = {}

local function safeCall(moduleId, fnName, fn, ...)
  local ok, result, err = pcall(fn, ...)
  if not ok then
    return false, string.format('%s.%s panicked: %s', moduleId, fnName, tostring(result))
  end

  if result == false then
    return false, tostring(err or 'returned false')
  end

  return true, nil
end

local function topoSort()
  local visiting = {}
  local visited = {}
  local result = {}

  local function visit(id)
    if visited[id] then
      return true
    end

    if visiting[id] then
      return false, 'cyclic dependency at ' .. id
    end

    local entry = registry[id]
    if not entry then
      return false, 'unknown module dependency: ' .. id
    end

    visiting[id] = true
    for _, dep in ipairs(entry.deps) do
      local ok, err = visit(dep)
      if not ok then
        return false, err
      end
    end
    visiting[id] = nil

    visited[id] = true
    table.insert(result, id)
    return true
  end

  for id, _ in pairs(registry) do
    local ok, err = visit(id)
    if not ok then
      return false, err
    end
  end

  return true, result
end

function Lifecycle.setContext(ctx)
  context = ctx or {}
end

function Lifecycle.register(spec)
  assert(type(spec) == 'table', 'register spec must be table')
  assert(type(spec.id) == 'string' and spec.id ~= '', 'module id is required')
  assert(type(spec.module) == 'table', 'module table is required')

  if registry[spec.id] then
    error('module already registered: ' .. spec.id)
  end

  local deps = spec.deps or {}
  if type(deps) ~= 'table' then
    error('deps must be a table')
  end

  registry[spec.id] = {
    id = spec.id,
    module = spec.module,
    deps = deps,
    enabled = spec.enabled ~= false,
    setupDone = false,
    started = false,
    failed = false,
    error = nil,
  }

  log.debug('Registered module', {id = spec.id})
end

function Lifecycle.startAll()
  local ok, result = topoSort()
  if not ok then
    log.error('Failed to resolve dependency graph', {error = result})
    return false
  end

  order = result

  for _, id in ipairs(order) do
    local entry = registry[id]

    if entry.enabled then
      if not entry.setupDone and type(entry.module.setup) == 'function' then
        local setupOk, setupErr = safeCall(id, 'setup', entry.module.setup, context)
        if not setupOk then
          entry.failed = true
          entry.error = setupErr
          log.error('Setup failed', {id = id, error = setupErr})
          return false
        end
        entry.setupDone = true
      end

      if type(entry.module.start) == 'function' then
        local startOk, startErr = safeCall(id, 'start', entry.module.start)
        if not startOk then
          entry.failed = true
          entry.error = startErr
          log.error('Start failed', {id = id, error = startErr})
          return false
        end
      end

      entry.started = true
      entry.failed = false
      entry.error = nil
      log.info('Started module', {id = id})
    end
  end

  return true
end

function Lifecycle.stopAll()
  if #order == 0 then
    local ok, result = topoSort()
    if not ok then
      return false, result
    end
    order = result
  end

  for i = #order, 1, -1 do
    local id = order[i]
    local entry = registry[id]
    if entry and entry.started and type(entry.module.stop) == 'function' then
      local stopOk, stopErr = safeCall(id, 'stop', entry.module.stop)
      if not stopOk then
        log.error('Stop failed', {id = id, error = stopErr})
      end
    end
    if entry then
      entry.started = false
    end
  end

  return true
end

function Lifecycle.disposeAll()
  Lifecycle.stopAll()

  if #order == 0 then
    local ok, result = topoSort()
    if ok then
      order = result
    end
  end

  for i = #order, 1, -1 do
    local id = order[i]
    local entry = registry[id]
    if entry and type(entry.module.dispose) == 'function' then
      local disposeOk, disposeErr = safeCall(id, 'dispose', entry.module.dispose)
      if not disposeOk then
        log.error('Dispose failed', {id = id, error = disposeErr})
      end
    end
  end

  return true
end

function Lifecycle.status()
  local result = {}
  for id, entry in pairs(registry) do
    result[id] = {
      enabled = entry.enabled,
      setupDone = entry.setupDone,
      started = entry.started,
      failed = entry.failed,
      error = entry.error,
      deps = entry.deps,
    }
  end
  return result
end

function Lifecycle.startedModules()
  local list = {}
  for _, id in ipairs(order) do
    local entry = registry[id]
    if entry and entry.started then
      table.insert(list, id)
    end
  end
  return list
end

function Lifecycle.failedModules()
  local list = {}
  for id, entry in pairs(registry) do
    if entry.failed then
      table.insert(list, {id = id, error = entry.error})
    end
  end
  return list
end

function Lifecycle.isRegistered(id)
  return registry[id] ~= nil
end

function Lifecycle.get(id)
  return registry[id]
end

return Lifecycle
