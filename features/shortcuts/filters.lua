local M = {}

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

M.hasAppBundlePath = hasAppBundlePath
M.containsAutofillText = containsAutofillText
M.isHiddenBundle = isHiddenBundle
M.isHiddenName = isHiddenName
M.hasDisplayableWindow = hasDisplayableWindow
M.hasAnyWindow = hasAnyWindow
M.revealExistingWindows = revealExistingWindows
M.isUserFacingApp = isUserFacingApp
M.currentSpacePidSet = currentSpacePidSet
M.addChoice = addChoice
M.dedupeKnownBundlePairs = dedupeKnownBundlePairs

return M
