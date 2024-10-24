#include <windows.h>
#include <stdio.h>

// Get Current Folder
void GetFolder(char *folderName)
{
    GetModuleFileName(GetModuleHandle(NULL), folderName, MAX_PATH);
    *(strrchr(folderName, '\\')) = 0;
}

// Example
int main()
{
	char folderName[MAX_PATH];
	GetFolder(folderName);
	printf("%s\n", folderName);
	return 0;
}