local Timing = require('shared.timing')

local M = {}

local ctx = nil
local log = nil
local watcher = nil
local debouncedSwitch = nil

local defaultIME = ''
local englishIME = ''

local lookup = {
  byPath = {},
  byBundle = {},
  byName = {},
  patterns = {},
}

local function lower(value)
  if not value then
    return ''
  end
  return string.lower(value)
end

local function resetLookup()
  lookup.byPath = {}
  lookup.byBundle = {}
  lookup.byName = {}
  lookup.patterns = {}
end

local function toAppName(path)
  local name = path:match('/([^/]+)%.app$')
  return name
end

local function buildLookup(apps)
  resetLookup()

  for _, item in ipairs(apps) do
    if type(item) == 'string' and item ~= '' then
      lookup.byPath[item] = true
      lookup.byBundle[item] = true
      lookup.byName[item] = true

      local appName = toAppName(item)
      if appName then
        lookup.byName[appName] = true
      end

      table.insert(lookup.patterns, lower(item))
    end
  end

  log.info('Input method lookup built', {count = #apps})
end

local function isEnglishApp(app)
  local appPath = app:path() or ''
  local bundleId = app:bundleID() or ''
  local appName = app:name() or ''

  if lookup.byPath[appPath] or lookup.byBundle[bundleId] or lookup.byName[appName] then
    return true
  end

  local pathLower = lower(appPath)
  local bundleLower = lower(bundleId)
  local nameLower = lower(appName)

  for _, pattern in ipairs(lookup.patterns) do
    if string.find(pathLower, pattern, 1, true) or string.find(bundleLower, pattern, 1, true) or string.find(nameLower, pattern, 1, true) then
      return true
    end
  end

  return false
end

local function applyForApp(app)
  if not app then
    return
  end

  local isEnglish = isEnglishApp(app)
  local target = isEnglish and englishIME or defaultIME
  local current = hs.keycodes.currentSourceID()

  ctx.events.emit(ctx.events.NAMES.INPUT_METHOD_WILL_CHANGE, {
    appName = app:name(),
    bundleId = app:bundleID(),
    appPath = app:path(),
    isEnglish = isEnglish,
    from = current,
    to = target,
  })

  if current == target then
    return
  end

  hs.keycodes.currentSourceID(target)

  log.debug('Input method switched', {
    app = app:name(),
    from = current,
    to = target,
  })

  ctx.events.emit(ctx.events.NAMES.INPUT_METHOD_CHANGED, {
    appName = app:name(),
    bundleId = app:bundleID(),
    appPath = app:path(),
    isEnglish = isEnglish,
    ime = target,
  })
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('InputMethod')

  defaultIME = ctx.config.inputMethod.default
  englishIME = ctx.config.inputMethod.english

  buildLookup(ctx.config.inputMethod.englishApps)
  debouncedSwitch = Timing.debounce(applyForApp, 0.2)

  return true
end

function M.start()
  watcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType ~= hs.application.watcher.activated then
      return
    end

    ctx.events.emit(ctx.events.NAMES.APP_FOCUSED, {
      appName = appName,
      bundleId = appObject and appObject:bundleID() or nil,
      appPath = appObject and appObject:path() or nil,
    })

    if appObject then
      debouncedSwitch(appObject)
    end
  end)

  watcher:start()
  log.info('Input method auto-switch started')
  return true
end

function M.stop()
  if watcher then
    watcher:stop()
    watcher = nil
  end

  if debouncedSwitch and debouncedSwitch.cancel then
    debouncedSwitch.cancel()
  end

  return true
end

function M.dispose()
  M.stop()
  ctx = nil
  log = nil
  defaultIME = ''
  englishIME = ''
  resetLookup()
  debouncedSwitch = nil
end

return M
