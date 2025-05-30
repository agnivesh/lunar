#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_dfstab
#
# Check dfstab
#
# Refer to Section(s) 10.2 Page(s) 138-9 CIS Solaris 10 Benchmark v1.1.0
#.

audit_dfstab () {
  print_function "audit_dfstab"
  if [ "${os_name}" = "SunOS" ]; then
    verbose_message    "Full Path Names in Exports" "check"
    replace_file_value "/etc/dfs/dfstab" "share"    "/usr/bin/share" "start"
  fi
}
