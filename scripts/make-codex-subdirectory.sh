#!/bin/bash

# Need one and only one parameter
if [ $# -ne 1 ]; then
  echo "Usage: $0 <new branch name>"
  echo "No spaces or such funny characters are allowed."
  exit 1
fi

# Make sure we're inside a git directory
git status >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "error: run this script from inside a git repository"
  exit 1
fi

BRANCH=`git rev-parse --abbrev-ref HEAD`

isEdition=`expr "$BRANCH" : 'editions'`

if [ $isEdition -ne 8 ]; then
  echo "WARNING - you're starting a new branch from $BRANCH"
  echo "That doesn't look like an editions/x.x branch!"
  read -p "Hit Ctrl-C to cancel, or RETURN to continue" choice
fi

# Checkout the new branch, create the directory & enter it
git checkout -b $1
mkdir $1
pushd $1
# Create the standard directory structure, and enter it
mkdir -p assets projects/starter projects/final projects/challenge
touch assets/.keep projects/starter/.keep projects/final/.keep projects/challenge/.keep
# Jump back out, and commit the changes
popd
git add $1
git commit -m "Adding $1" $1
git checkout $BRANCH

echo Added directory, branch, and initial commit for "$1".
echo "You're now back on the '$BRANCH' branch."

