using System;
using System.Collections.Generic;
using System.Windows.Forms;

namespace Autoscript
{
    public partial class FilteredComboBox : ComboBox
    {
        private List<string> listOfItems = new List<string>();
        private ToolTip toolTip = new ToolTip();

        public FilteredComboBox()
        {
            InitializeComponent();
        }

        public void ListFilling()
        {
            listOfItems.Clear();
            foreach (string s in Items)
                listOfItems.Add(s);                
        }

        private void repairComboBox()
        {
            if (Items.Count >= listOfItems.Count)
            {
                return;
            }
            else
            {
                Items.Clear();
                foreach (string s in listOfItems)
                    Items.Add(s);
            }
        }

        public void AccurateRepairComboBox()
        {
            if (Items.Count >= listOfItems.Count)
            {
                return;
            }
            else
            {
                foreach (string s in listOfItems)
                    if (Items.IndexOf(s) == -1)
                        Items.Add(s);
            }
        }

        protected override void OnDropDown(EventArgs e)
        {
            if ((Items.Count == 1) && (Items[0].ToString() == ""))  //если есть только пустая строка
            {
                repairComboBox();
            }

            int newWidth = 0;
            foreach (string s in Items)
            {
                newWidth = TextRenderer.MeasureText(s, Font).Width;
                if (DropDownWidth < newWidth)
                    DropDownWidth = newWidth;
            }

            Cursor.Current = Cursors.Default;
        }

        protected override void OnDropDownClosed(EventArgs e)
        {
            DropDownWidth = Width;
        }

        protected override void OnKeyDown(KeyEventArgs e)
        {
            base.OnKeyDown(e);
            if ((e.KeyCode == Keys.Down) || (e.KeyCode == Keys.Up))
            {
                try
                {
                    if (e.KeyCode == Keys.Down)
                        ++SelectedIndex;
                    if (e.KeyCode == Keys.Up)
                        --SelectedIndex;
                }
                catch (ArgumentOutOfRangeException)
                {
                    return;
                }

                Focus();
                Select(0, 0);
                DroppedDown = true;                
                e.Handled = true;                
            }

            if (e.KeyCode == Keys.Enter)
            {
                Select(0, 0);

                try
                {
                    if (Items.IndexOf(Text) != -1)
                    {
                        if (Text != Items[SelectedIndex].ToString())
                            Text = Items[SelectedIndex].ToString();
                        OnSelectedIndexChanged(e);
                    }
                    else
                    {
                        repairComboBox();
                        e.Handled = true;
                    }
                }
                catch(ArgumentOutOfRangeException)
                {
                    return;
                }

                repairComboBox();
            }
        }

        protected override void OnTextChanged(EventArgs e)
        {
            toolTip.SetToolTip(this, Text);
        }

        protected override void OnTextUpdate(EventArgs e)
        {
            if (Text.Length > 0)
            {
                int pos = SelectionStart;
                Items.Clear();
                DroppedDown = true;
                Cursor.Current = Cursors.Default;           //Иначе пропадает курсор мыши

                displayMatches();
                preventArgOutOfRangeEx();

                Select(pos, 0);                             //Возвращение текстового курсора на место
            }
            else
            {
                repairComboBox();
            }
        }

        private void displayMatches()
        {
            foreach (string s in listOfItems)
            {
                if (s.ToLower().Contains(Text.ToLower()))
                    Items.Add(s);
            }
        }

        private void preventArgOutOfRangeEx()
        {
            if (Items.Count == 0)                       
                Items.Add("");                          
        }
    }
}