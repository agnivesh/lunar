#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_svccfg_value
#
# Check syscfg settings
#.

audit_svccfg_value () {
  if [ "$os_name" = "SunOS" ]; then
    verbose_message "RPC Port Mapping" "check"
    service_name="$1"
    service_property="$2"
    correct_value="$3"
    current_value=$( svccfg -s $service_name listprop $service_property | awk '{print $3}' )
    file_header="svccfg"
    log_file="$work_dir/$file_header.log"
    if [ "$audit_mode" = 2 ]; then
      restore_file="$restore_dir/$file_header.log"
      if [ -f "$restore_file" ]; then
        restore_property=$( grep "$service_name" $restore_file | cut -f2 -d',' )
        restore_value=$( grep "$service_name" $restore_file | cut -f3 -d',' )
        if [ $( expr "$restore_property" : "[A-z]" ) = 1 ]; then
          if [ "$current_value" != "$restore_vale" ]; then
            verbose_message "Service \"$service_name\" Property \"$restore_property\" to \"$restore_value\"" "restore"
            eval "svccfg -s $service_name setprop $restore_property = $restore_value"
          fi
        fi
      fi
    else
      verbose_message "Service $service_name"
    fi
    if [ "$current_value" != "$correct_value" ]; then
      if [ "$audit_mode" = 1 ]; then
        increment_insecure "Service \"$service_name\" Property \"$service_property\" not set to \"$correct_value\""
        verbose_message "svccfg -s $service_name setprop $service_property = $correct_value" "fix"
      else
        if [ "$audit_mode" = 0 ]; then
          verbose_message "$service_name $service_propery to $correct_value" "set"
          echo "$service_name,$service_property,$current_value" >> "$log_file"
          eval "svccfg -s $service_name setprop $service_property = $correct_value"
        fi
      fi
    else
      if [ "$audit_mode" != 2 ]; then
        if [ "$audit_mode" = 1 ]; then
          increment_secure "Service \"$service_name\" Property \"$service_property\" already set to \"$correct_value\""
        fi
      fi
    fi
  fi
}
