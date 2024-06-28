#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# check_chsec
#
# Function to check sec under AIX
#.

check_chsec() {
  if [ "$os_name" = "AIX" ]; then
    sec_file="$1"
    sec_stanza="$2"
    parameter_name="$3"
    correct_value="$4"
    log_file="$sec_file_$sec_stanza_$parameter_name.log"
    if [ "$audit_mode" != 2 ]; then
      string="Security Policy for \"$parameter_name\" is set to \"$correct_value\""
      verbose_message "$string" "check"
      if [ "$ansible" = 1 ]; then
        echo ""
        echo "- name: Checking $string"
        echo "  command: sh -c \"lssec -f $sec_file -s $sec_stanza -a $parameter_name |awk '{print \$2}' |cut -f2 -d=\""
        echo "  register: lssec_check"
        echo "  failed_when: lssec_check == 1"
        echo "  changed_when: false"
        echo "  ignore_errors: true"
        echo "  when: ansible_facts['ansible_system'] == '$os_name'"
        echo ""
        echo "- name: Fixing $string"
        echo "  command: sh -c \"chsec -f $sec_file -s $sec_stanza -a $parameter_name=$correct_value\""
        echo "  when: lssec_check.rc == 1 and ansible_facts['ansible_system'] == '$os_name'"
        echo ""
      fi
      actual_value=$( lssec -f "$sec_file" -s "$sec_stanza" -a "$parameter_name" | awk '{print $2}' | cut -f2 -d= )
      if [ "$actual_value" != "$correct_value" ]; then
        log_file="$work_dir/$log_file"
        increment_insecure "Security Policy for \"$parameter_name\" is not set to \"$correct_value\""
        lockdown_command   "echo \"chsec -f $sec_file -s $sec_stanza -a $parameter_name=$actual_value\" > $log_file ; chsec -f $sec_file -s $sec_stanza -a $parameter_name=$correct_value" "Security Policy for \"$parameter_name\" to \"$correct_value\""
      else
        increment_secure   "Password Policy for \"$parameter_name\" is set to \"$correct_value\""
      fi
    else
      log_file="$restore_dir/$log_file"
      if [ -f "$log_file" ]; then
        previous_value=$( cut -f2 -d= "$log_file" )
        if [ "$previous_value" != "$actual_value" ]; then
          verbose_message "Restoring: Password Policy for \"$parameter_name\" to \"$previous_value\""
          sh < "$log_file"
        fi
      fi
    fi
  fi
}
