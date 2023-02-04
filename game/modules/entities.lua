local M = {}

local entities = {}

function M.register(name, url) 
	entities[name] = url
end

function M.get(name)
	return entities[name]
end

return M
