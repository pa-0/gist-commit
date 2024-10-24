/**
 * See http://stackoverflow.com/questions/14573055/can-i-download-file-from-url-link-generated-by-google-apps-script/14574217#14574217.
 * You can't actually "download" the source file, because apps-script has no access to your PC's file system to write the file, although
 * it does have file upload capabilities in the UiApp. (If you're in an Enterprise Google Apps domain, you could copy the retrieved file
 * to an internal server, but that's getting off-topic.)  
 * Example: var result = getFileFromURL("http://some.where.com/file.zip","SomeFolder");    
 * if (result.rc != 200) {      throw new Error("File Not Found");    }
 *
 * Retrieve a file from the given URL, store into the named folder
 * on Google Drive.
 *
 * @param {String} fileURL   URL to source file, e.g. "http://mysite.com/files/file.val1.val22.zip"
 * @param {String} folder    Name of target folder on Google Drive
 *
 * @returns {Object}         Response of operation, e.g.
 *                           {rc:200,fileName:"test.zip",fileSize:92994392}
 */
function getFileFromURL(fileURL,folder) {
  var rc = 404;       // 404 Not Found
  var fileName = "";
  var fileSize = 0;
  // see https://developers.google.com/apps-script/class_urlfetchapp
  try {
    var response = UrlFetchApp.fetch(fileURL);
    var rc = response.getResponseCode();
  } catch (e)
  {
    // fetch() does not handle unresolved DNS or file not found errors
    // We'll treat all unhandled errors as "404 Not Found"
    // This catch block simply suppresses the error
    debugger;
  }

  if (rc == 200) {
    var fileBlob = response.getBlob()
    var folder = DocsList.getFolder(folder);
    if (folder != null) {
      var file = folder.createFile(fileBlob);
      fileName = file.getName();
      fileSize = file.getSize();
    }
  }

  var retObj = { "rc":rc, "fileName":fileName, "fileSize":fileSize };
  debugger;  // Stop to observe if in debugger
  return retObj
}