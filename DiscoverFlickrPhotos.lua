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
LrFunctionContext.callWithContext('PublishLinker.AddRemoteCollection', function(context)

    local catalog = LrApplication.activeCatalog()

    local sources = {}
    local publishedCollections = {}

    local i
    local source

    log:info('splitting sources')

    for i, source in ipairs(catalog:getActiveSources()) do
        if source:type() == 'LrPublishedCollection' then
            append(publishedCollections, source)
        else
            append(sources, source)
        end
    end

    log:info('check selections')

    if #publishedCollections == 0 then
        error("Please select a published collecton.")
    elseif #sources == 0 then
        error("Please select a photo source.")
    end

    log:info('everything is selected')

    -- Collect all the remote photos.

    local date_taken_to_remote = {}
    for _, published_collection in ipairs(publishedCollections) do

        local url = 'http://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&api_key=46912733cea0913d152057b8d6a8da81&extras=date_taken&per_page=500&format=rest&photoset_id=' .. published_collection:getRemoteId()
        log:info(url)
        local body, headers = LrHttp.get(url)
        local root = LrXml.parseXml(body)
        if root:attributes().stat.value ~= 'ok' then
            log:info(body)
            error('Flickr response was not OK')
        end

        local photoset = root:childAtIndex(1)
        for i = 1, photoset:childCount() do
            local photo = photoset:childAtIndex(i)
            photo.owner = photoset:attributes().owner.value
            local photo_id = photo:attributes().id.value
            local raw_date_taken = photo:attributes().datetaken.value
            -- "2013-01-03 12:50:18"
            local date_taken = LrDate.timeFromComponents(
                string.match(raw_date_taken, '^(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)$')
            )
            log:info(i, raw_date_taken, date_taken, 'to', photo_id)
            date_taken_to_remote[date_taken] = {published_collection, photo}
        end

    end

    -- Look for photos in our sources that match.
    for _, source in ipairs(sources) do
        for _, photo in ipairs(source:getPhotos()) do
            local date_taken = photo:getRawMetadata('dateTimeOriginal')
            local remote_link = date_taken_to_remote[date_taken]
            if remote_link then
                local published_collection = remote_link[1]
                local photo_node = remote_link[2]
                local remote_id = photo_node:attributes().id.value
                log:info('Link', photo.localIdentifier, 'to', remote_id)

                catalog:withWriteAccessDo('PublishLinker.DiscoverFlickrPhotos.Link', function()
                    published_collection:addPhotoByRemoteId(
                        photo,
                        remote_id,
                        'https://secure.flickr.com/photos/' .. photo_node.owner .. '/' .. remote_id,
                        true
                    )
                end)

            end
        end
    end



end)
end)

