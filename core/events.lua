local Events = {}

local subscribers = {}
local stats = {
  published = 0,
  delivered = 0,
  errors = 0,
}

local function eventList(name)
  if not subscribers[name] then
    subscribers[name] = {}
  end
  return subscribers[name]
end

function Events.on(name, callback, options)
  assert(type(name) == 'string', 'event name must be string')
  assert(type(callback) == 'function', 'callback must be function')

  local opts = options or {}
  local list = eventList(name)
  local entry = {
    callback = callback,
    once = opts.once == true,
    owner = opts.owner or 'unknown',
  }

  table.insert(list, entry)

  return function()
    Events.off(name, callback)
  end
end

function Events.once(name, callback, options)
  local opts = options or {}
  opts.once = true
  return Events.on(name, callback, opts)
end

function Events.off(name, callback)
  local list = subscribers[name]
  if not list then
    return
  end

  if callback == nil then
    subscribers[name] = nil
    return
  end

  for i = #list, 1, -1 do
    if list[i].callback == callback then
      table.remove(list, i)
    end
  end

  if #list == 0 then
    subscribers[name] = nil
  end
end

function Events.emit(name, data)
  stats.published = stats.published + 1

  local list = subscribers[name]
  if not list or #list == 0 then
    return
  end

  local remove = {}

  for i, entry in ipairs(list) do
    local ok, err = pcall(entry.callback, data)
    if ok then
      stats.delivered = stats.delivered + 1
    else
      stats.errors = stats.errors + 1
      print(string.format('[Events] callback failed for %s (%s): %s', name, entry.owner, tostring(err)))
    end

    if entry.once then
      table.insert(remove, i)
    end
  end

  for i = #remove, 1, -1 do
    table.remove(list, remove[i])
  end

  if #list == 0 then
    subscribers[name] = nil
  end
end

function Events.clear()
  subscribers = {}
end

function Events.stats()
  local eventTypes = 0
  local subscriberCount = 0
  for _, list in pairs(subscribers) do
    eventTypes = eventTypes + 1
    subscriberCount = subscriberCount + #list
  end

  return {
    published = stats.published,
    delivered = stats.delivered,
    errors = stats.errors,
    eventTypes = eventTypes,
    subscribers = subscriberCount,
  }
end

Events.NAMES = {
  APP_FOCUSED = 'app.focused',
  APP_SWITCHED = 'app.switched',
  WINDOW_FOCUSED = 'window.focused',
  WINDOW_RESIZED = 'window.resized',
  WINDOW_DESTROYED = 'window.destroyed',
  INPUT_METHOD_WILL_CHANGE = 'inputmethod.willChange',
  INPUT_METHOD_CHANGED = 'inputmethod.changed',
  CONFIG_RELOADED = 'config.reloaded',
  SCREEN_CHANGED = 'screen.changed',
  CUSTOM_PREFIX = 'custom.',
}

return Events
