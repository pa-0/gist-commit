# Migrate Releases

This is a script to migrate a Github Release from one Repo to another.

## Instalation

```bash
npm i @octokit/rest semver dotenv
```

## Usage

1. Create a `.env` file with the following options:
  ```env
  GH_AUTH_TOKEN=
  SOURCE_REPO=
  DESTINATION_REPO=
  TAG_SHA=
  ```
  
2. Run migration
  ```bash
  node migrate-releases.js
  ```