#!/bin/sh
cd c:/xampp/htdocs/jidfam
git add --all
timestamp() {
  date +"at %H:%M:%S on %d/%m/%Y"
}

git commit -am "Regular auto-commit $(timestamp)"

ping www.github.com && git push origin --all || echo "not connected"

cd c:/xampp/htdocs/jidfam-frontend
git add --all
git commit -am "Regular auto-commit $(timestamp)"
ping www.github.com && git push origin --all || echo "not connected"