var = function(str)
	assert(str:match("^[_a-zA-Z][_a-zA-Z0-9]*$"), "Declared invalid variable name.")
	return function(v)
		rawset(_G, str, v)
	end
end

local mt = {
	__index = function(_, key)
		error("Attempt to get undeclared var '" .. key .. "'.")
	end,
	__newindex = function(_, key)
		error("Attempt to set undeclared var '" .. key .. "'.")
	end
}

setmetatable(_G, mt)