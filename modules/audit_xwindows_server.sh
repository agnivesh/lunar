#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_xwindows_server
#
# Refer to Section(s) 3.2     Page(s) 59-60 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 3.3     Page(s) 72-3  CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 3.2     Page(s) 62-3  CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 6.1     Page(s) 52    CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 2.1.20  Page(s) 283-4 CIS Ubuntu 24.04 Benchmark v1.0.0
#.

audit_xwindows_server () {
  print_module "audit_xwindows_server"
  if [ "${os_name}" = "Linux" ]; then
    verbose_message "X Windows Server"
    if [ "${os_vendor}" = "CentOS" ] || [ "${os_vendor}" = "Red" ]; then
      no_rego=$( yum grouplist 2>&1 | grep "not registered" )
      if [ -z "${no_rego}" ]; then
        check_linux_package_with_group "uninstalled" "X Windows Server" "group"
      else
        verbose_message "Warning:   System not registered with a repository"
      fi
    else
      if [ "${os_vendor}" = "Ubuntu" ]; then
        check_linux_package "uninstall" "xserver-common"
      fi
    fi
  fi
}
