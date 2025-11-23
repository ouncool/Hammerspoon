# Hammerspoon 快捷键参考

## 🔧 系统控制
| 快捷键 | 功能 |
|--------|------|
| `Cmd+Alt+Ctrl+R` | 重载 Hammerspoon 配置 |

## 🪟 窗口管理
| 快捷键 | 功能 |
|--------|------|
| `Alt+R` | 进入窗口管理模式 |
| └─ `h` | 左半屏 |
| └─ `l` | 右半屏 |
| └─ `j` | 下半屏 |
| └─ `k` | 上半屏 |
| └─ `y` | 左上角 1/4 |
| └─ `u` | 左下角 1/4 |
| └─ `i` | 右上角 1/4 |
| └─ `o` | 右下角 1/4 |
| └─ `f` | 最大化 |
| └─ `c` | 关闭窗口 |
| └─ `tab` | 显示帮助 |
| └─ `q/Esc` | 退出管理模式 |

## 🚀 应用启动
| 快捷键 | 功能 |
|--------|------|
| `Cmd+\`` | 环形应用启动器（按住显示，鼠标选择，松开启动）|

## 📁 Finder 集成
| 快捷键 | 功能 |
|--------|------|
| `Cmd+Alt+T` | 在 Ghostty 终端中打开当前 Finder 目录 |
| `Cmd+Alt+V` | 在 VS Code 中打开当前 Finder 目录 |

## ⌨️ 键盘增强
| 快捷键 | 功能 |
|--------|------|
| `Cmd+Shift+V` | 强制粘贴（绕过网站限制）|

## 📍 输入法指示器
- 顶部屏幕显示红色横条：当前为中文输入法
- 无显示：当前为英文输入法

## 🔔 自动功能
- **WiFi 自动静音**: 连接到公司 WiFi (MUDU) 时自动静音
- **工作提醒**:
  - 11:30 午休提醒
  - 17:30 下班提醒
- **输入法自动切换**:
  - 终端/编辑器/浏览器 → 英文
  - 其他应用 → 搜狗拼音

## ⚙️ 自定义配置

### 添加需要英文输入法的应用
编辑 `modules/input-method/auto-switch.lua`:
```lua
local ENGLISH_APPS = {
  '/Applications/Terminal.app',
  '/Applications/YourApp.app',  -- 添加你的应用
}
```

### 自定义环形启动器应用
编辑 `modules/window/launcher.lua`:
```lua
local APPLICATIONS = {
  { name = 'AppName', icon = '/Applications/AppName.app/Contents/Resources/icon.icns' },
}
```

### 修改快捷键
编辑 `modules/window/launcher.lua` 修改环形启动器快捷键:
```lua
local TRIGGER_MOD = 'cmd'      -- 修饰键
local TRIGGER_KEY = '`'        -- 触发键
```

## 💡 提示
1. 所有功能都可以在 `init.lua` 中启用/禁用
2. 配置文件采用模块化设计，易于维护和扩展
3. 查看 README.md 了解更多详细信息
