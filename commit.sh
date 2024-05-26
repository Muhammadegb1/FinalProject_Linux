#!/bin/bash

# נתיב לקובץ CSV
CSV_FILE="devebox_git.csv"

#CSV_FILE=$1
additional_description=$1

if [[ ! -f "$CSV_FILE" ]]; then
    echo "Error: CSV file does not exist."
    exit 1
fi



current_branch=$(git rev-parse --abbrev-ref HEAD)
# Read CSV and create commit message
while IFS=, read -r bug_id description branch dev_name bug_priroty github_url
do
    if [[ "$branch" == "$current_branch" ]]; then
        git remote add origin $github_url
        commit_message="$bug_id:$(date +%Y-%m-%d-%H:%M:%S):$branch:$dev_name:$bug_priroty:$description"
        if [[ -n "$additional_description" ]]; then # בודק אם המחרוזת אינה ריקה
              commit_message="$commit_message:$additional_description"
        fi

        break
    fi
done < <(tail -n +2 "$CSV_FILE")


echo $commit_message >> commit.log
# ביצוע הקומיט וה-push
git add .
git commit -m "$commit_message"
if [ $? -ne 0 ]; then
    echo "Commit failed."
    exit 1
fi

git push origin $current_branch
if [[ $? -ne 0 ]]; then
    echo "Push failed."
    exit 1
fi
echo "Commit and push were successful."