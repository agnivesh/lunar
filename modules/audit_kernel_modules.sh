#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_kernel_modules
#
# Check Kernel Modules
#
# Refer to http://kb.vmware.com/kb/2042473.
#.

audit_kernel_modules () {
  if [ "$os_name" = "VMkernel" ]; then
    verbose_message "Kernel Module Signing" "check"
    for module in $( esxcli system module list | grep '^[a-z]' | awk '($3 == "true") {print $1}' ); do
      log_file="kernel_module_$module"
      backup_file="$work_dir/$log_file"
      current_value=$( esxcli system module get -m "$module" | grep "Signed Status" | awk -F': ' '{print $2}' )
      if [ "$audit_mode" != "2" ]; then
        if [ "$current_value" != "VMware Signed" ]; then
          if [ "$audit_mode" = "0" ]; then
            if [ "$syslog_server" != "" ]; then
              verbose_message "Kernel module $module to disabled" "set"
              echo "true" > "$backup_file"
              esxcli system module set -e false -m "$module"
            fi
          fi
          if [ "$audit_mode" = "1" ]; then
            increment_insecure "Kernel module \"$module\" is not signed by VMware"
            verbose_message    "esxcli system module set -e false -m $module" "fix"
          fi
        else
          if [ "$audit_mode" = "1" ]; then
            increment_secure   "Kernel module \"$module\" is signed by VMware"
          fi
        fi
      else
        restore_file="$restore_dir/$log_file"
        if [ -f "$restore_file" ]; then
          previous_value=$( cat "$restore_file" )
          if [ "$previous_value" != "$current_value" ]; then
            verbose_message "Kernel module to \"$previous_value\"" "restore"
            esxcli system module set -e "$previous_value" -m "$module"
          fi
        fi
      fi
    done
  fi
}
