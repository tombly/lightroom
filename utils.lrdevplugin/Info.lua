--[[----------------------------------------------------------------------------

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in.

	LrToolkitIdentifier = 'net.nosleep.lightroom',

	LrPluginName = "Simple Utils",
	
	-- Add the menu items to the Library menu.
	
	LrLibraryMenuItems = {
	    {
		    title = "Update Titles",
		    file = "UpdateTitles.lua",
		},
		{
		    title = "Photo Info",
		    file = "PhotoInfo.lua",
		},
	},
	VERSION = { major=1, minor=0, revision=0, build=1 },
}
