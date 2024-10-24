namespace Autoscript
{
    partial class FormMain
    {
        /// <summary>
        /// Требуется переменная конструктора.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Освободить все используемые ресурсы.
        /// </summary>
        /// <param name="disposing">истинно, если управляемый ресурс должен быть удален; иначе ложно.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Код, автоматически созданный конструктором форм Windows

        /// <summary>
        /// Обязательный метод для поддержки конструктора - не изменяйте
        /// содержимое данного метода при помощи редактора кода.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormMain));
            this.mainMenu = new System.Windows.Forms.MenuStrip();
            this.cmdAdvancedSearch = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdBuffer = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdSQL = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdClear = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdDatabase = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdSettings = new System.Windows.Forms.ToolStripMenuItem();
            this.cmdAbout = new System.Windows.Forms.ToolStripMenuItem();
            this.dgrvTemp = new System.Windows.Forms.DataGridView();
            this.label2 = new System.Windows.Forms.Label();
            this.label1 = new System.Windows.Forms.Label();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.tabControl2 = new System.Windows.Forms.TabControl();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.lblExample = new System.Windows.Forms.Label();
            this.tbExample = new System.Windows.Forms.TextBox();
            this.grboxExamples = new System.Windows.Forms.GroupBox();
            this.tbDateCreate = new System.Windows.Forms.TextBox();
            this.tbDateChange = new System.Windows.Forms.TextBox();
            this.lblDateCreate = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.Questions = new Autoscript.FilteredComboBox();
            this.Topics = new Autoscript.FilteredComboBox();
            this.fctbZapros = new FastColoredTextBoxNS.FastColoredTextBox();
            this.contextMenuOfTextBox1 = new Autoscript.ContextMenuOfTextBox();
            this.fctbScript = new FastColoredTextBoxNS.FastColoredTextBox();
            this.mainMenu.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgrvTemp)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabControl2.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.grboxExamples.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.fctbZapros)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.fctbScript)).BeginInit();
            this.SuspendLayout();
            // 
            // mainMenu
            // 
            this.mainMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.cmdAdvancedSearch,
            this.cmdBuffer,
            this.cmdSQL,
            this.cmdClear,
            this.cmdDatabase,
            this.cmdSettings,
            this.cmdAbout});
            this.mainMenu.Location = new System.Drawing.Point(0, 0);
            this.mainMenu.Name = "mainMenu";
            this.mainMenu.ShowItemToolTips = true;
            this.mainMenu.Size = new System.Drawing.Size(831, 24);
            this.mainMenu.TabIndex = 3;
            // 
            // cmdAdvancedSearch
            // 
            this.cmdAdvancedSearch.Image = global::Autoscript.Properties.Resources.search;
            this.cmdAdvancedSearch.Name = "cmdAdvancedSearch";
            this.cmdAdvancedSearch.Size = new System.Drawing.Size(28, 20);
            this.cmdAdvancedSearch.Click += new System.EventHandler(this.cmdAdvancedSearch_Click);
            // 
            // cmdBuffer
            // 
            this.cmdBuffer.Image = global::Autoscript.Properties.Resources.copy;
            this.cmdBuffer.Name = "cmdBuffer";
            this.cmdBuffer.Size = new System.Drawing.Size(28, 20);
            this.cmdBuffer.Tag = "";
            this.cmdBuffer.ToolTipText = "Копировать скрипт в буфер обмена";
            this.cmdBuffer.Click += new System.EventHandler(this.cmdBuffer_Click);
            // 
            // cmdSQL
            // 
            this.cmdSQL.Image = global::Autoscript.Properties.Resources.disk_blue;
            this.cmdSQL.Name = "cmdSQL";
            this.cmdSQL.Size = new System.Drawing.Size(28, 20);
            this.cmdSQL.Tag = "";
            this.cmdSQL.ToolTipText = "Сохранить скрипт в  SQl файл";
            this.cmdSQL.Click += new System.EventHandler(this.cmdSQL_Click);
            // 
            // cmdClear
            // 
            this.cmdClear.Image = global::Autoscript.Properties.Resources.garbage_empty;
            this.cmdClear.Name = "cmdClear";
            this.cmdClear.Size = new System.Drawing.Size(28, 20);
            this.cmdClear.Tag = "";
            this.cmdClear.ToolTipText = "Очистить форму";
            this.cmdClear.Click += new System.EventHandler(this.cmdClear_Click);
            // 
            // cmdDatabase
            // 
            this.cmdDatabase.Image = global::Autoscript.Properties.Resources.server_into;
            this.cmdDatabase.Name = "cmdDatabase";
            this.cmdDatabase.Size = new System.Drawing.Size(28, 20);
            this.cmdDatabase.Tag = "";
            this.cmdDatabase.ToolTipText = "Работа с базой данных";
            this.cmdDatabase.Click += new System.EventHandler(this.cmdDatabase_Click);
            // 
            // cmdSettings
            // 
            this.cmdSettings.Image = global::Autoscript.Properties.Resources.wrench;
            this.cmdSettings.Name = "cmdSettings";
            this.cmdSettings.Size = new System.Drawing.Size(28, 20);
            this.cmdSettings.Tag = "";
            this.cmdSettings.ToolTipText = "Настройки программы";
            this.cmdSettings.Click += new System.EventHandler(this.cmdSettings_Click);
            // 
            // cmdAbout
            // 
            this.cmdAbout.Image = global::Autoscript.Properties.Resources.about;
            this.cmdAbout.Name = "cmdAbout";
            this.cmdAbout.Size = new System.Drawing.Size(28, 20);
            this.cmdAbout.Tag = "";
            this.cmdAbout.ToolTipText = "О программе";
            this.cmdAbout.Click += new System.EventHandler(this.cmdAbout_Click);
            // 
            // dgrvTemp
            // 
            this.dgrvTemp.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dgrvTemp.Location = new System.Drawing.Point(800, 24);
            this.dgrvTemp.Name = "dgrvTemp";
            this.dgrvTemp.Size = new System.Drawing.Size(19, 39);
            this.dgrvTemp.TabIndex = 16;
            this.dgrvTemp.Visible = false;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(3, 54);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(43, 13);
            this.label2.TabIndex = 20;
            this.label2.Text = "Задача";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(3, 27);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(34, 13);
            this.label1.TabIndex = 19;
            this.label1.Text = "Тема";
            // 
            // splitContainer1
            // 
            this.splitContainer1.Location = new System.Drawing.Point(0, 73);
            this.splitContainer1.Name = "splitContainer1";
            this.splitContainer1.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.tabControl1);
            this.splitContainer1.Panel1.Tag = "";
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.tabControl2);
            this.splitContainer1.Panel2.Tag = "";
            this.splitContainer1.Size = new System.Drawing.Size(837, 500);
            this.splitContainer1.SplitterDistance = 221;
            this.splitContainer1.SplitterWidth = 3;
            this.splitContainer1.TabIndex = 2;
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(837, 221);
            this.tabControl1.TabIndex = 0;
            this.tabControl1.GotFocus += new System.EventHandler(this.TabControl1_GotFocus);
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.fctbZapros);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(829, 195);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "Содержание ЗнО";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // tabControl2
            // 
            this.tabControl2.Controls.Add(this.tabPage2);
            this.tabControl2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl2.Location = new System.Drawing.Point(0, 0);
            this.tabControl2.Name = "tabControl2";
            this.tabControl2.SelectedIndex = 0;
            this.tabControl2.Size = new System.Drawing.Size(837, 276);
            this.tabControl2.TabIndex = 0;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.fctbScript);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(829, 250);
            this.tabPage2.TabIndex = 0;
            this.tabPage2.Text = "Решение";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // lblExample
            // 
            this.lblExample.AutoSize = true;
            this.lblExample.Location = new System.Drawing.Point(6, 26);
            this.lblExample.Name = "lblExample";
            this.lblExample.Size = new System.Drawing.Size(18, 13);
            this.lblExample.TabIndex = 21;
            this.lblExample.Text = "ID";
            // 
            // tbExample
            // 
            this.tbExample.Location = new System.Drawing.Point(30, 23);
            this.tbExample.Name = "tbExample";
            this.tbExample.Size = new System.Drawing.Size(82, 20);
            this.tbExample.TabIndex = 0;
            // 
            // grboxExamples
            // 
            this.grboxExamples.Controls.Add(this.tbExample);
            this.grboxExamples.Controls.Add(this.lblExample);
            this.grboxExamples.Location = new System.Drawing.Point(414, 29);
            this.grboxExamples.Name = "grboxExamples";
            this.grboxExamples.Size = new System.Drawing.Size(123, 54);
            this.grboxExamples.TabIndex = 4;
            this.grboxExamples.TabStop = false;
            this.grboxExamples.Text = "Примеры ЗнО";
            // 
            // tbDateCreate
            // 
            this.tbDateCreate.Location = new System.Drawing.Point(632, 27);
            this.tbDateCreate.Name = "tbDateCreate";
            this.tbDateCreate.Size = new System.Drawing.Size(63, 20);
            this.tbDateCreate.TabIndex = 5;
            // 
            // tbDateChange
            // 
            this.tbDateChange.Location = new System.Drawing.Point(632, 50);
            this.tbDateChange.Name = "tbDateChange";
            this.tbDateChange.Size = new System.Drawing.Size(63, 20);
            this.tbDateChange.TabIndex = 6;
            // 
            // lblDateCreate
            // 
            this.lblDateCreate.AutoSize = true;
            this.lblDateCreate.Location = new System.Drawing.Point(545, 34);
            this.lblDateCreate.Name = "lblDateCreate";
            this.lblDateCreate.Size = new System.Drawing.Size(85, 13);
            this.lblDateCreate.TabIndex = 24;
            this.lblDateCreate.Text = "Скрипт создан:";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(539, 56);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(93, 13);
            this.label4.TabIndex = 25;
            this.label4.Text = "Скрипт изменён:";
            // 
            // Questions
            // 
            this.Questions.Font = new System.Drawing.Font("Tahoma", 10F);
            this.Questions.FormattingEnabled = true;
            this.Questions.Location = new System.Drawing.Point(59, 50);
            this.Questions.Name = "Questions";
            this.Questions.Size = new System.Drawing.Size(291, 24);
            this.Questions.Sorted = true;
            this.Questions.TabIndex = 1;
            this.Questions.SelectedIndexChanged += new System.EventHandler(this.Questions_SelectedIndexChanged);
            // 
            // Topics
            // 
            this.Topics.Font = new System.Drawing.Font("Tahoma", 10F);
            this.Topics.FormattingEnabled = true;
            this.Topics.Location = new System.Drawing.Point(59, 24);
            this.Topics.Name = "Topics";
            this.Topics.Size = new System.Drawing.Size(291, 24);
            this.Topics.Sorted = true;
            this.Topics.TabIndex = 0;
            this.Topics.SelectedIndexChanged += new System.EventHandler(this.Topics_SelectedIndexChanged);
            // 
            // fctbZapros
            // 
            this.fctbZapros.AutoCompleteBracketsList = new char[] {
        '(',
        ')',
        '{',
        '}',
        '[',
        ']',
        '\"',
        '\"',
        '\'',
        '\''};
            this.fctbZapros.AutoIndentCharsPatterns = "";
            this.fctbZapros.AutoScrollMinSize = new System.Drawing.Size(0, 17);
            this.fctbZapros.BackBrush = null;
            this.fctbZapros.CharHeight = 17;
            this.fctbZapros.CharWidth = 8;
            this.fctbZapros.CommentPrefix = "--";
            this.fctbZapros.ContextMenuStrip = this.contextMenuOfTextBox1;
            this.fctbZapros.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.fctbZapros.DisabledColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.fctbZapros.Dock = System.Windows.Forms.DockStyle.Fill;
            this.fctbZapros.Font = new System.Drawing.Font("Consolas", 11F);
            this.fctbZapros.IndentBackColor = System.Drawing.SystemColors.Control;
            this.fctbZapros.IsReplaceMode = false;
            this.fctbZapros.Language = FastColoredTextBoxNS.Language.SQL;
            this.fctbZapros.LeftBracket = '(';
            this.fctbZapros.Location = new System.Drawing.Point(3, 3);
            this.fctbZapros.Name = "fctbZapros";
            this.fctbZapros.Paddings = new System.Windows.Forms.Padding(0);
            this.fctbZapros.RightBracket = ')';
            this.fctbZapros.SelectionColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(255)))));
            this.fctbZapros.ServiceColors = ((FastColoredTextBoxNS.ServiceColors)(resources.GetObject("fctbZapros.ServiceColors")));
            this.fctbZapros.Size = new System.Drawing.Size(823, 189);
            this.fctbZapros.TabIndex = 0;
            this.fctbZapros.WordWrap = true;
            this.fctbZapros.Zoom = 100;
            // 
            // contextMenuOfTextBox1
            // 
            this.contextMenuOfTextBox1.Name = "contextMenu";
            this.contextMenuOfTextBox1.Size = new System.Drawing.Size(186, 198);
            // 
            // fctbScript
            // 
            this.fctbScript.AutoCompleteBracketsList = new char[] {
        '(',
        ')',
        '{',
        '}',
        '[',
        ']',
        '\"',
        '\"',
        '\'',
        '\''};
            this.fctbScript.AutoIndentCharsPatterns = "";
            this.fctbScript.AutoScrollMinSize = new System.Drawing.Size(0, 17);
            this.fctbScript.BackBrush = null;
            this.fctbScript.CharHeight = 17;
            this.fctbScript.CharWidth = 8;
            this.fctbScript.CommentPrefix = "--";
            this.fctbScript.ContextMenuStrip = this.contextMenuOfTextBox1;
            this.fctbScript.Cursor = System.Windows.Forms.Cursors.IBeam;
            this.fctbScript.DisabledColor = System.Drawing.Color.FromArgb(((int)(((byte)(224)))), ((int)(((byte)(224)))), ((int)(((byte)(224)))));
            this.fctbScript.Dock = System.Windows.Forms.DockStyle.Fill;
            this.fctbScript.Font = new System.Drawing.Font("Consolas", 11F);
            this.fctbScript.IndentBackColor = System.Drawing.SystemColors.Control;
            this.fctbScript.IsReplaceMode = false;
            this.fctbScript.Language = FastColoredTextBoxNS.Language.SQL;
            this.fctbScript.LeftBracket = '(';
            this.fctbScript.Location = new System.Drawing.Point(3, 3);
            this.fctbScript.Name = "fctbScript";
            this.fctbScript.Paddings = new System.Windows.Forms.Padding(0);
            this.fctbScript.RightBracket = ')';
            this.fctbScript.SelectionColor = System.Drawing.Color.FromArgb(((int)(((byte)(50)))), ((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(255)))));
            this.fctbScript.ServiceColors = ((FastColoredTextBoxNS.ServiceColors)(resources.GetObject("fctbScript.ServiceColors")));
            this.fctbScript.Size = new System.Drawing.Size(823, 244);
            this.fctbScript.TabIndex = 0;
            this.fctbScript.WordWrap = true;
            this.fctbScript.Zoom = 100;
            // 
            // FormMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(831, 569);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.lblDateCreate);
            this.Controls.Add(this.tbDateCreate);
            this.Controls.Add(this.tbDateChange);
            this.Controls.Add(this.Questions);
            this.Controls.Add(this.Topics);
            this.Controls.Add(this.dgrvTemp);
            this.Controls.Add(this.grboxExamples);
            this.Controls.Add(this.splitContainer1);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.mainMenu);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.KeyPreview = true;
            this.MainMenuStrip = this.mainMenu;
            this.Name = "FormMain";
            this.Text = "Автоскрипт - подборка типовых скриптов";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.SizeChanged += new System.EventHandler(this.Form1_SizeChanged);
            this.mainMenu.ResumeLayout(false);
            this.mainMenu.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.dgrvTemp)).EndInit();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabControl2.ResumeLayout(false);
            this.tabPage2.ResumeLayout(false);
            this.grboxExamples.ResumeLayout(false);
            this.grboxExamples.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.fctbZapros)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.fctbScript)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.MenuStrip mainMenu;
        private System.Windows.Forms.ToolStripMenuItem cmdBuffer;
        private System.Windows.Forms.ToolStripMenuItem cmdSQL;
        private System.Windows.Forms.ToolStripMenuItem cmdClear;
        private System.Windows.Forms.ToolStripMenuItem cmdDatabase;
        private System.Windows.Forms.ToolStripMenuItem cmdAbout;
        private System.Windows.Forms.DataGridView dgrvTemp;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.SplitContainer splitContainer1;
        private System.Windows.Forms.ToolStripMenuItem cmdSettings;
        private System.Windows.Forms.TabControl tabControl2;
        private System.Windows.Forms.TabPage tabPage2;
        private System.Windows.Forms.TabControl tabControl1;
        private System.Windows.Forms.TabPage tabPage1;
        private System.Windows.Forms.Label lblExample;
        private System.Windows.Forms.TextBox tbExample;
        private System.Windows.Forms.GroupBox grboxExamples;
        private FastColoredTextBoxNS.FastColoredTextBox fctbZapros;
        private FastColoredTextBoxNS.FastColoredTextBox fctbScript;
        private FilteredComboBox Topics;
        private FilteredComboBox Questions;
        private ContextMenuOfTextBox contextMenuOfTextBox1;
        private System.Windows.Forms.TextBox tbDateCreate;
        private System.Windows.Forms.TextBox tbDateChange;
        private System.Windows.Forms.Label lblDateCreate;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.ToolStripMenuItem cmdAdvancedSearch;