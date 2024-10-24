REM To join two different documents we can run the following from the console:
pdftk source1.pdf source2.pdf cat output target.pdf

REM We can also join them together using tags:
pdftk A=source1.pdf B=source2.pdf cat A B output target.pdf

REM And of course we can use wild cards:
pdftk *.pdf cat output target.pdf

REM To separate pages from multiple documents and create a new document with them, we do the following:
pdftk A=source1.pdf B=source2.pdf cat A1-7 B1-5 output target.pdf

REM Another example with a single document:
pdftk A=source1.pdf cat A1-12 A14-end output target.pdf

REM To encrypt with a 128-bit key (default option) and restrict all permissions (default option):
pdftk source.pdf output target_encrypted.pdf owner_pw foopass

REM To encrypt the same as the previous case but assigning a password "miclv" that allows you to open the output file:
pdftk source.pdf output target_encrypted.pdf owner_pw foo user_pw miclv

REM Same as the previous case but with permission to print:
pdftk source.pdf output target_encrypted.pdf owner_pw foo user_pw miclv allow printing

REM To decrypt:
pdftk secured.pdf input_pw foopass output unsecure.pdf

REM To repair a corrupted pdf file:
pdftk corrupted.pdf output repaired.pdf

REM To unzip a pdf file for later editing in a text editor:
pdftk midoc.pdf output midoc_desc.pdf uncompress

REM To separate each of the pages of the document:
pdftk in.pdf burst

REM To generate a document report:
pdftk source.pdf dump_data output report.txt

REM Multistamp
pdftk fondo.pdf multistamp stamp.pdf output salida.pdf

REM Stamp
pdftk souce.pdf stamp stamp.pdf output target.pdf

REM Compress
ps2pdf  input.pdf  output.pdf
pdftk input.pdf output output.pdf compress
convert input.pdf -compress Zip output.pdf

---------------------------------------------------


PDFTK archivo1.pdf archivo2.pdf Cat Output salida.pdf


pdftk A=archivo1.pdf B=archivo2.pdf cat A B output salida.pdf


PDFTK *.pdf Cat Output salida.pdf


pdftk A=uno.pdf B=dos.pdf cat A1-7 B1-5 output salida.pdf


pdftk A=archivo1.pdf cat A1-12 A14-end output salida.pdf











