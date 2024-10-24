#include <windows.h>
#include <commctrl.h>
#include "resource.h"

const char g_szClassName[] = "myWindowClass";

#define IDC_MAIN_EDIT	101
#define IDC_MAIN_TOOL	102
#define IDC_MAIN_STATUS	103
HINSTANCE hInstance;

BOOL LoadTextFileToEdit(HWND hEdit, LPCTSTR pszFileName)
{
	HANDLE hFile;
	BOOL bSuccess = FALSE;

	hFile = CreateFile(pszFileName, GENERIC_READ, FILE_SHARE_READ, NULL,
		OPEN_EXISTING, 0, NULL);
	if(hFile != INVALID_HANDLE_VALUE)
	{
		DWORD dwFileSize;

		dwFileSize = GetFileSize(hFile, NULL);
		if(dwFileSize != 0xFFFFFFFF)
		{
			LPSTR pszFileText;

			pszFileText = (LPSTR)GlobalAlloc(GPTR, dwFileSize + 1);
			if(pszFileText != NULL)
			{
				DWORD dwRead;

				if(ReadFile(hFile, pszFileText, dwFileSize, &dwRead, NULL))
				{
					pszFileText[dwFileSize] = 0; // Add null terminator
					if(SetWindowText(hEdit, pszFileText))
						bSuccess = TRUE; // It worked!
				}
				GlobalFree(pszFileText);
			}
		}
		CloseHandle(hFile);
	}
	return bSuccess;
}

