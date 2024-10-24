using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Text;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Threading;
using Microsoft.Win32;
using System.Runtime.CompilerServices;
using System.Windows.Controls.Primitives;
using Windows.ApplicationModel.VoiceCommands;


namespace TaskManagement
{
    public partial class Form1 : Form
    {
        private List<Image> _listOfImages = new List<Image>();
        private PrivateFontCollection pfc = new PrivateFontCollection();
        private List<Goal> _listOfGoals = new List<Goal>();
        private List<string> _tasksList = new List<string>();
        private List<string> _shoppingList = new List<string>();
        private List<string> _customList = new List<string>();
        private string _customListTitle;
        private Dictionary<DateTime, List<Goal>> _dictOfDates;
        private Goal _currentlyEditingGoal = new Goal();
        private List<DayOfTheWeek> _listOfDays = new List<DayOfTheWeek>();
        private Object _lastCheckedLongTermItem = new object();
        private bool _iconEditGoalChanged = false;
        private bool _iconCreateGoalChanged = false;
        private int _selectedBackgroundImageIndex;
        private bool _setToStartUp = false;
        private bool _shouldDoRegistryUpdate = false;
        private string _themeColor = "red";
        private float _scaleFactor = 0;
        private string _filePath;
        private Dictionary<ComboBox, int> _dictTotalDropdownHeight = new Dictionary<ComboBox, int>();
        private bool _AreWeOnLoadShouldICheckCheckBoxes = true;
        private Dictionary<DateTime, List<Goal>> _dictWeeklyRotation = new Dictionary<DateTime,List<Goal>>();


        public Form1()
        { 
            InitializeComponent();

            //initiate the custom font to be used in the application
            InitCustomFont();
            //set the app title
            Text = "The Cutest Task Management by Aquaramelia";
            FormBorderStyle = FormBorderStyle.None;

            //set the icon for the app and create the menu for the notification tray icon
            Icon = Properties.Resources.icon311;
            notifyIcon.Icon = Icon;
            NotifyIconContextMenu();

            //set the app background
            RetrieveBgImages();
            BackgroundImage = _listOfImages[1];
            BackgroundImageLayout = ImageLayout.Stretch;
            RetrieveThemeImages();

            Hide();

            //the current application directory
            _filePath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + @"\Task Management\";
            //create the imagelist with the app icons
            AddIconsToImageList();
            //load the user data from the .txt save files
            LoadAllFromFile();
            //apply the currently selected application theme
            ApplyTheme();
            //if the app is set to start on system startup, check the appropriate checkbox
            checkBoxStartup.Checked = (_setToStartUp ? true : false);
            //if the app starts on startup, hide it on start
            if (_setToStartUp) Hide();
            
            //get the working area of the screen - this makes the app take on all the available screen space except from the taskbar
            //also tested on different resolutions
            var workingArea = Screen.FromHandle(Handle).WorkingArea;
            var scaleFactor = workingArea.Width / 1920f;
            _scaleFactor = scaleFactor;
            this.Size = new Size(Convert.ToInt32(this.Width * scaleFactor), Convert.ToInt32(this.Height * scaleFactor));
            ApplyCustomFontAndScalingToResolution(scaleFactor);

            MaximizedBounds = workingArea;
            WindowState = FormWindowState.Maximized;
            this.AutoScaleDimensions = new System.Drawing.SizeF(96F, 96F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Dpi;
            AutoSizeMode = AutoSizeMode.GrowOnly;
            AutoSize = true;

        }

        #region events
        
        //Not all app events are shown for simplicity.

        //when this button is clicked, add a new goal
        private void setGoalButton_Click(object sender, EventArgs e)
        {
            SetGoalButton();
        }

        //when this button is clicked, minimize the application to tray
        private void buttonMinimize_Click(object sender, EventArgs e)
        {
            if (this.WindowState == FormWindowState.Maximized)
            {
                this.WindowState = FormWindowState.Minimized;
                ShowInTaskbar = true;
                Hide();
            }

        }

        //quits the application on button click
        private void buttonQuit_Click(object sender, EventArgs e)
        {
            SaveAllToFile();
            Application.Exit();
        }

        //if Enter is pressed while writing the title for a new goal, the goal is added
        private void newGoalName_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter) SetGoalButton();
        }

