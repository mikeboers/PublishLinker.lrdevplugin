local Lr = require 'Lr'
local utils = require 'utils'

local log = Lr.Logger()
log:enable('print')


local append = function(t, x) t[#t + 1] = x end



Lr.Tasks.startAsyncTask(function()
Lr.FunctionContext.callWithContext('PublishLinker.AddRemoteCollection', function(context)

    local catalog = Lr.Application.activeCatalog()
    local services = catalog:getPublishServices()
    local photo = catalog:getTargetPhoto()

    if not photo then
        Lr.Dialogs.showError("Please select a photo.")
        return
    end

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


    local resetCollectionItems = function(service)

        if not service then
            props.collectionItems = {}
            props.collectionValue = nil
            return
        end

        local newItems = {}
        for _, collection in ipairs(service:getChildCollections()) do
            append(newItems, {
                title = collection:getName(),
                value = {
                    service = service,
                    collection = collection
                }
            })
        end

        props.collectionItems = newItems
        props.collectionValue = newItems[1].value

    end

    resetCollectionItems(props.service.service)

    props:addObserver('service', function(props, key, newValue)
        -- log:trace(string.format("service changed to %s: %s", utils.repr(key), utils.repr(newValue)))
        resetCollectionItems(newValue.service)
    end)

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
                title = 'Collection: ',
                alignment = 'right',
                width = Lr.View.share 'label_width',
            },
            ui:popup_menu {
                items = Lr.View.bind 'collectionItems',
                value = Lr.View.bind 'collectionValue'
            }
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

    }

    local res = Lr.Dialogs.presentModalDialog {
        title = "Link Remote Photo",
        contents = c,
    }
    if res ~= 'ok' then return end

    local service = props.service and props.service.service
    local collection = props.collectionValue and props.collectionValue.collection
    if not service or not collection then
        return
    end

    catalog:withWriteAccessDo('PublishLinker.AddRemoteCollection.Create', function()
        collection:addPhotoByRemoteId(photo, props.remoteId, props.remoteUrl, true)
    end)

end)
end)

