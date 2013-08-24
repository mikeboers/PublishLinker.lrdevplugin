local LrApplication = import 'LrApplication'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'

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
	local flickrService
	for _, service in ipairs(services) do
		if service:getPluginId() == 'com.adobe.lightroom.export.flickr' then
			flickrService = service
		end
	end

    local ui = LrView.osFactory()

    local props = LrBinding.makePropertyTable(context)
    props.remoteUrl = 'http://www.flickr.com/photos/mikeboers/sets/72157635207321829/'

    -- Create the contents for the dialog.
    local c = ui:column {

	    bind_to_object = props,
		spacing = ui:dialog_spacing(),

	    ui:edit_field {
		    value = LrView.bind('remoteUrl'),
		    width = 600,
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

