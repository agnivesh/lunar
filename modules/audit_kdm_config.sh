#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_kdm_config
#
# Turn off kdm config
#.

audit_kdm_config () {
  print_function "audit_kdm_config"
  if [ "${os_name}" = "SunOS" ]; then
    if [ "${os_version}" = "10" ] || [ "${os_version}" = "11" ]; then
      verbose_message     "Graphics Configuration" "check"
      check_sunos_service "svc:/platform/i86pc/kdmconfig:default" "disabled"
    fi
  fi
}
