local Logger = {}

local LEVELS = {
  DEBUG = 10,
  INFO = 20,
  WARN = 30,
  ERROR = 40,
  FATAL = 50,
}

local currentLevel = LEVELS.INFO
local destinations = {
  console = true,
  notification = false,
}

local stats = {
  DEBUG = 0,
  INFO = 0,
  WARN = 0,
  ERROR = 0,
  FATAL = 0,
}

local function levelFrom(value)
  if type(value) == 'number' then
    return value
  end

  if type(value) == 'string' then
    local upper = string.upper(value)
    return LEVELS[upper] or LEVELS.INFO
  end

  return LEVELS.INFO
end

local function levelName(value)
  for name, number in pairs(LEVELS) do
    if number == value then
      return name
    end
  end
  return 'INFO'
end

local function inspectContext(context)
  if context == nil then
    return ''
  end

  if hs and hs.inspect then
    return ' | ' .. hs.inspect(context)
  end

  return ' | ' .. tostring(context)
end

local function formatLine(level, scope, message, context)
  local timestamp = os.date('%Y-%m-%d %H:%M:%S')
  local suffix = inspectContext(context)
  return string.format('[%s] [%s] [%s] %s%s', timestamp, level, scope, message, suffix)
end

local function notifyIfNeeded(level, message)
  if not destinations.notification then
    return
  end

  if level ~= 'ERROR' and level ~= 'FATAL' then
    return
  end

  hs.notify.new({
    title = 'Hammerspoon ' .. level,
    informativeText = message,
  }):send()
end

local function write(level, scope, message, context)
  local numeric = levelFrom(level)
  if numeric < currentLevel then
    return
  end

  local name = levelName(numeric)
  stats[name] = (stats[name] or 0) + 1

  local line = formatLine(name, scope, tostring(message), context)

  if destinations.console then
    print(line)
  end

  notifyIfNeeded(name, tostring(message))
end

function Logger.configure(config)
  if type(config) ~= 'table' then
    return
  end

  if config.level ~= nil then
    currentLevel = levelFrom(config.level)
  end

  if config.console ~= nil then
    destinations.console = not not config.console
  end

  if config.notification ~= nil then
    destinations.notification = not not config.notification
  end
end

function Logger.setLevel(level)
  currentLevel = levelFrom(level)
end

function Logger.scope(scope)
  local scopeName = scope or 'App'
  return {
    debug = function(message, context)
      write('DEBUG', scopeName, message, context)
    end,
    info = function(message, context)
      write('INFO', scopeName, message, context)
    end,
    warn = function(message, context)
      write('WARN', scopeName, message, context)
    end,
    error = function(message, context)
      write('ERROR', scopeName, message, context)
    end,
    fatal = function(message, context)
      write('FATAL', scopeName, message, context)
    end,
  }
end

function Logger.getStats()
  return {
    DEBUG = stats.DEBUG,
    INFO = stats.INFO,
    WARN = stats.WARN,
    ERROR = stats.ERROR,
    FATAL = stats.FATAL,
    total = stats.DEBUG + stats.INFO + stats.WARN + stats.ERROR + stats.FATAL,
  }
end

function Logger.resetStats()
  stats.DEBUG = 0
  stats.INFO = 0
  stats.WARN = 0
  stats.ERROR = 0
  stats.FATAL = 0
end

return Logger
