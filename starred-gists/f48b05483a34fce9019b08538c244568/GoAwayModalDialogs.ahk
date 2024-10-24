; ==========================================================================================
; == Modal Dialog Automation
; ==
; == Automates away pesky modal dialogs by applying a default response when they pop up
; == Helper functions are at the bottom
; ==========================================================================================

; Defaults to fast no-regex title matching 
SetTitleMatchMode, 2

; Keep this script live
#Persistent
  SetTimer, AutomateDialogs, 350
return


; ------------------------------------------------------------------------
; -- A few handy global hotkeys
; -- Shift+Ctrl+Win+E     Edit this script
; -- Shift+Ctrl+Win+R     Reload this script
; -- Shift+Ctrl+Win+T     AutoHotkey help file
; -- Shift+Ctrl+Win+Y     Window Spy utility
; ------------------------------------------------------------------------

; #=Win ^=Ctrl +=Shift !=Alt

; Edit the master AutoHotkey file, used to be just "Edit"
; #^+e:: Run %edit% \\noahc-sys\c$\noah\data\settings\AutoHotkey.ahk
#^+e:: Edit

; Open the AutoHotkey help file for reference
#^+t:: Run "%ProgramFiles%\AutoHotkey\AutoHotkey.chm"

; Open the AutoHotkey spy utility
#^+y:: Run "%ProgramFiles%\AutoHotkey\AU3_Spy.exe"

; Reload this AutoHotkey script
#^+r::
  SoundPlay *64
  Reload
  Sleep 1000
  MsgBox 4, , Script reloaded unsuccessful, open it for editing?
  IfMsgBox Yes, Edit
return



; ------------------------------------------------------------------------
; -- Specific dialogs
; ------------------------------------------------------------------------

AutomateDialogs:

