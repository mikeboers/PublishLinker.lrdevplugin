local LrXml = import 'LrXml'


local M = {}


M.servicePluginNames = {
    ["com.adobe.lightroom.export.flickr"] = 'Flickr',
    ["com.adobe.lightroom.export.facebook"] = 'Facebook',
    ["com.mikeboers.lightroom.export.flask"] = 'Flask',
    ["com.mikeboers.lightroom.export.webhooks"] = 'WebHooks',
}


local _indent = function(n)
    return string.rep('    ', n)
end


M.repr = function(x, depth)
    depth = depth or 0
    local type_ = type(x)
    if type_ == 'table' then
        local res = '{\n'
        depth = depth + 1
        for k, v in pairs(x) do
            res = res .. _indent(depth) .. k .. ' = ' .. M.repr(v, depth) .. ',\n'
        end
        depth = depth - 1
        res = res .. _indent(depth) .. '}'
        return res
    elseif type_ == 'string' then
        return '"' .. x .. '"'
    else
        return tostring(x)
    end
end


return M

