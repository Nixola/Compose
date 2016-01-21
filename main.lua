require "noglob"
require "utils"

local board, instruments, instrument, gui, sound
local buttons = {}

love.load = function()
  var "SCR_W" (love.graphics.getWidth())
  var "SCR_H" (love.graphics.getHeight())

  love.graphics.setBackgroundColor(255, 248, 230)

  board = require "board"
  instruments = require "instruments"
  instrument = instruments[1]
  board.data = instruments[instrument].data

  gui = require "gui"

  for i, v in ipairs(instruments) do
    local b = buttons[i-1]
    local x = b and b.x + b.width + 16 or 16
    buttons[i] = gui.button(x, 24, v, function()
      instrument = v
      board.data = instruments[v].data
    end)
  end

  sound = require "sound"

end

love.update = function(dt)
  board:update(dt)
  for i, v in ipairs(buttons) do
    v:update(dt)
  end
end

love.draw = function()
  board:draw()
  for i, v in ipairs(buttons) do
    v:draw()
  end
end

love.mousepressed = function(x, y, b)
  board:mousepressed(x, y, b)
  for i, v in ipairs(buttons) do
    v:mousepressed(x, y, b)
  end
end

love.wheelmoved = function(wx, wy)
  board:wheelmoved(wx, wy)
end

love.keypressed = function(key)
  if key == "space" then
    if board.playing then
      board:pause()
    else
      board:play()
    end
  elseif key == "escape" then
    board:stop()
  end
end