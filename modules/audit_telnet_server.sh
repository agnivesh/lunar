#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_telnet_server
#
# Turn off telner server
#
# Refer to Section(s) 2.1.1 Page(s) 47-48 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 2.1.1 Page(s) 55    CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 2.1.1 Page(s) 50-1  CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 2.1.1 Page(s) 55    CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 5.1.7 Page(s) 44    CIS SLES 11 Benchmark v1.0.0
#.

audit_telnet_server () {
  if [ "${os_name}" = "Linux" ]; then
    if [ "${os_vendor}" = "CentOS" ] || [ "${os_vendor}" = "Red" ] || [ "${os_name}" = "Amazon" ]; then
      verbose_message     "Telnet Server Daemon" "check"
      check_linux_service "telnet.socket"        "off"
      check_linux_package "uninstall"            "telnet-server"
    fi
  fi
}
