-- **************************************************
-- Finder 集成：在终端/编辑器中打开当前 Finder 目录
-- **************************************************
-- Cmd+Alt+T: 在 Ghostty 终端中打开
-- Cmd+Alt+V: 在 VS Code 中打开
-- **************************************************

local M = {}

-- 转义 shell 路径
local function shellQuote(str)
    if not str then return "''" end
    -- 移除末尾的换行符和空格
    str = str:gsub("^%s*(.-)%s*$", "%1")
    -- 使用单引号包裹，并转义内部的单引号
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

-- 获取当前 Finder 窗口的路径
local function getFinderPath()
    local script = [[
    tell application "Finder"
        try
            set topWnd to front window
            set targetFolder to (target of topWnd) as alias
            return POSIX path of targetFolder
        on error
            -- 如果没有窗口打开，或者选中的不是文件夹，默认返回桌面
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

-- 在 Ghostty 终端中打开
function M.openInTerminal()
    local path = getFinderPath()
    if path then
        path = path:gsub("^%s*(.-)%s*$", "%1")
        print("打开终端路径: " .. path)
        hs.execute("open -a Ghostty " .. shellQuote(path))
    else
        hs.alert.show("无法获取 Finder 路径")
    end
end

-- 在 VS Code 中打开
function M.openInVSCode()
    local path = getFinderPath()
    if path then
        path = path:gsub("^%s*(.-)%s*$", "%1")
        print("打开 VS Code 路径: " .. path)

        -- 检查 VS Code 是否安装
        local appPath = "/Applications/Visual Studio Code.app"
        local result = hs.execute("test -d " .. shellQuote(appPath) .. " && echo 'exists'")

        if result and result:match("exists") then
            -- 使用 code 命令打开（如果安装了 code CLI）
            local codeResult = hs.execute("which code 2>/dev/null")
            if codeResult and codeResult:len() > 0 then
                hs.execute("code " .. shellQuote(path))
            else
                -- 使用 open 命令
                hs.execute("open -a 'Visual Studio Code' " .. shellQuote(path))
            end
        else
            hs.alert.show("未找到 Visual Studio Code")
        end
    else
        hs.alert.show("无法获取 Finder 路径")
    end
end

-- 绑定快捷键
hs.hotkey.bind({'cmd', 'alt'}, 'T', M.openInTerminal)
hs.hotkey.bind({'cmd', 'alt'}, 'V', M.openInVSCode)

print("Finder Integration loaded:")
print("  - Cmd+Alt+T: Open in Ghostty")
print("  - Cmd+Alt+V: Open in VS Code")

return M
