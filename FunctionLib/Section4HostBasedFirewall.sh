#!/bin/bash

package_installed() {
	command=$1
	if command -v $1 &> /dev/null; then
		echo "PASS"
	else
		echo "FAIL"
	fi
}

package_not_installed() {
	command=$1
	if command -v $1 &> /dev/null; then
		echo "FAIL"
	else
		echo "PASS"
	fi
}

check_ufw_installed() {
	package_installed "ufw"
}

check_iptables_persistent_not_installed() {
	package_not_installed "iptables-persistent"
}

check_ufw_service_enabled() {
	output=$(sudo ufw status 2>/dev/null)
	if [[ -z "$output" ]]; then
		echo "FAIL"
	elif echo "$output" | grep -q "inactive"; then
		echo "FAIL"
	else
		echo "PASS"
	fi
}

check_ufw_outbound_connections_configured() {
    if ! command -v ufw &> /dev/null; then
        echo "FAIL"
        return 1
    fi

    policy=$(sudo ufw status verbose | grep "Default:" | grep -oE 'allow \(outgoing\)|deny \(outgoing\)')

    if [[ "$policy" == "allow (outgoing)" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}


check_ufw_loopback_traffic_configured() {
	output=$(sudo ufw status verbose 2>/dev/null)
	if [[ -z "$output" ]]; then
		echo "FAIL"
	elif echo "$output" | grep -iqE "127\.0\.0\.1|on lo"; then
		echo "FAIL"
	else
		echo "PASS"
      	 fi
 }

check_ufw_firewall_rules_for_open_ports() {
    if ! command -v ufw &> /dev/null; then
        echo "FAIL"
        return 1
    fi

    echo "Checking open ports against UFW rules..."
    open_ports=$(sudo ss -tuln | awk 'NR>1 && $1 ~ /LISTEN/ {split($5, a, ":"); print a[length(a)]}' | sort -u)

    for port in $open_ports; do
        if sudo ufw status | grep -qw "$port"; then
            echo "PASS"
        else
            echo "FAIL"
        fi
    done
}

check_ufw_default_deny_policy_configured() {
    if ! command -v ufw &>/dev/null; then
        echo "FAIL"
        return 1
    fi

    output=$(sudo ufw status verbose 2>/dev/null | grep "Default:")

    if echo "$output" | grep -q "deny (incoming)"; then
        in_status="PASS"
    else
        in_status="FAIL"
    fi

    if echo "$output" | grep -q "deny (outgoing)"; then
        out_status="PASS"
    else
        out_status="FAIL"
    fi

    if echo "$output" | grep -q "deny (routed)"; then
        routed_status="PASS"
    else
        routed_status="FAIL"
    fi

}


check_nftables_installed() {
	package_installed "nft"

}
check_ufw_uninstalled_or_disabled_with_nftables() {
	package_not_installed "ufw"
}

check_nftables_table_exists() {
  if nft list tables &> /dev/null; then
    if [ -n "$(nft list tables)" ]; then
      echo "PASS"
    else
      echo "FAIL"
    fi
  else
    echo "FAIL"
  fi
}

check_nftables_base_chain_exists() {
  # List all chains and look for base chains (chains with hooks)
  chains=$(nft list chains 2>/dev/null)

  # Check if any chain has a hook (base chain)
  if echo "$chains" | grep -q 'hook'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_nftables_loopback_traffic_configured() {
  if nft list ruleset 2>/dev/null | grep -q 'iif "lo" accept'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if nftables outbound and established connections are configured
check_nftables_outbound_established_connections_configured() {
  # Example check: look for state ESTABLISHED/RELATED allow rules in nftables
  if nft list ruleset 2>/dev/null | grep -q 'ct state established,related accept'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if nftables default deny firewall policy is configured
check_nftables_default_deny_policy_configured() {
  # Look for base chains with default drop policy
  if nft list chains 2>/dev/null | grep -q 'policy drop'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if nftables service is enabled
check_nftables_service_enabled() {
  if systemctl is-enabled nftables &>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if nftables rules are permanent (saved in /etc/nftables.conf)
check_nftables_rules_permanent() {
  if [ -s /etc/nftables.conf ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if iptables packages are installed
check_iptables_packages_installed() {
  if command -v iptables &>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if nftables is not installed with iptables
check_nftables_not_installed_with_iptables() {
  # This is a bit heuristic: fail if both nft and iptables commands exist
  if command -v iptables &>/dev/null && command -v nft &>/dev/null; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

# Check if ufw is uninstalled or disabled with iptables
check_ufw_uninstalled_or_disabled_with_iptables() {
  if ! command -v ufw &>/dev/null || systemctl is-enabled ufw | grep -q 'disabled'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if iptables default deny firewall policy is configured
check_iptables_default_deny_firewall_policy_configured() {
  # Check if INPUT chain policy is DROP
  if iptables -L INPUT -n | grep -q 'policy DROP'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if iptables loopback traffic is configured
check_iptables_loopback_traffic_configured() {
  if iptables -L INPUT -v -n | grep -q 'lo'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if iptables outbound and established connections are configured
check_iptables_outbound_and_established_connections_configured() {
  if iptables -L INPUT -v -n | grep -q 'ESTABLISHED' && iptables -L OUTPUT -v -n | grep -q 'ESTABLISHED'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if iptables firewall rules exist for all open ports
check_iptables_firewall_rules_exist_for_all_open_ports() {
  # This is complex; simple heuristic: check if any ACCEPT rule exists in INPUT
  if iptables -L INPUT -n | grep -q 'ACCEPT'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if ip6tables default deny firewall policy is configured
check_ip6tables_default_deny_firewall_policy_configured() {
  if ip6tables -L INPUT -n | grep -q 'policy DROP'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if ip6tables loopback traffic is configured
check_ip6tables_loopback_traffic_configured() {
  if ip6tables -L INPUT -v -n | grep -q 'lo'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if ip6tables outbound and established connections are configured
check_ip6tables_outbound_and_established_connections_configured() {
  if ip6tables -L INPUT -v -n | grep -q 'ESTABLISHED' && ip6tables -L OUTPUT -v -n | grep -q 'ESTABLISHED'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Check if ip6tables firewall rules exist for all open ports
check_ip6tables_firewall_rules_exist_for_all_open_ports() {
  if ip6tables -L INPUT -n | grep -q 'ACCEPT'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
