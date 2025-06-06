#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2046
# shellcheck disable=SC2154

# audit_groups_exist
#
# Check groups
#
# Refer to Section(s) 9.2.11 Page(s) 170-1 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 9.2.11 Page(s) 196-7 CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 9.2.11 Page(s) 173-4 CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 6.2.15 Page(s) 282   CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 13.11  Page(s) 161-2 CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 9.11   Page(s) 80    CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 9.11   Page(s) 124-5 CIS Solaris 10 Benchmark v1.1.0
# Refer to Section(s) 6.2.15 Page(s) 269   CIS Amazon Linux Benchmark v2.1.0
# Refer to Section(s) 6.2.15 Page(s) 282   CIS Ubuntu 16.04 Benchmark v1.0.0       
# Refer to Section(s) 7.2.3  Page(s) 970-1 CIS Ubuntu 24.04 Benchmark v1.0.0       
#.

audit_groups_exist () {
  print_function "audit_groups_exist"
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ]; then
    verbose_message "User Groups" "check"
    check_file="/etc/group"
    group_fail=0
    if [ "${audit_mode}" != 2 ]; then
      for group_id in $( getent passwd | cut -f4 -d ":" ); do
        group_exists=$( grep -v "^#" "${check_file}" | cut -f3 -d":" | grep -c "^${group_id}$" | sed "s/ //g" )
        if [ "$group_exists" = 0 ]; then
          group_fail=1
          if [ "${audit_mode}" = 1 ];then
            increment_insecure "Group \"${group_id}\" does not exist in group file \"${check_file}\""
          fi
        fi
      done
      if [ "${group_fail}" != 1 ]; then
        if [ "${audit_mode}" = 1 ];then
          increment_secure "No non existant group issues"
        fi
      fi
    fi
  fi
}
