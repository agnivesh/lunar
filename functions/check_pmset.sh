#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# check_pmset
#
# Check Apple Power Management settings
#.

check_pmset() {
  if [ "${os_name}" = "Darwin" ]; then
    service="$1"
    value="$2"
    state="${value}"
    if [ "${value}" = "off" ]; then
      value="0"
    fi
    if [ "${value}" = "on" ]; then
      value="1"
    fi
    if [ "${value}" = "0" ]; then
      state="off"
    fi
    if [ "${value}" = "1" ]; then
      state="on"
    fi
    log_file="pmset_${service}.log"
    actual_test=$( pmset -g | grep "${service}" | awk '{print $2}' | grep -c "${value}" | sed "s/ //g" )
    if [ "$actual_test" = "0" ]; then
      actual_value="not-found"
    else
      actual_value=$( pmset -g | grep "${service}" | awk '{print $2}' | grep "${value}" )
    fi
    if [ "${audit_mode}" != 2 ]; then
      string="Sleep is disabled when powered"
      verbose_message "${string}" "check"
      if [ "${ansible}" = 1 ]; then
        echo ""
        echo "- name: Checking ${string}"
        echo "  command: sh -c \"pmset -g | grep ${service} |awk '{print \$2}' |grep ${value}\""
        echo "  register: pmset_check"
        echo "  failed_when: pmset_check == 1"
        echo "  changed_when: false"
        echo "  ignore_errors: true"
        echo "  when: ansible_facts['ansible_system'] == '${os_name}'"
        echo ""
        echo "- name: Fixing ${string}"
        echo "  command: sh -c \"pmset -c ${service} ${value}\""
        echo "  when: pmset_check.rc == 1 and ansible_facts['ansible_system'] == '${os_name}'"
        echo ""
      fi
      if [ ! "${actual_value}" = "${value}" ]; then
        increment_insecure "Service \"${service}\" is not \"${state}\""
        lockdown_command   "echo \"${state}\" > ${work_dir}/${log_file} ; pmset -c ${service} ${value}" "Service \"${service}\" to \"${state}\""
      else
        increment_secure   "Service \"${service}\" is \"${state}\""
      fi
    else
      restore_file=$retore_dir/${log_file}
      if [ -f "${restore_file}" ]; then
        restore_value=$( cat "${restore_file}" )
        if [ "${restore_value}" != "${actual_value}" ]; then
          verbose_message "Wake on lan to enabled" "restore"
          eval "pmset -c ${service} ${restore_value}"
        fi
      fi
    fi
  fi
}
