using System;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using RtbClass;

namespace ContextMenu
{
    public class ContextMenuClass : ContextMenuStrip
    {
        private Form form;                          //Создаём объект формы для обработки пунктов контекстного меню
        private ContextMenuStrip eMenu = new ContextMenuStrip();    //Создаём новое контекстное меню
        private MyRichClass richTemp = new MyRichClass();   //Создаем объект класса MyRichClass для извлечения из него шрифта
        private Form formSearch;                     //форма для поиска и замены текста
        private TextBox tbFind, tbReplace;           //для доступности элементов всему классу
        private CheckBox chkCase;                    //чувствительность к регистру при поиске
        private string FindStr="", ReplaceStr="";    //строки для поиска и замены
        private int pos;                             //позиция курсора в текстовом поле
        private int count;                           //количество найденных строк

        /*Создаём пункты контекстного меню*/
        private ToolStripMenuItem mCut = new ToolStripMenuItem("Вырезать");
        private ToolStripMenuItem mCopy = new ToolStripMenuItem("Копировать");
        private ToolStripMenuItem mPaste = new ToolStripMenuItem("Вставить");
        private ToolStripMenuItem mDel = new ToolStripMenuItem("Удалить");
        private ToolStripSeparator separator1 = new ToolStripSeparator();
        private ToolStripMenuItem mReplace = new ToolStripMenuItem("Найти и заменить (Ctrl-H)");
        private ToolStripSeparator separator2 = new ToolStripSeparator();
        private ToolStripMenuItem mUpper = new ToolStripMenuItem("К верхнему регистру");
        private ToolStripMenuItem mLower = new ToolStripMenuItem("К нижнему регистру");
        private ToolStripSeparator separator3 = new ToolStripSeparator();
        private ToolStripMenuItem mSelectAll = new ToolStripMenuItem("Выделить всё");

        public void AddContextMenu(MyRichClass[] Richiki)
        {
            /*Добавляем пункты контекстного меню*/
            eMenu.Items.Add(mCut); eMenu.Items.Add(mCopy); eMenu.Items.Add(mPaste); eMenu.Items.Add(mDel);
            eMenu.Items.Add(separator1); eMenu.Items.Add(mReplace);
            eMenu.Items.Add(separator2); eMenu.Items.Add(mUpper);
            eMenu.Items.Add(mLower); eMenu.Items.Add(separator3); eMenu.Items.Add(mSelectAll);

            /*Добавляем обработчики событий*/
            mCut.Click += new EventHandler(mCut_Click);
            mCopy.Click += new EventHandler(mCopy_Click);
            mPaste.Click += new EventHandler(mPaste_Click);
            mDel.Click += new EventHandler(mDel_Click);
            mReplace.Click += new EventHandler(mReplace_Click);
            mUpper.Click += new EventHandler(mUpper_Click);
            mLower.Click += new EventHandler(mLower_Click);
            mSelectAll.Click += new EventHandler(mSelectAll_Click);

            /*Привязываем контекстное меню к ричтекстбоксам*/
            foreach (MyRichClass richik in Richiki)
                richik.ContextMenuStrip = eMenu;
        }

        public void mCut_Click(object sender, EventArgs e)
        {
            try
            {
                if (form.ActiveControl is RichTextBox)
                {
                    Clipboard.SetText(((RichTextBox)form.ActiveControl).SelectedText);
                    ((RichTextBox)form.ActiveControl).SelectedText = "";
                }
                else if (form.ActiveControl is SplitContainer)
                {
                    SplitContainer split = (SplitContainer)form.ActiveControl;
                    if (split.ActiveControl is RichTextBox)
                    {
                        Clipboard.SetText(((RichTextBox)split.ActiveControl).SelectedText);
                        ((RichTextBox)split.ActiveControl).SelectedText = "";
                    }
                }
            }
            catch (Exception)
            {
                Clipboard.Clear();
                return;
            }
        }

        public void mCopy_Click(object sender, EventArgs e)
        {
            try
            {
                if (form.ActiveControl is RichTextBox)
                    Clipboard.SetText(((RichTextBox)form.ActiveControl).SelectedText);
                else if (form.ActiveControl is SplitContainer)
                {
                    SplitContainer split = (SplitContainer)form.ActiveControl;
                    if (split.ActiveControl is RichTextBox)
                        Clipboard.SetText(((RichTextBox)split.ActiveControl).SelectedText);
                }
            }
            catch (Exception)
            {
                Clipboard.Clear();
                return;
            }
        }

