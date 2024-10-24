/************************************************************************
 * @description Customise a GroupBox's border size and text/ background colour
 * @file GroupBoxEx.ahk
 * @author Nikola Perovic
 * @link https://github.com/nperovic
 * @date 2024/06/09
 * @version 1.0.0
 ***********************************************************************/
 
#Requires AutoHotkey v2.1-alpha.13

/** @link https://github.com/nperovic/WAPI/blob/alpha/WAPI.ahk */
#Include <WAPI>

/** @link https://github.com/nperovic/WAPI/blob/alpha/struct.ahk */
#Include <struct>

class _GroupBox extends Gui.GroupBox {
    static __New() => super.Prototype.DefineProp("SetDarkMode", this.Prototype.GetOwnPropDesc("SetDarkMode"))

    /**
     * @param {Integer} [borderWidth=3] 
     * @param {Integer} [txColor=0xFFFFFF] 
     * @param {Integer} [txBgColor=0x202020] 
     * @param {Integer} [borderColor=0xFFFFFF] 
     */
    SetDarkMode(borderWidth := 3, txColor := 0xFFFFFF, txBgColor := 0x202020, borderColor := 0xFFFFFF) {
        static WM_PAINT := 0x000F
        this.OnMessage(WM_PAINT, (gCtrl, wParam, lParam, uMsg) {
            static DT_CALCRECT := 0x00000400

            ps  := Buffer(68)
            hdc := WAPI.BeginPaint(gCtrl.hwnd, ps)
            
            WAPI.GetClientRect(gCtrl.hwnd, rc  := RECT())
            WAPI.SelectObject(hdc, hPen := WAPI.CreatePen(PS_SOLID := 0, borderWidth, RgbToBgr(borderColor)))
            WAPI.FrameRect(hdc, rc, hPen)

            WAPI.SelectObject(hdc, hbrush := WAPI.CreateSolidBrush(RgbToBgr("0x" gCtrl.Gui.BackColor)))
            WAPI.Rectangle(hdc, rc.left, rc.top, rc.right, rc.bottom)
            
            WAPI.SetTextColor(hdc, RgbToBgr(txColor))
            WAPI.SetBkColor(hdc, RgbToBgr(txBgColor))

            textFlags := GetTextFlags(&center, &vcenter, &right, &bottom)
            WAPI.DrawText(hdc, StrPtr(gCtrl.Text), -1, rct := RECT(), DT_CALCRECT)
            WAPI.OffsetRect(rc, right ? -9 : center ? 0 : 6, (rct.bottom-rct.top)/-2)
            WAPI.DrawText(hdc, StrPtr(gCtrl.Text), -1, rc, textFlags)
            WAPI.EndPaint(gCtrl.hwnd, ps)
            WAPI.DeleteObject(hPen)
            WAPI.DeleteObject(hbrush)
            return 0 
        }, -1)

        GetTextFlags(&center?, &vcenter?, &right?, &bottom?) {
            static BS_BOTTOM := 0x800, BS_CENTER := 0x300, BS_LEFT := 0x100, BS_LEFTTEXT := 0x20, BS_MULTILINE := 0x2000, BS_RIGHT := 0x200, BS_TOP := 0x0400, BS_VCENTER := 0x0C00, DT_BOTTOM := 0x8, DT_CENTER := 0x1, DT_LEFT := 0x0, DT_RIGHT := 0x2, DT_SINGLELINE := 0x20, DT_TOP := 0x0, DT_VCENTER := 0x4, DT_WORDBREAK := 0x10
            
            dwStyle     := ControlGetStyle(this)
            txC         := dwStyle & BS_CENTER
            txR         := dwStyle & BS_RIGHT
            txL         := dwStyle & BS_LEFT
            dwTextFlags := (dwStyle & BS_BOTTOM) ? DT_BOTTOM : !(dwStyle & BS_TOP) ? DT_VCENTER : DT_TOP
            
            if (this.Type = "Button") 
                dwTextFlags |= (txC && txR && !txL) ? DT_RIGHT : (txC && txL && !txR) ? DT_LEFT : DT_CENTER
            else
                dwTextFlags |= txL && txR ? DT_CENTER : !txL && txR ? DT_RIGHT : DT_LEFT

            if !(dwStyle & BS_MULTILINE) 
                dwTextFlags |= DT_SINGLELINE

            if (this.Type = "GroupBox")
                dwTextFlags &= ~(DT_VCENTER| DT_SINGLELINE)
            
            center  := !!(dwTextFlags & DT_CENTER)
            vcenter := !!(dwTextFlags & DT_VCENTER)
            right   := !!(dwTextFlags & DT_RIGHT)
            bottom  := !!(dwTextFlags & DT_BOTTOM)
            
            return dwTextFlags | DT_WORDBREAK
        }

        RgbToBgr(color) => (Type(color) = "string") ? RgbToBgr(Number(SubStr(Color, 1, 2) = "0x" ? color : "0x" color)) : (Color >> 16 & 0xFF) | (Color & 0xFF00) | ((Color & 0xFF) << 16)
    }
}