; ===[ Misc Apps ]===

  ; Sublime Text 2, unable to read project
  SendIfWinActive("Sublime Text 2 ahk_class #32770", "Unable to read project ", "{esc}")  
  
  ; Sublime Text 2, unable to write workspace
  SendIfWinActive("Sublime Text 2 ahk_class #32770", "Unable to write workspace ", "{esc}")  
  
  ; Sublime Text 2, register me
  SendIfWinActive("This is an unregistered copy ahk_class #32770", "Hello! Thanks for trying out Sublime Text.", "{esc}")  

  ; Spotify, send crash report
  SendIfWinActive("Spotify ahk_class #32770", "Send crash report?", "{enter}")  

  ; Picasa, remove a folder
  SendIfWinActive("Login ahk_class SunAwtFrame", "Password", "noahcoad{tab}blackscreen{enter}")  

  ; Picasa, remove a folder
  SendIfWinActive("Confirm ahk_class #32770", "Do you want to remove the folder", "{enter}")
  
  ; Picasa, remove a folder
  SendIfWinActive("Confirm ahk_class #32770", "Do you want to remove the folder", "{enter}")

  ; SlickRun, confirm to delete a MagicWord
  SendIfWinActiveEx("Confirm ahk_class #32770", "Yes", "!y", false, 366, 129)

  ; VirtualBox, restore snapshot
  SendIfWinActiveEx("VirtualBox - Question ahk_class QWidget", "", "{enter}", false, 227, 179)

	; Adobe Acrobat Reader, Enter password to open document, NOAH SPECIFIC
  ; SendIfWinActive(Password ahk_class #32770, "is protected. Please enter a Document Open Password.", "coad5143{enter}")	

	; Windows, Server Manager, Connect to Another Computer
  ; SendIfWinActive("Connect to Another Computer ahk_class WindowsForms10.Window.8.app.0.21d1674", "Select the computer on which you want to view Server Manager.", "firefly{enter}")	

	; Windows, Computer Management Console, Connect to Another Computer
  ; SendIfWinActive("Select Computer ahk_class #32770", "Select the computer you want this snap-in to manage.", "firefly{enter}")	

	; SysInternals Tools License Agreement
  SendIfWinActive("A License Agreement ahk_class #32770", "&Agree", "!a")	

	; VLC Media Player, crash
  SendIfWinActive("VLC crash reporting ahk_class #32770", "VLC media player just crashed. Do you want to send a bug report to the developers team?", "!y")	

	; Carbonite Backup, folder may contain non-backup files
  SendIfWinActive("Carbonite ahk_class #32770", "The drive or folder you've selected for backup may contain some files and folders that won't be backed up automatically", "{space}")	

	; Dell QuickSet, 65W AC Power Supply
  SendIfWinActive("QuickSet ahk_class #32770", "65W AC Power Adapter has been determined. Your system will operate slower and the battery", "{esc}")	

  ; Adobe Reader, allow opening of links
  SendIfWinActive("Security Warning ahk_class #32770", "If you trust the site, choose Allow. If you do not trust the site, choose Block.", "!m!a")

  ; GoToMeeting, leave meeting
  SendIfWinActive("Leave? - GoToMeeting ahk_class #32770", "Are you sure you want to leave GoToMeeting?", "{space}")

  ; GoToMeeting, end meeting for everyone
  SendIfWinActive("End meeting for everyone? ahk_class #32770", "Are you sure you want to end the meeting for everyone?", "{space}")

  ; GoToMeeting, meeeting scheduled and mail opened in Outlook
  SendIfWinActive("Meeting Scheduled - GoToMeeting ahk_class #32770", "A meeting has been scheduled in your Outlook Calendar. Enter the email addresses of those you want to attend and click Send.", "{space}")

  ; Quicken, update summary
  SendIfWinActive("One Step Update Summary ahk_class QWinPopup", "Show this dialog only if there is an error", "!c")

  ; Quicken, save edited transaction
  SendIfWinActive("Quicken 2010 ahk_class #32770", "You have changed the last transaction you were viewing.", "!y")

  ; Quicken, delete an item
  SendIfWinActive("Quicken 2010 ahk_class #32770", "Ok to Delete", "{space}")
  
  ; Quicken, update data from bank account
  SendIfWinActive("One Step Update ahk_class #32770", "One Step Update Settings", "!u")  
  
  ; Quicken, update data from bank account
  SendIfWinActive("Vault Password ahk_class #32770", "&Vault Password:", "wetduck{enter}")  

  ; AutoHotkey, don't edit the master script if it fails to load
  SendIfWinActive("NoahMain.ahk ahk_class #32770", "Script reloaded unsuccessful, open it for editing?", "!n")

  ; Notepad2.exe, notification that settings are saved
  SendIfWinActive("Notepad2 ahk_class #32770", "The current program settings have been saved.", "{space}")
  
  ; Sony Motion Picture Browser (Sony HDD HD Camcorder), Delete Selected Files
  SendIfWinActive("Picture Motion Browser ahk_class #32770", "Are you sure you want to send", "!y")
    
  ; Sony Motion Picture Browser (Sony HDD HD Camcorder), Delete Selected Files #2
  SendIfWinActive("Picture Motion Browser ahk_class #32770", "Do you want to send the related files to the Recycle Bin?", "!a")
    
  ; VSO Image Resizer, Continue Free Use
  ; SendIfWinActive("VSO Image Resizer ahk_class TfrmTrial", "Unlock", "{space}")
  
  ; 7zip (7-zip 7z), add file to archive
  SendIfWinActive("Confirm File Copy ahk_class #32770", "Are you sure you want to copy files to archive", "!y")
  
  ; 7zip (7-zip 7z), update file in archive
  SendIfWinActive("7-Zip ahk_class #32770", "Do you want to update it in the archive?", "{space}")

  ; SnagIt, overwrite existing file when saving
  SendIfWinActive("SnagIt ahk_class #32770", "Do you want to replace it?", "y")

  ; Swift To-Do List, delete a task
  SendIfWinActive("Swift To-Do List ahk_class #32770", "Do you really want to delete this task?", "y")
  
  ; Image Uploader, notice of successful upload 
  SendIfWinActive("Image Uploader ahk_class #32770", "Upload Successful!", "{space}")
  
  ; WinZip, minimize for install
  ; SendIfWinActive("Install ahk_class #32770", "WinZip will extract all files to a temporary folder and run the ", "{enter}")

  ; WinZip, confirm running file
  SendIfWinActive("WinZip - Security Warning ahk_class #32770", "Do you want to run this file?", "!r")

  ; WinZip, confirm opening file
  SendIfWinActive("WinZip - Security Warning ahk_class #32770", "Do you want to open this file?", "!o")

  ; WinZip, cant confirm publisher
  SendIfWinActive("WinZip - Security Warning ahk_class #32770", "The publisher could not be verified.  Are you sure you want to run this software?", "!r")

  ; WinZip, internet security notice
  SendIfWinActive("WinZip ahk_class #32770", "While files from the Internet can be useful", "!w!o")
    
  ; WinZip, minimize during install
  SendIfWinActive("Install ahk_class #32770", "WinZip will extract all files to a temporary folder and run the Setup.exe program", "{enter}")
    
  ; VSO Image Resizer, completed resizing images
  ; %noah%\Media\Images\Other\Automated Dialogs\VSO Image Resizer, completed resizing images.png
  SendIfWinActive("Processing Images - 100 ahk_class TfrmProgress", "Close", "{enter}")
  
  ; iTunes, delete app
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "Only files in the Mobile Applications folder will be moved to the Recycle Bin.", "!m")
  
  ; iTunes, age restricted material
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "One or more of these items contains age-restricted material.", "!o")
  
  ; iTunes, ignore sync alert
  SendIfWinActiveEx("Sync Alert ahk_class #32770", "Syncing with .* will change more than \d{1,2}% of your Notes on this computer.", "{space}", true, 0, 0)
  
  ; iTunes, remove selected tracks from library
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "Are you sure you want to remove the selected songs from your iTunes library?", "!r")
  
  ; iTunes, Edit multiple items
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "Are you sure you want to edit information for multiple items?", "!d!y")
    
  ; iTunes, change artwork on multiple items
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "Are you sure you want to change the artwork for multiple items?", "!y")
    
  ; iTunes, Remove items from playlist
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "Are you sure you want to remove the selected songs from the list?", "!d!r")
    
  ; iTunes, Sync more than 5% of contacts etc
  ; SendIfWinActive("Sync Alert ahk_class #32770", "will change more than 5% of your", "{space}")
    
  ; iTunes
  SendIfWinActive("iTunes Setup Assistant ahk_class iTunesCustomModalDialog, iTunes cannot locate the CD Configuration folder", "so you cannot import or burn CDs and DVDs.  This folder must be in the same directory as iTunes.", "{space}")
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "iTunes has stopped updating this podcast because you have not listened to any episodes recently. Would you like to resume updating this podcast?", "!y")
  SendIfWinActive("iTunes ahk_class iTunesCustomModalDialog", "Are you sure you want to remove the selected movie", "!d!r")
  IfWinActive iTunes ahk_class iTunesCustomModalDialog, There are duplicates being added to the playlist. Would you like to add the duplicates or skip them?
  {
    Send !s
    sleep 1000
  }

  ; FileZilla, Break Connection
  SendIfWinActive("FileZilla ahk_class #32770", "Break current connection?", "!y")

  ; FileZilla, Confirm Delete
  SendIfWinActive("Confirmation needed ahk_class #32770", "Really delete all selected files and/or directories?", "!y")
  
  ; MS Corporate ETrust Notice
  SendIfWinActive("Logon Script Anti-virus Security Module ahk_class #32770", "All attempts to update the necessary ETrust services", "!o")
    
  ; RoboForm, confirm overriding passcard
  SendIfWinActive("RoboForm Warning ahk_class #32770", "already exists. This will overwrite it", "{space}")
  
  ; DVD Decrypter, On-the-fly patching
  SendIfWinActive("DVD Decrypter ahk_class #32770", "On-the-fly IFO/BUP file patching failed", "{space}")
  
  ; Camtasia Studio, Delete Video Capture
  SendIfWinActive("Camtasia Recorder ahk_class #32770", "Are you sure you want to delete the current video capture?", "{space}")
    
  ; Camtasia Studio, Delete Video Capture #2
  SendIfWinActive("Camtasia Recorder ahk_class #32770", "Are you sure you want to discard the current video capture?", "!y")
    
  ; Camtasia Recorder, Delete Video Capture #3
  SendIfWinActiveEx("Camtasia Recorder ahk_class QWidget", "", "!y", false, 325, 122)
    
  ; ExpressSCH, part added to favorites
  SendIfWinActive("ExpressSCH ahk_class #32770", "has been added to your favorites list.", "{space}")

  ; Hyper-V Manager, error shutting down
  SendIfWinActiveEx("Hyper-V Manager ahk_class #32770", "Close", "!c", false, 366, 191)

  ; Hyper-V Manager, error starting PC
  SendIfWinActiveEx("Hyper-V Manager ahk_class #32770", "Close", "{esc}", false, 399, 231)
  
  ; TweakVI, freeware notice
  IfWinActive TweakVI Freeware Edition ahk_class ThunderRT6FormDC, Start the freeware version...
    MouseClick, left,  519,  298

	; CopyTo, overrite project file
  SendIfWinActive("ahk_class #32770", "The file already exists. Are you sure you want to overwrite ?", "!y")
	

