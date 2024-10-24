;@Ahk2Exe-ConsoleApp

/************************************************************************
 * Enumerate and invoke commands from the shellex context menu.
 *
 * 1) Install AutoHotkey v2.
 * https://www.autohotkey.com/download/ahk-v2.exe
 *
 * 2) Compile this script: Right click → Show more options → Compile script.
 * 3) Run 'shellex.exe' from the command prompt (cmd.exe) to see the help.
 ***********************************************************************/

#Requires AutoHotkey v2.0.18

OnError(HandleOnError)

IID_IShellFolder := '{000214E6-0000-0000-C000-000000000046}'
IID_IDataObject := '{0000010E-0000-0000-C000-000000000046}'
IID_IContextMenu := '{000214E4-0000-0000-C000-000000000046}'
IID_IShellExtInit := '{000214E8-0000-0000-C000-000000000046}'
IID_IClassFactory := '{00000001-0000-0000-C000-000000000046}'
IID_IQueryAssociations := '{C46CA590-3C3F-11D2-BEE6-0000F805CA57}'

IID_I7Zip := '{23170F69-40C1-278A-1000-000100020000}'
IID_IWinRar := '{B41DB860-64E4-11D2-9906-E49FADC173CA}'
; IID_IMicrosoftDefender := '{09A47860-11B0-4DA5-AFA5-26D86198A780}'

SFGAO_VALIDATE := 0x01000000

; show help
if (A_Args.Length < 2) {
    print(
        'Usage:`n`n`t{}',
        'shellex.exe <path> <clsid> [verb] [dll]'
    )
    print(
        '`nExamples:`n`n`t{}`n`t{}`n`t{}`n`t{}',
        'shellex.exe %ComSpec% ' . IID_I7Zip,
        'shellex.exe %ComSpec% ' . IID_I7Zip . ' 0003',
        'shellex.exe %ComSpec% ' . IID_I7Zip . ' "" "%ProgramFiles%\7-Zip\7-zip.dll"',
        'shellex.exe %ComSpec% ' . IID_IWinRar . ' "" "%ProgramFiles%\WinRAR\RarExt.dll"'
    )
    print(
        '`nTypes:`n{}{}{}{}{}{}{}{}{}',
        '`n`t0000 MFT_STRING',
        '`n`t0004 MFT_BITMAP',
        '`n`t0020 MFT_MENUBARBREAK',
        '`n`t0040 MFT_MENUBREAK',
        '`n`t0100 MFT_OWNERDRAW',
        '`n`t0200 MFT_RADIOCHECK',
        '`n`t0800 MFT_SEPARATOR',
        '`n`t2000 MFT_RIGHTORDER',
        '`n`t4000 MFT_RIGHTJUSTIFY',
    )
    ExitApp()
}

; parameters
target := A_Args[1]
clsid := A_Args[2]
verb := A_Args.Length >= 3 ? A_Args[3] : ''
dll := A_Args.Length >= 4 ? A_Args[4] : ''

; Get the file or directory PIDL.
item := ParseDisplayName(target, SFGAO_VALIDATE)

IShellFolder := BindToParent(item, IID_IShellFolder, &PIDL_CHILD)
IDataObject := GetUIObjectOf(IShellFolder, PIDL_CHILD, IID_IDataObject)
IQueryAssociations := GetUIObjectOf(IShellFolder, PIDL_CHILD, IID_IQueryAssociations)

; IQueryAssociations::GetKey method.
; https://learn.microsoft.com/en-us/windows/win32/api/shlwapi/nf-shlwapi-iqueryassociations-getkey
ComCall(5, IQueryAssociations, 'Int', 0, 'Int', 3, 'Ptr', 0, 'PtrP', &hKey:=0)

; IShellExtInit::Initialize method.
; https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ishellextinit-initialize
IShellExtInit := dll
    ? LoadLibrary(dll, clsid)
    : ComObject(clsid, IID_IShellExtInit)
ComCall(3, IShellExtInit, 'Ptr', item, 'Ptr', IDataObject, 'Ptr', hKey)

IContextMenu := ComObjQuery(IShellExtInit, IID_IContextMenu)

print('PARENT ID   TYPE NAME')
for m in EnumerateMenus(QueryContextMenu(IContextMenu))
    print('{}   {} {} {}',
        Format('{:04X}', m.parent),
        Format('{:04X}', m.id),
        Format('{:04X}', m.type),
        m.name
    )

if (verb != '') {
    verb := IsInteger(verb) ? Number(verb) : verb
    InvokeCommand(IContextMenu, verb)
}

/**
 * Convert a string to a pointer to an item identifier list (PIDL).
 * @see https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shparsedisplayname
 */
ParseDisplayName(name, attr:=0)
{
    DllCall('shell32\SHParseDisplayName', 'Str', name, 'Ptr', 0
        , 'PtrP', &PIDL:=0, 'UInt', attr, 'Ptr', 0, 'HRESULT')
    return PIDL
}

/**
 * Get a pointer to the specified interface from a pointer to a fully qualified PIDL.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shbindtoparent
 */
BindToParent(PIDL, CLSID, &PIDL_CHILD)
{
    CLSID := CLSIDFromString(CLSID)
    DllCall('shell32\SHBindToParent', 'Ptr', PIDL, 'Ptr', CLSID
        , 'PtrP', &PTR:=0, 'PtrP', &PIDL_CHILD:=0, 'HRESULT')
    return PTR
}

