using System;
using System.Windows.Forms;
using FastColoredTextBoxNS;

namespace Autoscript
{
    public partial class ContextMenuOfTextBox : ContextMenuStrip
    {
        private SplitContainer splitContainer;

        public ContextMenuOfTextBox() { InitializeComponent(); }

        public void Binding(SplitContainer mySplitContainer) { splitContainer = mySplitContainer; }

        private void cutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ((FastColoredTextBox)splitContainer.ActiveControl).Cut();
        }

        private void copyToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ((FastColoredTextBox)splitContainer.ActiveControl).Copy();
        }

        private void pasteToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ((FastColoredTextBox)splitContainer.ActiveControl).Paste();
        }

        private void selectAllToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ((FastColoredTextBox)splitContainer.ActiveControl).Selection.SelectAll();
        }

        private void undoToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (((FastColoredTextBox)splitContainer.ActiveControl).UndoEnabled)
                ((FastColoredTextBox)splitContainer.ActiveControl).Undo();
        }

        private void redoToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (((FastColoredTextBox)splitContainer.ActiveControl).RedoEnabled)
                ((FastColoredTextBox)splitContainer.ActiveControl).Redo();
        }

        private void findToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ((FastColoredTextBox)splitContainer.ActiveControl).ShowFindDialog();
        }

        private void replaceToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ((FastColoredTextBox)splitContainer.ActiveControl).ShowReplaceDialog();
        }
    }
}