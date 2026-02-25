-- Clipboard utilities and operations
local M = {}

local ctx = nil
local log = nil

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('ClipboardOps')
  return true
end

-- Force paste from clipboard
function M.forcePaste()
  local text = hs.pasteboard.getContents()
  if not text or text == '' then
    hs.alert.show('Clipboard is empty')
    log.warn('Force paste: clipboard empty')
    return
  end

  hs.eventtap.keyStrokes(text)
  log.info('Force pasted clipboard text')
end

function M.stop()
  return true
end

function M.dispose()
  ctx = nil
  log = nil
end

return M
