# audit_aws_sgs
#
# Security groups provide stateful filtering of ingress/egress network
# traffic to AWS resources. It is recommended that no security group allows
# unrestricted ingress access to port 22.
#
# Removing unfettered connectivity to remote console services, such as SSH,
# reduces a server's exposure to risk.
#
# Security groups provide stateful filtering of ingress/egress network
# traffic to AWS resources. It is recommended that no security group
# allows unrestricted ingress access to port 3389.
# 
# Removing unfettered connectivity to remote console services, such as RDP,
# reduces a server's exposure to risk.
#
# Check your EC2 security groups for inbound rules that allow unrestricted
# access (i.e. 0.0.0.0/0) to TCP port 22. Restrict access to only those IP
# addresses that require it, in order to implement the principle of least
# privilege and reduce the possibility of a breach. TCP port 22 is used for
# secure remote login by connecting an SSH client application with an SSH
# server.
#
# Allowing unrestricted SSH access can increase opportunities for malicious
# activity such as hacking, man-in-the-middle attacks (MITM) and brute-force
# attacks.
#
# Refer to https://www.cloudconformity.com/conformity-rules/EC2/unrestricted-ssh-access.html
#
# Check your EC2 security groups for inbound rules that allow unrestricted
# access (i.e. 0.0.0.0/0) to TCP port 3389 and restrict access to only those IP
# addresses that require it in order to implement the principle of least
# privilege and reduce the possibility of a breach. TCP port 3389 is used for
# secure remote GUI login to Microsoft servers by connecting an RDP (Remote
# Desktop Protocol) client application with an RDP server.
#
# Allowing unrestricted RDP access can increase opportunities for malicious
# activity such as hacking, man-in-the-middle attacks (MITM) and Pass-the-Hash
# (PtH) attacks.
#
# Refer to https://www.cloudconformity.com/conformity-rules/EC2/unrestricted-rdp-access.html
#
# Check your EC2 security groups for inbound rules that allow unrestricted
# access (i.e. 0.0.0.0/0) to TCP port 445 and restrict access to only those
# IP addresses that require it in order to implement the principle of least
# privilege and reduce the possibility of a breach. Common Internet File
# System (CIFS) port 445 is used by client/server applications to provide
# shared access to files, printers and communications between network nodes
# directly over TCP (without NetBIOS) in Microsoft Windows Server 2003 and
# later. CIFS is based on the enhanced version of Server Message Block (SMB)
# protocol for internet/intranet file sharing, developed by Microsoft.
#
# Allowing unrestricted CIFS access can increase opportunities for malicious
# activity such as man-in-the-middle attacks (MITM), Denial of Service (DoS)
# attacks or the Windows Null Session Exploit.
#
# Refer to https://www.cloudconformity.com/conformity-rules/EC2/unrestricted-cifs-access.html
#
# Check your EC2 security groups for inbound rules that allow unrestricted
# access (i.e. 0.0.0.0/0) to TCP and UDP port 53 and restrict access to only
# those IP addresses that require it in order to implement the principle of
# least privilege and reduce the possibility of a breach. TCP/UDP port 53 is
# used by the Domain Name Service during DNS resolution (DNS lookup), when the
# requests are sent from DNS clients to DNS servers or between DNS servers
#
# Allowing unrestricted DNS access can increase opportunities for malicious
# activity such as such as Denial of Service (DoS) attacks or Distributed Denial
# of Service (DDoS) attacks.
#
# Refer to https://www.cloudconformity.com/conformity-rules/EC2/unrestricted-dns-access.html
#.

audit_aws_sgs () {
  sgs=`aws ec2 describe-security-groups --region $aws_region --query SecurityGroups[].GroupId --output text`
  for sg in $sgs; do
    inbound=`aws ec2 describe-security-groups --region $aws_region --group-ids $sg --filters Name=group-name,Values='default' --query 'SecurityGroups[*].{IpPermissions:IpPermissions,GroupId:GroupId}' |grep "0.0.0.0/0"`
    if [ ! "$inbound" ]; then
      total=`expr $total + 1`
      secure=`expr $secure + 1`
      echo "Secure:    Security Group $sg does not have a open inbound rule [$secure Passes]"
    else
      funct_aws_open_port_check $sg 22 tcp SSH
      funct_aws_open_port_check $sg 3389 tcp RDP
      funct_aws_open_port_check $sg 445 tcp CIFS
      funct_aws_open_port_check $sg 53 tcp DNS
    fi
    outbound=`aws ec2 describe-security-groups --region $aws_region --group-ids $sg --filters Name=group-name,Values='default' --query 'SecurityGroups[*].{IpPermissionsEgress:IpPermissionsEgress,GroupId:GroupId}' |grep "0.0.0.0/0"`
    total=`expr $total + 1`
    if [ ! "$outbound" ]; then
      secure=`expr $secure + 1`
      echo "Secure:    Security Group $sg does not have a open outbound rule [$secure Passes]"
    else
      insecure=`expr $insecure + 1`
      echo "Warning:   Security Group $sg has an open outbound rule [$insecure Warnings]"
      funct_verbose_message "" fix
      funct_verbose_message "aws ec2 revoke-security-group-egress --region $aws_region --group-name $sg --protocol tcp --cidr 0.0.0.0/0" fix
      funct_verbose_message "" fix
    fi
  done
}

