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

return config
