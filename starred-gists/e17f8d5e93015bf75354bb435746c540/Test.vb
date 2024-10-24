Sub Test()
    Dim part2_string As String
    Dim part4_base64_string As String
    Dim expected As String
    Dim result As String

    ' 指定されたパート2とパート4の文字列
    part2_string = "67235055-46bb-4d57-ae1f-59589c9fddcd"
    part4_base64_string = "LgAAAAAHGGabzeUxQoG7SxGxGslRAQAM9NlovNFWQ4yxCZRlBLu9AAboWILbAAAB"

    ' CreateAndEncodeBytes関数から結果を取得
    result = CreateAndEncodeBytes(part2_string, part4_base64_string)
    
    ' 期待される結果
    expected = "AAMkADY3MjM1MDU1LTQ2YmItNGQ1Ny1hZTFmLTU5NTg5YzlmZGRjZAAuAAAAAAAHGGabzeUxQoG7SxGxGslRAQAM9NlovNFWQ4yxCZRlBLu9AAboWILbAAA="

    ' 期待される結果と実際の結果を比較
    If result = expected Then
        Debug.Print "テスト成功: 結果は期待される値と一致しています。"
    Else
        Debug.Print "テスト失敗: 結果が期待される値と一致しません。"
        Debug.Print "期待の結果: " & expected
        Debug.Print "実際の結果: " & result
    End If
End Sub