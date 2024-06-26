#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154
# shellcheck disable=SC2086

# check_itab
#
# Function to check inittab under AIX
#.

check_itab() {
  if [ "$os_name" = "AIX" ]; then
    service_name="$1"
    correct_value="$2"
    log_file="$service_name.log"
    actual_value=$( lsitab "$service_name" | cut -f1 -d: )
    if [ "$correct_value" = "off" ]; then
      if [ "$actual_status" != "$service_name" ]; then
        actual_value="off"
      fi
    fi
    if [ "$audit_mode" != 2 ]; then
      string="Service \"$service_name\" is not \"$correct_value\""
      verbose_message "$string" "check"
      if [ "$ansible" = 1 ]; then
        echo ""
        echo "- name: Checking $string"
        echo "  aix_inittab:"
        echo "    namw: $service_name"
        echo "    state: $correct_value"
        echo "  when: ansible_facts['ansible_system'] == '$os_name'"
        echo ""
      fi
      if [ "$actual_value" != "$correct_value" ]; then
        if [ "$audit_mode" = 1 ]; then
          increment_insecure "Service \"$service_name\" is \"$correct_value\""
          if [ "$correct_value" = "off" ]; then
            verbose_message "rmitab $( lsitab |grep \"^$service_name\" )" "fix"
          else
            verbose_message "chitab \"$correct_value\"" "fix"
          fi
        fi
        if [ "$audit_mode" = 0 ]; then
          log_file="$work_dir/$log_file"
          verbose_message "Service \"$service_name\" to \"$correct_value\"" "set"
          if [ "$correct_value" = "off" ]; then
            lsitab > "$log_file"
            rmitab "$service_name"
          else
            if [ "$actual_value" = "off" ]; then
              echo "off" > "$log_file"
              mkitab "$correct_value"
            else
              lsitab > "$log_file"
              chitab "$correct_value"
            fi
          fi
        fi
      else
        increment_secure "Service \"$service_name\" is \"$correct_value\""
      fi
    else
      log_file="$restore_dir/$log_file"
      if [ -f "$log_file" ]; then
        previous_value=$( cat "$log_file" )
        if [ "$previous_value" != "$actual_value" ]; then
          verbose_message "Service \"$service_name\" to \"$previous_value\"" "restore"
          if [ "$previous_value" = "off" ]; then
            rmitab "$service_name"
          else
            if [ "$actual_status" = "off" ]; then
              mkitab "$service_name" "$previous_value"
            else
              chitab "$service_name" "$previous_value"
            fi
          fi
        fi
      fi
    fi
  fi
}
