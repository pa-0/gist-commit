Create Github access token: https://github.com/settings/tokens

Setup backup tool:

```bash
pip3 install github-backup

export GITHUB_BACKUP_TOKEN=ghp_bananabananabananabananabananabanana
export GITHUB_BACKUP_USER=dreikanter
export GITHUB_BACKUP_PATH=~/github-backup/$GITHUB_BACKUP_USER
```

Backup a user:

```bash
mkdir -p $GITHUB_BACKUP_PATH

github-backup \
  --token $GITHUB_BACKUP_TOKEN \
  --output-directory $GITHUB_BACKUP_PATH \
  --starred \
  --followers \
  --following \
  --increment \
  --issues \
  --issue-comments \
  --pulls \
  --pull-comments \
  --pull-commits \
  --pull-details \
  --labels \
  --repositories \
  --wikis \
  --gists \
  --private \
  --fork \
  --releases \
  $GITHUB_BACKUP_USER
```

Add `--organization` flag if `$GITHUB_BACKUP_USER` is an organization:

```bash
mkdir -p $GITHUB_BACKUP_PATH

github-backup \
  --token $GITHUB_BACKUP_TOKEN \
  --output-directory $GITHUB_BACKUP_PATH \
  --starred \
  --followers \
  --following \
  --increment \
  --issues \
  --issue-comments \
  --pulls \
  --pull-comments \
  --pull-commits \
  --pull-details \
  --labels \
  --repositories \
  --wikis \
  --gists \
  --private \
  --fork \
  --releases \
  --organization \
  $GITHUB_BACKUP_USER
```

References:
- Native Github account data export: https://github.com/settings/admin → Export account data
- Backup tool: https://github.com/josegonzalez/python-github-backup