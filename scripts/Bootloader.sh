#!/usr/bin/env bash

input_json="$1"
target_parent_id="1.4"

# Function to check the password of the boot loader
boot_password() {
  user=$(grep "^set superusers" /boot/grub/grub.cfg)
  password=$(awk -F. '/^\s*password/ {print $1"."$2"."$3}' /boot/grub/grub.cfg)
  if [[ -z "$user" ]] || [[ -z "$password" ]]; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

# function to check the config of the boot loader
boot_config() {
  conf=&(stat -Lc 'Access: (%#a/%A) /boot/grub/grub.cfg Uid: (%u/%U) Gid: (%g/%G)' /boot/grub/grub.cfg)
  if [[ "$conf" != "Access: (0644/-rw-r--r--) /boot/grub/grub.cfg Uid: (0/root) Gid: (0/root)" ]]; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

# Dispatches and runs the appropiate check function based on check_type
run_check() {
    local check_type="$1"
    local result
    case "$check_type" in
      boot_password)
        result=$(boot_password)
        ;;
      boot_config)
        result=$(boot_config)
        ;;
      *)
        result="unknown"
        ;;
    esac
    echo "$result"
}

# Finds and returns the JSON object with the specified ID from the input file
find_object_by_id() {
    local id="$1"
    local obj
    obj=$(jq -c --arg id "$id" '
      .. | select(type == "object" and .id? == $id)
    ' < "$input_json" | head -n 1)
    if [ -z "$obj" ]; then
        echo '{}'
    else
        echo "$obj"
    fi
}

# Recursively runs checks on all children in a JSON object and aggregates results
collect_checks() {
    local json
    json=$(cat)
    local results=()
    local children
    children=$(echo "$json" | jq -c '.children[]?')
    while read -r child; do
        check_type=$(echo "$child" | jq -r '.check_type // empty')
        id=$(echo "$child" | jq -r '.id // empty')
        if [ -n "$check_type" ] && [ -n "$id" ]; then
            result=$(run_check "$check_type")
            results+=("$(jq -n --arg id "$id" --arg status "$result" '{id: $id, status: $status}')")
        fi
        # Recursively process children
        if echo "$child" | jq -e '.children | length > 0' >/dev/null; then
            subresults=$(echo "$child" | collect_checks)
            if [ -n "$subresults" ] && [ "$subresults" != "[]" ]; then
                subresults=$(echo "$subresults" | jq -c '.[]')
                while read -r subitem; do
                    results+=("$subitem")
                done <<< "$subresults"
            fi
        fi
    done <<< "$children"
    if [ ${#results[@]} -gt 0 ]; then
        printf "%s\n" "${results[@]}" | jq -s '.'
    else
        echo "[]"
    fi
}

# Finds the target parent object and initiates recursive check processing
process_json() {
    parent_obj=$(find_object_by_id "$target_parent_id")
    if [ -z "$parent_obj" ] || [ "$parent_obj" = "{}" ]; then
        echo "[]"
        return
    fi
    collect_checks < <(echo "$parent_obj")
}

process_json
