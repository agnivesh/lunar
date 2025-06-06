#!/bin/sh

# shellcheck disable=SC1083
# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_unowned_files
#
# Find unowned files
#
# Refer to Section(s) 9.1.11-2 Page(s) 160-1  CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 9.1.11-2 Page(s) 184-6  CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 9.1.11-2 Page(s) 163-4  CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 6.1.11-2 Page(s) 270-1  CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 12.9-10  Page(s) 151-2  CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 6.7      Page(s) 23     CIS FreeBSD Benchmark v1.0.5
# Refer to Section(s) 2.16.2   Page(s) 232-3  CIS AIX Benchmark v1.1.0
# Refer to Section(s) 9.24     Page(s) 89-90  CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 9.24     Page(s) 135-6  CIS Solaris 10 Benchmark v1.1.0
# Refer to Section(s) 6.1.11-2 Page(s) 248-9  CIS Amazon Linux Benchmark v1.0.0
# Refer to Section(s) 6.1.11-2 Page(s) 262-3  CIS Ubuntu 16.04 Benchmark v1.0.0
# Refer to Section(s) 7.1.12   Page(s) 958-60 CIS Ubuntu 16.04 Benchmark v1.0.0
#.

audit_unowned_files () {
  print_function "audit_unowned_files"
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "FreeBSD" ] || [ "${os_name}" = "AIX" ]; then
    verbose_message "Unowned Files and Directories" "check"
    if [ "${my_id}" != "0" ] && [ "${use_sudo}" = "0" ]; then
      verbose_message "Requires sudo to check" "notice"
      return
    fi
    if [ "${audit_mode}" = 1 ]; then
      if [ "${os_name}" = "Linux" ]; then
        file_systems=$( df --local -P | awk {'if (NR!=1) print $6'} 2> /dev/null )
        for file_system in ${file_system}s; do
          check_files=$( find "${file_system}" -xdev -nouser -ls 2> /dev/null )
          for check_file in ${check_file}s; do
            increment_insecure "File ${check_file} is unowned"
          done
        done
      else
        if [ "${os_name}" = "SunOS" ]; then
          find_command="find / \( -fstype nfs -o -fstype cachefs \
          -o -fstype autofs -o -fstype ctfs -o -fstype mntfs \
          -o -fstype objfs -o -fstype proc \) -prune \
          -o \( -nouser -o -nogroup \) -print"
        fi
        if [ "${os_name}" = "AIX" ]; then
          find_command="find / \( -fstype jfs -o -fstype jfs2 \) \
          \( -type d -o -type f \) \( -nouser -o -nogroup \) -ls"
        fi
        check_files=$( eval "${find_command}" )
        for check_file in ${check_file}s; do
          increment_insecure "File \"${check_file}\" is unowned"
        done
      fi
    fi
  fi
}
