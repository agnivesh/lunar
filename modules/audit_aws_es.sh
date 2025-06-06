#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_aws_es
#
# Check AWS Elasticsearch
#
# Refer to https://www.cloudconformity.com/conformity-rules/Elasticsearch/elasticsearch-domain-exposed.html
# Refer to https://www.cloudconformity.com/conformity-rules/Elasticsearch/elasticsearch-accessible-only-from-whitelisted-ip-addresses.html
#.

audit_aws_es () {
  print_function  "audit_aws_es"
  verbose_message "Elasticsearch" "check"
  domains=$( aws es list-domain-names --region "${aws_region}" --query "DomainNames[].DomainName" --output text )
  for domain in ${domains}; do
    check=$( aws es describe-elasticsearch-domain --domain-name "${domain}" --query 'DomainStatus.AccessPolicies' --output text | grep Principle | grep "{\"AWS\":\"\*\"}" )
    if [ -z "${check}" ]; then
      increment_secure   "Elasticsearch domain \"${domain}\" is not publicly accessible"
    else
      increment_insecure "Elasticsearch domain \"${domain}\" is publicly accessible"
    fi
    check=$( aws es describe-elasticsearch-domain --domain-name "${domain}" --query 'DomainStatus.AccessPolicies' --output text | grep "aws:SourceIp" | grep "[0-9]\." )
    if [ -n "${check}" ]; then
      increment_secure   "Elasticsearch doamin \"${domain}\" has an IP based access policy"
    else
      increment_insecure "Elasticsearch domain \"${domain}\" does not have and IP based access policy"
    fi
  done
}

