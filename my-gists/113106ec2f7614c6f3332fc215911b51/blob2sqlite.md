Sometimes the email filter at work tries to prevent you from sending certain files so you can use this method to get around it.  For example, .app files, or executables, or installers. 

tested with OS X and macOS, should work with any system with SQLite and bash installed

store the binary file as a blob in a SQLite database and then the reciepient can extract it. 

Sender: add the file to db

```bash
my_file="iStat.app"
echo "create table somefiles (thefile blob);" | sqlite3 files.db
echo "insert into somefiles (thefile) values(x'$(hexdump -ve '1/1 "%0.2X"' $my_file)');" | sqlite3 files.db 2>&1


# also send the the md5 in the email

md5 "$my_file"
# md5sum on some systems


```
Recipient: extract the file from db

```bash
echo "select quote(thefile) from somefiles limit 1 offset 0;" | sqlite3 files.db | tr -d "X'" | xxd -r -p > iStat.zip

md5 iStat.zip
```


