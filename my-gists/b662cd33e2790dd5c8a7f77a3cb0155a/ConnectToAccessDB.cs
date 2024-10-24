using System;
using System.Data;
using System.Data.OleDb;
using System.Windows.Forms;

namespace Autoscript
{
    public class ConnectClass
    {
        private OleDbConnection connection = new OleDbConnection();    //подключение к источнику данных
        private OleDbCommand command;                                  //команда, выполняемая на базе данных
        private OleDbDataAdapter dataAdapter;                          //набор команд для заполнения DataSet и обновления источника данных

        public string DatabasePath { get; set; }
        public string SqlCommand { get; set; }

        public string ConnectionStringAce
        {
            get
            {
                return "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=" + DatabasePath + "; Persist Security Info=False;";
            }
        }

        private void SetConnect()
        {
            connection.ConnectionString = ConnectionStringAce;
            connection.Open();
            command = connection.CreateCommand();
            command.CommandText = SqlCommand;
        }

        public void InsertIntoBase() {
            try
            {
                SetConnect();
                command.ExecuteNonQuery();
                connection.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public void SelectBase(ComboBox comboBox) {
            try
            {
                SetConnect();
                dataAdapter = new OleDbDataAdapter(command);
                OleDbDataReader reader = command.ExecuteReader();
                comboBox.Items.Clear();
                while (reader.Read())
                {
                    comboBox.Items.Add(reader[0].ToString());
                }
                connection.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public void SelectBase(DataGridView dataGridView) {
            try
            {
                SetConnect();
                dataAdapter = new OleDbDataAdapter(command);
                DataSet dataSet = new DataSet();
                dataAdapter.Fill(dataSet);
                connection.Dispose();
                dataGridView.DataSource = dataSet.Tables[0];                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public void SelectBase(DataTable dataTable)
        {
            try
            {
                SetConnect();
                dataAdapter = new OleDbDataAdapter(command);
                dataTable.Clear();
                dataAdapter.Fill(dataTable);
                connection.Dispose();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public void UpdateBase(DataGridView dataGridView)
        {
            try {
                SetConnect();
                dataAdapter = new OleDbDataAdapter(command);
                DataTable dataTable = new DataTable();
                dataAdapter.Fill(dataTable);
                connection.Dispose();
                dataTable = (DataTable)dataGridView.DataSource;
                dataAdapter.Update(dataTable);                
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        public void CompactAndRepairDb() //Сжатие и восстановление базы данных
        { 
            try
            {
                string tempDb = Application.StartupPath + @"\Temp.accdb";
                Microsoft.Office.Interop.Access.Dao.DBEngine engine = new Microsoft.Office.Interop.Access.Dao.DBEngine();
                engine.CompactDatabase(DatabasePath, tempDb);
                System.IO.File.Delete(DatabasePath);
                System.IO.File.Move(tempDb, DatabasePath);
                MessageBox.Show("Операция выполнена успешно!");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Процесс не удался:\n" + ex.Message);
                return;
            }
        }
    }
}