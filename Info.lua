return {
    
    LrSdkVersion = 5.0,
    LrSdkMinimumVersion = 5.0,

    LrToolkitIdentifier = 'com.mikeboers.lightroom.publishlinker',

    LrPluginName = 'Publish Linker',
    
    LrLibraryMenuItems = {

        {
            title = "Add Remote Collection",
            file  = "AddRemoteCollection.lua",
        },
        {
            title = "Link Remote Photo",
            file  = "LinkRemotePhoto.lua",
        }

    },

    VERSION = {
        major = 0,
        minor = 0,
        revision = 1,
        -- build = 1,
    },

}
