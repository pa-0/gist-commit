from github import Github
# read the text file and load each line as an item into a list
vars = list()
with open('vars.txt', 'r') as file:
    for line in file:
        vars.append(line.replace('\n', ''))

# assign each item to a variable
token = vars[0]
repo_for_upload = vars[1]
path_to_file = vars[2]
dest_path_on_git_hub = vars[3]
commit_message = vars[4]

g = Github(token)

repo = g.get_repo(repo_for_upload)

with open(path_to_file, 'r') as file:
    data = file.read()

repo.create_file(dest_path_on_git_hub, commit_message, data)
