
; Version: 2023.05.17.1
; https://gist.github.com/cd70e009792fc2eb866f9f5caf1e395a

/*
    Message.Listen(Callback) ; Listen
    Message.Listen()         ; Stop listening
    Message.Send(Message, Target[, Timeout := 7000ms])
    ErrorLevel
        -1 = Target not found
         0 = Message accepted
         1 = Message ignored
*/

class Message {

    Listen(Callback := "") {
        static WM_COPYDATA := 0x004A, bound := ""
        if (Callback = "") {
            OnMessage(WM_COPYDATA, bound, 0)
            bound := ""
            return
        }
        if (IsObject(Callback)) {
            if (Callback.MinParams < 1)
                throw Exception("Callback requires at least 1 parameter.", -1, Callback.Name)
            _callback := Callback
        } else {
            if (!IsFunc(Callback))
                throw Exception("Not a function.", -1, Callback)
            _callback := Func(Callback)
        }
        bound := ObjBindMethod(Message, "_Receive", _callback)
        OnMessage(WM_COPYDATA, bound, 1)
    }

    Send(Msg, Target, Timeout := 7000) {
        static WM_COPYDATA := 0x004A
        VarSetCapacity(COPYDATASTRUCT, 3 * A_PtrSize)
        NumPut(StrPut(Msg) * 2, COPYDATASTRUCT, A_PtrSize)
        NumPut(&Msg, COPYDATASTRUCT, 2 * A_PtrSize)
        Message._Modes(1)
        SendMessage WM_COPYDATA, 0, &COPYDATASTRUCT,, % Target,,,, % Timeout
        result := ErrorLevel
        Message._Modes(0)
        ErrorLevel := (result = "FAIL" ? -1 : !result)
    }

    ; Private

    _Modes(Mode) {
        static dhw, tmm
        if (Mode) {
            dhw := A_DetectHiddenWindows
            tmm := A_TitleMatchMode
        }
        DetectHiddenWindows % {0:dhw, 1:1}[Mode]
        SetTitleMatchMode % {0:tmm, 1:2}[Mode]
    }

    _Receive(Callback, _wParam, lParam) {
        lParam := NumGet(lParam + 2 * A_PtrSize)
        msg := StrGet(lParam)
        return Callback.Call(msg)
    }

}
