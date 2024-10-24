Sub RemoveExtraSpaces()
    Selection.InsertAfter "®®"
    With Selection.Find
      .ClearFormatting
      .Replacement.ClearFormatting
      .Text = "^p"
      'What to replace it with
      .Replacement.Text = " "
      .Forward = True
      .Wrap = wdFindStop
      .Format = False
      .MatchWildcards = False
      .Execute Replace:=wdReplaceAll
      'multi spaces with single space
      .Text = " [ ]@([! ])"
      .Replacement.Text = " \1"
      .Forward = True
      .Wrap = wdFindStop
      .Format = False
      .MatchWildcards = True
      .Execute Replace:=wdReplaceAll
      'hyphenation
      .Text = "- "
      .Replacement.Text = ""
      .Forward = True
      .Wrap = wdFindStop
      .Format = False
      .MatchWildcards = True
      .Execute Replace:=wdReplaceAll
      .Text = "®®"
      .Replacement.Text = "^p"
      .Forward = True
      .Wrap = wdFindStop
      .Format = False
      .MatchWildcards = False
      .Execute Replace:=wdReplaceAll
      'space + dot
      .Text = " ."
      .Replacement.Text = "."
      .Forward = True
      .Wrap = wdFindStop
      .Format = False
      .MatchWildcards = True
      .Execute Replace:=wdReplaceAll
      Selection.Style = ActiveDocument.Styles("Normal")
    End With
End Sub