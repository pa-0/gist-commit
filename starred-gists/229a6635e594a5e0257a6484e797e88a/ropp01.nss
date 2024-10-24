// Ropp's main config
// https://nilesoft.org/docs/functions/id
// Cheatsheet:
	// Types: file|dir|drive|usb|dvd|fixed|vhd|removable|remote|back|desktop|namespace|computer|recyclebin|taskbar	
		// remove... mod etc
			// multiple 			remove (find="view|sort|paste")
			// all not equal to 	remove(where=this.name!="shit")
			// type is file only	remove (type="file" find="run as admin")
			// modify( find = value [property = value [...] ])
		//
	// Validation Properties - Mode, Type, Where
// 

// Remove stuff
	// Win11 items
	remove(find="New|Always keep on this device|Free up space|Copy Link|Manage access|View online|Version history") 
	remove(find="Copy To folder|Move To Folder|Cut|Copy|Delete|Rename|Paste|Refresh") 
	remove(type="file" find="Add to Favorites|Troubleshoot compatibility") 

	// Software related items
	remove(find="Edit with Notepad++|Open with Visual Studio|Browse in Adobe Bridge 2024") 
	remove(find="Play with VLC media player|Add to VLC media player's playlist|Open with AddOn Studio for WoW") 

	// Cloud items
	remove(find='OneDrive|Sync or Backup') 

	// Remove the "Open" "Play" and "Edit" entry without losing stuff like open file location, open with etc. 
	remove(where=this.id==id.open image=image.default)
	remove(where=this.id==id.play image=image.default)
	remove(where=this.id==id.Edit image=image.default)

// Add stuff
	// Items
	item(title='VS-Code edit' type='file' image=[\uE272, #22A7F2] cmd='code' arg=@sel.file.name pos=1 sep=bottom)

	// Custom menu - show with modifier
	menu(mode="multiple" title='Ropp' vis=key.shift() or key.control() sep=sep.bottom image=\uE1DA)
	{
		menu(mode="single" title='editors' image=\uE17A)
		{
			item(type='file|dir|back' title='VS Code' image=[\uE272, #22A7F2] cmd='code' args='"@sel.path"' position=1 )	
			item(type='file|dir|back' title='Notepad++' image cmd='C:\Program Files\Notepad++\notepad++.exe' arg=@sel.file.name position=2 )
			item(type='file|dir|back' title='Sublime Text' image cmd='D:\Progam Portable\sublime_text_build_4152_x64\sublime_text.exe' args='"@sel.path"' position=3 )
		}

		menu(mode="single" title='Usual Suspects' image=\uE143)
		{		
			item(title='WowUp-CF' image cmd='C:\Users\robin\AppData\Local\Programs\wowup-cf\WowUp-CF.exe' args='"@sel.path"' pos=1)
			item(title='TSM' image cmd='C:\Program Files (x86)\TradeSkillMaster Application\app\TSMApplication.exe' args='"@sel.path"' pos=2)		
			item(title='WA Compantion' image cmd='C:\Users\robin\AppData\Local\Programs\weakauras-companion\WeakAuras Companion.exe' args='"@sel.path"' pos=3)	
			item(title='Wowsims-WOTLK' image cmd='O:\WoW-shit\WoW-Sims\wowsimwotlk-windows.exe' args='"@sel.path"' pos=4)
			item(title='Battlenet' image cmd='C:\Program Files (x86)\Battle.net\Battle.net Launcher.exe' args='"@sel.path"' pos=5 sep=top)
		}
	}

	// New+ - Menu | from file-manage
	menu(mode="single" type='back' title='New+' pos="8" image=[\uE17A, #22A7F2] sep=after)
	{
		item(title='Folder(ymdHM)' cmd=io.dir.create(sys.datetime("ymd_HM")) image=icon.new_folder)
		separator
		$dt = sys.datetime("ymd_HM")
		item(title='.txt' cmd=io.file.create('@(dt).txt', 'qwerty') image=icon.new_file)
		item(title='.xml' cmd=io.file.create('@(dt).xml', '<root>qwerty</root>') image=icon.new_file)
		item(title='.json' cmd=io.file.create('@(dt).json', '[]') image=icon.new_file)
	}

	// Custom Display-menu | use to move existing items
	menu(mode="single" type='back' title='Display' pos="9" image=[\uE203, #338822] sep=before)
	{
	}
	// Exit/Restart Explorer	
	item(title=title.exit_explorer cmd=command.restart_explorer vis=key.control() and key.shift() pos="10" sep=before image=#BB2233)

// Moving and modifying stuff
	// Organizing
	modify(where=this.name=='scan with microsoft defender' menu="more options")
	modify(find='using this file' menu='more options') 
	modify(find='7-Zip' type='drive' vis='hidden') // Removing 7z from drives
	modify(where=this.name=='properties' pos="10" sep=before )

	// Moving to Display menu
	modify(find='Personalize' menu="Display" pos="1")
	modify(where=this.name=='display settings' menu="Display" pos="2" )
	modify(find='NVIDIA' menu="Display" pos="3" sep=before)