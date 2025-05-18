#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_home_perms
#
# Check home permissions
#
# Refer to Section(s) 5.4   Page(s) 51-52 CIS Apple OS X 10.8 Benchmark v1.0.0
# Refer to Section(s) 6.6   Page(s) 22    CIS FreeBSD Benchmark v1.0.5
# Refer to Section(s) 13.7  Page(s) 158-9 CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 9.7   Page(s) 77    CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 9.7   Page(s) 121   CIS Solaris 10 Benchmark v1.1.0
# Refer to Section(s) 6.2.8 Page(s) 282   CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 6.2.8 Page(s) 260   CIS Amazon Linux Benchmark v2.0.0
# Refer to Section(s) 6.2.8 Page(s) 274   CIS Ubuntu 16.04 Benchmark v1.0.0
# Refer to Section(s) 5.1.1 Page(s) 107-8 CIS Apple OS X 10.12 Benchmark v1.0.0
# Refer to Section(s) 5.1.1 Page(s) 298-9 CIS Apple macOS 14 Sonoma Benchmark v1.0.0
#.

audit_home_perms () {
  print_module "audit_home_perms"
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "Darwin" ] || [ "${os_name}" = "FreeBSD" ]; then
    if [ "${do_fs}" = "1" ]; then
      verbose_message "Home Directory Permissions" "check"
      dir_list=$( cut -f6 -d":" < /etc/passwd | grep -v "^/$" | grep "home" )
      for home_dir in ${dir_list}; do
        if [ -d "${home_dir}" ]; then
          check_file_perms "${home_dir}" "0700"
        fi
      done
      if [ "${os_name}" = "Darwin" ]; then
        dir_list=$( find /Users -maxdepth 1 | grep -vE "localized|Shared" | cut -f3 -d/ )
        for home_dir in ${dir_list}; do
          check_file_perms "/Users/${home_dir}" "0700"
        done
      fi
    fi
  fi
}
