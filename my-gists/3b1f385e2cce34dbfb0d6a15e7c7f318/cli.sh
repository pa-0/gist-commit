# grepable with inline comments.
# create alias: gh alias set cheat 'gist view 4997128'
# gh cheat | grep cheat -C 3, shows 3 lines before and after, 
# Windows Powershell: gh cheat | Select-String cheat

bind -p | grep -v '^#\|self-insert\|^$' #list bash vim keybindings 
shopt #shell options
bind -P #print keybindings  
bash -x #print shellscript before executing, execute commands from file
help #brief summaries of builtin commands
fc #open last commandline in editor
kill -HUP $(ps -A -ostat,ppid | grep -e '[zZ]'| awk '{ print $2  }') #kill zombie processes
echo $0 #show if login shell or not, login shell has -bash  
rm ./-somefileordir #remove file with hyphen
cd ./-somefileordir #change into dir with hyphen
type #type of command  
type -a program #show path to all versions of program  
export HISTTIMEFORMAT="%h/%d - %H:%M:%S " #shows date in historyfile 
printf \t \n ... #formated print with tab and newline
grep -A 2 -B 3 foo README.txt # 2 lines before, 3 lines after
grep -C 3 foo README.txt # 3 lines before and after
xprop |grep WM_CLASS #get x11 window classname  
echo "scale=2; x+y" | bc #calculations from cli, 2 decimals
echo "x*y" | bc -l #calculations from cli   
sudo -s #stay in directory when sudo   
man std::-->tab #c++ manpages    
base64 #encode and decode using base64 representation
jq -r 'map(.Value | @base64d)' < file.json #decode base64 string of Value object
pdftotext my.pdf - | grep 'pattern' #grep through pdfs without writing txt file
yes foo > bar.txt #repeat some text (default is y) infinetly and save it to a file
strings #find the printable strings in a object, or other binary, file 
mkfifo --mode=0666 /tmp/namedPipe #load SQL commands ...  
gzip --stdout -d file.gz > /tmp/namedPipe #from gzipped file ...
  LOAD DATA INFILE '/tmp/namedPipe' INTO TABLE tableName; #into database ...
java -version #java version 
javac -version #java compiler version
ant -version #java make tool version 
mvn #java project management tool 
rcs  #revision control system
tee  #pipe to STDOUT and  file 
cal #display calendar   
tidy #html parser  
fmt #format text (TEX) 
textutil #convert document-files   
xpath #xml parser 
xmllint  #xml parser
locate -r "^\(.*/\)*header\.inc\.php$" #exact match  
sqlite3 #sqlite cli interface ...
  .databases #view databases ...
  .open FILENAME #connect to database file ... 
  .tables #show tabes ...
  .mode html #switch to html mode ...
  .once FILENAME.html #query output to file ...
  SELECT * FROM TABLE; # write content from table to FILENAME.html... 
  .quit #quit sqlite database ...
project.cj add overtone dep  #overtone audio live coding
lein deps # ...
gibber #audiovisual live coding framework in javascript 
xclip -sel clip < ~/.ssh/id_rsa.pub #copy from file to clipboard
sudo service start ssh start # start ssh daemon on WSL client and remotely connect to it
apt install <packet> # install gh in Kali, download deb: https://github.com/cli/cli/releases/latest