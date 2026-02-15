-- **************************************************
-- App Switcher with Beautiful UI
-- Option + Tab to switch between applications
-- **************************************************
-- Features:
--   Beautiful card-based UI with app icons
--   Mouse click support
--   Keyboard navigation (Arrow keys + Enter)
--   Search/filter apps by typing
-- **************************************************

local Logger = require('modules.core.logger')
local EventBus = require('modules.core.event-bus')
local configModule = require('modules.utils.config')

local log = Logger.new('AppSwitcher')

local M = {}

-- Configuration
local config = configModule.appSwitcher or {}
local scope = config.scope or "allSpaces"

-- UI state
local chooser = nil
local appsCache = {}
local previousApp = nil

-- Get running applications
local function getRunningApps()
  local apps = {}
  local currentApp = hs.application.frontmostApplication()
  local currentPid = currentApp and currentApp:pid() or nil

  -- Get all applications with visible windows
  local filterConfig = {visible = true}
  if scope == "currentSpace" then
    filterConfig.currentSpace = true
  end

  local windowFilter = hs.window.filter.new():setDefaultFilter(filterConfig)
  local windows = windowFilter:getWindows()

  -- Build app list from windows
  local seenApps = {}

  -- Add current app first
  if currentApp then
    table.insert(apps, {
      text = currentApp:name(),
      subText = "⌘ " .. (currentApp:bundleID() or ""),
      image = hs.image.imageFromAppBundle(currentApp:bundleID()),
      app = currentApp
    })
    seenApps[currentPid] = true
  end

  -- Add other apps
  for _, win in ipairs(windows) do
    local app = win:application()
    if app and not seenApps[app:pid()] then
      table.insert(apps, {
        text = app:name(),
        subText = "⌘ " .. (app:bundleID() or ""),
        image = hs.image.imageFromAppBundle(app:bundleID()),
        app = app
      })
      seenApps[app:pid()] = true
    end
  end

  return apps
end

-- App selected callback
local function appSelected(choice)
  if not choice then
    log.debug('App switcher cancelled')
    return
  end

  -- Switch to selected app
  local app = choice.app
  if app then
    local fromApp = previousApp and previousApp:name() or "Unknown"
    local toApp = app:name()

    app:activate()

    -- Emit event
    EventBus.emit(EventBus.EVENTS.APP_SWITCHED, {
      fromApp = fromApp,
      toApp = toApp,
      timestamp = hs.timer.absoluteTime()
    })

    log.info('App switched', {
      from = fromApp,
      to = toApp
    })
  end
end

-- Show app switcher with beautiful UI
local function showSwitcher(direction)
  -- Store current app
  previousApp = hs.application.frontmostApplication()

  -- Get running apps
  local apps = getRunningApps()
  appsCache = apps

  -- Create chooser if not exists
  if not chooser then
    chooser = hs.chooser.new(function(choice)
      appSelected(choice)
    end)

    -- Configure beautiful UI
    local bgR, bgG, bgB, bgA = config.bgColor.red or 0.1,
                                  config.bgColor.green or 0.1,
                                  config.bgColor.blue or 0.1,
                                  config.bgColor.alpha or 0.95

    local textR, textG, textB, textA = config.textColor.red or 1,
                                      config.textColor.green or 1,
                                      config.textColor.blue or 1,
                                      config.textColor.alpha or 1

    local subR, subG, subB, subA = config.subTextColor.red or 0.7,
                                     config.subTextColor.green or 0.7,
                                     config.subTextColor.blue or 0.7,
                                     config.subTextColor.alpha or 1

    local selR, selG, selB, selA = config.selectedColor.red or 0.3,
                                     config.selectedColor.green or 0.5,
                                     config.selectedColor.blue or 1,
                                     config.selectedColor.alpha or 0.3

    chooser:bgColor({red = bgR, green = bgG, blue = bgB, alpha = bgA})
    chooser:textColor({red = textR, green = textG, blue = textB, alpha = textA})
    chooser:subTextColor({red = subR, green = subG, blue = subB, alpha = subA})
    chooser:searchSubText(false)
    chooser:width(config.width or 0.4)
    chooser:numRows(config.numRows or 8)
    chooser:font({name = "System", size = config.textSize or 16})
    chooser:subTextFont({name = "System", size = config.subTextSize or 12})
    chooser:shadow(config.shadow ~= false)

    if config.radius then
      chooser:radius(config.radius)
    end
  end

  -- Configure choices with app info
  local choices = {}
  for _, app in ipairs(apps) do
    table.insert(choices, {
      text = app.text,
      subText = app.subText,
      image = app.image,
      app = app.app
    })
  end

  chooser:choices(choices)
  chooser:show()

  log.debug('App switcher shown')
end

-- Show next app
local function showAndNext()
  showSwitcher('next')
end

-- Show previous app
local function showAndPrevious()
  showSwitcher('previous')
end

-- Setup hotkeys
local nextHotkey = nil
local prevHotkey = nil

local function setupHotkeys()
  -- Alt+Tab: Show switcher
  nextHotkey = hs.hotkey.bind({'alt'}, 'tab', showAndNext)

  -- Alt+Shift+Tab: Show switcher
  prevHotkey = hs.hotkey.bind({'alt', 'shift'}, 'tab', showAndPrevious)

  log.info('App switcher hotkeys bound')
end

-- Lifecycle: Initialize
local function init()
  log.debug('Initializing app switcher')
  setupHotkeys()
  return true
end

-- Lifecycle: Start
local function start()
  log.debug('Starting app switcher')
  log.info('App switcher started. Press Alt+Tab to switch apps.')
  return true
end

-- Lifecycle: Stop
local function stop()
  log.debug('Stopping app switcher')

  if nextHotkey then
    nextHotkey:delete()
    nextHotkey = nil
  end

  if prevHotkey then
    prevHotkey:delete()
    prevHotkey = nil
  end

  if chooser then
    chooser:delete()
    chooser = nil
  end
end

-- Lifecycle: Cleanup
local function cleanup()
  log.debug('Cleaning up app switcher')
  stop()
  appsCache = {}
  previousApp = nil
end

-- Export module
return {
  init = init,
  start = start,
  stop = stop,
  cleanup = cleanup
}
