using System.Diagnostics;
using Microsoft.Build.Tasks;

namespace MsBuild
{
    public class RunAsyncExec : Exec
    {       
        protected override int ExecuteTool(string pathToTool, string responseFileCommands, string commandLineCommands)
        {
            using (var process = new Process
            {
                StartInfo = GetProcessStartInfo(pathToTool, commandLineCommands)
            })
            {
                process.Start();
            }
                
            return 0;
        }
        
        protected virtual ProcessStartInfo GetProcessStartInfo(string executable, string arguments)
        {
            if (arguments.Length > 0x7d00)
            {
                Log.LogWarningWithCodeFromResources("ToolTask.CommandTooLong", new object[] { GetType().Name });
            }
            
            var startInfo = new ProcessStartInfo(executable, arguments)
            {
                WindowStyle = ProcessWindowStyle.Hidden,
                CreateNoWindow = true,
                UseShellExecute = true
            };

            var workingDirectory = GetWorkingDirectory();
            if (workingDirectory != null)
            {
                startInfo.WorkingDirectory = workingDirectory;
            }
            
            if (EnvironmentVariables != null)
            {                
                foreach (string entry in EnvironmentVariables)
                {
                    string[] nameValuePair = entry.Split('=');

                    if (nameValuePair.Length == 1 || nameValuePair.Length == 2 && nameValuePair[0].Length == 0)
                    {                        
                        continue;
                    }

                    startInfo.EnvironmentVariables.Remove(nameValuePair[0].ToString());
                    startInfo.EnvironmentVariables.Add(nameValuePair[0].ToString(), nameValuePair[1].ToString());                    
                }               
            }
            return startInfo;
        }       
    }
}