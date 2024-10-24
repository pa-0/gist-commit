const KEY_QUERY_VALUE = &H0001
const KEY_SET_VALUE = &H0002
const KEY_CREATE_SUB_KEY = &H0004
const DELETE = &H00010000
const HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002
const REG_SZ = 1
const REG_EXPAND_SZ = 2
const REG_BINARY = 3
const REG_DWORD = 4
const REG_MULTI_SZ = 7


'Create Key
Sub createKey()
  strComputer = "."
	Set StdOut = WScript.StdOut

 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SOFTWARE\System Admin Scripting Guide"
	oReg.CreateKey HKEY_LOCAL_MACHINE,strKeyPath
end sub

'Create String & Dword
Sub createString()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SOFTWARE\System Admin Scripting Guide"
	strValueName = "String Value Name"
	strValue = "string value"
	oReg.SetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
	 
	strValueName = "DWORD Value Name"
	dwValue = 82
	oReg.SetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,dwValue
end Sub

'Create Binary Value
'Note: the iVaules contain a byte array, specified in hex
Sub createNode()
	strComputer = "."
	iValues = Array(&H01,&Ha2,&H10)
	Set oReg=GetObject( _ 
		"winmgmts:{impersonationLevel=impersonate}!\\" & _
	   strComputer & "\root\default:StdRegProv")
	strKeyPath = "SOFTWARE\NewKey"
	oReg.CreateKey HKEY_LOCAL_MACHINE,strKeyPath
	BinaryValueName = "Example Binary Value"

	oReg.SetBinaryValue HKEY_LOCAL_MACHINE,strKeyPath,_
		BinaryValueName,iValues
End Sub

'Delete Key
sub DeleteKey()
	strComputer = "."
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SOFTWARE\System Admin Scripting Guide"
	 
	oReg.DeleteKey HKEY_LOCAL_MACHINE, strKeyPath
end Sub

'Enumerate Values
Sub enumValues()
	On Error Resume Next
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery("Select * from Win32_Registry")
	For Each objItem in colItems
		Wscript.Echo "Current Size: " & objItem.CurrentSize
		Wscript.Echo "Description: " & objItem.Description
		Wscript.Echo "Install Date: " & objItem.InstallDate
		Wscript.Echo "Maximum Size: " & objItem.MaximumSize
		Wscript.Echo "Name: " & objItem.Name
		Wscript.Echo "Proposed Size: " & objItem.ProposedSize
	Next
end Sub

'Enumerate Values and Types
Sub enumValuesTypes()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SYSTEM\CurrentControlSet\Control\Lsa"
	 
	oReg.EnumValues HKEY_LOCAL_MACHINE, strKeyPath,_
	 arrValueNames, arrValueTypes
	 
	For i=0 To UBound(arrValueNames)
		StdOut.WriteLine "Value Name: " & arrValueNames(i) 
		
		Select Case arrValueTypes(i)
			Case REG_SZ
				StdOut.WriteLine "Data Type: String"
				StdOut.WriteBlankLines(1)
			Case REG_EXPAND_SZ
				StdOut.WriteLine "Data Type: Expanded String"
				StdOut.WriteBlankLines(1)
			Case REG_BINARY
				StdOut.WriteLine "Data Type: Binary"
				StdOut.WriteBlankLines(1)
			Case REG_DWORD
				StdOut.WriteLine "Data Type: DWORD"
				StdOut.WriteBlankLines(1)
			Case REG_MULTI_SZ
				StdOut.WriteLine "Data Type: Multi String"
				StdOut.WriteBlankLines(1)
		End Select 
	Next
End Sub

'Enumerate Subkeys
Sub enumSubKeys()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SYSTEM\CurrentControlSet\Services"
	oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys
	 
	For Each subkey In arrSubKeys
		StdOut.WriteLine subkey
	Next
End Sub

'List Registry Files
Sub listFiles()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	strKeyPath = "System\CurrentControlSet\Control\hivelist"
	oReg.EnumValues HKEY_LOCAL_MACHINE, strKeyPath,_
	 arrValueNames, arrValueTypes
	 
	For i=0 To UBound(arrValueNames)
		StdOut.WriteLine "File Name: " & arrValueNames(i) & " -- "      
		oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,_
		arrValueNames(i),strValue
		StdOut.WriteLine "Location: " & strValue
		StdOut.WriteBlankLines(1)
	Next
End Sub

