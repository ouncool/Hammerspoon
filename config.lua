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
  appSwitcher = {
    next = {mods = {'alt'}, key = 'tab'},
    previous = {mods = {'alt', 'shift'}, key = 'tab'},
  },
  pasteHelper = {
    mods = {'cmd', 'shift'},
    key = 'V',
  },
  hyper = {
    browser = 'G',
    terminal = 'T',
    finderTerminal = 'F',
    finderEditor = 'V',
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

config.appSwitcher = {
  scope = 'allSpaces',
  width = 0.4,
  numRows = 8,
  textSize = 16,
  subTextSize = 12,
  includeNoWindowBundleIds = {
    'com.tencent.flue.WeChatAppEx',
    'com.tencent.xinWeChat',
    'com.tencent.WeWorkMac',
  },
  bgColor = {red = 0.1, green = 0.1, blue = 0.1, alpha = 0.95},
  textColor = {red = 1, green = 1, blue = 1, alpha = 1},
  subTextColor = {red = 0.7, green = 0.7, blue = 0.7, alpha = 1},
  selectedColor = {red = 0.3, green = 0.5, blue = 1, alpha = 0.3},
  shadow = true,
  radius = 10,
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
