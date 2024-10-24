using System;
using System.Windows.Forms;
using FastColoredTextBoxNS;
using System.Drawing;
using System.Text;

namespace Autoscript
{
    public partial class FormEditDb : Form
    {
        private ConnectClass databaseWorker = new ConnectClass();                     //объект для работы с БД скриптов
        private FormMain formMain = (FormMain)Application.OpenForms[0];
        
        public FormEditDb() { InitializeComponent(); }

        private void FormEditDb_Load(object sender, EventArgs e)
        {
            databaseWorker.DatabasePath = Properties.Settings.Default.DatabasePath;
            databaseWorker.SqlCommand = "SELECT DISTINCT Tema FROM Table1";
            databaseWorker.SelectBase(Topics);

            Topics.ListFilling();

            SetLanguage(Properties.Settings.Default.FctbLanguage);

            contextMenuOfTextBox1.Binding(splitContainer1);
        }

        private bool isExistTopic()
        {
            if (Topics.FindStringExact(Topics.Text) == -1) return false;
            else return true;
        }

        private bool allowedToAddTopic()
        {
            if (DialogResult.Yes == MessageBox.Show("Темы '" + Topics.Text + "' нет. Добавляем новую?",
                "Запрос на добавление темы", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
            {
                return true;
            }
            else return false;
        }

        private void addTopic()
        {
            Topics.Items.Add(Topics.Text);

            formMain.AddNewTopic(Topics.Text);
        }

        private void btnNewRow_Click(object sender, EventArgs e)
        {
            if ((fctbNum.Text == "") && (Topics.Text != "") && (fctbQuestion.Text != "") && (fctbAnswer.Text != ""))
            {
                if (!isExistTopic())
                {
                    if (allowedToAddTopic()) addTopic();
                    else return;
                }

                databaseWorker.SqlCommand = string.Format("INSERT INTO Table1 (Tema,Example_ZnO,Zadacha,Script,Date_create) " +
                    "VALUES ('{0}', '{1}', '{2}', '{3}', '{4}')",
                    Topics.Text,
                    fctbExamples.Text,
                    fctbQuestion.Text.Replace("'", "\''"),
                    fctbAnswer.Text.Replace("'", "\''"),
                    FormatDate(DateTime.Now));

                databaseWorker.InsertIntoBase();
                requestFreshData();                     //запрос свежих данных из базы
                MessageBox.Show("Новый скрипт добавлен в базу данных!", "Системная информация",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
                btnClear_Click(this, e);
            }
        }

        private string FormatDate(DateTime date)
        {
            StringBuilder resultStr = new StringBuilder();
            string MM, DD, YYYY;
                        
            DD = date.Day.ToString(); if (DD.Length == 1) DD = "0" + DD;
            MM = date.Month.ToString(); if (MM.Length == 1) MM = "0" + MM;
            YYYY = date.Year.ToString();

            resultStr.Append(DD); resultStr.Append(".");
            resultStr.Append(MM); resultStr.Append(".");
            resultStr.Append(YYYY);

            return resultStr.ToString();
        }

        private void btnUpdate_Click(object sender, EventArgs e)
        {
            if ((fctbNum.Text.Length > 0) && (Topics.Text.Length > 0) && (fctbQuestion.Text.Length > 0)
                && (fctbAnswer.Text.Length > 0))
            {
                if (!isExistTopic())
                {
                    if (allowedToAddTopic())
                        addTopic();
                    else return;
                }

                databaseWorker.SqlCommand = "UPDATE Table1 SET Tema='" + Topics.Text +
                    "', Zadacha='" + fctbQuestion.Text.Replace("'", "\''") +
                    "', Script='" + fctbAnswer.Text.Replace("'", "\''") +
                    "', Example_ZnO='" + fctbExamples.Text +
                    "', Date_change='" + FormatDate(DateTime.Now) +
                    "' WHERE Number=" + Convert.ToInt32(fctbNum.Text) + ";";
                databaseWorker.UpdateBase(dgv1);
                MessageBox.Show("Изменения сохранены в базе данных.", "Системная информация",
                    MessageBoxButtons.OK, MessageBoxIcon.Information);

                requestFreshData();

                for (int i = 0; i < dgv1.RowCount; ++i)
                {
                    if (dgv1[0, i].Value.ToString().Contains(fctbNum.Text))
                    {
                        dgv1.CurrentCell = dgv1[0, i];        //Возвращаемся к редактируемой строке
                        return;
                    }
                }
            }
        }

        private void btnDelete_Click(object sender, EventArgs e)
        {
            if (dgv1.Rows.Count > 1)
            {
                dgv1.CurrentRow.Selected = true;                       //выделяем текущую строку
                int selectedRowsCount = dgv1.SelectedRows.Count;

                string strDelNumbers = "";                                      //Строка из номеров строк - для скрипта
                for (int i = 0; i < selectedRowsCount; ++i)
                {
                    int selectedRowIndex = dgv1.SelectedRows[i].Index;
                    strDelNumbers += dgv1.Rows[selectedRowIndex].Cells[0].Value.ToString() + " ";
                }
                strDelNumbers = strDelNumbers.Trim().Replace(" ", ", ");        //Кроме последнего пробела, добавляем запятые

                if (DialogResult.Yes == MessageBox.Show("Удалить записи в количестве " + selectedRowsCount + "?",
                    "Подтверждение удаления", MessageBoxButtons.YesNo, MessageBoxIcon.Question))
                {
                    databaseWorker.SqlCommand = "DELETE FROM Table1 WHERE Number IN (" + strDelNumbers + ")";
                    databaseWorker.UpdateBase(dgv1);
                    requestFreshData();
                    MessageBox.Show("Удалено!", "Системная информация", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                btnClear_Click(this, e);
            }
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            foreach (Control found in groupTextBoxes.Controls)
                if (found is FastColoredTextBox)
                    ((FastColoredTextBox)found).Text = "";
        }
        
        private void btnCompactAndRepair_Click(object sender, EventArgs e)
        {
            databaseWorker.CompactAndRepairDb();
        }

        private void FormEditDb_SizeChanged(object sender, EventArgs e)
        {
            scalingControls();
            SettingColumnWidths();                                         
        }

        private void SettingColumnWidths()
        {
            if (dgv1.Rows.Count > 0)
            {
                dgv1.Columns[0].Width = 30;
                dgv1.Columns[1].Width = 70;
                dgv1.Columns[2].Width = Convert.ToInt32(Width * 0.3);
                dgv1.Columns[3].Width = Convert.ToInt32(Width * 0.4);
            }
        }

        private void splitContainer1_SplitterMoved(object sender, SplitterEventArgs e)
        {
            scalingControls();
        }

        private void scalingControls()
        {
            const int indentFromTheBorder = 5;

            groupTextBoxes.Height = splitContainer1.Panel1.Height - groupButtons.Height;

            int textBoxHeight = groupTextBoxes.Bottom - fctbQuestion.Location.Y - indentFromTheBorder;
            fctbQuestion.Height = textBoxHeight;
            fctbAnswer.Size = new Size(groupTextBoxes.Right - fctbAnswer.Location.X - indentFromTheBorder, textBoxHeight);
        }

        private void Topics_SelectedIndexChanged(object sender, EventArgs e)
        {
            requestFreshData();
            SettingColumnWidths();
        }

        private void dgv1_Click(object sender, EventArgs e)
        {
            if (dgv1.Rows.Count > 0)
            {
                btnClear_Click(this, e);

                int numStr = dgv1.CurrentRow.Index;

                fctbNum.Text = dgv1.Rows[numStr].Cells[0].Value.ToString();                
                Topics.Text = dgv1.Rows[numStr].Cells[1].Value.ToString();
                fctbQuestion.Text = dgv1.Rows[numStr].Cells[2].Value.ToString();
                fctbAnswer.Text = dgv1.Rows[numStr].Cells[3].Value.ToString();
                fctbExamples.Text = dgv1.Rows[numStr].Cells[4].Value.ToString();

                string dateCreate = dgv1.Rows[numStr].Cells[5].Value.ToString();
                string dateChange = dgv1.Rows[numStr].Cells[6].Value.ToString();

                if (dateCreate != "") 
                    fctbDateCreate.Text = FormatDate(Convert.ToDateTime(dateCreate));
                if (dateChange != "")
                    fctbDateChange.Text = FormatDate(Convert.ToDateTime(dateChange));
            }
        }

        private void requestFreshData()
        {
            databaseWorker.SqlCommand = "SELECT Number as N, Tema as Тема, Zadacha as Задача, Script as Решение, " +
                "Example_ZnO as Пример, Date_create as Создан, Date_change as Изменён FROM Table1 WHERE " +
                "Tema = '" + Topics.Text + "' ORDER BY Zadacha";

            databaseWorker.SelectBase(dgv1);         
        }

        private void SetLanguage(string lang)
        {
            switch (lang)
            {
                case "SQL":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.SQL;
                    break;
                case "CSharp":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.CSharp;
                    break;
                case "Custom":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.Custom;
                    break;
                case "HTML":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.HTML;
                    break;
                case "JS":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.JS;
                    break;
                case "Lua":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.Lua;
                    break;
                case "PHP":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.PHP;
                    break;
                case "VB":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.VB;
                    break;
                case "XML":
                    foreach (Control found in groupTextBoxes.Controls)
                        if (found is FastColoredTextBox)
                            ((FastColoredTextBox)found).Language = Language.XML;
                    break;
            }
        }
    }
}