; ===[ Visual Studio ]===

  ; Visual Studio, can't connect to TFS
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "A connection could not be made to the following server:", "{esc}")

  ; Visual Studio, stop debugging
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "Do you want to stop debugging?", "!y")

	; Visual Studio, web publish will overright files
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "Existing files in the destination location will be deleted.", "!y")
	
	; Visual Studio, Team Explorer connection lost
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "Unable to read data from the transport connection", "{escape}")

  ; Visual Studio, Dismiss the Team Explorer Can't Connect dialog
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "TF30331: Team Explorer could not connect to the Team Foundation server", "{space}")

  ; Visual Studio, Connect to a different TFS Server warning
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "Connecting to a new Team Foundation Server will close the current", "{space}")
    
  ; Visual Studio, Dismiss VSTS showing work items from seperate projects
  SendIfWinActive("Microsoft Excel ahk_class #32770", "TF208015: You are trying to add work items that are not in the selected team project for this", "{space}")
    
  ; Visual Studio, TFS Busy Notice
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "Unable to switch servers at this time.  The Team Explorer is busy.", "{space}")

  ; Visual Studio 2010, TFS, Revert Work Item Changes, http://screencast.com/t/Tg3jEJd9hf59
  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "Are you sure you want to revert your changes to the work item?", "!y")

  SendIfWinActive("Microsoft Visual Studio ahk_class #32770", "will be removed from the Toolbox.", "{space}")
    

