local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'

local Utils = require 'utils'


local log = LrLogger()
log:enable('print')


local _urlBase = 'http://api.flickr.com/services/rest/'
local _apiKey = '46912733cea0913d152057b8d6a8da81'


local call = function(method, data)
    
    data.method = method
    data.format = 'rest'
    data.api_key = _apiKey

    local encodedData = {}
    for k, v in pairs(data) do
        encodedData[#encodedData + 1] = string.format('%s=%s', k, v)
    end

    local url = _urlBase .. '?' .. table.concat(encodedData, '&')
    local body, headers = LrHttp.get(url)

    if headers.status ~= 200 then
        error('non-200 response: ' .. tostring(headers.status))
    end

    local res = Utils.xmlToTable(body)

    if res['@stat'] ~= 'ok' then
        error('non-ok response')
    end

    return res

end


return {
    call = call,
}

