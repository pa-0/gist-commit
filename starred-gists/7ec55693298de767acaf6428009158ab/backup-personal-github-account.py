import requests
import subprocess
import os

# GitHub Personal Access Token
PAT = 'ghp_XXXXXXXXXXXXXXXXXXXXXXXX'
# The local directory where to save the backups
BACKUP_DIR = './'
# GitHub API URL to list the repositories
API_URL = 'https://api.github.com/user/repos'

def get_repos(pat):
    """
    Fetch all personal repositories for the authenticated user
    """
    headers = {'Authorization': f'token {pat}'}
    response = requests.get(API_URL, headers=headers, params={'visibility': 'all', 'per_page': 100, 'affiliation': 'owner'})
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"Failed to fetch repositories: {response.content.decode('utf-8')}")

def backup_repos(repos):
    """
    Mirror repositories into the specified backup directory
    """
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)
    
    for repo in repos:
        clone_url = repo['clone_url']
        print(f"----------------------------------- {clone_url}")
        clone_url_with_auth = clone_url.replace('https://', f'https://{PAT}@')
        repo_name = repo['name']
        print(f"Mirroring {repo_name}...")
        subprocess.run(['git', 'clone', '--mirror', clone_url_with_auth, os.path.join(BACKUP_DIR, repo_name)])

def main():
    try:
        repos = get_repos(PAT)
        backup_repos(repos)
        print("Backup completed successfully.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
