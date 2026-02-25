local M = {}

local Filters = require('features.shortcuts.filters')
local UI = require('features.shortcuts.ui')

local ctx = nil
local log = nil
local previousApp = nil

local function appChoices()
  local choices = {}
  local seen = {}
  local scope = ctx.config.appSwitcher.scope
  local onlyCurrentSpace = scope == 'currentSpace'
  local currentSpacePids = onlyCurrentSpace and Filters.currentSpacePidSet() or {}
  local includeNoWindow = {}
  for _, bundleId in ipairs(ctx.config.appSwitcher.includeNoWindowBundleIds or {}) do
    includeNoWindow[bundleId] = true
  end

  local frontmost = hs.application.frontmostApplication()
  if Filters.isUserFacingApp(frontmost, true) then
    Filters.addChoice(choices, seen, frontmost)
  end

  local othersByPid = {}
  local function collectOther(app, allowNoWindow)
    if not app or not Filters.isUserFacingApp(app, allowNoWindow == true) then
      return
    end

    local pid = app:pid()
    if seen[pid] or othersByPid[pid] then
      return
    end

    if onlyCurrentSpace and not currentSpacePids[pid] then
      return
    end

    othersByPid[pid] = app
  end

  -- First pass: apps that currently have visible windows.
  local filterConfig = {visible = true}
  if onlyCurrentSpace then
    filterConfig.currentSpace = true
  end

  local windowFilter = hs.window.filter.new():setDefaultFilter(filterConfig)
  local windows = windowFilter:getWindows()

  for _, win in ipairs(windows) do
    local app = win:application()
    collectOther(app, false)
  end

  -- Second pass: include running user-facing apps even if no active window.
  -- This keeps apps like WeChat discoverable when all windows are closed/minimized.
  if not onlyCurrentSpace then
    for _, app in ipairs(hs.application.runningApplications() or {}) do
      local bundleId = app and app:bundleID() or ''
      if bundleId and includeNoWindow[bundleId] then
        collectOther(app, true)
      end
    end
  end

  local others = {}
  for _, app in pairs(othersByPid) do
    table.insert(others, app)
  end

  table.sort(others, function(a, b)
    return string.lower(a:name() or '') < string.lower(b:name() or '')
  end)

  for _, app in ipairs(others) do
    Filters.addChoice(choices, seen, app)
  end

  return Filters.dedupeKnownBundlePairs(choices)
end

local function trySelectMenuItem(app, path)
  if not app or type(path) ~= 'table' then
    return false
  end

  local ok, result = pcall(function()
    return app:selectMenuItem(path)
  end)

  return ok and result == true
end

local function tryOpenNewWindow(app)
  if not app then
    return false, 'none'
  end

  local bundleId = app:bundleID() or ''
  local menuCandidates = {}

  if bundleId == 'com.apple.finder' then
    table.insert(menuCandidates, {'File', 'New Finder Window'})
    table.insert(menuCandidates, {'文件', '新建Finder窗口'})
    table.insert(menuCandidates, {'文件', '新建 Finder 窗口'})
  end

  table.insert(menuCandidates, {'File', 'New Window'})
  table.insert(menuCandidates, {'Window', 'New Window'})
  table.insert(menuCandidates, {'文件', '新建窗口'})
  table.insert(menuCandidates, {'窗口', '新建窗口'})

  if bundleId == 'com.tencent.xinWeChat' then
    table.insert(menuCandidates, {'Window', 'Bring All to Front'})
    table.insert(menuCandidates, {'窗口', '前置全部窗口'})
    table.insert(menuCandidates, {'窗口', '显示主窗口'})
  end

  for _, path in ipairs(menuCandidates) do
    if trySelectMenuItem(app, path) then
      return true, 'menu'
    end
  end

  local ok = pcall(function()
    hs.eventtap.keyStroke({'cmd'}, 'n', 0, app)
  end)

  if ok then
    return true, 'keystroke'
  end

  local okGlobal = pcall(function()
    hs.eventtap.keyStroke({'cmd'}, 'n', 0)
  end)
  if okGlobal then
    return true, 'keystroke-global'
  end

  return false, 'none'
end

local function tryReopenApp(app)
  if not app then
    return false
  end

  local bundleId = app:bundleID()
  if type(bundleId) ~= 'string' or bundleId == '' then
    return false
  end

  local escapedBundleId = bundleId:gsub('\\', '\\\\'):gsub('"', '\\"')
  local script = string.format([[
    tell application id "%s"
      reopen
      activate
    end tell
  ]], escapedBundleId)

  local ok, _ = hs.osascript.applescript(script)
  return ok == true
end

local function ensureWindowForActivatedApp(app, appName)
  hs.timer.doAfter(0.10, function()
    if Filters.hasDisplayableWindow(app) then
      return
    end

    Filters.revealExistingWindows(app)
    if Filters.hasDisplayableWindow(app) then
      log.info('Restored existing window for switched app', {app = appName})
      return
    end

    if not Filters.hasAnyWindow(app) and tryReopenApp(app) then
      hs.timer.doAfter(0.12, function()
        if Filters.hasDisplayableWindow(app) then
          log.info('Reopened app window after switch', {app = appName, method = 'reopen'})
          return
        end

        local opened, method = tryOpenNewWindow(app)
        if opened then
          log.info('Opened window for switched app', {app = appName, method = method})
        else
          log.debug('No window opened for switched app', {app = appName})
        end
      end)
      return
    end

    local opened, method = tryOpenNewWindow(app)
    if opened then
      log.info('Opened window for switched app', {app = appName, method = method})
    else
      log.debug('No window opened for switched app', {app = appName})
    end
  end)
end

local function onChoose(choice)
  if not choice or not choice.app then
    return
  end

  local fromApp = previousApp and previousApp:name() or 'Unknown'
  local toApp = choice.app:name()

  choice.app:activate()
  ensureWindowForActivatedApp(choice.app, toApp)

  ctx.events.emit(ctx.events.NAMES.APP_SWITCHED, {
    fromApp = fromApp,
    toApp = toApp,
  })

  log.info('Switched application', {from = fromApp, to = toApp})
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('AppSwitcher')
  UI.init(ctx, log)
  return true
end

local function showSwitcher()
  UI.showSwitcher(appChoices, onChoose)
end

function M.start()
  local cfg = ctx.config.hotkeys.appSwitcher

  ctx.hotkeys.bind({
    id = 'switcher.next',
    group = 'switcher',
    mods = cfg.next.mods,
    key = cfg.next.key,
    desc = 'Show app switcher',
    action = showSwitcher,
  })

  ctx.hotkeys.bind({
    id = 'switcher.previous',
    group = 'switcher',
    mods = cfg.previous.mods,
    key = cfg.previous.key,
    desc = 'Show app switcher (reverse)',
    action = showSwitcher,
  })

  log.info('App switcher started')
  return true
end

function M.stop()
  ctx.hotkeys.unbindGroup('switcher')
  UI.stopChooser()
  previousApp = nil
  return true
end

function M.dispose()
  M.stop()
  ctx = nil
  log = nil
end

return M
