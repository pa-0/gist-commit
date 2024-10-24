#include<windows.h>
#include<iostream>

using namespace std;

// Example of file explorer
int main()
{
    WIN32_FIND_DATA FindFileData;
    HANDLE hFind;
    hFind = FindFirstFile("C:\\*", &FindFileData);

    if (hFind == INVALID_HANDLE_VALUE)
    {
        cout << "FindFirstFile failed: " << GetLastError() << endl;
        return 1;
    }

    do cout << FindFileData.cFileName << endl;
    while (FindNextFile(hFind, &FindFileData));

    FindClose(hFind);
    return 0;
}


// Example Function: Change File Attributes
BOOL remove_ro_attr(TCHAR *file)
{
    /*
    FILE_ATTRIBUTE_ARCHIVE
    FILE_ATTRIBUTE_HIDDEN
    FILE_ATTRIBUTE_NORMAL
    FILE_ATTRIBUTE_NOT_CONTENT_INDEXED
    FILE_ATTRIBUTE_OFFLINE
    FILE_ATTRIBUTE_READONLY
    FILE_ATTRIBUTE_SYSTEM
    FILE_ATTRIBUTE_TEMPORARY
    */
    
    int attr = GetFileAttributes(file);
    if (attr == INVALID_FILE_ATTRIBUTES)
        return FALSE;

    return SetFileAttributes(file, attr & (~FILE_ATTRIBUTE_READONLY));
}

// return NULL if the file does not exist.
WIN32_FIND_DATA* file_exists(TCHAR *filename)
{
    static WIN32_FIND_DATA FindFileData;
    
    HANDLE hFind  = FindFirstFile(filename, &FindFileData);
    if (hFind  == INVALID_HANDLE_VALUE)
        return NULL;

    FindClose(hFind);
    return &FindFileData;
}
