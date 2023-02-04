local M = {}

local entities = {}

function M.register(name) 
	entities[name] = msg.url()
end

function M.get(name)
	return entities[name]
end

return M