'Read Expanded String Value
Sub getExpanded()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon"
	strValueName = "UIHost"
	oReg.GetExpandedStringValue HKEY_LOCAL_MACHINE,strKeyPath,_
	strValueName,strValue
	 
	StdOut.WriteLine  "The Windows logon UI host is: " & strValue
End Sub

'Read Multi String Value
Sub getMultiString()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SYSTEM\CurrentControlSet\Services\Eventlog\System"
	strValueName = "Sources"
	oReg.GetMultiStringValue HKEY_LOCAL_MACHINE,strKeyPath,_
	strValueName,arrValues
	 
	For Each strValue In arrValues
		StdOut.WriteLine  strValue
	Next
End Sub

'Read String and DWORD Value
Sub getString()
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_
	 strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "Console"
	strValueName = "HistoryBufferSize"
	oReg.GetDWORDValue HKEY_CURRENT_USER,strKeyPath,strValueName,dwValue
	StdOut.WriteLine "Current History Buffer Size: " & dwValue 
	 
	 
	strKeyPath = "SOFTWARE\Microsoft\Windows Script Host\Settings"
	strValueName = "TrustPolicy"
	oReg.GetStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,strValue
	StdOut.WriteLine "Current WSH Trust Policy Value: " & strValue
End Sub

'Read Binary Values
Sub getBinary
	strComputer = "."
	Set StdOut = WScript.StdOut
	 
	Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" &_ 
	strComputer & "\root\default:StdRegProv")
	 
	strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion"
	strValueName = "LicenseInfo"
	oReg.GetBinaryValue HKEY_LOCAL_MACHINE,strKeyPath,_
	strValueName,strValue
	 
	 
	For i = lBound(strValue) to uBound(strValue)
		StdOut.WriteLine  strValue(i)
	Next
End Sub

'=============================================================
'==					Monitoring Registry
'=============================================================

'Entry Level Events
Set wmiServices = GetObject("winmgmts:root/default") 
Set wmiSink = WScript.CreateObject("WbemScripting.SWbemSink", "SINK_") 
 
wmiServices.ExecNotificationQueryAsync wmiSink, _ 
  "SELECT * FROM RegistryValueChangeEvent WHERE Hive='HKEY_LOCAL_MACHINE' " & _
      "AND KeyPath='SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion'" _
          & " AND ValueName='CSDVersion'" 
 
WScript.Echo "Listening for Registry Change Events..." & vbCrLf 
 
While(1) 
    WScript.Sleep 1000 
Wend 
 
Sub SINK_OnObjectReady(wmiObject, wmiAsyncContext) 
    WScript.Echo "Received Registry Change Event" & vbCrLf & _ 
                 "------------------------------" & vbCrLf & _ 
                 wmiObject.GetObjectText_() 
End Sub

'Subkey Events
Set wmiServices = GetObject("winmgmts:root/default") 
Set wmiSink = WScript.CreateObject("WbemScripting.SWbemSink", "SINK_") 
 
 
wmiServices.ExecNotificationQueryAsync wmiSink, _ 
  "SELECT * FROM RegistryKeyChangeEvent WHERE Hive='HKEY_LOCAL_MACHINE' AND " & _ 
    "KeyPath='SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion'" 
 
WScript.Echo "Listening for Registry Change Events..." & vbCrLf 
 
While(1) 
    WScript.Sleep 1000 
Wend 
 
Sub SINK_OnObjectReady(wmiObject, wmiAsyncContext) 
    WScript.Echo "Received Registry Change Event" & vbCrLf & _ 
                 "------------------------------" & vbCrLf & _ 
                 wmiObject.GetObjectText_() 
End Sub

'Subtree Events
Set wmiServices = GetObject("winmgmts:root/default") 
Set wmiSink = WScript.CreateObject("WbemScripting.SWbemSink", "SINK_") 
 
wmiServices.ExecNotificationQueryAsync wmiSink, _ 
    "SELECT * FROM RegistryTreeChangeEvent WHERE Hive= " _
        & "'HKEY_LOCAL_MACHINE' AND RootPath=''" 
 
 
WScript.Echo "Listening for Registry Change Events..." & vbCrLf 
 
While(1) 
    WScript.Sleep 1000 
Wend 
 
Sub SINK_OnObjectReady(wmiObject, wmiAsyncContext) 
    WScript.Echo "Received Registry Change Event" & vbCrLf & _ 
                 "------------------------------" & vbCrLf & _ 
                 wmiObject.GetObjectText_() 
End Sub
