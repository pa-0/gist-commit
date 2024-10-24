#!/bin/bash
# --------------------------- Settings -------------------------
gitUsername="erlendaakre"

# ----------------------------- Code ---------------------------
echo "Getting list of all public repositories for user $gitUsername"
array=($(curl -s 1 https://api.github.com/users/$gitUsername/repos | grep '\"name\"\|clone' | sed 's/.*: \"//' | sed 's/\",$//' | xargs echo))
arrayLength=${#array[@]}
reposFound=$(($arrayLength/2))
i=0

echo "Backing up $reposFound repos"
echo "--------"

until [ $i -ge $arrayLength ];
do
        repoName=${array[$i]}
        repoUrl=${array[$i+1]}
        echo "Backing up" $repoName
        if [ -d "$repoName.git" ]
        then
                echo "   updating repo"
                cd $repoName.git
                git fetch -q --all -p
                cd ..
        else
                echo "   NOT FOUND. doing initial git clone!"
                git clone --mirror $repoUrl
        fi
        let i+=2
done