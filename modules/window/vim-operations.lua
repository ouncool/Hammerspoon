-- **************************************************
-- Vim 风格窗口操作逻辑
-- 提供各种窗口布局调整功能
-- **************************************************

local config = nil
pcall(function() config = require('modules.utils.config') end)

-- 安全获取当前焦点窗口
local function safeFocusWindow()
  local win = hs.window.frontmostWindow()
  if not win then
    hs.alert.show('没有焦点窗口')
    return nil
  end
  return win
end

-- 设置窗口框架
local function setFrame(win, rect)
  if not win then return end
  win:setFrame(rect)
end

-- 窗口操作函数
local operations = {
  -- 半屏操作
  halfLeft = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h })
  end,

  halfRight = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h })
  end,

  halfTop = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w, h = screen.h / 2 })
  end,

  halfBottom = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w, h = screen.h / 2 })
  end,

  -- 四分之一屏操作
  quarterLT = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h / 2 })
  end,

  quarterLB = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2 })
  end,

  quarterRT = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h / 2 })
  end,

  quarterRB = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    setFrame(win, { x = screen.x + screen.w / 2, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2 })
  end,

  -- 2/3屏操作
  twoThirdLeft = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    local ratio = (config and config.window and config.window.twoThirdRatio) or (2/3)
    setFrame(win, { x = screen.x, y = screen.y, w = screen.w * ratio, h = screen.h })
  end,

  twoThirdRight = function()
    local win = safeFocusWindow()
    if not win then return end
    local screen = win:screen():frame()
    local ratio = (config and config.window and config.window.twoThirdRatio) or (2/3)
    setFrame(win, { x = screen.x + screen.w * (1 - ratio), y = screen.y, w = screen.w * ratio, h = screen.h })
  end,

  -- 其他操作
  maximize = function()
    local win = safeFocusWindow()
    if win then win:maximize() end
  end,

  close = function()
    local win = safeFocusWindow()
    if win then win:close() end
  end
}

-- 帮助信息
local helpMessage = [[
窗口管理（按 q 或 Esc 退出）

h: 左半屏    l: 右半屏
j: 下半屏    k: 上半屏
y: 左上四分  u: 左下四分
i: 右上四分  o: 右下四分
H: 左三分之二  L: 右三分之二
f: 最大化    c: 关闭窗口
tab: 显示帮助
]]

-- 返回操作模块
return {
  operations = operations,
  helpMessage = helpMessage,
  safeFocusWindow = safeFocusWindow
}