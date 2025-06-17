#!/usr/bin/env bash

input_json="$1"
target_parent_id="1.3"

# Checks if apparmor is installed and its utils are available
apparmor_enabled() {
    installed=$(dpkg-query -s apparmor 2>/dev/null)
    utils_installed=$(dpkg-query -s apparmor-utils 2>/dev/null)
    if [[ "$installed" == *"install ok installed"* ]] && [[ "$utils_installed" == *"install ok installed"* ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Checks if apparmor is enabled on boot
boot_armor() {
    app=$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "apparmor=1")
    sec_armor=$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "security=apparmor")
    if [[ app == "" ]] && [[ sec_armor == "" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensures that AppArmor Profiles are in enforced or complain mode
apparmor_profiles() {
    profile_kill=$(apparmor_status | grep profiles | grep "kill mode" | awk '{print $1}')
    profile_enforce=$(apparmor_status | grep profiles | grep "enforce mode" | awk '{print $1}')
    processes_kill=$(apparmor_status | grep processes | grep "kill mode" | awk '{print $1}')
    processes_enforce=$(apparmor_status | grep processes | grep "enforce mode" | awk '{print $1}')
    if [[ -z "$profile_kill" || "$profile_kill" == "0" ]] && \
       [[ -z "$profile_enforce" || "$profile_enforce" == "0" ]] && \
       [[ -z "$processes_kill" || "$processes_kill" == "0" ]] && \
       [[ -z "$processes_enforce" || "$processes_enforce" == "0" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensures that AppArmor Profiles are in enforcing
apparmor_profiles_enforce() {
    profile_complain=$(apparmor_status | grep profiles | grep "complain mode" | awk '{print $1}')
    profile_kill=$(apparmor_status | grep profiles | grep "kill mode" | awk '{print $1}')
    profile_unconfined=$(apparmor_status | grep profiles | grep "unconfined mode" | awk '{print $1}')
    if { [[ -z "$profile_complain" || "$profile_complain" == "0" ]] && \
         [[ -z "$profile_kill" || "$profile_kill" == "0" ]] && \
         [[ -z "$profile_unconfined" || "$profile_unconfined" == "0" ]]; }; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Dispatches and runs the appropiate check function based on check_type
run_check() {
    local check_type="$1"
    local result
    case "$check_type" in
        apparmor_enabled)
            result=$(apparmor_enabled)
            ;;
        boot_armor)
            result=$(boot_armor)
            ;;
        apparmor_profiles)
            result=$(apparmor_profiles)
            ;;
        apparmor_profiles_enforce)
            result=$(apparmor_profiles_enforce)
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
