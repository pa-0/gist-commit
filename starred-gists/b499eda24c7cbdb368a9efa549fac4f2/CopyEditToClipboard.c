// HWND of text element
void CopyEditToClipboard(HWND hWnd)
{
	SendMessage(hWnd, EM_SETSEL, 0, 65535L);
	SendMessage(hWnd, WM_COPY, 0 , 0);
	SendMessage(hWnd, EM_SETSEL, 0, 0);
}

// Example
CopyEditToClipboard(GetDlgItem(hwndDlg, IDC_EDIT_MAIN));