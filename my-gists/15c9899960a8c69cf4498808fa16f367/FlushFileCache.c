// clang.exe -Os -nostdlib -fuse-ld=lld -Wl,-fixed,-subsystem:console FlushFileCache.c -o FlushFileCache.exe

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#pragma comment (lib, "kernel32.lib")
#pragma comment (lib, "advapi32.lib")

#define error(str) do { DWORD written; WriteFile(GetStdHandle(STD_ERROR_HANDLE), str, sizeof(str)-1, &written, NULL); } while (0)

static BOOL SetPrivilege(LPCSTR name)
{
	BOOL result = FALSE;

	HANDLE token;
	if (OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &token))
	{
		LUID luid;
		if (LookupPrivilegeValueA(NULL, name, &luid))
		{
			TOKEN_PRIVILEGES tp =
			{
				.PrivilegeCount = 1,
				.Privileges[0].Luid = luid,
				.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED,
			};
			if (AdjustTokenPrivileges(token, FALSE, &tp, sizeof(tp), NULL, NULL))
			{
				result = TRUE;
			}
		}
		CloseHandle(token);
	}
	return result;
}

int mainCRTStartup(void)
{
	if (!SetPrivilege(SE_INCREASE_QUOTA_NAME))
	{
		error("Cannot set needed privilege!\n");
		return 1;
	}

	if (!SetSystemFileCacheSize((SIZE_T)-1, (SIZE_T)-1, 0))
	{
		DWORD err = GetLastError();
		if (err == ERROR_ACCESS_DENIED)
		{
			error("Access denied! Is process elevated?\n");
		}
		else
		{
			error("SetSystemFileCacheSize failed!\n");
		}
		return 1;
	}

	return 0;
}
