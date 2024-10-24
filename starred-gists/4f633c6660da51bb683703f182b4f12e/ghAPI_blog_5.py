from github import Github
import sys

token = sys.argv[1]
repo_for_upload = sys.argv[2]
path_to_file = sys.argv[3]
dest_path_on_git_hub = sys.argv[4]
commit_message = sys.argv[5]

g = Github(token)

repo = g.get_repo(repo_for_upload)

with open(path_to_file, 'r') as file:
    data = file.read()

repo.create_file(dest_path_on_git_hub, commit_message, data)