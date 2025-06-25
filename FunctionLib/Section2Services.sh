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
