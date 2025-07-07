#!/bin/bash

# Check for input
if [ -z "$1" ]; then
  echo "Usage: $0 <id>"
  exit 1
fi

ID_TO_FIND="$1"
JSON_FILE="./json/Ubuntu22.04.json" 

# Extract values using jq
entry=$(jq -e --arg id "$ID_TO_FIND" '.. | objects | select(has("id") and .id == $id)' "$JSON_FILE")


if [ $? -ne 0 ]; then
  echo "No entry found with id '$ID_TO_FIND'"
  exit 1
fi

# Populate variables
summary=$(echo "$entry" | jq -r '"\(.id) \(.title)"')
description=$(echo "$entry" | jq -r '.description')
status=$(echo "$entry" | jq -r '.status')
type=$(echo "$entry" | jq -r '.type')

acli jira workitem create \
  --summary="$summary" \
  --description="$description" \
  --project="CIA" \
  --type="$type" \
  --assignee="default"

# Output (or use the variables as needed)
echo "Summary: $summary"
echo "Description: $description"
echo "Status: $status"
echo "Type: $type"

