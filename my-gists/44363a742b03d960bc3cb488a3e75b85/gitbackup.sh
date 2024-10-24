#!/bin/bash
name="copoer"
cntx="users"
page=1

echo $name
echo $cntx

START=1
END=3
for (( page=$START; page<=$END; page++ ))
do
        res=$(curl -s "https://gitlab.com/api/v4/$cntx/$name/projects?page=$page&per_page=100" | jq '.[]')
        if [[ $res == *"http_url_to_repo"* ]]; then
                echo $res | jq .'http_url_to_repo' | xargs -L1 git clone
        else
                echo "done git lab"
                break
        fi
done

for (( page=$START; page<=$END; page++ ))
do
        res=$(curl -s "https://api.github.com/$cntx/$name/repos?page=$page&per_page=100" | jq '.[]')
        if [[ $res == *"clone_url"* ]]; then
                echo $res | jq .'clone_url' | xargs -L1 git clone
        else
                echo "done git hub"
                break
        fi
done

# Pull Everything
ls | xargs -P10 -I{} git -C {} pull

exit 0
