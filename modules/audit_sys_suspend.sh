#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_sys_suspend
#
# Refer to Section(s) 10.4 Page(s) 140 CIS Solaris 10 Benchmark v1.1.0
#.

audit_sys_suspend () {
  print_function "audit_sys_suspend"
  if [ "${os_name}" = "SunOS" ]; then
    verbose_message  "System Suspend" "check"
    check_file_value "is" "/etc/default/sys-suspend" "PERMS" "eq" "-" "hash"
  fi
}