/**
 * Get an object that can be used to carry out actions on the specified file objects or folders.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-ishellfolder-getuiobjectof
 */
GetUIObjectOf(obj, PIDL, CLSID)
{
    CLSID := CLSIDFromString(CLSID)
    ; Note: 'PtrP, PIDL' is an array of PIDL
    ComCall(10, obj, 'Ptr', A_ScriptHwnd, 'UInt', 1
        , 'PtrP', PIDL, 'Ptr', CLSID, 'Ptr', 0, 'PtrP', &ptr:=0)
    return ptr
}

/**
 * Add commands to a shortcut menu.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-icontextmenu-querycontextmenu
 */
QueryContextMenu(obj, _menu:=0, index:=0, min:=0, max:=0x7FFF, flags:=0x100)
{
    m := _menu ? _menu : Menu(), h := m.Handle
    ComCall(3, obj, 'Ptr', h, 'UInt', index, 'UInt', min, 'UInt', max, 'UInt', flags)
    return m
}

EnumerateMenus(menu, parent:=0, menus:=[])
{
    menu := menu is Object ? menu.Handle : menu
    MENUITEMINFO := Buffer(16+8*A_PtrSize, 0), str := Buffer(512), len := str.Size / 2
    NumPut('UInt', MENUITEMINFO.Size, MENUITEMINFO), NumPut('UInt', 0x107, MENUITEMINFO, 4)
    loop DllCall('GetMenuItemCount', 'Ptr', menu) {
        DllCall("GetMenuItemInfo", "Ptr", menu, 'UInt', A_Index-1, 'Int', true, 'Ptr', MENUITEMINFO)
        type := NumGet(MENUITEMINFO, 8, 'UInt'), id := NumGet(MENUITEMINFO, 16, 'UInt')
        submenu := NumGet(MENUITEMINFO, 16+A_PtrSize, 'Ptr')
        n := DllCall('GetMenuStringW', 'Ptr', menu, 'UInt', id, 'Ptr', str, 'Int', len, 'UInt', 0)
        info := { type: type, id: id, name: StrGet(str, n, 'UTF-16'), parent: parent }
        menus.push(info), EnumerateMenus(submenu, id, menus), DllCall('DestroyMenu', 'Ptr', submenu)
    } return menus
}

/**
 * Invoke the command associated with a shortcut menu item.
 * @see https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-icontextmenu-invokecommand
 */
InvokeCommand(obj, verb)
{
    CMINVOKECOMMANDINFO := Buffer(4*4+5*A_PtrSize, 0)
    NumPut('UInt', CMINVOKECOMMANDINFO.Size, CMINVOKECOMMANDINFO)
    if (verb is String) {
        buff := Buffer(StrPut(verb, 'CP0'))
        verb := (StrPut(verb, buff, 'CP0'), buff.Ptr)
    }
    NumPut('Ptr', verb, CMINVOKECOMMANDINFO, 8+A_PtrSize)
    ComCall(4, obj, 'Ptr', CMINVOKECOMMANDINFO)
}

; /**
;  * Get information about a shortcut menu command.
;  * @see https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-icontextmenu-getcommandstring
;  */
; GetCommandString(obj, id, type:=0)
; {
;     buff := Buffer(512, 0)
;     ; GCS_VERB = 0x0 | GCS_HELPTEXT = 0x1 | GCS_VALIDATE = 0x2 | GCS_UNICODE = 0x4
;     ComCall(5, obj, 'Ptr', id, 'UInt', type, 'Ptr', 0, 'Ptr', buff, 'UInt', buff.Size)
;     return StrGet(buff, type & 0x4 ? 'UTF-16' : 'CP0')
; }

LoadLibrary(dll, clsid)
{
    clsid := CLSIDFromString(clsid)
    CLSID_IClassFactory := CLSIDFromString(IID_IClassFactory)
    CLSID_IShellExtInit := CLSIDFromString(IID_IShellExtInit)
    if !DllCall('ole32\CoLoadLibrary', 'Str', dll, 'Int', 1, 'Ptr')
        throw OSError()
    DllCall(dll . '\DllGetClassObject', 'Ptr', clsid, 'Ptr', CLSID_IClassFactory, 'PtrP', &pFactory:=0, 'HRESULT')
    ComCall(3, pFactory, 'Ptr', 0, 'Ptr', CLSID_IShellExtInit, 'PtrP', &IShellExtInit:=0, 'HRESULT')
    return IShellExtInit
}

CLSIDFromString(str)
{
    CLSID := Buffer(16)
    DllCall('ole32\CLSIDFromString', 'Str', str, 'Ptr', CLSID, 'HRESULT')
    return CLSID
}

; CoTaskMemFree(ptr) ; for PIDL
; {
;     DllCall('ole32\CoTaskMemFree', 'Ptr', ptr)
; }

print(str:='', values*)
{
    str .= '`n'
    FileAppend(Format(str, values*), '*')
}

HandleOnError(exception, mode)
{
    FileAppend(exception.Message . '`n`n', '**')
    FileAppend(exception.Stack . '`n', '**')
    ExitApp()
}