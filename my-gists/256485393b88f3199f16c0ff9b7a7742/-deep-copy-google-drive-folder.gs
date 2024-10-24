// @ts-check

// Script: Deep-copy Google Drive folder
// Homepage: https://gist.github.com/szhu/3835be972f71878a511a1a09bd0d4be2

// If you're trying to use this script to migrate content from a school Google
// account to a personal one, here is the recommended workflow:
//
// 01. First, share the folders you want to copy this way:
//
//     02. In your school Google Drive, share all the folders you want to copy
//         with your personal Google account. View-only access is sufficient.
//
//     03. In your personal Google Drive, create a new, empty folder that you
//         will use just for this migration process.
//
//         For example, you can call it "Files shared from school GDrive", or
//         you can choose a different name.
//
//     04. In your personal Google Drive, go to "Shared with me" and find all
//         the folders that you just shared with your personal Google account.
//         Drag all of them into the folder you created in step 3.
//
//         FYI, this step doesn't actually copy the folders, otherwise we
//         wouldn't need this script! It just creates shortcuts to the shared
//         folders.
//
// 05. Then, set up this script:
//
//     06. Go to script.google.com. Check if you're logged in with your personal
//         Google account, and use the account switcher if needed.
//
//     07. Create a new project.
//
//     08. Copy and paste the contents of this file into the new project.
//
//     09. Make sure to set the `sourceFolderName` and `targetFolderName`
//         variables below correctly.
//         - `sourceFolderName` should be the name of the folder you created in
//           step 3. If you used the recommended name, no change is needed.
//         - `targetFolderName` should be a folder that doesn't exist yet in
//           your personal Google Drive. No change is needed, but you can change
//           it if you want.
//
// 10. Now you're ready to run the script!
//
//     11. Click the play button in the toolbar.
//
//     12. When the script is running, you'll see a log showing the progress.
//         Make sure to review any lines that say "ERROR". Those are Drive
//         shortcuts whose targets can no longer be found.
//
//         All other kinds of errors will crash the script, so it'll be more
//         obvious if anything else went wrong.
//
//     13. If you are using this script, you most likely have more than a
//         trivial number of files, and it'll probably take more than Google
//         Script's maximum run time to copy them all. If you get an error that
//         says "Exceeded maximum execution time", just run the script again,
//         and it'll skip copying files that are already copied.
//
//         If the script takes too long in the beginning looking at folders you
//         know are already copied, you can add their paths to the
//         `folderPathsToSkip` variable.
//
//     14. Here's a summary of how the script does copying:
//
//         - If the script sees a folder whose copy destination already exists,
//           it does still look inside the folder to see if there are files or
//           folders that need to be copied.
//
//         - If the script sees a file whose copy destination already exists, it
//           skips copying that file. It does not check if the contents of the
//           files have changed.
//
//         - If the script sees a shortcut to a file or folder, it copies the
//           target of the shortcut, not the shortcut itself. If there is an
//           error getting the target of the shortcut, it logs an error and
//           continues.
//
//         This means that if you know any files or folders have changed and
//         want to re-copy them, you should delete the outdated copies and run
//         the script again.
//
//     15. The script will log "Done!" when it's finished.
//
// 16. If you have any questions, please reach out to the group chat or mailing
//     list where you found this script.
//
//     Or, leave a comment here:
//     https://gist.github.com/szhu/3835be972f71878a511a1a09bd0d4be2

var sourceFolderName = "Files shared from school GDrive";
// ^ Name of the folder to copy from.
// - This folder must be in the top level of your Google Drive.

var targetFolderName = "Files copied from school GDrive";
// ^ Name of the folder to copy to.
// - You don't need to create the folder.
// - This folder must be in the top level of your Google Drive.

var folderPathsToSkip = new Set([
  // Examples below. You can leave or remove them, it doesn't matter.
  "My Drive/path/to/folder/to/skip",
  "My Drive/path/to/another/folder/to/skip",
]);
// ^ Paths to skip over. When the script sees a folder whose path is below, it
// will skip copying it and its contents.
// - This is helpful if you need to re-run the script but you know some folders
//   were already copied over successfully. Or you can use it to skip folders
//   you don't want copied for any other reason.
// - These must be full paths. You can find them in the log output when you run
//   the script.

// -- Do not edit below this line --

// This script is based on https://www.labnol.org/code/19979-copy-folders-drive
//
// Major added features:
// - Log progress.
// - If a shortcut is encountered, copy its target rather than the shortcut
//   itself.
// - Allow setting folder paths to skip.
// - If the target already exists, don't copy it again.

const FolderMimeType = /** @type {any} */ (MimeType).FOLDER;

