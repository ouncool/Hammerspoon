local Timing = {}

function Timing.debounce(fn, delay)
  local timer = nil
  local delaySec = delay or 0

  local function invoke(...)
    local args = {...}

    if timer then
      timer:stop()
      timer = nil
    end

    timer = hs.timer.doAfter(delaySec, function()
      timer = nil
      fn(table.unpack(args))
    end)
  end

  local wrapper = {}

  function wrapper.cancel()
    if timer then
      timer:stop()
      timer = nil
    end
  end

  return setmetatable(wrapper, {
    __call = function(_, ...)
      invoke(...)
    end,
  })
end

function Timing.throttle(fn, delay)
  local waiting = false
  local pendingArgs = nil
  local timer = nil
  local delaySec = delay or 0

  local function flush()
    if pendingArgs == nil then
      waiting = false
      timer = nil
      return
    end

    local args = pendingArgs
    pendingArgs = nil
    fn(table.unpack(args))

    timer = hs.timer.doAfter(delaySec, flush)
  end

  local function invoke(...)
    local args = {...}

    if waiting then
      pendingArgs = args
      return
    end

    waiting = true
    fn(table.unpack(args))
    timer = hs.timer.doAfter(delaySec, flush)
  end

  local wrapper = {}

  function wrapper.cancel()
    if timer then
      timer:stop()
      timer = nil
    end
    pendingArgs = nil
    waiting = false
  end

  return setmetatable(wrapper, {
    __call = function(_, ...)
      invoke(...)
    end,
  })
end

return Timing
