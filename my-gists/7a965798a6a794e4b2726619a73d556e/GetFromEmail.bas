Function GetFromEmail(oItem As Object) As String
' https://tdalon.blogspot.com/2020/09/outlook-vba-get-from-email.html
Dim oAddressEntry As Outlook.AddressEntry
If TypeOf oItem Is Outlook.MailItem Then
    Set oAddressEntry = oItem.Sender
ElseIf (TypeOf oItem Is Outlook.AppointmentItem) Then
    Set oAddressEntry = oItem.GetOrganizer
End If
    
If oAddressEntry.Type = "SMTP" Then
    GetFromEmail = oAddressEntry.Address
ElseIf oAddressEntry.Type = "EX" Then
    GetFromEmail = oAddressEntry.GetExchangeUser.PrimarySmtpAddress
End If
End Function