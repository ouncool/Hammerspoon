local Finder = {}

function Finder.shellQuote(value)
  if value == nil then
    return "''"
  end
  local text = tostring(value)
  return "'" .. text:gsub("'", "'\\''") .. "'"
end

function Finder.currentPath()
  local script = [[
    tell application "Finder"
      try
        set topWnd to front window
        set targetFolder to (target of topWnd) as alias
        return POSIX path of targetFolder
      on error
        return POSIX path of (path to desktop)
      end try
    end tell
  ]]

  local ok, result = hs.osascript.applescript(script)
  if not ok or not result then
    return nil
  end

  local trimmed = tostring(result):gsub('^%s*(.-)%s*$', '%1')
  if trimmed == '' then
    return nil
  end

  return trimmed
end

return Finder
