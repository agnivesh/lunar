#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# full_audit_file_services
#
# Audit file permissions
#.

full_audit_file_services () {
  print_function "full_audit_file_services"
  audit_syslog_perms
  audit_volfs
  audit_autofs
  audit_dfstab
  audit_mount_setuid
  audit_mount_nodev
  audit_mount_noexec
  audit_mount_fdi
  audit_nfs
  audit_uucp
  audit_cd_sharing
  audit_filesystem_partitions
}
