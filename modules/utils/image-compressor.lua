-- **************************************************
-- Image compression tool
-- Function: Get image from clipboard -> Compress using sips -> Copy back to clipboard
-- **************************************************

local M = {}

-- Get temporary file path
local function getTempDir()
  return os.getenv('TMPDIR') or '/tmp'
end

local config = nil
pcall(function() config = require('modules.utils.config') end)

-- Get image from clipboard and save as temporary file
local function exportImageFromPasteboard()
  local tempDir = getTempDir()
  local outputFile = tempDir .. '/clipboard_image_' .. tostring(os.time()) .. '.tiff'
  
  -- Use osascript to export image from clipboard
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
    return nil, result ~= '' and result or 'Unable to export image from clipboard'
  end
  
  return result, nil
end

-- Compress image using sips
local function compressImage(inputPath, quality, maxDim)
  -- quality: JPEG quality (0-100), maxDim: max image dimension (pixels), can be nil
  quality = quality or 60  -- Default quality 60, aggressive to reduce size
  -- If maxDim not provided, default to limit max dimension to help reduce size
  maxDim = (maxDim == nil) and 1600 or maxDim
  
  if not hs.fs.pathToAbsolute(inputPath) then
    return nil, 'Invalid input file path'
  end
  
  local tempDir = getTempDir()
  local outputPath = tempDir .. '/compressed_' .. tostring(os.time()) .. '.jpg'
  local intermediatePath = nil

  -- If maxDim specified (>0), first resize to max dimension, generate intermediate file
  if maxDim and tonumber(maxDim) and tonumber(maxDim) > 0 then
    intermediatePath = tempDir .. '/resized_' .. tostring(os.time()) .. '.png'
    local resizeCmd = string.format('sips -Z %d "%s" --out "%s" 2>&1', tonumber(maxDim), inputPath, intermediatePath)
    local h1 = io.popen(resizeCmd)
    local out1 = h1:read('*a')
    h1:close()
    -- If intermediate file not generated, skip resize
    if not hs.fs.pathToAbsolute(intermediatePath) then
      intermediatePath = nil
    end
  end

  -- Use intermediate file (if exists) or original as input, generate final JPEG
  local src = intermediatePath or inputPath
  local cmd = string.format('sips -s format jpeg -s formatOptions %d "%s" --out "%s" 2>&1',
    tonumber(quality), src, outputPath)
  local handle = io.popen(cmd)
  local output = handle:read('*a')
  handle:close()

  if not hs.fs.pathToAbsolute(outputPath) then
    -- Clean up intermediate file
    if intermediatePath and hs.fs.pathToAbsolute(intermediatePath) then os.remove(intermediatePath) end
    return nil, 'Image compression failed: ' .. (output or '')
  end

  -- Clean up intermediate file
  if intermediatePath and hs.fs.pathToAbsolute(intermediatePath) then os.remove(intermediatePath) end

  return outputPath, nil
end

-- Copy image to clipboard - using the simplest reliable method
local function copyImageToPasteboard(imagePath)
  if not hs.fs.pathToAbsolute(imagePath) then
    return false, 'Invalid file path'
  end
  
  -- Check if file exists
  local file = io.open(imagePath, 'rb')
  if not file then
    return false, 'File does not exist or cannot be read'
  end
  file:close()
  
  -- Method 1: Direct AppleScript one-liner
  local escapedPath = imagePath:gsub('"', '\\"')
  local cmd = string.format(
    'osascript -e "set the clipboard to (read (POSIX file \\"%s\\") as JPEG picture)" 2>&1',
    escapedPath
  )
  
  local handle = io.popen(cmd)
  local result = handle:read('*a'):gsub('\n', ''):gsub('\r', '')
  handle:close()
  
  -- Success (no error message)
  if result == '' then
    return true, 'ok'
  end
  
  print('[DEBUG] AppleScript result: ' .. result)
  
  -- If first method fails, try method 2: Convert with tiffutil then copy
  local tiffPath = imagePath:gsub('%.jpg$', '.tiff')
  if tiffPath == imagePath then
    tiffPath = imagePath .. '.tiff'
  end
  
  local convertCmd = string.format('tiffutil -convert "%s" -out "%s" 2>&1', imagePath, tiffPath)
  os.execute(convertCmd)
  
  -- Use AppleScript to copy TIFF image
  local escapedTiffPath = tiffPath:gsub('"', '\\"')
  local cmd2 = string.format(
    'osascript -e "set the clipboard to (read (POSIX file \\"%s\\") as TIFF picture)" 2>&1',
    escapedTiffPath
  )
  
  local handle2 = io.popen(cmd2)
  local result2 = handle2:read('*a'):gsub('\n', ''):gsub('\r', '')
  handle2:close()
  
  -- Clean up temporary TIFF file
  if hs.fs.pathToAbsolute(tiffPath) then
    os.remove(tiffPath)
  end
  
  if result2 == '' then
    return true, 'ok'
  end
  
  print('[DEBUG] TIFF AppleScript result: ' .. result2)
  
  return false, 'Failed to copy to clipboard'
end

-- Clean up temporary files
local function cleanupTempFile(filePath)
  if filePath and hs.fs.pathToAbsolute(filePath) then
    os.remove(filePath)
  end
end

-- Optional parameters: quality (0-100), maxDim (pixels), both can be passed to override defaults
function M.compressImageFromPasteboard(quality, maxDim)
  -- Prefer passed parameters, then centralized config (if exists), then file defaults
  local defaultQuality = 60
  local defaultMaxDim = 1600
  if config and config.image then
    defaultQuality = config.image.quality or defaultQuality
    defaultMaxDim = config.image.maxDim or defaultMaxDim
  end

  quality = quality or defaultQuality
  maxDim = (maxDim == nil) and defaultMaxDim or maxDim
  
  hs.alert.show('Processing image...')
  
  -- Get image from clipboard
  local imagePath, err = exportImageFromPasteboard()
  if not imagePath then
    hs.alert.show('❌ ' .. (err or 'Failed to get image from clipboard'))
    return false
  end
  
  -- Compress image (resize to maxDim then compress)
  local compressedPath, compressErr = compressImage(imagePath, quality, maxDim)
  if not compressedPath then
    cleanupTempFile(imagePath)
    hs.alert.show('❌ ' .. (compressErr or 'Failed to compress image'))
    return false
  end
  
  -- Copy to clipboard
  local ok, copyErr = copyImageToPasteboard(compressedPath)
  
  -- Clean up temporary files
  cleanupTempFile(imagePath)
  cleanupTempFile(compressedPath)
  
  if ok then
    hs.alert.show('✅ Image compressed and copied to clipboard')
    return true
  else
    hs.alert.show('❌ ' .. (copyErr or 'Failed to copy to clipboard'))
    return false
  end
end

return M
