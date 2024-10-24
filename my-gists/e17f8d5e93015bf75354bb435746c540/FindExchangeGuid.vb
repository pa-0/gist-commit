Function FindExchangeGuid() As String
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Mailbox") ' "Mailbox" シートを設定

    Dim lastRow As Long
    Dim i As Long
    
    ' A列の最後の行を取得
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    
    ' A列を下に走査して "ExchangeGuid" を探す
    For i = 1 To lastRow
        If ws.Cells(i, "A").Value = "ExchangeGuid" Then
            FindExchangeGuid = ws.Cells(i, "B").Value ' B列の値を返す
            Exit Function
        End If
    Next i

    ' ExchangeGuid が見つからない場合、空の文字列を返す
    FindExchangeGuid = ""
End Function