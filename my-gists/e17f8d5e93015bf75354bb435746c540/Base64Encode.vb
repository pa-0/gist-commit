Function Base64Encode(inputData() As Byte) As String
    Dim xml As Object
    Set xml = CreateObject("MSXML2.DOMDocument.6.0")
    Dim element As Object
    Set element = xml.createElement("base64")
    element.DataType = "bin.base64"
    element.nodeTypedValue = inputData ' バイト配列を直接割り当てます。
    Base64Encode = Replace(element.text, vbLf, "")
    Base64Encode = Replace(Base64Encode, vbCrLf, "")
    Base64Encode = Replace(Base64Encode, vbCr, "")
End Function
