require "noglob"
require "utils"

local board, instruments, instrument, gui, sound, state

var "log" "dummy"
var "events" (function() end)

var "config" {}

local buttons = {}

love.load = function(arg)
  --pTable(arg)
  table.remove(arg, 1)
  for i, v in ipairs(arg) do
    if v:match("^%-%-") then --option
      config[v:match("^%-%-(.-)$")] = true
    else --par
      local o = arg[i-1]:match("^%-%-(.-)$")
      config[o] = v
    end
  end
  var "SCR_W" (love.graphics.getWidth())
  var "SCR_H" (love.graphics.getHeight())

  board = require "board"
  instruments = require "instruments"

  --board:load()

  love.keyboard.setKeyRepeat(true)

  state = instruments

  state.done = function(self)
    state = board
    board:load()
    love.graphics.setBackgroundColor(255, 248, 230)
    gui = require "gui"

    for i, v in ipairs(self) do
      local b = buttons[i-1]
      local x = b and b.x + b.width + 16 or 16
      buttons[i] = gui.button(x, 24, v, function()
        instrument = v
        board.data = instruments[v].data
      end)
    end

    log = gui.log(8, SCR_H - board.padding, SCR_W - 16, board.padding)
    events = gui.log(SCR_W - board.padding + 1, board.padding, board.padding - 2, SCR_H - board.padding*2)

    sound = require "sound"
    buttons[1].func()
    if config.loadLast then
      local saves = love.filesystem.getDirectoryItems("saves/")
      instruments:loadFile(saves[#saves])
    end
  end

  state:load()

end

love.update = function(dt)
  state:update(dt)
  for i, v in ipairs(buttons) do
    v:update(dt)
  end
end

love.draw = function()
  state:draw()
  love.graphics.setFont(fonts[12])
  for i, v in ipairs(buttons) do
    v:draw()
  end
  love.graphics.setColor(0, 0, 0)
end

love.mousepressed = function(x, y, b)
  state:mousepressed(x, y, b)
  for i, v in ipairs(buttons) do
    v:mousepressed(x, y, b)
  end
  events((b == 1 and "lm") or (b == 2 and "rm") or (b == 3 and "mm") or (b .. "m"))
end

love.wheelmoved = function(wx, wy)
  state:wheelmoved(wx, wy)
  events( (wy < 0 and "wu") or (wy > 0 and "wd") or (wx < 0 and "wl") or (wx > 0 and "wr"))
end

love.keypressed = function(key)
  local ctrl = love.keyboard.isDown("lctrl", "ctrl", "rctrl")
  local shift = love.keyboard.isDown("lshift", "shift", "rshift")
  local alt = love.keyboard.isDown("lalt", "alt", "ralt")
  if key == "s" and ctrl then
    instruments:save()
  end
  if key == "l" and ctrl then
    local saves = love.filesystem.getDirectoryItems("saves/")
    instruments:loadFile(saves[#saves])
  end
  state:keypressed(key)
  if not (key:match("ctrl") or key:match("shift") or key:match("alt")) then
    local s = ""
    s = ctrl and (s .. "C + ") or s
    s = alt and (s .. "A + ") or s
    s = shift and (s .. "S + ") or s
    s = s .. key
    events(s)
  end
end