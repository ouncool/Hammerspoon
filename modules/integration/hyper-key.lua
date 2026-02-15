-- **************************************************
-- Hyper Key Global Shortcuts
-- Caps Lock mapped to Cmd + Opt + Ctrl + Shift (Hyper)
-- **************************************************
-- Hyper + G: Open browser
-- Hyper + T: Open terminal
-- Hyper + F: Open Finder directory in terminal
-- Hyper + V: Open Finder directory in VS Code
-- Hyper + R: Window management mode
-- **************************************************

local Logger = require('modules.core.logger')
local EventBus = require('modules.core.event-bus')
local Finder = require('modules.utils.finder')

local log = Logger.new('HyperKey')

local M = {}

local hyperModifier = {'cmd', 'alt', 'ctrl', 'shift'}
local hotkeyBindings = {}

-- Hyper + G: Open browser
local function openBrowser()
    local apps = {
        '/Applications/Google Chrome.app',
        '/Applications/Brave Browser.app',
        '/Applications/Firefox.app',
        '/Applications/Safari.app'
    }

    local openedApp = Finder.openFirstAvailable(apps)
    if openedApp then
        log.info('Opened browser', { app = openedApp })
        EventBus.emit(EventBus.EVENTS.CUSTOM .. 'browser.opened', { app = openedApp })
    else
        hs.alert.show("No browser found")
        log.warn('No browser found')
    end
end

-- Hyper + T: Open terminal (Ghostty if available, else Terminal)
local function openTerminal()
    local terminalApps = {
        '/Applications/Ghostty.app',
        '/Applications/iTerm.app',
        '/Applications/Terminal.app'
    }

    local openedApp = Finder.openFirstAvailable(terminalApps)
    if openedApp then
        log.info('Opened terminal', { app = openedApp })
        EventBus.emit(EventBus.EVENTS.CUSTOM .. 'terminal.opened', { app = openedApp })
    else
        hs.alert.show("No terminal found")
        log.warn('No terminal found')
    end
end

-- Hyper + F: Open Finder directory in terminal
local function openFinderInTerminal()
    local path = Finder.getPath()
    if path then
        hs.execute("open -a Ghostty " .. Finder.shellQuote(path))
        log.info('Opened Finder directory in terminal', { path = path })
        EventBus.emit(EventBus.EVENTS.CUSTOM .. 'finder-terminal.opened', { path = path })
    else
        hs.alert.show("Unable to get Finder path")
        log.error('Failed to get Finder path')
    end
end

-- Hyper + V: Open Finder directory in VS Code
local function openFinderInVSCode()
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
            log.info('Opened Finder directory in VS Code', { path = path })
            EventBus.emit(EventBus.EVENTS.CUSTOM .. 'finder-vscode.opened', { path = path })
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
    log.debug('Initializing Hyper Key')
    return true
end

local function start()
    log.debug('Starting Hyper Key')

    -- Bind Hyper key combinations
    hotkeyBindings.browser = hs.hotkey.bind(hyperModifier, 'G', openBrowser)
    hotkeyBindings.terminal = hs.hotkey.bind(hyperModifier, 'T', openTerminal)
    hotkeyBindings.finderTerminal = hs.hotkey.bind(hyperModifier, 'F', openFinderInTerminal)
    hotkeyBindings.finderVSCode = hs.hotkey.bind(hyperModifier, 'V', openFinderInVSCode)

    log.info('Hyper Key shortcuts registered')
    return true
end

local function stop()
    log.debug('Stopping Hyper Key')

    for key, hotkey in pairs(hotkeyBindings) do
        if hotkey then
            hotkey:delete()
        end
    end
    hotkeyBindings = {}
end

local function cleanup()
    log.debug('Cleaning up Hyper Key')
    stop()
end

-- Export module
return {
    init = init,
    start = start,
    stop = stop,
    cleanup = cleanup
}
