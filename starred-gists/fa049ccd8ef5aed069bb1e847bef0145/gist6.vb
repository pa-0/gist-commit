'create the *.bas files first
'sample procedure: set a reference to the MS VBA Extensibility lib

Sub ImportBasFile()
Dim vbProj As VBProject

Set vbProj = ActiveDocument.VBProject
vbProj.VBComponents.Import "C:\MyBackBasFiles\FindReplaceStuff.bas"
End Sub

''''or'''
'use the Organizer to copy a module from to another template to another
  
Sub TransferViaOrganizer()
Dim source As String
Dim target As String

source = NormalTemplate.FullName
target = ActiveDocument.FullName
Application.OrganizerCopy source:=source, _
Destination:=target, Name:="FindReplaceStuff", _
Object:=wdOrganizerObjectProjectItems
End Sub

  'or to write code directly into an existing module:

'Adds to beginning of module
Sub WriteCodeToModule()
Dim vbProj As VBProject

Set vbProj = ActiveDocument.VBProject
vbProj.VBComponents("MathStuff").CodeModule.AddFromString _
"Sub NewCode()" & vbCr & _
"MsgBox " & """This procedure was added by code!""" & _
vbCr & "End Sub"

End Sub


    ' or to import from a bas file to an existing module:

Sub ImportIntoCodeModule()
Dim vbProj As VBProject

Set vbProj = ActiveDocument.VBProject
vbProj.VBComponents("MathStuff").CodeModule.AddFromFile _
"C:\BasBackup\OLEStuff.bas"
End Sub