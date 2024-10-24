using System;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Windows.Input;
using System.Windows;

namespace TaskManagementRevised.ViewModels
{
  
    //the view model of the goal overview display
    public class GoalOverviewViewModel : INotifyPropertyChanged
    {
        //setting the permissions for the properties
        private int goalID;
        public int GoalID
        {
            get => goalID;
            set => goalID = value;
        }
        private int subgoalID;
        public int SubGoalID
        {
            get => subgoalID;
            set => subgoalID = value;
        }
        private int subgoal2ID;
        public int SubGoal2ID
        {
            get => subgoal2ID;
            set => subgoal2ID = value;
        }
        private string name;
        public string Name
        {
            get => name;
            set
            {
                name = value;
                OnPropertyChanged();
            }
        }
        private string details;
        public string Details
        {
            get => details;
            set
            {
                details = value;
                OnPropertyChanged();
            }
        }
        private DateTime? deadline;
        public DateTime? Deadline
        {
            get => deadline;
            set
            {
                deadline = value;
                OnPropertyChanged();
            }
        }
        private int priority;
        public int Priority
        {
            get => priority;
            set
            {
                priority = value;
                OnPropertyChanged();
            }
        }
        private bool isChecked;
        public bool IsChecked
        {
            get => isChecked;
            set
            {
                isChecked = value;
                OnPropertyChanged();
            }
        }
        private Uri image;
        public Uri Image
        {
            get => image;
            set
            {
                image = value;
                OnPropertyChanged();
            }
        }
        
        //initiating the view model commands
        public GoalOverviewViewModel()
        {
            AddItemCommand = new RelayCommand(AddItem);
            RemoveItemCommand = new RelayCommand(RemoveItem);
            SelectItemChangedCommand = new RelayCommand(SelectItemChanged);
        }
        
        //the selected goal of the overview at any time
        private GoalOverviewViewModel _singleGoal;
        public GoalOverviewViewModel SingleGoal
        {
            get { return _singleGoal; }
            set
            {
                _singleGoal = value;
                OnPropertyChanged(nameof(SingleGoal));
            }
        }

        //the ObservableCollection of items that will be filled with instances of the view model 
        private readonly ObservableCollection<GoalOverviewViewModel> _items = new ObservableCollection<GoalOverviewViewModel>();
        public ObservableCollection<GoalOverviewViewModel> Items
        {
            get { return _items; }
        }

        //commands to add/remove/change the selected item
        public ICommand AddItemCommand { get; set; }
        public ICommand RemoveItemCommand { get; set; }
        public ICommand SelectItemChangedCommand { get; set; }

        //when the selected item is changed
        void SelectItemChanged(object parameter)
        {
            if (parameter is GoalOverviewViewModel singleGoal)
            {
                SingleGoal = singleGoal;
                MessageBox.Show(singleGoal.Name);
            }

        }
        
        //when an item is added
        public void AddItem(object parameter)
        {
            if (parameter is GoalOverviewViewModel singleGoal)
            {
                Items.Add(singleGoal);
                OnPropertyChanged(nameof(Items));
            }
        }

        //when an item is removed
        void RemoveItem(object parameter)
        {
            if (parameter is GoalOverviewViewModel singleGoal)
            {
                Items.Remove(singleGoal);
                OnPropertyChanged(nameof (Items));
            }
        }
        
        //implementation of the INotifyPropertyChanged interface
        public event PropertyChangedEventHandler PropertyChanged;
        protected virtual void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

}