#!/bin/bash

# -- SSH related checks --

check_sshd_config() {
    [ -f /etc/ssh/sshd_config ] && echo "PASS" || echo "FAIL"
}

check_ssh_priv() {
    local perm
    perm=$(stat -c %a /etc/ssh/sshd_config)
    [[ "$perm" -le 640 ]] && echo "PASS" || echo "FAIL"
}

check_SSH_pub() {
    # Check if authorized_keys exist for all users with valid perms (simplified)
    local fail=0
    for dir in /home/*; do
        if [ -f "$dir/.ssh/authorized_keys" ]; then
            perm=$(stat -c %a "$dir/.ssh/authorized_keys")
            [ "$perm" -le 600 ] || { fail=1; break; }
        fi
    done
    [ $fail -eq 0 ] && echo "PASS" || echo "FAIL"
}

check_ssh_access() {
    # Check if SSH access restricted (AllowUsers or AllowGroups)
    grep -qE '^\s*AllowUsers|^\s*AllowGroups' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_banner() {
    # Check if Banner is set and file exists
    local banner_file
    banner_file=$(grep -E '^\s*Banner' /etc/ssh/sshd_config | awk '{print $2}')
    if [[ -n "$banner_file" && -f "$banner_file" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

check_ssh_cipher() {
    # Check if weak ciphers disabled
    if grep -qE '^\s*Ciphers\s+(.*?)(aes256|chacha20|aes128)' /etc/ssh/sshd_config; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

check_ssh_client_alive() {
    # Check ClientAliveInterval and ClientAliveCountMax
    grep -qE '^\s*ClientAliveInterval\s+[0-9]+' /etc/ssh/sshd_config && \
    grep -qE '^\s*ClientAliveCountMax\s+[0-9]+' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_forwarding() {
    # Check if AllowTcpForwarding is disabled
    grep -qE '^\s*AllowTcpForwarding\s+no' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_GSSAPIA() {
    # Check GSSAPIAuthentication disabled
    grep -qE '^\s*GSSAPIAuthentication\s+no' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_hostbasedauthentication() {
    # Check HostbasedAuthentication disabled
    grep -qE '^\s*HostbasedAuthentication\s+no' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_ignorerhosts() {
    # Check IgnoreRhosts is yes
    grep -qE '^\s*IgnoreRhosts\s+yes' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_algorithms() {
    # Check if strong algorithms set (simplified)
    grep -qE '^\s*KexAlgorithms\s+(curve25519|diffie-hellman-group14-sha1)' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_grace() {
    # Check LoginGraceTime less than 60 seconds
    local grace=$(grep -E '^\s*LoginGraceTime' /etc/ssh/sshd_config | awk '{print $2}')
    [[ "$grace" =~ ^[0-9]+$ && "$grace" -le 60 ]] && echo "PASS" || echo "FAIL"
}

check_ssh_loglevel() {
    # Check LogLevel is INFO or VERBOSE
    local level=$(grep -E '^\s*LogLevel' /etc/ssh/sshd_config | awk '{print $2}')
    [[ "$level" == "INFO" || "$level" == "VERBOSE" ]] && echo "PASS" || echo "FAIL"
}

check_ssh_mac() {
    # Check if MACs are set to strong algorithms
    grep -qE '^\s*MACs\s+(hmac-sha2-256|hmac-sha2-512)' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_maxauthtries() {
    # Check MaxAuthTries less than or equal to 4
    local tries=$(grep -E '^\s*MaxAuthTries' /etc/ssh/sshd_config | awk '{print $2}')
    [[ "$tries" =~ ^[0-9]+$ && "$tries" -le 4 ]] && echo "PASS" || echo "FAIL"
}

check_ssh_maxsession() {
    # Check MaxSessions set (>=1)
    local sessions=$(grep -E '^\s*MaxSessions' /etc/ssh/sshd_config | awk '{print $2}')
    [[ "$sessions" =~ ^[0-9]+$ && "$sessions" -ge 1 ]] && echo "PASS" || echo "FAIL"
}

check_ssh_maxstartups() {
    local maxstartups=$(grep -E '^\s*MaxStartups' /etc/ssh/sshd_config | awk '{print $2}')
    [[ "$maxstartups" =~ ^[0-9]+$ ]] && echo "PASS" || echo "FAIL"
}

check_ssh_permitemptypasswords() {
    grep -qE '^\s*PermitEmptyPasswords\s+no' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_permitrootlogin() {
    grep -qE '^\s*PermitRootLogin\s+no' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_permituserenvironmnent() {
    grep -qE '^\s*PermitUserEnvironment\s+no' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

check_ssh_usepam() {
    grep -qE '^\s*UsePAM\s+yes' /etc/ssh/sshd_config && echo "PASS" || echo "FAIL"
}

# -- sudo checks --

check_sudo_installed() {
    command -v sudo >/dev/null 2>&1 && echo "PASS" || echo "FAIL"
}

check_sudo_pty() {
    grep -qE '^\s*Defaults\s+requiretty' /etc/sudoers && echo "PASS" || echo "FAIL"
}

check_sudo_log() {
    grep -qE '^\s*Defaults\s+logfile=' /etc/sudoers && echo "PASS" || echo "FAIL"
}

check_passwd_privilege() {
    local count=$(awk -F: '$3==0' /etc/passwd | wc -l)
    [[ "$count" -eq 1 ]] && echo "PASS" || echo "FAIL"
}

check_privilege_global() {
    find /etc/sudoers.d /etc/sudoers -perm -2 -type f 2>/dev/null | grep -q '.' && echo "FAIL" || echo "PASS"
}

check_sudo_timeout() {
    grep -qE '^\s*Defaults\s+timestamp_timeout=[0-9]+' /etc/sudoers && echo "PASS" || echo "FAIL"
}

check_su_restricted() {
    grep -qE '^\s*auth\s+required\s+pam_wheel.so' /etc/pam.d/su && echo "PASS" || echo "FAIL"
}

# -- PAM checks --

check_latest_pam() {
    dpkg -l | grep -q '^ii\s*libpam0g' && echo "PASS" || echo "FAIL"
}

check_libpam-module() {
    dpkg -l | grep -q '^ii\s*libpam-modules' && echo "PASS" || echo "FAIL"
}

check_libpam-pwquality() {
    dpkg -l | grep -q '^ii\s*libpam-pwquality' && echo "PASS" || echo "FAIL"
}

check_Pam_unix() {
    grep -q 'pam_unix.so' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_pam_faillock() {
    grep -q 'pam_faillock.so' /etc/pam.d/common-auth && echo "PASS" || echo "FAIL"
}

check_pam_pwquality() {
    grep -q 'pam_pwquality.so' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_pam_pwhistory() {
    grep -q 'pam_pwhistory.so' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

# -- Password Lockout --

check_passwd_lockout() {
    grep -q 'pam_faillock.so' /etc/pam.d/common-auth && echo "PASS" || echo "FAIL"
}

check_passwd_unlock() {
    # Placeholder: check if unlock after failures is configured
    grep -q 'unlock_time' /etc/security/faillock.conf && echo "PASS" || echo "FAIL"
}

check_root_fail_lockout() {
    # Check if root is locked after failed attempts (via faillock or PAM)
    grep -q 'root' /etc/security/faillock.conf && echo "PASS" || echo "FAIL"
}

check_Passwd_char() {
    # Check minimum number of chars (pwquality config)
    grep -q 'minlen' /etc/security/pwquality.conf && echo "PASS" || echo "FAIL"
}

check_min_passwd() {
    grep -q 'minlen' /etc/security/pwquality.conf && echo "PASS" || echo "FAIL"
}

check_passwd_complex() {
    grep -q 'dcredit' /etc/security/pwquality.conf && echo "PASS" || echo "FAIL"
}

check_passwd_conse() {
    # Check password consequences (like reject_user_check, retry, etc.)
    grep -q 'retry' /etc/security/pwquality.conf && echo "PASS" || echo "FAIL"
}

check_passwd_max() {
    grep -q 'maxrepeat' /etc/security/pwquality.conf && echo "PASS" || echo "FAIL"
}

check_passwd_dic() {
    grep -q 'dictcheck' /etc/security/pwquality.conf && echo "PASS" || echo "FAIL"
}

check_passwd_quality() {
    grep -q 'pwquality' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_passwd_quality_root() {
    grep -q 'pam_pwquality.so' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_passwd_hist() {
    grep -q 'remember' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_passwd_hist_root() {
    grep -q 'remember' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_pam_unix_nullok() {
    ! grep -q 'nullok' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_pam_unix() {
    grep -q 'pam_unix.so' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_pam_unix_hashing() {
    # Check hashing algo in pam_unix.so (sha512)
    grep -q 'sha512' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

check_pam_unix_authtok() {
    grep -q 'use_authtok' /etc/pam.d/common-password && echo "PASS" || echo "FAIL"
}

# -- Password expiration and aging --

check_passwd_expiration() {
    chage -l root | grep -q 'Password expires' && echo "PASS" || echo "FAIL"
}

check_min_passwd_age() {
    chage -l root | grep -q 'Minimum' && echo "PASS" || echo "FAIL"
}

check_passwd_expiration_warning_days() {
    chage -l root | grep -q 'Warning' && echo "PASS" || echo "FAIL"
}

check_passwd_hashing_algorithm() {
    if grep -q 'pam_unix.so.*sha512' /etc/pam.d/common-password; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

check_passwd_inactive_lock() {
    local inactive=$(chage -l root | grep 'Inactive' | awk -F: '{print $2}' | tr -d ' ')
    [[ "$inactive" -gt 0 ]] && echo "PASS" || echo "FAIL"
}

check_last_passwd_change() {
    chage -l root | grep -q 'Last password change' && echo "PASS" || echo "FAIL"
}

# -- Root and system account checks --

check_root_UID() {
    awk -F: '($3 == 0) {print $1}' /etc/passwd | grep -q '^root$' && echo "PASS" || echo "FAIL"
}

check_root_GID() {
    awk -F: '($3 == 0) {print $4}' /etc/passwd | grep -q '^0$' && echo "PASS" || echo "FAIL"
}

check_only_GID_root() {
    local count=$(awk -F: '$4 == 0 && $1 != "root" {print $1}' /etc/passwd | wc -l)
    [[ "$count" -eq 0 ]] && echo "PASS" || echo "FAIL"
}

check_root_passwd() {
    passwd -S root | grep -q 'L' && echo "PASS" || echo "FAIL"
}

check_root_integrity() {
    # Check root account integrity (e.g. shell not /bin/false or nologin)
    local shell=$(awk -F: '$1=="root" {print $7}' /etc/passwd)
    [[ "$shell" != "/bin/false" && "$shell" != "/usr/sbin/nologin" ]] && echo "PASS" || echo "FAIL"
}

check_root_umask() {
    local files=(
        "/root/.bashrc"
        "/root/.profile"
        "/root/.bash_profile"
        "/etc/profile"
        "/etc/bash.bashrc"
    )

    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            if grep -q 'umask 027' "$file"; then
                echo "PASS"
                return 0
            fi
        fi
    done

    echo "FAIL"
}

check_system_accounts() {
    # Check if system accounts have no login shells (simplified)
    local fail=0
    while IFS=: read -r user pass uid gid desc home shell; do
        if [[ "$uid" -lt 1000 ]]; then
            [[ "$shell" == "/usr/sbin/nologin" || "$shell" == "/bin/false" ]] || fail=1
        fi
    done < /etc/passwd
    [[ $fail -eq 0 ]] && echo "PASS" || echo "FAIL"
}

check_shell_locked() {
    passwd -S root | grep -q 'L' && echo "PASS" || echo "FAIL"
}

check_nologin() {
    grep -qE 'nologin' /etc/passwd && echo "PASS" || echo "FAIL"
}

# -- Environment and default settings --

check_default_timeout() {
    # Check TMOUT in /etc/profile or /etc/bash.bashrc
    grep -q 'TMOUT' /etc/profile && echo "PASS" || echo "FAIL"
}

check_default_umask() {
    local umask_val=$(umask)
    [[ "$umask_val" == "0022" || "$umask_val" == "0007" ]] && echo "PASS" || echo "FAIL"
}

# To call any check: e.g. check_sshd_config
