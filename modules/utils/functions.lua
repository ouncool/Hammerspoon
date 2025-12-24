local Utils = {}

function noop() end

function Utils.debounce(func, delay)
  local timer = nil

  return function(...)
    local args = { ... }

    if timer then
      timer:stop()
      timer = nil
    end

    timer = hs.timer.doAfter(delay, function()
      func(table.unpack(args))
    end)
  end
end

function Utils.throttle(func, delay)
  local wait = false
  local storedArgs = nil
  local timer = nil

  local function checkStoredArgs()
    if storedArgs == nil then
      wait = false
    else
      func(table.unpack(storedArgs))
      storedArgs = nil
      timer = hs.timer.doAfter(delay, checkStoredArgs)
    end
  end

  return function(...)
    local args = { ... }

    if wait then
      storedArgs = args
      return
    end

    func(table.unpack(args))
    wait = true
    timer = hs.timer.doAfter(delay, checkStoredArgs)
  end
end

function Utils.clamp(value, min, max)
  return math.max(math.min(value, max), min)
end

--- Transition effect utility function
-- @param options Parameter configuration
--   @field duration Transition duration
--   @field easing Easing function, accepts real progress and returns eased progress
--   @field onProgress Triggered during transition
--   @field onEnd Triggered after transition ends
-- @return Function to cancel transition
function Utils.animate(options)
  local duration = options.duration
  local easing = options.easing
  local onProgress = options.onProgress
  local onEnd = options.onEnd or noop

  local st = hs.timer.absoluteTime()
  local timer = nil

  local function progress()
    local now = hs.timer.absoluteTime()
    local diffSec = (now - st) / 1000000000

    if diffSec <= duration then
      onProgress(easing(diffSec / duration))
      timer = hs.timer.doAfter(1 / 60, function() progress() end)
    else
      timer = nil
      onProgress(1)
      onEnd()
    end
  end

  -- 初始执行
  progress()

  return function()
    if timer then
      timer:stop()
      timer = nil
    end
  end
end

return Utils
