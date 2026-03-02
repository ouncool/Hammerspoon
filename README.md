# Hammerspoon Configuration

面向个人日常高频操作的 Hammerspoon 配置，重点是稳定、可维护、可扩展。

## 功能概览

### 全局快捷键
- `Cmd+Alt+Ctrl+R`: 重新加载配置

### Hyperkey 快捷键集（Cmd+Alt+Ctrl+Shift）
- `Hyperkey + L`: 锁屏
- `Hyperkey + V`: 强制粘贴纯文本
- `Hyperkey + T`: 在 Finder 当前目录打开终端
- `Hyperkey + C`: 在 Finder 当前目录打开编辑器
- `Hyperkey + B`: 打开默认浏览器（按候选顺序）
- `Hyperkey + W`: 打开或切换微信
- `Hyperkey + Q`: 打开或切换企业微信
- `Hyperkey + ← / → / ↑ / ↓`: 窗口半屏布局
- `Hyperkey + Return`: 最大化窗口
- `Hyperkey + H`: 显示快捷键帮助面板
- `Hyperkey + R`: 进入窗口模式（modal）

### 窗口模式（进入后）
- `h/l/j/k`: 左/右/下/上半屏
- `y/u/i/o`: 四象限布局
- `Shift+h / Shift+l`: 左/右 2/3 宽
- `f`: 最大化
- `c`: 关闭窗口
- `Tab`: 显示帮助
- `q` 或 `Esc`: 退出窗口模式

### 自动化
- 输入法自动切换（按前台应用切换中英文输入法）
- Preview 打开 PDF 自动全屏

## 目录结构

```text
.
├── init.lua
├── config.lua
├── core/
│   ├── config.lua
│   ├── schema.lua
│   ├── events.lua
│   ├── lifecycle.lua
│   └── logger.lua
├── infra/
│   ├── hotkey-registry.lua
│   ├── command-runner.lua
│   └── app-discovery.lua
├── shared/
│   ├── finder.lua
│   └── timing.lua
└── features/
    ├── automation/
    │   └── auto-switch.lua
    ├── interaction/
    │   ├── clipboard.lua
    │   ├── finder-actions.lua
    │   └── pdf-fullscreen.lua
    ├── shortcuts/
    │   ├── app-launcher.lua
    │   ├── controller.lua
    │   └── help-display.lua
    └── window/
        ├── manager.lua
        └── operations.lua
```

## 配置说明

编辑 `config.lua`。

### `logging`
- `level`: `DEBUG | INFO | WARN | ERROR | FATAL`
- `console`: 是否输出控制台日志
- `notification`: 错误时是否系统通知

### `hotkeys`
- `reload`: 重载快捷键
- `hyperMods`: Hyperkey 修饰键数组
- `windowMode.key`: 进入窗口模式的按键（与 `hyperMods` 组合）

### `inputMethod`
- `default`: 默认输入法 ID
- `english`: 英文输入法 ID
- `englishApps`: 强制英文输入的应用列表（路径 / bundleId / 名称可匹配）

### `window`
- `twoThirdRatio`: 窗口 2/3 布局比例

### `apps`
- `browsers`: 浏览器候选路径（按顺序）
- `terminals`: 终端候选路径（按顺序）
- `editors`: 编辑器策略（`app + cli`）
- `wechat` / `weworkMac`: 可选，微信/企业微信路径

### `previewPdf`
- `appNames`: Preview 应用名候选（多语言）
- `bundleId`: Preview bundle id
- `debounceSec`: 防抖时间
- `fullscreenDelaySec`: 延时全屏时间

## 兼容迁移说明

为避免旧配置导致严格校验失败，启动时会自动移除并告警以下已废弃字段：
- `config.appSwitcher`
- `config.hotkeys.appSwitcher`
- `config.hotkeys.hyper`
- `config.hotkeys.pasteHelper`

日志示例：`Legacy config key removed: config.hotkeys.appSwitcher`

## 启动与排查

1. 修改配置后按 `Cmd+Alt+Ctrl+R` 重载。
2. Hammerspoon Console 查看日志：
   - 启动成功会看到 `Hammerspoon config loaded`
   - 启动失败会看到 `Startup aborted due to module failure`
3. 常用日志前缀：
   - `HyperkeyController`
   - `WindowManager`
   - `InputMethod`
   - `PreviewPdf`
   - `FinderActions`
   - `ClipboardOps`

## 依赖与权限

- 建议已将 Caps Lock 映射为 Hyper（`cmd+alt+ctrl+shift`）。
- 需要在 macOS 中授予 Hammerspoon 辅助功能权限（窗口管理、按键模拟、输入法切换相关）。
