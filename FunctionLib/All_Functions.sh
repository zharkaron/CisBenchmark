#!/bin/bash

source "$(dirname "$0")/FunctionLib/Section1InitialSetup.sh"
source "$(dirname "$0")/FunctionLib/Section2Services.sh"
source "$(dirname "$0")/FunctionLib/Section3Network.sh"
source "$(dirname "$0")/FunctionLib/Section4HostBasedFirewall.sh"
source "$(dirname "$0")/FunctionLib/Section5AccessControl.sh"
source "$(dirname "$0")/FunctionLib/Section6LoggingAndAuditing.sh"
source "$(dirname "$0")/FunctionLib/Section7SystemMaintenance.sh"

run_check_by_type_and_id() {
  local check_type="$1"
  local id="$2"
  local func="check_${check_type}"
  if declare -f "$func" > /dev/null; then
    "$func" "$id"
  else
    echo "UNKNOWN"
  fi
}
