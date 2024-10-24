Confluence_GetVerLink(url:="") { ; @fun_Confluence_GetVerLink@
; Get Link information from current page Url
; sHtml := Confluence_GetVerLink(url:="")
If (url="")
	url := Browser_GetUrl()
If (url="")
	return
; Get current pageId
pageId := Confluence_GetPageId(url)
rootUrl := Confluence_GetRootUrl()
pageInfo := Confluence_GetPageInfo(pageId,rootUrl)
; If Confluence Document History page, get parentId
If RegExMatch(pageInfo["title"],"i)^(Document|Work Product) History") {
	pageId := pageInfo["parentId"]
	pageInfo := Confluence_GetPageInfo(pageId,rootUrl)
}
;MsgBox % Jxon_Dump(pageInfo) ; DBG
version := pageInfo["version"]
sText := version["createdAt"] . " (v." . version["number"] . ")"
sLink :=  rootUrl . "/pages/viewpage.action?pageId=" . pageId . "&pageVersion=" . version["number"]
sHtml := "<a href=""" . sLink . """>" . sText . "</a>"
return sHtml
}