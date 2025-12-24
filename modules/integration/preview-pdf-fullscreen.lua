-- **************************************************
-- Auto fullscreen when opening PDF files in Preview
-- **************************************************

-- Get utility functions
local Utils = require('modules.utils.functions')

-- Preview app name (compatible with Chinese and English systems)
local PREVIEW_APP = "预览"
local PREVIEW_APP_EN = "Preview"
local PREVIEW_BUNDLE_ID = "com.apple.Preview"

-- Check if window title indicates a PDF file
local function isPDFWindow(window)
  if not window then return false end
  local title = window:title()
  if not title then return false end

  -- Check suffix or contains pdf keyword
  local lowerTitle = string.lower(title)
  local isPdf = string.find(lowerTitle, "%.pdf$") ~= nil or string.find(lowerTitle, "pdf") ~= nil
  return isPdf
end

-- Set window to fullscreen
local function setFullscreen(window)
  if not window then return end
  -- Delay execution to ensure window is fully loaded
  hs.timer.doAfter(0.5, function()
    pcall(function() window:setFullScreen(true) end)
  end)
end

-- Check if it's Preview app
local function isPreviewApp(appName, bundleID)
  return (appName == PREVIEW_APP or appName == PREVIEW_APP_EN) or bundleID == PREVIEW_BUNDLE_ID
end

local wf = nil

local function start()
  -- Use hs.window.filter to subscribe to window events
  -- Optimization: Only listen to Preview app, avoid scanning all windows
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