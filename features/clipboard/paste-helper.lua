local M = {}

local ctx = nil
local log = nil

local function forcePaste()
  local text = hs.pasteboard.getContents()
  if not text or text == '' then
    hs.alert.show('Clipboard is empty')
    return
  end

  hs.eventtap.keyStrokes(text)
  log.debug('Pasted clipboard text using synthetic keystrokes')
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('PasteHelper')
  return true
end

function M.start()
  local spec = ctx.config.hotkeys.pasteHelper
  ctx.hotkeys.bind({
    id = 'clipboard.force-paste',
    group = 'clipboard',
    mods = spec.mods,
    key = spec.key,
    desc = 'Force paste clipboard text',
    action = forcePaste,
  })
  return true
end

function M.stop()
  ctx.hotkeys.unbindGroup('clipboard')
  return true
end

function M.dispose()
  ctx = nil
  log = nil
end

return M
