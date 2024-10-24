using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using iTextSharp.text.pdf;

namespace PDFExtract
{
    public class PDFExtractor
    {
        public void ExtractAttachments()
        { 
        }

        // Origin of the code: http://stackoverflow.com/questions/3007780/itextsharp-how-to-open-read-extract-a-file-attachment
        internal void ExtractAttachments(string file_name, string folderName)
        {
            PdfDictionary documentNames = null;
            PdfDictionary embeddedFiles = null;
            PdfDictionary fileArray = null;
            PdfDictionary file = null;
            PRStream stream = null;

            PdfReader reader = new PdfReader(file_name);
            PdfDictionary catalog = reader.Catalog;
            
            documentNames = (PdfDictionary)PdfReader.GetPdfObject(catalog.Get(PdfName.NAMES));

            if (documentNames != null)
            {
                embeddedFiles = (PdfDictionary)PdfReader.GetPdfObject(documentNames.Get(PdfName.EMBEDDEDFILES));
                if (embeddedFiles != null)
                {
                    PdfArray filespecs = embeddedFiles.GetAsArray(PdfName.NAMES);

                    for (int i = 0; i < filespecs.Size; i++)
                    {
                        // i++; commenting this out as it is a mistake to change the loop variable
                        fileArray = filespecs.GetAsDict(i);
                        file = fileArray.GetAsDict(PdfName.EF);

                        foreach (PdfName key in file.Keys)
                        {
                            stream = (PRStream)PdfReader.GetPdfObject(file.GetAsIndirectObject(key));
                            string attachedFileName = fileArray.GetAsString(key).ToString();
                            byte[] attachedFileBytes = PdfReader.GetStreamBytes(stream);

                            System.IO.File.WriteAllBytes(attachedFileName, attachedFileBytes); 
                        }

                    }
                }    
            }
        }
    }
}