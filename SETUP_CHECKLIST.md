# 安装检查清单 ✅

在使用新配置前，请逐项检查以下内容。

---

## 📦 系统要求检查

### 软件安装
- [ ] **Hammerspoon** 已安装
  ```bash
  brew install hammerspoon
  ```
- [ ] **Karabiner-Elements** 已安装
  ```bash
  brew install karabiner-elements
  ```

### 权限和设置
- [ ] Hammerspoon 已添加到系统设置 → 隐私和安全 → 辅助功能
- [ ] Karabiner-Elements 已启用输入监控权限
- [ ] Hammerspoon 已启用自动化权限（如提示）
- [ ] Finder 脚本执行权限已授予

---

## 🔧 Karabiner-Elements 配置检查

### 规则配置
- [ ] Karabiner-Elements 应用已打开
- [ ] Complex modifications 规则已添加
- [ ] "caps_lock to hyper" 规则已启用
- [ ] Caps Lock 按下后无大小写切换反应

### 规则验证
- [ ] 按住 Caps Lock + 其他键时能识别修饰键
- [ ] 可在系统设置中的键盘快捷键测试中看到 Cmd+Alt+Ctrl+Shift 组合

---

## 📂 配置文件检查

### 文件结构
- [ ] `~/.hammerspoon/init.lua` 存在
- [ ] `~/.hammerspoon/modules/integration/hyper-key.lua` 存在
- [ ] `~/.hammerspoon/modules/window/manager.lua` 已更新
- [ ] `~/.hammerspoon/modules/integration/finder-terminal.lua` 已更新
- [ ] `~/.hammerspoon/README.md` 已更新

### 文档文件
- [ ] `HYPER_KEY.md` - Hyper Key 完整指南
- [ ] `QUICK_START.md` - 快速开始指南
- [ ] `ARCHITECTURE.md` - 架构文档已更新
- [ ] `CHANGES.md` - 修改总结

---

## 🚀 Hammerspoon 启动检查

### 初始化
- [ ] 打开 Hammerspoon 应用
- [ ] 见到通知：✅ **"Hammerspoon 配置已加载"**
- [ ] 没有错误通知

### Dock 和菜单
- [ ] Hammerspoon 图标出现在 Dock 中
- [ ] Hammerspoon 菜单图标出现在顶部菜单栏

---

## 🎮 快捷键功能测试

### 全局 Hyper 快捷键
- [ ] `Hyper + G` - 浏览器打开
- [ ] `Hyper + T` - 终端打开
- [ ] `Hyper + F` - Finder 目录在终端打开（在 Finder 中尝试）
- [ ] `Hyper + V` - Finder 目录在 VS Code 打开（在 Finder 中尝试）
- [ ] `Hyper + R` - 进入窗口管理模式，显示 "Window Management Mode"

### 窗口管理模式 (`Hyper + R` 进入)
- [ ] `h` - 窗口移至左半屏
- [ ] `l` - 窗口移至右半屏
- [ ] `j` - 窗口移至下半屏
- [ ] `k` - 窗口移至上半屏
- [ ] `y` - 左上四分位
- [ ] `o` - 右下四分位
- [ ] `f` - 最大化
- [ ] `c` - 关闭窗口
- [ ] `Tab` - 显示帮助
- [ ] `q` / `Esc` - 退出模式

### 其他快捷键
- [ ] `Cmd+Ctrl+Alt+R` - 重载配置
- [ ] `Cmd+Shift+V` - 强制粘贴

---

## 📝 输入法测试

### 输入法自动切换
- [ ] 打开终端或编辑器（例如 VS Code）
- [ ] 应自动切换到英文输入法
- [ ] 打开支持中文的应用（例如微信）
- [ ] 应自动切换回默认输入法

### 输入法 ID 验证
- [ ] 已确认 `config.lua` 中的输入法 ID 与系统匹配
- [ ] 如需修改，编辑 `modules/utils/config.lua`

---

## 📊 日志和诊断

### 查看日志
- [ ] 打开 Hammerspoon 菜单 → 显示 Hammerspoon 控制台
- [ ] 控制台中显示模块加载信息
- [ ] 没有红色错误日志

### 诊断命令
在 Hammerspoon 控制台中运行：

```lua
-- 查看快捷键
hs.hotkey.showAll()

-- 查看模块状态
Lifecycle.printStatus()

-- 查看活跃窗口
print(hs.window.focusedWindow():title())
```

---

## 🔍 应用路径验证

### 检查应用是否正确识别

在终端中运行这些命令验证应用路径：

```bash
# 检查浏览器
ls /Applications/Google\ Chrome.app
ls /Applications/Brave\ Browser.app
ls /Applications/Firefox.app
ls /Applications/Safari.app

# 检查终端
ls /Applications/Ghostty.app
ls /Applications/iTerm.app
ls /Applications/Terminal.app

# 检查编辑器
ls /Applications/Visual\ Studio\ Code.app
```

- [ ] 至少一个浏览器存在
- [ ] 至少一个终端存在
- [ ] VS Code 已安装（用于 Hyper + V）

### 自定义应用路径

如果您的应用安装在其他位置，编辑 `modules/integration/hyper-key.lua`：

```lua
local apps = {
  '/Applications/YourBrowser.app',
  -- 添加你的应用路径
}
```

---

## 🎯 自定义配置检查

### 输入法配置
编辑 `modules/utils/config.lua`，检查：
- [ ] `default` - 默认输入法 ID 正确
- [ ] `english` - 英文输入法 ID 正确
- [ ] `englishApps` - 应在英文模式下运行的应用列表正确

### Hyper 快捷键配置
编辑 `modules/integration/hyper-key.lua`，检查：
- [ ] 应用路径与系统匹配
- [ ] 快捷键字母符合个人习惯
- [ ] 没有遗漏的应用

---

## ⚠️ 故障排除

### 如果 Hyper 键不工作
- [ ] Karabiner-Elements 已启动
- [ ] 规则已启用（Complex modifications 中勾选）
- [ ] 系统设置中已授予输入监控权限
- [ ] 尝试重启 Karabiner-Elements 或系统

### 如果 Hammerspoon 快捷键不工作
- [ ] Hammerspoon 已在运行
- [ ] 按 `Cmd+Ctrl+Alt+R` 重载配置
- [ ] 查看控制台是否有错误信息
- [ ] 检查相关应用是否已安装

### 如果输入法不自动切换
- [ ] 确认 `config.lua` 中的输入法 ID 正确
- [ ] 检查应用路径是否正确
- [ ] 重载配置：`Cmd+Ctrl+Alt+R`
- [ ] 查看日志中的错误信息

---

## 📞 获得帮助

### 查看文档
- 快速开始：[QUICK_START.md](QUICK_START.md)
- Hyper Key 指南：[HYPER_KEY.md](HYPER_KEY.md)
- 完整说明：[README.md](README.md)
- 架构详情：[ARCHITECTURE.md](ARCHITECTURE.md)
- 修改记录：[CHANGES.md](CHANGES.md)

### 调试技巧
1. 打开 Hammerspoon 控制台查看详细日志
2. 使用 `print()` 语句添加自定义日志
3. 重载配置：`Cmd+Ctrl+Alt+R`
4. 检查 `/var/log/` 中的系统日志

---

## 🎉 完成！

如果上述所有项目都已检查并通过，您的 Hyper Key 配置已准备就绪！

**提示**：将此检查清单保存以供将来参考。

---

## 反馈

如有任何问题或改进建议，欢迎提出 Issue 或 PR。

**最后检查日期**：_________  
**检查者**：_________
