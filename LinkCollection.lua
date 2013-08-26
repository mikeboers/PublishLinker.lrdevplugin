local LrApplication = import 'LrApplication'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'

local KnownServices = require 'KnownServices'


local log = LrLogger()
log:enable('print')


local catalog = LrApplication.activeCatalog()
local sources = catalog:getActiveSources()


--[[
if #sources ~= 1 then
    LrDialogs.message('Please select one published collection.', nil, 'critical')
    return nil
end

local catalog = sources[1]
if catalog:type() ~= "LrPublishedCollection" then
    LrDialogs.message("Please select a published collection.", nil, 'critical')
    return nil
end
]]

LrFunctionContext.postAsyncTaskWithContext('PublishLinker_LinkCollection', function(context)

    local services = catalog:getPublishServices()
    local collectionItems = {}
    local append = function(t, x) t[#t + 1] = x end
    for _, service in ipairs(services) do

        local serviceDef = KnownServices.serviceById(service:getPluginId())
        if serviceDef then
            append(collectionItems, {
                title = serviceDef.name .. ': (new)',
                value = #collectionItems, 
            })
        end
    end

    local ui = LrView.osFactory()

    local props = LrBinding.makePropertyTable(context)
    props.remoteUrl = 'http://www.flickr.com/photos/mikeboers/sets/72157635207321829/'

    -- Create the contents for the dialog.
    local c = ui:column {

        bind_to_object = props,
        spacing = ui:control_spacing(),

        ui:row {
            ui:static_text {
                title = 'Collection: ',
                alignment = 'right',
                width = LrView.share 'label_width', 
            },
            ui:popup_menu {
                items = collectionItems,
            },
        },

        ui:row {
            ui:static_text {
                title = 'Remote URL: ',
                alignment = 'right',
                width = LrView.share 'label_width',
            },
            ui:edit_field {
                value = LrView.bind 'remoteUrl',
                width = 600,
            },
        },

    }

    local res = LrDialogs.presentModalDialog {
        title = "Link Published Collection",
        contents = c,
    }
    if res ~= 'ok' then return nil end


    local username, remoteId = string.match(props.remoteUrl, 'http://www.flickr.com/photos/(%w+)/sets/(%d+)/')
    log:info('remote ID', remoteId)

    LrTasks.startAsyncTask(function()
        catalog:withWriteAccessDo('Create Published Collection', function()
            log:info('creating collection...')
            local collection = flickrService:createPublishedCollection(remoteId, nil, true)
            log:info('created collection', collection)
            collection:setRemoteId(remoteId)
            collection:setRemoteUrl(props.remoteUrl)
        end)
    end)

end)