; ===[ Windows XP (WinXP) ]===

  ; IE, Open a file copied over the network
  SendIfWinActive("Internet Explorer ahk_class #32770", "This page has an unspecified potential security risk. Would you like to continue?", "!y")

  ; Registry Editor, okay to add reg settings?
  SendIfWinActive("Registry Editor ahk_class #32770", "Are you sure you want to add the information in", "!y")

  ; Registry Editor, reg settings applied
  SendIfWinActive("Registry Editor ahk_class #32770", "has been successfully entered into the registry.", "{enter}")

  ; Windows XP, file is too big for recycle bin
  SendIfWinActive("Confirm Folder Delete ahk_class #32770", "Do you want to permanently delete it?", "!a")
  
  ; msconfig, notice changes have been applied
  SendIfWinActive("System Configuration Utility ahk_class #32770", "You have used the System Configuration Utility to make changes to the way Windows starts.", "{space}{enter}")



; ===[ Windows 7 (Win7) ]===

  ; Windows Activation Failed
  SendIfWinActive("Windows Activation ahk_class #32770", "Key management services (KMS) host could not be located in domain name system (DNS), please have your system administrator verify that a KMS is published correctly in DNS.", "{esc}")

  ; Explorer, perminantyl delete a folder
  ; SendIfWinActive("Confirm Folder Delete ahk_class #32770", "&Yes", "!y")

  ; Windows Update, accept license to install update
  SendIfWinActive("Download and Install Updates ahk_class #32770", "You need to accept the license terms before installing updates.", "!a")

  ; Windows Update, install standalone update
  SendIfWinActive("Windows Update Standalone Installer ahk_class #32770", "Do you want to install the following Windows software update?", "!y")

  ; Desktop Gadgets, add a new gadget
  SendIfWinActive("Desktop Gadgets - Security Warning ahk_class #32770", "The publisher could not be verified. Are you sure you want to install this gadget?", "!i")

  ; Desktop Gadgets, add a new gadget
  SendIfWinActive("Desktop Gadgets - Security Warning ahk_class #32770", "Do you want to install this gadget?", "!i")

  ; msconfig, reboot needed to apply changes
  SendIfWinActive("System Configuration ahk_class #32770", "You may need to restart your computer to apply these changes. Before restarting, save any open files and close all programs.", "!d!x")

  ; Task Manager, End Process now
  SendIfWinActiveEx("Windows Task Manager ahk_class #32770", "End process", "{space}", false, 366, 200)

  ; Open Folder, not accessible
  SendIfWinActiveEx("Open Folder ahk_class #32770", "OK", "{escape}", false, 572, 184)

  ; Network Error, can't access share
  SendIfWinActiveEx("Network Error ahk_class #32770", "Diagnose", "{esc}", false, 534, 170)
  
  ; Virtual Machine, lost connection
  SendIfWinActiveEx("Virtual Machine Connection ahk_class #32770", "Reconnect", "!e", false, 366, 235)

  ; Virtual Machine, lost connection
  SendIfWinActiveEx("Virtual Machine Connection ahk_class #32770", "Reconnect", "!e", flase, 366, 277)

  ; Remote Desktop, can't connect
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "This computer can't connect to the remote computer.", "{escape}")

  ; Remote Desktop, session ended, due to getting booted out
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "Your network administrator might have ended the connection. Try connecting again, or contact technical support for assistance.", "{escape}")

  ; Remote Desktop, session ended, another user connected
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "Another user connected to the remote computer, so your connection was lost. Try connecting again, or contact your network administrator or technical support group.", "{escape}")

  ; Remote Desktop, can't connect due to timeout
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "The two computers couldn't connect in the amount of time allotted. Try connecting again. If the problem continues, contact your network administrator or technical support.", "{escape}")

  ; Remote Desktop, can't connect
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "Remote Desktop can’t connect to the remote computer for one of these reasons:", "{escape}")

  ; Remote Desktop, certificate not verified
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "The remote computer could not be authenticated due to problems with its security certificate. It may be unsafe to proceed.", "!d!y")

  ; Remote Desktop, system identity could not be determained
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "This remote connection could harm your local or remote computer. Do not connect unless you know where this connection came from or have used it before.", "!o!n")

  ; Remote Desktop, system identity could not be determained #2
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "This problem can occur if the remote computer is running a version of Windows that is earlier than Windows Vista, or if the remote computer is not configured to support server authentication.", "!d!y")

  ; Remote Desktop, disconnect now
  ; C:\Noah\Media\Images\random\Automated Dialogs\Remote_Desktop,_closing_not_logging_off.png
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "This will disconnect your Remote Desktop Services session. Your programs will continue to run while you are disconnected. You can reconnect to this session later by logging on again.", "{enter}")

  ; Remote Desktop, connection could harm your computer
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "This remote connection could harm your local or remote computer. Make sure that you trust the remote computer before you connect.", "!o!n")



