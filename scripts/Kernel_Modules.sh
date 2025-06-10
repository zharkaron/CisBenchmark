#!/usr/bin/env bash

input_json="$1"

target_parent_id="1.1.1"

check_kernel_module_not_available() {
    local module_name="$1"
    local status_val=""

    if lsmod | grep -wq "$module_name"; then
        status_val="FAIL"
    else
        if grep -Riq "blacklist $module_name" /etc/modprobe.d/ 2>/dev/null; then
            status_val="PASS"
        else
            status_val="FAIL"
        fi
    fi

    if [[ "$status_val" == "PASS" ]]; then
        echo -n "PASS"
    else
        echo -n "FAIL"
    fi
}

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to run this script." >&2
    exit 1
fi

checks_json=$(jq -c --arg id "$target_parent_id" '
    .. | objects | select(.id | startswith($id + ".")) | select(.check_type == "kernel_module")
' "$input_json")

results=()

while IFS= read -r check_obj; do
    id=$(jq -r '.id // empty' <<< "$check_obj")
    check_type=$(jq -r '.check_type // empty' <<< "$check_obj")
    module_name=$(jq -r '.module_name // empty' <<< "$check_obj")
    status_output=""

    if [[ -z "$id" || -z "$check_type" || -z "$module_name" ]]; then
        status_output="ERROR: Missing required fields (id, check_type, or module_name) in JSON for this item."
        results+=("{\"id\": \"$id\", \"status\": $(jq -Rs . <<< "$status_output")}")
        continue
    fi

    case "$check_type" in
        "kernel_module")
            status_output=$(check_kernel_module_not_available "$module_name")
            ;;
        *)
            status_output="N/A: Unknown or unsupported 'check_type': '$check_type' for ID: $id."
            ;;
    esac

    results+=("{\"id\": \"$id\", \"status\": $(jq -Rs . <<< "$status_output")}")

done <<< "$checks_json"

if [ ${#results[@]} -gt 0 ]; then
    printf "%s\n" "${results[@]}" | jq -s '.'
else
    echo "[]"
fi
