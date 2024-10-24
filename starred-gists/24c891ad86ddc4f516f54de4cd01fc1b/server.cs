using System.Net;

namespace TestHttpServer
{
    class Program
    {
        static void Main(string[] args)
        {
            using(var s = new HttpListener()){
                s.Prefixes.Add("http://localhost:65432/wat/");
                s.Start();
                var c = s.GetContext();
                c.Response.Close(System.Text.UTF8Encoding.UTF8.GetBytes("Hiya mister " + c.Request.Headers["User-Agent"]), true);
            }
        }
    }
}
