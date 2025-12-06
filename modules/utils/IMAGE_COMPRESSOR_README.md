# 图片压缩模块 (Image Compressor)

## 功能说明

此模块为 Hammerspoon 窗口管理器添加了快速图片压缩功能。

### 快捷键

进入 Vim 模式：`Option + R`

在 Vim 模式中压缩图片：`ii`

## 工作流程

1. **复制图片到剪切板**
   - 在任何应用中复制图片到剪切板

2. **进入 Vim 模式**
   - 按下 `Option + R` 进入窗口管理模式

3. **执行压缩命令**
   - 快速按下 `i` 两次（`ii`）

4. **结果**
   - 压缩后的图片会自动复制回剪切板
   - 系统会显示完成提示

## 技术细节

### 使用工具
- **sips**: macOS 原生图片工具，用于压缩和格式转换
- **AppleScript**: 与剪切板交互
- **Lua**: 事件处理和逻辑控制

### 压缩参数
- 默认质量：60（可调整，通过 `modules/utils/config.lua` 中 `image.quality` 修改）
- 最大边长：1600（像素），超过会先缩放再压缩，通过 `modules/utils/config.lua` 中 `image.maxDim` 修改
- 输出格式：JPEG
- 临时文件自动清理

## 文件位置

- 主模块：`modules/utils/image-compressor.lua`
- 集成文件：`modules/window/manager.lua`

## 备注

- 处理大图片时可能需要几秒钟
- `ii` 命令与原有的 `i` 键（右上四分窗口）兼容
- 单次按 `i` 后 0.5 秒内如未按第二次，则执行窗口调整
