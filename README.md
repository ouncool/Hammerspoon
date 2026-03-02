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
  - 防抖节流、Finder 路径
- `features/`: 业务功能
  - `shortcuts/`: Hyperkey 统一快捷键
  - `automation/`: 输入法自动切换
  - `interaction/`: Finder 操作、PDF 全屏、剪贴板粘贴
  - `window/`: 窗口管理和操作

### 为什么这样设计

- 单一职责: 热键绑定只在 `hotkey-registry` 汇总，不在各处直接 `hs.hotkey.bind`
- 模块可控: 每个功能模块统一 `setup/start/stop/dispose`
- 配置可进化: 新增配置项时，schema 会约束输入，减少运行时崩溃
- 故障可追踪: 统一日志、统一启动流程，能快速定位哪一个模块失败

## 最近重构（2024.2.25）

### 架构优化

采用 **3 阶段渐进式重构**，显著提升代码质量和可维护性：

**P1 - 快速清理**
- 删除 150+ 行无用代码（空模块、孤立文件）
- 清理：shared/animation.lua、features/clipboard/、features/hyper/ 目录

**P2.1 - 配置分离**
- 创建 `core/schema.lua`，集中管理配置 Schema 和默认值（253 行）
- 原 core/config.lua 从 505 行降至 ~150 行，职责更清晰

**P3 - 功能域重组**
- 将 5 个杂乱目录重构为 4 个清晰的功能域：
  - `window/` - 窗口操作
  - `shortcuts/` - 快捷键绑定（Hyperkey）
  - `automation/` - 自动化（输入法切换）
  - `interaction/` - 系统交互（Finder、剪贴板、PDF）

### 成果指标

| 指标 | 改进 |
|------|------|
| 代码行数 | 3,223 → 3,070（删除 ~150 行死代码） |
| 目录深度 | 最深 3 层 → 一致 2 层 |
| 最大文件 | 691 行 → 270 行 |
| 模块数 | 分散 7 个 → 集中 4 个功能域 |
| 配置 Schema | 集中在 core/schema.lua |

## 当前功能

### 全局快捷键
- `Cmd+Alt+Ctrl+R`: 重新加载配置

### Hyperkey 快捷键集 (Cmd+Alt+Ctrl+Shift)

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Hyperkey + L` | 锁屏 | 立即锁住屏幕 |
| `Hyperkey + V` | 强制粘贴 | 忽略格式直接粘贴剪贴板内容 |
| `Hyperkey + T` | 打开终端 | 在 Finder 当前目录打开终端 |
| `Hyperkey + C` | 打开编辑器 | 在 Finder 当前目录打开 VSCode |
| `Hyperkey + B` | 打开浏览器 | 启动默认浏览器 |
| `Hyperkey + W` | 打开微信 | 启动微信/切换到微信窗口 |
| `Hyperkey + Q` | 打开企业微信 | 启动企业微信/切换到企业微信窗口 |
| `Hyperkey + ←` | 窗口左半屏 | 调整当前窗口占据左半屏 |
| `Hyperkey + →` | 窗口右半屏 | 调整当前窗口占据右半屏 |
| `Hyperkey + ↑` | 窗口上半屏 | 调整当前窗口占据上半屏 |
| `Hyperkey + ↓` | 窗口下半屏 | 调整当前窗口占据下半屏 |
| `Hyperkey + Return` | 最大化窗口 | 将当前窗口最大化填满屏幕 |

### 自动化功能
- 输入法自动切换（根据前台应用）
- Preview 打开 PDF 自动全屏

## 目录结构

```text
.
├── init.lua                          # 应用入口 + 模块注册
├── config.lua                        # 用户配置覆盖
├── core/                             # 核心框架
│   ├── config.lua                    # 配置加载与验证
│   ├── schema.lua                    # 配置 Schema 定义
│   ├── events.lua                    # 事件总线
│   ├── lifecycle.lua                 # 模块生命周期管理
│   └── logger.lua                    # 统一日志
├── infra/                            # 基础设施适配
│   ├── hotkey-registry.lua           # 热键统一注册
│   ├── command-runner.lua            # 命令执行
│   └── app-discovery.lua             # 应用发现
├── shared/                           # 工具函数
│   ├── finder.lua                    # Finder 路径操作
│   └── timing.lua                    # 防抖/节流
└── features/                         # 业务功能模块
    ├── window/                       # 窗口管理
    │   ├── manager.lua
    │   └── operations.lua
    ├── shortcuts/                    # Hyperkey 快捷键
    │   ├── controller.lua            # 13 个 Hyperkey 绑定
    │   ├── app-launcher.lua          # 应用启动/切换
    │   └── help-display.lua          # Hyperkey 帮助面板
    ├── automation/                   # 自动化功能
    │   └── auto-switch.lua           # 输入法自动切换
    └── interaction/                  # 系统交互
        ├── finder-actions.lua        # Finder 集成（终端/编辑器）
        ├── clipboard.lua             # 剪贴板强制粘贴
        └── pdf-fullscreen.lua        # PDF 自动全屏
```

## 注意事项

### 1) Hyper 键映射

默认假设你已将 Caps Lock 映射为 Hyper（`cmd+alt+ctrl+shift`）。

### 2) 权限

涉及输入法切换、窗口操作、模拟按键时，macOS 需要辅助功能权限。

### 3) 旧配置兼容迁移

启动时会自动移除已废弃字段并输出 `WARN`（`appSwitcher`、`hotkeys.appSwitcher`、`hotkeys.hyper`、`hotkeys.pasteHelper`），避免旧配置导致校验失败。

## 可自行修改的配置条目

编辑 [config.lua](config.lua)。

### `logging`

- `level`: `DEBUG | INFO | WARN | ERROR | FATAL` - 日志级别
- `console`: 是否输出到控制台
- `notification`: 错误时是否系统通知

### `hotkeys`

- `reload`: 重载配置的快捷键（默认 `Cmd+Alt+Ctrl+R`）
- `hyperMods`: Hyperkey 修饰键集合（默认 `cmd+alt+ctrl+shift`）

### `inputMethod`

- `default`: 默认输入法
- `english`: 英文输入法 ID
- `englishApps`: 需要强制英文输入的应用列表（支持路径、Bundle ID 匹配）

### `window`

- `twoThirdRatio`: `H/L` 操作时的宽度比例

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

### 例1: 提升日志详细程度

```lua
config.logging.level = 'DEBUG'
```

## 启动与排查

1. 修改配置后按 `Cmd+Alt+Ctrl+R` 重载
2. Hammerspoon Console 查看启动状态：
   - "Started modules: ..." 表示启动成功
   - "Failed modules: ..." 表示存在失败模块
3. 若某功能无效，根据日志前缀追踪：
   - `HyperkeyController` - Hyperkey 快捷键
   - `InputMethod` - 输入法自动切换
   - `WindowManager` - 窗口管理
   - `PreviewPdf` - PDF 自动全屏
   - `FinderActions` - Finder 终端/编辑器集成
   - `ClipboardOps` - 强制粘贴

## 代码约定

新增功能模块建议遵循标准生命周期：

```lua
local M = {}

function M.setup(ctx)      -- 模块初始化，接收运行时上下文
  -- 初始化代码
  return true              -- 成功返回 true
end

function M.start()         -- 模块启动
  -- 启动代码（绑定快捷键、启动监听等）
  return true
end

function M.stop()          -- 模块停止
  -- 清理代码
  return true
end

function M.dispose()       -- 模块销毁
  -- 销毁资源（解绑、释放等）
end

return M
```

然后在 [init.lua](init.lua) 中通过 `Lifecycle.register()` 注册。
