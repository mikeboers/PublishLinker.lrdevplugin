local LrXml = import 'LrXml'


local M = {}


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


M.xmlToTable = function(xml)
    
    -- Implicitly convert to a LrXml.xmlDomInstance.
    if type(xml) == "string" then
        xml = LrXml.parseXml(xml)
    end

    local res = {}

    -- Convert all attributes.
    for _, attrib in pairs(xml:attributes()) do
        res['@' .. attrib.name] = attrib.value
    end

    -- Convert all children.
    for i = 1, xml:childCount() do
        local child = xml:childAtIndex(i)

        local childArray = res[child:name()] or {}
        res[child:name()] = childArray

        childArray[#childArray + 1] = M.xmlToTable(child)
    end

    return res

end


return M

