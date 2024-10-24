'Description:
'On first opening the workbook a log file is created. Every time the workbook is opened after that, the date & time 
'is checked against that in the log file. If the trial period has expired the user is given a message stating that 
'it's expired. The users data in the workbook is then transferred to separate files with a promotional text message 
'and the workbook rendered unusable. A further alternative is to not give the user any possibility of resuscitating 
'the workbook. To do this you will need to insert the code from following url to completely delete the workbook
'in the appropriate place(s). (see http://www.vbaexpress.com/kb/getarticle.php?kb_id=540) 
'
'Discussion:
'You may have spent a lot of time developing a product for sale yet you want to allow potential customers a set time to try out your product first. This code will allow you to do that. The examples in the attachment are unlocked for you to view the code, but naturally it is assumed you will lock your project and that you will also force the user to enable macros (see here http://www.vbaexpress.com/kb/getarticle.php?kb_id=578). If the project is locked for viewing there is a fairly good degree of security provided but it must be remembered that this is not infallible, however it will stop MOST people from copying your code. Apart from altering the trial period you've set in your code, the only other way to get around this trial period is to find the log file containing the start time and delete it. (Note: if it has been deleted a new file will be generated next time the workbook is opened) if you give the log file some innocuous name and place it in some obscure part of the hard drive most people will be unable to find and delete it. {If someone is so determined to hack into your code to extend the time period and/or continually find and delete the log file, I say - good luck to them :o) } 
'
'Code:
			
Option Explicit 
 
Private Sub Workbook_Open() 
    Dim StartTime#, CurrentTime# 
     
     '*****************************************
     'SET YOUR OWN TRIAL PERIOD BELOW
     'Integers (1, 2, 3,...etc) = number of days use
     '1/24 = 1Hr, 1/48 = 30Mins, 1/144 = 10Mins use
     
    Const TrialPeriod# = 30 '< 30 days trial
     
     'set your own obscure path and file-name
    Const ObscurePath$ = "C:\" 
    Const ObscureFile$ = "TestFileLog.Log" 
     '*****************************************
     
    If Dir(ObscurePath & ObscureFile) = Empty Then 
        StartTime = Format(Now, "#0.#########0") 
        Open ObscurePath & ObscureFile For Output As #1 
        Print #1, StartTime 
    Else 
        Open ObscurePath & ObscureFile For Input As #1 
        Input #1, StartTime 
        CurrentTime = Format(Now, "#0.#########0") 
        If CurrentTime < StartTime + TrialPeriod Then 
            Close #1 
            Exit Sub 
        Else 
            If [A1] <> "Expired" Then 
                MsgBox "Sorry, your trial period has expired - your data" & vbLf & _ 
                "will now be extracted and saved for you..." & vbLf & _ 
                "" & vbLf & _ 
                "This workbook will then be made unusable." 
                Close #1 
                SaveShtsAsBook 
                [A1] = "Expired" 
                ActiveWorkbook.Save 
                Application.Quit 
            ElseIf [A1] = "Expired" Then 
                Close #1 
                Application.Quit 
            End If 
        End If 
    End If 
    Close #1 
End Sub 
 
Sub SaveShtsAsBook() 
    Dim Sheet As Worksheet, SheetName$, MyFilePath$, N& 
    MyFilePath$ = ActiveWorkbook.Path & "\" & _ 
    Left(ThisWorkbook.Name, Len(ThisWorkbook.Name) - 4) 
    With Application 
        .ScreenUpdating = False 
        .DisplayAlerts = False 
        On Error Resume Next '<< a folder exists
        MkDir MyFilePath '<< create a folder
        For N = 1 To Sheets.Count 
            Sheets(N).Activate 
            SheetName = ActiveSheet.Name 
            Cells.Copy 
            Workbooks.Add (xlWBATWorksheet) 
            With ActiveWorkbook 
                With .ActiveSheet 
                    .Paste 
                     '//N.B. to remove all the cell formulas,
                     '//uncomment the 4 lines of code below...
                     'With Cells
                     '.Copy
                     '.PasteSpecial Paste:=xlPasteValues
                     'End With
                    .Name = SheetName 
                    [A1].Select 
                End With 
                 'save book in this folder
                .SaveAs Filename:=MyFilePath _ 
                & "\" & SheetName & ".xls" 
                .Close SaveChanges:=True 
            End With 
            .CutCopyMode = False 
        Next 
    End With 
    Open MyFilePath & "\READ ME.log" For Output As #1 
    Print #1, "Thank you for trying out this product." 
    Print #1, "If it meets your requirements, visit" 
    Print #1, "http://www.xxxxx/xxxx to purchase" 
    Print #1, "the full (unrestricted) version..." 
    Close #1 
End Sub 
			
'How to use:
'1. Open an Excel workbook
'2. Select Tools/Macro/Visual Basic Editor
'3. In the VBE window, select Tools/Project Explorer
'4. Select the ThisWorkbook module
'5. Copy and paste the code into the Module
'6. Now select File/Close and Return To Microsoft Excel
'7. Save your changes and close the workbook...
'8. Test the code:
  'In the folder in the attachment there are examples for trial periods of:
  '10 minutes, 1 hour, 1 day, 30 days, and 1 year.
  'Extract these files and COPY the 10 minute example to the desktop.
  'Open this example then have a look in the hard-drive for the file 'TestFileLog'
  'Close and open this example a few times to ensure that it's usable then wait 10 or more minutes...
  'Open the file again and you will be shown a message box saying your trial period has expired.
  'On clicking OK on the message box, the workbook will close a few seconds later.
  'If you now try to open this workbook it will instantly close.
  'Now create another copy of the 10 minute example on the desktop and try to use it...
  '(To use another copy you must find and delete the existing 'TestFileLog' before you can use it)
  'Now try the other versions (naturally you will have to wait longer to test them fully)