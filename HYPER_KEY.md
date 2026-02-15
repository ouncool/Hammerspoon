# Hyper Key 完整指南

## 什么是 Hyper 键？

Hyper 键是将 **Caps Lock** 重映射为 **`Cmd + Opt + Ctrl + Shift`** 的组合。这是现代 macOS 用户中最流行的快捷键设计模式。

### 为什么使用 Hyper 键？

1. **永不冲突**：没有原生软件会使用这个组合，所以你的所有快捷键都是独一无二的
2. **舒适性强**：Caps Lock 键位置优越，不需要同时按下多个键
3. **可发现性强**：所有 Hyper + 字母的快捷键易于记忆
4. **业界标准**：被许多 macOS 开发者社区推荐

## 安装和配置

### 方法 1：使用 Karabiner-Elements（推荐）

#### 步骤 1：安装 Karabiner-Elements
```bash
brew install karabiner-elements
```

#### 步骤 2：打开应用并授予权限
- 打开 Karabiner-Elements
- 按照提示授予必要的输入监控权限
- 可能需要进入"系统设置 → 隐私 → 输入监控"中启用

#### 步骤 3：添加 Caps Lock 到 Hyper 键规则
1. 打开 Karabiner-Elements 主界面
2. 点击 "Complex modifications"
3. 点击 "Add rule"
4. 搜索 "caps_lock to hyper"（如果没有，看步骤 4）
5. 添加规则并启用

#### 步骤 4：如果找不到预设规则，手动添加

编辑 `~/.config/karabiner/karabiner.json`，在 `rules` 数组中添加：

```json
{
  "description": "Caps Lock to Hyper Key",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "key_code": "caps_lock"
      },
      "to": [
        {
          "key_code": "left_shift",
          "modifiers": ["left_command", "left_option", "left_control"]
        }
      ]
    }
  ]
}
```

### 方法 2：使用 macOS 辅助功能（仅限修饰键）

> **注意**：这个方法有限制，无法完全实现 Hyper 键，建议使用 Karabiner-Elements

### 测试 Hyper 键

1. 安装配置后，打开任何文本编辑器
2. 按 Caps Lock（应该没有任何效果）
3. 按住 Caps Lock + 其他键，看是否激发快捷键

## Hammerspoon 中的 Hyper 快捷键

### 全局快捷键

| 快捷键 | 功能 | 应用 |
|--------|------|------|
| `Hyper + G` | 打开浏览器 | Chrome、Brave、Firefox、Safari |
| `Hyper + T` | 打开终端 | Ghostty、iTerm、Terminal |
| `Hyper + F` | 在终端打开当前 Finder 目录 | Ghostty/Terminal |
| `Hyper + V` | 在 VS Code 打开当前 Finder 目录 | VS Code |
| `Hyper + R` | 进入窗口管理模式 | 内置窗口管理 |

### 窗口管理快捷键 (`Hyper + R` 进入)

| 按键 | 功能 |
|-----|------|
| `h` | 窗口贴在屏幕左半部分 |
| `l` | 窗口贴在屏幕右半部分 |
| `j` | 窗口贴在屏幕下半部分 |
| `k` | 窗口贴在屏幕上半部分 |
| `y` | 窗口移至左上四分位 |
| `u` | 窗口移至左下四分位 |
| `i` | 窗口移至右上四分位 |
| `o` | 窗口移至右下四分位 |
| `H` | 窗口调整为左三分之二宽 |
| `L` | 窗口调整为右三分之二宽 |
| `f` | 最大化窗口 |
| `c` | 关闭窗口 |
| `Tab` | 显示帮助信息 |
| `q` / `Esc` | 退出窗口管理模式 |

## 故障排除

### Hyper 键不工作

**问题**：Caps Lock 的快捷键没有响应

**解决方案**：
1. 检查 Karabiner-Elements 是否正确安装和运行
2. 确保规则已启用（在 Complex modifications 中勾选）
3. 检查系统设置 → 隐私 → 输入监控中是否给予权限
4. 尝试重启 Karabiner-Elements 或重启系统

### 快捷键冲突

**问题**：某个应用中 Hyper 快捷键不工作

**解决方案**：
1. 检查该应用是否有禁用全局快捷键的选项
2. 在 Hammerspoon 日志中查看是否有错误信息
3. 尝试在另一个应用中测试该快捷键

### Caps Lock 仍有大写功能

**问题**：Caps Lock 仍会切换大小写

**解决方案**：
1. 检查 Karabiner 的规则是否正确应用
2. 确保没有其他工具（如 KeyRemap4MacBook）也在映射 Caps Lock
3. 重启系统生效

## 自定义快捷键

### 添加新的 Hyper 快捷键

编辑 `modules/integration/hyper-key.lua`，添加新函数和绑定：

```lua
-- 新函数：Hyper + 其他键
local function myCustomAction()
    log.info('Custom action triggered')
    -- 你的代码
end

-- 在 start() 函数中添加绑定：
hotkeyBindings.custom = hs.hotkey.bind(hyperModifier, 'X', myCustomAction)
```

### 修改现有快捷键

在 `modules/integration/hyper-key.lua` 中修改对应的函数，或在 `init.lua` 中修改快捷键字母。

## 推荐配置

### 完整的 Karabiner 配置示例

如果需要更复杂的设置（如 Hyper 单独按下时的行为），可以在 Karabiner 中添加：

```json
{
  "description": "Caps Lock to Hyper with single press to Escape",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "key_code": "caps_lock"
      },
      "to": [
        {
          "key_code": "left_shift",
          "modifiers": ["left_command", "left_option", "left_control"]
        }
      ],
      "to_if_alone": [
        {
          "key_code": "escape"
        }
      ]
    }
  ]
}
```

这样配置后，单独按 Caps Lock 会发送 Escape 键，配合其他键时发送 Hyper 键。

## 参考资源

- [Karabiner-Elements 官网](https://karabiner-elements.pqrs.org/)
- [Hammerspoon 官网](https://www.hammerspoon.org/)
- [Hyper 键讨论社区](https://github.com/rvaiya/keyd/discussions)