; ===[ Windows Vista - Apps+OS ]===



  ; Explorer, copy file without special properties
  SendIfWinActive("Property Loss ahk_class #32770", "has properties that can't be copied to the new location.", "!a!y")
  
  ; App Not Responding
  ; %noah%\Media\Images\Other\Automated Dialogs\Microsoft Windows, App Not Responding.png
  SendIfWinActive("Microsoft Windows ahk_class #32770", "Check for a solution and restart the program", "{escape}")

  ; App Stopped Working
  SendIfWinActive("Microsoft Windows ahk_class #32770", "Close Program", "!c")

  ; Security Center, Server authentication has a certificate
  ; %noah%\Media\Images\Other\Automated Dialogs\Security Alert, Server Authentication.png
  SendIfWinActive("Security Alert ahk_class #32770", "This page requires a secure connection which includes server authentication.", "!y")

  ; Security Alert, Site w/ certificate
  ; %noah%\Media\Images\Other\Automated Dialogs\Security Alert, Secure Connection.png
  SendIfWinActive("Security Alert ahk_class #32770", "A secure connection with this site cannot be verified. Would you still like to proceed?", "!y")
  
  SendIfWinActive("Windows Media Player - Device Setup ahk_class #32770", "What do you want to do with this device?", "{escape}")
  SendIfWinActive("Windows Task Manager ahk_class #32770", "Change priority", "{space}")
  SendIfWinActive("Disconnect Windows session ahk_class #32770", "This will disconnect your Windows session. Your programs will continue to run while you are disconnected.", "{space}")

  ; Remote Desktop
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "Don't show this warning again for connections to this remote computer", "!d!y")
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "This remote connection could harm your computer. Do not connect unless you know where this connection came from or have used it before.", "!o!n")
  SendIfWinActive("Remote Desktop Connection ahk_class #32770", "verify that you trust the computer to have access to your credentials and connected devices", "!o!y")
  ;IfWinActive Remote Desktop Disconnected ahk_class #32770, OK
  ;  Send {escape}
    
  ; Sign out of a Remote Desktop Terminal Services Session
  SendIfWinActive("Disconnect Terminal Services Session ahk_class #32770", "This will disconnect your Terminal Services session. Your programs will continue to run while you are disconnected. You can reconnect to this session later", "{space}")

  ; Confirm overwriting a file when doing a 'save as'
  SendIfWinActive("Confirm Save As ahk_class #32770", "Yes", "!y")

  ; Turn sticky keys on?
  SendIfWinActive("Filter Keys ahk_class NativeHWNDHost", "Yes", "{escape}")

  ; Watson, Cancel app crash dialogs
  SendIfWinActive("Microsoft Windows ahk_class #32770", "Check online for a solution and restart the program", "{escape}")

  ; Watson, Cancel app crash dialogs #2
  SendIfWinActive("Microsoft Windows ahk_class #32770", "Check online for a solution and close the program", "{escape}")

  ; Watson, Send app crash info
  SendIfWinActive("ahk_class #32770", "&Send information", "!s")

  ; Watson, Send app crash info, more information
  SendIfWinActive("ahk_class #32770", "send more information automatically (recommended)", "{space}")
  

