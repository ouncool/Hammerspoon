local Hotkeys = {}

local Logger = require('core.logger')
local log = Logger.scope('Hotkeys')

local bindings = {}
local groups = {}

local function addToGroup(group, id)
  if not group then
    return
  end

  if not groups[group] then
    groups[group] = {}
  end

  table.insert(groups[group], id)
end

local function removeFromGroup(group, id)
  if not group or not groups[group] then
    return
  end

  for i = #groups[group], 1, -1 do
    if groups[group][i] == id then
      table.remove(groups[group], i)
    end
  end

  if #groups[group] == 0 then
    groups[group] = nil
  end
end

function Hotkeys.bind(spec)
  assert(type(spec) == 'table', 'spec must be table')
  assert(type(spec.id) == 'string' and spec.id ~= '', 'spec.id is required')
  assert(type(spec.mods) == 'table', 'spec.mods is required')
  assert(type(spec.key) == 'string' and spec.key ~= '', 'spec.key is required')
  assert(type(spec.action) == 'function', 'spec.action is required')

  if bindings[spec.id] then
    Hotkeys.unbind(spec.id)
  end

  local hotkey = hs.hotkey.bind(spec.mods, spec.key, spec.action, spec.releasefn, spec.repeatfn)
  bindings[spec.id] = {
    hotkey = hotkey,
    id = spec.id,
    mods = spec.mods,
    key = spec.key,
    desc = spec.desc,
    group = spec.group,
  }

  addToGroup(spec.group, spec.id)
  log.debug('Bound hotkey', {id = spec.id, key = spec.key, group = spec.group})

  return hotkey
end

function Hotkeys.unbind(id)
  local binding = bindings[id]
  if not binding then
    return
  end

  if binding.hotkey then
    binding.hotkey:delete()
  end

  removeFromGroup(binding.group, id)
  bindings[id] = nil
end

function Hotkeys.unbindGroup(group)
  local ids = groups[group]
  if not ids then
    return
  end

  local copy = {}
  for _, id in ipairs(ids) do
    table.insert(copy, id)
  end

  for _, id in ipairs(copy) do
    Hotkeys.unbind(id)
  end
end

function Hotkeys.clear()
  local ids = {}
  for id, _ in pairs(bindings) do
    table.insert(ids, id)
  end

  for _, id in ipairs(ids) do
    Hotkeys.unbind(id)
  end
end

function Hotkeys.list()
  local list = {}
  for _, binding in pairs(bindings) do
    table.insert(list, {
      id = binding.id,
      key = binding.key,
      mods = binding.mods,
      desc = binding.desc,
      group = binding.group,
    })
  end
  table.sort(list, function(a, b)
    return a.id < b.id
  end)
  return list
end

return Hotkeys
