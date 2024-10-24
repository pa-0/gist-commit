program lazarusportable;

uses sysutils, process, AppUtils;

function GetLazarusDir: string;
var
  Current: string;
begin
  // check current directory first
  Current := GetCurrentDir;
  if CheckDir(Current) then begin
    Result := Current; Exit;
  end;
  // check subdir 'lazarus' (i.e. lazarus/lazarus.exe)
  Current := ConcatPaths([Current, 'lazarus']);
  if CheckDir(Current) then begin
    Result := Current; Exit;
  end;
  // standard PortableApps format (App/lazarus/lazarus.exe)
  // this may need to be moved first for performance
  Current := ConcatPaths([GetCurrentDir, 'App', 'lazarus']);
  if CheckDir(Current) then begin
    Result := Current; Exit;
  end;
  Result := '';
end;

function GetFpcDir(lazPath:string): string;
var
  Current: string;
begin
  Current := ConcatPaths([lazPath, 'fpc']);
  Result := ConcatPaths([Current, GetFirstSubdir(Current)]);
end;

function GetFpcBinDir(fpcPath:string): string;
var
  Current: string;
begin
  Current := ConcatPaths([fpcPath, 'bin']);
  Result := ConcatPaths([Current, GetFirstSubdir(Current)]);
end;

function MakeFpcConfig(fpcPath, fpcBinPath: string): string;
var
  Mkcfg, ProgramOutput: string;
begin
  ProgramOutput:='';
  Mkcfg:=ConcatPaths([fpcBinPath, 'fpcmkcfg']);
  RunCommand(Mkcfg, ['-d', 'basepath=' + fpcPath], ProgramOutput);
  Result := ProgramOutput;
end;

procedure ConfigureFpc(lazPath: string);
var
  fpcPath, fpcBinPath: string;
  fpcConfig: string;
begin
  fpcPath:=GetFpcDir(lazPath);
  fpcBinPath:=GetFpcBinDir(fpcPath);
  fpcConfig:=MakeFpcConfig(fpcPath, fpcBinPath);

  WriteToFile(ConcatPaths([fpcBinPath, 'fpc.cfg']), fpcConfig);
  //Writeln(fpcConfig);
end;

procedure StartLazarus(lazPath: string);
var
  lazExe, cfgDir, CmdLine: string;
begin
  lazExe:=ConcatPaths([lazPath, 'lazarus']);
  cfgDir:=ConcatPaths([lazPath, 'config']);
  CmdLine:='--primary-config-path='+cfgDir+' --lazarusdir='+lazPath;
  ExecuteProcess(lazExe, CmdLine);
end;

var
  lazPath: string;
begin
  lazPath := GetLazarusDir;
  if lazPath = '' then Abort;

  ConfigureFpc(lazPath);
  StartLazarus(lazPath);

//  Readln;
end.

