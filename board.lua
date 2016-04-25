local tween = require "lib.tween"

local notesList = require "notesList"

local instruments

local board = {}
board.load = function(self)
  instruments = require "instruments"
  self.data = {} -- 1D table; will be indexed by x * MAX_HEIGHT (92) + y
  self.bpm = 120
  self.x = 0
  self.targetX = 0
  self.y = 0
  self.targetY = 0
  self.tileSize = 12
  self.padding = 64
  self.length = math.floor((800 - self.padding*2) / self.tileSize)
  self.height = 76 -- number of notes; height in pixels will be this * tileSize. 92 are probably too much, I'll tone it down later or make it tuneable.
  self.spritebatch = love.graphics.newSpriteBatch(love.graphics.newImage("cell.png"), 10000)
  self.square = love.graphics.newImage("square.png")
  self.square:setWrap("repeat", "repeat")
  self.grid = love.graphics.newQuad(0, 0, SCR_W + self.tileSize*2, SCR_H + self.tileSize*2, 12, 12)
  self.cells = {
    love.graphics.newQuad(1, 1, 10, 10, 36, 12),
    love.graphics.newQuad(13, 1, 10, 10, 36, 12),
    love.graphics.newQuad(25, 1, 10, 10, 36, 12)
  }
  self.time = 0

  self.tween = tween.new(1, self, {x = 0, y = 0}, "outQuad")
end

board.mousepressed = function(self, x, y, b)
	if x < self.padding or x > SCR_W - self.padding or
	y < self.padding or y > SCR_H - self.padding then
	  --UI stuff. Nothing to do here. Maybe pass it to the UI itself here instead of in main?
	  return
	end
	local cx = math.floor((x - self.padding + self.x) / self.tileSize)
	local cy = math.floor((y - self.padding + self.y) / self.tileSize)
  local v = self.data[cx * self.height + cy] or 0
  if b == 1 then
    self.data[cx * self.height + cy] = (v+1)%4
    self.changed = true
  elseif b == 2 then
    self.data[cx * self.height + cy] = 0
    self.changed = true
  end
end

board.wheelmoved = function(self, wx, wy)
  local shift = love.keyboard.isDown("lshift", "shift", "rshift")
  wx, wy = shift and wy or wx, shift and wx or wy
  --[[
  local ty = self.targetY - self.tileSize * 8 * wy
  self.targetY = math.clamp(0, ty, self.height*self.tileSize - (SCR_H + self.padding))--]]
  local sy = -self.tileSize * 8 * wy

  --[[
  local tx = self.targetX - self.tileSize * 8 * wx
  self.targetX = math.clamp(0, tx, self:getLength() * self.tileSize - self.padding * 2)--]]
  local sx = -self.tileSize * 8 * wx

  --if not (self.targetY == self.y and self.targetX == self.x) then --scrolling happened
  self:scroll(sx, sy)
  --end

end

board.update = function(self, dt)
  self.tween:update(dt)
  if self.changed then
    self:render()
  end
  if self.playing then
    local oTime = self.time
    local bps = self.bpm/60
    self.time = self.time + dt
    local oldNote = math.ceil(oTime * bps)
    local newNote = math.ceil(self.time * bps)
    if not (oldNote == newNote) then
      for n = oldNote + 1, newNote do
        self:tick(n - 1, newNote)
      end
    end
    local lineX = self.padding - self.x + self.time * self.bpm/60 * self.tileSize
    local sx = 0
    if lineX < self.padding then
      sx = lineX - self.padding - self.tileSize * 8
    elseif lineX > SCR_W - self.padding then
      --sx = lineX + self.tileSize * 24 - (self.x + SCR_W - self.padding)
      sx = self.tileSize * 24 + (lineX - SCR_W + self.padding)
      print(lineX, sx)
    end
    self:scroll(sx)
  end
end

