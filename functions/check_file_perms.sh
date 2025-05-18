#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154
# shellcheck disable=SC2012

# check_file_perms
#
# Code to check permissions on a file
# If running in audit mode it will check permissions and report
# If running in lockdown mode it will fix permissions if they
# don't match those passed to routine
# Takes:
# check_file:   Name of file
# check_perms:  Octal of file permissions, eg 755
# check_owner:  Owner of file
# check_group:  Group ownership of file
#.

check_file_perms () {
  print_function "check_file_perms"
  check_file="$1"
  check_perms="$2"
  check_owner="$3"
  check_group="$4"
  if [ "${id_check}" = "0" ]; then
    find_command="find"
  else
    find_command="sudo find"
  fi
  if [ "${audit_mode}" != 2 ]; then
    string="File permissions on \"${check_file}\""
    verbose_message "${string}" "check"
    if [ "${ansible}" = 1 ]; then
      echo ""
      echo "- name: Checking ${string}"
      echo "  file:"
      echo "    path: ${check_file}"
      if [ ! "${check_owner}" = "" ]; then
        echo "    owner: ${check_owner}"
      fi
      if [ ! "${check_group}" = "" ]; then
        echo "    group: ${check_group}"
      fi
      echo "    mode: ${check_perms}"
      echo ""
    fi
  fi
  if [ ! -e "${check_file}" ]; then
    if [ "${audit_mode}" != 2 ]; then
      verbose_message "File \"${check_file}\" does not exist" "warn"
    fi
    return
  fi
  if [ "${check_owner}" != "" ]; then
    check_result=$( find "${check_file}" -maxdepth 0 -perm "${check_perms}" -user "${check_owner}" -group "${check_group}" 2> /dev/null | wc -l | sed "s/ //g" )
  else
    check_result=$( find "${check_file}" -maxdepth 0 -perm "${check_perms}" 2> /dev/null | wc -l | sed "s/ //g" )
  fi
  log_file="fileperms.log"
  if [ "${check_result}" != "1" ]; then
    if [ "${audit_mode}" = 1 ] && [ -n "${check_result}" ]; then
      increment_insecure "File \"${check_file}\" has incorrect permissions"
      verbose_message    "chmod ${check_perms} ${check_file}" "fix"
      if [ "${check_owner}" != "" ]; then
        if [ "${check_result}" != "1" ]; then
          verbose_message "chown ${check_owner}:${check_group} ${check_file}" "fix"
        fi
      fi
    fi
    if [ "${audit_mode}" = 0 ]; then
      log_file="${work_dir}/${log_file}"
      if [ "${os_name}" = "SunOS" ]; then
        file_perms=$( truss -vstat -tstat ls -ld "${check_file}" 2>&1 | grep 'm=' | tail -1 | awk '{print $3}' | cut -f2 -d'=' | cut -c4-7 )
      else
        if [ "${os_name}" = "Darwin" ]; then
          file_perms=$( stat -f %p "${check_file}" | tail -c 4 )
        else
          file_perms=$( stat -c %a "${check_file}" )
        fi
      fi
      if [ "${os_name}" = "Linux" ]; then
        file_owner=$( stat -c "%U,%G" "${check_file}" )
      else
        file_owner=$( ls -ld "${check_file}" | awk '{print $3","$4}' )
      fi
      update_log_file "${log_file}" "${check_file},${file_perms},${file_owner}"
      lockdown_message="File \"${check_file}\" to have correct permissions"
      lockdown_command="chmod ${check_perms} ${check_file}"
      execute_lockdown "${lockdown_command}" "${lockdown_message}" "sudo"
      if [ "${check_owner}" != "" ]; then
        if [ "${check_result}" != "${check_file}" ]; then
          lockdown_message="File \"${check_file}\" to have correct owner"
          lockdown_command="chown ${check_owner}:${check_group} ${check_file}"
          execute_lockdown "${lockdown_command}" "${lockdown_message}" "sudo"
        fi
      fi
    fi
  else
    if [ "${audit_mode}" = 1 ]; then
      increment_secure "File \"${check_file}\" has correct permissions"
    fi
  fi
  if [ "${audit_mode}" = 2 ]; then
    restore_file="${restore_dir}/${log_file}"
    if [ -f "${restore_file}" ]; then
      restore_check=$( grep "${check_file}" "${restore_file}" | cut -f1 -d"," )
      if [ "$restore_check" = "${check_file}" ]; then
        restore_info=$( grep "${check_file}" "${restore_file}" )
        restore_perms=$( echo "${restore_info}" | cut -f2 -d"," )
        restore_owner=$( echo "${restore_info}" | cut -f3 -d"," )
        restore_group=$( echo "${restore_info}" | cut -f4 -d"," )
        restore_message="File \"${check_file}\" to previous permissions"
        restore_command="chmod ${restore_perms} ${check_file}"
        execute_restore "${restore_command}" "${restore_message}" "sudo"
        if [ "${check_owner}" != "" ]; then
          if [ "${check_result}" != "${check_file}" ]; then
            restore_message="File \"${check_file}\" to previous owner"
            restore_command="chown ${restore_owner}:${restore_group} ${check_file}"
            execute_restore "${restore_command}" "${restore_message}" "sudo"
          fi
        fi
      fi
    fi
  fi
}
