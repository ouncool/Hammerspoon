-- 全局配置模块（集中管理可调参数）
local config = {}

config.image = {
  -- JPEG 质量 (0-100)，默认值可按需调整
  quality = 60,
  -- 图片最大边长（像素），超过会按比例缩放到此边长
  maxDim = 1600,
}

-- 其他潜在配置，可按需添加
config.window = {
  -- twoThird 宽度比例，默认 2/3
  twoThirdRatio = 2/3,
}

return config
