' Origin:https://social.msdn.microsoft.com/Forums/office/en-US/62938e12-5cad-4de7-92e9-00314813d31a/publish-date-property-in-word?forum=worddev
Sub SetDeveloperTabActive()
    Dim RibbonTab As IAccessible
    Set RibbonTab = GetAccessible(CommandBars("Ribbon"), ROLE_SYSTEM_PAGETAB,"Developer")
    If Not RibbonTab Is Nothing Then
        If ((RibbonTab.accState(CHILDID_SELF) And (STATE_SYSTEM_UNAVAILABLE Or STATE_SYSTEM_INVISIBLE)) = 0) Then
            RibbonTab.accDoDefaultAction CHILDID_SELF
        Else
            MsgBox "Designated Tab is unavailable"
        End If
    End If
End Sub

' Alternatively, using the registry:
DeveloperTools option in the registry.

Sub Test_DeveloperTab()
    Call setDeveloperTab(1)
End Sub

Sub setDeveloperTab(ByVal mode As Integer)
    Dim regKey As String
    regKey = "HKEY_CURRENT_USER\Software\Microsoft\Office\" & Application.Version & "\Excel\options\DeveloperTools"
    
    On Error GoTo errHandler
    
    ' If value is equal to existing or different from 0 or 1 then exit
    Select Case Registry_KeyExists(regKey)
        Case 0: If mode = 0 Then Exit Sub
        Case 1: If mode = 1 Then Exit Sub
        Case Else: Exit Sub
    End Select
    
    ' Late Binding
    Dim oShell As Object: Set oShell = CreateObject("Wscript.Shell")
        
    If (mode <> 0 And mode <> 1) Then Exit Sub
    
    ' Developer Tab: Activate \\ Deactivate
    oShell.RegWrite regKey, mode, "REG_DWORD"
    
exitRoutine:
    Exit Sub
    
errHandler:
    Debug.Print Now() & "; " & Err.Number & "; " & Err.Source & "; " & Err.Description
    Resume exitRoutine
End Sub

Function Registry_KeyExists(ByVal regKey$) As Variant
    ' Check if registry key exists
    
    On Error GoTo errHandler
    
    Dim wsh As Object: Set wsh = CreateObject("WScript.Shell")
    Registry_KeyExists = wsh.RegRead(regKey)

Exit Function

errHandler:
    Err.Raise Err.Number, "Registry_KeyExists", Err.Description
End Function