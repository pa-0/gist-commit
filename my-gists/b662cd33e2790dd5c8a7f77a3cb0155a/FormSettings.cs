using System;
using System.Windows.Forms;

namespace Autoscript
{
    public partial class FormSettings : Form
    {
        private FormMain formMain = (FormMain)Application.OpenForms[0];         //для обращения к главной форме

        public FormSettings()
        {
            InitializeComponent();
        }

        private void FormSettings_Load(object sender, EventArgs e)
        {
            tbDbPath.Text = Properties.Settings.Default.DatabasePath;
            openFileDialog1.InitialDirectory = tbDbPath.Text.Substring(0, tbDbPath.Text.Length - 14);

            //Показывать ли примеры ЗнО
            if (Properties.Settings.Default.ShowExamples)
                chkboxShow.Checked = true;
            
            //Язык текстовых полей - для подсветки синтаксиса
            Languages.Text = Properties.Settings.Default.FctbLanguage;
        }

        private void cmdOpen_Click(object sender, EventArgs e)
        {
            if (openFileDialog1.ShowDialog() == DialogResult.OK)
            {         
                Properties.Settings.Default.DatabasePath = openFileDialog1.FileName;
                Properties.Settings.Default.Save();

                tbDbPath.Text = openFileDialog1.FileName;               //сохраняем путь к БД на форме
                formMain.ChangeDatabasePath(openFileDialog1.FileName);  //изменяем значение connectionString
                cmdOpen.Enabled = false;                                //чтобы не вылетало ошибки при повторном выборе файла
            }
        }

        private void chkboxShow_CheckedChanged(object sender, EventArgs e)      //Видимость примеров ЗнО на гл.форме
        {
            formMain.DisplayNumberOfRequests(chkboxShow.Checked);         //чтобы не требовалось перезапускать программу

            if (chkboxShow.Checked)
                Properties.Settings.Default.ShowExamples = true;
            else
                Properties.Settings.Default.ShowExamples = false;

            Properties.Settings.Default.Save();
        }

        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)    //Закрытие формы по нажатию Escape
        {
            if (keyData == Keys.Escape) Dispose();
            return base.ProcessCmdKey(ref msg, keyData);
        }

        private void Languages_SelectedIndexChanged(object sender, EventArgs e)
        {
            formMain.SetLanguage(Languages.Text);

            Properties.Settings.Default.FctbLanguage = Languages.Text;
            Properties.Settings.Default.Save();            
        }
    }
}