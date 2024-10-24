/*
First add the embeded executable file as resource file to your existing resource file (add existing item to your project, and select resource file)
When you add the executable file in resource editor page, select type as [Files], then find your embeded excutable file and add it.
For example the file named as "subexe.exe", then the [resource design cs] file will have following code added:
{automatically of course)
*/

internal static byte[] SubExe {
        get {
            object obj = ResourceManager.GetObject("SubExe", resourceCulture);
            return ((byte[])(obj));
        }
    }


/*
and after that
add a method to access to your resource
just add following code to your (resource designer cs) file !
" may be found under properties > Resources.resx > Resources.Designer.cs "
*/
// add this function :
public static byte[] GetSubExe()
    {
        return SubExe;
    }
