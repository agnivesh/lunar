#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_rhosts_files
#
# Check rhosts files
#
# Refer to Section(s) 1.5.2 Page(s) 102-3 CIS AIX Benchmark v1.1.0
#.

audit_rhosts_files () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "AIX" ] || [ "$os_name" = "Linux" ]; then
    verbose_message "Rhosts Files" "check"
    for check_file in /.rhosts /.shosts /root/.rhosts /root/.shosts /etc/hosts.equiv; do
      check_file_exists "$check_file" "no"
    done
  fi
}
