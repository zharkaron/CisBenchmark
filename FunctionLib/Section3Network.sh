#!/bin/bash

check_IPv6() {
  local status
  status=$(grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable && echo -e "\n -IPv6 is enabled\n")
  if [ -z "$status" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_Wireless() {
  local wifi
  wifi=$( ip link | grep -E '^[0-9]+: wl[^:]*:' | grep 'UP')
  if [ -n "$wifi" ]; then
    echo "FAIL"
  else
    echo "PASS"
  fi

}

check_Bluetooth() {
  local bluetoothActive
  local bluetoothEnabled
  bluetoothEnable=$(systemctl is-enabled bluetooth.service 2>/dev/null | grep 'enabled')
  bluetoothActive=$(systemctl is-active bluetooth.service 2>/dev/null | grep 'active')
  if [ -n "$bluetoothActive" ] || [ -n "$bluetoothEnabled" ]; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_kernel_module() {
  local id="$1"
  local module_name
  module_name=$(get_kernel_module_name "$id")
  if lsmod | grep -wq "$module_name"; then
    echo -n "FAIL"
  else
    if grep -Riq "blacklist $module_name" /etc/modprobe.d/ 2>/dev/null; then
      echo -n "PASS"
    else
      echo -n "FAIL"
    fi
  fi
}


sysctl_value() {
    local key="$1"
    local expected="$2"
    local label="$3"

    actual=$(sysctl -n "$key" 2>/dev/null)

    if [[ "$actual" == "$expected" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Kernel module check function
get_kernel_module_name() {
  case "$1" in
    3.2.1) echo "dccp" ;;
    3.2.2) echo "tipc" ;;
    3.2.3) echo "rds" ;;
    3.2.4) echo "sctp" ;;
    *) echo "" ;;
  esac
}

check_ip_forward() {
    sysctl_value "net.ipv4.ip_forward" "0" "ip_forward: IP Forwarding Disabled"
}

check_packet_redirect() {
    sysctl_value "net.ipv4.conf.all.send_redirects" "0" "packet_redirect: Send Redirects Disabled"
}

check_icmp_ignore_bogus() {
    sysctl_value "net.ipv4.icmp_ignore_bogus_error_responses" "1" "icmp_ignore_bogus: Ignore Bogus ICMP Responses"
}

check_icmp_ignore() {
    sysctl_value "net.ipv4.icmp_echo_ignore_broadcasts" "1" "icmp_ignore: Ignore Broadcast ICMP Requests"
}

check_icmp_redirects() {
    sysctl_value "net.ipv4.conf.all.accept_redirects" "0" "icmp_redirects: ICMP Redirects Not Accepted"
}

check_secure_icmp_redirects() {
    sysctl_value "net.ipv4.conf.all.secure_redirects" "0" "secure_icmp_redirects: Secure ICMP Redirects Not Accepted"
}

check_reverse_path_filtering() {
    sysctl_value "net.ipv4.conf.all.rp_filter" "1" "reverse_path_filtering: Reverse Path Filtering Enabled"
}

check_source_routed_packets() {
    sysctl_value "net.ipv4.conf.all.accept_source_route" "0" "source_routed_packets: Source Routed Packets Not Accepted"
}

check_suspicious_packets() {
    sysctl_value "net.ipv4.conf.all.log_martians" "1" "suspicious_packets: Suspicious Packets Logged"
}

check_tcp_syn_cookies() {
    sysctl_value "net.ipv4.tcp_syncookies" "1" "tcp_syn_cookies: TCP SYN Cookies Enabled"
}

check_ipv6_router_advertisements() {
    sysctl_value "net.ipv6.conf.all.accept_ra" "0" "ipv6_router_advertisements: IPv6 RAs Not Accepted"
}
