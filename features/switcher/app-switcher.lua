local M = {}

local ctx = nil
local log = nil
local chooser = nil
local previousApp = nil

local HIDDEN_BUNDLE_PREFIXES = {
  'com.apple.WebKit.',
  'com.apple.appkit.xpc.',
  'com.apple.quicklook.',
  'com.apple.TextInputUI.xpc.',
}

local HIDDEN_BUNDLE_IDS = {
  ['com.apple.AirPlayUIAgent'] = true,
}

local HIDDEN_NAME_PATTERNS = {
  'Web Content',
  'Networking',
  'Graphics and Media',
  'Open and Save Panel Service',
  'QuickLookUIService',
  'CursorUIViewService',
}

local HIDDEN_NAME_CONTAINS_LOWER = {
  'service',
  'agent',
  'helper',
  'daemon',
  'eventmonitor',
  'xpc',
}

local HIDDEN_BUNDLE_CONTAINS = {
  '.xpc.',
}

local function hasAppBundlePath(appPath)
  if type(appPath) ~= 'string' or appPath == '' then
    return false
  end
  if string.find(appPath, '.app/', 1, true) then
    return true
  end
  if string.match(appPath, '%.app$') then
    return true
  end
  return false
end

local function containsAutofillText(text)
  if not text or text == '' then
    return false
  end

  local lower = string.lower(text)
  if string.find(lower, 'autofill', 1, true) then
    return true
  end
  if string.find(lower, 'auto fill', 1, true) then
    return true
  end
  if string.find(lower, '自动填充', 1, true) then
    return true
  end

  return false
end

local function chooseColor(object, methodName, value)
  local method = object[methodName]
  if type(method) == 'function' and type(value) == 'table' then
    object[methodName](object, value)
  end
end

local function callChooserMethod(object, methodName, ...)
  if not object then
    return false
  end
  local method = object[methodName]
  if type(method) ~= 'function' then
    return false
  end
  method(object, ...)
  return true
end

local function setChooserRows(object, rows)
  if type(rows) ~= 'number' then
    return false
  end

  if type(object.numRows) == 'function' then
    object:numRows(rows)
    return true
  end

  if type(object.rows) == 'function' then
    object:rows(rows)
    return true
  end

  return false
end

local function isHiddenBundle(bundleId)
  if not bundleId or bundleId == '' then
    return false
  end

  local lower = string.lower(bundleId)

  if containsAutofillText(bundleId) then
    return true
  end

  for _, marker in ipairs(HIDDEN_BUNDLE_CONTAINS) do
    if string.find(lower, marker, 1, true) then
      return true
    end
  end

  if HIDDEN_BUNDLE_IDS[bundleId] then
    return true
  end

  for _, prefix in ipairs(HIDDEN_BUNDLE_PREFIXES) do
    if string.find(bundleId, prefix, 1, true) == 1 then
      return true
    end
  end

  return false
end

local function isHiddenName(appName)
  if not appName or appName == '' then
    return true
  end

  local lower = string.lower(appName)

  if containsAutofillText(appName) then
    return true
  end

  for _, marker in ipairs(HIDDEN_NAME_CONTAINS_LOWER) do
    if string.find(lower, marker, 1, true) then
      return true
    end
  end

  if string.match(lower, '^[a-z0-9_%-]+d$') and not string.find(lower, ' ', 1, true) then
    return true
  end

  for _, pattern in ipairs(HIDDEN_NAME_PATTERNS) do
    if string.find(appName, pattern, 1, true) then
      return true
    end
  end

  return false
end

local function hasDisplayableWindow(app)
  local okWindows, windows = pcall(function()
    return app:allWindows() or {}
  end)
  if not okWindows or not windows then
    return false
  end

  for _, win in ipairs(windows) do
    local okVisible, visible = pcall(function()
      return win:isVisible()
    end)
    local okStandard, standard = pcall(function()
      return win:isStandard()
    end)
    if okVisible and visible then
      if okStandard then
        if standard then
          return true
        end
      else
        return true
      end
    end
  end

  return false
end

local function hasAnyWindow(app)
  local okWindows, windows = pcall(function()
    return app:allWindows() or {}
  end)
  return okWindows and windows and #windows > 0
end

local function revealExistingWindows(app)
  local okWindows, windows = pcall(function()
    return app:allWindows() or {}
  end)
  if not okWindows or not windows then
    return false
  end

  local touched = false
  for _, win in ipairs(windows) do
    local okStandard, standard = pcall(function()
      return win:isStandard()
    end)
    if okStandard and standard then
      touched = true
      local okMinimized, minimized = pcall(function()
        return win:isMinimized()
      end)
      if okMinimized and minimized then
        pcall(function()
          win:unminimize()
        end)
      end
      pcall(function()
        win:focus()
      end)
    end
  end

  return touched
end

local function isUserFacingApp(app, allowNoWindow)
  if not app then
    return false
  end

  local appName = app:name()
  if isHiddenName(appName) then
    return false
  end

  local bundleId = app:bundleID() or ''
  local appPath = app:path() or ''

  if not hasAppBundlePath(appPath) then
    return false
  end

  if bundleId == 'org.hammerspoon.Hammerspoon' then
    return false
  end

  if isHiddenBundle(bundleId) then
    return false
  end

  local okPolicy, policy = pcall(function()
    return app:activationPolicy()
  end)

  -- policy == 0: regular app. Keep others out of switcher list.
  if okPolicy and policy ~= nil and policy ~= 0 then
    return false
  end

  if allowNoWindow then
    return true
  end

  if not hasDisplayableWindow(app) then
    return false
  end

  return true
