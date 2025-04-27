#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_cde_screen_lock
#
# Check Screen Lock for CDE Users
#
# Refer to Section(s) 6.7 Page(s) 91-2 CIS Solaris 10 Benchmark v5.1.0
#.

audit_cde_screen_lock () {
  if [ "${os_name}" = "SunOS" ]; then
    verbose_message "Screen Lock for CDE Users" "check"
    file_list=$( find /usr/dt/config/*/sys.resources -t file -maxdepth 1 2> /dev/null )
    for cde_file in ${file_list}; do
      dir_name=$( dirname "$cde_file" | sed "s/usr/etc/" )
      if [ ! -d "${dir_name}" ]; then
        mkdir -p "${dir_name}"
      fi
      check_file="${dir_name}/sys.resources"
      check_file_value "is" "${check_file}" "dtsession*saverTimeout" "colon" " 10" "star"
      check_file_value "is" "${check_file}" "dtsession*lockTimeout"  "colon" " 10" "star"
      check_file_perms "${check_file}"      "0444" "root" "sys"
    done
  fi
}
