using System;
using System.Windows.Forms;
using System.Data;

namespace Autoscript
{
    public partial class FormAdvancedSearch : Form
    {
        private FormMain formMain = (FormMain)Application.OpenForms[0];
        private ConnectClass databaseWorker = new ConnectClass();
        private DataTable dataTable1 = new DataTable();

        public FormAdvancedSearch()
        {
            InitializeComponent();
        }

        private void FormAdvancedSearch_Load(object sender, EventArgs e)
        {
            databaseWorker.DatabasePath = Properties.Settings.Default.DatabasePath;

            dgvResult.AutoGenerateColumns = false;
            dgvResult.DataSource = dataTable1;
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            if (fctbSearchLine.Text == "")
                return;

            string lowerSearchLine = fctbSearchLine.Text.ToLower();

            databaseWorker.SqlCommand = "SELECT Number, Tema, Zadacha, Script, Example_ZnO, Date_create, Date_change " +
                "FROM Table1 WHERE " +
                "LCase(Zadacha) like '%" + lowerSearchLine + "%' or " +
                "LCase(Script) like '%" + lowerSearchLine + "%' " +
                "order by Tema, Zadacha;";
            databaseWorker.SelectBase(dataTable1);
            FindAndSelectPhrase();
            SettingColumnWidths();
            dgvResult.Focus();
        }

        private void FindAndSelectPhrase()
        {
            foreach (DataRow row in dataTable1.Rows)
            {
                SetTextBoldByColumn(row, "Zadacha");
                SetTextBoldByColumn(row, "Script");
            }
        }

        private void SetTextBoldByColumn(DataRow row, string colName)
        {
            string plainText;
            if (row.HasVersion(DataRowVersion.Original))
                plainText = row[colName, DataRowVersion.Original].ToString();
            else
                plainText = row[colName].ToString();
            row[colName] = GetRtf(plainText, fctbSearchLine.Text);
        }

        private static string GetRtf(string originalText, string boldText)
        {
            if (string.IsNullOrEmpty(boldText))
                return originalText;

            //Формируем Rtf-строку c русской кодировкой
            string rtf = @"{\rtf1\ansi\ansicpg1251 " +
                originalText.Replace(boldText, @"\b " + boldText + @"\b0 ") + @"}";

            return rtf;
        }

        private void SettingColumnWidths()
        {
            if (dgvResult.Rows.Count > 0)
            {
                dgvResult.Columns[0].Width = 30;
                dgvResult.Columns[1].Width = 70;
                dgvResult.Columns[2].Width = Convert.ToInt32(Width * 0.3);
                dgvResult.Columns[3].Width = Convert.ToInt32(Width * 0.4);
            }
        }

        private void FormAdvancedSearch_SizeChanged(object sender, EventArgs e)
        {
            SettingColumnWidths();
        }

        private void fctbSearchLine_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
                btnSearch_Click(this, e);
        }

        private void dgvResult_Click(object sender, EventArgs e)
        {
            if (dgvResult.Rows.Count > 0)
            {
                int numStr = dgvResult.CurrentRow.Index;
                int system_id = Convert.ToInt32(dgvResult.Rows[numStr].Cells[0].Value);

                if (system_id == 0) return;

                Dispose();
                formMain.ShowFounded(system_id);
            }
        }
    }
}