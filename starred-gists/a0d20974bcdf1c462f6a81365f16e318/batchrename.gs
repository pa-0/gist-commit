function batchRenameFiles() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet()
  var selection = sheet.getActiveRange()
  
  var data = selection.getFormulas()

  for (var i = 0; i < data.length; i++) {
    var counter = 1
    var row = data[i]
    Logger.log(row)
    for (var j = 0; j < row.length; j++) {
      var cell = row[j]
      if (cell) {
        var fileId = cell.match(/https:\/\/drive\.google\.com\/open\?id=([a-zA-Z0-9_-]+)/)[1]
        try {
          var file = DriveApp.getFileById(fileId)
          var originalName = file.getName()
          var fileExtension = originalName.match(/\.[0-9a-z]+$/i)
          var newName = padWithLeadingZeros(counter, 2) + fileExtension
          var newFormula = cell.replace(/"([^"]+)"\)$/, '"' + newName + '")')

          file.setName(newName)
          selection.getCell(i + 1, j + 1).setFormula(newFormula)

          Logger.log(originalName  + ' -> ' + newName)
          Logger.log(newFormula)
        } catch (e) {
          Logger.log('Error processing row ' + (i + 1) + 'cell ' + (j + 1) + ': ' + e.toString());
        }
        counter++
      }
    }
  }
}

function padWithLeadingZeros(number, targetLength) {
  var output = String(number)
  while (output.length < targetLength) {
    output = '0' + output
  }
  return output;
}

function onOpen() {
  FormsApp.onOpen();
  var ui = SpreadsheetApp.getUi();
  ui.createMenu('Custom Menu')
      .addItem('Batch Rename Files', 'batchRenameFiles')
      .addToUi();
}
