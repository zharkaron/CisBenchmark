#!/bin/bash
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

source ./FunctionLib/All_Functions.sh

# make sure running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" >&2
  exit 1
fi

print_json_tree() {
  local indent="$1"
  local id check_type result children_count

  # Read JSON from stdin
  local json
  json=$(cat)

  # Check if the current node is an array
  if echo "$json" | jq -e 'type == "array"' >/dev/null; then
    echo "$json" | jq -c '.[]' | while read -r element; do
      echo "$element" | print_json_tree "$indent"
    done
    return
  fi

  id=$(echo "$json" | jq -r '.Summary // empty')
  check_type=$(echo "$json" | jq -r '.Check_Type // empty')

  # Print id with indentation and color
  printf "%s${CYAN}%s${NC}: %s" "$indent" "$id"

  # If it's a leaf node, run the check and print result in color
  if [[ -n "$check_type" ]]; then
    result=$(run_check_by_type_and_id "$check_type" "$id")
    if [[ "$result" == "PASS" ]]; then
      printf " ${GREEN}%s${NC}" "$result"
    elif [[ "$result" == "FAIL" ]]; then
      printf " ${RED}%s${NC}" "$result"
    else
      printf " %s" "$result"
    fi
  fi
  printf "\n"

  # Recursively print children
  children_count=$(echo "$json" | jq '.children | length // 0')
  if [[ "$children_count" -gt 0 ]]; then
    echo "$json" | jq -c '.children[]' | while read -r child; do
      echo "$child" | print_json_tree "  $indent"
    done
  fi
}

# Load the top-level JSON object
json_data=$(<json/Ubuntu22.04.json)
echo "$json_data" | print_json_tree ""
