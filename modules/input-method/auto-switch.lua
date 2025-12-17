-- **************************************************
-- 输入法自动切换：根据应用自动切换输入法
-- **************************************************
-- 默认使用搜狗拼音，指定应用使用英文输入法
-- **************************************************

local utils = require('modules.utils.functions')

-- --------------------------------------------------
-- 配置区域
-- --------------------------------------------------

-- 默认输入法（搜狗拼音）
local DEFAULT_IME = 'com.sogou.inputmethod.sogou.pinyin'

-- 英文输入法
local ABC = 'com.apple.keylayout.ABC'

-- 需要使用英文输入法的应用列表
local ENGLISH_APPS = {
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

-- 将应用列表转换为快速查找表
local function updateFocusedAppInputMethod(appObject)
  if not appObject then
    return
  end

  local focusedAppPath = appObject:path() or ''
  local focusedBundleID = appObject:bundleID() or ''
  local focusedName = appObject:name() or ''

  -- 支持用路径、bundleID 或 应用名来匹配；增加大小写不敏感的子串匹配，提升对类似 Raycast 这种启动行为的覆盖。
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

  -- 如果出现 Raycast 但未匹配到，输出调试信息便于定位 bundleID/路径/名称
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

-- 防抖处理，避免频繁切换
local debouncedUpdateFn = utils.debounce(updateFocusedAppInputMethod, 0.1)

-- 监听应用切换事件
local appWatcher = hs.application.watcher.new(
  function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
      debouncedUpdateFn(appObject)
    end
  end
)
appWatcher:start()

print("Input Method Auto Switch loaded:")
print("  - Default: 搜狗拼音")
print("  - English apps: " .. #ENGLISH_APPS .. " configured")

return { watcher = appWatcher }
