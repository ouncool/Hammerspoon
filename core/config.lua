local Config = {}

local Logger = require('core.logger')
local log = Logger.scope('Config')

local defaults = {
  logging = {
    level = 'INFO',
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
  },
  previewPdf = {
    appNames = {'Preview', '预览'},
    bundleId = 'com.apple.Preview',
    debounceSec = 0.2,
    fullscreenDelaySec = 0.5,
  },
}

local schema = {
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

local snapshot = nil

local function isArray(value, allowEmpty)
  if type(value) ~= 'table' then
    return false
  end

  local max = 0
  local count = 0
  for key, _ in pairs(value) do
    if type(key) ~= 'number' or key < 1 or key % 1 ~= 0 then
      return false
    end
    if key > max then
      max = key
    end
    count = count + 1
  end

  if count == 0 then
    return allowEmpty == true
  end

  return max == count
end

local function deepCopy(value)
  if type(value) ~= 'table' then
    return value
  end

  local result = {}
  for key, inner in pairs(value) do
    result[key] = deepCopy(inner)
  end
  return result
end

local function deepMerge(base, override)
  if type(base) ~= 'table' then
    return deepCopy(override)
  end

  local result = deepCopy(base)
  if type(override) ~= 'table' then
    return result
  end

  for key, value in pairs(override) do
    local current = result[key]
    if type(value) == 'table' and type(current) == 'table' and (not isArray(value, false)) and (not isArray(current, false)) then
      result[key] = deepMerge(current, value)
    else
      result[key] = deepCopy(value)
    end
  end

  return result
end

local function addError(errors, path, message)
  table.insert(errors, string.format('%s: %s', path, message))
end

local function validateNode(value, node, path, errors)
  local expectedType = node.type

  if expectedType == 'array' then
    if type(value) ~= 'table' or not isArray(value, true) then
      addError(errors, path, 'expected array')
      return
    end

    for index, item in ipairs(value) do
      validateNode(item, node.items, string.format('%s[%d]', path, index), errors)
    end
    return
  end

  if expectedType == 'table' then
    if type(value) ~= 'table' then
      addError(errors, path, 'expected table')
      return
    end

    local fields = node.fields or {}
    for key, inner in pairs(value) do
      if fields[key] == nil then
        addError(errors, path .. '.' .. key, 'unknown key')
      end
    end

    for key, childSchema in pairs(fields) do
      local childValue = value[key]
      if childValue == nil then
        addError(errors, path .. '.' .. key, 'missing key')
      else
        validateNode(childValue, childSchema, path .. '.' .. key, errors)
      end
    end

    return
  end

  if type(value) ~= expectedType then
    addError(errors, path, string.format('expected %s, got %s', expectedType, type(value)))
    return
  end

  if expectedType == 'string' then
    if node.pattern and not string.match(value, node.pattern) then
      addError(errors, path, 'pattern mismatch')
    end

    if node.enum then
      local found = false
      for _, option in ipairs(node.enum) do
        if option == value then
          found = true
          break
        end
      end
      if not found then
        addError(errors, path, 'value is not in enum')
      end
    end
  end

  if expectedType == 'number' then
    if node.min and value < node.min then
      addError(errors, path, string.format('must be >= %s', node.min))
    end
    if node.max and value > node.max then
      addError(errors, path, string.format('must be <= %s', node.max))
    end
  end
end

local function validate(config)
  local errors = {}
  validateNode(config, schema, 'config', errors)
  return #errors == 0, errors
end

local function loadUserConfig()
  package.loaded.config = nil
  local ok, userConfig = pcall(require, 'config')
  if not ok then
    local err = tostring(userConfig)
    if string.find(err, "module 'config' not found", 1, true) then
      return {}, 'config.lua not found, using defaults'
    end
    return nil, 'failed to load config.lua: ' .. err
  end

  if type(userConfig) ~= 'table' then
    return nil, 'config.lua must return a table'
  end

  return userConfig, nil
end

function Config.reload()
  local userConfig, loadErr = loadUserConfig()
  if userConfig == nil then
    snapshot = deepCopy(defaults)
    return false, {loadErr}
  end

  local merged = deepMerge(defaults, userConfig)
  local ok, errors = validate(merged)
  if not ok then
    snapshot = deepCopy(defaults)
    return false, errors
  end

  snapshot = merged

  if loadErr then
    log.warn(loadErr)
  end

  return true, {}
end

function Config.get()
  if snapshot == nil then
    local ok, errors = Config.reload()
    if not ok then
      for _, err in ipairs(errors) do
        log.error(err)
      end
    end
  end
  return deepCopy(snapshot)
end

function Config.defaults()
  return deepCopy(defaults)
end

return Config