        public void mPaste_Click(object sender, EventArgs e)
        {
            if (form.ActiveControl is RichTextBox)
            {
                ((RichTextBox)form.ActiveControl).SelectedText = Clipboard.GetText();
                ((RichTextBox)form.ActiveControl).Font = richTemp.Fontik;       //Выравниваем шрифт после вставки текста
            }
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                {
                    ((RichTextBox)split.ActiveControl).SelectedText = Clipboard.GetText();
                    ((RichTextBox)split.ActiveControl).Font = richTemp.Fontik;  //Выравниваем шрифт после вставки текста
                }
            }
        }

        public void mDel_Click(object sender, EventArgs e)
        {
            if (form.ActiveControl is RichTextBox)
                ((RichTextBox)form.ActiveControl).SelectedText = "";
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                    ((RichTextBox)split.ActiveControl).SelectedText = "";
            }
        }

        public void mUpper_Click(object sender, EventArgs e)
        {
            if (form.ActiveControl is RichTextBox)
                ((RichTextBox)form.ActiveControl).SelectedText = ((RichTextBox)form.ActiveControl).SelectedText.ToUpper();
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                    ((RichTextBox)split.ActiveControl).SelectedText = ((RichTextBox)split.ActiveControl).SelectedText.ToUpper();
            }
        }

        public void mLower_Click(object sender, EventArgs e)
        {
            if (form.ActiveControl is RichTextBox)
                ((RichTextBox)form.ActiveControl).SelectedText = ((RichTextBox)form.ActiveControl).SelectedText.ToLower();
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                    ((RichTextBox)split.ActiveControl).SelectedText = ((RichTextBox)split.ActiveControl).SelectedText.ToLower();
            }
        }

        public void mSelectAll_Click(object sender, EventArgs e)
        {
            if (form.ActiveControl is RichTextBox)
                ((RichTextBox)form.ActiveControl).SelectAll();
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                    ((RichTextBox)split.ActiveControl).SelectAll();
            }
        }

        public void mReplace_Click(object sender, EventArgs e)
        {
            pos = 0;
            /*Запрет повторного открытия формы*/
            foreach (Form f in Application.OpenForms)
            {
                if (f.Name == "FormSearch")
                {
                    f.Activate();
                    return;
                }
            }
            /*Инициализируем форму поиска и замены текста*/
            formSearch = new Form(); formSearch.Name = "FormSearch";
            formSearch.TopMost = true;                                      //Отображаем поверх всех окон приложения
            formSearch.Size = new Size(350, 160); formSearch.FormBorderStyle = FormBorderStyle.FixedDialog;
            formSearch.MinimizeBox = false; formSearch.MaximizeBox = false;     //Запрет изменения размеров формы
            formSearch.Text = "Найти и заменить";

            /*Создаём элементы управления формы*/
            Label lbl1 = new Label(); Label lbl2 = new Label();
            tbFind = new TextBox(); tbReplace = new TextBox();
            Button btnFindNext = new Button(); Button btnReplace = new Button();
            Button btnReplaceAll = new Button(); Button btnCancel = new Button();
            chkCase = new CheckBox(); chkCase.Checked = false;
            lbl1.Size = new Size(33, 20); lbl2.Size = new Size(33, 20);
            tbFind.Size = new Size(190, 21); tbReplace.Size = new Size(190, 21);
            btnFindNext.Size = new Size(100, 25); btnReplace.Size = new Size(100, 25);
            btnReplaceAll.Size = new Size(100, 25); btnCancel.Size = new Size(100, 25);
            chkCase.Size = new Size(160, 21);
            lbl1.Text = "Что:"; lbl2.Text = "Чем:";
            btnFindNext.Text = "Найти далее"; btnReplace.Text = "Заменить";
            btnReplaceAll.Text = "Заменить все"; btnCancel.Text = "Отмена";
            chkCase.Text = "С учётом регистра";
            lbl1.Location = new Point(5, 10); lbl2.Location = new Point(5, 40);
            tbFind.Location = new Point(40, 11); tbReplace.Location = new Point(40, 41);
            btnFindNext.Location = new Point(240, 10); btnReplace.Location = new Point(240, 40);
            btnReplaceAll.Location = new Point(240, 70); btnCancel.Location = new Point(240, 100);
            chkCase.Location = new Point(10, 100);
            formSearch.Controls.Add(lbl1); formSearch.Controls.Add(lbl2);
            formSearch.Controls.Add(tbFind); formSearch.Controls.Add(tbReplace);
            formSearch.Controls.Add(btnFindNext); formSearch.Controls.Add(btnReplace);
            formSearch.Controls.Add(btnReplaceAll); formSearch.Controls.Add(btnCancel);
            formSearch.Controls.Add(chkCase);

            tbFind.TextChanged += new EventHandler(tbFind_TextChanged);
            tbReplace.TextChanged += new EventHandler(tbReplace_TextChanged);
            btnFindNext.Click += new EventHandler(btnFindNext_Click);
            btnReplace.Click += new EventHandler(btnReplace_Click);
            btnReplaceAll.Click += new EventHandler(btnReplaceAll_Click);
            btnCancel.Click += new EventHandler(btnCancel_Click);
            
            /*Выход по Escape*/
            tbFind.KeyDown += new KeyEventHandler(tbFind_KeyDown); tbReplace.KeyDown += new KeyEventHandler(tbFind_KeyDown);
            chkCase.KeyDown += new KeyEventHandler(tbFind_KeyDown); btnFindNext.KeyDown += new KeyEventHandler(tbFind_KeyDown);
            btnReplace.KeyDown += new KeyEventHandler(tbFind_KeyDown); btnReplaceAll.KeyDown += new KeyEventHandler(tbFind_KeyDown);
            btnCancel.KeyDown += new KeyEventHandler(tbFind_KeyDown);

            /*Передаём полю поиска выделенный фрагмент текста*/
            if (form.ActiveControl is RichTextBox)
            {
                tbFind.Text = ((RichTextBox)form.ActiveControl).SelectedText.Trim();
                ((RichTextBox)form.ActiveControl).SelectionStart = 0;
                ((RichTextBox)form.ActiveControl).SelectionLength = 0;
            }
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                {
                    tbFind.Text = ((RichTextBox)split.ActiveControl).SelectedText.Trim();
                    ((RichTextBox)split.ActiveControl).SelectionStart = 0;
                    ((RichTextBox)split.ActiveControl).SelectionLength = 0;
                }
            }
            formSearch.Show();       //показываем форму поиска и замены текста     
        }

        public void tbFind_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
                formSearch.Dispose();
        }

        public void tbFind_TextChanged(object sender, EventArgs e)
        {
            FindStr = tbFind.Text;
        }

        public void tbReplace_TextChanged(object sender, EventArgs e)
        {
            ReplaceStr = tbReplace.Text;
        }

        public void btnFindNext_Click(object sender, EventArgs e)
        {
            try
            {
                if (form.ActiveControl is RichTextBox)
                {
                    if (!chkCase.Checked)    //поиск, нечувствительный к регистру
                        pos = ((RichTextBox)form.ActiveControl).Text.ToLower().IndexOf(FindStr.ToLower(), pos);
                    else
                        pos = ((RichTextBox)form.ActiveControl).Text.IndexOf(FindStr, pos);                    
                    ((RichTextBox)form.ActiveControl).SelectionStart = pos;
                    ((RichTextBox)form.ActiveControl).SelectionLength = FindStr.Length;
                    ((RichTextBox)form.ActiveControl).Focus();
                }
                else if (form.ActiveControl is SplitContainer)
                {
                    SplitContainer split = (SplitContainer)form.ActiveControl;
                    if (split.ActiveControl is RichTextBox)
                    {
                        if (!chkCase.Checked)    //поиск, нечувствительный к регистру
                            pos = ((RichTextBox)split.ActiveControl).Text.ToLower().IndexOf(FindStr.ToLower(), pos);
                        else
                            pos = ((RichTextBox)split.ActiveControl).Text.IndexOf(FindStr, pos);
                        ((RichTextBox)split.ActiveControl).SelectionStart = pos;
                        ((RichTextBox)split.ActiveControl).SelectionLength = FindStr.Length;
                        ((RichTextBox)split.ActiveControl).Focus();
                    }
                }
                count++;
                pos++;
            }
            catch (ArgumentOutOfRangeException)     //перехват исключения превышения индекса
            {
                pos = 0;
                if (count > 0)
                {
                    MessageBox.Show("Достигнут конец текста.\nБудем искать сначала.");
                    count = 0;
                }
                else
                    MessageBox.Show("Не удаётся найти \"" + FindStr + "\".");
            }
            catch (ArgumentNullException)   //перехват исключения при передаче указателя NULL методу
            {
                MessageBox.Show("Не задана строка поиска!");
                return;
            }
            catch (NullReferenceException)  //перехват исключения при попытке разыменования указателя NULL на объект
            {
                MessageBox.Show("Не задана строка поиска!");
                return;
            }
        }

        public void btnReplace_Click(object sender, EventArgs e)
        {
            if (FindStr == "")
            {
                MessageBox.Show("Не указана строка поиска!");
                return;
            }
            if (form.ActiveControl is RichTextBox)
            {
                if (!chkCase.Checked)       //поиск, нечувствительный к регистру
                {
                    if (((RichTextBox)form.ActiveControl).SelectedText.ToLower() == FindStr.ToLower())
                    {
                        ((RichTextBox)form.ActiveControl).SelectedText = ReplaceStr;
                        btnFindNext_Click(sender, e);
                    }
                    else
                        btnFindNext_Click(sender, e);
                }
                else                        //поиск, чувствительный к регистру            
                {
                    if (((RichTextBox)form.ActiveControl).SelectedText == FindStr)
                    {
                        ((RichTextBox)form.ActiveControl).SelectedText = ReplaceStr;
                        btnFindNext_Click(sender, e);
                    }
                    else
                        btnFindNext_Click(sender, e);
                }
            }
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                {
                    if (!chkCase.Checked)       //поиск, нечувствительный к регистру
                    {
                        if (((RichTextBox)split.ActiveControl).SelectedText.ToLower() == FindStr.ToLower())
                        {
                            ((RichTextBox)split.ActiveControl).SelectedText = ReplaceStr;
                            btnFindNext_Click(sender, e);
                        }
                        else
                            btnFindNext_Click(sender, e);
                    }
                    else                        //поиск, чувствительный к регистру            
                    {
                        if (((RichTextBox)split.ActiveControl).SelectedText == FindStr)
                        {
                            ((RichTextBox)split.ActiveControl).SelectedText = ReplaceStr;
                            btnFindNext_Click(sender, e);
                        }
                        else
                            btnFindNext_Click(sender, e);
                    }
                }
            }
        }

        public void btnReplaceAll_Click(object sender, EventArgs e)
        {
            if (FindStr == "")
            {
                MessageBox.Show("Не указана строка поиска!");
                return;
            }
            pos = 0;
            count = 0;      //число замен
            if (form.ActiveControl is RichTextBox)
            {
                try
                {
                    while (pos < ((RichTextBox)form.ActiveControl).TextLength - FindStr.Length - 1)
                    {
                        try
                        {
                            if(!chkCase.Checked)        //поиск, нечувствительный к регистру
                                pos = ((RichTextBox)form.ActiveControl).Text.ToLower().IndexOf(FindStr.ToLower(), pos);
                            else                        //поиск, чувствительный к регистру
                                pos = ((RichTextBox)form.ActiveControl).Text.IndexOf(FindStr, pos);
                            ((RichTextBox)form.ActiveControl).SelectionStart = pos;
                            ((RichTextBox)form.ActiveControl).SelectionLength = FindStr.Length;
                            ((RichTextBox)form.ActiveControl).SelectedText = ReplaceStr;
                            count++;
                            pos++;
                        }
                        catch (ArgumentOutOfRangeException)
                        {
                            pos = 0;
                            break;
                        }                        
                    }
                }
                catch (NullReferenceException)
                {
                    MessageBox.Show("Не задана строка поиска!");
                    return;
                }
            }
            else if (form.ActiveControl is SplitContainer)
            {
                SplitContainer split = (SplitContainer)form.ActiveControl;
                if (split.ActiveControl is RichTextBox)
                {
                    try
                    {
                        while (pos < ((RichTextBox)split.ActiveControl).TextLength - FindStr.Length - 1)
                        {
                            try
                            {
                                if (!chkCase.Checked)        //поиск, нечувствительный к регистру
                                    pos = ((RichTextBox)split.ActiveControl).Text.ToLower().IndexOf(FindStr.ToLower(), pos);
                                else                        //поиск, чувствительный к регистру
                                    pos = ((RichTextBox)split.ActiveControl).Text.IndexOf(FindStr, pos);
                                ((RichTextBox)split.ActiveControl).SelectionStart = pos;
                                ((RichTextBox)split.ActiveControl).SelectionLength = FindStr.Length;
                                ((RichTextBox)split.ActiveControl).SelectedText = ReplaceStr;
                                count++;
                                pos++;
                            }
                            catch (ArgumentOutOfRangeException)
                            {
                                pos = 0;
                                break;
                            }                            
                        }
                    }
                    catch (NullReferenceException)
                    {
                        MessageBox.Show("Не задана строка поиска!");
                        return;
                    }
                }
            }
            
            if (count.ToString().EndsWith("1"))
                MessageBox.Show("Произведена " + count + " замена.");
            else if (count.ToString().EndsWith("12") || count.ToString().EndsWith("13") || count.ToString().EndsWith("14"))
                MessageBox.Show("Произведено " + count + " замен.");
            else if (count.ToString().EndsWith("2") || count.ToString().EndsWith("3") || count.ToString().EndsWith("4"))
                MessageBox.Show("Произведено " + count + " замены.");
            else
                MessageBox.Show("Произведено " + count + " замен.");

            count = 0;        
        }

        public void btnCancel_Click(object sender, EventArgs e)
        {
            formSearch.Dispose();
        }

        public void FormBinding(Form forma)     //Привязка элементов формы к классу
        {
            form = forma;
        }
    }
}