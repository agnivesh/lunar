#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_cde_ttdb
#
# Check CDE ToolTalk Database Server
#
# Refer to Section(s) 2.1.1 Page(s) 17-8 CIS Solaris 10 v5.1.0
#.

audit_cde_ttdb () {
  print_function "audit_cde_ttdb"
  if [ "${os_name}" = "SunOS" ]; then
    if [ "${os_version}" = "10" ]; then
      verbose_message     "CDE ToolTalk Database Server"        "check"
      check_sunos_service "svc:/network/rpc/cde-ttdbserver:tcp" "disabled"
    fi
  fi
}
