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
- `Hyperkey + F`: 打开 Finder（Downloads）
- `Hyperkey + B`: 打开默认浏览器（按候选顺序）
- `Hyperkey + W`: 打开或切换微信
- `Hyperkey + Q`: 打开或切换企业微信
- `Hyperkey + ← / → / ↑ / ↓`: 窗口半屏布局
- `Hyperkey + Return`: 最大化窗口
- `Hyperkey + H`: 显示快捷键帮助面板

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

### `inputMethod`
- `default`: 默认输入法 ID
- `english`: 英文输入法 ID
- `englishApps`: 强制英文输入的应用列表（路径 / bundleId / 名称可匹配）

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

## 配置对照表

| 配置项 | 默认值来源 | 运行时消费点 | 文档入口 |
| --- | --- | --- | --- |
| `logging.level` | `core/schema.lua` | `core/logger.lua` 的 `Logger.configure()` | 本节 `logging` |
| `logging.console` | `core/schema.lua` | `core/logger.lua` 的 `Logger.configure()` | 本节 `logging` |
| `logging.notification` | `core/schema.lua` | `core/logger.lua` 的 `Logger.configure()` | 本节 `logging` |
| `hotkeys.reload.mods` | `core/schema.lua` | `init.lua` 的全局重载快捷键绑定 | 本节 `hotkeys`，功能概览 |
| `hotkeys.reload.key` | `core/schema.lua` | `init.lua` 的全局重载快捷键绑定 | 本节 `hotkeys`，功能概览 |
| `hotkeys.hyperMods` | `core/schema.lua` | `features/shortcuts/controller.lua` 的 Hyperkey 绑定 | 本节 `hotkeys`，功能概览 |
| `inputMethod.default` | `core/schema.lua` | `features/automation/auto-switch.lua` | 本节 `inputMethod`，自动化 |
| `inputMethod.english` | `core/schema.lua` | `features/automation/auto-switch.lua` | 本节 `inputMethod`，自动化 |
| `inputMethod.englishApps` | `core/schema.lua` | `features/automation/auto-switch.lua` 的英文应用匹配表 | 本节 `inputMethod`，自动化 |
| `apps.browsers` | `core/schema.lua` | `features/shortcuts/controller.lua` -> `AppLauncher.openFirstApp()` | 本节 `apps`，功能概览 |
| `apps.terminals` | `core/schema.lua` | `features/interaction/finder-actions.lua` 的 `openInTerminal()` | 本节 `apps`，功能概览 |
| `apps.editors[].app` | `core/schema.lua` | `features/interaction/finder-actions.lua` 的 `openInEditor()` | 本节 `apps`，功能概览 |
| `apps.editors[].cli` | `core/schema.lua` | `features/interaction/finder-actions.lua` 的 `openInEditor()` | 本节 `apps`，功能概览 |
| `apps.wechat` | `core/schema.lua` | `features/shortcuts/controller.lua` 的微信快捷键 | 本节 `apps`，功能概览 |
| `apps.weworkMac` | `core/schema.lua` | `features/shortcuts/controller.lua` 的企业微信快捷键 | 本节 `apps`，功能概览 |
| `previewPdf.appNames` | `core/schema.lua` | `features/interaction/pdf-fullscreen.lua` 的窗口过滤与应用识别 | 本节 `previewPdf`，自动化 |
| `previewPdf.bundleId` | `core/schema.lua` | `features/interaction/pdf-fullscreen.lua` 的 Preview 识别 | 本节 `previewPdf`，自动化 |
| `previewPdf.debounceSec` | `core/schema.lua` | `features/interaction/pdf-fullscreen.lua` 的 `Timing.debounce()` | 本节 `previewPdf`，自动化 |
| `previewPdf.fullscreenDelaySec` | `core/schema.lua` | `features/interaction/pdf-fullscreen.lua` 的延时全屏 | 本节 `previewPdf`，自动化 |

维护规则：
- 新增配置项时，同时更新 `config.lua`、`core/schema.lua`、本表，以及对应功能描述。
- 删除配置项时，同时更新 `core/config.lua` 的 legacy 清理逻辑，或明确说明不再兼容。
- 如果某个配置项只存在于默认值、却没有运行时消费点，视为待清理信号。

## 兼容迁移说明

为避免旧配置导致严格校验失败，启动时会自动移除并告警以下已废弃字段：
- `config.appSwitcher`
- `config.hotkeys.appSwitcher`
- `config.hotkeys.hyper`
- `config.hotkeys.pasteHelper`
- `config.hotkeys.windowMode`
- `config.window`

日志示例：`Legacy config key removed: config.hotkeys.appSwitcher`

## 启动与排查

1. 修改配置后按 `Cmd+Alt+Ctrl+R` 重载。
2. Hammerspoon Console 查看日志：
   - 启动成功会看到 `Hammerspoon config loaded`
   - 启动失败会看到 `Startup aborted due to module failure`
3. 常用日志前缀：
   - `HyperkeyController`
   - `WindowOps`
   - `InputMethod`
   - `PreviewPdf`
   - `FinderActions`
   - `ClipboardOps`

## 依赖与权限

- 建议已将 Caps Lock 映射为 Hyper（`cmd+alt+ctrl+shift`）。
- 需要在 macOS 中授予 Hammerspoon 辅助功能权限（窗口管理、按键模拟、输入法切换相关）。
