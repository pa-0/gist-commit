import os
import json

# Directory where repositories will be cloned
CLONE_DIR = os.getcwd()

def clone_and_pull_repos():
    # Create directory if it doesn't exist
    if not os.path.exists(CLONE_DIR):
        os.makedirs(CLONE_DIR)
    
    # Get all repositories using gh CLI
    repos_list = os.popen('gh repo list --json name').read().strip()
    author = os.popen('gh api user -q ".login"').read().strip()

    # Process JSON output
    repos = json.loads(repos_list)
    
    # Iterate through repositories
    for repo in repos:
        repo_name = repo['name']
        full_repo_name = f"{author}/{repo_name}"
        repo_dir = os.path.join(CLONE_DIR, repo_name)
        
        # Clone if not already cloned
        if not os.path.exists(repo_dir):
            os.system(f'git clone https://github.com/{full_repo_name}.git {repo_dir} --single-branch --depth=1')
        else:
            # Pull latest changes
            os.system(f'cd {repo_dir} && git pull --depth=1')

if __name__ == "__main__":
    clone_and_pull_repos()
