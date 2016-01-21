local tween = require "lib.tween"

local board = {}
board.data = {} -- 1D table; will be indexed by x * MAX_HEIGHT (92) + y
board.bpm = 120
board.x = 0
board.targetX = 0
board.y = 0
board.targetY = 0
board.tileSize = 12
board.padding = 64
board.length = math.floor((800 - board.padding*2) / board.tileSize)
board.height = 76 -- number of notes; height in pixels will be this * tileSize. 92 are probably too much, I'll tone it down later or make it tuneable.
board.spritebatch = love.graphics.newSpriteBatch(love.graphics.newImage("cell.png"), 10000)
board.square = love.graphics.newImage("square.png")
board.square:setWrap("repeat", "repeat")
board.grid = love.graphics.newQuad(0, 0, SCR_W + board.tileSize*2, SCR_H + board.tileSize*2, 12, 12)
board.cells = {
  love.graphics.newQuad(1, 1, 10, 10, 36, 12),
  love.graphics.newQuad(13, 1, 10, 10, 36, 12),
  love.graphics.newQuad(25, 1, 10, 10, 36, 12)
}
board.time = 0

board.tween = tween.new(1, board, {x = 0, y = 0}, "outQuad")

board.mousepressed = function(self, x, y, b)
	if x < self.padding or x > SCR_W - self.padding or
	y < self.padding or y > SCR_H - self.padding then
	  --UI stuff. Nothing to do here. Maybe pass it to the UI itself here instead of in main?
	  return
	end
	local cx = math.floor((x - self.padding + self.x) / self.tileSize)
	local cy = math.floor((y - self.padding + self.y) / self.tileSize)
  local v = self.data[cx * 92 + cy] or 0
  if b == 1 then
    self.data[cx * 92 + cy] = (v+1)%4
    self.changed = true
  elseif b == 2 then
    self.data[cx * 92 + cy] = 0
    self.changed = true
  end
end

board.wheelmoved = function(self, wx, wy)
  local ty = self.targetY - self.tileSize * 8 * wy
  self.targetY = math.clamp(0, ty, self.height*self.tileSize - (SCR_H + self.padding))
  print(ty, self.targetY)

  local tx = self.targetX + self.tileSize * 24 * wx
  self.targetX = math.clamp(0, tx, self.length * self.tileSize - (SCR_W + self.padding * 2))

  if not (self.targetY == self.y and self.targetX == self.x) then --scrolling happened
    self.tween = tween.new(.25, self, {x = self.targetX, y = self.targetY}, "outQuad")
    --print("hai", wx, wy, tx, ty)
  end

end

board.update = function(self, dt)
  self.tween:update(dt)
  if self.changed then
    self.spritebatch:clear()
    for i, v in pairs(self.data) do
      if type(i) == "number" then
        local cx = math.floor(i / 92)
        local cy = i % 92
        if not (v == 0) then
          --self.spritebatch:setColor((v == 1 or v == 3) and 255 or 0, (v == 1 or v == 2) and 255 or 0, (v == 1) and 255 or 0)
          self.spritebatch:add(self.cells[v], (cx) * self.tileSize + 1, (cy) * self.tileSize + 1)
        end
      end
    end
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
  end
end

board.draw = function(self)
  love.graphics.setScissor(0, self.padding, SCR_W - self.padding*2, SCR_H - self.padding*2)
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.square, self.grid, ((-self.x) % self.tileSize) + self.padding, ((-self.y + self.padding) % self.tileSize) - self.tileSize)
  love.graphics.draw(self.spritebatch, -self.x + self.padding, -self.y + self.padding)

  love.graphics.setColor(0, 255, 255)
  local lineX = self.padding - self.x + self.time * self.bpm/60 * self.tileSize
  love.graphics.line(lineX, 0, lineX, SCR_H)
  
  love.graphics.setScissor()
  --DEBUG
  --love.graphics.circle("fill", self.x, self.y, 16, 64)
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


return board