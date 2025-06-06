#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# full_audit_password_services
#
# Audit password related services
#.

full_audit_password_services () {
  print_function "full_audit_password_services"
  audit_rsa_securid_pam
  audit_system_auth
  audit_system_auth_use_uid
  audit_password_expiry
  audit_password_strength
  audit_passwd_perms
  audit_retry_limit
  audit_login_records
  audit_failed_logins
  audit_login_delay
  audit_pass_req
  audit_pam_wheel
  audit_pam_authtok
  audit_password_hashing "${password_hashing}"
  audit_pam_deny
  audit_crypt_policy
  audit_account_lockout
  audit_sudo_timeout
  audit_sudo_timestamp
  audit_sudo_authenticate
  audit_sudo_nopassword
  audit_sudo_logfile
  audit_sudo_usepty
  audit_sudo_perms
}
