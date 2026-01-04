-- **************************************************
-- Some websites prohibit pasting, this script simulates system input events to bypass restrictions
-- **************************************************

local Logger = require('modules.core.logger')
local log = Logger.new('PasteHelper')

-- Paste function
local function paste()
  local contents = hs.pasteboard.getContents()
  hs.eventtap.keyStrokes(contents)
  log.debug('Pasted content from clipboard')
end

-- Bind hotkey
local hotkey = hs.hotkey.bind({ 'cmd', 'shift' }, 'v', paste)

-- Lifecycle functions
local function init()
  log.debug('Initializing paste helper')
  return true
end

local function start()
  log.debug('Starting paste helper')
  return true
end

local function stop()
  log.debug('Stopping paste helper')
  if hotkey then
    hotkey:delete()
    hotkey = nil
  end
end

local function cleanup()
  log.debug('Cleaning up paste helper')
  stop()
end

-- Export module
return {
  init = init,
  start = start,
  stop = stop,
  cleanup = cleanup
}
