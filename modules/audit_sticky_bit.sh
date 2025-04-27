#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_sticky_bit
#
# Check sticky bitss set of files
#
# Refer to Section(s) 1.17   Page(s) 26    CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 1.1.21 Page(s) 46    CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 1.1.17 Page(s) 28    CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 1.1.17 Page(s) 27    CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 2.17   Page(s) 26    CIS SLES 11 Benchmark v1.2.0
# Refer to Section(s) 6.3    Page(s) 21-22 CIS FreeBSD Benchmark v1.0.5
# Refer to Section(s) 5.3    Page(s) 77-8  CIS Solaris 10 Benchmark v5.1.0
# Refer to Section(s) 1.1.18 Page(s) 42    CIS Amazon Linux Benchmark v2.0.0
#.

audit_sticky_bit () {
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "FreeBSD" ]; then
    if [ "${do_fs}" = 1 ]; then
      verbose_message "World Writable Directories and Sticky Bits" "check"
      if [ "${os_version}" = "10" ]; then
        log_file="${work_dir}/sticky_bits"
        file_list=$( find / \( -fstype nfs -o -fstype cachefs \
          -o -fstype autofs -o -fstype ctfs \
          -o -fstype mntfs -o -fstype objfs \
          -o -fstype proc \) -prune -o -type d \
          \( -perm -0002 -a -perm -1000 \) -print )
        for check_dir in ${file_list}; do
          if [ "${audit_mode}" = 1 ]; then
            
            increment_insecure "Sticky bit not set on \"${check_dir}\""
            verbose_message    "chmod +t ${check_dir}" "fix"
          fi
          if [ "${audit_mode}" = 0 ]; then
            verbose_message "Sticky bit on \"${check_dir}\"" "set"
            chmod +t "${check_dir}"
            echo "${check_dir}" >> "${log_file}"
          fi
        done
        if [ "${audit_mode}" = 2 ]; then
          restore_file="${restore_dir}/sticky_bits"
          if [ -f "${restore_file}" ]; then
            check_dirs=$( cat "${restore_file}" )
            for check_dir in ${check_dirs}; do
              if [ -d "${check_dir}" ]; then
                verbose_message "Removing sticky bit from \"${check_dir}\"" "restore"
                chmod -t "${check_dir}"
              fi
            done
          fi
        fi
      fi
    fi
  fi
}
