#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_ftp_logging
#
# Check FTP logging
#
# Refer to Section(s) 4.2 Page(s) 67 CIS Solaris 10 Benchmark v5.1.0
#.

audit_ftp_logging () {
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ]; then
    verbose_message "FTPD Daemon Logging" "check"
    if [ "${os_name}" = "SunOS" ]; then
      if [ "${os_version}" = "10" ]; then
        get_command="svcprop -p inetd_start/exec svc:/network/ftp:default"
        check_value=$( ${get_command} | grep -c "\-d" )
        file_header="ftpd_logging"
        if [ "${audit_mode}" != 2 ]; then
         verbose_message "File ${file_header}" "check"
        fi
        log_file="${work_dir}/${file_header}.log"
        if [ "${audit_mode}" = 1 ]; then
          if [ "${check_value}" -eq 0 ]; then
            increment_insecure "FTP daemon logging not enabled"
            verbose_message    "inetadm -m svc:/network/ftp exec=\"/usr/sbin/in.ftpd -a -l -d\"" "fix"
          else
            increment_secure   "FTP daemon logging enabled"
          fi
        else
          if [ "${audit_mode}" = 0 ]; then
            if [ "${check_value}" -eq 0 ]; then
              verbose_message "FTP daemon logging to enabled" "set"
              eval "${get_command} > ${log_file}"
              eval "inetadm -m svc:/network/ftp exec=\"/usr/sbin/in.ftpd -a -l -d\""
            fi
          else
            if [ "${audit_mode}" = 2 ]; then
              restore_file="${restore_dir}/${file_header}.log"
              if [ -f "${restore_file}" ]; then
                exec_string=$( cat "${restore_file}" )
                verbose_message "Previous value for FTP daemon to \"${exec_string}\"" "restore"
                evel "inetadm -m svc:/network/ftp exec=\"${exec_string}\""
              fi
            fi
          fi
        fi
      fi
    fi
    if [ "${os_name}" = "Linux" ]; then
      check_file="/etc/vsftpd.conf"
      if [ -f "${check_file}" ]; then
        check_file_value "is" "${check_file}" "log_ftp_protocol"  "eq" "YES" "hash"
        check_file_value "is" "${check_file}" "ftpd_banner"       "eq" "Authorized users only. All activity may be monitored and reported." "hash"
        check_file_perms      "${check_file}" "0600" "root" "root"
      fi
      check_file="/etc/vsftpd/vsftpd.conf"
      if [ -f "${check_file}" ]; then
        check_file_value "is" "${check_file}" "log_ftp_protocol"  "eq" "YES" "hash"
        check_file_value "is" "${check_file}" "ftpd_banner"       "eq" "Authorized users only. All activity may be monitored and reported." "hash"
        check_file_perms      "${check_file}" "0600" "root" "root"
      fi
    fi
  fi
}
