#!/bin/bash
# Section 1: Initial Setup
# This script is going to be all the functions that are needed to check benchmark 1

# Check if kernel modules are not available
check_kernel_module_not_available() {
  local module_name="$1"
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

# Check if a mount point is a separate partition
check_separate_partition() {
    local mount_point="$1"

    if [[ ! -d "$mount_point" ]]; then
        echo -n "FAIL"
        return
    fi

    # Get the device for the mount point
    local device
    device=$(findmnt -n -o SOURCE --target "$mount_point")
    # Get the device for root
    local root_device
    root_device=$(findmnt -n -o SOURCE --target /)

    if [[ -z "$device" ]]; then
        echo -n "FAIL"
        return
    fi

    if [[ "$device" == "$root_device" ]]; then
        echo -n "FAIL"
    else
        echo -n "PASS"
    fi
}

# Checks if GPG keys are present in the APT trusted keys directory
gpg_keys() {
    if find /etc/apt/trusted.gpg.d -type f -name "*.gpg" 2>/dev/null | grep -q .; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Verifies that APT repositories are configured correctly by checking if apt update runs without errors
repo_conf() {
    if sudo apt update >/dev/null 2>&1; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Checks if security updates can be applied using apt update and apt upgrade
sec_updates() {
    if sudo apt update >/dev/null 2>&1 && sudo apt upgrade -y >/dev/null 2>&1; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Checks if apparmor is installed and its utils are available
apparmor_enabled() {
    installed=$(dpkg-query -s apparmor 2>/dev/null)
    utils_installed=$(dpkg-query -s apparmor-utils 2>/dev/null)
    if [[ "$installed" == *"install ok installed"* ]] && [[ "$utils_installed" == *"install ok installed"* ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Checks if apparmor is enabled on boot
boot_armor() {
    app=$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "apparmor=1")
    sec_armor=$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "security=apparmor")
    if [[ app == "" ]] && [[ sec_armor == "" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensures that AppArmor Profiles are in enforced or complain mode
apparmor_profiles() {
    profile_kill=$(apparmor_status | grep profiles | grep "kill mode" | awk '{print $1}')
    profile_enforce=$(apparmor_status | grep profiles | grep "enforce mode" | awk '{print $1}')
    processes_kill=$(apparmor_status | grep processes | grep "kill mode" | awk '{print $1}')
    processes_enforce=$(apparmor_status | grep processes | grep "enforce mode" | awk '{print $1}')
    if [[ -z "$profile_kill" || "$profile_kill" == "0" ]] && \
       [[ -z "$profile_enforce" || "$profile_enforce" == "0" ]] && \
       [[ -z "$processes_kill" || "$processes_kill" == "0" ]] && \
       [[ -z "$processes_enforce" || "$processes_enforce" == "0" ]]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensures that AppArmor Profiles are in enforcing
apparmor_profiles_enforce() {
    profile_complain=$(apparmor_status | grep profiles | grep "complain mode" | awk '{print $1}')
    profile_kill=$(apparmor_status | grep profiles | grep "kill mode" | awk '{print $1}')
    profile_unconfined=$(apparmor_status | grep profiles | grep "unconfined mode" | awk '{print $1}')
    if { [[ -z "$profile_complain" || "$profile_complain" == "0" ]] && \
         [[ -z "$profile_kill" || "$profile_kill" == "0" ]] && \
         [[ -z "$profile_unconfined" || "$profile_unconfined" == "0" ]]; }; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Function to check the password of the boot loader
boot_password() {
  user=$(grep "^set superusers" /boot/grub/grub.cfg)
  password=$(awk -F. '/^\s*password/ {print $1"."$2"."$3}' /boot/grub/grub.cfg)
  if [[ -z "$user" ]] || [[ -z "$password" ]]; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

# function to check the config of the boot loader
boot_config() {
  conf=$(stat -Lc 'Access: (%#a/%A) /boot/grub/grub.cfg Uid: (%u/%U) Gid: (%g/%G)' /boot/grub/grub.cfg 2>/dev/null)
  if [[ "$conf" != "Access: (0644/-rw-r--r--) /boot/grub/grub.cfg Uid: (0/root) Gid: (0/root) " ]]; then
    echo "FAIL"
  else
    echo "PASS"
  fi
}

# Function to check if Address Space Layout Randomization (ASLR) is enabled
audit_kernel_param() {
    local l_kpname="$1"
    local l_kpvalue="$2"
    local l_output2=""
    local l_ufwscf
    l_ufwscf="$([ -f /etc/default/ufw ] && awk -F= '/^\s*IPT_SYSCTL=/ {print $2}' /etc/default/ufw)"

    kernel_parameter_chk() {
        local l_krp
        l_krp="$(sysctl "$l_kpname" | awk -F= '{print $2}' | xargs)"
        if [ "$l_krp" != "$l_kpvalue" ]; then
            l_output2=1
        fi
        unset A_out; declare -A A_out
        while read -r l_out; do
            if [ -n "$l_out" ]; then
                if [[ $l_out =~ ^\s*# ]]; then
                    l_file="${l_out//# /}"
                else
                    l_kpar="$(awk -F= '{print $1}' <<< "$l_out" | xargs)"
                    [ "$l_kpar" = "$l_kpname" ] && A_out+=(["$l_kpar"]="$l_file")
                fi
            fi
        done < <(/usr/lib/systemd/systemd-sysctl --cat-config | grep -Po '^\h*([^#\n\r]+|#\h*\/[^#\n\r\h]+\.conf\b)')
        if [ -n "$l_ufwscf" ]; then
            l_kpar="$(grep -Po "^\h*$l_kpname\b" "$l_ufwscf" | xargs)"
            l_kpar="${l_kpar//\//.}"
            [ "$l_kpar" = "$l_kpname" ] && A_out+=(["$l_kpar"]="$l_ufwscf")
        fi
        if (( ${#A_out[@]} > 0 )); then
            while IFS="=" read -r l_fkpname l_fkpvalue; do
                l_fkpname="${l_fkpname// /}"; l_fkpvalue="${l_fkpvalue// /}"
                if [ "$l_fkpvalue" != "$l_kpvalue" ]; then
                    l_output2=1
                fi
            done < <(grep -Po -- "^\h*$l_kpname\h*=\h*\H+" "${A_out[@]}")
        else
            l_output2=1
        fi
    }

    if ! grep -Pqs '^\h*0\b' /sys/module/ipv6/parameters/disable && grep -q '^net.ipv6.' <<< "$l_kpname"; then
        echo "PASS"
        return
    else
        kernel_parameter_chk
    fi

    if [ -z "$l_output2" ]; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Function to check if ptrace scope is set to 1
check_prelink_not_installed() {
    if  ! command -v prelink >/dev/null 2>&1; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Function to check if automatic error reporting is disabled
check_auto_error_reporting_disabled() {
    if [ -f /etc/default/apport ]; then
        if grep -q '^enabled=0' /etc/default/apport; then
            echo "PASS"
        else
            echo "FAIL"
        fi
    fi
}

# Checks for specific banner/message contents in a file
check_command() {
  local filecheck="$1"
  local os_id
  os_id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed 's/"//g')
  local command
  command=$(grep -E -i "(\\\v|\\\r|\\\m|\\\s|$os_id)" "$filecheck" 2>/dev/null)
  if [ -z "$command" ]; then
    echo "PASS"
  else
    echo "FAIL"
  fi
}

# Checks the access permissions of a file
check_access() {
    local access_check="$1"
    if [ -e "$access_check" ]; then
        local command
        command=$(stat -Lc 'Access: (%#a/%A) Uid: ( %u/ %U) Gid: ( %g/%G)' "$access_check" 2>/dev/null)
        if [ -z "$command" ] || [ "$command" == "Access: (0644/-rw-r--r--) Uid: ( 0/ root) Gid: ( 0/ root)" ]; then
            echo "PASS"
        else
            echo "FAIL"
        fi
    else
        echo "FAIL"
    fi
}

# Ensure GDM is removed
gdm_removed() {
    if ! dpkg -l | grep -qw gdm3; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM login banner is configured
gdm_login_banner_configured() {
    if grep -q 'banner-message-enable=true' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM disable-user-list option is enabled
gdm_disable_user_list_enabled() {
    if grep -q 'disable-user-list=true' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM screen locks when the user is idle
gdm_screen_lock_idle() {
    if grep -q 'idle-delay' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM screen locks cannot be overridden
gdm_screen_lock_not_overridden() {
    if grep -q 'lock-enabled=true' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM automatic mounting of removable media is disabled
gdm_auto_mount_disabled() {
    if grep -q 'automount=false' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM disabling automatic mounting of removable media is not overridden
gdm_auto_mount_not_overridden() {
    if grep -q 'automount-open=false' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM autorun-never is enabled
gdm_autorun_never_enabled() {
    if grep -q 'autorun-never=true' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure GDM autorun-never is not overridden
gdm_autorun_never_not_overridden() {
    if ! grep -q 'autorun-never=false' /etc/gdm3/greeter.dconf-defaults 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Ensure XDCMP is not enabled
gdm_xdmcp_not_enabled() {
    if ! grep -q 'Enable=true' /etc/gdm3/custom.conf 2>/dev/null; then
        echo "PASS"
    else
        echo "FAIL"
    fi
}

# Add more functions as needed for other checks

# Check if a mount option is present or absent on a mount point
check_mount_option() {
    local mount_point="$1"
    local mount_option="$2"
    local expected_state="$3"
    local status_val="FAIL"

    if ! findmnt -M "$mount_point" &>/dev/null; then
        echo -n "FAIL"
        return
    fi

    local options
    options=$(findmnt -n -o OPTIONS --target "$mount_point")

    if [[ "$expected_state" == "present" ]]; then
        if [[ "$options" == *"$mount_option"* ]]; then
            status_val="PASS"
        else
            status_val="FAIL"
        fi
    elif [[ "$expected_state" == "absent" ]]; then
        if [[ "$options" == *"$mount_option"* ]]; then
            status_val="FAIL"
        else
            status_val="PASS"
        fi
    else
        status_val="FAIL"
    fi

    echo -n "$status_val"
}

# Kernel module check function
get_kernel_module_name() {
  case "$1" in
    1.1.1.1) echo "cramfs" ;;
    1.1.1.2) echo "freevxfs" ;;
    1.1.1.3) echo "hfs" ;;
    1.1.1.4) echo "hfsplus" ;;
    1.1.1.5) echo "jffs2" ;;
    1.1.1.6) echo "squashfs" ;;
    1.1.1.7) echo "udf" ;;
    1.1.1.8) echo "usb-storage" ;;
    *) echo "" ;;
  esac
}

# Partition check function
get_partition_mount_point() {
  case "$1" in
    1.1.2.1.1) echo "/tmp" ;;
    1.1.2.2.1) echo "/dev/shm" ;;
    1.1.2.3.1) echo "/home" ;;
    1.1.2.4.1) echo "/var" ;;
    1.1.2.5.1) echo "/var/tmp" ;;
    1.1.2.6.1) echo "/var/log" ;;
    1.1.2.7.1) echo "/var/log/audit" ;;
    *) echo "" ;;
  esac
}

# Mount option check function
get_mount_option_info() {
  case "$1" in
    1.1.2.1.2) echo "/tmp nodev present" ;;
    1.1.2.1.3) echo "/tmp nosuid present" ;;
    1.1.2.1.4) echo "/tmp noexec present" ;;
    1.1.2.2.2) echo "/dev/shm nodev present" ;;
    1.1.2.2.3) echo "/dev/shm nosuid present" ;;
    1.1.2.2.4) echo "/dev/shm noexec present" ;;
    1.1.2.3.2) echo "/home nodev present" ;;
    1.1.2.3.3) echo "/home nosuid present" ;;
    1.1.2.4.2) echo "/var nodev present" ;;
    1.1.2.4.3) echo "/var nosuid present" ;;
    1.1.2.5.2) echo "/var/tmp nodev present" ;;
    1.1.2.5.3) echo "/var/tmp nosuid present" ;;
    1.1.2.5.4) echo "/var/tmp noexec present" ;;
    1.1.2.6.2) echo "/var/log nodev present" ;;
    1.1.2.6.3) echo "/var/log nosuid present" ;;
    1.1.2.6.4) echo "/var/log noexec present" ;;
    1.1.2.7.2) echo "/var/log/audit nodev present" ;;
    1.1.2.7.3) echo "/var/log/audit nosuid present" ;;
    1.1.2.7.4) echo "/var/log/audit noexec present" ;;
    *) echo "" ;;
  esac
}

