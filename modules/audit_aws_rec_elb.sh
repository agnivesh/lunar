#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_aws_rec_elb
#
# Check ELB Recommendations
# 
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-connection-draining-enabled.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-cross-zone-load-balancing-enabled.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/elb-minimum-number-of-ec2-instances.html
# Refer to https://www.cloudconformity.com/conformity-rules/ELB/unused-elastic-load-balancers.html
#.

audit_aws_rec_elb () {
  print_module    "audit_aws_rec_elb"
  verbose_message "ELB Recommendations" "check"
	elbs=$( aws elb describe-load-balancers --region "${aws_region}" --query "LoadBalancerDescriptions[].LoadBalancerName" --output text )
  for elb in ${elbs}; do
    check=$( aws elb describe-load-balancer-attributes --region "${aws_region}" --load-balancer-name "${elb}" --query "LoadBalancerAttributes.ConnectionDraining" | grep Enabled | grep true )
    if [ ! "${check}" ]; then
      increment_insecure "ELB \"${elb}\" does not have connection draining enabled"
      verbose_message    "aws elb modify-load-balancer-attributes --region ${aws_region} --load-balancer-name ${elb} --load-balancer-attributes \"{\\\"ConnectionDraining\\\":{\\\"Enabled\\\":true, \\\"Timeout\\\":300}}\"" "fix"
    else
      increment_secure   "ELB \"${elb}\" has connection draining"
    fi
    check=$( aws elb describe-load-balancer-attributes --region "${aws_region}" --load-balancer-name "${elb}"  --query "LoadBalancerAttributes.CrossZoneLoadBalancing" | grep Enabled | grep true )
    if [ ! "${check}" ]; then
      increment_insecure "ELB \"${elb}\" does not have cross zone balancing enabled"
    else
      increment_secure   "ELB \"${elb}\" has cross zone balancing enabled"
    fi
    number=$( aws elb describe-instance-health --region "${aws_region}" --load-balancer-name "${elb}"  --query "InstanceStates[].State" | grep -c InService )
    if [ "${number}" -lt 2 ]; then
      increment_insecure "ELB \"${elb}\" does not have at least 2 instances in service"
    else
      increment_secure   "ELB \"${elb}\" has at least two instances in service"
    fi
    instances=$( aws elb describe-instance-health --region "${aws_region}" --load-balancer-name "${elb}"  --query "InstanceStates[].InstanceState" --filter ansible_value=state,Values='OutOfService' --output text )
    for instance in ${instances}; do
      increment_insecure "ELB \"${elb}\" instance \"${instance}\" is out of service "
    done
  done
}

