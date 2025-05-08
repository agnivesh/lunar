#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# check_no
#
# Function to check no under AIX
#.

check_no() {
  if [ "${os_name}" = "AIX" ]; then
    parameter_name="$1"
    correct_value="$2"
    ansible_counter=$((ansible_counter+1))
    name="check_no_${ansible_counter}"
    log_file="${parameter_name}.log"
    actual_value=$( no -a | grep "${parameter_name} " | cut -f2 -d= | sed "s/ //g" )
    if [ "${audit_mode}" != 2 ]; then
      string="Parameter \"${parameter_name}\" is \"${correct_value}\""
      verbose_message "${string}" "check"
      if [ "${ansible}" = 1 ]; then
        echo ""
        echo "- name: Checking ${string}"
        echo "  command: sh -c \"no -a |grep '${parameter_name} ' |cut -f2 -d= |sed 's/ //g' |grep '${correct_value}'\""
        echo "  register: ${name}"
        echo "  failed_when: ${name} == 1"
        echo "  changed_when: false"
        echo "  ignore_errors: true"
        echo "  when: ansible_facts['ansible_system'] == '${os_name}'"
        echo ""
        echo "- name: Fixing ${string}"
        echo "  command: sh -c \"no -p -o ${parameter_name}=${correct_value}\""
        echo "  when: ${name}.rc == 1 and ansible_facts['ansible_system'] == '${os_name}'"
        echo ""
      fi
      if [ "${actual_value}" != "${correct_value}" ]; then
        log_file="${work_dir}/${log_file}"
        increment_insecure "Parameter \"${parameter_name}\" is not \"${correct_value}\""
        lockdown_command   "echo \"${actual_value}\" > ${log_file} ; no -p -o ${parameter_name}=${correct_value}" "Parameter \"${parameter_name}\" to \"${correct_value}\""
      else
        increment_secure   "Parameter \"${parameter_name}\" is \"${correct_value}\""
      fi
    else
      log_file="${restore_dir}/${log_file}"
      if [ -f "${log_file}" ]; then
        previous_value=$( cat "${log_file}" )
        if [ "${previous_value}" != "${actual_value}" ]; then
          verbose_message "Parameter \"${parameter_name}\" to \"${previous_value}\"" "restore"
          no -p -o "${parameter_name}=${previous_value}"
        fi
      fi
    fi
  fi
}
