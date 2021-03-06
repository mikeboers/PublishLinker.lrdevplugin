local Lr = require 'Lr'
local utils = require 'utils'

local log = Lr.Logger()
log:enable('print')


local append = function(t, x) t[#t + 1] = x end



Lr.Tasks.startAsyncTask(function()
Lr.FunctionContext.callWithContext('PublishLinker.AddRemoteCollection', function(context)

    local catalog = Lr.Application.activeCatalog()
    local services = catalog:getPublishServices()

    local serviceMenuItems = {}
    for _, service in ipairs(services) do

        local pluginId = service:getPluginId()
        local serviceType = utils.servicePluginNames[pluginId] or pluginId
        append(serviceMenuItems, {
            title = serviceType .. ': ' .. service:getName(),
            value = {
                service = service,
            }
        })

    end

    local ui = Lr.View.osFactory()

    local props = Lr.Binding.makePropertyTable(context)
    
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
                width = Lr.View.share 'label_width', 
            },
            ui:popup_menu {
                items = serviceMenuItems,
                value = Lr.View.bind 'service'
            },
        },

        ui:row {
            ui:static_text {
                title = 'Remote URL: ',
                alignment = 'right',
                width = Lr.View.share 'label_width',
            },
            ui:edit_field {
                value = Lr.View.bind 'remoteUrl',
                width = 600,
            },
        },

        ui:row {
            ui:static_text {
                title = 'Remote ID: ',
                alignment = 'right',
                width = Lr.View.share 'label_width',
            },
            ui:edit_field {
                value = Lr.View.bind 'remoteId',
                width = 600,
            },
        },

        ui:row {
            ui:static_text {
                title = 'Name: ',
                alignment = 'right',
                width = Lr.View.share 'label_width',
            },
            ui:edit_field {
                value = Lr.View.bind 'name',
                width = 250,
            },
        },

    }

    local res = Lr.Dialogs.presentModalDialog {
        title = "Link Published Collection",
        contents = c,
    }
    if res ~= 'ok' then return end

    local service = props.service.service

    -- Make sure there isn't a collision.
    -- TODO: This should really check the full graph.
    for i, collection in ipairs(service:getChildCollections()) do
        if collection:getRemoteId() == props.remoteId then
            Lr.Dialogs.showError("This collection aLr.eady exists.")
            return
        elseif collection:getRemoteUrl() == props.remoteUrl then
            Lr.Dialogs.showError("This collection aLr.eady exists.")
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

