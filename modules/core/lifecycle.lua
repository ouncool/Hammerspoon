-- **************************************************
-- Module Lifecycle Manager
-- Handles initialization, starting, stopping, and cleanup of modules
-- **************************************************

local Lifecycle = {}
local Logger = require('modules.core.logger')

-- Module registry
local modules = {
  loaded = {},
  started = {},
  failed = {}
}

-- Module dependencies
local dependencies = {}

-- Register a module with its dependencies
-- @param name string Module name
-- @param module table The module table
-- @param deps table Optional list of module names this module depends on
function Lifecycle.register(name, module, deps)
  if not name or type(name) ~= 'string' then
    error('Lifecycle.register: Invalid module name')
  end

  if not module or type(module) ~= 'table' then
    error('Lifecycle.register: Invalid module')
  end

  modules.loaded[name] = module
  dependencies[name] = deps or {}

  Logger.debug('Lifecycle', 'Module registered: ' .. name)
end

-- Initialize a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.init(name)
  if not modules.loaded[name] then
    Logger.error('Lifecycle', 'Module not found: ' .. name)
    return false
  end

  if modules.started[name] then
    Logger.warn('Lifecycle', 'Module already started: ' .. name)
    return true
  end

  local module = modules.loaded[name]

  -- Check dependencies
  for _, dep in ipairs(dependencies[name] or {}) do
    if not modules.started[dep] then
      Logger.error('Lifecycle', string.format('Module %s depends on %s which is not started', name, dep))
      return false
    end
  end

  -- Call init if exists
  if module.init and type(module.init) == 'function' then
    local ok, err = pcall(module.init)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to init module %s: %s', name, tostring(err)))
      modules.failed[name] = err
      return false
    end
    Logger.debug('Lifecycle', 'Module initialized: ' .. name)
  end

  return true
end

-- Start a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.start(name)
  if not modules.loaded[name] then
    Logger.error('Lifecycle', 'Module not found: ' .. name)
    return false
  end

  if modules.started[name] then
    Logger.debug('Lifecycle', 'Module already started: ' .. name)
    return true
  end

  -- Initialize first
  if not Lifecycle.init(name) then
    return false
  end

  local module = modules.loaded[name]

  -- Call start if exists
  if module.start and type(module.start) == 'function' then
    local ok, err = pcall(module.start)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to start module %s: %s', name, tostring(err)))
      modules.failed[name] = err
      return false
    end
    Logger.debug('Lifecycle', 'Module started: ' .. name)
  end

  modules.started[name] = true
  return true
end

-- Stop a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.stop(name)
  if not modules.started[name] then
    Logger.debug('Lifecycle', 'Module not started: ' .. name)
    return true
  end

  local module = modules.loaded[name]

  -- Call stop if exists
  if module.stop and type(module.stop) == 'function' then
    local ok, err = pcall(module.stop)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to stop module %s: %s', name, tostring(err)))
      return false
    end
    Logger.debug('Lifecycle', 'Module stopped: ' .. name)
  end

  modules.started[name] = nil
  return true
end

-- Cleanup a module
-- @param name string Module name
-- @return boolean success
function Lifecycle.cleanup(name)
  -- Stop first
  Lifecycle.stop(name)

  local module = modules.loaded[name]
  if not module then
    Logger.warn('Lifecycle', 'Module not found: ' .. name)
    return false
  end

  -- Call cleanup if exists
  if module.cleanup and type(module.cleanup) == 'function' then
    local ok, err = pcall(module.cleanup)
    if not ok then
      Logger.error('Lifecycle', string.format('Failed to cleanup module %s: %s', name, tostring(err)))
      return false
    end
    Logger.debug('Lifecycle', 'Module cleaned up: ' .. name)
  end

  -- Remove from registry
  modules.loaded[name] = nil
  modules.failed[name] = nil
  dependencies[name] = nil

  return true
end

-- Get module status
-- @param name string Module name
-- @return string status: 'loaded', 'started', 'failed', or nil
function Lifecycle.getStatus(name)
  if modules.failed[name] then
    return 'failed'
  elseif modules.started[name] then
    return 'started'
  elseif modules.loaded[name] then
    return 'loaded'
  end
  return nil
