#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_ufw
#
# Chec UFW is enabled
#
# Refer to Section(s) 3.5.1.1-3 Page(s) 216-20 CIS Ubuntu 22.04 Benchmark v1.0.0
#.

audit_ufw () {
  if [ "$os_name" = "Linux" ] && [ "$os_vendor" = "Ubuntu" ]; then
    verbose_message     "UFW"       "check"
    check_linux_package "install"   "ufw"
    check_linux_package "uninstall" "iptables-persistent"
    check_linux_service "ufw"       "on"
  fi
}