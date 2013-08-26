local LrApplication = import 'LrApplication'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrDate = import 'LrDate'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'
local LrFunctionContext = import 'LrFunctionContext'
local LrXml = import 'LrXml'
local LrHttp = import 'LrHttp'


local log = LrLogger()
log:enable('print')


local append = function(t, x) t[#t + 1] = x end



LrTasks.startAsyncTask(function()
LrFunctionContext.callWithContext('PublishLinker.Sandbox', function(context)


    local ui = LrView.osFactory()
    local props = LrBinding.makePropertyTable(context)
    
    local thumb_resource = _PLUGIN:resourceId('example_thumb.jpg')

    log:info('thumb_resource', thumb_resource)

    -- Create the contents for the dialog.
    local c = ui:column {

        bind_to_object = props,
        spacing = ui:control_spacing(),

        ui:row {
            ui:static_text {
                title = 'Picture: ',
                alignment = 'right',
                width = LrView.share 'label_width', 
            },
            ui:picture {
                value = thumb_resource,
                frame_width = 1,
            },

        },

    }

    local res = LrDialogs.presentModalDialog {
        title = "Dev Sandbox",
        contents = c,
    }
    if res ~= 'ok' then return end



end)
end)

