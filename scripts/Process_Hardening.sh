#!/usr/bin/env bash

input_json="$1"
target_parent_id="1.5"

#!/usr/bin/env bash

audit_kernel_param() {
    local l_kpname="$1"
    local l_kpvalue="$2"
    local l_output2=""
    local l_ufwscf
    l_ufwscf="$([ -f /etc/default/ufw ] && awk -F= '/^\s*IPT_SYSCTL=/ {print $2}' /etc/default/ufw)"

    kernel_parameter_chk() {
        local l_krp
        l_krp="$(sysctl "$l_kpname" | awk -F= '{print $2}' | xargs)"
        if [ "$l_krp" != "$l_kpvalue" ]; then
            l_output2=1
        fi
        unset A_out; declare -A A_out
        while read -r l_out; do
            if [ -n "$l_out" ]; then
                if [[ $l_out =~ ^\s*# ]]; then
                    l_file="${l_out//# /}"
                else
                    l_kpar="$(awk -F= '{print $1}' <<< "$l_out" | xargs)"
                    [ "$l_kpar" = "$l_kpname" ] && A_out+=(["$l_kpar"]="$l_file")
                fi
            fi
        done < <(/usr/lib/systemd/systemd-sysctl --cat-config | grep -Po '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')
        if [ -n "$l_ufwscf" ]; then
            l_kpar="$(grep -Po "^\h*$l_kpname\b" "$l_ufwscf" | xargs)"
            l_kpar="${l_kpar//\//.}"
            [ "$l_kpar" = "$l_kpname" ] && A_out+=(["$l_kpar"]="$l_ufwscf")
        fi
        if (( ${#A_out[@]} > 0 )); then
            while IFS="=" read -r l_fkpname l_fkpvalue; do
                l_fkpname="${l_fkpname// /}"; l_fkpvalue="${l_fkpvalue// /}"
                if [ "$l_fkpvalue" != "$l_kpvalue" ]; then
                    l_output2=1
                fi
            done < <(grep -Po -- "^\h*$l_kpname\h*=\h*\H+" "${A_out[@]}")
        else
            l_output2=1
        fi
    }

    if ! grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable && grep -q '^net.ipv6.' <<< "$l_kpname"; then
        echo "PASS"
        return
    else
        kernel_parameter_chk
    fi

    if [ -z "$l_output2" ]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

check_prelink_not_installed() {
    if  ! command -v prelink >/dev/null 2>&1; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

check_auto_error_reporting_disabled() {
    if [ -f /etc/default/apport ]; then
        if grep -q '^enabled=0' /etc/default/apport; then
            echo "PASS"
        else
            echo "FAIL"
        fi
    fi
}

# Dispatches and runs the appropiate check function based on check_type
run_check() {
    local check_type="$1"
    local result
    case "$check_type" in
        aslr_enabled)
          result="$(audit_kernel_param "kernel.randomize_va_space" "2")"
            ;;
          ptrace_score)
            result="$(audit_kernel_param "kernel.yama.ptrace_scope" "1")"
            ;;
          core_dumps_restricted)
            result="$(audit_kernel_param "fs.suid_dumpable" "0")"
            ;;
          prelink_not_installed)
            result="$(check_prelink_not_installed)"
            ;;
          auto_error_reporting)
            result="$(check_auto_error_reporting_disabled)"
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
