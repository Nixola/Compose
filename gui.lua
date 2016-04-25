local gui = {}

gui.button = {}
gui.button.inactive = {96, 96, 96}
gui.button.active = {160, 160, 160}
gui.button.__index = gui.button
gui.button.__parent = gui
setmetatable(gui.button, {__call = function(self, x, y, text, func, size)
  local t = {}
  t.x = x
  t.y = y
  t.text = text
  t.func = func
  t.size = t.size or 16
  t.width = love.graphics.getFont():getWidth(text) + 6
  t.height = love.graphics.getFont():getHeight() + 6
  setmetatable(t, self)
  return t
end})

gui.button.draw = function(self)
  love.graphics.setColor(self.hover and self.active or self.inactive)
  love.graphics.rectangle("fill", self.x + 1, self.y +1, self.width - 2, self.height - 2)
  love.graphics.setColor(192, 192, 192)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

  love.graphics.setColor(255, 255, 255)
  love.graphics.print(self.text, self.x + 3, self.y + 3)
end

gui.button.update = function(self, dt)
  local mx, my = love.mouse.getPosition()
  if mx > self.x and mx < self.x + self.width and
  my > self.y and my < self.y + self.height then
    self.hover = true
  else
    self.hover = false
  end
end

gui.button.mousepressed = function(self, mx, my, b)
  if mx > self.x and mx < self.x + self.width and
  my > self.y and my < self.y + self.height  and
  b == 1 then
    self.func()
  end
end


gui.log = {}
setmetatable(gui.log, {__call = function(self, x, y, width, height)
  local t = {}
  t.x = x
  t.y = y
  t.width = width
  t.height = height
  t.buffer = {}
  setmetatable(t, {__index = self, __call = function(s, t) return s:push(t) end})
  return t
end})

gui.log.draw = function(self)
  local y = self.y + self.height
  local step = love.graphics.getFont():getHeight()
  for i = 1, #self.buffer do
    if i * step > self.height then break end
    local ii = #self.buffer - i + 1
    local v = self.buffer[ii]
    love.graphics.print(v, self.x, y - step * i)
  end
end

gui.log.push = function(self, text)
  local w, t = love.graphics.getFont():getWrap(text, self.width)
  for i, v in ipairs(t) do
    table.insert(self.buffer, t)
  end
end



return gui