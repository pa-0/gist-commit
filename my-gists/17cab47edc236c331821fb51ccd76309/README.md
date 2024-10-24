```vba
Public Sub FetchExample()
  Dim Client As New WebClient
  Client.BaseUrl = "https://example.com/"
  Dim Request As New WebRequest
  Request.Format = WebFormat.PlainText
  Request.Method = WebMethod.HttpGet
  Dim Response As WebResponse
  Set Response = Client.Execute(Request)
  Debug.Print Response.Content
End Sub
```