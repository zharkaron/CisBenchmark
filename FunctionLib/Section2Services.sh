#!/bin/bash

# Function to check if a service is enabled or active
check_service() {
  local pkg="$1"
  shift
  local services=("$@")
  local enabled=false
  local active=false

  if dpkg-query -s "$pkg" >/dev/null 2>&1; then
    enabled=true
  fi

  for svc in "${services[@]}"; do
    if systemctl is-enabled "$svc" 2>/dev/null | grep -q 'enabled'; then
      enabled=true
    fi
    if systemctl is-active "$svc" 2>/dev/null | grep -q 'active'; then
      active=true
    fi
  done

  if $enabled || $active; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_autofs() {
  check_service autofs autofs.service
}
check_avahi() {
  check_service avahi-daemon avahi-daemon.socket avahi-daemon.service
}
check_dhcp() {
  check_service isc-dhcp-server isc-dhcp-server.service isc-dhcp-server6.service
}
check_dns() {
  check_service bind9 bind9.service
}
check_dnsmasq() {
  check_service dnsmasq dnsmasq.service
}
check_ftp() {
  check_service vsftpd vsftpd.service
}
check_ldap() {
  check_service slapd slapd.service
}
check_dovecot() {
  check_service "dovecot dovecot-imapd dovecot-pop3d" dovecot.service dovecot.socket
}
check_nfs() {
  check_service nfs-kernel-server nfs-server.service
}
check_nis() {
  check_service ypserv ypserv.service
}
check_cups() {
  check_service cups cups.service cups.socket
}
check_rpcbind() {
  check_service rpcbind rpcbind.service rpcbind.socket
}
check_rsync() {
  check_service rsync rsync.service
}
check_samba() {
  check_service samba smbd.service
}
check_snmp() {
  check_service snmpd snmpd.service
}
check_tftp() {
  check_service tftpd tftpd-hpa.service
}
check_squid() {
  check_service squid squid.service
}
check_apache() {
  check_service "apache2 nginx" apache2.service apache2.socket nginx.service nginx.socket
}
check_xinetd() {
  check_service xinetd xinetd.service
}
check_XWindows() {
  check_service xserver-common
}
check_MailTransferAgent() {
  inet_interfaces=$(postconf -h inet_interfaces 2>/dev/null)
  if [[ "$inet_interfaces" == "loopback-only" || "$inet_interfaces" == "localhost" || "$inet_interfaces" == "127.0.0.1" ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_ApprovedServices() {
  local approved_file="./approved_services.txt"
  local approved_ports=()

  # If file exists and is not empty, read approved ports from it
  if [[ -s "$approved_file" ]]; then
    mapfile -t approved_ports < "$approved_file"
  else
    # Default to only port 22 (SSH)
    approved_ports=(22)
  fi

  local listening_ports
  listening_ports=$(ss -tulnH | awk '{print $5}' | awk -F: '{print $NF}' | grep -E '^[0-9]+$' | sort -u)

  for port in $listening_ports; do
    local allowed=false
    for ap in "${approved_ports[@]}"; do
      if [[ "$port" == "$ap" ]]; then
        allowed=true
        break
      fi
    done

    if ! $allowed; then
      echo "FAIL"
      return 1
    fi
  done

  echo "PASS"
  return 0
}
package_check() {
  local pkg="$1"
  # if package is not installed then return pass
  if ! dpkg-query -s "$pkg" >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_NISClient() {
  package_check nis
}
check_RSHClient() {
  package_check rsh-client
}
check_TalkClient() {
  package_check talk
}
check_TelnetClient() {
  package_check telnet
}
check_LDAPClient() {
  package_check ldap-utils
}
check_FTPClient() {
  package_check ftp
}
check_SingleSync() {
  local count=0

  for svc in systemd-timesyncd.service chrony.service; do
    if systemctl is-enabled "$svc" &>/dev/null && systemctl is-active "$svc" &>/dev/null; then
      ((count++))
    fi
  done

  if [[ "$count" -eq 1 ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_TimesyncdConfig() {
  local config_file="/etc/systemd/timesyncd.conf"
  local config=$(systemd-analyze cat-config "$config_file" 2>/dev/null)

  # Check if NTP and FallbackNTP are set (not commented out)
  grep -Eiq '^\s*NTP=' <<< "$config" && local ntp_set=true || ntp_set=false
  grep -Eiq '^\s*FallbackNTP=' <<< "$config" && local fallback_set=true || fallback_set=false

  if $ntp_set && $fallback_set; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_TimesyncdEnabled() {
  local enabled
  local active

  enabled=$(systemctl is-enabled systemd-timesyncd.service 2>/dev/null)
  active=$(systemctl is-active systemd-timesyncd.service 2>/dev/null)

  if [[ "$enabled" == "enabled" && "$active" == "active" ]]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_ChronyConfig() {
  local timesyncd_active="n"
  local chrony_active="n"

  # Check systemd-timesyncd service enabled and active
  if systemctl is-enabled systemd-timesyncd.service &>/dev/null && systemctl is-active systemd-timesyncd.service &>/dev/null; then
    timesyncd_active="y"
  fi

  # Check chrony config for 'server' or 'pool'
  if grep -Pq '^\s*(server|pool)\s+\S+' /etc/chrony/*.conf 2>/dev/null; then
    chrony_active="y"
  fi

  if [[ $timesyncd_active == "y" && $chrony_active == "y" ]]; then
    echo "FAIL"
  elif [[ $timesyncd_active == "n" && $chrony_active == "n" ]]; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}
check_ChronyUser() {
  # Check if chronyd is running
  if pgrep chronyd > /dev/null 2>&1; then
    # Check if any chronyd process is NOT running as _chrony
    if ps -eo user,comm | awk '/[c]hronyd/ && $1 != "_chrony" { exit 1 }'; then
      echo "PASS"
    else
      echo "FAIL"
    fi
  else
    # Chronyd not running, so either not in use or irrelevant for this test
    echo "FAIL"
  fi
}
check_chrony_enabled_running() {
  if systemctl is-enabled chrony.service &>/dev/null && systemctl is-active chrony.service &>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}
check_CronEnabled() {
  if systemctl list-unit-files | awk '$1~/^crond?\.service/{print $2}' | grep -q 'enabled' && systemctl list-units | awk '$1~/^crond?\.service/{print $3}' | grep -q "active"; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

CronPerm() {
  # variable to hold the file or directory name
  local file="$1"
  if stat -Lc 'Access: (%a/%A) Uid: ( %u/ %U) Gid: ( %g/ %G)' /etc/$file | grep -q 'Access: (600/-rw-------) Uid: ( 0/ root) Gid: ( 0/ root)"'; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_CronTab() {
  CronPerm "crontab"
}

check_CronHourly() {
  CronPerm "cron.hourly/"
}
