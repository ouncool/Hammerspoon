-- **************************************************
-- Finder Integration: Open current Finder directory in terminal/editor
-- **************************************************
-- Cmd+Alt+T: Open in Ghostty terminal
-- Cmd+Alt+V: Open in VS Code
-- **************************************************

local M = {}

-- Escape shell path
local function shellQuote(str)
    if not str then return "''" end
    -- Remove trailing newlines and spaces
    str = str:gsub("^%s*(.-)%s*$", "%1")
    -- Wrap in single quotes and escape internal single quotes
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

-- Get current Finder window path
local function getFinderPath()
    local script = [[
    tell application "Finder"
        try
            set topWnd to front window
            set targetFolder to (target of topWnd) as alias
            return POSIX path of targetFolder
        on error
            -- If no window is open, or selected is not a folder, default to desktop
            return POSIX path of (path to desktop)
        end try
    end tell
    ]]
    local ok, result = hs.osascript.applescript(script)
    if ok then
        return result
    else
        return nil
    end
end

-- Open in Ghostty terminal
function M.openInTerminal()
    local path = getFinderPath()
    if path then
        path = path:gsub("^%s*(.-)%s*$", "%1")
        print("Opening terminal path: " .. path)
        hs.execute("open -a Ghostty " .. shellQuote(path))
    else
        hs.alert.show("Unable to get Finder path")
    end
end

-- Open in VS Code
function M.openInVSCode()
    local path = getFinderPath()
    if path then
        path = path:gsub("^%s*(.-)%s*$", "%1")
        print("Opening VS Code path: " .. path)

        -- Check if VS Code is installed
        local appPath = "/Applications/Visual Studio Code.app"
        local result = hs.execute("test -d " .. shellQuote(appPath) .. " && echo 'exists'")

        if result and result:match("exists") then
            -- Use code command if code CLI is installed
            local codeResult = hs.execute("which code 2>/dev/null")
            if codeResult and codeResult:len() > 0 then
                hs.execute("code " .. shellQuote(path))
            else
                -- Use open command
                hs.execute("open -a 'Visual Studio Code' " .. shellQuote(path))
            end
        else
            hs.alert.show("Visual Studio Code not found")
        end
    else
        hs.alert.show("Unable to get Finder path")
    end
end

-- Bind hotkeys
hs.hotkey.bind({'cmd', 'alt'}, 'T', M.openInTerminal)
hs.hotkey.bind({'cmd', 'alt'}, 'V', M.openInVSCode)

print("Finder Integration loaded:")
print("  - Cmd+Alt+T: Open in Ghostty")
print("  - Cmd+Alt+V: Open in VS Code")

return M
