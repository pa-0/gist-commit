using System;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace RtbClass
{
    public class MyRichClass : RichTextBox
    {
        private RichTextBox myRich = new RichTextBox();     //Создаём новый ричтекстбокс

        /*Массив ключевых слов языка SQL*/
        private string[] keywords =
            {"add", "all", "alter", "and", "as", "asc", "begin", "between", "break", "by", "case", "char", "close", "coalesce", 
                "commit", "constant", "constraint", "continue", "count", "create", "cursor", "declare", "default", "delete", "desc", 
                "distinct", "do", "double", "drop", "each", "else", "end", "exists", "exit", "for", "foreign", "from", "full", 
                "having", "group", "if", "in", "inner", "insert", "integer", "into", "is", "join", "key", "left", "like", "not", 
                "null", "of", "on", "open", "outer", "order", "primary", "return", "right", "roll", "rollback", "row", "select", 
                "set", "substr", "substring", "then", "to", "trim", "union", "update", "values", "when", "where"};
        public string[] Keywords
        {
            get { return keywords; }
            set { keywords = value; }
        }

        /*Массив цифр*/
        private string[] nums = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "." };
        public string[] Nums
        {
            get { return nums; }
            set { nums = value; }
        }

        /*Массив разделителей*/
        private string[] marks = { "(", ")", "*", ";", ",", "'", "<", "=", ">", "+", "%", "|" };
        public string[] Marks
        {
            get { return marks; }
            set { marks = value; }
        }

        /*Шрифт ричтекстбокса (используем там, где не сохраняются свойства класса)*/
        private Font fontik;
        public Font Fontik
        {
            get { return fontik = new Font("Segoe UI Symbol", 11, FontStyle.Bold); }
            set { fontik = value; }
        }

        /*Метод создания ричтекстбокса перегружен. Координаты и размер указывается только при необходимости*/
        public void AddRichTextbox(RichTextBox myRich, int x, int y, int width, int height) 
        {
            myRich.Width = width;
            myRich.Height = height;
            myRich.Location = new Point(x, y);
            myRich.Font = Fontik;
            myRich.BackColor = Color.Navy;
            myRich.ForeColor = Color.Cyan;
        }
        public void AddRichTextbox(RichTextBox myRich, int x, int y, int width, int height, int bw) 
        {
            myRich.Width = width;
            myRich.Height = height;
            myRich.Location = new Point(x, y);
            myRich.Font = Fontik;
            myRich.BackColor = Color.White;
            myRich.ForeColor = Color.Black;
        }
        public void AddRichTextbox(RichTextBox myRich)                                      
        {
            myRich.Width = 10;
            myRich.Height = 10;
            myRich.Location = new Point(10, 10);
            myRich.Font = Fontik;
            myRich.BackColor = Color.Navy;
            myRich.ForeColor = Color.Cyan;
        }
        public void AddRichTextbox(RichTextBox myRich, int bw)                                      
        {
            myRich.Width = 10;
            myRich.Height = 10;
            myRich.Location = new Point(10, 10);
            myRich.Font = Fontik;
            myRich.BackColor = Color.White;
            myRich.ForeColor = Color.Black;
        }

        public void HighLightSymbol(MyRichClass box, string phrase, Color color)            //Подсветка символов
        {
            int pos = box.SelectionStart;
            string s = box.Text;
            for (int ix = 0; ; )
            {
                int jx = s.IndexOf(phrase, ix, StringComparison.CurrentCultureIgnoreCase);
                if (jx < 0) break;
                box.SelectionStart = jx;
                box.SelectionLength = phrase.Length;
                box.SelectionColor = color;
                ix = jx + 1;
            }
        }
        public void HighLightKeyword(MyRichClass box, string phrase, Color color)      //Подсветка ключевых слов SQL
        {
            string s = box.Text;
            for (int ix = 0; ; )
            {
                int jx = s.IndexOf(phrase, ix, StringComparison.CurrentCultureIgnoreCase);
                if (jx < 0) break;

                if (jx + phrase.Length == s.Length)   //Если текст заканчивается ключевым словом
                {
                    if (jx == 0)                      //Если текст состоит из одного ключевого слова
                    {
                        try
                        {
                            box.SelectionStart = jx;
                            box.SelectionLength = phrase.Length;
                            box.SelectionColor = color;
                            ix = jx + 1; //прибавляем счётчик найденных слов
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Ошибка: " + ex.Message, "Системная информация", 
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                    }
                    if (jx > 0)                        //Если перед ключевым словом есть другие символы
                    {
                        try
                        {
                            char pered = char.Parse(s.Substring(jx - 1, 1)); //символ перед найденным словом из массива keywords[]
                            //подсветка, если символы перед и после слова - не буквы (найденное слово не входит в состав другого)
                            if (!(Char.IsLetter(pered)) & pered.ToString() != "_")
                            {
                                box.SelectionStart = jx;
                                box.SelectionLength = phrase.Length;
                                box.SelectionColor = color;
                            }
                            ix = jx + 1; //прибавляем счётчик найденных слов
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Ошибка: " + ex.Message, "Системная информация",
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                    }
                    MessageBox.Show("Ключевое слово SQL не может быть последним\nПроверьте синтаксис!");
                }
                else                                  //Если текст не заканчивается ключевым словом
                {
                    char posle = char.Parse(s.Substring(jx + phrase.Length, 1)); //символ после найденного ключевого слова
                    if (jx == 0) //Текст начинается ключевым словом, проверяем следующий за ним символ
                    {
                        try
                        {
                            //подсветка, если следующий символ - не буква (найденное слово не входит в состав другого)
                            if (!(Char.IsLetter(posle)))
                            {
                                box.SelectionStart = jx;
                                box.SelectionLength = phrase.Length;
                                box.SelectionColor = color;
                            }
                            ix = jx + 1; //прибавляем счётчик найденных слов
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Ошибка: " + ex.Message, "Системная информация",
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                    }
                    if (jx > 0)                         //Если перед и после ключевого слова есть другие символы
                    {
                        try
                        {
                            char pered = char.Parse(s.Substring(jx - 1, 1)); //символ перед найденным словом из массива keywords[]
                            //подсветка, если символы перед и после слова - не буквы (найденное слово не входит в состав другого)
                            if (!(Char.IsLetter(pered)) & pered.ToString() != "_" & !(Char.IsLetter(posle)))
                            {
                                box.SelectionStart = jx;
                                box.SelectionLength = phrase.Length;
                                box.SelectionColor = color;
                            }
                            ix = jx + 1; //прибавляем счётчик найденных слов
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Ошибка: " + ex.Message, "Системная информация",
                                MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return; }
                    }
                }
            }
        }
    }
}