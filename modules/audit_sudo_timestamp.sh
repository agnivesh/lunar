#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_sudo_timestanp
#
# Check sudo timestamp
#
# Refer to Section(s) 5.5 Page(s) 346-7 CIS Apple macOS 14 Sonoma Benchmark v1.0.0
#.

audit_sudo_timestamp () {
  if [ "$os_name" = "Darwin" ] || [ "$os_name" = "Linux" ] || [ "$os_name" = "SunOS" ]; then
    verbose_message "Sudo timestamp" "check"
    major_ver=$( sudo --version |head -1 |awk '{print $3}' |cut -f1 -d. )
    minor_ver=$( sudo --version |head -1 |awk '{print $3}' |cut -f2 -d. )
    check_sudo="0"
    if [ $major_ver -gt 1 ]; then
      check_sudo="1"
    else
      if [ $major_ver -eq 1 ] && [ $minor_ver -ge 8 ]; then
        check_sudo="1"
      fi
    fi
    if [ "$check_sudo" = "1" ]; then
      if [ "$os_name" = "Darwin" ] && [ "$os_version" -ge 14 ]; then
        check_file="/etc/sudoers.d/sudoers_timestamp"
      else
        if [ "$os_name" = "Linux" ]; then
          check_file="/etc/sudoers.d/sudoers_timestamp"
        else
          check_file="/etc/sudoers"
        fi
      fi
    fi
    check_file_value "is" "$check_file" "Defaults timestamp_type" "eq" "tty" "hash" "after" "# Defaults specification"
    check_file_perms "$check_file"      "440" "root" "wheel" 
  fi
}
