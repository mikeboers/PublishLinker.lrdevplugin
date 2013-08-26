
local M = {}

M.serviceById = {}

local function defineService(t)
    M.serviceById[t.pluginId] = t
end


defineService {

    pluginId = 'com.adobe.lightroom.export.flickr',
    name = 'Flickr',

    parseCollectionUrl = function(url)
        local pattern = 'http://www.flickr.com/photos/(%w+)/sets/(%d+)/'
        local username, id = string.match(url, pattern)
        if username then return {
            url = url,
            username = username,
            id = id,
        } end
    end

}



return M
