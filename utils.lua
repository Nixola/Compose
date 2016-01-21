math.clamp = function(min, n, max)
  return math.max(math.min(max, n), min)
end