-- User configuration (strictly validated by core/config.lua)

local config = {}

config.logging = {
  level = 'INFO',
  console = true,
  notification = false,
}

config.hotkeys = {
  reload = {
    mods = {'cmd', 'alt', 'ctrl'},
    key = 'R',
  },
  hyperMods = {'cmd', 'alt', 'ctrl', 'shift'},
  windowMode = {
    key = 'R',
  },
}

config.inputMethod = {
  default = 'com.sogou.inputmethod.sogou.pinyin',
  english = 'com.apple.keylayout.ABC',
  englishApps = {
    '/Applications/Terminal.app',
    '/Applications/Ghostty.app',
    '/Applications/iTerm.app',
    '/Applications/Visual Studio Code.app',
    '/Applications/WebStorm.app',
    '/Applications/Raycast.app',
  },
}

config.window = {
  twoThirdRatio = 2 / 3,
}

config.apps = {
  browsers = {
    '/Applications/Google Chrome.app',
    '/Applications/Brave Browser.app',
    '/Applications/Firefox.app',
    '/Applications/Safari.app',
  },
  terminals = {
    '/Applications/Ghostty.app',
    '/Applications/iTerm.app',
    '/Applications/Terminal.app',
  },
  editors = {
    {
      app = '/Applications/Visual Studio Code.app',
      cli = 'code',
    },
  },
}

config.previewPdf = {
  appNames = {'Preview', '预览'},
  bundleId = 'com.apple.Preview',
  debounceSec = 0.2,
  fullscreenDelaySec = 0.5,
}

return config
