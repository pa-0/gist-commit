/*
in your code, add this to read resource and write it as a new file :
*/

string tempExeName = Path.Combine(Directory.GetCurrentDirectory(), "FILE_NAME.exe");

    using(FileStream fsDst = new FileStream(tempExeName,FileMode.CreateNew,FileAccess.Write))
    {
        byte[] bytes = Resource1.GetSubExe();

        fsDst.Write(bytes, 0, bytes.Length);
    }    

