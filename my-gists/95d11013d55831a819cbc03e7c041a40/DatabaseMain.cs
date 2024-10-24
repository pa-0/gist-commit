using System;

namespace TaskManagementRevised.Database
{
    internal class DatabaseMain
    {
        // returns the connection path so that the rest of the database files can open connections to the database
        static string dbPath = Environment.CurrentDirectory;
        static string dbFilePath = "/Database/Database.db";

        private DatabaseMain() { }

        private static string CreateConnectionString()
        {
            return string.Format("Data Source={0};", dbPath + dbFilePath);
        }

        public static string GetConnectionString()
        {
            return CreateConnectionString();
        }
    }
}