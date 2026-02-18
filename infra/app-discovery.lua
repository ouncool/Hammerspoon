local AppDiscovery = {}

function AppDiscovery.existsApp(path)
  return hs.fs.pathToAbsolute(path) ~= nil
end

function AppDiscovery.firstExisting(paths)
  if type(paths) ~= 'table' then
    return nil
  end

  for _, path in ipairs(paths) do
    if AppDiscovery.existsApp(path) then
      return path
    end
  end

  return nil
end

function AppDiscovery.openFirstAvailable(paths)
  local appPath = AppDiscovery.firstExisting(paths)
  if not appPath then
    return nil
  end

  hs.application.open(appPath)
  return appPath
end

function AppDiscovery.openApp(path, args)
  if not AppDiscovery.existsApp(path) then
    return false
  end

  if args and #args > 0 then
    local cmd = 'open -a ' .. string.format('%q', path)
    for _, arg in ipairs(args) do
      cmd = cmd .. ' ' .. string.format('%q', tostring(arg))
    end
    hs.execute(cmd)
    return true
  end

  hs.application.open(path)
  return true
end

function AppDiscovery.hasCLI(binary)
  if type(binary) ~= 'string' or binary == '' then
    return false
  end

  local cmd = string.format('command -v %q >/dev/null 2>&1 && echo ok', binary)
  local out = hs.execute(cmd)
  return out and out:match('ok') ~= nil
end

return AppDiscovery
