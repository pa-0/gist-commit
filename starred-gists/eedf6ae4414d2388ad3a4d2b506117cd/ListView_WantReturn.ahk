; ==================================================================================================================================
; LV_WantReturn
;     'Fakes' Return key processing for ListView controls which otherwise won't process it.
;     If enabled, control's g-label will be triggered with A_GuiEvent = K and A_EventInfo = 13
;     whenever the <Return> key is pressed while the control has the focus.
; Usage:
;     To register a control call the functions once and pass the controls HWND as the first and only parameter.
;     To deregister it, call the function again with the same HWND as the first and only parameter.
; ==================================================================================================================================
ListView_WantReturn(wParam, lParam := "", Msg := "", HWND := "") {
    Static Controls := []
         , MsgFunc := Func("ListView_WantReturn")
         , OnMsg := False
         , LVN_KEYDOWN := -155
   ; Message handler call -----------------------------------------------------------------------------------------------------------
    If (Msg = 256) { ; WM_KEYDOWM (0x0100)
       If (wParam = 13) && (Ctl := Controls[HWND]) {
          If !(lParam & 0x40000000) { ; don't send notifications for auto-repeated keydown events
             VarSetCapacity(NMKD, (A_PtrSize * 3) + 8, 0) ; NMLVKEYDOWN/NMTVKEYDOWN structure 64-bit
             , NumPut(HWND, NMKD, 0, "Ptr")
             , NumPut(Ctl.CID, NMKD, A_PtrSize, "Ptr")
             , NumPut(LVN_KEYDOWN, NMKD, A_PtrSize * 2, "Int")
             , NumPut(13, NMKD, A_PtrSize * 3, "UShort")
             , DllCall("SendMessage", "Ptr", Ctl.HGUI, "UInt", 0x004E, "Ptr", Ctl.CID, "Ptr", &NMKD)
          }
          Return 0
       }
    }
    ; User call ---------------------------------------------------------------------------------------------------------------------
    Else {
       If (Controls[wParam += 0]) { ; the control is already registered, remove it
          Controls.Delete(wParam)
          If ((Controls.Length() = 0) && OnMsg) {
             OnMessage(0x0100, MsgFunc, 0)
             OnMsg := False
          }
          Return True
       }
       If !DllCall("IsWindow", "Ptr", wParam, "UInt")
          Return False
       WinGetClass, ClassName, ahk_id %wParam%
       If (ClassName <> "SysListView32")
          Return False
       Controls[wParam] := {CID:  DllCall("GetDlgCtrlID", "Ptr", wParam, "Int")
                          , HGUI: DllCall("GetParent", "Ptr", wParam, "UPtr")}
       If !(OnMsg)
          OnMessage(0x0100, MsgFunc, -1)
       Return (OnMsg := True)
    }
 }
