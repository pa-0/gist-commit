#If Confluence_IsWinActive()
::,ver:: ; Page version info
sHtml := Confluence_GetVerLink(url:="")
Clip_PasteHtml(sHtml)	
return