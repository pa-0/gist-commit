#Requires AutoHotkey v2.0
#SingleInstance Force

/*
1. Semicolon (; ) or a pound sign (#) indicates that it is a note line.
2. The beginning of the slash (/) indicates the output folder
3. Words
   One word per line, automatically go to the Yahoo! website to retrieve the explanation, phonetic transcription and parts of speech
   park
4. Missing words
   A sentence containing {{c1:: is a sentence with a group of missing words
   I love {{c1::summer}} {{c2::vacation}}. i like summer vacation
*/

Global _EXPL_ := 1  ; Explanation
Global _NOTION_ := 2  ; Part of speech
Global _PRONOUNCE_ := 3  ; Phonetic Pronunciation

; There are 3 formats for input text files
; 1=English words
; 2=phrase [Tab] Chinese explanation
; 3=Kelu character

Global _ACTION_WORD_ := 1
Global _ACTION_PHRASE_ := 2
Global _ACTION_CLOZE_ := 3

Global sInputFile := "j:\AHK2\English-7A.txt"  ;Input profile, file encoding：UTF-8
;;Global sOutputFolder := "j:\JERRY\MOC\060-Anki\English-7\English-7-1-words\"
Global sSeparator := A_Tab  ;Delimiter character for input file

Global action_word

; template to generate
; {1}=single word {2}=Parts of speech + Chinese explanation {3}=Phonetic symbols {4}=Blank unused
action_word := "
(
---
tags:
  - english
  - english-word
  - english-7A
---
# {1}

---
---

{2}

{3}
{4}
)"  ; action_word

;f1::
oInputBox := InputBox("Enter profile name：", "Enter filename", "w300 h100", sInputFile)
if (oInputBox.Result = "Cancel") {
  Return
}
sInputFile := oInputBox.Value

if !FileExist(sInputFile) {
  MsgBox(sInputFile . "Must be created first。", "Error!", 0)
  Return
}
_iCount := 0

FileEncoding "UTF-8"

_sTags := ""
_sOutputFolder := ""
_aEnglishWords := []
_aOutputFolders := []
_iWordCount := 0

