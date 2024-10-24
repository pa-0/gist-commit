using System;
using System.Data.SQLite;
using System.Runtime.Remoting.Metadata.W3cXsd2001;

namespace TaskManagementRevised.Database
{
    public static class DatabaseAddGoals
    {

        static string connectionString;
        //the connection path to the database is retrieved from DatabaseMain.cs
        static DatabaseAddGoals()
        {
            connectionString = DatabaseMain.GetConnectionString();
        }
        
        //for testing purposes - clears the database table with the user goals
        public static void ClearTable(string tableName)
        {
            string insertQuery = $"DELETE FROM @tableName;";
            SQLiteCommand command = new SQLiteCommand(insertQuery);
            command.Parameters.AddWithValue("@tableName", tableName);
            using (SQLiteConnection connection = new SQLiteConnection(connectionString))
            {
                connection.Open();
                {
                    command.Connection = connection;
                    command.ExecuteNonQuery();
                }
            }
        } //for debugging purposes

        //returns the goal ID from the database, so that the created subgoal can have the same goal ID and we can identify its parent goal
        private static int ReturnGoalIDForSubGoal(string goalName)
        {
            string insertQuery = $"SELECT GoalKey FROM table_goals WHERE GoalName = @goalName;";
            SQLiteCommand command = new SQLiteCommand(insertQuery);
            command.Parameters.AddWithValue("@goalName", goalName);
            using (SQLiteConnection connection = new SQLiteConnection(connectionString))
            {
                connection.Open();
                {
                    using (command)
                    {
                        command.Connection = connection;
                        return Convert.ToInt32(command.ExecuteScalar());
                    }
                }
            }
        }

        //creates a new subgoal 
        public static void AddSubGoalToGoal(string goalName, int priority, string subgoalName, string subgoalDetails,
            int iconIndex, string subgoalDeadline, bool isChecked, int progressPercent)
        {
            int goalID = ReturnGoalIDForSubGoal(goalName);
            AddEntryToSubGoals(priority, subgoalName, subgoalDetails, iconIndex, subgoalDeadline, isChecked, progressPercent, goalID);
        }

        //creates a new second-level subgoal
        public static void AddSubGoal2ndLevel(string subgoalName, int priority, string subgoal2Name, string subgoal2Details,
            int iconIndex, string subgoal2Deadline, bool isChecked, int progressPercent)
        {
            int[] searchResult = ExecuteReaderForAddingSubGoals(subgoalName);
            int goalID = searchResult[0];
            int subgoalID = searchResult[1];
            AddEntryToSubGoals2(priority, subgoal2Name, subgoal2Details, iconIndex, subgoal2Deadline, isChecked, progressPercent, goalID, subgoalID);
        }
        
        //executes a reader to return specific results from the database
        private static int[] ExecuteReaderForAddingSubGoals(string subgoalName)
        {
            int[] result = new int[2];
            string insertQuery = $"SELECT SubGoalKey, GoalID FROM table_subgoals WHERE GoalName = @subGoalName;";
            using (SQLiteConnection connection = new SQLiteConnection(connectionString))
            {
                connection.Open();
                using (SQLiteCommand insertCommand = new SQLiteCommand(insertQuery, connection))
                {
                    insertCommand.Connection = connection;
                    insertCommand.Parameters.AddWithValue("@subgoalName", subgoalName);
                    using (SQLiteDataReader reader = insertCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            result[0] = Convert.ToInt32(reader["SubGoalKey"].ToString());
                            result[1] = Convert.ToInt32(reader["GoalID"].ToString());
                        }
                    }
                }
            }
            return result;
        }

