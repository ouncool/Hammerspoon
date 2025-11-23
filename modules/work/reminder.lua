-- **************************************************
-- 工作提醒：在指定时间提示（每日）
-- 默认时间：11:30 和 17:30
-- **************************************************

local reminders = {
  { hour = 11, min = 30, title = '午休提醒', msg = '现在是 11:30，记得午休或整理一下任务。' },
  { hour = 17, min = 30, title = '下班提醒', msg = '现在是 17:30，记得收工下班。' },
}

local alerted = {}

local function keyFor(r)
  return string.format('%02d:%02d', r.hour, r.min)
end

local function checkReminders()
  local t = os.date('*t')

  for _, r in ipairs(reminders) do
    local k = keyFor(r)
    if t.hour == r.hour and t.min == r.min then
      if not alerted[k] then
        hs.alert.show(r.msg)
        hs.notify.new({ title = r.title, informativeText = r.msg }):send()
        alerted[k] = true
      end
    else
      alerted[k] = false
    end
  end
end

-- 每 30 秒检查一次（足够精确同时不会太耗资源）
local reminderTimer = hs.timer.doEvery(30, checkReminders)
checkReminders()

return {}
