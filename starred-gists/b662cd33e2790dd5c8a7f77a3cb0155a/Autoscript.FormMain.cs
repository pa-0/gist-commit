using System;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using FastColoredTextBoxNS;

namespace Autoscript
{
    public partial class FormMain : Form
    {
        private ConnectClass databaseWorker = new ConnectClass();             //объект для работы с БД скриптов        

        public FormMain()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (!File.Exists(Properties.Settings.Default.DatabasePath)) {
                Properties.Settings.Default.DatabasePath = Application.StartupPath + @"\Scripts.accdb";
            }
            databaseWorker.DatabasePath = Properties.Settings.Default.DatabasePath;
            databaseWorker.SqlCommand = "SELECT DISTINCT Tema FROM Table1";
            databaseWorker.SelectBase(Topics);

            Topics.ListFilling();

            DisplayNumberOfRequests(Properties.Settings.Default.ShowExamples);
            SetLanguage(Properties.Settings.Default.FctbLanguage);

            contextMenuOfTextBox1.Binding(splitContainer1);
        }

        private void Form1_SizeChanged(object sender, EventArgs e)
        {
            splitContainer1.Height = Height - 107;
            splitContainer1.Width = Width - 10;
        }

        public void AddNewTopic(string newTopic)         //для добавления новой темы из окна редакт-я БД
        {
            Topics.Items.Add(newTopic);
            Topics.ListFilling();
        }

        public void ChangeDatabasePath(string newPath)   //обновление пути к БД скриптов без перезапуска программы
        {
            databaseWorker.DatabasePath = newPath;
        }

        public void DisplayNumberOfRequests(bool display)
        {
            if (display) grboxExamples.Visible = true;
            else grboxExamples.Visible = false;
        }

        public void SetLanguage(string lang)
        {
            switch (lang)
            {
                case "SQL":
                    fctbScript.Language = Language.SQL; fctbZapros.Language = Language.SQL; break;
                case "CSharp":
                    fctbScript.Language = Language.CSharp; fctbZapros.Language = Language.CSharp; break;
                case "Custom":
                    fctbScript.Language = Language.Custom; fctbZapros.Language = Language.Custom; break;
                case "HTML":
                    fctbScript.Language = Language.HTML; fctbZapros.Language = Language.HTML; break;
                case "JS":
                    fctbScript.Language = Language.JS; fctbZapros.Language = Language.JS; break;
                case "Lua":
                    fctbScript.Language = Language.Lua; fctbZapros.Language = Language.Lua; break;
                case "PHP":
                    fctbScript.Language = Language.PHP; fctbZapros.Language = Language.PHP; break;
                case "VB":
                    fctbScript.Language = Language.VB; fctbZapros.Language = Language.VB; break;
                case "XML":
                    fctbScript.Language = Language.XML; fctbZapros.Language = Language.XML; break;
            }
        }

        public void ShowFounded(int num)
        {
            databaseWorker.SqlCommand = "SELECT Tema, Zadacha FROM Table1 WHERE Number=" + num;
            databaseWorker.SelectBase(dgrvTemp);

            Topics.Text = dgrvTemp.Rows[0].Cells[0].Value.ToString();
            Questions.Text = dgrvTemp.Rows[0].Cells[1].Value.ToString();
        }

        private void Topics_SelectedIndexChanged(object sender, EventArgs e)
        {
            databaseWorker.SqlCommand = "SELECT Zadacha FROM Table1 WHERE Tema='" + Topics.Text + "';";
            databaseWorker.SelectBase(Questions);

            Questions.Focus();
            Questions.ListFilling();            
            Questions.Text = "";           
        }

