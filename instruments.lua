local notes = love.filesystem.load "notes.lua"
local board = require "board"

local instruments = {
  sine = notes("sine", 0.8, 1, board.height),
  square = notes("square", 0.8, 1, board.height),
  organ = notes("organ", 0.8, 1, board.height);

  "sine", "square", "organ";
}

for i, v in ipairs(instruments) do
  i = instruments[v]
  i.data = {}
end

return instruments