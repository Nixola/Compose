local notes = love.filesystem.load "notes.lua"
local board = require "board"

local instruments = {
  --sine = notes("sine", 0.8, 1, board.height),
  --square = notes("square", 0.8, 1, board.height),
  --organ = notes("organ", 0.8, 1, board.height),
  --guitar = notes("guitarbeat", 0.8, 1, board.height);

  "sine", "square", "organ", "guitar";
}

--[[
for i, v in ipairs(instruments) do
  i = instruments[v]
  i.data = {}
end--]]

local c
local i = 1
local ins = instruments[i]
local timer = 0

instruments.load = function(self)
  c = coroutine.create(notes(ins, 0.8, 1, board.height))
  coroutine.resume(c)
end

instruments.update = function(self, dt)
  local b, n = coroutine.resume(c)
  assert(b, n)
  if not n then b, n = coroutine.resume(c) assert(b, n) end
  if n then
    instruments[ins] = n
    n.data = {}
    i = i + 1
    ins = instruments[i]
    if not ins then
      self:done()
    else
      c = coroutine.create(notes(ins, 0.8, 1, board.height))
    end
  end
  timer = timer + dt
end

instruments.draw = function(self)
  love.graphics.setFont(fonts[48])
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf("Loading...", 0, 200, SCR_W, "center")
  love.graphics.setLineWidth(4)
  love.graphics.circle("line", SCR_W/2, SCR_H / 2, math.sin(timer*2) * 50, 50) -- 24 + 25, 50)
end

--dummy callbacks
instruments.keypressed = function(self, key)
end

instruments.mousepressed = function(self, x, y, b)
end

instruments.wheelmoved = function(self, wx, wy)
end
--[[Savefile example:
1:1,2,3 ; 4,5 ; 6
2:1 ; 2,3,4 ; 
3: ; 1,2 ; ]]

instruments.save = function(self, name)
  name = (name or os.time()) .. ".nixm"
  local save = {}
  for i, insName in ipairs(self) do
    local data = self[insName].data
    local t = {{},{},{}, [0] = {}}
    for i, v in pairs(data) do
      print(v, type(v))
      table.insert(t[v], i)
    end
    for i, v in ipairs(t) do
      t[i] = table.concat(v, ',')
    end
    save[i] = i .. ':' .. table.concat(t, ' ; ')
  end
  local s = table.concat(save, '\n')
  print(s)
  if not love.filesystem.isDirectory("saves") then
    love.filesystem.createDirectory("saves")
  end
  s = board.bpm .. "\n" .. s
  local f = love.filesystem.newFile("saves/" .. name, "w")
  f:write(love.math.compress(s, "zlib", 9))
  f:close()
  log("Correctly saved: " .. name)
end

instruments.loadFile = function(self, filename)
  local f, e = love.filesystem.newFile("saves/" .. filename, "r")
  if not f then return f, e end
  local s = f:read()
  f:close()
  s = love.math.decompress(s, "zlib")
  local s1, bpm
  bpm, s1 = s:match("^(%d+)\n(.-)$")
  board.bpm = bpm or board.bpm
  s = s1 or s
  for piece in s:gmatch("([^%\n]+)") do
    print(piece)
    print()
    local i
    i, piece = piece:match("^(%d+):(.-)$")
    i = tonumber(i)
    local value = 1
    for part in piece:gmatch("([^;]+)") do
      print("|" .. part .. "|")
      for note in part:gmatch("(%d+)") do
        print(note)
        local ins = instruments[i]
        instruments[ins].data[tonumber(note)] = value
        print("Loading note " .. note .. " (" .. value .. ") for instrument " .. ins)
      end
      value = value + 1
    end
  end
  board.changed = true --board:render won't work! why!
  log("Correctly loaded: " .. filename)
end
  
return instruments