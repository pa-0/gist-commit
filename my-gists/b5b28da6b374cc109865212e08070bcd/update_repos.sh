#!/bin/bash

echo 'Updating repos'
for $project in `find . -type d -depth 1`
do
    echo 'Current repo: ' $project
    cd $project
    git pull
    cd ..
done
echo 'Done'