        //adds to the goals table
        public static void AddEntryToGoals(int priority, string goalName, string goalDetails, 
            int iconIndex, string goalDeadline, bool isChecked, int progressPercent)
        {
            string insertQuery = $"INSERT INTO table_goals (Priority, GoalName, GoalDetails, IconIndex, GoalDeadline, IsChecked, ProgressPercent) " +
                $"VALUES (@Value1, @Value2, @Value3, @Value4, @Value5, @Value6, @Value7);";
            using (SQLiteConnection connection = new SQLiteConnection(connectionString))
            {
                connection.Open();
                using (SQLiteCommand insertCommand = new SQLiteCommand(insertQuery, connection))
                {
                    insertCommand.Parameters.AddWithValue("@Value1", priority);
                    insertCommand.Parameters.AddWithValue("@Value2", goalName);
                    insertCommand.Parameters.AddWithValue("@Value3", goalDetails);
                    insertCommand.Parameters.AddWithValue("@Value4", iconIndex);
                    insertCommand.Parameters.AddWithValue("@Value5", goalDeadline);
                    insertCommand.Parameters.AddWithValue("@Value6", Convert.ToInt32(isChecked));
                    insertCommand.Parameters.AddWithValue("@Value7", progressPercent);
                    insertCommand.ExecuteNonQuery();
                }
            }
        }

        //adds to the subgoals table
        private static void AddEntryToSubGoals(int priority, string goalName, string goalDetails,
            int iconIndex, string goalDeadline, bool isChecked, int progressPercent, int goalID)
        {
            string insertQuery = $"INSERT INTO table_subgoals (Priority, GoalName, GoalDetails, IconIndex, GoalDeadline, IsChecked, ProgressPercent, GoalID) " +
                $"VALUES (@Value1, @Value2, @Value3, @Value4, @Value5, @Value6, @Value7, @Value8);";
            using (SQLiteConnection connection = new SQLiteConnection(connectionString))
            {
                connection.Open();
                using (SQLiteCommand insertCommand = new SQLiteCommand(insertQuery, connection))
                {
                    insertCommand.Parameters.AddWithValue("@Value1", priority);
                    insertCommand.Parameters.AddWithValue("@Value2", goalName);
                    insertCommand.Parameters.AddWithValue("@Value3", goalDetails);
                    insertCommand.Parameters.AddWithValue("@Value4", iconIndex);
                    insertCommand.Parameters.AddWithValue("@Value5", goalDeadline);
                    insertCommand.Parameters.AddWithValue("@Value6", Convert.ToInt32(isChecked));
                    insertCommand.Parameters.AddWithValue("@Value7", progressPercent);
                    insertCommand.Parameters.AddWithValue("@Value8", goalID);
                    insertCommand.ExecuteNonQuery();
                }
            }
        }

        //adds to the second-level subgoals table
        private static void AddEntryToSubGoals2(int priority, string goalName, string goalDetails,
            int iconIndex, string goalDeadline, bool isChecked, int progressPercent, int goalID, int subGoalID)
        {
            string insertQuery = $"INSERT INTO table_subgoals2 (Priority, GoalName, GoalDetails, IconIndex, GoalDeadline, IsChecked, ProgressPercent, GoalID, SubGoalID) " +
                $"VALUES (@Value1, @Value2, @Value3, @Value4, @Value5, @Value6, @Value7, @Value8, @Value9);";
            using (SQLiteConnection connection = new SQLiteConnection(connectionString))
            {
                connection.Open();
                using (SQLiteCommand insertCommand = new SQLiteCommand(insertQuery, connection))
                {
                    insertCommand.Parameters.AddWithValue("@Value1", priority);
                    insertCommand.Parameters.AddWithValue("@Value2", goalName);
                    insertCommand.Parameters.AddWithValue("@Value3", goalDetails);
                    insertCommand.Parameters.AddWithValue("@Value4", iconIndex);
                    insertCommand.Parameters.AddWithValue("@Value5", goalDeadline);
                    insertCommand.Parameters.AddWithValue("@Value6", Convert.ToInt32(isChecked));
                    insertCommand.Parameters.AddWithValue("@Value7", progressPercent);
                    insertCommand.Parameters.AddWithValue("@Value8", goalID);
                    insertCommand.Parameters.AddWithValue("@Value9", subGoalID);
                    insertCommand.ExecuteNonQuery();
                }
            }
        }

    }
}