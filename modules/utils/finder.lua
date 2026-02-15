-- **************************************************
-- Finder Utility Module
-- Shared utilities for Finder integration
-- **************************************************

local M = {}

-- Escape shell path with quotes
function M.shellQuote(str)
    if not str then return "''" end
    str = str:gsub("^%s*(.-)%s*$", "%1")
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

-- Get current Finder window path
function M.getPath()
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
    if ok then
        return result:gsub("^%s*(.-)%s*$", "%1")
    else
        return nil
    end
end

-- Check if application exists and open it
function M.openApp(appPath)
    local result = hs.execute("test -d " .. M.shellQuote(appPath) .. " && echo 'exists'")
    if result and result:match("exists") then
        hs.execute("open " .. M.shellQuote(appPath))
        return true
    end
    return false
end

-- Open first available app from list
function M.openFirstAvailable(appList)
    for _, appPath in ipairs(appList) do
        if M.openApp(appPath) then
            return appPath
        end
    end
    return nil
end

return M
