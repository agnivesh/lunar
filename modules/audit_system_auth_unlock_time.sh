#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_system_auth_unlock_time
#
# Check lockout time for failed password attempts enabled
#
# Refer to Section(s) 6.3.3 Page(s) 139-140 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 6.3.3 Page(s) 143-4   CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 5.3.2 Page(s) 234     CIS Ubuntu 16.04 Benchmark v1.0.0
#.

audit_system_auth_unlock_time () {
  auth_string="$1"
  search_string="$2"
  search_value="$3"
  if [ "${os_name}" = "Linux" ]; then
    os_check=0
    if [ "${os_vendor}" = "Amazon" ]; then
      os_check=1
    fi
    if [ "${os_vendor}" = "Ubuntu" ] && [ "${os_version}" -ge 16 ]; then
      if [ "${os_version}" -ge 22 ]; then
        os_check=0
      else
        os_check=1
      fi
    fi
    for check_file in /etc/pam.d/system-auth /etc/pam.d/common-auth; do
      if [ -f "${check_file}" ]; then
        if [ "${audit_mode}" != 2 ]; then
          verbose_message "Lockout time for failed password attempts enabled in \"${check_file}\"" "check"
          check_value=$( grep "^${auth_string}" "${check_file}" | grep "${search_string}$" | awk -F '${search_string}=' '{print $2}' | awk '{print $1}' )
          if [ "${check_value}" != "${search_string}" ]; then
            if [ "${audit_mode}" = "1" ]; then
              increment_insecure "Lockout time for failed password attempts not enabled in \"${check_file}\""
              verbose_message    "cp ${check_file} ${temp_file}" "fix"
              if [ "${os_check}" -eq 0 ]; then
                verbose_message "sed 's/^auth.*pam_env.so$/&\nauth\t\trequired\t\t\tpam_faillock.so preauth audit silent deny=5 unlock_time=900\nauth\t\t[success=1 default=bad]\t\t\tpam_unix.so\nauth\t\t[default=die]\t\t\tpam_faillock.so authfail audit deny=5 unlock_time=900\nauth\t\tsufficient\t\t\tpam_faillock.so authsucc audit deny=5 ${search_string}=${search_value}\n/' < ${temp_file} > ${check_file}" "fix"
              else
                verbose_message "awk '( $1 == \"auth\" && $2 == \"required\" && $3 == \"pam_tally2.so\" ) { print \"auth\trequired\tpam_tally2.so onerr=fail audit silent deny=5 unlock_time=900\"; print $0; next };' < ${temp_file} > ${check_file}" "fix"
              fi
              verbose_message "rm ${temp_file}" "fix"
            fi
            if [ "${audit_mode}" = 0 ]; then
              backup_file      "${check_file}"
              verbose_message  "Password minimum length in \"${check_file}\"" "set"
              cp "${check_file}" "${temp_file}"
              if [ "${os_check}" -eq 0 ]; then
                sed "s/^auth.*pam_env.so$/&\nauth\t\trequired\t\t\tpam_faillock.so preauth audit silent deny=5 unlock_time=900\nauth\t\t[success=1 default=bad]\t\t\tpam_unix.so\nauth\t\t[default=die]\t\t\tpam_faillock.so authfail audit deny=5 unlock_time=900\nauth\t\tsufficient\t\t\tpam_faillock.so authsucc audit deny=5 ${search_string}=${search_value}\n/" < "${temp_file}" > "${check_file}"
              else
                awk '( $1 == "auth" && $2 == "required" && $3 == "pam_tally2.so" ) { print "auth\trequired\tpam_tally2.so onerr=fail audit silent deny=5 unlock_time=900"; print $0; next };' < "${temp_file}" > "${check_file}"
              fi
              if [ -f "${temp_file}" ]; then
                rm "${temp_file}"
              fi
            fi
          else
            if [ "${audit_mode}" = "1" ]; then
              increment_secure "Lockout time for failed password attempts enabled in \"${check_file}\""
            fi
          fi
        else
          for restore_file in /etc/pam.d/system-auth /etc/pam.d/common-auth; do
            restore_file "${restore_file}" "${restore_dir}"
          done
        fi
      fi
    done
  fi
}
