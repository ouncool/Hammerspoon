-- Application launcher for Hyperkey features
local AppDiscovery = require('infra.app-discovery')

local M = {}

local ctx = nil
local log = nil

function M.setup(runtime)
  ctx = runtime
  log = ctx.logger.scope('HyperkeyLauncher')
  return true
end

-- Open the first available app from a list
function M.openFirstApp(appPaths)
  if not appPaths or #appPaths == 0 then
    log.warn('No apps configured')
    return false, 'No apps configured'
  end

  local app = AppDiscovery.openFirstAvailable(appPaths)
  if not app then
    log.warn('No app found', {paths = appPaths})
    return false, 'No app found'
  end

  log.info('Opened app', {app = app})
  return true, app
end

-- Switch to app if running, else launch it
function M.switchOrLaunch(appPath)
  if not appPath or appPath == '' then
    log.warn('No app path provided')
    return false, 'No app path provided'
  end

  -- Check if app exists
  local exists = AppDiscovery.existsApp(appPath)
  if not exists then
    log.warn('App not found', {path = appPath})
    return false, 'App not found: ' .. appPath
  end

  -- Use shell open command for most reliable launching
  local cmd = string.format('open -a %q', appPath)
  local result = hs.execute(cmd)
  
  log.info('Executed open command', {app = appPath})
  return true, appPath
end

function M.dispose()
  ctx = nil
  log = nil
end

return M
