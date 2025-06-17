#!/usr/bin/env bash

# I wanna check that they run the script through sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root or with sudo." >&2
    exit 1
fi

JSON_FILE="./json/cis_benchmark.json"
RESULTS_FILE="./json/results.json"

COLOR_RESET="\033[0m"
COLOR_CYAN="\033[36m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"

declare -g ALL_COLLECTED_RESULTS=()

get_result() {
    local id="$1"
    for item_json in "${ALL_COLLECTED_RESULTS[@]}"; do
        local found_id=$(echo "$item_json" | jq -r '.id // empty')
        if [[ "$found_id" == "$id" ]]; then
            echo "$item_json" | jq -r '.status // empty'
            return
        fi
    done
    echo ""
}

print_controls() {
    local json_obj_str="$1"
    local indent="$2"

    local id=$(echo "$json_obj_str" | jq -r '.id // empty')
    local desc=$(echo "$json_obj_str" | jq -r '.title // empty')
    local script_path=$(echo "$json_obj_str" | jq -r '.script // empty')

    if [[ -n "$script_path" && -x "$script_path" ]]; then
        echo -e "${COLOR_CYAN}${indent}Running script: $script_path${COLOR_RESET}"
        local script_output
        script_output=$(bash "$script_path" "$JSON_FILE" "$RESULTS_FILE" 2>&1)

        if [[ -n "$script_output" ]]; then
            local -a parsed_script_results
            if mapfile -t parsed_script_results < <(echo "$script_output" | jq -c '.[]'); then
                for item in "${parsed_script_results[@]}"; do
                    ALL_COLLECTED_RESULTS+=("$item")
                done
            else
                echo -e "${COLOR_RED}${indent}Warning: Script '$script_path' output is NOT valid JSON array or empty. Raw Output: '$script_output'${COLOR_RESET}" >&2
            fi
        fi
    fi

    if [[ -n "$id" && -n "$desc" ]]; then
        printf "%b%s%s%b: %s" "$COLOR_CYAN" "$indent" "$id" "$COLOR_RESET" "$desc"

        local result=$(get_result "$id")
        if [[ "$result" == "PASS" ]]; then
            printf " %b%s%b\n" "$COLOR_GREEN" "$result" "$COLOR_RESET"
        elif [[ "$result" == "FAIL"* ]]; then
            printf " %b%s%b\n" "$COLOR_RED" "$result" "$COLOR_RESET"
        else
            printf "\n"
        fi
    fi

    local -a children_array
    if mapfile -t children_array < <(echo "$json_obj_str" | jq -c '.children[]?'); then
        for child_obj in "${children_array[@]}"; do
            print_controls "$child_obj" "  $indent"
        done
    fi
}

if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to run this script." >&2
    exit 1
fi

> "$RESULTS_FILE"

json_data=$(<"$JSON_FILE")

top_level_objects=()
if mapfile -t top_level_objects < <(echo "$json_data" | jq -c 'if type=="array" then .[] else . end'); then
    for item in "${top_level_objects[@]}"; do
        print_controls "$item" ""
    done
else
    echo "Error: Could not parse top-level JSON from $JSON_FILE." >&2
    exit 1
fi

first=true
{
    echo "["
    for item_json in "${ALL_COLLECTED_RESULTS[@]}"; do
        if [ "$first" = false ]; then
            echo ","
        fi
        echo -n "  $item_json"
        first=false
    done
    echo ""
    echo "]"
} > "$RESULTS_FILE"

echo -e "\n${COLOR_CYAN}Compliance scan finished. All results consolidated in $RESULTS_FILE.${COLOR_RESET}"
