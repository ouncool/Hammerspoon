-- **************************************************
-- Input method auto-switch: Automatically switch input method based on app
-- **************************************************
-- Default to Sogou Pinyin, use English for specified apps
-- **************************************************

local utils = require('modules.utils.functions')
local config = require('modules.utils.config')

-- --------------------------------------------------
-- Configuration Area
-- --------------------------------------------------

-- Default input method (Sogou Pinyin)
local DEFAULT_IME = config.inputMethod and config.inputMethod.default or 'com.sogou.inputmethod.sogou.pinyin'

-- English input method
local ABC = config.inputMethod and config.inputMethod.english or 'com.apple.keylayout.ABC'

-- Apps that need English input method
local ENGLISH_APPS = config.inputMethod and config.inputMethod.englishApps or {
  '/Applications/Terminal.app',
  '/Applications/Ghostty.app',
  '/Applications/iTerm.app',
  '/Applications/Visual Studio Code.app',
  '/Applications/WebStorm.app',
  '/Applications/Raycast.app'
--   '/Applications/Google Chrome.app',
--  '/Applications/Brave Browser.app',
}

-- --------------------------------------------------
-- 实现
-- --------------------------------------------------

-- Convert application list to fast lookup table
local function updateFocusedAppInputMethod(appObject)
  if not appObject then
    return
  end

  local focusedAppPath = appObject:path() or ''
  local focusedBundleID = appObject:bundleID() or ''
  local focusedName = appObject:name() or ''

  -- Support matching by path, bundleID, or app name; add case-insensitive substring matching to improve coverage for apps like Raycast
  local function contains(hay, needle)
    if not hay or not needle then
      return false
    end
    return string.find(string.lower(hay), string.lower(needle), 1, true) ~= nil
  end

  local isEnglish = false
  for _, id in ipairs(ENGLISH_APPS) do
    if id == focusedAppPath or id == focusedBundleID or id == focusedName
       or contains(focusedAppPath, id) or contains(focusedBundleID, id) or contains(focusedName, id) then
      isEnglish = true
      break
    end
  end

  -- If Raycast is detected but not matched, output debug info to locate bundleID/path/name
  if (contains(focusedAppPath, 'raycast') or contains(focusedBundleID, 'raycast') or contains(focusedName, 'raycast')) and not isEnglish then
    print("[InputMethod] Raycast detected but not matched. Details:")
    print("  path=", focusedAppPath)
    print("  bundle=", focusedBundleID)
    print("  name=", focusedName)
  end

  if isEnglish then
    hs.keycodes.currentSourceID(ABC)
  else
    hs.keycodes.currentSourceID(DEFAULT_IME)
  end
end

-- Debounce processing to avoid frequent switching
local debouncedUpdateFn = utils.debounce(updateFocusedAppInputMethod, 0.1)

-- Listen to application switch events
local appWatcher = hs.application.watcher.new(
  function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
      debouncedUpdateFn(appObject)
    end
  end
)
appWatcher:start()

print("Input Method Auto Switch loaded:")
print("  - Default: Sogou Pinyin")
print("  - English apps: " .. #ENGLISH_APPS .. " configured")

return { watcher = appWatcher }
