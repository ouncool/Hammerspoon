-- **************************************************
-- Hammerspoon 配置主入口
-- **************************************************

-- 重载配置的快捷键
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

-- 辅助函数：安全加载模块
local function loadModule(name)
  local ok, err = pcall(require, name)
  if not ok then
    hs.notify.new({title="Hammerspoon", informativeText="Failed to load module: " .. name .. "\n" .. tostring(err)}):send()
    print("Error loading module: " .. name .. "\n" .. tostring(err))
  end
end

-- ==================================================
-- 模块加载
-- ==================================================

-- --------------------------------------------------
-- 输入法相关
-- --------------------------------------------------
loadModule('modules.input-method.auto-switch')    -- 自动切换输入法（默认搜狗，指定应用用英文）
loadModule('modules.input-method.indicator')      -- 输入法状态指示器

-- --------------------------------------------------
-- 窗口管理
-- --------------------------------------------------
loadModule('modules.window.manager')              -- Vim风格窗口管理器 (Alt+R)
loadModule('modules.window.launcher')             -- 环形应用启动器 (Cmd+`)

-- --------------------------------------------------
-- 键盘增强
-- --------------------------------------------------
loadModule('modules.keyboard.paste-helper')       -- Cmd+Shift+V绕过粘贴限制

-- --------------------------------------------------
-- 工作相关
-- --------------------------------------------------
loadModule('modules.work.wifi-mute')              -- 连接公司WiFi自动静音
loadModule('modules.work.reminder')               -- 工作时间提醒

-- --------------------------------------------------
-- 应用集成
-- --------------------------------------------------
loadModule('modules.integration.finder-terminal') -- Cmd+Alt+T/V 在终端/VSCode打开Finder目录

-- 配置加载完成
hs.alert.show("✅ Hammerspoon Config Loaded")
