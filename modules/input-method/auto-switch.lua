-- **************************************************
-- Input method auto-switch: Automatically switch input method based on app
-- **************************************************
-- Default to Sogou Pinyin, use English for specified apps
-- **************************************************

local utils = require('modules.utils.functions')
local config = require('modules.utils.config')
local EventBus = require('modules.core.event-bus')
local Logger = require('modules.core.logger')

local log = Logger.new('InputMethod')

-- --------------------------------------------------
-- Configuration Area
-- --------------------------------------------------

-- Default input method (Sogou Pinyin)
local DEFAULT_IME = config.inputMethod and config.inputMethod.default or 'com.sogou.inputmethod.sogou.pinyin'

-- English input method
local ABC = config.inputMethod and config.inputMethod.english or 'com.apple.keylayout.ABC'

-- Apps that need English input method
local ENGLISH_APPS = config.inputMethod and config.inputMethod.englishApps or {
  '/Applications/Terminal.app',
  '/Applications/Ghostty.app',
  '/Applications/iTerm.app',
  '/Applications/Visual Studio Code.app',
  '/Applications/WebStorm.app',
  '/Applications/Raycast.app'
--   '/Applications/Google Chrome.app',
--  '/Applications/Brave Browser.app',
}

-- --------------------------------------------------
-- Performance Optimization: Pre-compiled Lookup Tables
-- --------------------------------------------------

-- Build optimized lookup tables for O(1) access
local englishAppLookup = {
  byPath = {},
  byBundleID = {},
  byName = {},
  bySubstring = {}
}

-- Initialize lookup tables
local function initLookupTables()
  for _, appDef in ipairs(ENGLISH_APPS) do
    -- Direct match tables
    englishAppLookup.byPath[appDef] = true
    englishAppLookup.byBundleID[appDef] = true
    englishAppLookup.byName[appDef] = true
    
    -- Substring match table (lowercase for case-insensitive matching)
    local lowerDef = string.lower(appDef)
    englishAppLookup.bySubstring[lowerDef] = appDef
  end
  
  log.info('Lookup tables initialized', {
    pathCount = #ENGLISH_APPS,
    bundleCount = #ENGLISH_APPS,
    nameCount = #ENGLISH_APPS
  })
end

-- Fast substring check with caching
local substringCache = {}
local function isEnglishApp(focusedAppPath, focusedBundleID, focusedName)
  -- O(1) direct lookups first
  if englishAppLookup.byPath[focusedAppPath] then
    return true
  end
  
  if englishAppLookup.byBundleID[focusedBundleID] then
    return true
  end
  
  if englishAppLookup.byName[focusedName] then
    return true
  end
  
  -- Fallback to substring matching (only if direct match fails)
  local lowerPath = string.lower(focusedAppPath or '')
  local lowerBundle = string.lower(focusedBundleID or '')
  local lowerName = string.lower(focusedName or '')
  
  for pattern, original in pairs(englishAppLookup.bySubstring) do
    if string.find(lowerPath, pattern, 1, true) or
       string.find(lowerBundle, pattern, 1, true) or
       string.find(lowerName, pattern, 1, true) then
      return true
    end
  end
  
  return false
end

-- --------------------------------------------------
-- Core Logic
-- --------------------------------------------------

-- Convert application list to fast lookup table
local function updateFocusedAppInputMethod(appObject)
  if not appObject then
    return
  end

  local focusedAppPath = appObject:path() or ''
  local focusedBundleID = appObject:bundleID() or ''
  local focusedName = appObject:name() or ''

  -- Use optimized lookup
  local isEnglish = isEnglishApp(focusedAppPath, focusedBundleID, focusedName)

  -- Emit event for other modules
  EventBus.emit(EventBus.EVENTS.INPUT_METHOD_WILL_CHANGE, {
    isEnglish = isEnglish,
    appPath = focusedAppPath,
    bundleID = focusedBundleID,
    appName = focusedName
  })

  -- Switch input method
  local targetIME = isEnglish and ABC or DEFAULT_IME
  local currentIME = hs.keycodes.currentSourceID()
  
  if currentIME ~= targetIME then
    hs.keycodes.currentSourceID(targetIME)
    
    log.debug('Input method switched', {
      from = currentIME,
      to = targetIME,
      app = focusedName
    })
    
    -- Emit event after switch
    EventBus.emit(EventBus.EVENTS.INPUT_METHOD_CHANGED, {
      ime = targetIME,
      isEnglish = isEnglish,
      appPath = focusedAppPath,
      bundleID = focusedBundleID,
      appName = focusedName
    })
  end
end

-- Debounce processing to avoid frequent switching
local debouncedUpdateFn = utils.debounce(updateFocusedAppInputMethod, 0.1)

-- Listen to application switch events
local appWatcher = hs.application.watcher.new(
  function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
      -- Emit app focused event
      EventBus.emit(EventBus.EVENTS.APP_FOCUSED, {
        appName = appName,
        appObject = appObject
      })
      
      debouncedUpdateFn(appObject)
    end
  end
)

-- Initialize module
local function init()
  initLookupTables()
  return true
end

-- Start module
local function start()
  appWatcher:start()
  log.info('Module started', {
    defaultIME = DEFAULT_IME,
    englishIME = ABC,
    appCount = #ENGLISH_APPS
  })
  return true
end

-- Stop module
local function stop()
  appWatcher:stop()
  log.info('Module stopped')
end

-- Cleanup module
local function cleanup()
  stop()
  englishAppLookup = {
    byPath = {},
    byBundleID = {},
    byName = {},
    bySubstring = {}
  }
end

return {
  init = init,
  start = start,
  stop = stop,
  cleanup = cleanup,
  watcher = appWatcher
}
