## These are the comments from the original that I forked (alternative scripts availabl)

//a script that will work with subfolders.
//This should work for every file in your drive.

function fileRename() {
  var files = DriveApp.getFiles();
  while(files.hasNext()){
    var file = files.next()
    var fileName = file.getName();
    if (fileName.indexOf('Copy of ') > -1) {
      fileName= fileName.split('Copy of ')[1];
      file.setName(fileName);
    };
  };
}


//I reworked this a bit to be fully recursive and to include the parent folder ID.
function fileRename() {
  var parentfolder = DriveApp.getFolderById('XXXXXXXXXXXXXXXXXXXXXXX');
  var recursive = true;

  getFilesFromFolder(parentfolder);

  var folders = parentfolder.getFolders();
  while(folders.hasNext() && recursive){
    var folder = folders.next();
    getFilesFromFolder(folder);
  }
}

function getFilesFromFolder(folder){
  var folderName = folder.getName();
  Logger.log(folderName);
  var files = folder.getFiles();
  while(files.hasNext()){
    var file = files.next()
    var fileName = file.getName();
    if (fileName.indexOf('Copy of ') > -1) {
        Logger.log(fileName);
        fileName= fileName.split('Copy of ')[1];
        file.setName(fileName);
    };
  };
}

//Below is some updated code you can add to a gsheet script. 
//It adds a menu item to execute the script to the gsheet menu bar 
//and provides a popup box so you can enter the folder name that contains the files with "Copy of"

function onOpen() {
  var SS = SpreadsheetApp.getActiveSpreadsheet();
  var ui = SpreadsheetApp.getUi();
  ui.createMenu('Remove "Copy of" from start of file names in a folder')
    .addItem('Start script', 'fileRename')
    .addToUi();
};

function fileRename() {
  var inputFolder = Browser.inputBox('Enter folder ID', Browser.Buttons.OK_CANCEL);
  if (inputFolder === "") {
    Browser.msgBox('Remove "Copy of" from the start of file names in this folder:');
  return;
  }

  var folders = DriveApp.getFoldersByName(inputFolder);
  var folder = folders.next();
  var files = folder.getFiles();
  var fileCnt=0;
  var renamedCnt = 0;

  while(files.hasNext()){
    fileCnt++;
    var file = files.next()
    var fileName = file.getName();
    if (fileName.indexOf('Copy of ') > -1) {
      fileName= fileName.split('Copy of ')[1];
      file.setName(fileName);
      renamedCnt++;
    };
  };
  SpreadsheetApp.getUi().alert('Removed "Copy of" from: '+renamedCnt+" Total Files Processed:"+fileCnt);
}