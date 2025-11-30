-- **************************************************
-- 预览程序打开PDF文件时自动全屏
-- **************************************************

-- 获取工具函数
local Utils = require('modules.utils.functions')

-- 预览程序应用名称（中英文系统兼容）
local PREVIEW_APP = "预览"
local PREVIEW_APP_EN = "Preview"
local PREVIEW_BUNDLE_ID = "com.apple.Preview"

-- 检查窗口标题是否表示PDF文件
local function isPDFWindow(window)
  if not window then return false end
  local title = window:title()
  if not title then return false end

  -- 检查后辍或包含pdf关键词
  local lowerTitle = string.lower(title)
  local isPdf = string.find(lowerTitle, "%.pdf$") ~= nil or string.find(lowerTitle, "pdf") ~= nil
  return isPdf
end

-- 将窗口设置为全屏
local function setFullscreen(window)
  if not window then return end
  -- 延迟执行，确保窗口完全加载
  hs.timer.doAfter(0.5, function()
    pcall(function() window:setFullScreen(true) end)
  end)
end

-- 检查是否为预览程序
local function isPreviewApp(appName, bundleID)
  return (appName == PREVIEW_APP or appName == PREVIEW_APP_EN) or bundleID == PREVIEW_BUNDLE_ID
end

local wf = nil

local function start()
  -- 使用 hs.window.filter 订阅窗口事件
  -- 优化：只监听预览程序，避免扫描所有窗口
  local ok_wf, filter = pcall(function() 
    return hs.window.filter.new({PREVIEW_APP, PREVIEW_APP_EN}) 
  end)

  if ok_wf and filter then
    wf = filter
    local debouncedHandle = Utils.debounce(function(win)
      if not win then return end
      -- double check app name just in case
      local app = win:application()
      if not app then return end
      
      if isPreviewApp(app:name(), app:bundleID()) and isPDFWindow(win) and not win:isFullScreen() then
        setFullscreen(win)
      end
    end, 0.2)

    wf:subscribe(hs.window.filter.windowCreated, function(win, appName) debouncedHandle(win) end)
    wf:subscribe(hs.window.filter.windowFocused, function(win, appName) debouncedHandle(win) end)
    wf:subscribe(hs.window.filter.windowTitleChanged, function(win, appName) debouncedHandle(win) end)
  else
    hs.printf("❌ preview-pdf-fullscreen: Failed to create window filter")
  end
end

return { start = start }