-- **************************************************
-- Finder Integration: Open current Finder directory in terminal/editor
-- **************************************************
-- Cmd+Alt+T: Open in Ghostty terminal
-- Cmd+Alt+V: Open in VS Code
-- **************************************************

local Logger = require('modules.core.logger')
local EventBus = require('modules.core.event-bus')

local log = Logger.new('FinderIntegration')

local M = {}

local terminalHotkey = nil
local vscodeHotkey = nil

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
        
        EventBus.emit(EventBus.EVENTS.CUSTOM .. 'terminal.opened', {
            path = path,
            app = 'Ghostty'
        })
        
        log.info('Opened terminal', { path = path })
    else
        hs.alert.show("Unable to get Finder path")
        log.error('Failed to get Finder path')
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
            
            EventBus.emit(EventBus.EVENTS.CUSTOM .. 'vscode.opened', {
                path = path,
                app = 'VSCode'
            })
            
            log.info('Opened VS Code', { path = path })
        else
            hs.alert.show("Visual Studio Code not found")
            log.error('VS Code not found')
        end
    else
        hs.alert.show("Unable to get Finder path")
        log.error('Failed to get Finder path')
    end
end

-- Lifecycle functions
local function init()
    log.info('Initializing finder integration')
    return true
end

local function start()
    log.info('Starting finder integration')
    
    -- Bind hotkeys
    terminalHotkey = hs.hotkey.bind({'cmd', 'alt'}, 'T', M.openInTerminal)
    vscodeHotkey = hs.hotkey.bind({'cmd', 'alt'}, 'V', M.openInVSCode)
    
    return true
end

local function stop()
    log.info('Stopping finder integration')
    
    -- Delete hotkeys
    if terminalHotkey then
        terminalHotkey:delete()
        terminalHotkey = nil
    end
    if vscodeHotkey then
        vscodeHotkey:delete()
        vscodeHotkey = nil
    end
end

local function cleanup()
    log.info('Cleaning up finder integration')
    stop()
end

-- Export module
return {
    init = init,
    start = start,
    stop = stop,
    cleanup = cleanup,
    openInTerminal = M.openInTerminal,
    openInVSCode = M.openInVSCode
}
