-- **************************************************
-- 图片压缩工具
-- 功能：从剪切板获取图片 -> 使用 sips 压缩 -> 复制回剪切板
-- **************************************************

local M = {}

-- 获取临时文件路径
local function getTempDir()
  return os.getenv('TMPDIR') or '/tmp'
end

local config = nil
pcall(function() config = require('modules.utils.config') end)

-- 从剪切板获取图片并保存为临时文件
local function exportImageFromPasteboard()
  local tempDir = getTempDir()
  local outputFile = tempDir .. '/clipboard_image_' .. tostring(os.time()) .. '.tiff'
  
  -- 使用 osascript 导出剪切板中的图片
  local script = string.format(
    [[osascript << 'APPLESCRIPT_EOF'
on run
  try
    set imageData to (the clipboard as TIFF picture)
    set imageFile to (open for access POSIX file "%s" with write permission)
    write imageData to imageFile
    close access imageFile
    return "%s"
  on error err
    return "error: " & err
  end try
end run
APPLESCRIPT_EOF
]],
    outputFile,
    outputFile
  )
  
  local handle = io.popen(script)
  local result = handle:read('*a'):gsub('\n', ''):gsub('\r', '')
  handle:close()
  
  if result:find('error') or not hs.fs.pathToAbsolute(result) then
    return nil, result ~= '' and result or '无法从剪切板导出图片'
  end
  
  return result, nil
end

-- 使用 sips 压缩图片
local function compressImage(inputPath, quality, maxDim)
  -- quality: JPEG 质量（0-100），maxDim: 图片最大边长（像素），两者可为空
  quality = quality or 60  -- 默认质量 60，较为激进以减小体积
  -- 如果没有传入 maxDim，则默认限制最大边长，帮助减小体积
  maxDim = (maxDim == nil) and 1600 or maxDim
  
  if not hs.fs.pathToAbsolute(inputPath) then
    return nil, '输入文件路径无效'
  end
  
  local tempDir = getTempDir()
  local outputPath = tempDir .. '/compressed_' .. tostring(os.time()) .. '.jpg'
  local intermediatePath = nil

  -- 如果指定了 maxDim（>0），先缩放到指定最大边长，生成中间文件
  if maxDim and tonumber(maxDim) and tonumber(maxDim) > 0 then
    intermediatePath = tempDir .. '/resized_' .. tostring(os.time()) .. '.png'
    local resizeCmd = string.format('sips -Z %d "%s" --out "%s" 2>&1', tonumber(maxDim), inputPath, intermediatePath)
    local h1 = io.popen(resizeCmd)
    local out1 = h1:read('*a')
    h1:close()
    -- 如果中间文件未生成，则放弃 resize
    if not hs.fs.pathToAbsolute(intermediatePath) then
      intermediatePath = nil
    end
  end

  -- 以中间文件（如果存在）或原始文件为输入，生成最终 JPEG
  local src = intermediatePath or inputPath
  local cmd = string.format('sips -s format jpeg -s formatOptions %d "%s" --out "%s" 2>&1',
    tonumber(quality), src, outputPath)
  local handle = io.popen(cmd)
  local output = handle:read('*a')
  handle:close()

  if not hs.fs.pathToAbsolute(outputPath) then
    -- 清理中间文件
    if intermediatePath and hs.fs.pathToAbsolute(intermediatePath) then os.remove(intermediatePath) end
    return nil, '图片压缩失败: ' .. (output or '')
  end

  -- 清理中间文件
  if intermediatePath and hs.fs.pathToAbsolute(intermediatePath) then os.remove(intermediatePath) end

  return outputPath, nil
end

-- 将图片复制到剪切板 - 使用最简单可靠的方法
local function copyImageToPasteboard(imagePath)
  if not hs.fs.pathToAbsolute(imagePath) then
    return false, '文件路径无效'
  end
  
  -- 检查文件是否存在
  local file = io.open(imagePath, 'rb')
  if not file then
    return false, '文件不存在或无法读取'
  end
  file:close()
  
  -- 方法1：直接使用 AppleScript 一行命令
  local escapedPath = imagePath:gsub('"', '\\"')
  local cmd = string.format(
    'osascript -e "set the clipboard to (read (POSIX file \\"%s\\") as JPEG picture)" 2>&1',
    escapedPath
  )
  
  local handle = io.popen(cmd)
  local result = handle:read('*a'):gsub('\n', ''):gsub('\r', '')
  handle:close()
  
  -- 成功（没有错误信息）
  if result == '' then
    return true, 'ok'
  end
  
  print('[DEBUG] AppleScript result: ' .. result)
  
  -- 如果第一种方法失败，尝试方法2：使用 tiffutil 转换后再复制
  local tiffPath = imagePath:gsub('%.jpg$', '.tiff')
  if tiffPath == imagePath then
    tiffPath = imagePath .. '.tiff'
  end
  
  local convertCmd = string.format('tiffutil -convert "%s" -out "%s" 2>&1', imagePath, tiffPath)
  os.execute(convertCmd)
  
  -- 使用 AppleScript 复制 TIFF 图片
  local escapedTiffPath = tiffPath:gsub('"', '\\"')
  local cmd2 = string.format(
    'osascript -e "set the clipboard to (read (POSIX file \\"%s\\") as TIFF picture)" 2>&1',
    escapedTiffPath
  )
  
  local handle2 = io.popen(cmd2)
  local result2 = handle2:read('*a'):gsub('\n', ''):gsub('\r', '')
  handle2:close()
  
  -- 清理临时 TIFF 文件
  if hs.fs.pathToAbsolute(tiffPath) then
    os.remove(tiffPath)
  end
  
  if result2 == '' then
    return true, 'ok'
  end
  
  print('[DEBUG] TIFF AppleScript result: ' .. result2)
  
  return false, '复制到剪切板失败'
end

-- 清理临时文件
local function cleanupTempFile(filePath)
  if filePath and hs.fs.pathToAbsolute(filePath) then
    os.remove(filePath)
  end
end

-- 可选参数：quality (0-100), maxDim (像素)，两者均可传入以覆盖默认
function M.compressImageFromPasteboard(quality, maxDim)
  -- 优先使用传入参数，否则使用集中配置（若存在），否则使用文件内默认
  local defaultQuality = 60
  local defaultMaxDim = 1600
  if config and config.image then
    defaultQuality = config.image.quality or defaultQuality
    defaultMaxDim = config.image.maxDim or defaultMaxDim
  end

  quality = quality or defaultQuality
  maxDim = (maxDim == nil) and defaultMaxDim or maxDim
  
  hs.alert.show('正在处理图片...')
  
  -- 获取剪切板中的图片
  local imagePath, err = exportImageFromPasteboard()
  if not imagePath then
    hs.alert.show('❌ ' .. (err or '获取剪切板图片失败'))
    return false
  end
  
  -- 压缩图片（按 maxDim 缩放后压缩）
  local compressedPath, compressErr = compressImage(imagePath, quality, maxDim)
  if not compressedPath then
    cleanupTempFile(imagePath)
    hs.alert.show('❌ ' .. (compressErr or '压缩图片失败'))
    return false
  end
  
  -- 复制到剪切板
  local ok, copyErr = copyImageToPasteboard(compressedPath)
  
  -- 清理临时文件
  cleanupTempFile(imagePath)
  cleanupTempFile(compressedPath)
  
  if ok then
    hs.alert.show('✅ 图片已压缩并复制到剪切板')
    return true
  else
    hs.alert.show('❌ ' .. (copyErr or '复制到剪切板失败'))
    return false
  end
end

return M
