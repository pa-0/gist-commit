## Sync all your GitHub forks with a 1-line command

#### Tested with Git Bash and Powershell 7:

This has only one dependency: [GitHub CLI](https://cli.github.com "GitHub's official command-line tool")
```bash
gh repo list <USERNAME> --fork --limit 9999 --json nameWithOwner --jq '.[]|.nameWithOwner' | while read -r  owner _; do gh repo sync "$owner"; done
```
>[!Note]
>Replace `<USERNAME>` with your GitHub username. Paste the command in your terminal, and press `ENTER`.  That's it.