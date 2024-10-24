call_vba 
'full script below
'Double-click the vbs file to execute the VBA of the xlsm file of the same name.

''''''''''''''call_vba.vbs''''''''''''''
FilePath = Replace(WScript.ScriptFullName, ".vbs", ".xlsm")
Const FunctionName = "main"

With WScript.CreateObject("Excel.Application")
  .Visible = True ' if true, excel window visible when app opens
    .Workbooks.Open FilePath
    .Application.Run FunctionName
    .Quit
End With
''''''''''''''call_vba.vbs''''''''''''''

'Example: Call the main procedure or function of book.xlsm.
'Save this VBS file in the same folder as the XLSM file with the same name (book.vbs in this example).
'If you double-click this VBS file, the target procedure or function will be called.

'Note: path of the xlsm file created by using filename of script itself (XXX.vbs) parsed w/ "WScript.ScriptFullName" and replacing ext