local board = require "board"
local instruments = require "instruments"

board.tick = function(self, oldNote, newNote)
  print "hai"
  for i, v in ipairs(instruments) do
    local instrument = instruments[v]
    local data, sources = instrument.data, instrument.sources
    for cell = (newNote - 1) * self.height + 1, (newNote - 1) * self.height + self.height do
      local v = data[cell] or 0
      local ov = data[cell - self.height] or 0
      --note number should probably be reversed; 1 is highest, self.height is lowest, but Notes does things the *right* way.
      local note = (self.height - cell) % self.height + 1
      if v == 1 and ov == 0 then
        print(note)
        sources[note]:play()
      elseif v == 0 and ov == 1 then
        print(note)
        sources[note]:stop()
      end
      -- I *NEED* to handle case 2 and 3 (notes starts, note stops).
    end
  end
end