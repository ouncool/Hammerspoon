# Hammerspoon 配置

个人精简的 Hammerspoon 配置，采用模块化设计，只保留实用功能。

## 目录结构

```
~/.hammerspoon/
├── init.lua                          # 主入口文件
├── modules/                          # 所有功能模块
│   ├── input-method/                 # 输入法相关
│   │   ├── auto-switch.lua          # 自动切换输入法
│   │   └── indicator.lua            # 输入法状态指示器
│   ├── window/                       # 窗口管理
│   │   ├── manager.lua              # Vim风格窗口管理器
│   │   └── launcher.lua             # 环形应用启动器
│   ├── keyboard/                     # 键盘增强
│   │   └── paste-helper.lua         # 粘贴助手
│   ├── work/                         # 工作相关
│   │   ├── wifi-mute.lua            # WiFi自动静音
│   │   └── reminder.lua             # 工作时间提醒
│   ├── integration/                  # 应用集成
│   │   └── finder-terminal.lua      # Finder与终端/编辑器集成
│   └── utils/                        # 工具库
│       ├── functions.lua            # 工具函数
│       └── animation.lua            # 动画函数
└── Spoons/                           # Hammerspoon Spoons
```

## 功能列表

### 输入法管理
- **自动切换**: 默认使用搜狗拼音，指定应用（终端、编辑器、浏览器）自动切换为英文
- **状态指示**: 屏幕顶部显示红色横条表示中文输入法

### 窗口管理
- **Vim风格管理器** (`Alt + R`):
  - `h/l/j/k`: 左/右/下/上半屏
  - `y/u/i/o`: 四个角的四分之一屏
  - `H/L`: 左/右 三分之二 屏（大写 H / L）
  - `f`: 最大化
  - `c`: 关闭窗口
  - `tab`: 显示帮助
  - `q/Esc`: 退出管理模式
- **环形启动器** (`Cmd + \``): 按住显示环形菜单，鼠标选择应用，松开启动

### 键盘增强
- **粘贴助手** (`Cmd + Shift + V`): 绕过网站粘贴限制

### 工作助手
- **WiFi自动静音**: 连接到公司WiFi时自动静音
- **时间提醒**: 11:30和17:30定时提醒

### 应用集成
- **Finder → 终端** (`Cmd + Alt + T`): 在 Ghostty 终端中打开当前 Finder 目录
- **Finder → VS Code** (`Cmd + Alt + V`): 在 VS Code 中打开当前 Finder 目录

## 使用说明

### 安装
1. 安装 Hammerspoon: `brew install hammerspoon`
2. 将此配置放到 `~/.hammerspoon/`
3. 重载配置: `Cmd + Alt + Ctrl + R`

### 自定义输入法应用列表
编辑 `modules/input-method/auto-switch.lua`，修改 `ENGLISH_APPS` 列表：

```lua
local ENGLISH_APPS = {
  '/Applications/Terminal.app',
  '/Applications/Ghostty.app',
  '/Applications/Visual Studio Code.app',
  -- 添加更多应用...
}
```

### 自定义环形启动器应用
编辑 `modules/window/launcher.lua`，修改 `APPLICATIONS` 列表：

```lua
local APPLICATIONS = {
  { name = 'WeChat', icon = '/Applications/WeChat.app/Contents/Resources/AppIcon.icns' },
  { name = 'Google Chrome', icon = '/Applications/Google Chrome.app/Contents/Resources/app.icns' },
  -- 添加更多应用...
}
```

### 修改快捷键
所有快捷键都在各自的模块文件中定义，可以根据需要修改。

### 图片压缩模块（剪切板）
项目新增了一个图片压缩模块，用于将剪切板中的图片压缩并复制回剪切板，常用于快速粘贴体积较小的截图或图片。

- 触发方式：进入窗口管理模式（`Alt + R`），在模式下快速按两次 `i`（即 `ii`）会执行压缩并复制回剪切板。
- 默认行为：先将图片按比例缩放到最大边长 `1600` 像素（可配置），然后以 JPEG 格式导出，默认质量 `60`（可配置）。
- 配置项：可在 `modules/utils/config.lua` 中修改默认值：
  - `image.quality`：JPEG 压缩质量（0-100），默认 `60`。
  - `image.maxDim`：最大边长（像素），默认 `1600`。

示例：编辑 `modules/utils/config.lua`，例如把质量设为 50：

```lua
config = require('modules.utils.config')
config.image.quality = 50
```

（或者直接在 `image-compressor` 的调用处传入参数：`compressImageFromPasteboard(quality, maxDim)`）

## 快捷键参考

| 快捷键 | 功能 |
|--------|------|
| `Cmd+Alt+Ctrl+R` | 重载配置 |
| `Alt+R` | 窗口管理模式 |
| `Cmd+\`` | 环形启动器 |
| `Cmd+Alt+T` | 在终端打开Finder目录 |
| `Cmd+Alt+V` | 在VS Code打开Finder目录 |
| `Cmd+Shift+V` | 强制粘贴 |

## 自动功能
- WiFi自动静音（连接到MUDU）
- 工作时间提醒（11:30/17:30）
- 输入法自动切换
 - 预览 (Preview) 自动全屏：当在 Preview 中打开 PDF 文件时，模块 `modules/integration/preview-pdf-fullscreen.lua` 会尝试将窗口切换到全屏模式（已验证）。
   - 如果需要手工重载配置或调试，请使用 `hs.reload()` 或菜单热键 `Cmd+Alt+Ctrl+R`。

## 注意事项
1. 输入法ID需要根据实际安装的输入法修改
2. WiFi名称需要在 `modules/work/wifi-mute.lua` 中修改
3. 工作提醒时间可在 `modules/work/reminder.lua` 中自定义

## 参考资料
- [Hammerspoon 官方文档](https://www.hammerspoon.org/docs/)
- [Hammerspoon API](https://www.hammerspoon.org/docs/index.html)

## 归档与备份
- 旧脚本与备份文件已移动到 `legacy/` 目录，例如 `legacy/1.lua`、`legacy/inputswith2.lua`，主目录仅保留模块化实现。

## 本地配置示例（`.env`）

为了避免将公司或个人的敏感配置（例如 Wi‑Fi 名称、输入法 ID 等）提交到仓库，项目支持在本地放置一个不被提交的 `.env` 文件（位置：`~/.hammerspoon/.env`）。以下是 `example.env` 中的示例内容，复制并根据需要修改为你的本地值：

```
# Example env file for ~/.hammerspoon
#
# This file is intended as a harmless example to show how to configure
# local, sensitive values such as company Wi‑Fi SSIDs. Do NOT put real
# secrets here if you plan to commit this file; instead copy this to
# `.env` and edit the real values locally. The real `.env` file is
# ignored by `.gitignore`.
#
# Options:
# - WORK_SSIDS: comma-separated list of SSIDs
# - WORK_SSID1 / WORK_SSID2 ... : alternate individual entries

# Example using a comma-separated list:
WORK_SSIDS=COMPANY_WIFI,COMPANY_WIFI_5G

# Or using individual variables:
#WORK_SSID1=COMPANY_WIFI
#WORK_SSID2=COMPANY_WIFI_5G
```

模块 `modules/work/wifi-mute.lua` 会优先读取 `~/.hammerspoon/.env` 中的 `WORK_SSIDS` 或 `WORK_SSID*`，若不存在则使用文件中内置的默认值。
