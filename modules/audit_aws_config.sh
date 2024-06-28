#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# audit_aws_config
#
# Check AWS Config
#
# Refer to https://www.cloudconformity.com/conformity-rules/Config/aws-config-enabled.html
#.

audit_aws_config () {
  verbose_message "Config" "check"
	check=$( aws configservice describe-configuration-recorders --region "$aws_region" )
  if [ ! "$check" ]; then
    increment_insecure "AWS Configuration Recorder not enabled"
    lockdown_command   "aws configservice start-configuration-recorder" "fix"
  else
    increment_secure   "AWS Configuration Recorder enabled"
  fi
  check=$( aws configservice --region "$aws_region" get-status | grep FAILED )
  if [ "$check" ]; then
    increment_insecure "AWS Config not enabled"
  else
    increment_secure   "AWS Config enabled"
  fi
}

