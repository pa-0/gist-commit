Function Base64Decode(base64Str As String) As Variant
    Dim xml As Object
    Set xml = CreateObject("MSXML2.DOMDocument.6.0")
    Dim element As Object
    Set element = xml.createElement("base64")
    element.DataType = "bin.base64"
    element.text = base64Str
    ' nodeTypedValueはバイト配列を返します。
    Base64Decode = element.nodeTypedValue
End Function