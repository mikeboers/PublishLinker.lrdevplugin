local LrApplication = import 'LrApplication'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local LrFunctionContext = import 'LrFunctionContext'


local log = LrLogger()
log:enable('print')


local append = function(t, x) t[#t + 1] = x end

local servicePluginNames = {
    ["com.adobe.lightroom.export.flickr"] = 'Flickr',
    ["com.adobe.lightroom.export.facebook"] = 'Facebook',
}


LrTasks.startAsyncTask(function()
LrFunctionContext.callWithContext('PublishLinker.AddRemoteCollection', function(context)

    local catalog = LrApplication.activeCatalog()
    local services = catalog:getPublishServices()

    local serviceMenuItems = {}
    for _, service in ipairs(services) do

        local pluginId = service:getPluginId()
        local serviceType = servicePluginNames[pluginId] or pluginId
        append(serviceMenuItems, {
            title = serviceType .. ': ' .. service:getName(),
            value = {
                service = service,
            }
        })

    end

    local ui = LrView.osFactory()

    local props = LrBinding.makePropertyTable(context)
    
    props:addObserver('remoteUrl', function(props, key, newValue)
        local id = string.match(newValue, '(%d+)[^%d]*$')
        if id then
            props.remoteId = id
        end
    end)
    
    props.remoteUrl = ''
    props.service = serviceMenuItems[1].value

    -- Create the contents for the dialog.
    local c = ui:column {

        bind_to_object = props,
        spacing = ui:control_spacing(),

        ui:row {
            ui:static_text {
                title = 'Service: ',
                alignment = 'right',
                width = LrView.share 'label_width', 
            },
            ui:popup_menu {
                items = serviceMenuItems,
                value = LrView.bind 'service'
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

        ui:row {
            ui:static_text {
                title = 'Remote ID: ',
                alignment = 'right',
                width = LrView.share 'label_width',
            },
            ui:edit_field {
                value = LrView.bind 'remoteId',
                width = 250,
            },
        },

        ui:row {
            ui:static_text {
                title = 'Name: ',
                alignment = 'right',
                width = LrView.share 'label_width',
            },
            ui:edit_field {
                value = LrView.bind 'name',
                width = 250,
            },
        },

    }

    local res = LrDialogs.presentModalDialog {
        title = "Link Published Collection",
        contents = c,
    }
    if res ~= 'ok' then return end

    local service = props.service.service

    -- Make sure there isn't a collision.
    -- TODO: This should really check the full graph.
    for _, collection in ipairs(service:getChildCollections()) do
        if collection:getRemoteId() == props.remoteId then
            LrDialogs.showError("This collection already exists.")
            return
        elseif collection:getRemoteURL() == props.remoteUrl then
            LrDialogs.showError("This collection already exists.")
            return
        end 
    end

    catalog:withWriteAccessDo('PublishLinker.AddRemoteCollection.Create', function()
        local collection = props.service.service:createPublishedCollection(props.name, nil, true)
        collection:setRemoteId(props.remoteId)
        collection:setRemoteUrl(props.remoteUrl)
    end)

end)
end)