; ===[ Microsoft Office ]===

  ; OneNote, open 'unsafe' location
  SendIfWinActive("Microsoft OneNote Security Notice ahk_class NUIDialog", "", "!y")
    
  ; OneNote, confirm delete section
  SendIfWinActive("Microsoft Office OneNote ahk_class #32770", "Are you sure you want to delete the following section", "!y")
    
  ; Outlook 2010, confirm delete toolbar
  SendIfWinActive("Microsoft Outlook ahk_class #32770", "You placed a large amount of data on the Clipboard. Do you want these data to be available to Microsoft Outlook or other programs after you close this window?", "{esc}")

	; Outlook 2010, dismiss reminders
	; SendIfWinActive("ahk_class #32770", "Click Snooze to be reminded again in:", "{down}!a")
    
  ; Outlook, confirm delete toolbar
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770", "Are you sure you want to delete the", "{space}")
    
  ; Outlook, send invite without location
  SendIfWinActive("Microsoft Outlook ahk_class #32770", "&Send Anyway", "!s")
    
  ; Outlook, marks as not junk
  SendIfWinActive("Mark as Not Junk ahk_class #32770", "This message will be moved back into the Inbox Folder.", "{enter}")
    
  ; Outlook, open attachment
  SendIfWinActive("Microsoft Outlook ahk_class #32770", "is open or in use by another application. If you continue, your changes to the attachment will be lost. Do you want to continue?", "!y")
    
  ; Outlook, lost changes to open attachment
  SendIfWinActive("Microsoft Outlook ahk_class #32770", "Changes to this file will be lost unless you save your changes to another file by clicking the File Tab in the other program, and then clicking Save As.", "{esc}")
    
  ; Outlook, save changes
  SendIfWinActive("Microsoft Outlook ahk_class #32770", "Do you want to save changes?", "!y")
    
  ; Word, Send Proofing Help
  SendIfWinActive("Help improve proofing tools ahk_class bosa_sdm_msword", "", "!s")
    
  ; Word 2010, Large clipboard
  SendIfWinActive("Microsoft Word ahk_class #32770", "You placed a large amount of content on the Clipboard.  Do you want this content to be available to other applications after you quit Word?", "!y")
    
  ; Excel 2010, Large clipboard
  SendIfWinActive("Microsoft Excel ahk_class #32770", "There is a large amount of information on the Clipboard. Do you want to be able to paste this information into another program later?", "!y")
    
  ; Excel 2010, Can't empty clipboard
  SendIfWinActive("Microsoft Excel ahk_class #32770", "The Clipboard cannot be emptied. Another program might be using the Clipboard.", "{esc}")

  ; Excel 2007, Can't open clipboard
  SendIfWinActive("Microsoft Office Excel ahk_class #32770", "Cannot open the Clipboard.", "{esc}")

  ; Excel 2007, Large clipboard
  SendIfWinActive("Microsoft Office Excel ahk_class #32770", "There is a large amount of information on the Clipboard. Do you want to be able to paste this information into another", "!y")
    
  ; Excel 2007, Open Link
  SendIfWinActive("Microsoft Office ahk_class #32770", "Some files can contain viruses or otherwise be harmful to your computer.", "{tab}{space}")
    
  ; Outlook, enable access to object model
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770", "A program is trying to access e-mail address information stored in Outlook. If this is unexpected", "{tab}{tab}{space}{tab}{down}{down}{down}{tab}{enter}")
  
  ; Excel 2007, Cannot empty the Clipboard
  SendIfWinActive("Microsoft Office Excel ahk_class #32770", "Cannot empty the Clipboard.", "{space}")

  ; Excel 2007, error in transport layer (OLAP PivotTable)
  SendIfWinActive("Microsoft Office Excel ahk_class #32770", "An error was encountered in the transport layer.", "{esc}")

  ; Excel 2007, Cannot show or hide detail for this selection.
  SendIfWinActive("Microsoft Office Excel ahk_class #32770", "Cannot show or hide detail for this selection.", "{esc}")

  ; InfoPath, Save location reminder
  SendIfWinActive("*- Microsoft Office InfoPath ahk_class #32770", "Your file will be saved to this location", "{space}")
    
  ; Office Communicator 2007, disconnect call
  SendIfWinActive("Microsoft Office Communicator 2007 ahk_class #32770", "If you close this window you will no longer be able to control the call", "!n")
  
  ; Office Communicator 2007, disconnect call #2
  SendIfWinActive("Office Communicator ahk_class #32770", "If you close this window you will no longer be able to control the call.", "!n")

  ; Office Communicator 2007, retrieve outlook data
  SendIfWinActive("Communicator - Services Sign In ahk_class #32770", "Type your credentials to retrieve calendar data from Outlook.", "{escape}")

  ; Windows Communicator, On the Phone
  ; %noah%\Media\Images\Other\Automated Dialogs\MS Office Communicator, Phone Conversation.png
  ; SendIfWinActiveEx("ahk_class IMWindowClass", "", "!{space}n", false, 362, 144)

  ; Excel, useful info dialog
  SendIfWinActiveEx("Customer Feedback ahk_class NUIDialog", "Reconnect", "!n", false, 358, 157)

  ; PowerPoint, Open External Links
  SendIfWinActiveEx("Microsoft Office PowerPoint Security Notice ahk_class NUIDialog", "", "!y", false, 398, 215)

  ; Unclassified Office Dialogs
  SendIfWinActive("Microsoft Office OneNote 2007 ahk_class #32770", "To restore the OneNote icon in the taskbar", "{enter}")
  SendIfWinActive("Opening Mail Attachment ahk_class #32770", "You should only open attachments from a trustworthy source.", "!o")
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770, the connection to the server will be permanently removed. If you reopen the file on your computer", "changes will not be synchronized with the server. Do you want to continue?", "y")
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770", "Do you want to remove the selected", "!y")
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770", "Are you sure you want to permanently delete all the items and subfolders", "!y")
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770", "Are you sure you want to delete the folder", "!y")
  SendIfWinActive("Microsoft Office Outlook ahk_class #32770", "Rss Feed from Outlook?", "!y")
  SendIfWinActive("Help improve proofing tools ahk_class bosa_sdm_Microsoft", "Office Word 12.0", "!s")
  SendIfWinActive("Personal Folders ahk_class #32770", "The file C:\Users\noahc\AppData\Local\Microsoft\Outlook\SharePoint Lists(", "{space}")
  SendIfWinActive("Update Table of Contents ahk_class bosa_sdm_Microsoft", "Office Word 12.0", "!e{enter}")
  SendIfWinActive("Microsoft Office OneNote ahk_class #32770", "notebook in OneNote (recommended) or just open the", "!n")



