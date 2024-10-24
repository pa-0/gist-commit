SRC="/home/git_repo"
DEST="/home/svn_repo"

echo -e "Deploy to github & SVN repository"

echo \#commit message :
read msg

if [ $# -eq 1 ]
  then msg="$1"
fi

git add .
git commit -m "$msg"
git push origin master

rsync -av --progress . ${DEST} --exclude ".*/" --exclude ".*" --exclude "build/"
cd ${DEST}

svn commit -m "$msg"

echo -e "Done!"