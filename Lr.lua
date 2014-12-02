
local Lr = {}
local meta = {}

setmetatable(Lr, meta)

meta.__index = function(table, key)
    
    key = string.sub(key, 1, 1):upper() .. string.sub(key, 2)
    Lr[key] = import('Lr' .. key)
    return Lr[key]

end

return Lr
