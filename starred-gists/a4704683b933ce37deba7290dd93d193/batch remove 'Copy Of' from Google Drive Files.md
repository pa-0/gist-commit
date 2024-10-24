## Remove 'Copy of' prefix from Google Drive filenames

 `xterm` is a nifty Unix console emulator you can use in Google Colab notebooks. We can use it to manipulate files hosted on Google Drive in batch

 ### step 1: mount your Drive in Colab

Paste the following code in a 'code' cell of the Colab notebook and click _Run_
```python
from google.colab import drive

drive.mount('/content/drive') 
```

### step2: install `xterm`

Paste the following code in a 'code' cell of the Colab notebook and click _Run_. 
```python
!pip install colab-xterm

%load_ext colabxterm
```
Wait for `xterm` to finish loading.

### step 3: `cd` to the folder containing the files to be renamed

The command line prompt in `xterm` displays a path.  This is your _Current Working Directory_ or `cwd`.  To access the files to be renamed, ensure that the `cwd` is the folder where those files are located.  

Verify that the path in the code matches the path where your files are located and then paste the command into the `xterm` console.

```bash
#"MyDrive" is your Google Drive root directory.
# Replace "Books" with the folder (or path to the folder) containing the files 
# As-is, this command will make a folder called "Books" in your Drive the cwd

cd /content/drive/MyDrive/Books
```

### step 4: preview results of the batch-remove script

To avoid unexpected results, first run the following.  This will give you a preview: a list of all renamed files and their new names.  
```bash
# run 'echo' version of script first (below)
# this provides a preview of the results
# before actually renaming any files

for file in * ; do
    echo mv -v "$file" "${file#Copy of}"
done
```

### FINAL step: batch-remove the "Copy of" prefix from all files in the `cwd`

Finally, once you are sure the script will work as expected, run the following:  
```bash
for file in * ; do
    mv -v "$file" "${file#Copy of}"
done
```