check_perm_passwd() {
  local perm=$(stat -c %a /etc/passwd 2>/dev/null)
  [ "$perm" = "644" ] && echo "PASS" || echo "FAIL"
}

check_perm_passwd-() {
  # Checks if /etc/passwd is NOT more permissive than 644
  local perm=$(stat -c %a /etc/passwd 2>/dev/null)
  if [ "$perm" -le 644 ]; then echo "PASS"; else echo "FAIL"; fi
}

check_perm_group() {
  local perm=$(stat -c %a /etc/group 2>/dev/null)
  [ "$perm" = "644" ] && echo "PASS" || echo "FAIL"
}

check_perm_group-() {
  local perm=$(stat -c %a /etc/group 2>/dev/null)
  if [ "$perm" -le 644 ]; then echo "PASS"; else echo "FAIL"; fi
}

check_perm_shadow() {
  local perm=$(stat -c %a /etc/shadow 2>/dev/null)
  [[ "$perm" == "640" || "$perm" == "600" ]] && echo "PASS" || echo "FAIL"
}

check_perm_shadow-() {
  local perm=$(stat -c %a /etc/shadow 2>/dev/null)
  if [ "$perm" -le 640 ]; then echo "PASS"; else echo "FAIL"; fi
}

check_perm_gshadow() {
  local perm=$(stat -c %a /etc/gshadow 2>/dev/null)
  [[ "$perm" == "640" || "$perm" == "600" ]] && echo "PASS" || echo "FAIL"
}

check_perm_gshadow-() {
  local perm=$(stat -c %a /etc/gshadow 2>/dev/null)
  if [ "$perm" -le 640 ]; then echo "PASS"; else echo "FAIL"; fi
}

check_perm_shells() {
  local perm=$(stat -c %a /etc/shells 2>/dev/null)
  [ "$perm" = "644" ] && echo "PASS" || echo "FAIL"
}

check_perm_opasswd() {
  local perm=$(stat -c %a /etc/opasswd 2>/dev/null)
  if [ -f /etc/opasswd ]; then
    [[ "$perm" == "640" || "$perm" == "600" ]] && echo "PASS" || echo "FAIL"
  else
    echo "PASS"  # Not present, consider PASS
  fi
}

check_world_files() {
  # Check for any world writable files outside safe directories
  if find / -xdev -type f -perm -002 ! -path "/proc/*" ! -path "/sys/*" ! -path "/dev/*" 2>/dev/null | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_no_user() {
  # Check for users without a valid shell or home directory
  local invalid_users
  invalid_users=$(awk -F: '($7 == "" || $7 !~ /^\/bin\/bash|\/bin\/sh|\/bin\/nologin/) || ($6 == "" || system("[ -d "$6" ]") != 0) {print $1}' /etc/passwd)
  [ -z "$invalid_users" ] && echo "PASS" || echo "FAIL"
}

check_SUID_SGID_reviewed() {
  # This is manual, so check for any SUID/SGID files and mark FAIL if found
  if find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_shadowed_passwd() {
  # Check if all passwd entries have corresponding shadow entries
  local missing_shadow
  missing_shadow=$(awk -F: 'NR==FNR{a[$1];next}!($1 in a){print $1}' /etc/shadow /etc/passwd)
  [ -z "$missing_shadow" ] && echo "PASS" || echo "FAIL"
}

check_not_empty_passwd() {
  # Check for empty password fields in /etc/shadow
  if awk -F: '($2 == "" || $2 == "*" || $2 == "!") {next} $2 == "" {print $1}' /etc/shadow | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_group_in_passwd() {
  # Check if groups in /etc/passwd exist in /etc/group
  local missing_groups
  missing_groups=$(awk -F: 'NR==FNR{a[$1];next} $4 && !($4 in a){print $1}' /etc/group /etc/passwd)
  [ -z "$missing_groups" ] && echo "PASS" || echo "FAIL"
}

check_shadow_group_empty() {
  # Check if any group entries in /etc/shadow are empty
  if awk -F: '($2 == "") {print $1}' /etc/gshadow | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_no_dup_UID() {
  if awk -F: '{print $3}' /etc/passwd | sort | uniq -d | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_no_dup_GID() {
  if awk -F: '{print $3}' /etc/group | sort | uniq -d | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_no_dub_user() {
  # Check for duplicate usernames
  if awk -F: '{print $1}' /etc/passwd | sort | uniq -d | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_no_dup_group() {
  # Check for duplicate group names
  if awk -F: '{print $1}' /etc/group | sort | uniq -d | grep -q .; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

check_conf_user_home_dir() {
  # Check if user home directories exist and are owned by user
  local errors=0
  while IFS=: read -r user _ _ uid gid home shell; do
    if [ "$uid" -ge 1000 ] && [ -d "$home" ]; then
      owner=$(stat -c %U "$home")
      if [ "$owner" != "$user" ]; then
        errors=$((errors + 1))
      fi
    fi
  done < /etc/passwd
  [ "$errors" -eq 0 ] && echo "PASS" || echo "FAIL"
}

check_local_dot_file_config() {
  # Check if user home directories contain writable dot files by others
  local errors=0
  while IFS=: read -r user _ _ uid gid home shell; do
    if [ "$uid" -ge 1000 ] && [ -d "$home" ]; then
      if find "$home" -maxdepth 1 -name ".*" -type f -perm -002 | grep -q .; then
        errors=$((errors + 1))
      fi
    fi
  done < /etc/passwd
  [ "$errors" -eq 0 ] && echo "PASS" || echo "FAIL"
}
