check_file() {
    local file="$1"
    local pattern="$2"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    if [[ -z "$pattern" ]]; then
        return 0
    fi

    if grep -q "$pattern" "$file"; then
        return 0
    else
        return 1
    fi
}

check_perm() {
    local expected_owner_group="$1"
    local max_mode="$2"
    local file="$3"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    # Get actual mode and ownership
    local perms
    perms=$(stat -c "%a %U:%G" "$file")
    local mode owner_group
    read -r mode owner_group <<< "$perms"

    # Check owner:group
    if [[ "$owner_group" != "$expected_owner_group" ]]; then
        return 1
    fi

    # Compare modes numerically
    if (( 10#$mode > 10#$max_mode )); then
        return 1
    fi

    return 0
}

check_sshd_config() {
  local file='/etc/ssh/sshd_config'

  check_file $file || return 1
  check_perm "root:root" "600" "$file" || return 1

  echo "PASS"
  return 0
}

check_ssh_priv() {
  local file='/etc/ssh/ssh_host_*_key'

  if ! check_file $file; then
    echo "FAIL"
    return 1
  fi

  if ! check_perm "root:root" "600" "$file"; then
    echo "FAIL"
    return 1
  fi

  echo "PASS"
  return 0
}

check_SSH_pub() {
  local file='/etc/ssh/ssh_host_*_key.pub'

  if ! check_file $file; then
    echo "FAIL"
    return 1
  fi

  if ! check_perm "root:root" "644" "$file"; then  # Public keys usually have 644 perms
    echo "FAIL"
    return 1
  fi

  echo "PASS"
  return 0
}

check_ssh_access() {
    local file="/etc/ssh/sshd_config"
    local overall=0

    local patterns=(
        "^PermitRootLogin no"
        "^AllowUsers"
        "^AllowGroups"
        "^DenyUsers"
        "^DenyGroups"
    )

    for pat in "${patterns[@]}"; do
        check_file "$file" "$pat"
        if [[ $? -ne 0 ]]; then
            overall=1
        fi
    done

    if [[ $overall -eq 0 ]]; then echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

check_ssh_banner() {
    local config="/etc/ssh/sshd_config"
    local banner_file

    # Check if Banner directive exists
    if ! check_file "$config" '^\s*Banner\s+'; then
        echo "FAIL"
        return 1
    fi

    # Extract banner file path (assuming only one Banner directive)
    banner_file=$(grep -Ei '^\s*Banner\s+' "$config" | awk '{print $2}' | head -n1)

    # Check if banner file exists
    if ! check_file "$banner_file"; then
        echo "FAIL"
        return 1
    fi

    # Check if banner file is not empty
    if [[ ! -s "$banner_file" ]]; then
        echo "FAIL"
        return 1
    fi

    echo "PASS"
    return 0
}

check_ssh_cipher() {
    local config="/etc/ssh/sshd_config"
    local pattern="^\s*Ciphers\s+"

    # Check that the Ciphers directive exists
    if ! check_file "$config" "$pattern"; then
        echo "FAIL"
        return 1
    fi

    # Optionally: validate the ciphers are strong
    local ciphers_line
    ciphers_line=$(grep -Ei "$pattern" "$config" | awk '{$1=""; print $0}' | xargs)

    # List of acceptable ciphers (edit to match your policy)
    local allowed="aes256-gcm@openssh.com aes256-ctr aes192-ctr aes128-ctr"

    for cipher in $(echo "$ciphers_line" | tr ',' ' '); do
        if ! grep -qw "$cipher" <<< "$allowed"; then
            echo "FAIL"
            return 1
        fi
    done

    echo "PASS"
    return 0
}

check_ssh_client_alive() {
    local config="/etc/ssh/sshd_config"
    local interval count
    local fail=0

    interval=$(grep -Ei '^\s*ClientAliveInterval' "$config" | awk '{print $2}' | head -n1)
    count=$(grep -Ei '^\s*ClientAliveCountMax' "$config" | awk '{print $2}' | head -n1)

    [[ -z "$interval" || "$interval" -gt 300 ]] && fail=1
    [[ -z "$count" || "$count" -gt 3 ]] && fail=1

    if [[ $fail -eq 0 ]]; then
        echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

check_ssh_forwarding() {
    local config="/etc/ssh/sshd_config"
    local pattern='^\s*DisableForwarding\s+yes'

    if check_file "$config" "$pattern"; then
        echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

