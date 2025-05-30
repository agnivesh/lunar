#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2009
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_unconfined_daemons
#
# Check for unconfined daemons
#
# Refer to Section(s) 1.4.6   Page(s) 40   CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 1.4.6   Page(s) 45-6 CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 1.4.6   Page(s) 43   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 1.6.1.4 Page(s) 68   CIS Ubuntu 16.04 Benchmark v1.0.0
#.

audit_unconfined_daemons () {
  print_function "audit_unconfined_daemons"
  if [ "${os_name}" = "Linux" ]; then
    verbose_message "Unconfined Daemons" "check"
    daemon_check=$( ps -eZ 2> /dev/null | grep "initrc" | grep -Evw "tr|ps|egrep|bash|awk" | tr ':' ' ' | awk '{ print $NF }' )
    if [ -z "${daemon_check}" ]; then
      if [ "${audit_mode}" = 1 ]; then
        increment_insecure "Unconfined daemons \"${daemon_check}\""
      fi
    else
      if [ "${audit_mode}" = 1 ]; then
        increment_secure   "No unconfined daemons"
      fi
    fi
  fi
}
