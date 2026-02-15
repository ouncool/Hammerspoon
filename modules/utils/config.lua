-- Global configuration module (centralized management of adjustable parameters)
local config = {}

config.image = {
  -- JPEG quality (0-100), default can be adjusted as needed
  quality = 60,
  -- Maximum image dimension (pixels), will scale proportionally if exceeded
  maxDim = 1600,
}

config.window = {
  -- Two-third width ratio, default 2/3
  twoThirdRatio = 2/3,
}

config.inputMethod = {
  -- Default input method (Sogou Pinyin)
  default = 'com.sogou.inputmethod.sogou.pinyin',
  -- English input method
  english = 'com.apple.keylayout.ABC',
  -- Apps that need English input method
  englishApps = {
    '/Applications/Terminal.app',
    '/Applications/Ghostty.app',
    '/Applications/iTerm.app',
    '/Applications/Visual Studio Code.app',
    '/Applications/WebStorm.app',
    '/Applications/Raycast.app'
  }
}

config.appSwitcher = {
  -- Switch scope: "currentSpace" | "allSpaces"
  scope = "allSpaces",

  -- UI width (percentage of screen width)
  width = 0.4,

  -- Number of rows to show
  numRows = 8,

  -- Font size
  textSize = 16,
  subTextSize = 12,

  -- Colors (rgba format)
  bgColor = {red = 0.1, green = 0.1, blue = 0.1, alpha = 0.95},
  textColor = {red = 1, green = 1, blue = 1, alpha = 1},
  subTextColor = {red = 0.7, green = 0.7, blue = 0.7, alpha = 1},
  selectedColor = {red = 0.3, green = 0.5, blue = 1, alpha = 0.3},

  -- Show shadow
  shadow = true,

  -- Rounded corners
  radius = 10
}

return config