function start() {
  var source = DriveApp.getFoldersByName(sourceFolderName);
  var target = getOrCreateFolder(DriveApp, targetFolderName);

  if (source.hasNext()) {
    copyFolder(source.next(), target);
  }

  Logger.log("Done!");
}

/**
 * @param {GoogleAppsScript.Drive.DriveApp | GoogleAppsScript.Drive.Folder} parent
 * @param {string} name
 */
function getOrCreateFolder(parent, name) {
  var matches = parent.getFoldersByName(name);

  var folder;
  if (matches.hasNext()) {
    folder = matches.next();
  } else {
    folder = parent.createFolder(name);
  }
  var path = getFilePath(folder);
  if (folderPathsToSkip.has(path)) {
    Logger.log("Skipping folder: " + path);
    return /** @type {const} */ ("skipping");
  } else {
    Logger.log("Folder: " + path);
    return folder;
  }
}

/**
 * @param {GoogleAppsScript.Drive.File} source
 * @param {GoogleAppsScript.Drive.Folder} targetFolder
 * @param {string} targetName
 */
function getOrCopyFile(source, targetFolder, targetName) {
  var matches = targetFolder.getFilesByName(targetName);

  if (matches.hasNext()) {
    // Logger.log("Already copied: " + getFilePath(source));
    return matches.next();
  } else {
    Logger.log("Copying: " + getFilePath(source));
    return source.makeCopy(targetName, targetFolder);
  }
}

/**
 * @param {GoogleAppsScript.Drive.Folder} folder
 * @param {string} fileName
 * @param {string} path
 * @param {string} [linkedFileId]
 */
function writeShortcutErrorInfoFile(folder, fileName, path, linkedFileId) {
  const errorFileName = fileName + " - GDRIVE_COPY_ERROR.txt";
  var info = [
    "ERROR: Unable to copy shortcut",
    "Path: " + path,
    linkedFileId
      ? `Linked file not found: ${linkedFileId}\nhttps://drive.google.com/open?id=${linkedFileId}`
      : "No linked file ID found",
  ].join("\n");

  const existingFiles = folder.getFilesByName(errorFileName);
  if (existingFiles.hasNext()) {
    var file = existingFiles.next();
    Logger.log("ERROR: Error file already exists: " + getFilePath(file));
  } else {
    var file = folder.createFile(errorFileName, info);
    Logger.log("Wrote error to: " + getFilePath(file));
  }
}

/**
 * @param {GoogleAppsScript.Drive.Folder} source
 * @param {GoogleAppsScript.Drive.Folder | "skipping"} target
 */
function copyFolder(source, target) {
  if (target === "skipping") return;

  var folders = source.getFolders();
  var files = source.getFiles();

  while (files.hasNext()) {
    var file = files.next();

    if (file.getMimeType() === "application/vnd.google-apps.shortcut") {
      var linkedFileId = file.getTargetId();
      if (!linkedFileId) {
        Logger.log("ERROR: No linked file ID found for: " + getFilePath(file));
        writeShortcutErrorInfoFile(target, file.getName(), getFilePath(file));
        continue;
      }

      var linkedFile;
      try {
        linkedFile = DriveApp.getFileById(linkedFileId);
      } catch {
        Logger.log("ERROR: Linked file not found for: " + getFilePath(file));
        writeShortcutErrorInfoFile(
          target,
          file.getName(),
          getFilePath(file),
          linkedFileId,
        );
        continue;
      }

      if (linkedFile.getMimeType() == FolderMimeType) {
        var linkedFolder = DriveApp.getFolderById(linkedFileId);
        var targetFolder = getOrCreateFolder(target, file.getName());
        copyFolder(linkedFolder, targetFolder);
      } else {
        getOrCopyFile(linkedFile, target, file.getName());
      }
    } else {
      getOrCopyFile(file, target, file.getName());
    }
  }

  while (folders.hasNext()) {
    var subFolder = folders.next();
    var folderName = subFolder.getName();
    var targetFolder = getOrCreateFolder(target, folderName);
    copyFolder(subFolder, targetFolder);
  }
}

var FilePathCache = new Map();

/**
 * @param {GoogleAppsScript.Drive.Folder | GoogleAppsScript.Drive.File} file
 */
function getFilePath(file) {
  var path = [];

  /** @type {GoogleAppsScript.Drive.Folder | GoogleAppsScript.Drive.File} */
  var folder = file;
  while (folder) {
    var id = folder.getId();
    if (FilePathCache.has(id)) {
      path.unshift(FilePathCache.get(id));
      break;
    } else {
      path.unshift(folder.getName());
      if (folder.getParents().hasNext()) {
        folder = folder.getParents().next();
      } else {
        break;
      }
    }
  }

  var filePath = path.join("/");

  FilePathCache.set(file.getId(), filePath);

  return filePath;
}
