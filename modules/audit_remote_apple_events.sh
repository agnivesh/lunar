#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_remote_apple_events
#
# Check Apple remote events
#
# Refer to Section(s) 5.20    Page(s) 68-9  CIS Apple OS X 10.8 Benchmark v1.0.0
# Refer to Section(s) 2.4.2   Page(s) 38    CIS Apple OS X 10.12 Benchmark v1.0.0
# Refer to Section(s) 2.3.3.7 Page(s) 106-7 CIS Apple macOS 14 Sonoma Benchmark v1.0.0
#.

audit_remote_apple_events () {
  print_function "audit_remote_apple_events"
  if [ "${os_name}" = "Darwin" ]; then
    verbose_message "Remote Apple Events" "check"
    if [ "${long_os_version}" -ge 1008 ]; then
      check_osx_systemsetup   "getremoteappleevents" "off"
    else
      check_launchctl_service "eppc"
    fi
  fi
}
