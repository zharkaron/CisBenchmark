#!/usr/bin/env bash

input_json="$1"
output_json="$2"
target_id="1.1.1"

check_module() {
	  local name="$1"
	    local pass=true

	      if ! modprobe --showconfig | grep -Pq "^\s*blacklist\s+$name\b"; then
		          pass=false
			    fi

			      if ! modprobe -n -v "$name" | grep -qE 'install /bin/(true|false)'; then
				          pass=false
					    fi

					      if lsmod | grep -q "^$name"; then
						          pass=false
							    fi

							      $pass && echo "PASS" || echo "FAIL"
						      }

						      children=$(jq -c --arg id "$target_id" '
						        .. | objects | select(.id? == $id) | .children // []
							' "$input_json")

							results=()

							while IFS= read -r child; do
								  id=$(jq -r '.id' <<< "$child")
								    name=$(jq -r '.name // empty' <<< "$child")
								      [[ -z "$name" ]] && continue
								        status=$(check_module "$name")
									  results+=("{\"id\": \"$id\", \"status\": \"$status\"}")
								  done <<< "$(jq -c '.[]' <<< "$children")"

								  {
									    echo "["
									      printf "  %s\n" "$(IFS=,$'\n'; echo "${results[*]}")"
									        echo "]"
									} > "$output_json"
