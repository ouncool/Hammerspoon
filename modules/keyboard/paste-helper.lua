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
  log.info('Initializing paste helper')
  return true
end

local function start()
  log.info('Starting paste helper')
  return true
end

local function stop()
  log.info('Stopping paste helper')
  if hotkey then
    hotkey:delete()
    hotkey = nil
  end
end

local function cleanup()
  log.info('Cleaning up paste helper')
  stop()
end

-- Export module
return {
  init = init,
  start = start,
  stop = stop,
  cleanup = cleanup
}
