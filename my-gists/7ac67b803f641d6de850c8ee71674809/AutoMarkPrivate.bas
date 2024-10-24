Sub Appt_AutoMarkPrivate(oItem As Object)
If TypeOf oItem Is MeetingItem Then
   Set oItem = oItem.GetAssociatedAppointment(True)
End If
'Change the condition as per your actual needs
If (oItem.SenderEmailAddress = "thierry.dalon@gmail.com") Or (oItem.ReplyRecipients.Item(1).Address = "thierry.dalon@gmail.com") _
Or (oItem.ReplyRecipients.Item(1).Address = "c9e3p3airart0n2hvn9cq825i0@group.calendar.google.com") _
Or (InStr(LCase(objMeeting.Subject), "emmi") > 0) Or (InStr(LCase(objMeeting.Subject), "leo") > 0) Then
   oItem.Sensitivity = olPrivate
   oItem.Save
End If
End Sub