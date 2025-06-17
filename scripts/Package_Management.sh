#!/usr/bin/env bash

input_json="$1"
target_parent_id="1.2"

gpg_keys() {
    if find /etc/apt/trusted.gpg.d -type f -name "*.gpg" 2>/dev/null | grep -q .; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

repo_conf() {
    if sudo apt update >/dev/null 2>&1; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

sec_updates() {
    if sudo apt update >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

run_check() {
    local check_type="$1"
    local result
    case "$check_type" in
        gpg_keys)
            result=$(gpg_keys)
            ;;
        repo_conf)
            result=$(repo_conf)
            ;;
        sec_updates)
            result=$(sec_updates)
            ;;
        *)
            result="unknown"
            ;;
    esac
    echo "$result"
}

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

process_json() {
    parent_obj=$(find_object_by_id "$target_parent_id")
    if [ -z "$parent_obj" ] || [ "$parent_obj" = "{}" ]; then
        echo "[]"
        return
    fi
    collect_checks < <(echo "$parent_obj")
}

process_json
