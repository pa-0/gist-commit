Attribute VB_Name = "SavePDFButton"
'  Outlook 2016: Save all PDF Attachments (Macro Button)
'  -----------------------------------------------------------------------------------------------------------
'  Author:          GSolone
'  Version:         0.3
'  Based on:        "Save Attachments to the hard drive"
'                   (https://www.slipstick.com/developer/save-attachments-to-the-hard-drive/)
'  Info:            https://gioxx.org/tag/microsoft-outlook
'  Last modified:   11-01-2018
'  Credits:         http://www.visual-basic-tutorials.com/Tutorials/MsCodes/get-special-directories-path-in-visual-basic.htm
'                   http://www.vbaexpress.com/forum/showthread.php?7866-Check-for-folder-create-if-it-does-not-exist
'                   http://www.pixelchef.net/content/rule-autosave-attachment-outlook?page=2
'                   https://www.slipstick.com/outlook/rules/outlook-2016-run-a-script-rules/
'  ------------------------------------------------------------------------------------------------------------
'   WARNING:
'       You'll need to set macro security to warn before enabling macros or
'       sign the macro. You can change the folder name or path where the attachments
'       are saved by editing the code.
'
'   UPDATES:
'       0.3- Fixed extraction bug (the previous version of the script can extract only "pdf" files, case sensitive!).
'       0.2- I prepend SentOn (Date) to attachments, to solve the problem of the attachments with the same file name. Fixed extraction bug (now it works only for PDF files).

Public Sub ExportAttachments()

    Dim objOL As Outlook.Application
    Dim objMsg As Outlook.MailItem 'Object
    Dim objAttachments As Outlook.Attachments
    Dim objSelection As Outlook.Selection
    Dim i As Long
    Dim lngCount As Long
    Dim strFile As String
    Dim strFolderpath As String
    Dim strDeletedFiles As String
    Dim dtDate As Date
    Dim sName As String
    
        ' Get the path to your Desktop folder
        strFolderpath = CreateObject("WScript.Shell").SpecialFolders(10)
        On Error Resume Next
    
        ' Instantiate an Outlook Application object.
        Set objOL = CreateObject("Outlook.Application")
    
        ' Get the collection of selected objects.
        Set objSelection = objOL.ActiveExplorer.Selection
    
        ' Set the Attachment folder.
        strFolderpath = strFolderpath & "\Attachments\"
        
        ' Create directory Attachments if not exist
        If Dir(strFolderpath, vbDirectory) = "" Then
            MkDir strFolderpath
        End If
    
        ' Check each selected item for attachments.
        For Each objMsg In objSelection
    
        Set objAttachments = objMsg.Attachments
        lngCount = objAttachments.Count
            
        If lngCount > 0 Then
            dtDate = objMsg.SentOn
            'dtDate = objMsg.ReceivedDate
            sName = Format(dtDate, "ddmmyyyy", vbUseSystemDayOfWeek, vbUseSystem) & "_" & Format(dtDate, "hhnnss", vbUseSystemDayOfWeek, vbUseSystem) & "-"
                
            ' Use a count down loop for removing items
            ' from a collection. Otherwise, the loop counter gets
            ' confused and only every other item is removed.
            
            For i = lngCount To 1 Step -1
                ' Get the file name.
                'strFile = objAttachments.Item(i).FileName
                strFile = sName & objAttachments.Item(i).FileName
				sFileType = LCase$(Right$(strFile, 4))
                ' Save the file only if is a PDF
                Select Case sFileType
				Case ".PDF", ".pdf"
					' Combine with the path to the Temp folder.
					strFile = strFolderpath & strFile
					' Save the attachment as a file.
					objAttachments.Item(i).SaveAsFile strFile
				End Select
            Next i
        End If
        
        Next
        
ExitSub:
    
    Set objAttachments = Nothing
    Set objMsg = Nothing
    Set objSelection = Nothing
    Set objOL = Nothing
End Sub
