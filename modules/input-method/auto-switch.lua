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
  '/Applications/Google Chrome.app',
  '/Applications/Brave Browser.app',
}

-- --------------------------------------------------
-- 实现
-- --------------------------------------------------

-- 将应用列表转换为快速查找表
local englishAppSet = {}
for _, appPath in ipairs(ENGLISH_APPS) do
  englishAppSet[appPath] = true
end

local function updateFocusedAppInputMethod(appObject)
  local focusedAppPath = appObject:path()

  -- 检查是否在英文应用列表中
  if englishAppSet[focusedAppPath] then
    hs.keycodes.currentSourceID(ABC)
  else
    -- 其他应用使用默认输入法（搜狗拼音）
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
