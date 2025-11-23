# 配置修复说明

## 已修复的问题

### 1. LeftRightHotkey Spoon 依赖问题
**问题**: 原代码依赖外部 Spoon `LeftRightHotkey`，但该 Spoon 未安装或为空。

**解决方案**:
- 重写了 `modules/keyboard/arrow-remap.lua`
- 使用原生的 `hs.hotkey.bind()` 替代 Spoon
- 现在使用 **Shift + WASD** 映射方向键（无法区分左右Shift，但功能正常）

### 2. Caffeine Spoon 依赖问题
**问题**: 原代码依赖外部 Spoon `Caffeine`，但该 Spoon 未安装或为空。

**解决方案**:
- 重写了 `modules/system/caffeine.lua`
- 使用原生的 `hs.caffeinate` API 和 `hs.menubar` 实现
- 在菜单栏显示图标：☕️(激活) / 💤(未激活)
- 点击图标可切换防睡眠状态

### 3. 添加错误处理
**改进**: 在 `init.lua` 中添加了 `loadModule()` 函数
- 使用 `pcall()` 安全加载每个模块
- 加载失败时会显示通知和控制台日志
- 不会因为单个模块失败而导致整个配置崩溃

## 当前配置状态

### ✅ 已启用的模块
- 输入法指示器
- 窗口管理器 (Alt+R)
- 环形启动器 (Alt+Tab)
- 方向键映射 (Shift+WASD)
- 粘贴助手 (Cmd+Shift+V)
- WiFi自动静音
- 工作时间提醒
- Finder终端集成 (Cmd+Alt+T)
- Launchpad快捷键 (Cmd+Space)
- 鼠标滚轮修复
- Caffeine防睡眠

### ⏸️ 已禁用的模块（需要时可启用）
- 输入法自动切换 (`modules.input-method.auto-switch`)
- 输入法强制锁定 (`modules.input-method.lock`)

## 如何启用已禁用的模块

编辑 `/Users/mac/.hammerspoon/init.lua`，取消注释相应行：

```lua
-- 启用输入法自动切换
loadModule('modules.input-method.auto-switch')

-- 启用输入法强制锁定
loadModule('modules.input-method.lock')
```

## 如何重载配置

按下快捷键: **Cmd + Alt + Ctrl + R**

## 自定义配置

### 修改WiFi静音的SSID
编辑 `modules/work/wifi-mute.lua`，修改第7行：
```lua
local WORK_SSID = 'YOUR_WIFI_NAME'
```

### 修改工作提醒时间
编辑 `modules/work/reminder.lua`，修改第6-9行：
```lua
local reminders = {
  { hour = 11, min = 30, title = '午休提醒', msg = '...' },
  { hour = 17, min = 30, title = '下班提醒', msg = '...' },
}
```

### 修改输入法ID
编辑 `modules/input-method/auto-switch.lua` 或 `lock.lua`，查看当前输入法ID：
```bash
hs.keycodes.currentSourceID()
```

## 注意事项

1. **方向键映射**: 现在使用任意Shift键，如需只使用右Shift，需要安装 LeftRightHotkey Spoon
2. **输入法模块**: 需要根据您实际安装的输入法修改ID
3. **应用路径**: 某些模块中的应用路径可能需要根据实际情况调整

## 故障排查

如果遇到问题：
1. 打开 Hammerspoon 控制台查看错误日志
2. 检查是否有通知提示模块加载失败
3. 临时禁用有问题的模块（在 init.lua 中注释掉）
4. 查看 README.md 了解各模块的功能

## 文件结构
```
~/.hammerspoon/
├── init.lua              # 主入口（已优化）
├── README.md             # 功能文档
├── FIXES.md              # 本文档
└── modules/              # 所有功能模块（已重组）
```
