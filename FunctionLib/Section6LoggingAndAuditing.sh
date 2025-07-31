#!/bin/bash

check_AIDE_installed() {
  if command -v aide >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_filesystem_integrity() {
  # Check if AIDE cron job or systemd timer exists (example)
  if systemctl list-timers | grep -q aide; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_cryptographic_mechanisms() {
  # Example: Check if auditctl is owned by root with strict perms
  if [ -x /sbin/auditctl ] && [ "$(stat -c %U /sbin/auditctl)" = "root" ] && [ "$(stat -c %a /sbin/auditctl)" -le 755 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_journald_enabled() {
  if systemctl is-enabled systemd-journald >/dev/null 2>&1 && systemctl is-active systemd-journald >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_journald_access() {
  if [ -d /var/log/journal ] && [ "$(stat -c %a /var/log/journal)" -le 750 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_journald_rotation() {
  # Check journald rotation config in /etc/systemd/journald.conf
  if grep -Eiq '^SystemMaxUse=' /etc/systemd/journald.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_journald_ForwardToSyslog() {
  # Ensure ForwardToSyslog=no in journald.conf
  if grep -Eiq '^ForwardToSyslog=no' /etc/systemd/journald.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_journald_storage() {
  # Ensure Storage setting exists and not "auto"
  if grep -Eiq '^Storage=persistent' /etc/systemd/journald.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_journald_compress() {
  # Check if Compress=yes is set
  if grep -Eiq '^Compress=yes' /etc/systemd/journald.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_systemd-journal-remote() {
  if command -v systemd-journal-remote >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_systemd-journal-remote_authentication() {
  # Placeholder: Assume checking config file for authentication enabled
  if grep -Eiq '^\s*Seal=yes' /etc/systemd/journal-remote.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_systemd-journal-upload_enabled() {
  if systemctl is-enabled systemd-journal-upload >/dev/null 2>&1 && systemctl is-active systemd-journal-upload >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_systemd-journald-remote_noinuse() {
  # Check if systemd-journal-remote service is disabled/not running
  if systemctl is-enabled systemd-journal-remote >/dev/null 2>&1; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_logfiles_access() {
  # Example: check permissions on /var/log
  if [ -d /var/log ] && [ "$(stat -c %a /var/log)" -le 750 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_auditd_installed() {
  if command -v auditd >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_auditd_enabled() {
  if systemctl is-enabled auditd >/dev/null 2>&1 && systemctl is-active auditd >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_auditing_bfr_auditd() {
  # Check kernel boot params for audit=1 or similar (example)
  if grep -q audit=1 /proc/cmdline; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_autidit_backlog_limit_sufficient() {
  # Check audit_backlog_limit in /etc/audit/auditd.conf or sysctl -a
  local val
  val=$(grep ^audit_backlog_limit /etc/audit/auditd.conf 2>/dev/null | awk '{print $3}')
  if [[ $val =~ ^[0-9]+$ ]] && [ "$val" -ge 8192 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_log_storage_config() {
  # Placeholder: check auditd.conf for max_log_file action or size
  if grep -Eq '^max_log_file' /etc/audit/auditd.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_logs_not_automatically_deleteld() {
  # Check if max_log_file_action is not "delete"
  if grep -Eq '^max_log_file_action\s*=\s*(?!delete)' /etc/audit/auditd.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_system_disabled_logs_full() {
  # Check if space_left_action is set to "halt"
  if grep -Eq '^space_left_action\s*=\s*halt' /etc/audit/auditd.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_alarm_logs_full() {
  # Check if admin_space_left_action is set to "email" or "exec"
  if grep -Eq '^admin_space_left_action\s*=\s*(email|exec)' /etc/audit/auditd.conf 2>/dev/null; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_sudoers() {
  # Check if sudoers file exists and perms are 440 or stricter
  if [ -f /etc/sudoers ] && [ "$(stat -c %a /etc/sudoers)" -le 440 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_actions_logged() {
  # Placeholder: check if audit rules include '-w /etc/passwd' or similar for user actions
  if auditctl -l 2>/dev/null | grep -q 'user' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_mod_sudo_log_file() {
  # Check audit rules for sudo log file modifications
  if auditctl -l 2>/dev/null | grep -q 'sudo' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_mod_date_time() {
  # Check audit rules for date/time modifications
  if auditctl -l 2>/dev/null | grep -q 'time-change' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_system_network() {
  # Check audit rules for network environment changes
  if auditctl -l 2>/dev/null | grep -q 'network' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_priviledge_commands() {
  # Check audit rules for privileged commands
  if auditctl -l 2>/dev/null | grep -q 'privileged' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_unsuccessful_priv_commands() {
  # Check audit rules for unsuccessful privileged command attempts
  if auditctl -l 2>/dev/null | grep -q 'failed' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_acpm() {
  # Define audit rules patterns that capture DAC permission changes (chmod-related syscalls)
  local patterns=(
    "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat"
    "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat"
    "-w /etc/group -p wa -k perm_mod"
    "-w /etc/passwd -p wa -k perm_mod"
    "-w /etc/shadow -p wa -k perm_mod"
    "-w /etc/gshadow -p wa -k perm_mod"
  )
  
  # Check all rules files for at least one of these patterns
  local files="/etc/audit/audit.rules /etc/audit/rules.d/*.rules"
  local found=0

  for pattern in "${patterns[@]}"; do
    if grep -E -- "$pattern" $files >/dev/null 2>&1; then
      found=1
      break
    fi
  done

  if [ $found -eq 1 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_mod_user/group() {
  # Check audit rules for user/group modifications
  if auditctl -l 2>/dev/null | grep -q 'identity' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_sys_mount() {
  # Check audit rules for mount operations
  if auditctl -l 2>/dev/null | grep -q 'mount' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_session_init_info() {
  # Check audit rules for session init info
  if auditctl -l 2>/dev/null | grep -q 'session' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_log_logout() {
  # Check audit rules for login/logout events
  if auditctl -l 2>/dev/null | grep -q 'logout' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_file_deletion() {
  # Check audit rules for file deletion
  if auditctl -l 2>/dev/null | grep -q 'unlink' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_mod_mac() {
  # Check audit rules for MAC modifications
  if auditctl -l 2>/dev/null | grep -q 'mac' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_chcon_used() {
  # Check if chcon binary exists and perms
  if command -v chcon >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_setfacl_used() {
  if command -v setfacl >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_chacl_used() {
  # chacl is less common, check command existence
  if command -v chacl >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_usermod_used() {
  if command -v usermod >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_module_load_unload() {
  # Check audit rules for module load/unload
  if auditctl -l 2>/dev/null | grep -q 'modules' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_immutable() {
  # Check if auditctl is in immutable mode
  if auditctl -s 2>/dev/null | grep -q 'enabled' ; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_run_disk_same() {
  # Placeholder: check if audit logs are stored on the same disk as system logs
  # Complex check, so just returning FAIL for now
  echo "FAIL"
}

check_audit_log_files() {
  # Check if audit log files exist
  if [ -f /var/log/audit/audit.log ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_log_files_owner() {
  if [ "$(stat -c %U /var/log/audit/audit.log 2>/dev/null)" = "root" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_log_group_owner() {
  if [ "$(stat -c %G /var/log/audit/audit.log 2>/dev/null)" = "root" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_log_file_directory() {
  if [ -d /var/log/audit ] && [ "$(stat -c %a /var/log/audit)" -le 750 ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_config() {
  if [ -f /etc/audit/auditd.conf ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_config_owner() {
  if [ "$(stat -c %U /etc/audit/auditd.conf 2>/dev/null)" = "root" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_config_group() {
  if [ "$(stat -c %G /etc/audit/auditd.conf 2>/dev/null)" = "root" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_tools() {
  # Check if auditctl and ausearch exist
  if command -v auditctl >/dev/null 2>&1 && command -v ausearch >/dev/null 2>&1; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_tools_owner() {
  if [ "$(stat -c %U $(command -v auditctl 2>/dev/null))" = "root" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

check_audit_tools_group() {
  if [ "$(stat -c %G $(command -v auditctl 2>/dev/null))" = "root" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

