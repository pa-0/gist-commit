'Description:
'The file containing this code is closed and permanently deleted. **Caution** - use this code with care 
'
'Discussion:
'Perhaps a workbook should expire after a certain date, or somone fails to correctly answer a password 
'query and the file is deleted to prevent unauthorised access. This code could be used in conjuction with
'(or as an alternative to) gist6.vb <https://gist.github.com/poa00/fa049ccd8ef5aed069bb1e847bef0145> to 
'delete a workbook once its trial period has expired. 

Option Explicit 
Sub KillMe() 
    With ThisWorkbook 
        .Saved = True 
        .ChangeFileAccess Mode:=xlReadOnly 
        Kill .FullName 
        .Close False 
    End With 
End Sub 
 
'How to use:
'Copy the code above.
'Open your workbook.
'Hit Alt+F11 to open the Visual Basic Editor (VBE).
'From the menu, choose Insert-Module.
'Paste the code into the code window at right.
'Close the VBE, and save the file if desired.
' 
'Test the code:
'Run the macro by going to Tools-Macro-Macros and double-click KillMe.
'**** This code will kill the file it is run from! ****