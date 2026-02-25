local Operations = {}

local function nowNs()
  return hs.timer.absoluteTime()
end

function Operations.new(ctx)
  local log = ctx.logger.scope('WindowOps')
  local events = ctx.events
  local ratio = ctx.config.window.twoThirdRatio

  local screenCache = {}
  local cacheNs = 0
  local cacheDurationNs = 1000000000

  local function focusedWindow()
    local win = hs.window.frontmostWindow()
    if not win then
      log.debug('No focused window')
      return nil
    end

    if not win:isVisible() then
      log.debug('Focused window is not visible')
      return nil
    end

    local app = win:application()
    events.emit(events.NAMES.WINDOW_FOCUSED, {
      title = win:title(),
      app = app and app:name() or 'unknown',
    })

    return win
  end

  local function screenFrame(win)
    local current = nowNs()
    if (current - cacheNs) > cacheDurationNs then
      screenCache = {}
      cacheNs = current
    end

    local screen = win:screen()
    local id = screen:id()
    if not screenCache[id] then
      screenCache[id] = screen:frame()
    end
    return screenCache[id]
  end

  local function setFrame(win, rect)
    local old = win:frame()
    local ok, err = pcall(function()
      win:setFrame(rect)
    end)

    if not ok then
      log.error('Failed to set frame', {error = err})
      return
    end

    events.emit(events.NAMES.WINDOW_RESIZED, {
      oldFrame = old,
      newFrame = rect,
    })
  end

  local function withWindow(handler)
    local win = focusedWindow()
    if not win then
      return
    end
    handler(win, screenFrame(win))
  end

  local api = {}

  function api.halfLeft()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h})
    end)
  end

  function api.halfRight()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h})
    end)
  end

  function api.halfTop()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x, y = screen.y, w = screen.w, h = screen.h / 2})
    end)
  end

  function api.halfBottom()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x, y = screen.y + screen.h / 2, w = screen.w, h = screen.h / 2})
    end)
  end

  function api.quarterLT()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h / 2})
    end)
  end

  function api.quarterLB()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2})
    end)
  end

  function api.quarterRT()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h / 2})
    end)
  end

  function api.quarterRB()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x + screen.w / 2, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2})
    end)
  end

  function api.twoThirdLeft()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x, y = screen.y, w = screen.w * ratio, h = screen.h})
    end)
  end

  function api.twoThirdRight()
    withWindow(function(win, screen)
      setFrame(win, {x = screen.x + screen.w * (1 - ratio), y = screen.y, w = screen.w * ratio, h = screen.h})
    end)
  end

  function api.maximize()
    withWindow(function(win)
      win:maximize()
      events.emit(events.NAMES.WINDOW_RESIZED, {action = 'maximize'})
    end)
  end

  function api.close()
    withWindow(function(win)
      win:close()
      events.emit(events.NAMES.WINDOW_DESTROYED, {action = 'close'})
    end)
  end

  api.helpMessage = [[
Window Management

h/l/j/k: left/right/bottom/top half
y/u/i/o: quarter windows
H/L: left/right two-thirds
f: maximize
c: close window
Tab: show this help
q or Esc: exit
]]

  return api
end

return Operations
