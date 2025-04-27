#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_suse_firewall
#
# Check SuSE Firewall enabled
#
# Refer to Section(s) 7.7 Page(s) 83-4 SLES 11 Benchmark v1.0.0
#.

audit_suse_firewall () {
  if [ "${os_name}" = "Linux" ]; then
    if [ "${os_vendor}" = "SuSE" ]; then
      verbose_message     "SuSE Firewall" "check"
      check_linux_service "SuSEfirewall2_init"  "on"
      check_linux_service "SuSEfirewall2_setup" "on"
    fi
  fi
}
