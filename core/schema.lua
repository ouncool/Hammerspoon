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
