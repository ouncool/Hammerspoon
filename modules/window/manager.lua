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

local vimOps = require('modules.window.vim-operations')

-- 创建窗口管理模式
local windowModal = hs.hotkey.modal.new({'alt'}, 'r')

-- 帮助显示定时器
local helpTimer = nil

-- 显示帮助信息
local function showHelp()
  if helpTimer then helpTimer:stop() helpTimer = nil end
  hs.alert.show(vimOps.helpMessage, 5)
end

-- 进入模式时提示
function windowModal:entered()
  hs.alert.show('窗口管理模式', 1)
end

function windowModal:exited()
  hs.alert.show('退出窗口管理', 1)
end

-- 绑定窗口操作按键
windowModal:bind('', 'h', vimOps.operations.halfLeft)
windowModal:bind('', 'l', vimOps.operations.halfRight)
windowModal:bind('', 'j', vimOps.operations.halfBottom)
windowModal:bind('', 'k', vimOps.operations.halfTop)

windowModal:bind('', 'y', vimOps.operations.quarterLT)
windowModal:bind('', 'u', vimOps.operations.quarterLB)
windowModal:bind('', 'i', vimOps.operations.quarterRT)
windowModal:bind('', 'o', vimOps.operations.quarterRB)

-- 左右 2/3 绑定（使用大写 H / L）
windowModal:bind('', 'H', vimOps.operations.twoThirdLeft)
windowModal:bind('', 'L', vimOps.operations.twoThirdRight)

windowModal:bind('', 'f', vimOps.operations.maximize)
windowModal:bind('', 'c', vimOps.operations.close)

windowModal:bind('', 'tab', showHelp)
windowModal:bind('', 'q', function() windowModal:exit() end)
windowModal:bind('', 'escape', function() windowModal:exit() end)

-- 创建命令模式（预留，暂不实现）
local commandModal = hs.hotkey.modal.new({'alt'}, 'v')

function commandModal:entered()
  hs.alert.show('命令模式（暂未实现）', 1)
  -- 立即退出，因为暂未实现
  hs.timer.doAfter(1, function()
    commandModal:exit()
  end)
end

function commandModal:exited()
  hs.alert.show('退出命令模式', 1)
end

-- 导出模块
return {
  windowModal = windowModal,
  commandModal = commandModal
}
