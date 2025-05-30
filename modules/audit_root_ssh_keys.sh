#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_root_ssh_keys
#
# Make sure there are not ssh keys for root
#.

audit_root_ssh_keys () {
  print_function "audit_root_ssh_keys"
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "Darwin" ]; then
    verbose_message "Root SSH keys" "check"
    if [ "${audit_mode}" != 2 ]; then
      root_home=$( grep '^root' /etc/passwd | cut -f6 -d: )
      for check_file in $root_home/.ssh/authorized_keys $root_home/.ssh/authorized_keys2; do
        if [ -f "${check_file}" ]; then
          key_check=$( wc -l "${check_file}" | awk '{print $1}' )
          if [ "${key_check}" -ge 1 ]; then
            if [ "${audit_mode}" = 1 ]; then
              increment_insecure "Keys file \"${check_file}\" ${exists}"
              verbose_message    "mv ${check_file} ${check_file}.disabled" "fix"
            fi
            if [ "${audit_mode}" = 0 ]; then
              backup_file     "${check_file}"
              verbose_message "Removing:  Keys file \"${check_file}\"" "remove"
              if [ -f "${check_file}" ]; then
                rm "${check_file}"
              fi
            fi
          else
            if [ "${audit_mode}" = 1 ]; then
              increment_secure "Keys file \"${check_file}\" does not contain any keys"
            fi
          fi
        else
          if [ "${audit_mode}" = 1 ]; then
            increment_secure "Keys file \"${check_file}\" does not exist"
          fi
        fi
      done
    else
      restore_file "${check_file}" "${restore_dir}"
    fi
  fi
}
