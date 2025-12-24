-- **************************************************
-- Hammerspoon Main Configuration Entry
-- **************************************************

-- Hotkey to reload configuration
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  hs.reload()
end)

-- Helper function: Safely load module with enhanced error handling
local function loadModule(name)
  if not name or type(name) ~= 'string' then
    hs.notify.new({title="Hammerspoon", informativeText="Invalid module name: " .. tostring(name)}):send()
    print("❌ Error: Invalid module name provided")
    return nil
  end
  
  local ok, result = pcall(require, name)
  
  if ok then
    -- If module returns start or init function, call it automatically
    if type(result) == 'table' then
      if result.start and type(result.start) == 'function' then
        local startOk, startErr = pcall(result.start)
        if not startOk then
          hs.notify.new({title="Hammerspoon", informativeText="Failed to start module: " .. name .. "\n" .. tostring(startErr)}):send()
          print("❌ Error starting module: " .. name .. "\n" .. tostring(startErr))
          return nil
        end
      elseif result.init and type(result.init) == 'function' then
        local initOk, initErr = pcall(result.init)
        if not initOk then
          hs.notify.new({title="Hammerspoon", informativeText="Failed to init module: " .. name .. "\n" .. tostring(initErr)}):send()
          print("❌ Error initializing module: " .. name .. "\n" .. tostring(initErr))
          return nil
        end
      end
    end
    return result
  else
    hs.notify.new({title="Hammerspoon", informativeText="Failed to load module: " .. name .. "\n" .. tostring(result)}):send()
    print("❌ Error loading module: " .. name .. "\n" .. tostring(result))
    return nil
  end
end

-- ==================================================
-- Module Loading
-- ==================================================

-- --------------------------------------------------
-- Input Method Related
-- --------------------------------------------------
loadModule('modules.input-method.auto-switch')    -- Auto-switch input method (default Sogou, English for specified apps)
-- loadModule('modules.input-method.indicator')      -- Input method status indicator

-- --------------------------------------------------
-- Window Management
-- --------------------------------------------------
loadModule('modules.window.manager')              -- Vim-style window manager (Alt+R)

-- --------------------------------------------------
-- Keyboard Enhancement
-- --------------------------------------------------
loadModule('modules.keyboard.paste-helper')       -- Cmd+Shift+V bypass paste restrictions

-- --------------------------------------------------
-- Application Integration
-- --------------------------------------------------
loadModule('modules.integration.finder-terminal') -- Cmd+Alt+T/V open Finder directory in terminal/VSCode
loadModule('modules.integration.preview-pdf-fullscreen') -- Auto fullscreen when opening PDF in Preview

-- Configuration loaded
hs.alert.show("✅ Hammerspoon Config Loaded")