; ===[ Internet Explorer ]===

  ; === Specific websites === 
  
  ; --- Dev10 Bug TFS Database ---
    
  ; Internet Explorer, Allow ActiveX to Run
  SendIfWinActive("Message from webpage ahk_class #32770", "Are you sure you want to undo all changes and refresh the work item?", "{space}")

  ; Internet Explorer, Notice of sending info others can see on the internet
  SendIfWinActive("Internet Explorer ahk_class #32770", "it might be possible for others to see that information. Do you want to continue?", "!y")

  ; Internet Explorer, page contains mixed secure and non-secure items
  SendIfWinActive("Security Warning ahk_class #32770, This webpage contains content that will not be delivered using a secure HTTPS connection", "which could compromise the security of the entire webpage.", "!y")

  ; Internet Explorer, Allow ActiveX to Run
  SendIfWinActive("Internet Explorer - Security Warning ahk_class #32770", "Do you want to run this ActiveX control?", "!r")

  ; Internet Explorer, Close a page (if asked if you're sure navigating away is okay)
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "Are you sure you want to navigate away from this page?", "{space}")
  
  ; Internet Explorer, Close a tab (if asked if you're sure navigating away is okay)
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "The webpage you are viewing is trying to close the tab.", "{space}")
    
  ; Other web page messages
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "Are you sure you want to delete the selected comment(s)?", "{space}")
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "Are you sure you want to delete the selected items?", "{space}")
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "This message will be permanently deleted", "{space}")
  SendIfWinActive("Windows Internet Explorer ahk_class #32770, Some files can harm your computer. If the file information looks suspicious or you do not fully trust the source", "do not open the file.", "{space}")
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "Are you sure you want to delete this message?", "{space}")
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "Deleting this link also deletes any links that might exist under it. Do you want to delete this link?", "{space}")
  SendIfWinActive("Windows Internet Explorer ahk_class #32770", "The webpage you are viewing is trying to close the window.", "!y")
  SendIfWinActive("https://msmvps.com/ ahk_class Chrome_WindowImpl_0", "Are you sure you want to delete this comment?", "{space}")

  SendIfWinActive("Internet Explorer ahk_class #32770", "This page is accessing information that is not under its control. This poses a security risk. Do you want to continue?", "!y")
  SendIfWinActive("Internet Explorer ahk_class #32770", "Do you want to allow this webpage to access your Clipboard?", "{a}")
  SendIfWinActive("Internet Explorer", "Do you want to move or copy files from this zone?", "Y")
  SendIfWinActive("Security Information ahk_class #32770", "This page contains both secure and nonsecure items.", "!y")
  SendIfWinActive("Security Alert ahk_class #32770", "Information you exchange with this site cannot be viewed or changed by others.", "!y")

  SendIfWinActive("AutoComplete Passwords ahk_class #32770", "Do you want Internet Explorer to remember this password?", "!y")
  SendIfWinActive("Microsoft Office 2003 Web Components ahk_class #32770", "This Website uses a data provider that may be unsafe", "{tab}{space}")

  SendIfWinActive("Internet Explorer - Security Warning", "Do you want to run this software?", "R")
  SendIfWinActive("Internet Explorer - Security Warning ahk_class #32770", "The publisher could not be verified.  Are you sure you want to run this software?", "r")

  ; Open Untrusted File
  SendIfWinActive("Open File - Security Warning", "Do you want to run this file?", "!w!r")

  ; Allow local ActiveX javascript
  SendIfWinActive("Security Warning ahk_class #32770", "However, active content might also harm your computer.", "!y")

  ; Open Untrusted File
  SendIfWinActive("Open File - Security Warning", "The publisher could not be verified.  Are you sure you want to run this software", "!w!r")
    
  ; AutoComplete password changed
  ; %noah%\Media\Images\Other\Automated Dialogs\Internet Explorer, AutoComplete, Changed Password.png
  SendIfWinActive("AutoComplete ahk_class #32770", "The password you entered does not match the password stored in Windows for this user name.", "!y")

  ; Internet Explorer, Always allow popups?
  SendIfWinActive("Allow pop-ups from this site? ahk_class #32770", "Would you like to allow pop-ups from", "!y")

  ; Internet Explorer, Always allow popups?
  SendIfWinActive("Windows Security ahk_class #32770", "How do I know if I can trust this website?", "+{tab}{space}")

  ; Internet Explorer, Allow mixed content secure and not
  SendIfWinActive("Security Warning ahk_class #32770", "This webpage contains content that will not be delivered using a secure HTTPS connection, which could compromise the security of the entire webpage.", "!y")
    
; ===[ Google Chrome ]===    
  ; Google Chrome, Delete a comment from msdn blog
  SendIfWinActiveEx("http://blogs.msdn.com/ ahk_class Chrome_WindowImpl_0", "Reconnect", "{space}", false, 352, 112)

  ; Google Chrome, Launch external protocol app
  SendIfWinActive("External Protocol Request ahk_class Chrome_WindowImpl_0", "Launch Application", "{tab}{space}")
    
  ; Google Chrome, Log into TFS
  ; SendIfWinActive("Untitled - Google Chrome ahk_class Chrome_WidgetWin_0", "Authentication Required", "ichip\ncoad{tab}ZipLine23{enter}")
    
