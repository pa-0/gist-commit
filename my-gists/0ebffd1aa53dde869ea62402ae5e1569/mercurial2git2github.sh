#!/usr/bin/env bash

set -euxo pipefail

GH_USER='eggplants'  # MODIFY THIS IF YOU USE THIS SCRIPT

TARGET_MERCURIAL_REPO_URL='https://hg.jcea.es/pybsddb'  # MODIFY THIS IF YOU USE THIS SCRIPT
TARGET_MERCURIAL_REPO_NAME="${TARGET_MERCURIAL_REPO_URL/*\//}"

GH_MIRROR_URL="https://github.com/${GH_USER}/${TARGET_MERCURIAL_REPO_NAME}-mirror"

if ! command -v gh git hg pip &>/dev/null; then
  echo "Install: gh, git, hg(mercurial), pip" >&2
  exit 1
elif ! [ -f ~/.config/gh/config.yml ]; then
  echo "Is gh set up?" >&2
  exit 1
fi

# Set up hg-git
if ! grep -q 'hggit' ~/.hgrc; then
  pip install dulwich
  hg clone https://foss.heptapod.net/mercurial/hg-git
  echo -e "[extensions]\nhgext.bookmarks =\nhggit = $PWD/hg-git/hggit" >> ~/.hgrc
fi

# Mirror
git init --bare "${TARGET_MERCURIAL_REPO_NAME}-git"  # Mirroring Git repo
hg clone "$TARGET_MERCURIAL_REPO_URL"  # Mirrored Mercurial repo
cd "$TARGET_MERCURIAL_REPO_NAME"
hg bookmarks hg
hg push "../${TARGET_MERCURIAL_REPO_NAME}-git"
cd ..

# Push GitHub repo
gh repo create "${TARGET_MERCURIAL_REPO_NAME}-mirror"  # `--public`, `--private`, or `--internal`
git clone --mirror "${TARGET_MERCURIAL_REPO_NAME}-git" "${TARGET_MERCURIAL_REPO_NAME}-mirror"
cd "${TARGET_MERCURIAL_REPO_NAME}-mirror"
git remote set-url --push origin "$GH_MIRROR_URL"
git push --mirror

echo "done: ${GH_MIRROR_URL}"