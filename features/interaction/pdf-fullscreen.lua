local Timing = require('shared.timing')

local M = {}

local ctx = nil
local log = nil
local wf = nil
local debounced = nil
local config = nil

local function isPreviewApp(app)
  if not app then
    return false
  end

  if app:bundleID() == config.bundleId then
    return true
  end

  local name = app:name()
  for _, appName in ipairs(config.appNames) do
    if name == appName then
      return true
    end
  end

  return false
end

local function isPdfWindow(win)
  if not win then
    return false
  end

  local title = win:title()
  if not title then
    return false
  end

  local lower = string.lower(title)
  return lower:find('%.pdf$') ~= nil or lower:find('pdf') ~= nil
end

local function fullscreenIfNeeded(win)
  if not win then
    return
  end

  local app = win:application()
  if not isPreviewApp(app) then
    return
  end

  if not isPdfWindow(win) then
    return
  end

  if win:isFullScreen() then
    return
  end

  hs.timer.doAfter(config.fullscreenDelaySec, function()
    if not win then
      return
    end

    local okVisible, visible = pcall(function()
      return win:isVisible()
    end)
    if not okVisible or not visible then
      return
    end

    local okFullscreen, isFullscreen = pcall(function()
      return win:isFullScreen()
    end)
    if not okFullscreen or isFullscreen then
      return
    end

    local ok, err = pcall(function()
      win:setFullScreen(true)
    end)

    if ok then
      log.info('Set PDF window to fullscreen', {title = win:title()})
      ctx.events.emit(ctx.events.NAMES.CUSTOM_PREFIX .. 'pdf.fullscreen', {
        title = win:title(),
      })
    else
      log.error('Failed to set fullscreen', {error = err})
    end
  end)
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('PreviewPdf')
  config = ctx.config.previewPdf
  debounced = Timing.debounce(fullscreenIfNeeded, config.debounceSec)
  return true
end

function M.start()
  local ok, filterOrErr = pcall(function()
    return hs.window.filter.new(config.appNames)
  end)

  if not ok then
    return false, tostring(filterOrErr)
  end

  wf = filterOrErr

  wf:subscribe(hs.window.filter.windowCreated, function(win)
    debounced(win)
  end)

  wf:subscribe(hs.window.filter.windowFocused, function(win)
    debounced(win)
  end)

  wf:subscribe(hs.window.filter.windowTitleChanged, function(win)
    debounced(win)
  end)

  log.info('Preview PDF fullscreen started')
  return true
end

function M.stop()
  if wf then
    wf:unsubscribe()
    wf = nil
  end

  if debounced and debounced.cancel then
    debounced.cancel()
  end

  return true
end

function M.dispose()
  M.stop()
  ctx = nil
  log = nil
  config = nil
  debounced = nil
end

return M