end

local function currentSpacePidSet()
  local result = {}
  local wf = hs.window.filter.new():setDefaultFilter({
    visible = true,
    currentSpace = true,
  })

  for _, win in ipairs(wf:getWindows()) do
    local app = win:application()
    if app then
      result[app:pid()] = true
    end
  end

  return result
end

local function addChoice(choices, seen, app)
  if not app then
    return
  end

  local pid = app:pid()
  if seen[pid] then
    return
  end

  local bundleId = app:bundleID()
  local icon = nil

  if type(bundleId) == 'string' and bundleId ~= '' then
    local okImage, image = pcall(hs.image.imageFromAppBundle, bundleId)
    if okImage then
      icon = image
    end
  end

  if not icon then
    local okIcon, appIcon = pcall(function()
      return app:icon()
    end)
    if okIcon then
      icon = appIcon
    end
  end

  table.insert(choices, {
    text = app:name() or 'Unknown',
    subText = (type(bundleId) == 'string' and bundleId) or '',
    bundleId = (type(bundleId) == 'string' and bundleId) or '',
    image = icon,
    app = app,
  })
  seen[pid] = true
end

local function dedupeKnownBundlePairs(choices)
  local hasWeChatAppEx = false
  for _, item in ipairs(choices) do
    if item.bundleId == 'com.tencent.flue.WeChatAppEx' then
      hasWeChatAppEx = true
      break
    end
  end

  if not hasWeChatAppEx then
    return choices
  end

  local filtered = {}
  for _, item in ipairs(choices) do
    if item.bundleId ~= 'com.tencent.xinWeChat' then
      table.insert(filtered, item)
    end
  end

  return filtered
end

local function appChoices()
  local choices = {}
  local seen = {}
  local scope = ctx.config.appSwitcher.scope
  local onlyCurrentSpace = scope == 'currentSpace'
  local currentSpacePids = onlyCurrentSpace and currentSpacePidSet() or {}
  local includeNoWindow = {}
  for _, bundleId in ipairs(ctx.config.appSwitcher.includeNoWindowBundleIds or {}) do
    includeNoWindow[bundleId] = true
  end

  local frontmost = hs.application.frontmostApplication()
  if isUserFacingApp(frontmost, true) then
    addChoice(choices, seen, frontmost)
  end

  local othersByPid = {}
  local function collectOther(app, allowNoWindow)
    if not app or not isUserFacingApp(app, allowNoWindow == true) then
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
    addChoice(choices, seen, app)
  end

  return dedupeKnownBundlePairs(choices)
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
    if hasDisplayableWindow(app) then
      return
    end

    revealExistingWindows(app)
    if hasDisplayableWindow(app) then
      log.info('Restored existing window for switched app', {app = appName})
      return
    end

    if not hasAnyWindow(app) and tryReopenApp(app) then
      hs.timer.doAfter(0.12, function()
        if hasDisplayableWindow(app) then
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

local function ensureChooser()
  if chooser then
    return chooser
  end

  chooser = hs.chooser.new(onChoose)

  local cfg = ctx.config.appSwitcher
  chooseColor(chooser, 'bgColor', cfg.bgColor)
  chooseColor(chooser, 'fgColor', cfg.textColor)
  chooseColor(chooser, 'textColor', cfg.textColor)
  chooseColor(chooser, 'subTextColor', cfg.subTextColor)

  callChooserMethod(chooser, 'searchSubText', false)

  local width = cfg.width
  if type(width) ~= 'number' then
    width = 40
  end

  -- hs.chooser:width expects percentage (e.g. 40), but config may use ratio (0.4).
  if width > 0 and width <= 1 then
    width = width * 100
  end

  if width < 30 then
    width = 30
  elseif width > 80 then
    width = 80
  end
  callChooserMethod(chooser, 'width', width)

  setChooserRows(chooser, cfg.numRows)
  callChooserMethod(chooser, 'font', {name = 'System', size = cfg.textSize})
  callChooserMethod(chooser, 'subTextFont', {name = 'System', size = cfg.subTextSize})

  callChooserMethod(chooser, 'shadow', cfg.shadow)

  if cfg.radius then
    callChooserMethod(chooser, 'radius', cfg.radius)
  end

  return chooser
end

local function showSwitcher()
  previousApp = hs.application.frontmostApplication()

  local choices = appChoices()
  if #choices == 0 then
    hs.alert.show('No switchable apps')
    return
  end

  local c = ensureChooser()
  local cfgRows = ctx.config.appSwitcher.numRows or 8
  local rows = math.max(3, math.min(cfgRows, #choices))
  setChooserRows(c, rows)
  c:choices(choices)
  c:show()

  log.debug('App switcher shown', {choices = #choices, rows = rows, scope = ctx.config.appSwitcher.scope})
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('AppSwitcher')
  return true
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

  if chooser then
    chooser:delete()
    chooser = nil
  end

  previousApp = nil
  return true
end

function M.dispose()
  M.stop()
  ctx = nil
  log = nil
end

return M
