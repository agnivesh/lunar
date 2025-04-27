#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_aws_ses
#
# Check AWS SES
#
# Refer to https://www.cloudconformity.com/conformity-rules/SES/dkim-enabled.html
#.

audit_aws_ses () {
  verbose_message "SES" "check"
  # determine if your AWS Simple Email Service (SES) identities (domains and email addresses) are configured to use DKIM signatures
  domain_list=$( aws ses list-identities --region "${aws_region}" --query Identities --output text 2> /dev/null )
  for domain in ${domain}_list; do
    ses_check=$( aws ses get-identity-dkim-attributes --region "${aws_region}" --identities "${domain}" | grep DkimEnabled | grep true )
    if [ -n "${ses_check}" ]; then
      increment_secure   "Domain \"${domain}\" has DKIM enabled" 
    else
      increment_insecure "Domain \"${domain}\" does not have DKIM enabled"
      verbose_message    "aws ses set-identity-dkim-enabled --region ${aws_region} --identity ${domain} --dkim-enabled" "fix"
    fi
  done
}

