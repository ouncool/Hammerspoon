-- Configuration schema and defaults
local Schema = {}

Schema.defaults = {
  logging = {
    level = 'WARN',
    console = true,
    notification = false,
  },
  hotkeys = {
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
  },
  inputMethod = {
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
  },
  window = {
    twoThirdRatio = 2 / 3,
  },
  appSwitcher = {
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
  },
  apps = {
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
    wechat = '/Applications/WeChat.app',
    weworkMac = '/Applications/企业微信.app',
  },
  previewPdf = {
    appNames = {'Preview', '预览'},
    bundleId = 'com.apple.Preview',
    debounceSec = 0.2,
    fullscreenDelaySec = 0.5,
  },
}

Schema.definition = {
  type = 'table',
  fields = {
    logging = {
      type = 'table',
      fields = {
        level = {type = 'string', enum = {'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'}},
        console = {type = 'boolean'},
        notification = {type = 'boolean'},
      },
    },
    hotkeys = {
      type = 'table',
      fields = {
        reload = {
          type = 'table',
          fields = {
            mods = {type = 'array', items = {type = 'string'}},
            key = {type = 'string'},
          },
        },
        hyperMods = {type = 'array', items = {type = 'string'}},
        windowMode = {
          type = 'table',
          fields = {
            key = {type = 'string'},
          },
        },
        appSwitcher = {
          type = 'table',
          fields = {
            next = {
              type = 'table',
              fields = {
                mods = {type = 'array', items = {type = 'string'}},
                key = {type = 'string'},
              },
            },
            previous = {
              type = 'table',
              fields = {
                mods = {type = 'array', items = {type = 'string'}},
                key = {type = 'string'},
              },
            },
          },
        },
        pasteHelper = {
          type = 'table',
          fields = {
            mods = {type = 'array', items = {type = 'string'}},
            key = {type = 'string'},
          },
        },
        hyper = {
          type = 'table',
          fields = {
            browser = {type = 'string'},
            terminal = {type = 'string'},
            finderTerminal = {type = 'string'},
            finderEditor = {type = 'string'},
          },
        },
      },
    },
    inputMethod = {
      type = 'table',
      fields = {
        default = {type = 'string', pattern = '^[%w%._%-]+$'},
        english = {type = 'string', pattern = '^[%w%._%-]+$'},
        englishApps = {type = 'array', items = {type = 'string'}},
      },
    },
    window = {
      type = 'table',
      fields = {
        twoThirdRatio = {type = 'number', min = 0.1, max = 0.9},
      },
    },
    appSwitcher = {
      type = 'table',
      fields = {
        scope = {type = 'string', enum = {'allSpaces', 'currentSpace'}},
        width = {type = 'number', min = 0.2, max = 0.95},
        numRows = {type = 'number', min = 3, max = 20},
        textSize = {type = 'number', min = 10, max = 40},
        subTextSize = {type = 'number', min = 8, max = 30},
        includeNoWindowBundleIds = {type = 'array', items = {type = 'string'}},
        bgColor = {type = 'table', fields = {
          red = {type = 'number', min = 0, max = 1},
          green = {type = 'number', min = 0, max = 1},
          blue = {type = 'number', min = 0, max = 1},
          alpha = {type = 'number', min = 0, max = 1},
        }},
        textColor = {type = 'table', fields = {
          red = {type = 'number', min = 0, max = 1},
          green = {type = 'number', min = 0, max = 1},
          blue = {type = 'number', min = 0, max = 1},
          alpha = {type = 'number', min = 0, max = 1},
        }},
        subTextColor = {type = 'table', fields = {
          red = {type = 'number', min = 0, max = 1},
          green = {type = 'number', min = 0, max = 1},
          blue = {type = 'number', min = 0, max = 1},
          alpha = {type = 'number', min = 0, max = 1},
        }},
        selectedColor = {type = 'table', fields = {
          red = {type = 'number', min = 0, max = 1},
          green = {type = 'number', min = 0, max = 1},
          blue = {type = 'number', min = 0, max = 1},
          alpha = {type = 'number', min = 0, max = 1},
        }},
        shadow = {type = 'boolean'},
        radius = {type = 'number', min = 0, max = 40},
      },
    },
    apps = {
      type = 'table',
      fields = {
        browsers = {type = 'array', items = {type = 'string'}},
        terminals = {type = 'array', items = {type = 'string'}},
        editors = {
          type = 'array',
          items = {
            type = 'table',
            fields = {
              app = {type = 'string'},
              cli = {type = 'string'},
            },
          },
        },
        wechat = {type = 'string'},
        weworkMac = {type = 'string'},
      },
    },
    previewPdf = {
      type = 'table',
      fields = {
        appNames = {type = 'array', items = {type = 'string'}},
        bundleId = {type = 'string'},
        debounceSec = {type = 'number', min = 0.05, max = 3},
        fullscreenDelaySec = {type = 'number', min = 0.05, max = 5},
      },
    },
  },
}

return Schema
