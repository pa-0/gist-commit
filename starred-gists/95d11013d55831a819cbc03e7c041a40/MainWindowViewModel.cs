using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace TaskManagementRevised.ViewModels
{
     // the main view model that creates the other view models on application start
     // via this view model, the rest of the view models can be accessed via data binding in the app view XAML layout
    public class MainWindowViewModel : INotifyPropertyChanged
    {
        public MainWindowViewModel() { }
        
        //the view model for the main goal overview
        public GoalOverviewViewModel GoalViewModel { get; } = new GoalOverviewViewModel();
        
        //the view model for the tasklist overviews
        public DailyTasksViewModel TaskListViewModel { get; } = new DailyTasksViewModel();
        public DailyTasksViewModel ShoppingListViewModel { get; } = new DailyTasksViewModel();
        public DailyTasksViewModel CustomListViewModel { get; } = new DailyTasksViewModel();
        
        //the view models for the views where goals are shown by priority (high or urgent)
        public PrioritiesViewModel HighUrgentViewModel { get; } = new PrioritiesViewModel();
        public PrioritiesViewModel HighNotUrgentViewModel { get; } = new PrioritiesViewModel();
        public PrioritiesViewModel LowUrgentViewModel { get; } = new PrioritiesViewModel();
        public PrioritiesViewModel LowNotUrgentViewModel { get; } = new PrioritiesViewModel();
        
        //the view model for the overview that displays the long term goals set by the user
        public LongTermViewModel LongTermViewModel { get; } = new LongTermViewModel();
        
        //the view model for the application theme, which can be changed by the user
        public ThemeViewModel ThemeViewModel { get; } = new ThemeViewModel();

        //implementation of the INotifyPropertyChanged interface
        public event PropertyChangedEventHandler PropertyChanged;
        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

    }
}