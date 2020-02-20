#!/bin/bash

set -e
echo "Start Creating PR action"

##### CONSTANCE
OUTPUT_PATH=".output"

##### VARIABLE
IS_NEED_APPROVE="false"

##### FUNCTION
function create_pr()
{
 TITLE="[HOTFIX] auto merged by $(jq -r ".pull_request.user.login" "$GITHUB_EVENT_PATH" | head -1) into master."
 REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
 SOURCE_BRANCH=$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")
 RESPONSE_CODE=$(curl -o $OUTPUT_PATH -s -w "%{http_code}\n" \
  --data "{\"title\":\"$TITLE\", \"head\": \"$SOURCE_BRANCH\", \"base\": \"$TARGET_BRANCH\"}" \
  -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_FULLNAME/pulls")
 echo "head: $SOURCE_BRANCH, base: $TARGET_BRANCH"
 echo "Create PR Response:"
 echo "Code : $RESPONSE_CODE"
 if [[ "$RESPONSE_CODE" != "201" ]];
 then
  exit 1
 fi
}

function delete_branch()
{
 DELETE_URL="$(jq -r ".head.repo.git_refs_url" "$OUTPUT_PATH" | head -1)"
 RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" \
  -X DELETE \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "$DELETE_URL")
 echo "Delete branch:"
 echo "used url: $DELETE_URL"
 echo "Code : $RESPONSE_CODE"
 if [[ "$RESPONSE_CODE" != "204" ]];
 then
  exit 1
 fi

}

function merge_pr()
{
 REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
 COMMIT_TITLE="$(jq -r ".title" "$OUTPUT_PATH" | head -1)"
 COMMIT_MESSAGE="$(jq -r ".body.head_commit.message" "$OUTPUT_PATH" | head -1)"
 HEAD_SHA="$(jq -r ".head.sha" "$OUTPUT_PATH" | head -1)"
 MERGE_METHOD="merge"
 PULL_NUMBER="$(jq -r ".number" "$OUTPUT_PATH" | head -1)"
 RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" \
  --data "{\"commit_title\":\"$COMMIT_TITLE\", \"commit_message\":\"$COMMIT_MESSAGE\", \"sha\": \"$HEAD_SHA\", \"merge_method\": \"$MERGE_METHOD\"}" \
  -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_FULLNAME/pulls/$PULL_NUMBER/merge")
 echo "Merged PR Response:"
 echo "Code : $RESPONSE_CODE"
}

function approve_pr()
{
 REPO_FULLNAME=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")
 PULL_NUMBER="$(jq -r ".number" "$OUTPUT_PATH" | head -1)"
 RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" \
  --data "{\"event\":\"APPROVE\"}" \
  -X POST \
  -H "Authorization: token $BOT_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_FULLNAME/pulls/$PULL_NUMBER/reviews")
 echo "Approve PR Response:"
 echo "Code : $RESPONSE_CODE"
}

function check_token_is_defined()
{
  if [[ -z "$GITHUB_TOKEN" ]];
  then
    echo "Undefined GITHUB_TOKEN environment variable."
    exit 1
  fi
}

function check_bot_token_is_defined()
{
  if [[ "$BOT_TOKEN" != null ]];
  then
    echo "Bot Token Avaliable"
    IS_NEED_APPROVE=true    
  else
    echo "Bot Token not Avaliable"
  fi
}

function check_is_pr_is_merged()
{
  echo "$(jq -r ".pull_request.merged" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.merged" "$GITHUB_EVENT_PATH")" == "false" ]];
  then
    echo "This PR has not merged event."
    exit 0
  fi
}

function check_is_pr_branch_has_hotfix_prefix()
{
  echo "$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.head.ref" "$GITHUB_EVENT_PATH")" != "$HOTFIX_PREFIX"* ]];
  then
    echo "This PR head branch do not have prefix."
    exit 0
  fi
}

function check_is_merged_base_branch_is_trigger()
{
  echo "$(jq -r ".pull_request.base.ref" "$GITHUB_EVENT_PATH")"
  if [[ "$(jq -r ".pull_request.base.ref" "$GITHUB_EVENT_PATH")" != "$BASE_BRANCH"* ]];
  then
    echo "This PR base branch is not base branch."
    exit 0
  fi

}

function check_validate() 
{
  check_token_is_defined
  check_bot_token_is_defined
  check_is_pr_is_merged
  check_is_pr_branch_has_prefix
  check_is_merged_base_branch_is_trigger
}

##### MAIN
function main()
{
  check_validate
  create_pr 
  if [[ "$IS_NEED_APPROVE" == "true" ]];
  then
    approve_pr
  fi
  merge_pr
  delete_branch
}

##### EXECUTE
main
