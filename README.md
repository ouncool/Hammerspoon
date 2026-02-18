# Hammerspoon Configuration

面向个人日常高频操作的 Hammerspoon 配置，重点是稳定、可维护、可扩展。

## 设计思路

本项目采用分层架构，避免“功能脚本散落 + 热键重复绑定 + 配置分散”的问题。

- `core/`: 核心基础能力
  - `config.lua`: 默认配置 + 严格校验 + 用户配置合并
  - `events.lua`: 事件总线
  - `lifecycle.lua`: 模块注册与生命周期编排
  - `logger.lua`: 统一日志输出
- `infra/`: 系统交互适配
  - `hotkey-registry.lua`: 热键统一注册/注销
  - `command-runner.lua`: 系统命令统一执行
  - `app-discovery.lua`: 应用发现与打开能力
- `shared/`: 纯工具
  - 防抖节流、Finder 路径、动画等
- `features/`: 业务功能
  - 输入法自动切换
  - 窗口管理
  - 应用切换器（Alt+Tab）
  - Hyper 快捷键
  - Finder 打开终端/编辑器
  - Preview PDF 自动全屏
  - 强制粘贴

### 为什么这样设计

- 单一职责: 热键绑定只在 `hotkey-registry` 汇总，不在各处直接 `hs.hotkey.bind`
- 模块可控: 每个功能模块统一 `setup/start/stop/dispose`
- 配置可进化: 新增配置项时，schema 会约束输入，减少运行时崩溃
- 故障可追踪: 统一日志、统一启动流程，能快速定位哪一个模块失败

## 当前功能

- `Cmd+Alt+Ctrl+R`: 重新加载配置
- `Hyper + G/T/F/V`: 浏览器 / 终端 / Finder目录到终端 / Finder目录到编辑器
- `Hyper + R`: 进入窗口管理模式（`h/j/k/l/y/u/i/o/H/L/f/c`）
- `Alt+Tab`, `Alt+Shift+Tab`: 应用切换器
- `Cmd+Shift+V`: 强制粘贴
- 输入法自动切换（按前台应用）
- Preview 打开 PDF 自动全屏

## 目录结构

```text
.
├── init.lua
├── config.lua
├── core/
├── infra/
├── shared/
└── features/
```

## 注意事项

### 1) Hyper 键映射

默认假设你已将 Caps Lock 映射为 Hyper（`cmd+alt+ctrl+shift`）。

### 2) Hammerspoon 版本差异

`hs.chooser` 的部分方法在不同版本可用性不同。当前代码已对 `rows/numRows`、`font` 等做方法探测调用，避免直接崩溃。

### 3) App Switcher 过滤策略

为避免出现大量系统后台进程，切换器默认过滤 `xpc/service/agent/helper` 类条目，并仅对白名单中的“无窗口应用”做运行态补充。

### 4) 权限

涉及输入法切换、窗口操作、模拟按键时，macOS 需要辅助功能权限。

## 可自行修改的配置条目

编辑 `config.lua`。

### `logging`

- `level`: `DEBUG | INFO | WARN | ERROR | FATAL`
- `console`: 是否输出到控制台
- `notification`: 错误时是否通知

### `hotkeys`

- `reload.mods/key`: 重载快捷键
- `hyperMods`: Hyper 修饰键集合
- `windowMode.key`: 进入窗口模式按键
- `appSwitcher.next/previous`: 切换器快捷键
- `pasteHelper.mods/key`: 强制粘贴快捷键
- `hyper.browser/terminal/finderTerminal/finderEditor`: Hyper 功能键

### `inputMethod`

- `default`: 默认输入法
- `english`: 英文输入法
- `englishApps`: 使用英文输入法的应用列表（路径、名称、bundle id 都支持匹配）

### `window`

- `twoThirdRatio`: `H/L` 操作时的宽度比例

### `appSwitcher`

- `scope`: `allSpaces | currentSpace`
- `width`: 窗口宽度（支持 `0~1` 或百分比数值）
- `numRows`: 显示行数
- `textSize/subTextSize`: 文本字号
- `bgColor/textColor/subTextColor/selectedColor`: 颜色
- `shadow/radius`: 样式
- `includeNoWindowBundleIds`: 无窗口但需要在 Alt+Tab 中保留的 bundle id 白名单

### `apps`

- `browsers`: Hyper+G 候选浏览器路径（按顺序）
- `terminals`: Hyper+T 候选终端路径（按顺序）
- `editors`: Finder 打开编辑器策略（`app + cli`）

### `previewPdf`

- `appNames`: Preview 应用名候选（多语言）
- `bundleId`: Preview bundle id
- `debounceSec`: 事件防抖
- `fullscreenDelaySec`: 延时全屏时间

## 常见自定义示例

### 例1: 让微信/企业微信在无窗口时仍出现在 Alt+Tab

在 `config.lua` 中设置:

```lua
config.appSwitcher.includeNoWindowBundleIds = {
  'com.tencent.flue.WeChatAppEx',
  'com.tencent.WeWorkMac',
}
```

### 例2: 改应用切换快捷键（示例改为 Hyper+E / Hyper+Q）

```lua
config.hotkeys.appSwitcher = {
  next = { mods = {'cmd','alt','ctrl','shift'}, key = 'e' },
  previous = { mods = {'cmd','alt','ctrl','shift'}, key = 'q' },
}
```

### 例3: 提升日志详细程度

```lua
config.logging.level = 'DEBUG'
```

## 启动与排查

1. 修改配置后按 `Cmd+Alt+Ctrl+R` 重载
2. 看 Hammerspoon Console 是否出现 `Started module` 和 `Failed module`
3. 若某功能无效，先看该模块日志前缀:
   - `AppSwitcher`
   - `InputMethod`
   - `WindowManager`
   - `PreviewPdf`

## 开发约定

新增功能模块建议遵循:

```lua
function M.setup(ctx) ... end
function M.start() ... end
function M.stop() ... end
function M.dispose() ... end
```

并在 `init.lua` 中通过 `Lifecycle.register` 注册。
