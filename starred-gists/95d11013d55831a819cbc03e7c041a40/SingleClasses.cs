using System.Threading.Tasks;
using System.Windows.Controls;

namespace TaskManagementRevised
{

    //the class goal that holds the goal data in the communication between the database and the view model
    public class Goal
    {
        public Goal()
        {
            Priority = -1;
        }
        public int GoalID { get => goalID; set => goalID = value; }
        public int GoalLevel { get => goalLevel; set => goalLevel = value; }
        public int Priority { get => priority; set => priority = value; }
        public string GoalName { get => goalName; set => goalName = value; }
        public string GoalDetails { get => goalDetails; set => goalDetails = value; }
        public int IconIndex { get => iconIndex; set => iconIndex = value; }
        public List<SubGoal> SubGoals { get => subGoals; set => subGoals = value; }
        public DateTime GoalDeadline { get => goalDeadline; set => goalDeadline = value; }
        public bool IsChecked { get => isChecked; set => isChecked = value; }
        public int ProgressPercent { get => progressPercent; set => progressPercent = value; }


        private int goalID;
        private int goalLevel;
        private int priority = -1;
        private string goalName;
        private string goalDetails;
        private int iconIndex;
        private List<SubGoal> subGoals = new List<SubGoal>();
        private DateTime goalDeadline;
        private bool isChecked;
        private int progressPercent;

    }

    //the class for the first-level subgoals, inheriting from Goal
    public class SubGoal : Goal
    {
        private int subGoalID;
        public int SubGoalID { get => subGoalID; set => subGoalID = value; } 
        private List<SubGoal2> subgoals = new List<SubGoal2>();
        public new List<SubGoal2> SubGoals { get => subgoals; set => subgoals = value; }
    }

    //the class for the second-level subgoals, inheriting from Subgoal
    public class SubGoal2 : SubGoal
    {
        private int subGoal2ID;
        public int SubGoal2ID { get => subGoal2ID; set => subGoal2ID = value; }
    }
}