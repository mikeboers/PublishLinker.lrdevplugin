
- More tools for unlinking photos and collections, since it is dangerous to
  let Lightroom manage this.

  - Delete local collection
  - Unlink photo

- ok, res = flickr_call(method, data) -> really basic flickr api call

- xml_to_table(xml) converts the LrXml object into a table.
    - attributes are stored under `@name`
    - child nodes are stored under a table of that name
    - e.g., accessing photos from a photoset:
        res.photoset[1].photo[1]['@id']

- Photo discovery should pull in names and captions as well.
- Photo discovery could ask for our approval of every photo.
    - Can use ui:catalog_photo to show the one in the catalog
    - Can use ui:picture to show to flickr version?
        - Get the `url_s` extra from flickr.photoset.getList
        - Download it to a directory within the plugin, or a temp directory.
            - Find a temp folder by looking for the ones that we know about with
              LrFileUtils.exists, and fall back to "tmp" within the plugin
        - Display it along with the potential match.

    - Mark them as potential duplicates.