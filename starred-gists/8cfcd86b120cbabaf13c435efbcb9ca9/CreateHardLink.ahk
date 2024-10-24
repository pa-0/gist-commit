
; Version: 2023.05.22.2
; https://gist.github.com/8809edd5a0f212ecec688141da590a24

/*
now := A_Now
file := A_Desktop "\file." now ".txt"
link := A_Desktop "\link." now ".txt"
FileOpen(file, 0x1).Write("Hello World!")
created := CreateHardLink(link, file)
if (created)
    RunWait % link
else
    MsgBox 0x40010, Error, Error while creating the link.
FileDelete % A_Desktop "\*." now ".txt"
*/

CreateHardLink(Link, Target) {
    if (FileExist(Link)) {
        ErrorLevel := -1
        return false ; Link already exists
    }
    attributes := FileExist(Target)
    if (!attributes) {
        ErrorLevel := -2
        return false ; Target doesn't exist
    }
    if (InStr(attributes, "D")) {
        ErrorLevel := -3
        return false ; Not a file
    }
    loop Files, % Target, F
        Target := A_LoopFileLongPath
    if (SubStr(Link, 2, 1) = ":") {
        if (SubStr(Link, 1, 1) != SubStr(Target, 1, 1)) {
            ErrorLevel := -4
            return false ; Not in the same drive
        }
        Link := "\\?\" Link
    }
    Target := "\\?\" Target
    success := DllCall("CreateHardLink", "Ptr", &Link, "Ptr", &Target, "Ptr", 0, "Int")
    ErrorLevel := !success
    return success
}
