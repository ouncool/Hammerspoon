-- **************************************************
-- Configuration Validator
-- Validates configuration values on load and provides helpful error messages
-- **************************************************

local Validator = {}
local Logger = require('modules.core.logger')

-- Validation schemas
local schemas = {
  inputMethod = {
    default = { type = 'string', required = true, pattern = '^com%.%w+%.%w+' },
    english = { type = 'string', required = true, pattern = '^com%.%w+%.%w+' },
    englishApps = { type = 'table', required = true, elementType = 'string' }
  },
  
  window = {
    twoThirdRatio = { type = 'number', required = false, min = 0.1, max = 0.9 }
  },
  
  image = {
    quality = { type = 'number', required = false, min = 1, max = 100 },
    maxDim = { type = 'number', required = false, min = 100, max = 10000 }
  },
  
  logging = {
    level = { type = 'string', required = false, enum = {'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'} },
    file = { type = 'boolean', required = false },
    console = { type = 'boolean', required = false },
    notification = { type = 'boolean', required = false }
  }
}

-- Validation errors
local errors = {}

-- Add error
local function addError(path, message)
  table.insert(errors, {
    path = path,
    message = message
  })
end

-- Validate a value against a schema
-- @param value any The value to validate
-- @param schema table The schema to validate against
-- @param path string The configuration path (for error messages)
-- @return boolean valid
local function validateValue(value, schema, path)
  if not schema then
    return true
  end

  -- Check required
  if schema.required and value == nil then
    addError(path, 'Required value is missing')
    return false
  end

  if value == nil then
    return true -- Optional and nil is OK
  end

  -- Check type
  if schema.type and type(value) ~= schema.type then
    addError(path, string.format('Expected %s, got %s', schema.type, type(value)))
    return false
  end

  -- Check pattern (for strings)
  if schema.pattern and type(value) == 'string' then
    if not value:match(schema.pattern) then
      addError(path, string.format('Value does not match pattern: %s', schema.pattern))
      return false
    end
  end

  -- Check enum
  if schema.enum then
    local found = false
    for _, v in ipairs(schema.enum) do
      if value == v then
        found = true
        break
      end
    end
    if not found then
      addError(path, string.format('Value must be one of: %s', table.concat(schema.enum, ', ')))
      return false
    end
  end

  -- Check min/max (for numbers)
  if schema.min and type(value) == 'number' then
    if value < schema.min then
      addError(path, string.format('Value must be >= %s, got %s', schema.min, value))
      return false
    end
  end

  if schema.max and type(value) == 'number' then
    if value > schema.max then
      addError(path, string.format('Value must be <= %s, got %s', schema.max, value))
      return false
    end
  end

  -- Check array element type
  if schema.elementType and type(value) == 'table' then
    for i, v in ipairs(value) do
      if type(v) ~= schema.elementType then
        addError(path .. '[' .. i .. ']', string.format('Expected %s, got %s', schema.elementType, type(v)))
        return false
      end
    end
  end

  return true
end

-- Validate a configuration section
-- @param config table The configuration to validate
-- @param section string The section name
-- @param schema table The schema for this section
-- @return boolean valid
function Validator.validateSection(config, section, schema)
  if not config then
    addError(section, 'Configuration is nil')
    return false
  end

  local sectionConfig = config[section]
  if not sectionConfig then
    if schema and schema.required then
      addError(section, 'Required section is missing')
      return false
    end
    return true -- Optional and missing is OK
  end

  local valid = true
  for key, keySchema in pairs(schema) do
    local path = section .. '.' .. key
    if not validateValue(sectionConfig[key], keySchema, path) then
      valid = false
    end
  end

  return valid
end

-- Validate entire configuration
-- @param config table The configuration to validate
-- @return boolean valid, table errors
function Validator.validate(config)
  errors = {}
  
  if not config then
    addError('root', 'Configuration is nil')
    return false, errors
  end

  local valid = true
  
  -- Validate each section
  for sectionName, schema in pairs(schemas) do
    if not Validator.validateSection(config, sectionName, schema) then
      valid = false
    end
  end

  return valid, errors
end

-- Validate and provide helpful error messages
-- @param config table The configuration to validate
-- @return boolean valid
function Validator.validateAndReport(config)
  local valid, errs = Validator.validate(config)
  
  if not valid then
    Logger.error('Validator', 'Configuration validation failed:')
    for _, err in ipairs(errs) do
      Logger.error('Validator', string.format('  %s: %s', err.path, err.message))
    end
  else
    Logger.info('Validator', 'Configuration validation passed')
  end
  
  return valid
end

-- Get default configuration
-- @return table Default configuration
function Validator.getDefaults()
  return {
    inputMethod = {
      default = 'com.sogou.inputmethod.sogou.pinyin',
      english = 'com.apple.keylayout.ABC',
      englishApps = {
        '/Applications/Terminal.app',
        '/Applications/Ghostty.app',
        '/Applications/iTerm.app',
        '/Applications/Visual Studio Code.app'
      }
    },
    
    window = {
      twoThirdRatio = 2/3
    },
    
    image = {
      quality = 60,
      maxDim = 1600
    },
    
    logging = {
      level = 'INFO',
      file = false,
      console = true,
      notification = true
    }
  }
end

-- Merge user config with defaults
-- @param userConfig table User configuration
-- @return table Merged configuration
function Validator.mergeWithDefaults(userConfig)
  local defaults = Validator.getDefaults()
  local merged = {}
  
  -- Deep merge
  for section, sectionConfig in pairs(defaults) do
    merged[section] = {}
    for key, value in pairs(sectionConfig) do
      merged[section][key] = value
    end
  end
  
  -- Override with user config
  if userConfig then
    for section, sectionConfig in pairs(userConfig) do
      if not merged[section] then
        merged[section] = {}
      end
      for key, value in pairs(sectionConfig) do
        merged[section][key] = value
      end
    end
  end
  
  return merged
end

return Validator