        private void Questions_SelectedIndexChanged(object sender, EventArgs e)
        {
            databaseWorker.SqlCommand = "SELECT Script, Example_ZnO, Date_create, Date_change FROM Table1 WHERE Tema='" +
                Topics.Text + "' and Zadacha='" + Questions.Text + "';";
            databaseWorker.SelectBase(dgrvTemp);

            fctbScript.Text = dgrvTemp.Rows[0].Cells[0].Value.ToString();
            tbExample.Text = dgrvTemp.Rows[0].Cells[1].Value.ToString();
            tbDateCreate.Text = dgrvTemp.Rows[0].Cells[2].Value.ToString();
            tbDateChange.Text = dgrvTemp.Rows[0].Cells[3].Value.ToString();

            fctbScript.Focus();
        }

        private void TabControl1_GotFocus(object sender, EventArgs e)   //При получении фокуса переходить в Решение
        {
            fctbScript.Focus();
        }

        // Главное меню формы
        private void cmdAdvancedSearch_Click(object sender, EventArgs e)
        {
            FormAdvancedSearch formAdvancedSearch = new FormAdvancedSearch();
            formAdvancedSearch.StartPosition = FormStartPosition.CenterParent;
            formAdvancedSearch.ShowDialog();
        }

        private void cmdBuffer_Click(object sender, EventArgs e) {
            if (fctbScript.Text.Length > 0)            
            {
                //Clipboard.SetText(fctbScript.Text.Replace("\n", "\r\n"));
                Clipboard.SetText(fctbScript.Text.Replace("\r\n", System.Environment.NewLine));
            }
        }

        private void cmdSQL_Click(object sender, EventArgs e)
        {
            if (fctbScript.Text.Length > 0)
            {
                string path = "C:\\";       //каталог выгрузки    
                string tema = Topics.Text;
                string tail = ".txt";      //окончание имени файла
                string nullname = path + tema + tail;

                if (!File.Exists(nullname)) //первый файл категории в каталоге выгрузки
                {
                    var contents = fctbZapros.Text.Replace("\n", "\r\n") + Environment.NewLine + fctbScript.Text.Replace("\n", "\r\n");
                    try
                    {
                        File.WriteAllText(nullname, contents, Encoding.GetEncoding(1251)); //выгружаем в кириллице
                        MessageBox.Show("Выгружен в\n" + nullname);
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Ошибка: " + ex.Message);
                        return;
                    }
                }
                else                        //файлы этой категории уже есть
                {
                    for (int i = 1; ;)
                    {
                        string fullname = path + tema + "_" + i.ToString() + tail;
                        if (!File.Exists(fullname))
                        {
                            var contents = fctbZapros.Text.Replace("\n", "\r\n") + Environment.NewLine + fctbScript.Text.Replace("\n", "\r\n");
                            try
                            {
                                File.WriteAllText(fullname, contents, Encoding.GetEncoding(1251)); //выгружаем в кириллице
                                MessageBox.Show("Скрипт выгружен в файл\n" + fullname);
                                break;
                            }
                            catch (Exception ex)
                            {
                                MessageBox.Show("Ошибка: " + ex.Message);
                                return;
                            }
                        }
                        else ++i;
                    }
                }
            }
        }

        private void cmdClear_Click(object sender, EventArgs e) {
            Questions.Text = "";
            fctbZapros.Clear(); fctbScript.Clear();
            tbExample.Clear(); tbDateCreate.Clear(); tbDateChange.Clear();
        }

        private void cmdDatabase_Click(object sender, EventArgs e)
        {
            foreach (Form f in Application.OpenForms)   //Поиск среди уже открытых форм
            {
                if (f.Name == "FormEditDb")
                {
                    f.Activate();
                    f.WindowState = FormWindowState.Maximized;
                    return;
                }
            }
            FormEditDb formEditDb = new FormEditDb();
            formEditDb.Location = new Point(100, 100);
            formEditDb.Show();
        }

        private void cmdSettings_Click(object sender, EventArgs e)
        {
            FormSettings formSettings = new FormSettings();
            formSettings.StartPosition = FormStartPosition.CenterParent;
            formSettings.ShowDialog();                                 
        }

        private void cmdAbout_Click(object sender, EventArgs e)
        {
            MessageBox.Show("          Автоскрипт\n Программа для быстрого\nподбора нужных скриптов",
                "Системная информация", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}