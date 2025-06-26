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

# Service checks
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

# Function to check if the Mail Transfer Agent (MTA) is configured to listen only on localhost
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

# client checks
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
