Sub FindExchangeGuidAndProcess()
    Dim wsFolder As Worksheet, wsUrls As Worksheet
    Dim part2_string As String
    Dim part4_base64_string As String
    Dim result As String
    Dim encodedResult As String ' URLエンコードされた結果
    Dim finalUrl As String ' 最終的にセルに書き込むURL
    Dim hyperlinkFormula As String ' HYPERLINK関数を使用する数式
    Dim linkText As String ' リンクテキスト
    Dim lastRow As Long, urlRow As Long
    Dim i As Long

    ' "MailboxFolder" シートを設定
    Set wsFolder = ThisWorkbook.Sheets("MailboxFolder")

    ' "FolderUrls" シートを設定、存在しない場合は新規作成
    On Error Resume Next
    Set wsUrls = ThisWorkbook.Sheets("FolderUrls")
    If wsUrls Is Nothing Then
        Set wsUrls = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
        wsUrls.Name = "FolderUrls"
    End If
    On Error GoTo 0

    ' FolderUrls シートの内容をクリア
    wsUrls.Cells.Clear

    ' MailboxFolder シートの D 列の最後の行を取得
    lastRow = wsFolder.Cells(wsFolder.Rows.Count, "D").End(xlUp).Row

    ' FindExchangeGuid 関数を呼び出して part2_string を取得
    part2_string = FindExchangeGuid()

    ' part2_string が空でない場合のみ処理を行う
    If part2_string <> "" Then
        urlRow = 1 ' FolderUrls シートでの書き込み開始行
        ' MailboxFolder シートの D 列を走査して part4_base64_string を取得し処理
        For i = 2 To lastRow ' ヘッダ行をスキップ
            part4_base64_string = wsFolder.Cells(i, "D").Value
            linkText = wsFolder.Cells(i, "A").Value ' A 列の値をリンクテキストとして使用

            ' CreateAndEncodeBytes 関数を呼び出す
            result = CreateAndEncodeBytes(part2_string, part4_base64_string)

            ' URLエンコーディング: "=" を "%3D" に、"+" を "%2B" に置き換える
            encodedResult = Replace(result, "=", "%3D")
            encodedResult = Replace(encodedResult, "+", "%2B")
            encodedResult = Replace(encodedResult, "/", "%2F")

            ' "https://outlook.office.com/mail/" と連接
            finalUrl = "https://outlook.office.com/mail/" & encodedResult

            ' HYPERLINK関数を使用して数式を生成
            hyperlinkFormula = "=HYPERLINK(""" & finalUrl & """, """ & linkText & """)"
            
            ' HYPERLINK数式を FolderUrls シートに書き込む
            wsUrls.Cells(urlRow, 1).Formula = hyperlinkFormula
            urlRow = urlRow + 1
        Next i
    Else
        ' part2_string が空の場合、ExchangeGuid が見つからなかったことを表示
        Debug.Print "ExchangeGuid が見つかりませんでした。"
    End If
End Sub

