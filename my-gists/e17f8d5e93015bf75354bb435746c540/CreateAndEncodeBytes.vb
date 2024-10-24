Function CreateAndEncodeBytes(part2 As String, part4_base64 As String) As String
    ' Define the parts
    Dim part1() As Byte
    part1 = StrConv(Chr(0) & Chr(3) & Chr(36) & Chr(0), vbFromUnicode)

    Dim part3() As Byte
    part3 = StrConv(Chr(0) & Chr(46) & Chr(0), vbFromUnicode)

    ' Decode part4 from Base64 and get the byte array
    Dim part4_full() As Byte
    part4_full = Base64Decode(part4_base64)

    ' Extract the required part from part4 (excluding the first and the last byte)
    Dim part4() As Byte
    ReDim part4(UBound(part4_full) - 2)
    Dim i As Integer
    For i = 1 To UBound(part4_full) - 1
        part4(i - 1) = part4_full(i)
    Next i

    ' Convert part2 (String) to byte array
    Dim part2_bytes() As Byte
    part2_bytes = StrConv(part2, vbFromUnicode)

    ' Create a new byte array to hold the combined result
    Dim combined() As Byte
    ReDim combined(UBound(part1) + UBound(part2_bytes) + UBound(part3) + UBound(part4) + 3)

    ' Combine part1, part2_bytes, part3, and part4 into the combined array
    Dim pos As Integer
    pos = 0

    ' Copy part1 to combined
    For i = LBound(part1) To UBound(part1)
        combined(pos) = part1(i)
        pos = pos + 1
    Next i

    ' Copy part2_bytes to combined
    For i = LBound(part2_bytes) To UBound(part2_bytes)
        combined(pos) = part2_bytes(i)
        pos = pos + 1
    Next i

    ' Copy part3 to combined
    For i = LBound(part3) To UBound(part3)
        combined(pos) = part3(i)
        pos = pos + 1
    Next i

    ' Copy part4 to combined
    For i = LBound(part4) To UBound(part4)
        combined(pos) = part4(i)
        pos = pos + 1
    Next i

    ' Encode the combined byte array to Base64
    Dim encoded_combined As String
    encoded_combined = Base64Encode(combined)

    ' Return the result
    CreateAndEncodeBytes = encoded_combined
End Function