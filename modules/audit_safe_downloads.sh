#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_safe_downloads
#
# Check safe downloads
#
# Refer to Section(s) 2.6.3 Page(s) 29-30 CIS Apple OS X 10.8 Benchmark v1.0.0
#.

audit_safe_downloads () {
  print_function "audit_safe_downloads"
  if [ "${os_name}" = "Darwin" ]; then
    verbose_message "Safe Downloads list" "check"
    log_file="gatekeeper.log"
    if [ "${audit_mode}" != 2 ]; then
      update_file="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.plist"
      if [ ! -f "${update_file}" ]; then
        actual_value="not-found"
      else
        actual_value=$( find "${update_file}" -mtime -30 )
      fi
      if [ "${actual_value}" != "${update_file}" ]; then
        if [ "${audit_mode}" = 1 ]; then
          increment_insecure "Safe Downloads list has not be updated recently"
          verbose_message    "Open System Preferences"                        "fix"
          verbose_message    "Select Security & Privacy"                      "fix"
          verbose_message    "Select the General tab"                         "fix"
          verbose_message    "Select Advanced"                                "fix"
          verbose_message    "Check Automatically update safe downloads list" "fix"
          verbose_message    "sudo /usr/libexec/XProtectUpdater"              "fix"
        fi
        if [ "${audit_mode}" = 0 ]; then
          verbose_message "Updating:  Safe Downloads list"
          sudo /usr/libexec/XProtectUpdater
        fi
      else
        if [ "${audit_mode}" = 1 ]; then
          increment_secure "Safe Downloads list has been updated recently"
        fi
      fi
    fi
  fi
}
