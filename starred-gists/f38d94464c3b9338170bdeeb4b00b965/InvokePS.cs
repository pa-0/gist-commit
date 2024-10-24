private static void InvokePowerShell(IDictionary<string, object> env, StreamWriter w)
        {
            string req = env["owin.RequestQueryString"] as string;
            var queryParts = HttpUtility.ParseQueryString(req);

            var powerShellFilename = queryParts[null] + ".ps1";

            if (File.Exists(powerShellFilename))
            {
                var script = File.ReadAllText(powerShellFilename);

                var ps = PowerShell
                    .Create()
                    .AddScript(script);

                foreach (string item in queryParts)
                {
                    if (item != null)
                    {
                        ps.AddParameter(item, queryParts[item]);
                    }
                }

                ps.AddCommand("Out-String");

                foreach (var item in ps.Invoke())
                {
                    w.Write(item);
                }
            }
            else
            {
                w.Write(string.Format("{0} not found, cannot execute", powerShellFilename));
            }
        }