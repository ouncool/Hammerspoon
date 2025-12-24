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
│   │   └── manager.lua              # Vim风格窗口管理器
│   ├── keyboard/                     # 键盘增强
│   │   └── paste-helper.lua         # 粘贴助手
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

### 键盘增强
- **粘贴助手** (`Cmd + Shift + V`): 绕过网站粘贴限制



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

### 自定义窗口管理器
编辑 `modules/window/manager.lua`，修改快捷键或布局。


## 快捷键参考

| 快捷键 | 功能 |
|--------|------|
| `Cmd+Alt+Ctrl+R` | 重载配置 |
| `Alt+R` | 窗口管理模式 |
| `Cmd+Alt+T` | 在终端打开Finder目录 |
| `Cmd+Alt+V` | 在VS Code打开Finder目录 |
| `Cmd+Shift+V` | 强制粘贴 |

## 自动功能
- 输入法自动切换
- 预览 (Preview) 自动全屏：当在 Preview 中打开 PDF 文件时，模块 `modules/integration/preview-pdf-fullscreen.lua` 会尝试将窗口切换到全屏模式（已验证）。
   - 如果需要手工重载配置或调试，请使用 `hs.reload()` 或菜单热键 `Cmd+Alt+Ctrl+R`。

## 注意事项
1. 输入法ID需要根据实际安装的输入法修改

## 参考资料
- [Hammerspoon 官方文档](https://www.hammerspoon.org/docs/)
- [Hammerspoon API](https://www.hammerspoon.org/docs/index.html)