board.draw = function(self)
  love.graphics.setScissor(self.padding, self.padding, SCR_W - self.padding*2, SCR_H - self.padding*2)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.square, self.grid, ((-self.x) % self.tileSize) + self.padding, ((-self.y + self.padding) % self.tileSize) - self.tileSize)
  love.graphics.draw(self.spritebatch, -self.x + self.padding, -self.y + self.padding)

  love.graphics.setColor(0, 255, 255)
  local lineX = self.padding - self.x + self.time * self.bpm/60 * self.tileSize
  love.graphics.line(lineX, 0, lineX, SCR_H)

  love.graphics.setColor(0, 192, 0, 32)
  local mx, my = love.mouse.getPosition()
  mx = mx - self.padding
  my = my - self.padding
  local cx = math.floor(mx / self.tileSize)
  local cy = math.floor(my / self.tileSize)
  love.graphics.rectangle("fill", cx * self.tileSize + self.padding + (-self.x)%self.tileSize, self.padding, self.tileSize, SCR_H)
  love.graphics.rectangle("fill", self.padding, cy * self.tileSize + self.padding + (-self.y)%self.tileSize, SCR_W, self.tileSize)

  love.graphics.setScissor(0, self.padding, self.padding, SCR_H - self.padding * 2)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setFont(fonts[10])
  --love.graphics.printf(table.concat(notesList, "\n", 88 - self.height), 0, self.padding - self.y, self.padding, "right")
  love.graphics.printf(table.concat(notesList, "\n", 88 - self.height, self.height), 0, self.padding - self.y, self.padding, "right")
  love.graphics.setScissor()
  --love.graphics.setFont(fonts[12])
  log:draw()
  events:draw()
  
  --DEBUG
  --love.graphics.circle("fill", self.x, self.y, 16, 64)
end

board.keypressed = function(self, key)
  local ctrl = love.keyboard.isDown("ctrl", "rctrl", "lctrl")
  if key == "space" then
    if self.playing then self:pause()
    else self:play()
    end
  elseif key == "escape" then
    self:stop()
  elseif key == "up" then
    self.bpm = self.bpm + (ctrl and 5 or 1)
    print(self.bpm)
  elseif key == "down" then
    self.bpm = self.bpm - (ctrl and 5 or 1)
    print(self.bpm)
  end
end


board.pause = function(self)
  self.playing = false
  love.audio.stop() --improve this; handle playing notes, stop/pause them (don't rewind them) and store them so that they can be played back
end

board.play = function(self)
  self.playing = true
  --improve this; restore playing notes if any
end

board.stop = function(self)
  love.audio.stop()
  self.playing = false
  self.time = 0
end

board.getLength = function(self)
  local n = 0
  for i, v in ipairs(instruments) do
    local ins = instruments[v]
    local ni = table.maxn(ins.data)
    n = math.max(n, ni)
  end
  return math.max(math.floor(n/self.height) + 24, 56)
end

board.scroll = function(self, x, y)
  x, y = x or 0, y or 0
  local tx = self.targetX + x
  local ty = self.targetY + y

  local otx, oty = self.targetX, self.targetY

  self.targetX = math.clamp(0, tx, self:getLength() * self.tileSize - self.padding * 2)
  self.targetY = math.clamp(0, ty, self.height*self.tileSize - (SCR_H + self.padding))

  if not (self.targetX == otx and self.targetY == oty) then --scrolling happened
    self.tween = tween.new(.25, self, {x = self.targetX, y = self.targetY}, "outQuad")
  end
end



board.render = function(self)
  self.spritebatch:clear()
  for i, v in pairs(self.data) do
    if type(i) == "number" then
      local cx = math.floor(i / self.height)
      local cy = i % self.height
      if not (v == 0) then
        --self.spritebatch:setColor((v == 1 or v == 3) and 255 or 0, (v == 1 or v == 2) and 255 or 0, (v == 1) and 255 or 0)
        self.spritebatch:add(self.cells[v], (cx) * self.tileSize + 1, (cy) * self.tileSize + 1)
      end
    end
  end
end

return board