-- **************************************************
-- 基于 vim 风格的简单窗口管理器
-- 前缀键：Option + R 进入管理模式
-- 模式键位：
--   h / l / j / k : 左/右/下/上 半屏
--   y / u / i / o : 左上/左下/右上/右下 四分之一
--   f : 最大化
--   c : 关闭窗口
--   tab : 显示帮助
--   q / esc : 退出管理模式
-- **************************************************

local modal = hs.hotkey.modal.new({'alt'}, 'r')

local function safeFocusWindow()
  local win = hs.window.frontmostWindow()
  if not win then
    hs.alert.show('没有焦点窗口')
    return nil
  end
  return win
end

local function setFrame(win, rect)
  if not win then return end
  win:setFrame(rect)
end

local function halfLeft()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h })
end

local function halfRight()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h })
end

local function halfTop()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x, y = screen.y, w = screen.w, h = screen.h / 2 })
end

local function halfBottom()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w, h = screen.h / 2 })
end

local function quarterLT()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x, y = screen.y, w = screen.w / 2, h = screen.h / 2 })
end

local function quarterLB()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2 })
end

local function quarterRT()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x + screen.w / 2, y = screen.y, w = screen.w / 2, h = screen.h / 2 })
end

local function quarterRB()
  local win = safeFocusWindow()
  if not win then return end
  local screen = win:screen():frame()
  setFrame(win, { x = screen.x + screen.w / 2, y = screen.y + screen.h / 2, w = screen.w / 2, h = screen.h / 2 })
end

local helpMessage = [[
窗口管理（按 q 或 Esc 退出）

h: 左半屏    l: 右半屏
j: 下半屏    k: 上半屏
y: 左上四分  u: 左下四分
i: 右上四分  o: 右下四分
f: 最大化    c: 关闭窗口
tab: 显示帮助
]]

local helpTimer = nil

local function showHelp()
  if helpTimer then helpTimer:stop() helpTimer = nil end
  hs.alert.show(helpMessage, 5)
  -- 也可以使用更复杂的 canvas 来显示帮助
end

-- 进入模式时提示
function modal:entered()
  hs.alert.show('窗口管理模式', 1)
end

function modal:exited()
  hs.alert.show('退出窗口管理', 1)
end

-- 绑定按键
modal:bind('', 'h', halfLeft)
modal:bind('', 'l', halfRight)
modal:bind('', 'j', halfBottom)
modal:bind('', 'k', halfTop)

modal:bind('', 'y', quarterLT)
modal:bind('', 'u', quarterLB)
modal:bind('', 'i', quarterRT)
modal:bind('', 'o', quarterRB)

modal:bind('', 'f', function()
  local win = safeFocusWindow()
  if win then win:maximize() end
end)

modal:bind('', 'c', function()
  local win = safeFocusWindow()
  if win then win:close() end
end)

modal:bind('', 'tab', function()
  showHelp()
end)

modal:bind('', 'q', function() modal:exit() end)
modal:bind('', 'escape', function() modal:exit() end)

-- 如果需要在进入时高亮当前窗口或显示帮助，可在 entered 中实现

-- 导出为空模块（按 require 即可注册）
return {}
