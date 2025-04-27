#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# print_audit_info
#
# This function searches the script for the information associated
# with a function.
# It finds the line starting with # function_name
# then reads until it finds a #.
#.

print_audit_info () {
  if [ "${verbose}" = 1 ]; then
    module="$1"
    comment_text=0
    dir_name=$( pwd )
    check=$( echo "${module}" |grep "audit" )
    if [ -z "${check}" ]; then
      module="audit_${module}" 
    fi
    file_name="${dir_name}/modules/${module}.sh"
    if [ -f "${file_name}" ] ; then
      verbose_message "# Module: ${module}"
      while read -r line ; do
        if [ "${line}" = "# ${module}" ]; then
          comment_text=1
        else
          if [ "${comment_text}" = 1 ]; then
            if [ "${line}" = "#." ]; then
              verbose_message ""
              comment_text=0
            fi
            if [ "${comment_text}" = 1 ]; then
              if [ "${line}" != "#" ]; then
                verbose_message "${line}"
              fi
            fi
          fi
        fi
      done < "${file_name}"
   fi 
  fi
}
