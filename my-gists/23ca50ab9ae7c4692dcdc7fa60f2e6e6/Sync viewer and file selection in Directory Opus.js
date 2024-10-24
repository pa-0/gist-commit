// Viewer Select
// (c) 2016-2017 Leo Davidson

// This is a script for Directory Opus.
// See https://www.gpsoft.com.au/DScripts/redirect.asp?page=scripts for development information.
// See https://resource.dopus.com/viewtopic.php?f=35&t=27361 for information about this specific script.

// Called by Directory Opus to initialize the script
function OnInit(initData)
{
	initData.name = "Viewer Select";
	initData.version = "1.3";
	initData.copyright = "(c) 2016-2017 Leo Davidson";
	initData.url = "https://resource.dopus.com/viewtopic.php?f=35&t=27361";
	initData.desc = "The file display selection will track the standalone viewer's current file.";
	initData.default_enable = true;
	initData.min_version = "12.2";

	initData.vars.Set("VMapPaths", DOpus.Create.Map());
	initData.vars("VMapPaths").persist = false;
}

// Called when an event takes place in the standalone viewer
function OnViewerEvent(viewerEventData)
{
	var viewer   = viewerEventData.viewer;
	var tab      = viewer.parenttab;
	var mapPaths = Script.vars("VMapPaths").value;

	if (viewerEventData.event == "load")
	{
		if (!mapPaths.exists(viewer))
		{
            // For the first file, verify the tab contains the file we open with.
            // If it doesn't, the viewer may have been launched from outside of Opus,
            // or via a command which explicitly displays a file from a path which isn't
            // visible in the folder tab. Those situations still associate the viewer with
            // a lister/tab if one exists, and we want to leave those tabs alone.

            if (TabContainsFile(tab, viewer.current))
            {
                mapPaths(viewer) = tab.path + ""; // Store string, not Path object.
            }
            else
            {
                mapPaths(viewer) = ""; // Make a note to ignore this viewer.
            }
        }


        var path = mapPaths(viewer);
        var file = viewerEventData.item;

        // Still in the starting folder?
        if (typeof tab  != "undefined"
        	&&  typeof path != "undefined"
        	&&  typeof file != "undefined"
        	&&  path != ""
        	&&  tab.path == path)
        {

        	var cmd = DOpus.Create.Command();
        	cmd.SetSourceTab(tab);

        	cmd.AddFile(file);
        	cmd.RunCommand("Select FROMSCRIPT SETFOCUS DESELECTNOMATCH");
        }

        return;
    }

    if (viewerEventData.event == "destroy")
    {
    	mapPaths.erase(viewer);
    	return;
    }
}

function TabContainsFile(tab, item)
{
    // Workaround to avoid error if no valid file is passed.

    if (typeof tab  == "undefined"
    	||  typeof item == "undefined")
    {
    	return false;
    }

    // Simple test is usually enough. Is the tab showing the folder the file is in?
    // (It's possible the file is hidden, but that would be weird in this context, so we ignore that.)

    if (DOpus.FSUtil.ComparePath(DOpus.FSUtil.Resolve(tab.path), item.path))
    {
    	return true;
    }

    // To work in collections, libraries and flat view, we need to go through the actual list of files.
    // This could be slow as we don't currently have a quicker way than looping through the files.

    var itemPathString = item + "";

    // It'll usually be a selected file if the viewer opened via double-click. Try them first.

    for (var eItems = new Enumerator(tab.selected_files); !eItems.atEnd(); eItems.moveNext())
    {
        // Compare the path strings, not the item objects.
        if ((eItems.item() + "") == itemPathString)
        {
        	return true;
        }
    }

    for (var eItems = new Enumerator(tab.files); !eItems.atEnd(); eItems.moveNext())
    {
        // Compare the path strings, not the item objects.
        // Skip selected files as we already checked them.
        if (!eItems.item().selected && (eItems.item() + "") == itemPathString)
        {
        	return true;
        }
    }

    return false;
}