local M = {}

local ctx = nil
local log = nil
local chooser = nil
local previousApp = nil

local function chooseColor(object, methodName, value)
  local method = object[methodName]
  if type(method) == 'function' and type(value) == 'table' then
    object[methodName](object, value)
  end
end

local function callChooserMethod(object, methodName, ...)
  if not object then
    return false
  end
  local method = object[methodName]
  if type(method) ~= 'function' then
    return false
  end
  method(object, ...)
  return true
end

local function setChooserRows(object, rows)
  if type(rows) ~= 'number' then
    return false
  end

  if type(object.numRows) == 'function' then
    object:numRows(rows)
    return true
  end

  if type(object.rows) == 'function' then
    object:rows(rows)
    return true
  end

  return false
end

local function ensureChooser(onChoose_fn)
  if chooser then
    return chooser
  end

  chooser = hs.chooser.new(onChoose_fn)

  local cfg = ctx.config.appSwitcher
  chooseColor(chooser, 'bgColor', cfg.bgColor)
  chooseColor(chooser, 'fgColor', cfg.textColor)
  chooseColor(chooser, 'textColor', cfg.textColor)
  chooseColor(chooser, 'subTextColor', cfg.subTextColor)

  callChooserMethod(chooser, 'searchSubText', false)

  local width = cfg.width
  if type(width) ~= 'number' then
    width = 40
  end

  -- hs.chooser:width expects percentage (e.g. 40), but config may use ratio (0.4).
  if width > 0 and width <= 1 then
    width = width * 100
  end

  if width < 30 then
    width = 30
  elseif width > 80 then
    width = 80
  end
  callChooserMethod(chooser, 'width', width)

  setChooserRows(chooser, cfg.numRows)
  callChooserMethod(chooser, 'font', {name = 'System', size = cfg.textSize})
  callChooserMethod(chooser, 'subTextFont', {name = 'System', size = cfg.subTextSize})

  callChooserMethod(chooser, 'shadow', cfg.shadow)

  if cfg.radius then
    callChooserMethod(chooser, 'radius', cfg.radius)
  end

  return chooser
end

function M.init(runtime, logger)
  ctx = runtime
  log = logger
end

function M.showSwitcher(appChoices_fn, onChoose_fn)
  previousApp = hs.application.frontmostApplication()

  local choices = appChoices_fn()
  if #choices == 0 then
    hs.alert.show('No switchable apps')
    return
  end

  local c = ensureChooser(onChoose_fn)
  local cfgRows = ctx.config.appSwitcher.numRows or 8
  local rows = math.max(3, math.min(cfgRows, #choices))
  setChooserRows(c, rows)
  c:choices(choices)
  c:show()

  log.debug('App switcher shown', {choices = #choices, rows = rows, scope = ctx.config.appSwitcher.scope})
end

function M.stopChooser()
  if chooser then
    chooser:delete()
    chooser = nil
  end
  previousApp = nil
end

return M
