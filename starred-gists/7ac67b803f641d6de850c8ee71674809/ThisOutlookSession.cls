Private WithEvents objIncomingItems As Outlook.Items

Private Sub Application_Startup()
  Set objIncomingItems = Outlook.Application.Session.GetDefaultFolder(olFolderInbox).Items
End Sub


Private Sub objIncomingItems_ItemAdd(ByVal oItem As Object)
' Mark meeting as Private
' https://datanumen.com/blogs/2-quick-tips-auto-mark-specific-incoming-meetings-private-outlook/
If TypeOf oItem Is MeetingItem Then
   Call Appt_AutoMarkPrivate(oItem)
End If
End Sub