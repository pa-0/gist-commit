namespace Autoscript
{
    partial class FormSettings
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormSettings));
            this.cmdOpen = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.tbDbPath = new System.Windows.Forms.TextBox();
            this.chkboxShow = new System.Windows.Forms.CheckBox();
            this.openFileDialog1 = new System.Windows.Forms.OpenFileDialog();
            this.label1 = new System.Windows.Forms.Label();
            this.Languages = new Autoscript.FilteredComboBox();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // cmdOpen
            // 
            this.cmdOpen.Location = new System.Drawing.Point(174, 22);
            this.cmdOpen.Name = "cmdOpen";
            this.cmdOpen.Size = new System.Drawing.Size(69, 22);
            this.cmdOpen.TabIndex = 2;
            this.cmdOpen.Text = "Выбрать...";
            this.cmdOpen.UseVisualStyleBackColor = true;
            this.cmdOpen.Click += new System.EventHandler(this.cmdOpen_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.tbDbPath);
            this.groupBox1.Controls.Add(this.cmdOpen);
            this.groupBox1.Location = new System.Drawing.Point(11, 12);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(249, 52);
            this.groupBox1.TabIndex = 1;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Путь к базе скриптов";
            // 
            // tbDbPath
            // 
            this.tbDbPath.Location = new System.Drawing.Point(7, 22);
            this.tbDbPath.Name = "tbDbPath";
            this.tbDbPath.ReadOnly = true;
            this.tbDbPath.Size = new System.Drawing.Size(161, 20);
            this.tbDbPath.TabIndex = 3;
            // 
            // chkboxShow
            // 
            this.chkboxShow.AutoSize = true;
            this.chkboxShow.Location = new System.Drawing.Point(18, 95);
            this.chkboxShow.Name = "chkboxShow";
            this.chkboxShow.Size = new System.Drawing.Size(162, 17);
            this.chkboxShow.TabIndex = 8;
            this.chkboxShow.Text = "Показывать примеры ЗнО";
            this.chkboxShow.UseVisualStyleBackColor = true;
            this.chkboxShow.CheckedChanged += new System.EventHandler(this.chkboxShow_CheckedChanged);
            // 
            // openFileDialog1
            // 
            this.openFileDialog1.FileName = "openFileDialog1";
            this.openFileDialog1.Filter = "База данных Access(*.accdb)|*.accdb";
            this.openFileDialog1.RestoreDirectory = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(212, 70);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(97, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Подсветка языка";
            // 
            // Languages
            // 
            this.Languages.Font = new System.Drawing.Font("Tahoma", 10F);
            this.Languages.FormattingEnabled = true;
            this.Languages.Items.AddRange(new object[] {
            "CSharp",
            "Custom",
            "HTML",
            "JS",
            "Lua",
            "PHP",
            "SQL",
            "VB",
            "XML"});
            this.Languages.Location = new System.Drawing.Point(209, 88);
            this.Languages.Name = "Languages";
            this.Languages.Size = new System.Drawing.Size(143, 24);
            this.Languages.Sorted = true;
            this.Languages.TabIndex = 10;
            this.Languages.SelectedIndexChanged += new System.EventHandler(this.Languages_SelectedIndexChanged);
            // 
            // FormSettings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(389, 136);
            this.Controls.Add(this.Languages);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.chkboxShow);
            this.Controls.Add(this.groupBox1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "FormSettings";
            this.Text = "Настройки программы";
            this.Load += new System.EventHandler(this.FormSettings_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Button cmdOpen;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.CheckBox chkboxShow;
        private System.Windows.Forms.TextBox tbDbPath;
        private System.Windows.Forms.OpenFileDialog openFileDialog1;
        private System.Windows.Forms.Label label1;
        private FilteredComboBox Languages;
    }
}