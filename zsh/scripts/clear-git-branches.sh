#!/bin/sh

git checkout master --quiet

BRANCHES=`git branch --merged | tr '*' ' ' | grep 'vlada'`

for BRANCH in $BRANCHES 
do
  echo Deleting $BRANCH ...

  if [ "$1" == "delete" ]
  then
    git branch -d $BRANCH --quiet
    git push origin --delete $BRANCH --quiet
  fi
done
