-- **************************************************
-- Unified Logging System
-- Provides structured logging with levels and output destinations
-- **************************************************

local Logger = {}

-- Log levels
local LEVELS = {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  FATAL = 4
}

-- Current log level (default: INFO)
local currentLevel = LEVELS.INFO

-- Log destinations
local destinations = {
  console = true,
  file = false,
  notification = false
}

-- Log file path
local logFilePath = os.getenv('TMPDIR') .. '/hammerspoon.log'

-- Maximum log file size (1MB)
local maxLogSize = 1024 * 1024

-- Statistics
local stats = {
  debug = 0,
  info = 0,
  warn = 0,
  error = 0,
  fatal = 0
}

-- Module log levels (for fine-grained control)
local moduleLevels = {}

-- Color codes for console output
local colors = {
  DEBUG = '\27[36m', -- Cyan
  INFO = '\27[32m',  -- Green
  WARN = '\27[33m',  -- Yellow
  ERROR = '\27[31m', -- Red
  FATAL = '\27[35m', -- Magenta
  RESET = '\27[0m'
}

-- Format timestamp
local function formatTimestamp()
  return os.date('%Y-%m-%d %H:%M:%S')
end

-- Format log message
local function formatMessage(level, module, message, context)
  local timestamp = formatTimestamp()
  local ctxStr = context and ' | ' .. hs.inspect(context) or ''
  return string.format('[%s] [%s] [%s] %s%s', timestamp, level, module, message, ctxStr)
end

-- Write to log file
local function writeToFile(message)
  if not destinations.file then
    return
  end

  -- Check file size
  local file = io.open(logFilePath, 'r')
  if file then
    local size = file:seek('end')
    file:close()
    if size > maxLogSize then
      -- Rotate log file
      os.rename(logFilePath, logFilePath .. '.old')
    end
  end

  -- Append to log file
  file = io.open(logFilePath, 'a')
  if file then
    file:write(message .. '\n')
    file:close()
  end
end

-- Show notification for error/fatal
local function showNotification(level, message)
  if not destinations.notification then
    return
  end

  if level == 'ERROR' or level == 'FATAL' then
    hs.notify.new({
      title = 'Hammerspoon ' .. level,
      informativeText = message,
      sound = level == 'FATAL' and 'Basso' or nil
    }):send()
  end
end

-- Core logging function
local function log(level, levelName, module, message, context)
  -- Check if we should log this level
  local moduleLevel = moduleLevels[module] or currentLevel
  if level < moduleLevel then
    return
  end

  -- Update statistics
  stats[levelName:lower()] = stats[levelName:lower()] + 1

  -- Format message
  local formattedMsg = formatMessage(levelName, module, message, context)

  -- Output to console with colors
  if destinations.console then
    local color = colors[levelName] or colors.RESET
    print(color .. formattedMsg .. colors.RESET)
  end

  -- Write to file
  writeToFile(formattedMsg)

  -- Show notification for errors
  showNotification(levelName, message)
end

-- Public API
function Logger.debug(module, message, context)
  log(LEVELS.DEBUG, 'DEBUG', module, message, context)
end

function Logger.info(module, message, context)
  log(LEVELS.INFO, 'INFO', module, message, context)
end

function Logger.warn(module, message, context)
  log(LEVELS.WARN, 'WARN', module, message, context)
end

function Logger.error(module, message, context)
  log(LEVELS.ERROR, 'ERROR', module, message, context)
end

function Logger.fatal(module, message, context)
  log(LEVELS.FATAL, 'FATAL', module, message, context)
end

-- Set global log level
function Logger.setLevel(level)
  if type(level) == 'string' then
    level = LEVELS[level:upper()] or LEVELS.INFO
  end
  currentLevel = level
end

-- Set module-specific log level
function Logger.setModuleLevel(module, level)
  if type(level) == 'string' then
    level = LEVELS[level:upper()] or LEVELS.INFO
  end
  moduleLevels[module] = level
end

-- Enable/disable log destinations
function Logger.setDestination(dest, enabled)
  if destinations[dest] ~= nil then
    destinations[dest] = enabled
  end
end

-- Set log file path
function Logger.setLogFile(path)
  logFilePath = path
end

-- Get statistics
function Logger.getStats()
  return {
    debug = stats.debug,
    info = stats.info,
    warn = stats.warn,
    error = stats.error,
    fatal = stats.fatal,
    total = stats.debug + stats.info + stats.warn + stats.error + stats.fatal
  }
end

-- Print statistics (only if there are non-zero entries)
function Logger.printStats()
  local s = Logger.getStats()

  -- Only show levels that have non-zero counts
  local lines = {}
  if s.debug > 0 then
    table.insert(lines, string.format('  DEBUG: %d', s.debug))
  end
  if s.info > 0 then
    table.insert(lines, string.format('  INFO: %d', s.info))
  end
  if s.warn > 0 then
    table.insert(lines, string.format('  WARN: %d', s.warn))
  end
  if s.error > 0 then
    table.insert(lines, string.format('  ERROR: %d', s.error))
  end
  if s.fatal > 0 then
    table.insert(lines, string.format('  FATAL: %d', s.fatal))
  end

  if #lines > 0 then
    print('📊 Logger Statistics:')
    for _, line in ipairs(lines) do
      print(line)
    end
    print(string.format('  Total: %d', s.total))
  end
end

-- Clear statistics
function Logger.clearStats()
  stats = {
    debug = 0,
    info = 0,
    warn = 0,
    error = 0,
    fatal = 0
  }
end

-- Create a logger for a specific module
function Logger.new(moduleName)
  return {
    debug = function(msg, ctx) Logger.debug(moduleName, msg, ctx) end,
    info = function(msg, ctx) Logger.info(moduleName, msg, ctx) end,
    warn = function(msg, ctx) Logger.warn(moduleName, msg, ctx) end,
    error = function(msg, ctx) Logger.error(moduleName, msg, ctx) end,
    fatal = function(msg, ctx) Logger.fatal(moduleName, msg, ctx) end
  }
end

return Logger