BOOL SaveTextFileFromEdit(HWND hEdit, LPCTSTR pszFileName)
{
	HANDLE hFile;
	BOOL bSuccess = FALSE;

	hFile = CreateFile(pszFileName, GENERIC_WRITE, 0, NULL,
		CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
	if(hFile != INVALID_HANDLE_VALUE)
	{
		DWORD dwTextLength;

		dwTextLength = GetWindowTextLength(hEdit);
		// No need to bother if there's no text.
		if(dwTextLength > 0)
		{
			LPSTR pszText;
			DWORD dwBufferSize = dwTextLength + 1;

			pszText = (LPSTR)GlobalAlloc(GPTR, dwBufferSize);
			if(pszText != NULL)
			{
				if(GetWindowText(hEdit, pszText, dwBufferSize))
				{
					DWORD dwWritten;

					if(WriteFile(hFile, pszText, dwTextLength, &dwWritten, NULL))
						bSuccess = TRUE;
				}
				GlobalFree(pszText);
			}
		}
		CloseHandle(hFile);
	}
	return bSuccess;
}

void DoFileOpen(HWND hwnd)
{
	OPENFILENAME ofn;
	char szFileName[MAX_PATH] = "";

	ZeroMemory(&ofn, sizeof(ofn));

	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = hwnd;
	ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0";
	ofn.lpstrFile = szFileName;
	ofn.nMaxFile = MAX_PATH;
	ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
	ofn.lpstrDefExt = "txt";

	if(GetOpenFileName(&ofn))
	{
		HWND hEdit = GetDlgItem(hwnd, IDC_MAIN_EDIT);
		if(LoadTextFileToEdit(hEdit, szFileName))
		{
			SendDlgItemMessage(hwnd, IDC_MAIN_STATUS, SB_SETTEXT, 0, (LPARAM)"Opened...");
			SendDlgItemMessage(hwnd, IDC_MAIN_STATUS, SB_SETTEXT, 1, (LPARAM)szFileName);
		}
	}
}

void DoFileSave(HWND hwnd)
{
	OPENFILENAME ofn;
	char szFileName[MAX_PATH] = "";

	ZeroMemory(&ofn, sizeof(ofn));

	ofn.lStructSize = sizeof(ofn);
	ofn.hwndOwner = hwnd;
	ofn.lpstrFilter = "Text Files (*.txt)\0*.txt\0All Files (*.*)\0*.*\0";
	ofn.lpstrFile = szFileName;
	ofn.nMaxFile = MAX_PATH;
	ofn.lpstrDefExt = "txt";
	ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT;

	if(GetSaveFileName(&ofn))
	{
		HWND hEdit = GetDlgItem(hwnd, IDC_MAIN_EDIT);
		if(SaveTextFileFromEdit(hEdit, szFileName))
		{
			SendDlgItemMessage(hwnd, IDC_MAIN_STATUS, SB_SETTEXT, 0, (LPARAM)"Saved...");
			SendDlgItemMessage(hwnd, IDC_MAIN_STATUS, SB_SETTEXT, 1, (LPARAM)szFileName);
		}
	}
}
BOOL CALLBACK DlgProc(HWND hwnd, UINT Message, WPARAM wParam, LPARAM lParam)
{
    switch(Message)
    {
        case WM_INITDIALOG:
            // This is where we set up the dialog box, and initialise any default values

            SetDlgItemText(hwnd, IDC_TEXT, "This is a string");
            SetDlgItemInt(hwnd, IDC_NUMBER, 5, FALSE);
            break;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case IDC_ADD:
                {
                    // When somebody clicks the Add button, first we get the number of
                    // they entered

                    BOOL bSuccess;
                    int nTimes = GetDlgItemInt(hwnd, IDC_NUMBER, &bSuccess, FALSE);
                    if(bSuccess)
                    {
                        // Then we get the string they entered
                        // First we need to find out how long it is so that we can
                        // allocate some memory

                        int len = GetWindowTextLength(GetDlgItem(hwnd, IDC_TEXT));
                        if(len > 0)
                        {
                            // Now we allocate, and get the string into our buffer

                            int i;
                            char* buf;

                            buf = (char*)GlobalAlloc(GPTR, len + 1);
                            GetDlgItemText(hwnd, IDC_TEXT, buf, len + 1);

                            // Now we add the string to the list box however many times
                            // the user asked us to.

                            for(i = 0;i < nTimes; i++)
                            {
                                int index = SendDlgItemMessage(hwnd, IDC_LIST, LB_ADDSTRING, 0, (LPARAM)buf);

                                // Here we are associating the value nTimes with the item
                                // just for the heck of it, we'll use it to display later.
                                // Normally you would put some more useful data here, such
                                // as a pointer.
                                SendDlgItemMessage(hwnd, IDC_LIST, LB_SETITEMDATA, (WPARAM)index, (LPARAM)nTimes);
                            }

                            // Dont' forget to free the memory!
                            GlobalFree((HANDLE)buf);
                        }
                        else
                        {
                            MessageBox(hwnd, "You didn't enter anything!", "Warning", MB_OK);
                        }
                    }
                    else
                    {
                        MessageBox(hwnd, "Couldn't translate that number :(", "Warning", MB_OK);
                    }

                }
                    break;
                case IDC_REMOVE:
                {
                    // When the user clicks the Remove button, we first get the number
                    // of selected items

                    HWND hList = GetDlgItem(hwnd, IDC_LIST);
                    int count = SendMessage(hList, LB_GETSELCOUNT, 0, 0);
                    if(count != LB_ERR)
                    {
                        if(count != 0)
                        {
                            // And then allocate room to store the list of selected items.

                            int i;
                            int *buf = (int*)GlobalAlloc(GPTR, sizeof(int) * count);
                            SendMessage(hList, LB_GETSELITEMS, (WPARAM)count, (LPARAM)buf);

                            // Now we loop through the list and remove each item that was
                            // selected.

                            // WARNING!!!
                            // We loop backwards, because if we removed items
                            // from top to bottom, it would change the indexes of the other
                            // items!!!

                            for(i = count - 1; i >= 0; i--)
                            {
                                SendMessage(hList, LB_DELETESTRING, (WPARAM)buf[i], 0);
                            }

                            GlobalFree(buf);
                        }
                        else
                        {
                            MessageBox(hwnd, "No items selected.", "Warning", MB_OK);
                        }
                    }
                    else
                    {
                        MessageBox(hwnd, "Error counting items :(", "Warning", MB_OK);
                    }
                }
                    break;
                case IDC_CLEAR:
                    SendDlgItemMessage(hwnd, IDC_LIST, LB_RESETCONTENT, 0, 0);
                    break;
                case IDC_LIST:
                    switch(HIWORD(wParam))
                    {
                        case LBN_SELCHANGE:
                        {
                            // Get the number of items selected.

                            HWND hList = GetDlgItem(hwnd, IDC_LIST);
                            int count = SendMessage(hList, LB_GETSELCOUNT, 0, 0);
                            if(count != LB_ERR)
                            {
                                // We only want to continue if one and only one item is
                                // selected.

                                if(count == 1)
                                {
                                    // Since we know ahead of time we're only getting one
                                    // index, there's no need to allocate an array.

                                    int index;
                                    int err = SendMessage(hList, LB_GETSELITEMS, (WPARAM)1, (LPARAM)&index);
                                    if(err != LB_ERR)
                                    {
                                        // Get the data we associated with the item above
                                        // (the number of times it was added)

                                        int data = SendMessage(hList, LB_GETITEMDATA, (WPARAM)index, 0);

                                        SetDlgItemInt(hwnd, IDC_SHOWCOUNT, data, FALSE);
                                    }
                                    else
                                    {
                                        MessageBox(hwnd, "Error getting selected item :(", "Warning", MB_OK);
                                    }
                                }
                                else
                                {
                                    // No items selected, or more than one
                                    // Either way, we aren't going to process this.
                                    SetDlgItemText(hwnd, IDC_SHOWCOUNT, "-");
                                }
                            }
                            else
                            {
                                MessageBox(hwnd, "Error counting items :(", "Warning", MB_OK);
                            }
                        }
                            break;
                    }
                    break;
            }
            break;
        case WM_CLOSE:
            EndDialog(hwnd, 0);
            break;
        default:
            return FALSE;
    }
    return TRUE;
}
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)
	{
        case WM_INITDIALOG:
            // This is where we set up the dialog box, and initialise any default values

            SetDlgItemText(hwnd, IDC_TEXT, "This is a string");
            SetDlgItemInt(hwnd, IDC_NUMBER, 5, FALSE);
            break;
		case WM_CREATE:
		{
			HFONT hfDefault;
			HWND hEdit;

			HWND hTool;
			TBBUTTON tbb[3];
			TBADDBITMAP tbab;

			HWND hStatus;
			int statwidths[] = {100, -1};

			//Create Edit Control

			hEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "", 
				WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL, 
				0, 0, 100, 100, hwnd, (HMENU)IDC_MAIN_EDIT, GetModuleHandle(NULL), NULL);
			if(hEdit == NULL)
				MessageBox(hwnd, "Could not create edit box.", "Error", MB_OK | MB_ICONERROR);

			hfDefault = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
			SendMessage(hEdit, WM_SETFONT, (WPARAM)hfDefault, MAKELPARAM(FALSE, 0));



            /* Create Edit Control

            hEdit = CreateWindowEx(WS_EX_CLIENTEDGE, "EDIT", "",
                WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL,
                0, 0, 100, 100, hwnd, (HMENU)IDC_MAIN_EDIT, GetModuleHandle(NULL), NULL);
            if(hEdit == NULL)
                MessageBox(hwnd, "Could not create edit box.", "Error", MB_OK | MB_ICONERROR);

            hfDefault = (HFONT)GetStockObject(DEFAULT_GUI_FONT);
            SendMessage(hEdit, WM_SETFONT, (WPARAM)hfDefault, MAKELPARAM(FALSE, 0));

            */

			// Create Toolbar

			hTool = CreateWindowEx(0, TOOLBARCLASSNAME, NULL, WS_CHILD | WS_VISIBLE, 0, 0, 0, 0,
				hwnd, (HMENU)IDC_MAIN_TOOL, GetModuleHandle(NULL), NULL);
			if(hTool == NULL)
				MessageBox(hwnd, "Could not create tool bar.", "Error", MB_OK | MB_ICONERROR);


            /*if(hList == NULL)
              MessageBox(hwnd, "Could not create programs list.", "Error", MB_OK | MB_ICONERROR);
                  */

			// Send the TB_BUTTONSTRUCTSIZE message, which is required for
			// backward compatibility.
			SendMessage(hTool, TB_BUTTONSTRUCTSIZE, (WPARAM)sizeof(TBBUTTON), 0);
			
			tbab.hInst = HINST_COMMCTRL;
			tbab.nID = IDB_STD_SMALL_COLOR;
			SendMessage(hTool, TB_ADDBITMAP, 0, (LPARAM)&tbab);

			ZeroMemory(tbb, sizeof(tbb));
			tbb[0].iBitmap = STD_FILENEW;
			tbb[0].fsState = TBSTATE_ENABLED;
			tbb[0].fsStyle = TBSTYLE_BUTTON;
			tbb[0].idCommand = ID_FILE_NEW;

			tbb[1].iBitmap = STD_FILEOPEN;
			tbb[1].fsState = TBSTATE_ENABLED;
			tbb[1].fsStyle = TBSTYLE_BUTTON;
			tbb[1].idCommand = ID_FILE_OPEN;

			tbb[2].iBitmap = STD_FILESAVE;
			tbb[2].fsState = TBSTATE_ENABLED;
			tbb[2].fsStyle = TBSTYLE_BUTTON;
			tbb[2].idCommand = ID_FILE_SAVEAS;

			SendMessage(hTool, TB_ADDBUTTONS, sizeof(tbb)/sizeof(TBBUTTON), (LPARAM)&tbb);



			SendMessage(hStatus, SB_SETPARTS, sizeof(statwidths)/sizeof(int), (LPARAM)statwidths);
			SendMessage(hStatus, SB_SETTEXT, 0, (LPARAM)"Hi there :)");
		}
           /* //Make the programs list
            HWND hList;
            //                    return DialogBox(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, DlgProc);
            hList = DialogBox(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, DlgProc);
            */
           
            break;
		case WM_SIZE:
		{
			HWND hTool;
			RECT rcTool;
			int iToolHeight;

			HWND hStatus;
			RECT rcStatus;
			int iStatusHeight;

			HWND hEdit;
			int iEditHeight;
			RECT rcClient;

			// Size toolbar and get height

			hTool = GetDlgItem(hwnd, IDC_MAIN_TOOL);
			SendMessage(hTool, TB_AUTOSIZE, 0, 0);

			GetWindowRect(hTool, &rcTool);
			iToolHeight = rcTool.bottom - rcTool.top;

			// Size status bar and get height

			hStatus = GetDlgItem(hwnd, IDC_MAIN_STATUS);
			SendMessage(hStatus, WM_SIZE, 0, 0);

			GetWindowRect(hStatus, &rcStatus);
			iStatusHeight = rcStatus.bottom - rcStatus.top;

			// Calculate remaining height and size edit

			GetClientRect(hwnd, &rcClient);

			iEditHeight = rcClient.bottom - iToolHeight - iStatusHeight;

			hEdit = GetDlgItem(hwnd, IDC_MAIN_EDIT);
			SetWindowPos(hEdit, NULL, 0, iToolHeight, rcClient.right, iEditHeight, SWP_NOZORDER);
		}
		break;
		case WM_CLOSE:
			DestroyWindow(hwnd);
		break;
		case WM_DESTROY:
			PostQuitMessage(0);
		break;
		case WM_COMMAND:
			switch(LOWORD(wParam))
			{
				case ID_FILE_EXIT:
					PostMessage(hwnd, WM_CLOSE, 0, 0);
				break;
				case ID_FILE_NEW:
					SetDlgItemText(hwnd, IDC_MAIN_EDIT, "");
				break;
				case ID_FILE_OPEN:
					DoFileOpen(hwnd);
				break;
				case ID_FILE_SAVEAS:
                    return DialogBox(hInstance, MAKEINTRESOURCE(IDD_MAIN), NULL, DlgProc);
                    ;
				break;
			}
		break;
		default:
			return DefWindowProc(hwnd, msg, wParam, lParam);
	}
	return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
	LPSTR lpCmdLine, int nCmdShow)
{
	WNDCLASSEX wc;
	HWND hwnd;
	MSG Msg;



	wc.cbSize		 = sizeof(WNDCLASSEX);
	wc.style		 = 0;
	wc.lpfnWndProc	 = WndProc;
	wc.cbClsExtra	 = 0;
	wc.cbWndExtra	 = 0;
	wc.hInstance	 = hInstance;
	wc.hIcon		 = LoadIcon(NULL, IDI_APPLICATION);
	wc.hCursor		 = LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
	wc.lpszMenuName  = MAKEINTRESOURCE(IDR_MAINMENU);
	wc.lpszClassName = g_szClassName;
	wc.hIconSm		 = LoadIcon(NULL, IDI_APPLICATION);


    if(!RegisterClassEx(&wc))
	{
		MessageBox(NULL, "Window Registration Failed!", "Error!",
			MB_ICONEXCLAMATION | MB_OK);
		return 0;
	}

	hwnd = CreateWindowEx(
		0,
		g_szClassName,
		"theForger's Tutorial Application",
		WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN,
		CW_USEDEFAULT, CW_USEDEFAULT, 480, 320,
		NULL, NULL, hInstance, NULL);

	if(hwnd == NULL)
	{
		MessageBox(NULL, "Window Creation Failed!", "Error!",
			MB_ICONEXCLAMATION | MB_OK);
		return 0;
	}

	ShowWindow(hwnd, nCmdShow);
	UpdateWindow(hwnd);

	while(GetMessage(&Msg, NULL, 0, 0) > 0)
	{
		TranslateMessage(&Msg);
		DispatchMessage(&Msg);
	}

	return Msg.wParam;
}

