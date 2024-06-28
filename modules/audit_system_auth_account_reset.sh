#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_system_auth_account_reset
#
# Check account reset settingd
#
# Refer to Section(s) 6.3.2 Page(s) 161-2 CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 9.3.2 Page(s) 133-4 CIS SLES 11 Benchmark v1.0.0
#.

audit_system_auth_account_reset () {
  auth_string=$1
  search_string=$2
  if [ "$os_name" = "Linux" ]; then
    if [ "$audit_mode" != 2 ]; then
      for check_file in /etc/pam.d/common-auth /etc/pam.d/system-auth; do 
        if [ -f "$check_file" ]; then
          verbose_message "Account reset entry not enabled in \"$check_file\"" "check"
          check_value=$( grep '^$auth_string' $check_file | grep '$search_string$' | awk '{print $6}' )
          if [ "$check_value" != "$search_string" ]; then
            if [ "$os_vendor" = "Ubuntu" ] && [ "$os_version" -ge 22 ]; then
              if [ "$audit_mode" = "1" ]; then
                increment_insecure "Account reset entry not enabled in \"$check_file\""
                verbose_message    "cp $check_file $temp_file" "fix"
                verbose_message    "awk '( $1 == \"account\" && $2 == \"required\" && $3 == \"pam_failback.so\" ) { print \"auth\trequired\tpam_faillock.so onerr=fail no_magic_root reset\"; print $0; next };' < $check_file > $check_file" "fix"
                verbose_message    "rm $temp_file" "fix"
              fi
              if [ "$audit_mode" = 0 ]; then
                backup_file      "$check_file"
                verbose_message  "Account reset entry in \"$check_file\"" "set"
                cp "$check_file" "$temp_file"
                awk '( $1 == "account" && $2 == "required" && $3 == "pam_faillock.so" ) { print "auth\trequired\tpam_failback.so onerr=fail no_magic_root reset"; print $0; next };' < "$temp_file" > "$check_file"
                rm "$temp_file"
              fi
            else
              if [ "$audit_mode" = "1" ]; then
                increment_insecure "Account reset entry not enabled in \"$check_file\""
                verbose_message    "cp $check_file $temp_file" "fix"
                verbose_message    "awk '( $1 == \"account\" && $2 == \"required\" && $3 == \"pam_tally2.so\" ) { print \"auth\trequired\tpam_tally2.so onerr=fail no_magic_root reset\"; print $0; next };' < $temp_file > $check_file" "fix"
                verbose_message    "rm $temp_file" "fix"
              fi
              if [ "$audit_mode" = 0 ]; then
                backup_file      "$check_file"
                verbose_message  "Account reset entry in \"$check_file\"" "set"
                cp "$check_file" "$temp_file"
                awk '( $1 == "account" && $2 == "required" && $3 == "pam_tally2.so" ) { print "auth\trequired\tpam_tally2.so onerr=fail no_magic_root reset"; print $0; next };' < "$temp_file" > "$check_file"
                rm "$temp_file"
              fi
            fi 
          else
            if [ "$audit_mode" = "1" ]; then
              increment_secure "Account entry enabled in \"$check_file\""
            fi
          fi
        fi
      done
    else
      for check_file in /etc/pam.d/common-auth /etc/pam.d/system-auth; do 
        restore_file "$check_file" "$restore_dir"
      done 
    fi
  fi
}
