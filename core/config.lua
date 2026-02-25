local Config = {}

local Logger = require('core.logger')
local Schema = require('core.schema')
local log = Logger.scope('Config')

local defaults = Schema.defaults
local schema = Schema.definition

local snapshot = nil

local function isArray(value, allowEmpty)
  if type(value) ~= 'table' then
    return false
  end

  local max = 0
  local count = 0
  for key, _ in pairs(value) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      return false
    end
    if key > max then
      max = key
    end
    count = count + 1
  end

  if count == 0 then
    return allowEmpty == true
  end

  return max == count
end

local function deepCopy(value)
  if type(value) ~= 'table' then
    return value
  end

  local result = {}
  for key, inner in pairs(value) do
    result[key] = deepCopy(inner)
  end
  return result
end

local function deepMerge(base, override)
  if type(base) ~= 'table' then
    return deepCopy(override)
  end

  local result = deepCopy(base)
  if type(override) ~= 'table' then
    return result
  end

  for key, value in pairs(override) do
    local current = result[key]
    if type(value) == 'table' and type(current) == 'table' and (not isArray(value, false)) and (not isArray(current, false)) then
      result[key] = deepMerge(current, value)
    else
      result[key] = deepCopy(value)
    end
  end

  return result
end

local function addError(errors, path, message)
  table.insert(errors, string.format('%s: %s', path, message))
end

local function validateNode(value, node, path, errors)
  local expectedType = node.type

  if expectedType == 'array' then
    if type(value) ~= 'table' or not isArray(value, true) then
      addError(errors, path, 'expected array')
      return
    end

    for index, item in ipairs(value) do
      validateNode(item, node.items, string.format('%s[%d]', path, index), errors)
    end
    return
  end

  if expectedType == 'table' then
    if type(value) ~= 'table' then
      addError(errors, path, 'expected table')
      return
    end

    local fields = node.fields or {}
    for key, inner in pairs(value) do
      if fields[key] == nil then
        addError(errors, path .. '.' .. key, 'unknown key')
      end
    end

    for key, childSchema in pairs(fields) do
      local childValue = value[key]
      if childValue == nil then
        addError(errors, path .. '.' .. key, 'missing key')
      else
        validateNode(childValue, childSchema, path .. '.' .. key, errors)
      end
    end

    return
  end

  if type(value) ~= expectedType then
    addError(errors, path, string.format('expected %s, got %s', expectedType, type(value)))
    return
  end

  if expectedType == 'string' then
    if node.pattern and not string.match(value, node.pattern) then
      addError(errors, path, 'pattern mismatch')
    end

    if node.enum then
      local found = false
      for _, option in ipairs(node.enum) do
        if option == value then
          found = true
          break
        end
      end
      if not found then
        addError(errors, path, 'value is not in enum')
      end
    end
  end

  if expectedType == 'number' then
    if node.min and value < node.min then
      addError(errors, path, string.format('must be >= %s', node.min))
    end
    if node.max and value > node.max then
      addError(errors, path, string.format('must be <= %s', node.max))
    end
  end
end

local function validate(config)
  local errors = {}
  validateNode(config, schema, 'config', errors)
  return #errors == 0, errors
end

local function loadUserConfig()
  package.loaded.config = nil
  local ok, userConfig = pcall(require, 'config')
  if not ok then
    local err = tostring(userConfig)
    if string.find(err, "module 'config' not found", 1, true) then
      return {}, 'config.lua not found, using defaults'
    end
    return nil, 'failed to load config.lua: ' .. err
  end

  if type(userConfig) ~= 'table' then
    return nil, 'config.lua must return a table'
  end

  return userConfig, nil
end

function Config.reload()
  local userConfig, loadErr = loadUserConfig()
  if userConfig == nil then
    snapshot = deepCopy(defaults)
    return false, {loadErr}
  end

  local merged = deepMerge(defaults, userConfig)
  local ok, errors = validate(merged)
  if not ok then
    snapshot = deepCopy(defaults)
    return false, errors
  end

  snapshot = merged

  if loadErr then
    log.warn(loadErr)
  end

  return true, {}
end

function Config.get()
  if snapshot == nil then
    local ok, errors = Config.reload()
    if not ok then
      for _, err in ipairs(errors) do
        log.error(err)
      end
    end
  end
  return deepCopy(snapshot)
end

function Config.defaults()
  return deepCopy(defaults)
end

return Config
