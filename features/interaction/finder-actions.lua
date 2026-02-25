local AppDiscovery = require('infra.app-discovery')
local Finder = require('shared.finder')

local M = {}

local ctx = nil
local log = nil
local terminals = {}
local editors = {}

local function customEvent(name, payload)
  ctx.events.emit(ctx.events.NAMES.CUSTOM_PREFIX .. name, payload)
end

local function activePath(path)
  local candidate = path or Finder.currentPath()
  if not candidate or candidate == '' then
    return nil, 'Unable to get Finder path'
  end
  return candidate, nil
end

function M.openInTerminal(path)
  local targetPath, pathErr = activePath(path)
  if not targetPath then
    return false, pathErr
  end

  local appPath = AppDiscovery.firstExisting(terminals)
  if not appPath then
    return false, 'No terminal app found'
  end

  local result = ctx.command.run({
    cmd = 'open',
    args = {'-a', appPath, targetPath},
  })

  if not result.ok then
    return false, 'Failed to open terminal'
  end

  log.info('Opened terminal from Finder path', {app = appPath, path = targetPath})
  customEvent('finder.terminal.opened', {app = appPath, path = targetPath})
  return true, nil
end

function M.openInEditor(path)
  local targetPath, pathErr = activePath(path)
  if not targetPath then
    return false, pathErr
  end

  for _, editor in ipairs(editors) do
    if AppDiscovery.existsApp(editor.app) then
      if editor.cli and AppDiscovery.hasCLI(editor.cli) then
        local cliResult = ctx.command.run({
          cmd = editor.cli,
          args = {targetPath},
        })
        if cliResult.ok then
          log.info('Opened editor via CLI', {cli = editor.cli, path = targetPath})
          customEvent('finder.editor.opened', {mode = 'cli', cli = editor.cli, app = editor.app, path = targetPath})
          return true, nil
        end
      end

      local openResult = ctx.command.run({
        cmd = 'open',
        args = {'-a', editor.app, targetPath},
      })

      if openResult.ok then
        log.info('Opened editor via open -a', {app = editor.app, path = targetPath})
        customEvent('finder.editor.opened', {mode = 'app', app = editor.app, path = targetPath})
        return true, nil
      end
    end
  end

  return false, 'No configured editor is available'
end

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('FinderActions')

  terminals = ctx.config.apps.terminals
  editors = ctx.config.apps.editors

  return true
end

function M.start()
  return true
end

function M.stop()
  return true
end

function M.dispose()
  ctx = nil
  log = nil
  terminals = {}
  editors = {}
end

return M
