#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_postfix_daemon
#
# Refer to Section(s) 3.16   Page(s) 69-70 CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 2.2.15 Page(s) 115-6 CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 2.2.15 Page(s) 107-8 CIS Amazon Linux Benchmark v2.0.0
# Refer to Section(s) 2.2.15 Page(s) 115-6 CIS Ubuntu 16.04 Benchmark v1.0.0
#.

audit_postfix_daemon () {
  if [ "${os_name}" = "Linux" ]; then
    verbose_message "Postfix Daemon" "check"
    if [ "${os_vendor}" = "SuSE" ]; then
      check_file_value "is" "/etc/sysconfig/mail"  "SMTPD_LISTEN_REMOTE" "eq" "no"        "hash"
    fi
    check_file_value   "is" "/etc/postfix/main.cf" "inet_interfaces"     "eq" "localhost" "hash"
  fi
}
