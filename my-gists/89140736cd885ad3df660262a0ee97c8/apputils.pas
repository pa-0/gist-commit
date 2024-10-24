unit AppUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function CheckDir(path:string):Boolean;
function GetFirstSubdir(path:string): string;
procedure WriteToFile(outputf, text: string);

implementation

function CheckDir(path:string):Boolean;
var
  lazfile: string;
begin
  lazfile := ConcatPaths([path, 'lazarus.exe']);
  Result := DirectoryExists(path) and FileExists(lazfile);
end;

function GetFirstSubdir(path:string): string;
var
  InitialDirectory: string;
  SearchResult: TSearchRec;
begin
  InitialDirectory:=GetCurrentDir; Result := '';
  SetCurrentDir(path);
  if FindFirst('*', faDirectory, SearchResult) = 0 then
  begin
    repeat
      if (LeftStr(SearchResult.Name, 1) <> '.') // filter '.' and '..'
         and ((SearchResult.Attr and faDirectory) = faDirectory) then
      begin
        Result := SearchResult.Name;
        Break;
      end;
    until FindNext(SearchResult) <> 0;
    FindClose(SearchResult);
  end;
  SetCurrentDir(InitialDirectory);
end;

procedure WriteToFile(outputf, text: string);
var
  OutFile: TextFile;
begin
  AssignFile(OutFile, outputf);
  Rewrite(OutFile);
  Write(OutFile, text);
  CloseFile(OutFile);
end;

end.

