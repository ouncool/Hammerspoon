# Refactoring Testing Checklist

## Pre-Deployment Testing

### ✅ Code Quality Checks
- [x] All comments converted to English
- [x] No Chinese text remaining in code
- [x] Consistent naming conventions applied
- [x] Error handling added to critical functions
- [x] Configuration centralized in `modules/utils/config.lua`

### ✅ Syntax Validation
- [x] No syntax errors detected
- [x] All `end` statements properly matched
- [x] All brackets balanced
- [x] All strings properly quoted

### ✅ Functional Testing (Manual)

#### Window Management
- [ ] Press `Alt+R` to enter window management mode
- [ ] Test `h` key - window should move to left half
- [ ] Test `l` key - window should move to right half
- [ ] Test `j` key - window should move to bottom half
- [ ] Test `k` key - window should move to top half
- [ ] Test `y` key - window should move to top-left quarter
- [ ] Test `u` key - window should move to bottom-left quarter
- [ ] Test `i` key - window should move to top-right quarter
- [ ] Test `o` key - window should move to bottom-right quarter
- [ ] Test `H` key - window should expand to left 2/3
- [ ] Test `L` key - window should expand to right 2/3
- [ ] Test `f` key - window should maximize
- [ ] Test `c` key - window should close
- [ ] Test `Tab` key - help should display
- [ ] Test `q` or `Esc` - should exit management mode

#### Input Method Auto-Switch
- [ ] Open Terminal - should switch to English input
- [ ] Open Ghostty - should switch to English input
- [ ] Open VS Code - should switch to English input
- [ ] Open Finder - should switch to Sogou Pinyin
- [ ] Open Safari - should switch to Sogou Pinyin
- [ ] Check console for debug messages

#### Finder Integration
- [ ] Open Finder and navigate to a folder
- [ ] Press `Cmd+Alt+T` - Ghostty should open in that directory
- [ ] Press `Cmd+Alt+V` - VS Code should open in that directory
- [ ] Test with Desktop folder
- [ ] Test with nested folders

#### Paste Helper
- [ ] Copy some text
- [ ] Go to a website with paste restrictions
- [ ] Press `Cmd+Shift+V` - text should paste

#### PDF Auto-Fullscreen
- [ ] Open a PDF file in Preview
- [ ] Window should automatically go fullscreen
- [ ] Close and reopen - should work again

### ✅ Configuration Testing
- [ ] Modify `modules/utils/config.lua`
- [ ] Change input method default
- [ ] Change window two-third ratio
- [ ] Reload config with `Cmd+Alt+Ctrl+R`
- [ ] Verify changes take effect

### ✅ Error Handling Testing
- [ ] Try window operations with no focused window
- [ ] Should see "No focused window" alert
- [ ] Try Finder integration with no Finder window open
- [ ] Should handle gracefully

### ✅ Performance Testing
- [ ] Rapidly press window management keys
- [ ] Should respond smoothly without lag
- [ ] Switch between applications rapidly
- [ ] Input method should switch correctly

## Deployment Steps

### 1. Backup Current Configuration
```bash
cp -r ~/.config/hammerspoon ~/.config/hammerspoon.backup
```

### 2. Deploy Refactored Configuration
```bash
# Already in place, just reload
# Press Cmd+Alt+Ctrl+R or:
hs.reload()
```

### 3. Verify Loading
- [ ] Check Hammerspoon console for errors
- [ ] Should see "✅ Hammerspoon Config Loaded"
- [ ] No error notifications should appear

### 4. Test Core Functionality
- [ ] Go through "Functional Testing" checklist above
- [ ] Mark each test as passed

### 5. Monitor for Issues
- [ ] Use for 1 day and note any issues
- [ ] Check Hammerspoon console periodically
- [ ] Verify all hotkeys work as expected

## Rollback Plan

If issues are found:

```bash
# Restore backup
rm -rf ~/.config/hammerspoon
mv ~/.config/hammerspoon.backup ~/.config/hammerspoon

# Reload Hammerspoon
# Press Cmd+Alt+Ctrl+R
```

## Known Limitations

1. **Lua not in PATH**: Cannot run standalone Lua syntax checks
   - **Workaround**: Rely on Hammerspoon's built-in parser
   - **Alternative**: Use online Lua validators

2. **No automated tests**: Manual testing required
   - **Future**: Add busted testing framework

3. **Hot-reload limitations**: Some changes require full restart
   - **Example**: Watcher callbacks may not update properly

## Success Criteria

✅ **All tests pass**
✅ **No errors in console**
✅ **All features work as before**
✅ **Performance improved or maintained**
✅ **Code is more maintainable**

## Sign-off

- [ ] Developer: ________________ Date: ________
- [ ] Reviewer: ________________ Date: ________
- [ ] Approved: ________________ Date: ________

---

*Last Updated: 2025-12-24*
