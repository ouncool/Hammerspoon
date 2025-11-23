-- **************************************************
-- 连接到公司 Wi-Fi 后自动静音
-- **************************************************

-- --------------------------------------------------
-- 定义公司的 wifi 名称
local WORK_SSID1 = 'MUDU'
local WORK_SSID2 = 'MUDU-5G'
-- --------------------------------------------------

local function mute()
  hs.audiodevice.defaultOutputDevice():setOutputMuted(true)
end

local function unmute()
  hs.audiodevice.defaultOutputDevice():setOutputMuted(false)
end

local handleWifiChanged = function()
  local currentSSID = hs.wifi.currentNetwork()

  if currentSSID == WORK_SSID1 or currentSSID == WORK_SSID2 then
    mute()
  else
    unmute()
  end
end

local wifiWatcher = hs.wifi.watcher.new(handleWifiChanged)
wifiWatcher:start()

return { watcher = wifiWatcher }
