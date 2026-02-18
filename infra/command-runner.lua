local CommandRunner = {}

local Logger = require('core.logger')
local log = Logger.scope('CommandRunner')

local function shellQuote(value)
  if value == nil then
    return "''"
  end

  local text = tostring(value)
  return "'" .. text:gsub("'", "'\\''") .. "'"
end

local function buildCommand(spec)
  if type(spec) ~= 'table' then
    error('spec must be table')
  end

  if spec.raw then
    return spec.raw
  end

  if type(spec.cmd) ~= 'string' or spec.cmd == '' then
    error('spec.cmd is required')
  end

  local parts = {shellQuote(spec.cmd)}
  if type(spec.args) == 'table' then
    for _, arg in ipairs(spec.args) do
      table.insert(parts, shellQuote(arg))
    end
  end

  local command = table.concat(parts, ' ')
  if spec.cwd then
    command = 'cd ' .. shellQuote(spec.cwd) .. ' && ' .. command
  end

  return command
end

function CommandRunner.run(spec)
  local command = buildCommand(spec)
  local output, status, statusType, code = hs.execute(command)
  local ok = status == true

  if not ok then
    log.warn('Command failed', {
      command = command,
      statusType = statusType,
      code = code,
      output = output,
    })
  end

  return {
    ok = ok,
    code = code or (ok and 0 or 1),
    statusType = statusType,
    stdout = output or '',
    stderr = ok and '' or (output or ''),
    command = command,
  }
end

function CommandRunner.shellQuote(value)
  return shellQuote(value)
end

return CommandRunner
