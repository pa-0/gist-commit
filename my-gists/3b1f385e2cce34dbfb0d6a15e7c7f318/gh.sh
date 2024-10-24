gh gist create - # finish with ctrl-d. gist name is hash
gh gist create -d cheatsheet -f TITLE - # add new gist, name is TITLE, description is cheatsheet. finish wiht ctrl-d (2x)
https://developer.github.com/v4/explorer/  # Live GraphQL Github API explorer (create API calls for gh api graphql 
gh gist list # neat colorfull list of your gits, use -L int to show more
gh gist edit 4997128 # get a neat menu and choose from the files in this gist to edit 
git checkout -b BRANCH # create and checkout branch before pull request ...
echo "code" > code.txt; git add . # create file and stash ...
git commit -m "commit in branch before pull request" # ...
gh pr create --title "pull request" --body "comment" # select repo to push new branch ...
gh pr review --comment -b "comment" # reviews pull request and comments it
gh api repos/:owner/:repo/issues # will be replaced with values from repo, retrieve 
gh issue create -R owner/repo # create issue in specified repository
# Don't Break the Chain productivity tracking with gh issue:
gh issue create -m <name> # Add issue to a milestone by name
# Automated in powershell for ($num =1 ; $num -le 365 ; $num++){ sleep 10 ; gh issue create -t 'learn python' -b ' ' -m python }
gh issue list --search 'sort:created-asc' # list issues in ascending order
gh issue close <number> # close issue 