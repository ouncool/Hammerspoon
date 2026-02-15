# Hyper Key Quick Reference

## 一键安装指南

### 1. 安装必要软件
```bash
# 安装 Hammerspoon
brew install hammerspoon

# 安装 Karabiner-Elements（用于 Hyper Key 映射）
brew install karabiner-elements
```

### 2. 克隆配置文件
```bash
cd ~/.config
git clone <repository-url> hammerspoon
# 或直接复制配置文件到 ~/.hammerspoon/
```

### 3. 配置 Karabiner-Elements
1. 打开 Karabiner-Elements 应用
2. 点击 "Complex modifications" → "Add rule"
3. 搜索并启用 "caps_lock to hyper key" 规则
4. 或手动配置：`caps_lock` → `left_command + left_option + left_control + left_shift`

### 4. 授予权限
- Hammerspoon 会提示需要的权限（输入监控、自动化等）
- 在系统设置中一一授予

### 5. 启动 Hammerspoon
- 打开 Hammerspoon 应用
- 系统会自动加载 `~/.hammerspoon/init.lua`
- 看到 "✅ Hammerspoon 配置已加载" 通知表示成功

---

## 完整快捷键表

### 全局快捷键（任何应用）

| 快捷键 | 功能 | 应用 |
|--------|------|------|
| `Hyper + G` | 打开浏览器 | Chrome/Brave/Firefox/Safari |
| `Hyper + T` | 打开终端 | Ghostty/iTerm/Terminal |
| `Hyper + F` | 在终端打开 Finder 目录 | 当前 Finder 窗口 |
| `Hyper + V` | 在 VS Code 打开 Finder 目录 | 当前 Finder 窗口 |
| `Hyper + R` | 进入窗口管理模式 | 任何应用 |
| `Cmd + Ctrl + Alt + R` | 重载 Hammerspoon 配置 | 任何应用 |
| `Cmd + Shift + V` | 强制粘贴（绕过限制） | 任何应用 |

### 窗口管理模式（`Hyper + R` 进入）

| 按键 | 功能 |
|-----|------|
| `h` | 窗口贴在左半屏 |
| `l` | 窗口贴在右半屏 |
| `j` | 窗口贴在下半屏 |
| `k` | 窗口贴在上半屏 |
| `y` | 左上四分位 |
| `u` | 左下四分位 |
| `i` | 右上四分位 |
| `o` | 右下四分位 |
| `H` | 左三分之二 |
| `L` | 右三分之二 |
| `f` | 全屏 |
| `c` | 关闭窗口 |
| `Tab` | 显示帮助 |
| `q` / `Esc` | 退出模式 |

---

## 快速配置

### 修改默认输入法

编辑 `~/.hammerspoon/modules/utils/config.lua`：

```lua
config.inputMethod = {
  default = 'com.sogou.inputmethod.sogou.pinyin',  -- 默认输入法
  english = 'com.apple.keylayout.ABC',             -- 英文输入法
  englishApps = {
    '/Applications/Terminal.app',
    '/Applications/Ghostty.app',
    '/Applications/Visual Studio Code.app',
    -- 添加你的应用
  }
}
```

### 修改 Hyper 快捷键应用优先级

编辑 `~/.hammerspoon/modules/integration/hyper-key.lua`，修改应用列表顺序：

```lua
-- 浏览器优先级
local apps = {
  '/Applications/Google Chrome.app',    -- 最优先
  '/Applications/Brave Browser.app',
  '/Applications/Firefox.app',
  '/Applications/Safari.app'             -- 最后备选
}

-- 终端优先级
local terminalApps = {
  '/Applications/Ghostty.app',          -- 最优先
  '/Applications/iTerm.app',
  '/Applications/Terminal.app'           -- 最后备选
}
```

### 添加新的 Hyper 快捷键

1. 打开 `~/.hammerspoon/modules/integration/hyper-key.lua`
2. 添加新函数：

```lua
-- 新函数示例
local function openSlack()
    hs.execute("open -a Slack")
    log.info('Opened Slack')
end
```

3. 在 `start()` 函数中添加绑定：

```lua
hotkeyBindings.slack = hs.hotkey.bind(hyperModifier, 'S', openSlack)
```

4. 按 `Cmd + Ctrl + Alt + R` 重载配置

---

## 常见问题

### Q: Hyper 键不工作？
**A:** 
1. 检查 Karabiner-Elements 是否运行
2. 确保规则已启用（Complex modifications 中勾选）
3. 检查系统设置 → 隐私 → 输入监控中是否授予权限
4. 重启 Karabiner-Elements 或整个系统

### Q: 某个快捷键不工作？
**A:**
1. 检查应用是否正确安装
2. 查看 Hammerspoon 通知中的错误信息
3. 按 `Cmd + Ctrl + Alt + R` 重载配置
4. 检查 `~/.hammerspoon/modules/integration/hyper-key.lua` 中应用路径是否正确

### Q: 如何禁用某个快捷键？
**A:** 编辑 `modules/integration/hyper-key.lua`，在 `start()` 函数中注释掉对应的绑定行

### Q: 可以自定义快捷键吗？
**A:** 可以。编辑对应模块，修改 `hs.hotkey.bind()` 的最后一个参数（字母）即可

### Q: 如何重载配置？
**A:** 按 `Cmd + Ctrl + Alt + R` 或在菜单中点击 Reload

---

## 更新日志

### v2.0 - Hyper Key 整合版
- ✨ 添加 Hyper Key 全局快捷键系统
- 📁 新增 `modules/integration/hyper-key.lua` 模块
- 📚 完整的 Hyper Key 设置指南
- 🚀 优化的快捷键架构
- 📖 更新所有文档

### v1.0 - 初始版本
- 输入法自动切换
- Vim 风格窗口管理
- 粘贴助手
- Finder 集成
- PDF 自动全屏

---

## 支持

- 📖 详细文档：[HYPER_KEY.md](HYPER_KEY.md)
- 🏗️ 架构说明：[ARCHITECTURE.md](ARCHITECTURE.md)
- 🆘 提交问题或改进建议
