//Display 'Open File' dialog-box
BOOL OpenFileDialog(LPSTR lpFilename)
{
	OPENFILENAME of;
	char szFilter[] = "Music Files (*.ogg)\0*.ogg\0Image Files (*.png)\0*.png\0All files (*.*)\0*.*\0\0";
	char szFile[MAX_PATH] = "\0";
	char szTitle[] = "Select a file";
	char szExt[] = "ogg";

	of.lStructSize = sizeof(of);
	of.hwndOwner = hMainDlg;
	of.lpstrFilter = szFilter;
	of.lpstrCustomFilter = NULL;
	of.nFilterIndex = 0;
	of.lpstrFile = szFile;
	of.nMaxFile = MAX_PATH;
	of.lpstrFileTitle = NULL;
	of.lpstrInitialDir = NULL;
	of.lpstrTitle = szTitle;
	of.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_PATHMUSTEXIST;
	of.lpstrDefExt = szExt;
	
	if (!GetOpenFileName(&of))
	    return FALSE;
    
	strcpy(lpFilename, of.lpstrFile); 
	return TRUE;
}


void Open(HWND hwndDlg)
{
	char szFilename[MAX_PATH];

	//Display open file dialog-box
	if (OpenFileDialog(szFilename))
	{
		//Load the file that the user selected.
		do_something(szFilename);
		
		// OpenFileForRead (Windows mode)
		//CreateFile(lpszFilename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
	}
}