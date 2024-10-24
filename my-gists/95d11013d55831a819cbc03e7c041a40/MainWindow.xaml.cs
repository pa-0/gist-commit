using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using TaskManagementRevised.ViewModels;
using TaskManagementRevised.Database;
using Microsoft.Win32;

namespace TaskManagementRevised
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private string _filePath;
        private FontFamily _myFontFamily;
        private bool _iconCreateGoalChanged = false;
 
        public MainWindow()
        {
            //Set the MainWindowViewModel, the parent ViewModel to the other ViewModels, as the DataContext
            //This way, we can reference the rest of the ViewModels through the DataContext
            DataContext = new MainWindowViewModel();

            InitializeComponent();

            //Initial processes
            InitCustomFont();
            ApplyCustomFont();
            
            //Set the WindowState of the window
            MaxHeight = SystemParameters.MaximizedPrimaryScreenHeight;
            WindowState = WindowState.Maximized;

            //Used to retrieve the .txt old save files -- DELETE AFTER COMPLETING THE DATABASE SETUP
            _filePath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\Task Management\";

            //Populate overviews on Load
            GetTheListGoal();
            PopulateDailyTasks();
            PopulateLongTermGoals();

            //Applies the currently selected theme -- MAKE THIS UPDATE AUTOMATICALLY VIA XAML & VIEWMODELS
            //ApplyTheme("Blue");
        }

        #region Initial Processes
        
        
        /// <summary>
        /// Initial processes necessary to ensure good presentation, take place at startup
        /// </summary>
        
        //Get the custom font family from resources
        void InitCustomFont()
        {
            foreach (FontFamily fontFamily in Fonts.GetFontFamilies(new Uri("pack://application:,,,/"), "./Resources/Fonts/"))
            {
                _myFontFamily = fontFamily;
            }
            
        }

        //Apply the custom font family to the application
        void ApplyCustomFont()
        {
            if (_myFontFamily == null)
            {
                Console.WriteLine("Null font family");
                return;
            }
            else
            {
                FontFamily = _myFontFamily;
            }
        }

       
        #endregion

        #region TreeViewModels

        /// <summary>
        /// Communication between the database and the view models
        /// </summary>

        //Retrieves the goal records from the database and creates the GoalOverviewViewModels

        void GetTheListGoal()
        {
            var listOfGoals = DatabaseRetrieveGoals.RetrieveAllGoals();
            PopulateTheGoalOverviewTreeview(listOfGoals);
            PopulatePriotities(listOfGoals);
        }

        void PopulateTheGoalOverviewTreeview(List<Goal> listOfGoals)
        {
            foreach (var goal in listOfGoals)
            {
                GoalOverviewViewModel rootGoalItem;
                if (goal.GoalDeadline == DateTime.MinValue)
                {
                    rootGoalItem = new GoalOverviewViewModel()
                    {
                        GoalID = goal.GoalID,
                        Name = goal.GoalName,
                        Details = goal.GoalDetails,
                        Deadline = null,
                        Priority = goal.Priority,
                        IsChecked = goal.IsChecked,
                        Image = new Uri(("Resources/Icons/" + "icon" + goal.IconIndex.ToString() + ".png"), UriKind.Relative)
                    };
                }
                else
                {
                    rootGoalItem = new GoalOverviewViewModel()
                    {
                        GoalID = goal.GoalID,
                        Name = goal.GoalName,
                        Details = goal.GoalDetails,
                        Deadline = goal.GoalDeadline,
                        Priority = goal.Priority,
                        IsChecked = goal.IsChecked,
                        Image = new Uri(("Resources/Icons/" + "icon" + goal.IconIndex.ToString() + ".png"), UriKind.Relative)
                    };
                }

                foreach (var subgoal in goal.SubGoals)
                {
                    GoalOverviewViewModel subGoalItem;
                    if (subgoal.GoalDeadline == DateTime.MinValue)
                    {
                        subGoalItem = new GoalOverviewViewModel()
                        {
                            GoalID = goal.GoalID,
                            SubGoalID = subgoal.SubGoalID,
                            Name = subgoal.GoalName,
                            Details = subgoal.GoalDetails,
                            Deadline = null,
                            Priority = subgoal.Priority,
                            IsChecked = subgoal.IsChecked,
                            Image = new Uri(("Resources/Icons/" + "icon" + subgoal.IconIndex.ToString() + ".png"), UriKind.Relative)
                        };
                    }
                    else
                    {
                        subGoalItem = new GoalOverviewViewModel()
                        {
                            GoalID = goal.GoalID,
                            SubGoalID = subgoal.SubGoalID,
                            Name = subgoal.GoalName,
                            Details = subgoal.GoalDetails,
                            Deadline = subgoal.GoalDeadline,
                            Priority = subgoal.Priority,
                            IsChecked = subgoal.IsChecked,
                            Image = new Uri(("Resources/Icons/" + "icon" + subgoal.IconIndex.ToString() + ".png"), UriKind.Relative)
                        };
                    }

                    foreach (var subgoal2 in subgoal.SubGoals)
                    {
                        GoalOverviewViewModel subGoal2Item;
                        if (subgoal2.GoalDeadline == DateTime.MinValue)
                        {
                            subGoal2Item = new GoalOverviewViewModel()
                            {
                                GoalID = goal.GoalID,
                                SubGoalID = subgoal2.SubGoalID,
                                SubGoal2ID = subgoal2.SubGoal2ID,
                                Name = subgoal2.GoalName,
                                Details = subgoal2.GoalDetails,
                                Deadline = null,
                                Priority = subgoal2.Priority,
                                IsChecked = subgoal2.IsChecked,
                                Image = new Uri(("Resources/Icons/" + "icon" + subgoal2.IconIndex.ToString() + ".png"), UriKind.Relative)
                            };
                        }
                        else
                        {
                            subGoal2Item = new GoalOverviewViewModel()
                            {
                                GoalID = goal.GoalID,
                                SubGoalID = subgoal2.SubGoalID,
                                SubGoal2ID = subgoal2.SubGoal2ID,
                                Name = subgoal2.GoalName,
                                Details = subgoal2.GoalDetails,
                                Deadline = subgoal2.GoalDeadline,
                                Priority = subgoal2.Priority,
                                IsChecked = subgoal2.IsChecked,
                                Image = new Uri(("Resources/Icons/" + "icon" + subgoal2.IconIndex.ToString() + ".png"), UriKind.Relative)
                            };
                        }

                        subGoalItem.Items.Add(subGoal2Item);
                    }
                    rootGoalItem.Items.Add(subGoalItem);
                }
                ((MainWindowViewModel)DataContext).GoalViewModel.AddItem(rootGoalItem);

            }
        }

        
        void PopulatePriotities(List<Goal> listOfGoals)
        {
            foreach (var goal in listOfGoals)
            {
                if (goal.SubGoals.Count == 0)
                {
                    if (goal.Priority == 0) continue;
                    PrioritiesViewModel prioritiesViewModel;
                    if ((goal.GoalDeadline == DateTime.MinValue))
                    {
                        prioritiesViewModel = new PrioritiesViewModel()
                        {
                            Name = goal.GoalName,
                            Image = new Uri(("Resources/Icons/" + "icon" + goal.IconIndex.ToString() + ".png"), UriKind.Relative),
                            Deadline = null,
                            Progress = "(" + goal.ProgressPercent.ToString() + " %)",
                        };
                    }
                    else
                    {
                        prioritiesViewModel = new PrioritiesViewModel()
                        {
                            Name = goal.GoalName,
                            Image = new Uri(("Resources/Icons/" + "icon" + goal.IconIndex.ToString() + ".png"), UriKind.Relative),
                            Deadline = goal.GoalDeadline,
                            Progress = "(" + goal.ProgressPercent.ToString() + " %)",
                        };
                    }

                    switch (goal.Priority)
                    {
                        case 0:
                            ((MainWindowViewModel)DataContext).HighUrgentViewModel.Items.Add(prioritiesViewModel);
                            break;
                        case 1:
                            ((MainWindowViewModel)DataContext).HighNotUrgentViewModel.Items.Add(prioritiesViewModel);
                            break;
                        case 2:
                            ((MainWindowViewModel)DataContext).LowUrgentViewModel.Items.Add(prioritiesViewModel);
                            break;
                        case 3:
                            ((MainWindowViewModel)DataContext).LowNotUrgentViewModel.Items.Add(prioritiesViewModel);
                            break;
                    }
                }
                else
                {
                    foreach (var subgoal in goal.SubGoals)
                    {
                        if (subgoal.Priority == 0) continue;
                        PrioritiesViewModel prioritiesViewModel;
                        if ((subgoal.GoalDeadline == DateTime.MinValue))
                        {
                            prioritiesViewModel = new PrioritiesViewModel()
                            {
                                Name = subgoal.GoalName,
                                Image = new Uri(("Resources/Icons/" + "icon" + subgoal.IconIndex.ToString() + ".png"), UriKind.Relative),
                                Deadline = null,
                                Progress = "(" + subgoal.ProgressPercent.ToString() + " %)",
                            };
                        }
                        else
                        {
                            prioritiesViewModel = new PrioritiesViewModel()
                            {
                                Name = subgoal.GoalName,
                                Image = new Uri(("Resources/Icons/" + "icon" + subgoal.IconIndex.ToString() + ".png"), UriKind.Relative),
                                Deadline = subgoal.GoalDeadline,
                                Progress = "(" + subgoal.ProgressPercent.ToString() + " %)",
                            };
                        }

                        switch (subgoal.Priority)
                        {
                            case 0:
                                ((MainWindowViewModel)DataContext).HighUrgentViewModel.Items.Add(prioritiesViewModel);
                                break;
                            case 1:
                                ((MainWindowViewModel)DataContext).HighNotUrgentViewModel.Items.Add(prioritiesViewModel);
                                break;
                            case 2:
                                ((MainWindowViewModel)DataContext).LowUrgentViewModel.Items.Add(prioritiesViewModel);
                                break;
                            case 3:
                                ((MainWindowViewModel)DataContext).LowNotUrgentViewModel.Items.Add(prioritiesViewModel);
                                break;
                        }
                    }
                }
            }
        }


        void PopulateLongTermGoals()
        {
            //Adds long term goals
            var goalList = DatabaseLongTermGoals.RetrieveFromDatabase();
            var currentTaskModel = ((MainWindowViewModel)DataContext).LongTermViewModel;
            foreach (var goal in goalList)
            {
                LongTermViewModel goalViewModel = new LongTermViewModel()
                {
                    Name = goal.Name,
                    CompletedStatus = goal.IsChecked
                };
                currentTaskModel.AddItemCommand.Execute(goalViewModel);
            }
        }

        void PopulateDailyTasks()
        {
            //Adds tasklist tasks
            var taskList = DatabaseDailyTasks.RetrieveFromDatabase("taskList");
            var currentTaskModel = ((MainWindowViewModel)DataContext).TaskListViewModel;
            foreach (var task in taskList)
            {
                DailyTasksViewModel taskViewModel = new DailyTasksViewModel()
                {
                    Name = task.Name,
                    CompletedStatus = task.IsChecked
                };
                currentTaskModel.AddItemCommand.Execute(taskViewModel);
            }

            //Adds shopping list tasks
            taskList = DatabaseDailyTasks.RetrieveFromDatabase("shoppingList");
            currentTaskModel = ((MainWindowViewModel)DataContext).ShoppingListViewModel;
            foreach (var task in taskList)
            {
                DailyTasksViewModel taskViewModel = new DailyTasksViewModel()
                {
                    Name = task.Name,
                    CompletedStatus = task.IsChecked
                };
                currentTaskModel.AddItemCommand.Execute(taskViewModel);
            }

            //Adds custom list tasks
            taskList = DatabaseDailyTasks.RetrieveFromDatabase("customList");
            currentTaskModel = ((MainWindowViewModel)DataContext).CustomListViewModel;
            foreach (var task in taskList)
            {
                DailyTasksViewModel taskViewModel = new DailyTasksViewModel()
                {
                    Name = task.Name,
                    CompletedStatus = task.IsChecked
                };
                currentTaskModel.AddItemCommand.Execute(taskViewModel);
            }

        }
        #endregion

        #region Set Goals, Subgoals and Tasks

        /// <summary>
        /// Adding new goals, subgoals and tasks to the database
        /// </summary>

        void SetGoalButton()
        {
            if (textBoxCreateGoalName.Text == "") return;
            var newGoal = new Goal();
            var name = textBoxCreateGoalName.Text;
            if (name.Contains(':')) name = name.Replace(':', '-');
            newGoal.GoalName = name;
            newGoal.GoalID = _listOfGoals.Count;
            newGoal.GoalDetails = textBoxCreateGoalDetails.Text;
            var dateTime = datePickerCreateGoal.SelectedDate;
            if ((bool)!checkClearDateCreateGoal.IsChecked && dateTime.HasValue) newGoal.GoalDeadline = (DateTime)dateTime;
            else newGoal.GoalDeadline = DateTime.MinValue;
            if (comboBoxCreateGoalPriority.SelectedItem != null) newGoal.Priority = comboBoxCreateGoalPriority.Items.IndexOf(comboBoxCreateGoalPriority.SelectedItem);
            newGoal.GoalID = _listOfGoals.Count;
            if (_iconCreateGoalChanged) newGoal.IconIndex = listViewCreateGoalIcons.SelectedIndex;


            //clear textboxes
            textBoxCreateGoalName.Clear();
            textBoxCreateGoalDetails.Clear();
            comboBoxCreateGoalPriority.SelectedIndex = -1;

            _listOfGoals.Add(newGoal);
            AdjustSubGoalComboBox();
            comboBoxCreateSubGoalForGoal.SelectedItem = comboBoxCreateSubGoalForGoal.Items[comboBoxCreateSubGoalForGoal.Items.Count - 1];

            _iconCreateGoalChanged = false;
        }

        void AdjustSubGoalComboBox()
        {
            //refresh the goal overview to display the freshly added goal
            comboBoxCreateSubGoalForGoal.Items.Clear();
            foreach (Goal goal in _listOfGoals)
            {
                comboBoxCreateSubGoalForGoal.Items.Add(goal.GoalName); // used goalName to show the name of the goal instead of "MyFormsApp.Goal"
            }
        }

        void SetSubGoalButton()
        {
            if (comboBoxCreateSubGoalForGoal.Text == "") return;
            if (textBoxCreateSubGoalName.Text == "") return;
            var newSubGoal = new SubGoal();
            var name = textBoxCreateSubGoalName.Text;
            newSubGoal.GoalName = name;
            newSubGoal.GoalDetails = textBoxCreateSubGoalDetails.Text;
            if (comboBoxCreateSubGoalPriority.SelectedItem != null) newSubGoal.Priority = comboBoxCreateSubGoalPriority.Items.IndexOf(comboBoxCreateSubGoalPriority.SelectedItem);
            var dateTime = datePickerCreateSubGoal.SelectedDate;
            if (checkClearDateCreateSubGoal.IsChecked == false && dateTime.HasValue) newSubGoal.GoalDeadline = (DateTime)datePickerCreateSubGoal.SelectedDate;
            else newSubGoal.GoalDeadline = DateTime.MinValue;

            //clear textboxes
            textBoxCreateSubGoalName.Clear();
            textBoxCreateSubGoalDetails.Clear();
            comboBoxCreateSubGoalPriority.SelectedIndex = -1;

            Goal relatedGoal = new Goal();
            foreach (Goal goal in _listOfGoals)
            {
                if (goal.GoalName == comboBoxCreateSubGoalForGoal.Text)
                {
                    relatedGoal = goal;
                }
            }

            newSubGoal.GoalID = relatedGoal.GoalID;

            relatedGoal.SubGoals.Add(newSubGoal);
            newSubGoal.IconIndex = relatedGoal.IconIndex;
            //UpdateAllLists();
            //SaveAllToFile();
        }


        //Adds the daily task to the appropriate view model and the database
        void AddDailyTask(string taskListType, string taskName, bool isChecked)
        {
            DailyTasksViewModel currentDailyTasksViewModel;
            switch(taskListType)
            {
                case "taskList":
                    currentDailyTasksViewModel = ((MainWindowViewModel)DataContext).TaskListViewModel;
                    break;
                case "shoppingList":
                    currentDailyTasksViewModel = ((MainWindowViewModel)DataContext).ShoppingListViewModel;
                    break;
                case "customList":
                    currentDailyTasksViewModel = ((MainWindowViewModel)DataContext).CustomListViewModel;
                    break;
                default:
                    currentDailyTasksViewModel = null;
                    Console.WriteLine("DailyTasksViewModel not set correctly");
                    break;
            }
            currentDailyTasksViewModel.AddItemCommand.Execute(new DailyTasksViewModel
            {
                Name = taskName,
                CompletedStatus = isChecked
            });
            DatabaseDailyTasks.AddToDatabase(taskListType, taskName, isChecked);
        }

        //Adds the new long term goal to the view model and the database
        void AddLongTermGoal(string goalName, bool isChecked)
        {
            var viewModel = ((MainWindowViewModel)DataContext).LongTermViewModel;
            viewModel.AddItemCommand.Execute(new LongTermViewModel
            {
                Name = goalName,
                CompletedStatus = isChecked
            });
            DatabaseLongTermGoals.AddToDatabase(goalName, isChecked);
        }

        #endregion

        #region Events

        /// <summary>
        /// UI events that fire internal processes
        /// </summary>

        // Adds the margin to the textblocks in treeviews, so that word wrap happens correctly
        // If word wrap extends beyond the treeview width, add more to the margin
        private void TextBlock_Loaded_GoalOverview(object sender, RoutedEventArgs e)
        {
            TextBlock textBlock = sender as TextBlock;
            TreeViewItem tvi = (TreeViewItem)((Grid)((StackPanel)((textBlock.Parent))).Parent).Parent;
            ItemsControl parent = ItemsControl.ItemsControlFromItemContainer(tvi);
            int index = 1;
            while (parent != null && parent.GetType() == typeof(TreeViewItem))
            {
                index++;
                parent = ItemsControl.ItemsControlFromItemContainer(parent);
            }

            textBlock.Margin = new Thickness(0, 0, 80 * index, 0);
        }

        private void TextBlock_Loaded_DailyTasks(object sender, RoutedEventArgs e)
        {
            TextBlock textBlock = sender as TextBlock;
            TreeViewItem tvi = (TreeViewItem)((Grid)((WrapPanel)((textBlock.Parent))).Parent).Parent;
            ItemsControl parent = ItemsControl.ItemsControlFromItemContainer(tvi);
            int index = 1;
            while (parent != null && parent.GetType() == typeof(TreeViewItem))
            {
                index++;
                parent = ItemsControl.ItemsControlFromItemContainer(parent);
            }

            textBlock.Margin = new Thickness(0, 0, 30 * index, 0);
        }
        #endregion

        //Fill the Goal overview UI elements based on the selected element
        private void treeViewGoalOverview_SelectedItemChanged(object sender, RoutedPropertyChangedEventArgs<object> e)
        {
            if (DataContext is GoalOverviewViewModel goalOverviewViewModel && e.NewValue is GoalOverviewViewModel singleGoal)
            {
                goalOverviewViewModel.SelectItemChangedCommand.Execute(singleGoal);
            }
        }

        //Remove goal on Backspace press 
        private void treeViewGoalOverview_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Back)
            {
                var treeView = sender as TreeView;
                if (treeView.Items.IndexOf(treeView.SelectedItem) == -1 && treeView.SelectedItem != null)
                {
                    return;
                }
                else
                {
                    if (treeView.DataContext is GoalOverviewViewModel goalOverviewViewModel)
                    {
                        goalOverviewViewModel.RemoveItemCommand.Execute(treeView.SelectedItem);
                    }
                }
            }
        }

        //On pressing Enter, add the task to the tasklist
        private void textBoxTaskList_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                var textBox = sender as TextBox;
                string taskListType = "";
                if (textBox.Text.Length > 0)
                {
                    switch (textBox.Name)
                    {
                        case "textBoxTaskList":
                            taskListType = "taskList";
                            break;
                        case "textBoxShoppingList":
                            taskListType = "shoppingList";
                            break;
                        case "textBoxCustomList":
                            taskListType = "customList";
                            break;
                        default:
                            Console.WriteLine("TaskList name not correct");
                            break;
                    }
                    AddDailyTask(taskListType, textBox.Text, false);
                    textBox.Clear();
                }
            }
        }

        //On pressing Enter, add the long term goal to the list
        private void textBoxLongTermGoals_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                var textBox = sender as TextBox;
                if (textBox.Text.Length > 0)
                {
                    AddLongTermGoal(textBox.Text, false);
                    textBox.Clear();
                }                
            }
        }

        private void buttonQuit_Click(object sender, RoutedEventArgs e)
        {
            System.Windows.Application.Current.Shutdown();
        }

        private void buttonMinimize_Click(object sender, RoutedEventArgs e)
        {
            WindowState = WindowState.Minimized;
        }
    }

}