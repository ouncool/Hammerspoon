-- Help panel display using hs.canvas
-- Shows all available hotkeys organized by group

local M = {}

local ctx = nil
local log = nil
local hud = nil
local hudTimer = nil

local HYPERKEY_CN_DESC = {
  ['hyperkey.lock'] = '锁屏',
  ['hyperkey.paste'] = '强制粘贴',
  ['hyperkey.terminal'] = '打开终端',
  ['hyperkey.editor'] = '打开编辑器',
  ['hyperkey.browser'] = '打开浏览器',
  ['hyperkey.wechat'] = '打开微信',
  ['hyperkey.weworkMac'] = '打开企业微信',
  ['hyperkey.window.left'] = '窗口左半屏',
  ['hyperkey.window.right'] = '窗口右半屏',
  ['hyperkey.window.up'] = '窗口上半屏',
  ['hyperkey.window.down'] = '窗口下半屏',
  ['hyperkey.window.maximize'] = '窗口最大化',
  ['hyperkey.help'] = '显示帮助面板',
}

local GLOBAL_CN_DESC = {
  ['global.reload'] = '重新加载配置',
}

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('HelpDisplay')
  return true
end

local function hideHud()
  if hudTimer then
    hudTimer:stop()
    hudTimer = nil
  end
  if hud then
    hud:delete()
    hud = nil
  end
end

local function modsToString(mods)
  if not mods or #mods == 0 then return '' end
  local modNames = {}
  for _, mod in ipairs(mods) do
    if mod == 'cmd' then
      table.insert(modNames, '⌘')
    elseif mod == 'alt' then
      table.insert(modNames, '⌥')
    elseif mod == 'ctrl' then
      table.insert(modNames, '⌃')
    elseif mod == 'shift' then
      table.insert(modNames, '⇧')
    else
      table.insert(modNames, mod)
    end
  end
  return table.concat(modNames, '')
end

local function keyToString(key)
  local keyMap = {
    left = '←',
    right = '→',
    up = '↑',
    down = '↓',
    Return = '⏎',
    Backspace = '⌫',
    Tab = '⇥',
    space = '␣',
  }
  return keyMap[key] or key:upper()
end

local function formatHotkey(binding)
  if binding.group == 'hyperkey' then
    local key = keyToString(binding.key)
    local desc = HYPERKEY_CN_DESC[binding.id] or (binding.desc or binding.id)
    return 'Hyperkey + ' .. key .. '    ' .. desc
  end

  if binding.group == 'global' then
    local mods = modsToString(binding.mods)
    local key = keyToString(binding.key)
    local desc = GLOBAL_CN_DESC[binding.id] or (binding.desc or binding.id)
    return mods .. ' + ' .. key .. '    ' .. desc
  end

  local mods = modsToString(binding.mods)
  local key = keyToString(binding.key)
  local desc = binding.desc or binding.id
  return mods .. key .. '    ' .. desc
end

local function groupHotkeys(hotkeys)
  local grouped = {}
  local groupOrder = {'global', 'hyperkey', 'other'}

  for _, binding in ipairs(hotkeys) do
    local group = binding.group or 'other'
    if not grouped[group] then
      grouped[group] = {}
    end
    table.insert(grouped[group], binding)
  end

  -- Sort each group by ID
  for group, items in pairs(grouped) do
    table.sort(items, function(a, b)
      return a.id < b.id
    end)
  end

  return grouped, groupOrder
end

local function buildHelpLines()
  local allHotkeys = ctx.hotkeys.list()
  local grouped, groupOrder = groupHotkeys(allHotkeys)

  local lines = {}
  local groupLabels = {
    global = '📌 全局快捷键',
    hyperkey = '🔥 超级键 (Cmd+Alt+Ctrl+Shift)',
    other = '⚙️ 其他功能',
  }

  for _, group in ipairs(groupOrder) do
    if grouped[group] and #grouped[group] > 0 then
      if #lines > 0 then
        table.insert(lines, '')  -- blank line
      end
      table.insert(lines, groupLabels[group] or group)
      for _, binding in ipairs(grouped[group]) do
        table.insert(lines, '  ' .. formatHotkey(binding))
      end
    end
  end

  return lines
end

function M.show()
  hideHud()

  local lines = buildHelpLines()
  if #lines == 0 then
    log.warn('No hotkeys to display')
    hs.alert.show('No hotkeys registered')
    return
  end

  local screen = hs.screen.mainScreen()
  if not screen then return end
  local f = screen:frame()

  -- Canvas dimensions
  local w = 600
  local lineHeight = 24
  local titleHeight = 40
  local padding = 24
  local extraSpace = 8
  local h = titleHeight + padding + (#lines * lineHeight) + padding

  -- Center on screen
  local x = f.x + math.floor((f.w - w) / 2)
  local y = f.y + math.floor((f.h - h) / 2)

  -- Create canvas
  hud = hs.canvas.new({x = x, y = y, w = w, h = h})

  -- Shadow background (offset)
  hud[1] = {
    type = 'rectangle',
    action = 'fill',
    fillColor = {red = 0, green = 0, blue = 0, alpha = 0.25},
    roundedRectRadii = {xRadius = 18, yRadius = 18},
    frame = {x = 6, y = 6, w = w - 12, h = h - 12},
  }

  -- Main background
  hud[2] = {
    type = 'rectangle',
    action = 'fill',
    fillColor = {red = 0.12, green = 0.12, blue = 0.12, alpha = 0.96},
    roundedRectRadii = {xRadius = 16, yRadius = 16},
  }

  -- Title
  hud[3] = {
    type = 'text',
    text = '❓ 快捷键帮助',
    textFont = 'Helvetica-Bold',
    textSize = 22,
    textColor = {white = 1, alpha = 1},
    frame = {x = padding, y = padding / 2, w = w - padding * 2, h = titleHeight},
    textAlignment = 'left',
  }

  -- Hotkey lines
  for i, line in ipairs(lines) do
    if line == '' then
      -- Skip blank lines, just add spacing
    elseif line:find('📌') or line:find('🔥') or line:find('⚙️') then
      -- Section headers
      hud[#hud + 1] = {
        type = 'text',
        text = line,
        textFont = 'Helvetica-Bold',
        textSize = 15,
        textColor = {red = 0.6, green = 0.8, blue = 1, alpha = 0.95},
        frame = {
          x = padding,
          y = padding / 2 + titleHeight + (i - 1) * lineHeight,
          w = w - padding * 2,
          h = lineHeight,
        },
        textAlignment = 'left',
      }
    else
      -- Regular hotkey lines
      hud[#hud + 1] = {
        type = 'text',
        text = line,
        textFont = 'Monaco',
        textSize = 14,
        textColor = {white = 0.95, alpha = 0.9},
        frame = {
          x = padding,
          y = padding / 2 + titleHeight + (i - 1) * lineHeight,
          w = w - padding * 2,
          h = lineHeight,
        },
        textAlignment = 'left',
      }
    end
  end

  hud:show()

  -- Auto hide after 5 seconds
  hudTimer = hs.timer.doAfter(5, hideHud)
  log.info('Help panel shown with ' .. #lines .. ' lines')
end

return M
