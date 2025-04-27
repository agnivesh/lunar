#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_virtual_memory
#
# Refer to Section(s) 1.6.3 Page(s) 46    CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 1.6.3 Page(s) 51-2  CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 1.6.3 Page(s) 48-9  CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 4.3   Page(s) 37    CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 1.5.3 Page(s) 57    CIS Amazon Linux Benchmark v2.0.0
# Refer to Section(s) 1.5.1 Page(s) 166-9 CIS Ubuntu 24.04 Benchmark v1.0.0
#.

audit_virtual_memory () {
  if [ "${os_name}" = "Linux" ]; then
    verbose_message "Randomised Virtual Memory Region Placement" "check"
    if [ "${os_vendor}" = "CentOS" ] || [ "${os_vendor}" = "Red" ]; then
      if [ "${os_version}" -gt 5 ]; then
        check_file_value "is" "/etc/sysctl.conf" "kernel.randomize_va_space" "eq" "2" "hash"
      fi
    fi
  fi
}
