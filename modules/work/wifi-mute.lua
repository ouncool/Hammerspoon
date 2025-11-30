-- **************************************************
-- 连接到公司 Wi-Fi 后自动静音
-- **************************************************

-- --------------------------------------------------
-- 定义公司的 wifi 名称
-- 支持从 .env 文件读取 WiFi 名称以避免泄露到 git
-- 优先顺序：~/.hammerspoon/.env 中的配置 -> 本文件内的默认值
-- .env 示例（请用占位符或你自己的本地值替换，不要在示例中放置真实公司 SSID）：
-- WORK_SSIDS=COMPANY_WIFI,COMPANY_WIFI_5G
-- 或
-- WORK_SSID1=COMPANY_WIFI
-- WORK_SSID2=COMPANY_WIFI_5G

local WORK_SSIDS = {}

local function readEnvFile()
  local configPath = hs.configdir .. '/.env'
  local fh = io.open(configPath, 'r')
  if not fh then return end
  for line in fh:lines() do
    line = line:match('^%s*(.-)%s*$') -- trim
    if line ~= '' and not line:match('^#') then
      local k, v = line:match('([^=]+)=(.*)')
      if k and v then
        k = k:match('^%s*(.-)%s*$')
        v = v:match('^%s*(.-)%s*$')
        if k == 'WORK_SSIDS' then
          for s in string.gmatch(v, "[^,]+") do
            s = s:match('^%s*(.-)%s*$')
            if s ~= '' then table.insert(WORK_SSIDS, s) end
          end
        else
          local m = k:match('WORK_SSID(%d+)')
          if m and v ~= '' then table.insert(WORK_SSIDS, v) end
        end
      end
    end
  end
  fh:close()
end

local function mute()
  hs.audiodevice.defaultOutputDevice():setOutputMuted(true)
end

local function unmute()
  hs.audiodevice.defaultOutputDevice():setOutputMuted(false)
end

local wifiWatcher = nil

local function start(config)
  -- 如果传入了配置，直接使用
  if config and config.work_ssids then
    WORK_SSIDS = config.work_ssids
  else
    -- 否则尝试读取 .env
    readEnvFile()
    
    -- 默认值（当 .env 无配置时使用）
    if #WORK_SSIDS == 0 then
      WORK_SSIDS = { 'COMPANY_WIFI', 'COMPANY_WIFI_5G' }
    end
  end

  -- 构建快速查找表
  local WORK_SSID_SET = {}
  for _, s in ipairs(WORK_SSIDS) do WORK_SSID_SET[s] = true end

  local handleWifiChanged = function()
    local currentSSID = hs.wifi.currentNetwork()
    if currentSSID and WORK_SSID_SET[currentSSID] then
      mute()
    else
      unmute()
    end
  end

  if wifiWatcher then wifiWatcher:stop() end
  wifiWatcher = hs.wifi.watcher.new(handleWifiChanged)
  wifiWatcher:start()

  -- 初始检查一次
  handleWifiChanged()
end

-- 为了保持向后兼容，如果直接 require 且没有显式调用 start，
-- 我们可以在这里自动启动，但这样就无法避免 I/O 了。
-- 更好的做法是：如果不调用 start，就不启动。
-- 但为了不破坏现有配置（init.lua 只是 require），我们需要保留自动启动，
-- 除非我们修改 init.lua 来调用 start。
-- 鉴于我们已经修改了 init.lua 的 loadModule，我们可以让 loadModule 支持调用 init/start。
-- 但目前 loadModule 只是 require。
-- 所以我们保留自动启动逻辑，但允许被覆盖。

-- 自动启动（旧行为）
-- readEnvFile() ...
-- 这里的逻辑稍微有点 tricky。如果用户只是 require，我们希望它工作。
-- 我们可以使用 timer.doAfter(0, ...) 来延迟启动，给调用者一个机会去配置？
-- 或者，我们直接保留旧行为，但提供 start 函数供优化。

-- 既然我们还没修改 init.lua 去调用 start，那么现在必须保留自动启动。
-- 但是，如果我们在 init.lua 中 require 之后立即调用 start，那么之前的自动启动已经跑了。
-- 所以，我们应该把自动启动逻辑放在这里，但如果 init.lua 改为调用 start，我们就不需要自动启动了。

-- 方案：
-- 导出 start 函数。
-- 在文件末尾，检查是否已经被配置过？很难。
-- 简单点：直接运行旧逻辑，但如果调用 start(config)，则重新初始化。
-- 这样虽然第一次 require 还是会读文件，但至少提供了优化的路径。
-- 等等，如果第一次 require 就读文件，那优化个啥？
-- 我们必须去掉顶层的执行代码，改为只导出函数。
-- 但是 init.lua 里面只是 `loadModule('...')` -> `require`.
-- 如果我去掉顶层代码，现有的 `init.lua` 就失效了（模块加载了但不工作）。
-- 所以我必须同时修改 `init.lua` 来调用 `start`，或者修改 `wifi-mute.lua` 来延迟执行。

-- 让我们修改 init.lua 来支持模块初始化函数。
-- 如果模块返回一个 table 且有 start/init 方法，并在 loadModule 中调用它。
-- 这样我就可以把 wifi-mute.lua 的顶层代码移到 start 中。

-- 让我们先修改 wifi-mute.lua 为：
-- return { start = start }
-- 然后修改 init.lua 自动调用 start。

return { start = start }