; ===[ Uncatagorized ]===
  SendIfWinActive("Confirmation ahk_class TfrmMsgDlg", "Select the same button at the next file.", "!s!n")
  SendIfWinActive("Export ahk_class #32770", "Do you want to replace it?", "!y")
  SendIfWinActive("Confirm Encryption Loss ahk_class #32770", "Do you want to copy this file without encryption", "!a!y")
  SendIfWinActive("Application Install - Security Warning ahk_class WindowsForms10.Window.8.app.0.21af1a5", "While applications from the Internet can be useful", "!i")
  SendIfWinActive("System Configuration ahk_class #32770", "Don't show this message or start System Configuration when Windows starts", "{tab}{space}{tab}{space}")
  SendIfWinActive("Open File - Security Warning ahk_class #32770", "Do you want to open this file?", "!w!o")

; ===[ Dialogs that require size verification. ]===

  ; Disk Cleanup, asks if you're sure you want to continue with a clean up that is going to delete files
  SendIfWinActiveEx("Disk Cleanup ahk_class #32770", "Delete Files", "{space}", false, 366, 159)
  
  ; Registry Editor, asks if you're sure you want to import settings to the registry
  SendIfWinActiveEx("Registry Editor ahk_class #32770", "", "{space}", false, 572, 137)
  SendIfWinActiveEx("Registry Editor ahk_class #32770", "", "{space}", false, 572, 199)

  ; Registry Editor, confirm importing settings
  SendIfWinActiveEx("Registry Editor ahk_class #32770", "", "!y", false, 572, 182)
  
  ; Office, ???
  SendIfWinActiveEx("Microsoft Office Security Options ahk_class NUIDialog", "", "!e{enter}", false, 491, 436)
  
  ; OneNote "Are You Sure" to open an external link
  ; SendIfWinActiveEx("Microsoft Office OneNote Security Notice ahk_class NUIDialog", "", "!y", false, 398, 215)
  SendIfWinActiveEx("Microsoft Office OneNote Security Notice ahk_class NUIDialog", "", "!y", false, 398, 217)

  ; Remote Desktop asks if you're sure you want to connect to a PC that is not Vista secure
  SendIfWinActiveEx("Remote Desktop Connection", "Yes", "!y", false, 562, 232)
  
  ; Windows asking if data should be sent to MS after and application crashes
  SendIfWinActiveEx("Microsoft Windows ahk_class #32770", "Send information", "!s", false, 424, 189)

  ; Excel, asking if external data sources should be allowed
  SendIfWinActiveEx("Microsoft Office Excel Security Notice ahk_class NUIDialog", "", "{space}", false, 398, 193)
 
  ; Task Manager, asking if the process should be forced to close
  SendIfWinActiveEx("Windows Task Manager ahk_class #32770", "End process", "{space}", false, 366, 198)

  ; Windows Image Preview, Delete Confirmation, Removable Storage
  SendIfWinActiveEx("Confirm File Delete ahk_class #32770", "", "!y", false, 402, 129)

  ; Windows Image Preview, Multiple File Delete Confirmation, Removable Storage
  SendIfWinActiveEx("Confirm Multiple File Delete ahk_class #32770", "", "!y", false, 392, 129)

return







; -----------------------------------------------------------------------------------
; -- Sends keys if a window matching criteria is the active window
; -- AutoHotkey doesn't have method overloading so we name them differently
; ------------------------------------------------------------------------------------

SendIfWinActive(title, text, keys)
{ 
  SendIfWinActiveEx(title, text, keys, false, 0, 0) 
}

SendIfWinActiveEx(title, text, keys, regex, targetWidth, targetHeight)
{
	SendIfWinActiveExtended(title, text, keys, regex, targetWidth, targetHeight, "false")
}

SendIfWinActiveForce(title, text, keys, regex, targetWidth, targetHeight)
{
	SendIfWinActiveExtended(title, text, keys, regex, targetWidth, targetHeight, "true")
}

; Sends keys to a dialog if the dialog can be found
SendIfWinActiveExtended(title, text, keys, regex, targetWidth, targetHeight, force)
{
  ; Save current title mode matching
  savedA_TitleMatchMode=%A_TitleMatchMode%
  
  ; Using regex to specify title?
  if (regex)
    SetTitleMatchMode RegEx
  
  ; Activate the dialog if it exists
  if (force = "true")
		WinActivate %title%, %text%
  
  ; Find the dialog
  IfWinActive %title%, %text%
  {
    ; If dialog size is provided, make sure it matches
    if (targetWidth > 0 and targetHeight > 0)
    {
      WinGetActiveStats, Title, Width, Height, X, Y
      if (targetWidth = Width and targetHeight = Height)
      {
        Send %keys%
      }
    } else {
      Send %keys%
    }
  }
  
  ; Restore previous title mode matching
  SetTitleMatchMode %savedA_TitleMatchMode%
}
