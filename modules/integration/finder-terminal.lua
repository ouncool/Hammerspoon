-- **************************************************
-- Finder Integration: Open current Finder directory in terminal/editor
-- **************************************************
-- Hyper + F: Open in terminal (Ghostty)
-- Hyper + V: Open in VS Code
-- (Hyper = Caps Lock mapped to Cmd+Alt+Ctrl+Shift)
-- **************************************************

local Logger = require('modules.core.logger')
local EventBus = require('modules.core.event-bus')
local Finder = require('modules.utils.finder')

local log = Logger.new('FinderIntegration')

local M = {}

local terminalHotkey = nil
local vscodeHotkey = nil

-- Open in Ghostty terminal
function M.openInTerminal()
    local path = Finder.getPath()
    if path then
        log.info('Opened terminal', { path = path })
        hs.execute("open -a Ghostty " .. Finder.shellQuote(path))

        EventBus.emit(EventBus.EVENTS.CUSTOM .. 'terminal.opened', {
            path = path,
            app = 'Ghostty'
        })
    else
        hs.alert.show("Unable to get Finder path")
        log.error('Failed to get Finder path')
    end
end

-- Open in VS Code
function M.openInVSCode()
    local path = Finder.getPath()
    if path then
        local appPath = "/Applications/Visual Studio Code.app"
        local result = hs.execute("test -d " .. Finder.shellQuote(appPath) .. " && echo 'exists'")

        if result and result:match("exists") then
            local codeResult = hs.execute("which code 2>/dev/null")
            if codeResult and codeResult:len() > 0 then
                hs.execute("code " .. Finder.shellQuote(path))
            else
                hs.execute("open -a 'Visual Studio Code' " .. Finder.shellQuote(path))
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
    log.debug('Initializing finder integration')
    return true
end

local function start()
    log.debug('Starting finder integration')

    -- Bind hotkeys using Hyper (Cmd+Alt+Ctrl+Shift)
    terminalHotkey = hs.hotkey.bind({'cmd', 'alt', 'ctrl', 'shift'}, 'F', M.openInTerminal)
    vscodeHotkey = hs.hotkey.bind({'cmd', 'alt', 'ctrl', 'shift'}, 'V', M.openInVSCode)

    return true
end

local function stop()
    log.debug('Stopping finder integration')

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
    log.debug('Cleaning up finder integration')
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
