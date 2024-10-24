#Requires AutoHotkey v2
main := Gui('AlwaysOnTop')
lv := main.AddListView('w600 r10', ['Before', 'Selection', 'After', 'hwnd'])
lv.OnEvent('DoubleClick', ActivateWindow)

rangeStack := []
currentIndex := 0
contextLength := 20 ; context or tolerance in characters
wordApp := "" ;global placeholder for word application object

SelectRangeInWord(index) {
    global wordApp, rangeStack
    if (rangeStack.Length <= 1 || index < 1) {
        return
    }
    rangeData := rangeStack[index]
    wordApp := ComObjActive("Word.Application")
    if (wordApp) {
        ; doc := wordApp.Documents(rangeData.docName) ; Access the document by its name
        doc:=rangeData.doc
        if (doc) {
            wordApp.Visible := true ; Make sure Word is visible
            doc.Activate() ; Activate the document within Word
            if doc.Bookmarks.Exists(rangeData.bookmarkName) {
                bookmark := doc.Bookmarks.Item(rangeData.bookmarkName)
                bookmark.Range.Select()
                (rangeData.window != "") ? WinActivate(rangeData.window) : WinActivate("ahk_class OpusApp") ; Activate the Word window itself AFTER selecting the range
            } else {
                ToolTip("Bookmark not found.")
                Sleep(2000)
                ToolTip("")
            }
        } else {
            ToolTip("No document is currently active in Word.")
            Sleep(2000)
            ToolTip("")
        }
    } else {
        ToolTip("Microsoft Word is not running.")
        Sleep(2000)
        ToolTip("")
    }
}

GetSurroundingText(doc, rangeStart, rangeEnd, contextLength := 10) {
    beforeText := "", afterText := ""
    (rangeStart > contextLength) ? beforeText := doc.Range(rangeStart - contextLength, rangeStart).Text : beforeText := doc.Range(0, rangeStart).Text
    (rangeEnd + contextLength < doc.Content.End) ? afterText := doc.Range(rangeEnd, rangeEnd + contextLength).Text : afterText := doc.Range(rangeEnd, doc.Content.End).Text
    return {beforeText: beforeText, selectedText: doc.Range(rangeStart, rangeEnd).Text, afterText: afterText}
}

;this would be any hotkey of your choosing to save the word selection position
SC0D7::
{
    global rangeStack, currentIndex, contextLength, wordApp
    if WinActive("ahk_class OpusApp") {
        wordApp := ComObjActive("Word.Application")
        doc := wordApp.ActiveDocument
        selection := wordApp.Selection
        range := doc.Range(selection.Start, selection.End)
        textData := GetSurroundingText(doc, range.Start, range.End)
        currentWindow := WinGetTitle() ;hwnd store in rangeStack

        ; Add a unique bookmark
        bookmarkName := "Bookmark_" rangeStack.Length + 1
        if !doc.Bookmarks.Exists(bookmarkName) {
            doc.Bookmarks.Add(bookmarkName, range)
        }

        rangeStack.Push({bookmarkName: bookmarkName, selectedText: textData.selectedText, beforeText: textData.beforeText, afterText: textData.afterText, window: currentWindow, doc: doc})
        currentIndex := rangeStack.Length
    }
}
;this would be any hotkey of your choosing to jump back to the word selection in the stack
^SC0D7::
{
    global rangeStack, currentIndex
    if (rangeStack.Length >= 1) {
        currentIndex++
        if (currentIndex > rangeStack.Length) {
            currentIndex := 1 ; Wrap around to the beginning
        }
        SelectRangeInWord(currentIndex)
    }
}
!SC0D7::
{
    lv.Delete()
    for range in rangeStack
        lv.Add('', range.beforeText, range.selectedText, range.afterText, range.window)
    lv.ModifyCol()
    main.Show("x1921")
}

ActivateWindow(OBJ, ROW)
{
    global rangeStack
    SelectRangeInWord(ROW)
}

RemoveBookmarks() {
    global rangeStack, wordApp
    wordApp := ComObjActive("Word.Application")
    for rangeData in rangeStack {
        doc := wordApp.Documents(rangeData.docName)
        if doc.Bookmarks.Exists(rangeData.bookmarkName) {
            doc.Bookmarks(rangeData.bookmarkName).Delete()
        }
    }
    rangeStack := []
}

; Add a hotkey to remove all bookmarks
^!SC0D7::RemoveBookmarks()