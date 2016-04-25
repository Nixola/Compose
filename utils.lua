math.clamp = function(min, n, max)
  return math.max(math.min(max, n), min)
end

var "fonts" (setmetatable({}, {__index = function(self, k)
  assert(tonumber(k) and k % 1 == 0, "Font size must be an integer.")
  self[k] = love.graphics.newFont(k)
  return self[k]
end}))

var "pTable"(
function(t, n)
  n = n or 0
  for i, v in pairs(t) do
    io.write(("\t"):rep(n))
    io.write(tostring(i), ":\t", type(v), "\t", tostring(v), "\n")
    if type(v) == "table" then
      pTable(v, n+1)
    end
  end
  if n == 0 then
    io.write "\n"
  end
end
)