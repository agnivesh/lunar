#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_internet_sharing
#
# Check Internet Sharing
#
# Refer to Section(s) 2.4.2    Page(s) 17-18   CIS Apple OS X 10.8 Benchmark v1.0.0
# Refer to Section(s) 2.3.3.8  Page(s) 108-10  CIS Apple macOS 14 Sonoma Benchmark v1.0.0
#.

audit_internet_sharing () {
  if [ "${os_name}" = "Darwin" ]; then
    verbose_message         "Internet Sharing" "check"
    check_osx_defaults_dict "/Library/Preferences/SystemConfiguration/com.apple.nat" "NAT" "Enabled" "dict" "0" "int"
    check_launchctl_service "com.apple.InternetSharing" "off"
  fi
}
