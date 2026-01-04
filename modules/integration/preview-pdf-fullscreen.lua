-- **************************************************
-- Auto fullscreen when opening PDF files in Preview
-- **************************************************

local Utils = require('modules.utils.functions')
local Logger = require('modules.core.logger')
local EventBus = require('modules.core.event-bus')

local log = Logger.new('PreviewPDF')

-- Preview app name (compatible with Chinese and English systems)
local PREVIEW_APP = "预览"
local PREVIEW_APP_EN = "Preview"
local PREVIEW_BUNDLE_ID = "com.apple.Preview"

local wf = nil

-- Check if window title indicates a PDF file
local function isPDFWindow(window)
  if not window then return false end
  local title = window:title()
  if not title then return false end

  -- Check suffix or contains pdf keyword
  local lowerTitle = string.lower(title)
  local isPdf = string.find(lowerTitle, "%.pdf$") ~= nil or string.find(lowerTitle, "pdf") ~= nil
  return isPdf
end

-- Set window to fullscreen
local function setFullscreen(window)
  if not window then return end
  -- Delay execution to ensure window is fully loaded
  hs.timer.doAfter(0.5, function()
    local ok, err = pcall(function() window:setFullScreen(true) end)
    if ok then
      log.info('Set PDF to fullscreen', { title = window:title() })
      EventBus.emit(EventBus.EVENTS.CUSTOM .. 'pdf.fullscreen', {
        window = window,
        title = window:title()
      })
    else
      log.error('Failed to set fullscreen', { error = err })
    end
  end)
end

-- Check if it's Preview app
local function isPreviewApp(appName, bundleID)
  return (appName == PREVIEW_APP or appName == PREVIEW_APP_EN) or bundleID == PREVIEW_BUNDLE_ID
end

-- Lifecycle functions
local function init()
  log.debug('Initializing preview PDF fullscreen')
  return true
end

local function start()
  log.debug('Starting preview PDF fullscreen')

  -- Use hs.window.filter to subscribe to window events
  -- Optimization: Only listen to Preview app, avoid scanning all windows
  local ok_wf, filter = pcall(function()
    return hs.window.filter.new({PREVIEW_APP, PREVIEW_APP_EN})
  end)

  if ok_wf and filter then
    wf = filter
    local debouncedHandle = Utils.debounce(function(win)
      if not win then return end
      -- double check app name just in case
      local app = win:application()
      if not app then return end

      if isPreviewApp(app:name(), app:bundleID()) and isPDFWindow(win) and not win:isFullScreen() then
        setFullscreen(win)
      end
    end, 0.2)

    wf:subscribe(hs.window.filter.windowCreated, function(win, appName) debouncedHandle(win) end)
    wf:subscribe(hs.window.filter.windowFocused, function(win, appName) debouncedHandle(win) end)
    wf:subscribe(hs.window.filter.windowTitleChanged, function(win, appName) debouncedHandle(win) end)

    log.debug('Window filter subscribed successfully')
  else
    log.error('Failed to create window filter')
  end

  return true
end

local function stop()
  log.debug('Stopping preview PDF fullscreen')

  if wf then
    wf:unsubscribe()
    wf = nil
  end
end

local function cleanup()
  log.debug('Cleaning up preview PDF fullscreen')
  stop()
end

-- Export module
return {
  init = init,
  start = start,
  stop = stop,
  cleanup = cleanup
}