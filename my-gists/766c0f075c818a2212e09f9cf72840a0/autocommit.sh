echo "Staging Files..."
git add .
echo "Commiting Files"
if [ "$1" != '' ]; then
  git commit -m "$1"
else
  git commit -m "Auto Commit :octocat:"
fi
echo "Pushing Changes"
if [ "$2" != '' ]; then
  git push origin $2
else
  git push origin master
fi