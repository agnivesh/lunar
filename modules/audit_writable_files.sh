#!/bin/sh

# shellcheck disable=SC1083
# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_writable_files
#
# Refer to Section(s) 9.1.10   Page(s) 159-160 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 9.1.10   Page(s) 183-4   CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 9.1.10   Page(s) 162-3   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 6.1.10   Page(s) 269     CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 12.8     Page(s) 150-1   CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 6.1.10   Page(s) 247     CIS Amazon Linux Benchmark v1.0.0
# Refer to Section(s) 6.4      Page(s) 22      CIS FreeBSD Benchmark v1.0.5
# Refer to Section(s) 2.16.3   Page(s) 233-4   CIS AIX Benchmark v1.1.0
# Refer to Section(s) 5.1,9.22 Page(s) 45,88   CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 9.22     Page(s) 134     CIS Solaris 10 Benchmark v1.1.0
# Refer to Section(s) 6.1.10   Page(s) 261     CIS Ubuntu 16.04 Benchmark v1.0.0
# Refer to Section(s) 7.1.11   Page(s) 954-7   CIS Ubuntu 24.04 Benchmark v1.0.0
# Refer to Section(s) 5.1.3-4  Page(s) 110-1   CIS Apple OS X 10.12 Benchmark v1.0.0
# Refer to Section(s) 5.1.7    Page(s) 311-4   CIS Apple macOS 14 Sonoma Benchmark v1.0.0
#.

audit_writable_files () {
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "FreeBSD" ] || [ "${os_name}" = "AIX" ]; then
    if [ "${do_fs}" = 1 ]; then
      verbose_message "World Writable Files" "check"
      log_file="worldwritablefiles.log"
      if [ "${audit_mode}" = 0 ]; then
        log_file="${work_dir}/${log_file}"
      fi
      if [ "${audit_mode}" != 2 ]; then
        if [ "${os_name}" = "Linux" ]; then
          file_systems=$( df --local -P | awk {'if (NR!=1) print $6'} 2> /dev/null )
          for file_system in ${file_system}s; do
            check_files=$( find "${file_system}" -xdev -type f -perm -0002 2> /dev/null )
            for check_file in ${check_file}s; do
              if [ "${ansible}" = 1 ]; then
                echo ""
                echo "- name: Checking write permissions for ${check_file}"
                echo "  file:"
                echo "    path: ${check_file}"
                echo "    mode: o-w"
                echo ""
              fi
              if [ "${audit_mode}" = 1 ]; then
                increment_insecure "File ${check_file} is world writable"
                verbose_message    "chmod o-w ${check_file}" "fix"
              fi
              if [ "${audit_mode}" = 0 ]; then
                update_log_file "${log_file}" "${check_file}"
                lockdown_message="File \"${check_file}\" to be non world writable"
                lockdown_command="chmod o-w ${check_file}"
                execute_lockdown "${lockdown_command}" "${lockdown_message}" "sudo"
              fi
            done
          done
        else
          if [ "${os_name}" = "SunOS" ]; then
            find_command="find / \( -fstype nfs -o -fstype cachefs \
            -o -fstype autofs -o -fstype ctfs -o -fstype mntfs \
            -o -fstype objfs -o -fstype proc \) -prune \
            -o -type f -perm -0002 -print"
          fi
          if [ "${os_name}" = "AIX" ]; then
            find_command="find / \( -fstype jfs -o -fstype jfs2 \) \
            \( -type d -o -type f \) -perm -o+w -ls"
          fi
          if [ "${os_name}" = "FreeBSD" ]; then
            find_command="find / \( -fstype ufs -type file -perm -0002 \
            -a ! -perm -1000 \) -print"
          fi
          for check_file in $( ${find_command} ); do
            if [ "${ansible}" = 1 ]; then
              echo ""
              echo "- name: Checking write permissions for ${check_file}"
              echo "  file:"
              echo "    path: ${check_file}"
              echo "    mode: o-w"
              echo ""
            fi
            if [ "${audit_mode}" = 1 ]; then
              increment_insecure "File ${check_file} is world writable"
              verbose_message    "chmod o-w ${check_file}" "fix"
            fi
            if [ "${audit_mode}" = 0 ]; then
              update_log_file "${log_file}" "${check_file}"
              lockdown_message="File \"${check_file}\" to be non world writable"
              lockdown_command="chmod o-w ${check_file}"
              execute_lockdown "${lockdown_command}" "${lockdown_message}" "sudo"
            fi
          done
        fi
      fi
      if [ "${audit_mode}" = 2 ]; then
        restore_file="${restore_dir}/${log_file}"
        if [ -f "${restore_file}" ]; then
          check_files=$( cat "${restore_file}" )
          for check_file in ${check_file}s; do
            if [ -f "${check_file}" ]; then
              restore_message="File \"${check_file}\" to previous permissions"
              restore_command="chmod o+w ${check_file}"
              execute_restore "${restore_command}" "${restore_message}" "sudo"
            fi
          done
        fi
      fi
    fi
  fi
}
