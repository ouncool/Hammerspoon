local AppDiscovery = require('infra.app-discovery')
local FinderActions = require('features.integration.finder-actions')

local M = {}

local ctx = nil
local log = nil

local function emit(name, payload)
  ctx.events.emit(ctx.events.NAMES.CUSTOM_PREFIX .. name, payload)
end

local function showError(message)
  hs.alert.show(message)
  log.warn(message)
end

local function openBrowser()
  local app = AppDiscovery.openFirstAvailable(ctx.config.apps.browsers)
  if not app then
    showError('No browser app found')
    return
  end

  log.info('Opened browser', {app = app})
  emit('browser.opened', {app = app})
end

local function openTerminal()
  local app = AppDiscovery.openFirstAvailable(ctx.config.apps.terminals)
  if not app then
    showError('No terminal app found')
    return
  end

  log.info('Opened terminal', {app = app})
  emit('terminal.opened', {app = app})
end

local function openFinderInTerminal()
  local ok, err = FinderActions.openInTerminal()
  if not ok then
    showError(err)
  end
end

local function openFinderInEditor()
  local ok, err = FinderActions.openInEditor()
  if not ok then
    showError(err)
  end
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('HyperShortcuts')
  return true
end

function M.start()
  local mods = ctx.config.hotkeys.hyperMods
  local keys = ctx.config.hotkeys.hyper

  ctx.hotkeys.bind({
    id = 'hyper.browser',
    group = 'hyper',
    mods = mods,
    key = keys.browser,
    desc = 'Open browser',
    action = openBrowser,
  })

  ctx.hotkeys.bind({
    id = 'hyper.terminal',
    group = 'hyper',
    mods = mods,
    key = keys.terminal,
    desc = 'Open terminal',
    action = openTerminal,
  })

  ctx.hotkeys.bind({
    id = 'hyper.finder.terminal',
    group = 'hyper',
    mods = mods,
    key = keys.finderTerminal,
    desc = 'Open Finder path in terminal',
    action = openFinderInTerminal,
  })

  ctx.hotkeys.bind({
    id = 'hyper.finder.editor',
    group = 'hyper',
    mods = mods,
    key = keys.finderEditor,
    desc = 'Open Finder path in editor',
    action = openFinderInEditor,
  })

  return true
end

function M.stop()
  ctx.hotkeys.unbindGroup('hyper')
  return true
end

function M.dispose()
  ctx = nil
  log = nil
end

return M
