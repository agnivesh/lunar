#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2046
# shellcheck disable=SC2154

# audit_pam_authtok
#
# Check PAM use_authok
#
#.

audit_pam_authtok () {
  if [ "${os_name}" = "Linux" ]; then
    pam_module="use_authtok"
    check_string="PAM ${pam_module} Configuration"
    verbose_message "${check_string}" "check"
    if [ "${os_vendor}" = "Ubuntu" ] && [ "${os_version}" -ge 24 ]; then
      check_dir="/etc/pam.d"
      if [ "${audit_mode}" = 2 ]; then
        restore_file "${check_file}" "${restore_dir}"
      else
        pam_check=$( grep -cPH -- "^\h*password\h+([^#\n\r]+)\h+pam_unix\.so\h+([^#\n\r]+\h+)?${pam_module}\b" < "${check_file}" )
        if [ "${ansible}" = 1 ]; then
          echo ""
          echo "- name: Checking ${check_string}"
          echo "  command: sh -c \"grep -cPH -- \\"^\h*password\h+\([^#\n\r]+\)\h+pam_unix\.so\h+\([^#\n\r]+\h+\)?${pam_module}\b\\" < ${check_file}\"" 
          echo "  register: ${pam_module}_check"
          echo "  failed_when: ${pam_module}_check == 0"
          echo "  changed_when: false"
          echo "  ignore_errors: true"
          echo "  when: ansible_facts['ansible_system'] == '${os_name}'"
          echo ""
          echo "- name: Fixing ${check_string}"
          echo "  command: sh -c \"sed \\"s/\(^password.*pam_unix\.so\)\(.*\)/\1 ${pam_module} \2/g\\" ${check_file}\""
          echo "  when: ${pam_module}_check.rc == 0 and ansible_facts['ansible_system'] == '${os_name}'"
          echo ""
        fi
        if [ "${pam_check}" = "0" ]; then
          if [ "${audit_mode}" = 1 ]; then
            increment_insecure "PAM ${pam_module} not enabled in \"${check_file}\""
            verbose_message "sed \"s/\(^password.*pam_unix\.so\)\(.*\)/\1 ${pam_module} \2/g\" < ${check_file} > ${temp_file}" "fix"
            verbose_message "cat ${temp_file} > ${check_file}" "fix"
            verbose_message "rm ${temp_file}" "fix"
          fi
          if [ "${audit_mode}" = 0 ]; then
            backup_file     "${check_file}"
            verbose_message "PAM ${pam_module} enabled in \"${check_file}\"" "set"
            sed "s/\(^password.*pam_unix\.so\)\(.*\)/\1 ${pam_module} \2/g" < "${check_file}" > "${temp_file}"
            cat "${temp_file}" > "${check_file}"
            if [ -f "${temp_file}" ]; then
              rm "${temp_file}"
            fi
          fi
        else
          increment_secure "PAM ${pam_module} enabled in \"${check_file}\""
        fi
      fi
    fi
  fi
}
