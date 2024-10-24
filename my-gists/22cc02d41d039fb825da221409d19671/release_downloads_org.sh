#!/bin/bash -eu
set -e
set -u
brew install gh || true
gh extension install mdb/gh-release-report || true
GITHUB_ORG=${GITHUB_ORG:-pact-foundation}
for repo in $(gh repo list $GITHUB_ORG --json name -q '.[]|.name'); do for tag in $(gh release list --repo $GITHUB_ORG/$repo --limit 1000 | cut -f3); do gh release-report --repo $GITHUB_ORG/$repo --tag "$tag"; done; done;