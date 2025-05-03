#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_ftp_users
#
# Check FTP users
#
# Refer to Section(s) 2.12.9 Page(s) 213-4 CIS AIX Benchmark v1.1.0
# Refer to Section(s) 6.9    Page(s) 52-3  CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 6.5    Page(s) 89-91 CIS Solaris 10 Benchmark v5.1.0
#.

audit_ftp_users () {
  check_file="$1"
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "AIX" ]; then
    funct_verbost_message "FTP Users" "check"
    if [ "${os_name}" = "AIX" ]; then
      for user_name in $( lsuser -c ALL | grep -v ^#name | grep -v root | cut -f1 -d: ); do
        user_check=$( lsuser -f "${user_name}" | grep id | cut -f2 -d= )
        if [ "${user_check}" -lt 200 ]; then
          if [ "${audit_mode}" = 1 ]; then
            increment_insecure  "User \"${user_name}\" not in \"${check_file}\""
          fi
          if [ "${audit_mode}" = 0 ]; then
            backup_file         "${check_file}"
            verbose_message     "User \"${user_name}\" to not be allowed ftp access" "set"
            check_append_file   "${check_file}" "${user_name}" "hash"
          fi
        else
          if [ "${audit_mode}" = 1 ]; then
            increment_secure    "User \"${user_name}\" in \"${check_file}\""
          fi
        fi
      done
      if [ "${audit_mode}" = 2 ]; then
        restore_file "${check_file}" "${restore_dir}"
      fi
    fi
    if [ "${os_name}" = "SunOS" ]; then
      for user_name in adm bin daemon gdm listen lp noaccess \
        nobody nobody4 nuucp postgres root smmsp svctag \
        sys uucp webserverd; do
        user_check=$( cut -f1 -d":" < /etc/passwd | grep "^${user_name}$" )
        user_check=$( expr "${user_check}" : "[A-z]" )
        if [ "${user_check}" = 1 ]; then
          ftpuser_check=$( grep -v '^#' < "${check_file}" | grep "^${user_name}$" )
          ftpuser_check=$( expr "${ftpuser_check}" : "[A-z]" )
          if [ "${ftpuser_check}" != 1 ]; then
            if [ "${audit_mode}" = 1 ]; then
              increment_insecure "User \"${user_name}\" not in \"${check_file}\""
            fi
            if [ "${audit_mode}" = 0 ]; then
              backup_file       "${check_file}"
              verbose_message   "User \"${user_name}\" to not be allowed ftp access" "set"
              check_append_file "${check_file}" "${user_name}" "hash"
            fi
          else
            if [ "${audit_mode}" = 1 ]; then
              increment_secure  "User \"${user_name}\" in \"${check_file}\""
            fi
          fi
        fi
      done
      if [ "${audit_mode}" = 2 ]; then
        restore_file "${check_file}" "${restore_dir}"
      fi
    fi
    if [ "${os_name}" = "Linux" ]; then
      for user_name in root bin daemon adm lp sync shutdown halt mail \
        news uucp operator games nobody; do
        user_check=$( cut -f1 -d":" < /etc/passwd | grep "^${user_name}$" )
        user_check=$( expr "${user_check}" : "[A-z]" )
        if [ "${user_check}" = 1 ]; then
          ftpuser_check=$( grep -v '^#' < "${check_file}" | grep "^${user_name}$" )
          ftpuser_check=$( expr "${ftpuser_check}" : "[A-z]" )
          if [ "${ftpuser_check}" != 1 ]; then
            if [ "${audit_mode}" = 1 ]; then
              increment_insecure  "User \"${user_name}\" not in \"${check_file}\""
            fi
            if [ "${audit_mode}" = 0 ]; then
              backup_file       "${check_file}"
              verbose_message   "User ${user_name} to not be allowed ftp access" "set"
              check_append_file "${check_file}" "${user_name}" "hash"
            fi
          else
            if [ "${audit_mode}" = 1 ]; then
              increment_secure  "User \"${user_name}\" in \"${check_file}\""
            fi
          fi
        fi
      done
      if [ "${audit_mode}" = 2 ]; then
        restore_file "${check_file}" "${restore_dir}"
      fi
    fi
  fi
}