        //if Enter is pressed, a new task is added to the tasklist
        private void textBoxCheckedListTasks_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                SetTask(textBoxCheckedListTasks.Text, checkedListTasks, _tasksList);
                textBoxCheckedListTasks.Clear();
                SaveAllToFile();
            }
            
        }

        //if an item of this treeview is selected, the selected goal's properties are to be shown in other UI elements
        private void treeViewGoals_AfterSelect(object sender, TreeViewEventArgs e)
        {
            var str = e.Node.Text;
            str = str.Replace('\n', ' ');
            foreach (var goal in _listOfGoals)
            {
                if (e.Node.Parent == null)
                {
                    if (goal.goalName == str)
                    {
                        PopulateEditGoalView(goal);
                    }
                }
                else
                {
                    foreach (var subgoal in goal.subGoals)
                    {
                        if (subgoal.goalName == str)
                        {
                            PopulateEditGoalView(subgoal);
                        }
                    }
                }
            }
        }

        //checks the selected goal
        private void treeViewWeekly_BeforeCheck(object sender, TreeViewCancelEventArgs e)
        {
            if (_AreWeOnLoadShouldICheckCheckBoxes == true) return;
            var treeView = (TreeView)sender;
            treeView.BeginInvoke(new Action(() =>
            {
                var goal = ReturnGoalFromText(e.Node.Text, false);
                goal.IsChecked = !goal.IsChecked;

                SaveAllToFile();
                UpdateAllLists();
            }));
        }

        //if a goal is selected in the comboBox, add it to the day's task list
        private void comboBoxMonday_SelectionChangeCommitted(object sender, EventArgs e)
        {
            var item = ((ComboBox)sender).SelectedItem;
            var text = item.ToString();
            if (item != null)
            {
                TreeNode newNode = new TreeNode();
                newNode.Text = item.ToString();
                //if the name contains ": ", it is a subgoal, this results from the way the goal is displayed
                var goal = ReturnGoalFromText(text, !text.Contains(": "));
                if (goal.iconIndex != -1)
                {
                    newNode.ImageIndex = goal.iconIndex;
                    newNode.SelectedImageIndex = goal.iconIndex;
                }
                treeViewMonday.Nodes.Add(newNode);
                ((ComboBox)sender).SelectedIndex = -1;
                SaveAllToFile();
            }
        }
        
        //checks an item in the long term goals task list and makes sure that the checked item is ordered below all unchecked items
        private void checkedListLongTerm_ItemCheck(object sender, ItemCheckEventArgs e)
        {
            checkedListLongTerm.BeginInvoke(new Action(() =>
            {
                if (e.NewValue == CheckState.Checked)
                {
                    var item = checkedListLongTerm.Items[e.Index];
                    if (item != _lastCheckedLongTermItem)
                    {
                        checkedListLongTerm.Items.Remove(item);
                        var newIndex = checkedListLongTerm.Items.Count - checkedListLongTerm.CheckedItems.Count;
                        _lastCheckedLongTermItem = item;
                        checkedListLongTerm.Items.Insert(newIndex, item);
                        checkedListLongTerm.SetItemChecked(newIndex, true);
                        SaveAllToFile();
                    }
                    else
                    {
                        _lastCheckedLongTermItem = null;
                    }
                    
                }
                else
                {
                    var item = checkedListLongTerm.Items[e.Index];
                    checkedListLongTerm.Items.Remove(item);
                    checkedListLongTerm.Items.Insert(0, item);
                    SaveAllToFile();
                }
            }));

        }
        
        //maximizes app on notification tray icon double click
        private void notifyIcon_DoubleClick(object sender, EventArgs e)
        {
            // Show the form when the user double clicks on the notify icon.

            // Set the WindowState to normal if the form is minimized.
            if (this.WindowState == FormWindowState.Minimized)
            {
                Activate();
                this.Show();
                MaximizedBounds = Screen.FromHandle(this.Handle).WorkingArea;
                WindowState = FormWindowState.Maximized;
                Refresh();
            }


        }
        
        //on button mouse enter and leave, change the button image
        private void buttonSave_MouseEnter(object sender, EventArgs e)
        {
            buttonSave.BackgroundImage = ChangeButtonImage(true, true, false);
        }

        private void buttonSave_MouseLeave(object sender, EventArgs e)
        {
            buttonSave.BackgroundImage = ChangeButtonImage(false, true, false);
        }
        
        //exits the app
        private void menuExit(object Sender, EventArgs e)
        {
            Close();
        }

        #endregion

        #region initial processes

        //for some comboboxes with multiline content, get the appropriate height for the combobox item
        void ComboBoxInitialize(ComboBox comboBox)
        {
            if (!_dictTotalDropdownHeight.ContainsKey(comboBox)) _dictTotalDropdownHeight.Add(comboBox, 0);
            int totalLines = 0, stringHeight;
            foreach (string item in comboBox.Items)
            {
                foreach (string str in WrapString(item, comboBox.CreateGraphics(), comboBox.Font, comboBox.Width))
                {
                    totalLines++;
                    if (totalLines == 1)
                    {
                        stringHeight = (int)comboBox.CreateGraphics().MeasureString(item, comboBox.Font).Height;
                    }
                }

            }
            comboBox.DropDownHeight = _dictTotalDropdownHeight[comboBox] + 2;
        }
        
        //initialize custom font use
        void InitCustomFont()
        {
            //Create your private font collection object.
            //Select your font from the resources.
            int fontLength = Properties.Resources.BeduaFreeUpdated.Length;

            // create a buffer to read in to
            byte[] fontdata = Properties.Resources.BeduaFreeUpdated;

            // create an unsafe memory block for the font data
            System.IntPtr data = Marshal.AllocCoTaskMem(fontLength);

            // copy the bytes to the unsafe memory block
            Marshal.Copy(fontdata, 0, data, fontLength);

            // pass the font to the font collection
            pfc.AddMemoryFont(data, fontLength);
        }
        
        //applies the custom font and scales the app to adjust to the user's screen resolution at the same time
        void ApplyCustomFontAndScalingToResolution(float scaleFactor)
        {
            var currentFont = new Font(pfc.Families[0], 8.25f * scaleFactor, FontStyle.Regular);
            this.Font = currentFont;
            var dataGridFont = new Font(pfc.Families[0], 16 * scaleFactor, FontStyle.Regular);
            dataGridViewDates.Font = dataGridFont;

            var buttonFontSize = mainTabControl.Font.Size * scaleFactor;
            var buttonFontStyle = mainTabControl.Font.Style;
            mainTabControl.Font = new Font(pfc.Families[0], buttonFontSize, buttonFontStyle);
            mainTabControl.Size = new Size(Convert.ToInt32(mainTabControl.Width * scaleFactor), Convert.ToInt32(mainTabControl.Height * scaleFactor));
            mainTabControl.Location = new Point(Convert.ToInt32(mainTabControl.Location.X * scaleFactor), Convert.ToInt32(mainTabControl.Location.Y * scaleFactor));

            buttonFontSize = buttonSave.Font.Size * scaleFactor;
            buttonFontStyle = buttonQuit.Font.Style;
            buttonQuit.Font = new Font(pfc.Families[0], buttonFontSize, buttonFontStyle);
            buttonQuit.Size = new Size(Convert.ToInt32(buttonQuit.Width * scaleFactor), Convert.ToInt32(buttonQuit.Height * scaleFactor));
            buttonQuit.Location = new Point(Convert.ToInt32(buttonQuit.Location.X * scaleFactor), Convert.ToInt32(buttonQuit.Location.Y * scaleFactor));

            gearButton.Size = new Size(Convert.ToInt32(gearButton.Width * scaleFactor), Convert.ToInt32(gearButton.Height * scaleFactor));
            gearButton.Location = new Point(Convert.ToInt32(gearButton.Location.X * scaleFactor), Convert.ToInt32(gearButton.Location.Y * scaleFactor));

            buttonFontSize = buttonMinimize.Font.Size * scaleFactor;
            buttonFontStyle = buttonMinimize.Font.Style;
            buttonMinimize.Font = new Font(pfc.Families[0], buttonFontSize, buttonFontStyle);
            buttonMinimize.Size = new Size(Convert.ToInt32(buttonMinimize.Width * scaleFactor), Convert.ToInt32(buttonMinimize.Height * scaleFactor));
            buttonMinimize.Location = new Point(Convert.ToInt32(buttonMinimize.Location.X * scaleFactor), Convert.ToInt32(buttonMinimize.Location.Y * scaleFactor));

            buttonFontSize = buttonSave.Font.Size * scaleFactor;
            buttonFontStyle = buttonSave.Font.Style;
            buttonSave.Font = new Font(pfc.Families[0], buttonFontSize, buttonFontStyle);
            buttonSave.Size = new Size(Convert.ToInt32(buttonSave.Width * scaleFactor), Convert.ToInt32(buttonSave.Height * scaleFactor));
            buttonSave.Location = new Point(Convert.ToInt32(buttonSave.Location.X * scaleFactor), Convert.ToInt32(buttonSave.Location.Y * scaleFactor));

            foreach (TabPage tabPage in mainTabControl.TabPages)
            {
                tabPage.Font = currentFont;
                tabPage.Size = new Size(Convert.ToInt32(tabPage.Width * scaleFactor), Convert.ToInt32(tabPage.Height * scaleFactor));
                tabPage.Location = new Point(Convert.ToInt32(tabPage.Location.X * scaleFactor), Convert.ToInt32(tabPage.Location.Y * scaleFactor));
                

                foreach (Control ctrl in tabPage.Controls)
                {
                    
                    if (ctrl is Panel)
                    {
                        foreach (Control panelCtrl in ctrl.Controls)
                        {
                            panelCtrl.Size = new Size(Convert.ToInt32(panelCtrl.Width * scaleFactor), Convert.ToInt32(panelCtrl.Height * scaleFactor));
                            panelCtrl.Location = new Point(Convert.ToInt32(panelCtrl.Location.X * scaleFactor), Convert.ToInt32(panelCtrl.Location.Y * scaleFactor));
                            var fontSize = panelCtrl.Font.Size * scaleFactor;
                            var fontStyle = panelCtrl.Font.Style;
                            panelCtrl.Font = new Font(pfc.Families[0], fontSize, fontStyle);
                        }
                    }
                    var initialFontSize = ctrl.Font.Size * scaleFactor;
                    var initialFontStyle = ctrl.Font.Style;
                    ctrl.Font = new Font(pfc.Families[0], initialFontSize, initialFontStyle);
                    ctrl.Size = new Size(Convert.ToInt32(ctrl.Width * scaleFactor), Convert.ToInt32(ctrl.Height * scaleFactor));
                    ctrl.Location = new Point(Convert.ToInt32(ctrl.Location.X * scaleFactor), Convert.ToInt32(ctrl.Location.Y * scaleFactor));
                }
            }

            panelTabButtons.Size = new Size(Convert.ToInt32(panelTabButtons.Width * scaleFactor), Convert.ToInt32(panelTabButtons.Height * scaleFactor));
            panelTabButtons.Location = new Point(Convert.ToInt32(panelTabButtons.Location.X * scaleFactor), Convert.ToInt32(panelTabButtons.Location.Y * scaleFactor));

            foreach (Control ctrl in panelTabButtons.Controls)
            {
                var initialFontSize = ctrl.Font.Size * scaleFactor;
                var fontStyle = ctrl.Font.Style;
                ctrl.Font = new Font(pfc.Families[0], initialFontSize, fontStyle);
                ctrl.Size = new Size(Convert.ToInt32(ctrl.Width * scaleFactor), Convert.ToInt32(ctrl.Height * scaleFactor));
                ctrl.Location = new Point(Convert.ToInt32(ctrl.Location.X * scaleFactor), Convert.ToInt32(ctrl.Location.Y * scaleFactor));
            }

        }

        //adds the app icons to an imagelist for later use
        void AddIconsToImageList()
        {
            newGoalIcons.LargeImageList = imageListIcons;
            editGoalIcons.LargeImageList = imageListIcons;
            for (int i = 1; i <= 44; i++)
            {
                
                var img = Properties.Resources.ResourceManager.GetObject("icon" + i.ToString());
                imageListIcons.Images.Add((Image)img);
                imageListSmallIcons.Images.Add((Image)img);
                var item1 = new ListViewItem(i.ToString())
                {
                    ImageIndex = i - 1
                };
                var item2 = new ListViewItem(i.ToString())
                {
                    ImageIndex = i - 1
                };
                newGoalIcons.Items.Add(item1);
                editGoalIcons.Items.Add(item2);
            }

        }
        
        //changes the button image on mouse hover
        Image ChangeButtonImage(bool OnHover, bool IsMain, bool IsTabButton)
        {
            if (OnHover)
            {
                if (IsTabButton) return (Image)Properties.Resources.ResourceManager.GetObject("buttonMainHover_" + _themeColor);
                if (IsMain) return (Image)Properties.Resources.ResourceManager.GetObject("buttonMainHover_" + _themeColor);
                else return (Image)Properties.Resources.ResourceManager.GetObject("buttonSecHover_" + _themeColor);
            }
            else
            {
                if (IsTabButton) return (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
                if (IsMain) return (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
                else return (Image)Properties.Resources.ResourceManager.GetObject("buttonSec_" + _themeColor);
            }
        }

        //the context menu that shows when the user right-clicks the app icon on the notification tray
        void NotifyIconContextMenu()
        {
            notifyIcon.ContextMenuStrip = new ContextMenuStrip();
            notifyIcon.ContextMenuStrip.Items.Insert(0, new ToolStripLabel("Task Management by Aquaramelia"));
            notifyIcon.ContextMenuStrip.Items.Insert(1, new ToolStripSeparator());
            notifyIcon.ContextMenuStrip.Items.Add("Maximize", null, notifyIcon_DoubleClick);
            notifyIcon.ContextMenuStrip.Items.Add("Exit", null, menuExit);

        }

        //register the app to start on Windows startup, only if the user chooses it and it isn't registered already
        void RegisterInStartup(bool shouldDoIt, bool setToStartup)
        {
            RegistryKey registryKey = Registry.CurrentUser.OpenSubKey
                    ("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", true);
            if (setToStartup)
            {
                if (!shouldDoIt) return;
                registryKey.SetValue("ApplicationName", Application.ExecutablePath);
                _shouldDoRegistryUpdate = false;
            }
            else
            {
                if (!shouldDoIt) return;
                registryKey.DeleteValue("ApplicationName");
                _shouldDoRegistryUpdate = false;
            }
        }

        //applies the currently selected theme on application start and on theme changed by user
        void ApplyTheme()
        {
            //main buttons
            buttonSave.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            buttonQuit.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            buttonMinimize.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonPriorities.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonGoalOverview.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonDatesOverview.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonCreateGoal.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonDailyTasks.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonWeeklyRotation.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);
            tabButtonLongTermPlanning.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonMain_" + _themeColor);

            //sec buttons
            setGoalButton.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonSec_" + _themeColor);
            setSubGoalButton.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonSec_" + _themeColor);
            buttonSaveGoalChanges.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("buttonSec_" + _themeColor);

            //menu panel bg
            panelTabButtons.BackgroundImage = (Image)Properties.Resources.ResourceManager.GetObject("panelStrip_" + _themeColor);
        }

        //make a treeview multiline --> add this event to it. 
        private void TreeView_SO_DrawNode(object sender, DrawTreeNodeEventArgs e)
        {
            e.DrawDefault = false;
            if (e.Node.Text == null) return;
            Font drawFont = e.Node.NodeFont ?? e.Node.TreeView?.Font ?? ((TreeView)sender).Font;
            SolidBrush drawBrush = new SolidBrush(Color.Black);
            if (e.Node.ImageIndex != -1)
            {
                var goal = ReturnGoalFromText(e.Node.Text, false);
                
                var fontSize = drawFont.Size;
                var fontStyle = drawFont.Style;
                var fontFamily = drawFont.FontFamily;
                if (goal.IsChecked) fontStyle = FontStyle.Strikeout;
                else  fontStyle = FontStyle.Regular;
                drawFont = new Font(fontFamily, fontSize, fontStyle);

            }
            if (e.Node.NodeFont != null)
            {
                if (e.Node.NodeFont.Style == FontStyle.Strikeout) drawBrush.Color = Color.Gray;
            }
            var tuple = NodeBounds(e.Node);
            Rectangle eNodeBounds = tuple.Item1;
            if (eNodeBounds.X == 0 && eNodeBounds.Y == 0) return;
            e.Graphics.DrawString(tuple.Item2, drawFont, drawBrush, eNodeBounds);
        }

        //Returns the string to be drawn in the treeview node, as well as the bounds of the node.
        //It is necessary to change the bounds of the node, so that they are enough to hold our multiline text.
        private Tuple<Rectangle, string> NodeBounds(TreeNode node)
        {
            if (node?.TreeView != null && node?.Text != null && (0 < node.Bounds.Location.X || 0 < node.Bounds.Location.Y))
            {
                using (Graphics g = node.TreeView.CreateGraphics())
                {
                    int charFitted;
                    //more characters fit in the goal overview than in the weekly rotation nodes
                    if (node.TreeView == treeViewGoals)
                    {
                        if (node.Parent == null) charFitted = (int)Math.Floor(40 * _scaleFactor);
                        else charFitted = (int)Math.Floor(25 * _scaleFactor);
                    }

                    else if (node.TreeView == treeViewHighUrgent || node.TreeView == treeViewHighNotUrgent || node.TreeView == treeViewLowUrgent || node.TreeView == treeViewLowNotUrgent)
                    {
                        charFitted = (int)Math.Floor(35 * _scaleFactor);
                    }
                    else charFitted = (int)Math.Floor(35 * _scaleFactor);

                    string formatted_text = WrapText(node.Text, charFitted);
                    SizeF textSize = g.MeasureString(formatted_text, node.NodeFont ?? node.TreeView.Font);


                    return new Tuple<Rectangle, string>(Rectangle.Ceiling(new RectangleF(PointF.Add(node.Bounds.Location,
                                             new SizeF(0, (node.TreeView.ItemHeight - textSize.Height) / 2)),
                                             new SizeF(textSize))), formatted_text);
                }
            }
            else
            {
                return new Tuple<Rectangle, string> (node?.Bounds??new Rectangle(), null);
            }
        }
        
        //original code to make wrap the text if it exceeds the charFitted number of characters
        string WrapText(string nodeText, int charFitted)
        {
            string[] spaces = nodeText.Split(' ');
            string completeText = string.Empty;
            string currentLine = string.Empty;
            int lineIndex = 1;
            for (int i = 0; i < spaces.Length; i++)
            {
                if (currentLine.Length + spaces[i].Length <= charFitted)
                {
                    if (i == 0)
                    {
                        currentLine = spaces[i];
                        if (i == spaces.Length - 1)
                        {
                            completeText += currentLine;
                            lineIndex++;
                        }
                    }
                    else if (i != spaces.Length - 1)
                    {
                        currentLine += " " + spaces[i];
                        continue;
                    }
                    else
                    {
                        currentLine += " " + spaces[i];
                        completeText += currentLine;
                        lineIndex++;
                    }
                }
                else if (spaces[i].Length >= charFitted)
                {
                    if (i == 0)
                    {
                        currentLine = spaces[i].Substring(0, charFitted) + "\n";
                        completeText += currentLine;
                        lineIndex++;
                        if (spaces[i].Substring(charFitted).Length > charFitted)
                        {
                            currentLine = spaces[i].Substring(charFitted, charFitted) + "\n";
                            lineIndex++;
                            completeText += currentLine;
                            //assuming we have no more lines, the max goal name character length at the moment of writing this is 80
                            currentLine = spaces[i].Substring(charFitted * 2);
                            if (i == spaces.Length - 1)
                            {
                                completeText += currentLine;
                                lineIndex++;
                            }
                        }
                        else
                        {
                            currentLine = spaces[i].Substring(charFitted);
                            if (i == spaces.Length - 1)
                            {
                                completeText += currentLine;
                                lineIndex++;
                            }
                            if (currentLine.Length == charFitted)
                            {
                                currentLine += " " + "\n";
                                completeText += currentLine;
                                lineIndex++;
                                currentLine = "";
                            }
                        }
                    }
                    else
                    {
                        if (currentLine != "") currentLine += " " + "\n";
                        completeText += currentLine;
                        lineIndex++;
                        currentLine = spaces[i].Substring(0, charFitted) + "\n";
                        completeText += currentLine;
                        lineIndex++;
                        if (spaces[i].Substring(charFitted).Length > charFitted)
                        {
                            currentLine = spaces[i].Substring(charFitted, charFitted) + "\n";
                            lineIndex++;
                            completeText += currentLine;
                            //assuming we have no more lines, the max goal name character length at the moment of writing this is 80
                            currentLine = spaces[i].Substring(charFitted * 2);
                            if (i == spaces.Length - 1)
                            {
                                completeText += currentLine;
                                lineIndex++;
                            }
                        }
                        else
                        {
                            currentLine = spaces[i].Substring(charFitted);
                            if (i == spaces.Length - 1)
                            {
                                completeText += currentLine;
                                lineIndex++;
                            }
                            if (currentLine.Length == charFitted)
                            {
                                currentLine += " " + "\n";
                                completeText += currentLine;
                                lineIndex++;
                                currentLine = "";
                            }
                        }
                    }
                }
                else
                {
                    currentLine += " " + "\n";
                    completeText += currentLine;
                    currentLine = spaces[i];
                    lineIndex++;
                }
            }
            return completeText;
        }


        //make the create subgoal combobox multiline

        private void comboBox_DrawItem(object sender, DrawItemEventArgs e)
        {
            var combobox = (ComboBox)sender;
            if (!_dictTotalDropdownHeight.ContainsKey(combobox)) _dictTotalDropdownHeight.Add(combobox, 0);
            
            if (e.Index > -1)
            {
                string itemText = combobox.Items[e.Index].ToString();
                Brush backgroundBrush, forgroundBrush;

                if (e.State == (DrawItemState.Selected | DrawItemState.NoAccelerator | DrawItemState.NoFocusRect) ||
                e.State == DrawItemState.Selected)
                {
                    forgroundBrush = new SolidBrush(SystemColors.Highlight);
                    backgroundBrush = new SolidBrush(Color.LightSlateGray);
                    //this.tooltip.Show(itemText, combobox, e.Bounds.Right, e.Bounds.Bottom);
                }
                else
                {
                    forgroundBrush = new SolidBrush(SystemColors.Window);
                    backgroundBrush = Brushes.Black;
                    //this.tooltip.Hide(combobox);
                }

                if ((e.State & DrawItemState.Focus) == 0)
                {
                    e.Graphics.FillRectangle(Brushes.Lavender, e.Bounds);
                    e.Graphics.DrawString(itemText, combobox.Font, backgroundBrush,
                        e.Bounds);
                    //e.Graphics.DrawRectangle(new Pen(Brushes.LightSlateGray), e.Bounds);
                }
                else
                {
                    e.Graphics.FillRectangle(Brushes.LightSlateGray, e.Bounds);
                    e.Graphics.DrawString(itemText, combobox.Font, backgroundBrush,
                        e.Bounds);
                }
            }
        }
        
        //measures the string of the combobox in order to wrap its text
        protected void comboBox_MeasureItem(object sender, MeasureItemEventArgs e)
        {
            var combobox = (ComboBox)sender;
            if (!_dictTotalDropdownHeight.ContainsKey(combobox)) _dictTotalDropdownHeight.Add(combobox, 0);
            
            if (e.Index > -1)
            {
                string itemText = combobox.Items[e.Index].ToString();
                SizeF sf = e.Graphics.MeasureString(itemText, combobox.Font, combobox.Width);
                int multiLineCount = 0;
                foreach (string item in WrapString(itemText, e.Graphics, combobox.Font, combobox.Width))
                {
                    multiLineCount++;
                }
                e.ItemHeight = (int)Math.Floor(multiLineCount * 31 * _scaleFactor);
                _dictTotalDropdownHeight[combobox] += e.ItemHeight;
                e.ItemWidth = combobox.Width;
            }
        }
        
        //wraps the text if it exceeds a certain width
        IEnumerable<string> WrapString(string str, Graphics g, Font font,
                                           int allowedWidth)
        {
            string[] arr = str.Split(' ');
            StringBuilder current = new StringBuilder();
            foreach (string token in arr)
            {
                int width =
                  (int)g.MeasureString(current.ToString() + " " + token, font).Width;
                if (width > allowedWidth)
                {
                    yield return current.ToString();
                    current = new StringBuilder();
                }
                current.Append(token + " ");
            }
            yield return current.ToString();
        }
        
        
        //shows a daily reminder as a system notification; 
        //commented out because it doesn't work by default on all systems
        /*void ShowReminder()
        {
            if (_showReminders == false) return;
            if (!_dictOfDates.ContainsKey(DateTime.Today)) return;
            var tasks = _dictOfDates[DateTime.Today];
            if (tasks.Count != 0)
            {

                var maxIndex = 4;
                var index = 0;
                string balloonText = "";
                foreach (var task in tasks)
                {
                    if (index <= maxIndex) 
                    {
                        balloonText += task.goalName + '\n';
                        index++;
                    }
                }
                if (index == maxIndex)
                {
                    if (tasks.Count > maxIndex + 1) 
                    {
                        balloonText += "...and " + (tasks.Count - (maxIndex + 1)).ToString() + " more.";
                    }
                }
                
                string title = "You have new reminders for today!";
                notifyIcon.ShowBalloonTip(30000, title, balloonText, ToolTipIcon.Info);
                //WaitToShowBalloon(3000, notifyIcon, title, "Hello!");
            }
        }

        static async Task WaitToShowBalloon(int milliseconds, NotifyIcon notifyIcon, string title, string text)
        {
            await Task.Delay(milliseconds); 
            notifyIcon.ShowBalloonTip(30000, title, text, ToolTipIcon.Info);
        }*/
        #endregion

        #region set goals and subgoals

        void SetGoalButton()
        {
            if (newGoalName.Text == "") return;
            var newGoal = new Goal();
            var name = newGoalName.Text;
            if (name.Contains(':')) name = name.Replace(':', '-');
            newGoal.goalName = name;
            newGoal.goalID = _listOfGoals.Count;
            newGoal.goalDetails = newGoalDetails.Text;
            if (!clearDateCreateGoal.Checked) newGoal.goalDeadline = datePickerCreateGoal.Value;
            else newGoal.goalDeadline = DateTime.MinValue;
            if (newGoalPriority.SelectedItem != null) newGoal.priority = newGoalPriority.Items.IndexOf(newGoalPriority.SelectedItem);
            newGoal.goalID = _listOfGoals.Count;
            if (_iconCreateGoalChanged) newGoal.iconIndex = newGoalIcons.SelectedIndices[0];
            

            //clear textboxes
            newGoalName.Clear();
            newGoalDetails.Clear();
            newGoalPriority.SelectedIndex = -1;

            _listOfGoals.Add(newGoal);
            AdjustSubGoalComboBox();
            comboBoxSubGoal.SelectedItem = comboBoxSubGoal.Items[comboBoxSubGoal.Items.Count - 1];

            UpdateAllLists();
            _iconCreateGoalChanged = false;
            SaveAllToFile();
        }

        #endregion

        #region Populate goal lists
        //when a goal is selected in the goal view, show its data on the UI elements
        void PopulateEditGoalView(Goal goalToView)
        {
            _currentlyEditingGoal = goalToView;
            textBoxEditGoalName.Text = goalToView.goalName;
            textBoxEditGoalDetails.Text = goalToView.goalDetails;
            if (goalToView.goalDeadline != DateTime.MinValue)
            {
                datePickerEditGoal.Value = goalToView.goalDeadline;
                clearDateEditGoal.Checked = false;
            }
            else clearDateEditGoal.Checked = true;
            editGoalIcons.SelectedIndices.Clear();
            editGoalIcons.SelectedIndices.Add(goalToView.iconIndex);
            editGoalIcons.EnsureVisible(goalToView.iconIndex);
            comboBoxEditGoalPriority.SelectedIndex = goalToView.priority;

        }

        //saves the changes made to the goal
        void SaveGoalChanges(Goal goalToSave)
        {
            goalToSave.goalName = textBoxEditGoalName.Text;
            goalToSave.goalDetails = textBoxEditGoalDetails.Text;
            if (!clearDateEditGoal.Checked) goalToSave.goalDeadline = datePickerEditGoal.Value;
            else goalToSave.goalDeadline = DateTime.MinValue;
            if (_iconEditGoalChanged) goalToSave.iconIndex = editGoalIcons.SelectedIndices[0];
            if (!(goalToSave is SubGoal)) 
                foreach (var subgoal in goalToSave.subGoals)
                {
                    subgoal.iconIndex = editGoalIcons.SelectedIndices[0];
                }
            goalToSave.priority = comboBoxEditGoalPriority.SelectedIndex;

            _iconEditGoalChanged = false;
            SaveAllToFile();
            UpdateAllLists();
        }

        
        void PopulateWeeklyRotation()
        {
            CreateDaysOfTheWeek();
            CreateDateTimeList();
            FillTheComboBoxes();
        }

        #endregion

        #region save to disk
        
        //saves the goals to the .txt save file
        void SaveGoalsToFile()
        {
            if (!File.Exists(_filePath + "SaveGoals.txt")) 
            {
                if (!Directory.Exists(_filePath)) Directory.CreateDirectory(_filePath);
                File.Create(_filePath + "SaveGoals.txt").Close(); 
            }
            File.WriteAllText(_filePath + "SaveGoals.txt", string.Empty);
            using (StreamWriter sw = File.AppendText(_filePath + "SaveGoals.txt"))
            {
                foreach (Goal goal in _listOfGoals)
                {
                    sw.WriteLine(goal.goalID + "\t" + goal.goalName + "\t" + goal.priority + "\t" + goal.goalDetails + "\t" + goal.goalDeadline.ToString() + "\t" + goal.iconIndex.ToString() + "\t" + goal.IsChecked.ToString());
                }
            }

        }


        //loads the goals from the .txt save file
        void LoadGoalsFromFile()
        {
            if (!File.Exists(_filePath + "SaveGoals.txt")) return;
            using (StreamReader sr = new StreamReader(_filePath + "SaveGoals.txt"))
            {
                while (sr.Peek() >= 0)
                {
                    string str;
                    string[] strArray;
                    str = sr.ReadLine();
                    strArray = str.Split('\t');
                    Goal currentGoal = new Goal();
                    currentGoal.goalID = int.Parse(strArray[0]);
                    currentGoal.goalName = strArray[1];
                    currentGoal.priority = int.Parse(strArray[2]);
                    currentGoal.goalDetails = strArray[3];
                    currentGoal.goalDeadline = DateTime.Parse(strArray[4]);
                    currentGoal.iconIndex = int.Parse(strArray[5]);
                    currentGoal.IsChecked = bool.Parse(strArray[6]);
                    _listOfGoals.Add(currentGoal);
                }
            }
            AdjustSubGoalComboBox();
            comboBoxSubGoal.SelectedIndex = -1;
        
        }

        #endregion

        #region tasks 
        
        //adds a newly added task
        void SetTask(string taskName, CheckedListBox checkedList, List<string> listToAdd)
        {
            listToAdd.Add(taskName);
            checkedList.Items.Add(taskName);
            SaveAllToFile();
        }

        #endregion

        #region weekly rotation

        //adds the current week dates to the _listOfDays
        //and displays them in the UI
        void CreateDateTimeList()
        {

            for(int i = 0; i < 7; i++)
            {
                var currentDate = DateTime.Today.AddDays(i);
                _listOfDays[i].date = currentDate; 
                _listOfDays[i].label.Text = currentDate.ToString("D");
            }
            labelFlexible.Text = "Flexible Tasks";
        }

        //creates a new day of the week object for each day of the weekly rotation and adds the UI elements. 
        //this makes the codebase tightly coupled to the user interface.
        //I have created a de-coupled version of the app in WPF.
        
        void CreateDaysOfTheWeek()
        {
            var Monday = new DayOfTheWeek();
            Monday.comboBox = comboBoxMonday;
            Monday.treeView = treeViewMonday;
            Monday.label = labelMonday;
            Monday.textBox = textBoxMonday;
            _listOfDays.Add(Monday);

            var Tuesday = new DayOfTheWeek();
            Tuesday.comboBox = comboBoxTuesday;
            Tuesday.treeView = treeViewTuesday;
            Tuesday.label = labelTuesday;
            Tuesday.textBox = textBoxTuesday;
            _listOfDays.Add(Tuesday);

            var Wednesday = new DayOfTheWeek(); 
            Wednesday.comboBox = comboBoxWednesday;
            Wednesday.treeView = treeViewWednesday;
            Wednesday.label = labelWednesday;
            Wednesday.textBox = textBoxWednesday;
            _listOfDays.Add(Wednesday);

            var Thursday = new DayOfTheWeek();
            Thursday.comboBox = comboBoxThursday;
            Thursday.treeView = treeViewThursday;
            Thursday.label = labelThursday;
            Thursday.textBox = textBoxThursday;
            _listOfDays.Add(Thursday);

            var Friday = new DayOfTheWeek();
            Friday.comboBox = comboBoxFriday;
            Friday.treeView = treeViewFriday;
            Friday.label = labelFriday;
            Friday.textBox = textBoxFriday;
            _listOfDays.Add(Friday);

            var Saturday = new DayOfTheWeek();
            Saturday.comboBox = comboBoxSaturday;
            Saturday.treeView = treeViewSaturday;
            Saturday.label = labelSaturday;
            Saturday.textBox = textBoxSaturday;
            _listOfDays.Add(Saturday);

            var Sunday = new DayOfTheWeek();
            Sunday.comboBox = comboBoxSunday;
            Sunday.treeView = treeViewSunday;
            Sunday.label = labelSunday;
            Sunday.textBox = textBoxSunday;
            _listOfDays.Add(Sunday);

            var Flexible = new DayOfTheWeek();
            Flexible.comboBox = comboBoxFlexible;
            Flexible.treeView = treeViewFlexible;
            Flexible.label = labelFlexible;
            Flexible.textBox = textBoxFlexible;
            _listOfDays.Add(Flexible);
        }

        //In the weekly rotation view, it is important that the combobox under each day 
        //doesn't include the already placed goals in that day, but includes all others. This is ensured in this function.
        void FillTheComboBoxes()
        {
            foreach (var day in _listOfDays)
            {
                day.comboBox.Items.Clear();
            }

            foreach (var goal in _listOfGoals)
            {
                var str = goal.goalName;
                foreach (var day in _listOfDays)
                {
                    bool FoundIt = false;
                    
                    foreach (TreeNode item in day.treeView.Nodes)
                    {
                        if (item.Text.ToString() == str) FoundIt = true;
                    }
                    if (!FoundIt) day.comboBox.Items.Add(str);

                }
                if (goal.subGoals.Count != 0)
                {
                    foreach (var subgoal in goal.subGoals)
                    {
                        var strSub = subgoal.goalName;
                        foreach (var day in _listOfDays)
                        {
                            bool FoundIt = false;
                            
                            foreach (TreeNode item in day.treeView.Nodes)
                            {
                                if (item.Text.ToString() == strSub) FoundIt = true;
                            }
                            if (!FoundIt) day.comboBox.Items.Add(strSub);
                        }
                    }
                }
            }
        }

        #endregion
        
    }

    //the class for the user goals
    public class Goal
    {
        public int goalID; //autocount
        public int priority = -1; // 0, 1, 2, or 3 - these are the available priority levels, with 0 being the most urgent
        public string goalName;
        public string goalDetails;
        public int iconIndex;
        public List<SubGoal> subGoals = new List<SubGoal>();
        public DateTime goalDeadline;
        public bool IsChecked;
    }

    //the class Subgoal inherits Goal, but is named differently to help distinguish between objects in code.
    public class SubGoal : Goal
    {
        
    }

    //creation of an extended treeview class that inherits treeview but enables us to remove the horizontal scrollbar via the designer view.
    public partial class ExtendedTreeView : TreeView
    {
        private bool _horizontalScrollbar = true;
        [Category("Appearance")]
        [Description("Whether to enable a horizontal scrollbar")]
        public bool HorizontalScrollbar
        {
            get { return _horizontalScrollbar; }
            set
            {
                _horizontalScrollbar = value;
                if (DesignMode)
                {
                    RecreateHandle();
                }
                else
                {
                    Invalidate();
                }
            }
        }

        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams ret = base.CreateParams;
                if (!_horizontalScrollbar)
                {
                    ret.Style |= 0x8000; // TVS_NOHSCROLL
                }
                return ret;
            }
        }
    }
}