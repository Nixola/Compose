local board = require "board"
local instruments = require "instruments"
local first

board.tick = function(self, oldNote, newNote)
  for i, v in ipairs(instruments) do
    local instrument = instruments[v]
    local data, sources = instrument.data, instrument.sources
    for cell = (newNote - 1) * self.height + 1, (newNote) * self.height do
      local v = data[cell] or 0
      local ov = data[cell - self.height] or 0
      --note number should probably be reversed; 1 is highest, self.height is lowest, but Notes does things the *right* way.
      local note = (self.height - cell ) % self.height + 1
      --[[
      if v == 1 and ov == 0 then
        sources[note]:play()
      elseif v == 0 and ov == 1 then
        sources[note]:stop()
      end--]]
      if ov == 3 then
        sources[note]:stop()
      end
      if v == 0 and ov == 1 then
        sources[note]:stop()
      elseif v == 1 then
        sources[note]:stop()
        sources[note]:play()
      elseif v == 2 then
        sources[note]:play()
      end

      -- I *NEED* to handle case 2 and 3 (notes starts, note stops).
    end
  end
end