end

-- Get all modules
-- @param status string Optional filter by status
-- @return table List of module names
function Lifecycle.getModules(status)
  local result = {}
  
  for name, _ in pairs(modules.loaded) do
    if not status or Lifecycle.getStatus(name) == status then
      table.insert(result, name)
    end
  end
  
  return result
end

-- Get module
-- @param name string Module name
-- @return table Module or nil
function Lifecycle.getModule(name)
  return modules.loaded[name]
end

-- Print status of all modules (简体中文简洁输出)
function Lifecycle.printStatus()
  local started = Lifecycle.getModules('started')
  local failed = {}

  for name, err in pairs(modules.failed) do
    table.insert(failed, name)
  end

  if #started > 0 then
    print('✅ 已启动模块 (' .. #started .. '):')
    -- 使用简短名称显示
    for _, name in ipairs(started) do
      local shortName = name:match('modules%.(.+)') or name
      print('  • ' .. shortName)
    end
  end

  if #failed > 0 then
    print('❌ 启动失败:')
    for _, name in ipairs(failed) do
      print('  • ' .. name .. ': ' .. tostring(modules.failed[name]))
    end
  end
end

-- Get hotkey information from modules (收集模块快捷键信息)
function Lifecycle.getHotkeyInfo()
  local hotkeys = {}

  -- 定义模块的中文描述和快捷键
  local moduleInfo = {
    ['modules.input-method.auto-switch'] = {
      name = '输入法切换',
      hotkeys = {}
    },
    ['modules.window.manager'] = {
      name = '窗口管理',
      hotkeys = {
        { key = '⌥H', desc = '窗口左半屏' },
        { key = '⌥J', desc = '窗口下半屏' },
        { key = '⌥K', desc = '窗口上半屏' },
        { key = '⌥L', desc = '窗口右半屏' },
        { key = '⌥⇧H', desc = '窗口左三分之一' },
        { key = '⌥⇧L', desc = '窗口右三分之一' },
        { key = '⌥⇧J', desc = '窗口下三分之二' },
        { key = '⌥⇧K', desc = '窗口上三分之二' },
        { key = '⌥M', desc = '最大化窗口' },
        { key = '⌥N', desc = '居中窗口' }
      }
    },
    ['modules.keyboard.paste-helper'] = {
      name = '粘贴助手',
      hotkeys = {
        { key = '⌘⇧V', desc = '粘贴剪贴板内容' }
      }
    },
    ['modules.integration.finder-terminal'] = {
      name = 'Finder 集成',
      hotkeys = {
        { key = '⌘⌃⌥T', desc = '在终端打开当前路径' },
        { key = '⌘⌃⌥V', desc = '在 VSCode 打开当前路径' }
      }
    },
    ['modules.integration.preview-pdf-fullscreen'] = {
      name = 'PDF 全屏预览',
      hotkeys = {}
    }
  }

  -- 收集已启动模块的快捷键
  for _, moduleName in ipairs(Lifecycle.getModules('started')) do
    local info = moduleInfo[moduleName]
    if info then
      table.insert(hotkeys, {
        module = info.name,
        hotkeys = info.hotkeys
      })
    end
  end

  return hotkeys
end

-- Print hotkey information (打印快捷键信息)
function Lifecycle.printHotkeys()
  local hotkeyInfo = Lifecycle.getHotkeyInfo()

  if #hotkeyInfo == 0 then
    return
  end

  print('')
  print('⌨️  快捷键:')

  for _, module in ipairs(hotkeyInfo) do
    if #module.hotkeys > 0 then
      print('  ' .. module.module .. ':')
      for _, hotkey in ipairs(module.hotkeys) do
        print('    ' .. hotkey.key .. ' - ' .. hotkey.desc)
      end
    end
  end

  -- 全局快捷键
  print('  全局:')
  print('    ⌘⌃⌥R - 重新加载配置')
end

return Lifecycle
