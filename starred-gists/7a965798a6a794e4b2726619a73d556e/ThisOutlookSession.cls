Private Sub Application_Startup()
  Set calItems = Session.GetDefaultFolder(olFolderCalendar).Items
  Set objIncomingItems = Outlook.Application.Session.GetDefaultFolder(olFolderInbox).Items
  Call Cat_InitDic
End Sub

' Categorize Sent Emails
Private Sub Application_ItemSend(ByVal Item As Object, Cancel As Boolean)
    If TypeOf Item Is Outlook.MailItem And Len(Item.Categories) = 0 Then
        Call Cat_CheckRecip(Item)
    End If
End Sub
' ---------------------------
Private Sub calItems_ItemAdd(ByVal Item As Object)
' Categorize based on Recipients Domain
If TypeOf Item Is Outlook.AppointmentItem Then
    Call Cat_CheckRecip(Item)
End If
End Sub
' ---------------------------
Private Sub objIncomingItems_ItemAdd(ByVal oItem As Object) 
Call Cat_CheckItem(oItem)
End Sub