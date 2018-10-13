#!/bin/sh
# Script to grab key data on GitHub organizations, their repos,
# and their contributors and export it to a JSON file.


# Add you GitHub 40-charcter authentication token:

TOKEN=put-your-github-token-here


# List all GitHub usernames you would like collect data on
# separate with spaces or line breaks, no commas

ORGS=(
gettypubs
thegetty
)


# Loop through list of users, make call to GitHub API
# construct new JSON object with the needed information,
# and save to tempoarary file

# NEED FIX: Currently only gets the first page of results
# with 100 repositories so the data on any org with more
# repositories than that is incomplete

for i in "${ORGS[@]}"
do

  curl -H 'Authorization: token '$TOKEN'' "https://api.github.com/orgs/$i/repos?per_page=100" | jq '.[] | {
    name_full: .full_name,
    name: .name,
    url: .html_url,
    description: .description,
    type: (if .fork == true then "Fork" else "Original" end),
    date_created: (.created_at | fromdateiso8601 | strftime("%Y-%m-%d") ),
    date_pushed: (.pushed_at | fromdateiso8601 | strftime("%Y-%m-%d") ),
    size_kb: .size,
    size_span: (
        if (.size/1000) < 1 then "0-1 MB"
      elif (.size/1000) < 10 then "1-10 MB"
      elif (.size/1000) < 100 then "10-100 MB"
      elif (.size/1000) < 1000 then "100-1000 MB"
      else "1000+ MB" end),
    stars: .stargazers_count,
    language: .language,
    forks: .forks_count,
    license: (if .license.name then .license.name else .license end),
    owner_name: .owner.login,
    owner_url: .owner.html_url }' >> REPOS.txt

done


# The sections below follow the same pattern:
#
# 1. Create a temporary file with variable array
# of repository names generated in the step above
#
# 2. Loop through that array, make call to GitHub API
# for information, and create new array of objects


# Get contributor names and contribution counts
# for all museum repositories

echo "REPO_NAMES=(" >> REPO_NAMES.txt

cat REPOS.txt | jq --slurp ".[] | if .name_full == null then null else .name_full end" >> REPO_NAMES.txt

echo ")" >> REPO_NAMES.txt

source REPO_NAMES.txt

for i in "${REPO_NAMES[@]}"
do

  curl -H 'Authorization: token '$TOKEN'' "https://api.github.com/repos/$i/contributors" | jq --arg repo "$i" '{
    name_full: $repo,
    contributor_count: (length),
    contributor: [.[] | {name: .login, contributions: .contributions}]}' >> NAMES.txt

done


# Get the parent information for any museum
# repository identified as a Fork

echo "REPO_FORKS=(" >> REPO_FORKS.txt

cat REPOS.txt | jq --slurp ".[] | if .type == \"Fork\" then .name_full else empty end" >> REPO_FORKS.txt

echo ")" >> REPO_FORKS.txt

source REPO_FORKS.txt

for i in "${REPO_FORKS[@]}"
do

  curl -H 'Authorization: token '$TOKEN'' "https://api.github.com/repos/$i" | jq --arg repo "$i" '{
    name_full: $repo,
    parent: .parent.full_name}' >> FORKS.txt

done


# Combine two resulting json texts from above (REPOS and PEOPLE),
# group into arrays by repository name, and output a JSON file
# with a timestamp.

NOW=$(date +%F-%s)

jq --slurp --sort-keys '[group_by(.name_full) | .[] | add ]' NAMES.txt REPOS.txt FORKS.txt >> GITHUB-DATA-$NOW.json

echo "Your JSON file is ready! --> GITHUB-DATA-$NOW.json"


# Remove all temporary files

rm -f REPOS.txt
rm -f REPO_NAMES.txt
rm -f NAMES.txt
rm -f REPO_FORKS.txt
rm -f FORKS.txt