;Add words to array and get count to create progress bar
Loop read, sInputFile
{
  iLineNumber := A_Index
  Loop parse, A_LoopReadLine, "`n"
  {
    ;MsgBox line #%A_Index%=%_sLine%.
    _sLine := A_LoopField
    _sFirstChar := SubStr(_sLine, 1, 1)
    if (_sFirstChar == ";" or _sFirstChar == "#") {  ;If 1st char is semicolon (;) or pound (#), then treat as comment
      continue
    }
    if (_sFirstChar == "/") {  ;; if 1st character is forward slash (/) treate as output folder
      _sOutputFolder := SubStr(_sLine, 2, 255)
      _sLastChar := SubStr(_sOutputFolder, StrLen(_sOutputFolder) - 1, 1)
      if (_sLastChar != "\") {
        _sOutputFolder := _sOutputFolder . "\"
      }
      if (!FileExist(_sOutputFolder)) {
        DirCreate(_sOutputFolder)
      }
      continue
    }
    _iWordCount++
    _aEnglishWords.Push(_sLine)
    _aOutputFolders.Push(_sOutputFolder)
  }
}  

_fProgressInc := Float(100 / _iWordCount)  ; counter iteration of progress bar
MyGui := Gui()
oText := MyGui.Add("Text", "w200", "Total: " . "0 / " . _iWordCount)
MyGui.Add("Progress", "w200 h20 cBlue vMyProgress", 0)
MyGui.Show()

_iCount := 0
Loop _iWordCount
{
  _sEnglishWord := _aEnglishWords[A_Index]
  _sOutputFolder := _aOutputFolders[A_Index]
  _iCount++
  
  oText.Value := "Total: " . _iCount . " / " . _iWordCount
  MyGui["MyProgress"].Value := _iCount * _fProgressInc
  output(_ACTION_WORD_, _sOutputFolder, _sEnglishWord, "", "")
}
MyGui.Destroy

MsgBox("Number of Processes: " . _iCount, "Result", 0)
ExitApp(0)
Return

;; Write the word sNotion: part of speech
output(iActionKind, sOutputFolder, sEnglish, sChinese, sNotion) {
  ;MsgBox("Text " . sEnglish . "=" . sChinese, "Title", 0)
  local _sOutput, _aTokens, _sChineseGet, _sNotion

  if (iActionKind == _ACTION_WORD_) {  ;single word
    action := action_word
    try {
      _aTokens := translate(sEnglish)  ;get translation, phonetic symbols, and parts of speech
      _sChineseGet := _aTokens[_EXPL_]
      _sNotion := _aTokens[_NOTION_]  ;part of speech
      ;; \r and \t will cause failure and must be converted first.
      _sChineseGet := StrReplace(_sChineseGet, "`r", " ")
      _sChineseGet := _sNotion . " " . StrReplace(_sChineseGet, "`t", " ")
      _sEnghishGet := " " . _aTokens[_PRONOUNCE_]
      _sEnghishGet := StrReplace(_sEnghishGet, "`r", " ")

      _sOutputFilename := sEnglish . ".md"
      if (FileExist(sOutputFolder . _sOutputFilename)) {
        FileDelete(sOutputFolder . _sOutputFilename)
      }
      _sOutput := Format(action, sEnglish, _sChineseGet, _sEnghishGet, "")
      FileAppend(_sOutput, sOutputFolder . _sOutputFilename)
      return 1
    } catch (Error as err) {
      MsgBox(sEnglish . " " . err.Message, "Error!", 0)
      return 0
    }
  }
}

;Pass text as search terms and return results.
;Output results in Markdown
translate(sSearch) {
  ;msgbox sSearch=%sSearch%
  url := "https://tw.dictionary.search.yahoo.com/search?p=" . sSearch . "&fr=sfp&iscqry="

  httpClient := ComObject("WinHttp.WinHttpRequest.5.1")
  httpClient.Open("POST", url, false)
  httpClient.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
  httpClient.Send()
  httpClient.WaitForResponse()
  Result := httpClient.ResponseText

  html := ComObject("HTMLFile")
  html.write(Result)

  elements := html.getElementsByTagName("div")
  _sPronounce := ""  ;pronunciation
  _sNotion := ""     ;part of speech
  _sDictionaryExplanation := ""  ;explain

  _isFirstNotion := true
  _isFirstExplain := true
  ;MsgBox("length=" . elements.Length, "Length", 0)
  Loop elements.length
  {
    ele := elements(A_Index - 1) ; zero based collection. [] does not work
    _sClassName := ele.className

    if (InStr(_sClassName, "pos_button") > 0) and (_isFirstNotion) {  ;part of speech
      _sNotion := ele.innerHTML
      _sNotion := StrReplace(_sNotion, "[", "\[")  ;Change 'n.[C]' to 'n.\[C]'
      _isFirstNotion := false
    } else if (InStr(_sClassName, "compList d-ib") > 0) {  ;phonetic symbols
      _sPronounce := ele.innerText
      _iPos := InStr(_sPronounce, "DJ[")
      _sPronounce := SubStr(_sPronounce, 1, _iPos - 1)
      _sPronounce := StrReplace(_sPronounce, "[", "\[")  ;change 'KK[' to 'KK\['
      ;Msgbox("pronounce="  _sPronounce, "pronounce", 0)
    } else if (InStr(_sClassName, "dictionaryExplanation") > 0 and _isFirstExplain) {
      _sDictionaryExplanation .= ele.innerHTML . "`r"
      _sDictionaryExplanation := StrReplace(_sDictionaryExplanation, "[", "\[")
      _isFirstExplain := false
    }
  }
  ;;MsgBox("expl=" . _sDictionaryExplanation . ", notion=" . _sNotion . ", pron=" . _sPronounce, "title",0)
  _aTokens := []
  _aTokens.Push(_sDictionaryExplanation, _sNotion, _sPronounce)

  return _aTokens
}