# Dispatcher
run_check_by_type_and_id() {
  local check_type="$1"
  local id="$2"
  case "$check_type" in
    kernel_module)
      local module_name
      module_name=$(get_kernel_module_name "$id")
      check_kernel_module_not_available "$module_name"
      ;;
    partition)
      local mount_point
      mount_point=$(get_partition_mount_point "$id")
      check_separate_partition "$mount_point"
      ;;
    mount_option)
      local info mount_point option state
      info=$(get_mount_option_info "$id")
      read -r mount_point option state <<< "$info"
      check_mount_option "$mount_point" "$option" "$state"
      ;;
    gpg_keys)
      gpg_keys
      ;;
    repo_conf)
      repo_conf
      ;;
    sec_updates)
      sec_updates
      ;;
    apparmor_enabled)
      apparmor_enabled
      ;;
    boot_armor)
      boot_armor
      ;;
    apparmor_profiles)
      apparmor_profiles
      ;;
    apparmor_profiles_enforce)
      apparmor_profiles_enforce
      ;;
    boot_password)
      boot_password
      ;;
    boot_config)
      boot_config
      ;;
    aslr_enabled)
      audit_kernel_param "kernel.randomize_va_space" "2"
      ;;
    ptrace_score)
      audit_kernel_param "kernel.yama.ptrace_scope" "1"
      ;;
    core_dumps_restricted)
      audit_kernel_param "fs.suid_dumpable" "0"
      ;;
    prelink_not_installed)
      check_prelink_not_installed
      ;;
    auto_error_reporting)
      check_auto_error_reporting_disabled
      ;;
    day_message)
      check_command "/etc/motd"
      ;;
    banner_message)
      check_command "/etc/issue"
      ;;
    banner_message_login)
      check_command "/etc/issue.net"
      ;;
    access_motd)
      check_access "/etc/motd"
      ;;
    access_issue)
      check_access "/etc/issue"
      ;;
    access_issue_net)
      check_access "/etc/issue.net"
      ;;
    gdm_removed)
      gdm_removed
      ;;
    login_banner)
      gdm_login_banner_configured
      ;;
    disable_user_list_enabled)
      gdm_disable_user_list_enabled
      ;;
    screen_lock_idle)
      gdm_screen_lock_idle
      ;;
    screen_lock_not_overridden)
      gdm_screen_lock_not_overridden
      ;;
    auto_mount_disabled)
      gdm_auto_mount_disabled
      ;;
    auto_mount_not_overridden)
      gdm_auto_mount_not_overridden
      ;;
    autorun_never_enabled)
      gdm_autorun_never_enabled
      ;;
    autorun_not_overridden)
      gdm_autorun_never_not_overridden
      ;;
    xdmcp_not_enabled)
      gdm_xdmcp_not_enabled
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}
