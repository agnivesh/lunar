#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_bpcd
#
# Turn off bpcd
#.

audit_bpcd () {
  print_function "audit_bpcd"
  if [ "${os_name}" = "SunOS" ]; then
    if [ "${os_version}" = "10" ] || [ "${os_version}" = "11" ]; then
      verbose_message     "BPC Daemon" "check"
      check_sunos_service "svc:/network/bpcd/tcp:default" "disabled"
    fi
  fi
}
