#!/usr/bin/env bash

JSON_FILE="./json/cis_benchmark.json"
RESULTS_FILE="./json/results.json"

COLOR_RESET="\033[0m"
COLOR_CYAN="\033[36m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"

get_result() {
	  local id="$1"
	    jq -r --arg id "$id" '.[] | select(.id == $id) | .status' "$RESULTS_FILE" 2>/dev/null
    }

    print_controls() {
	      local json="$1"
	        local indent="$2"

		  local id=$(echo "$json" | jq -r '.id // empty')
		    local desc=$(echo "$json" | jq -r '.description // empty')
		      local script=$(echo "$json" | jq -r '.script // empty')

		        if [[ -n "$script" && -x "$script" ]]; then
				    echo -e "${COLOR_CYAN} Running $script${COLOR_RESET}"
				        "$script" "$JSON_FILE" "$RESULTS_FILE"
					  fi

					    if [[ -n "$id" && -n "$desc" ]]; then
						        printf "%b%s%b: %s" "$COLOR_CYAN" "$indent$id" "$COLOR_RESET" "$desc"

							    result=$(get_result "$id")
							        if [[ "$result" == "PASS" ]]; then
									      printf " %b%s%b\n" "$COLOR_GREEN" "$result" "$COLOR_RESET"
									          elif [[ "$result" == "FAIL" ]]; then
											        printf " %b%s%b\n" "$COLOR_RED" "$result" "$COLOR_RESET"
												    else
													          printf "\n"
														      fi
														        fi

															  echo "$json" | jq -c '.children[]?' | while read -r child; do
															      print_controls "$child" "  $indent"
															        done
															}

															json_data=$(<"$JSON_FILE")
															is_array=$(echo "$json_data" | jq 'if type=="array" then 1 else 0 end')

															if [ "$is_array" -eq 1 ]; then
																  echo "$json_data" | jq -c '.[]' | while read -r item; do
																      print_controls "$item" ""
																        done
																else
																	  print_controls "$json_data" ""
															fi

