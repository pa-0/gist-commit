if !ClipWait(2)
{
    Notify.Default.GenSound := "Error"
    Notify.show('The attempt to copy text onto the clipboard failed.')
    sleep 3000
    Exitapp
}