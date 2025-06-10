#!/usr/bin/env bash

input_json="$1"

target_parent_id="1.1.2"

check_separate_partition() {
    local mount_point="$1"

    if [[ ! -d "$mount_point" ]]; then
        echo -n "FAIL"
        return
    fi

    local device=$(df -P "$mount_point" | awk 'NR==2 {print $1}')
    local root_device=$(df -P / | awk 'NR==2 {print $1}')

    if [[ -z "$device" ]]; then
        echo -n "FAIL"
        return
    fi

    if [[ "$device" == "$root_device" ]]; then
        echo -n "FAIL"
    else
        echo -n "PASS"
    fi
}

check_mount_option() {
    local mount_point="$1"
    local mount_option="$2"
    local expected_state="$3"
    local status_val="FAIL"

    if ! findmnt -M "$mount_point" &>/dev/null; then
        echo -n "FAIL"
        return
    fi

    local options=$(findmnt -M "$mount_point" -o OPTIONS --noheadings)

    if [[ "$expected_state" == "present" ]]; then
        if [[ "$options" == *"$mount_option"* ]]; then
            status_val="PASS"
        else
            status_val="FAIL"
        fi
    elif [[ "$expected_state" == "absent" ]]; then
        if [[ "$options" == *"$mount_option"* ]]; then
            status_val="FAIL"
        else
            status_val="PASS"
        fi
    else
        status_val="FAIL"
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
    .. | objects | select(.id | startswith($id + ".")) |
    select(.check_type == "partition" or .check_type == "mount_option")
' "$input_json")

results=()

while IFS= read -r check_obj; do
    id=$(jq -r '.id // empty' <<< "$check_obj")
    check_type=$(jq -r '.check_type // empty' <<< "$check_obj")
    mount_point=$(jq -r '.mount_point // empty' <<< "$check_obj")
    mount_option=$(jq -r '.mount_option // empty' <<< "$check_obj")
    expected_state=$(jq -r '.expected_state // empty' <<< "$check_obj")
    status_output=""

    if [[ -z "$id" || -z "$check_type" || -z "$mount_point" ]]; then
        status_output="ERROR: Missing required fields (id, check_type, or mount_point) in JSON for this item."
        results+=("{\"id\": \"$id\", \"status\": $(jq -Rs . <<< "$status_output")}")
        continue
    fi

    case "$check_type" in
        "partition")
            status_output=$(check_separate_partition "$mount_point")
            ;;
        "mount_option")
            if [[ -z "$mount_option" || -z "$expected_state" ]]; then
                status_output="ERROR: Missing required fields (mount_option or expected_state) for mount_option check for ID: $id."
            else
                status_output=$(check_mount_option "$mount_point" "$mount_option" "$expected_state")
            fi
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
