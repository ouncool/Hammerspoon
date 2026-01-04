-- **************************************************
-- Event Bus System
-- Provides publish-subscribe pattern for inter-module communication
-- **************************************************

local EventBus = {}

-- Table to store event subscribers
-- Structure: { eventName: { {callback, once, module}, ... } }
local subscribers = {}
local subscriberCount = 0
local maxSubscribers = 1000 -- Prevent memory leaks

-- Event history for debugging (last 100 events)
local eventHistory = {}
local maxHistorySize = 100

-- Statistics
local stats = {
  eventsPublished = 0,
  eventsProcessed = 0,
  errors = 0
}

-- Subscribe to an event
-- @param eventName string The event name to listen for
-- @param callback function The callback function(eventData)
-- @param options table Optional: { once: boolean, module: string }
-- @return function Unsubscribe function
function EventBus.on(eventName, callback, options)
  if type(eventName) ~= 'string' or type(callback) ~= 'function' then
    error('EventBus.on: Invalid arguments')
  end

  options = options or {}
  
  if not subscribers[eventName] then
    subscribers[eventName] = {}
  end

  local subscriber = {
    callback = callback,
    once = options.once or false,
    module = options.module or 'unknown'
  }
  
  table.insert(subscribers[eventName], subscriber)
  subscriberCount = subscriberCount + 1

  -- Return unsubscribe function
  return function()
    EventBus.off(eventName, callback)
  end
end

-- Subscribe to event only once
function EventBus.once(eventName, callback, options)
  return EventBus.on(eventName, callback, { once = true, module = options and options.module })
end

-- Unsubscribe from an event
-- @param eventName string The event name
-- @param callback function The callback to remove (optional, removes all if nil)
function EventBus.off(eventName, callback)
  if not subscribers[eventName] then
    return
  end

  if callback then
    for i = #subscribers[eventName], 1, -1 do
      if subscribers[eventName][i].callback == callback then
        table.remove(subscribers[eventName], i)
        subscriberCount = subscriberCount - 1
      end
    end
    
    -- Clean up empty event tables
    if #subscribers[eventName] == 0 then
      subscribers[eventName] = nil
    end
  else
    -- Remove all subscribers for this event
    subscriberCount = subscriberCount - #subscribers[eventName]
    subscribers[eventName] = nil
  end
end

-- Publish an event
-- @param eventName string The event name
-- @param eventData any Data to pass to subscribers
-- @param options table Optional: { async: boolean, priority: number }
function EventBus.emit(eventName, eventData, options)
  options = options or {}
  
  stats.eventsPublished = stats.eventsPublished + 1
  
  -- Add to history
  table.insert(eventHistory, {
    name = eventName,
    data = eventData,
    time = hs.timer.absoluteTime()
  })
  if #eventHistory > maxHistorySize then
    table.remove(eventHistory, 1)
  end

  if not subscribers[eventName] then
    return
  end

  local toRemove = {}
  
  for i, subscriber in ipairs(subscribers[eventName]) do
    local ok, err = pcall(subscriber.callback, eventData)
    
    stats.eventsProcessed = stats.eventsProcessed + 1
    
    if not ok then
      stats.errors = stats.errors + 1
      print(string.format('❌ EventBus error in %s for event "%s": %s', 
        subscriber.module, eventName, tostring(err)))
    end
    
    if subscriber.once then
      table.insert(toRemove, i)
    end
  end
  
  -- Remove 'once' subscribers (in reverse order)
  for i = #toRemove, 1, -1 do
    table.remove(subscribers[eventName], toRemove[i])
    subscriberCount = subscriberCount - 1
  end
end

-- Clear all subscribers
function EventBus.clear()
  subscribers = {}
  subscriberCount = 0
  eventHistory = {}
end

-- Get event history
function EventBus.getHistory()
  return eventHistory
end

-- Get statistics
function EventBus.getStats()
  local eventCount = 0
  for k, v in pairs(subscribers) do
    eventCount = eventCount + 1
  end
  
  return {
    published = stats.eventsPublished,
    processed = stats.eventsProcessed,
    errors = stats.errors,
    subscribers = subscriberCount,
    events = eventCount
  }
end

-- Print statistics (only if there's meaningful activity)
function EventBus.printStats()
  local s = EventBus.getStats()

  -- Skip if no meaningful activity
  if s.published == 0 and s.processed == 0 and s.errors == 0 and s.subscribers == 0 and s.events == 0 then
    return
  end

  print('📊 EventBus Statistics:')
  print(string.format('  Events Published: %d', s.published))

  if s.processed > 0 then
    print(string.format('  Events Processed: %d', s.processed))
  end

  if s.errors > 0 then
    print(string.format('  Errors: %d', s.errors))
  end

  if s.subscribers > 0 then
    print(string.format('  Active Subscribers: %d', s.subscribers))
  end

  if s.events > 0 then
    print(string.format('  Event Types: %d', s.events))
  end
end

-- Common event names (constants)
EventBus.EVENTS = {
  -- Application events
  APP_FOCUSED = 'app.focused',
  APP_LAUNCHED = 'app.launched',
  APP_HIDDEN = 'app.hidden',
  
  -- Window events
  WINDOW_FOCUSED = 'window.focused',
  WINDOW_MOVED = 'window.moved',
  WINDOW_RESIZED = 'window.resized',
  WINDOW_CREATED = 'window.created',
  WINDOW_DESTROYED = 'window.destroyed',
  
  -- Input method events
  INPUT_METHOD_CHANGED = 'inputmethod.changed',
  INPUT_METHOD_WILL_CHANGE = 'inputmethod.willChange',
  
  -- System events
  CONFIG_RELOADED = 'config.reloaded',
  SCREEN_CHANGED = 'screen.changed',
  WIFI_CHANGED = 'wifi.changed',
  
  -- Custom events
  CUSTOM = 'custom.'
}

return EventBus
