# AWS Troubleshooting Guide

This comprehensive guide provides commands, techniques, and solutions for troubleshooting common issues in Amazon Web Services (AWS) environments.

## Table of Contents

- [EC2 Instance Troubleshooting](#ec2-instance-troubleshooting)
- [EBS Volume Issues](#ebs-volume-issues)
- [VPC and Networking Problems](#vpc-and-networking-problems)
- [IAM and Permissions](#iam-and-permissions)
- [S3 Storage Issues](#s3-storage-issues)
- [RDS Database Troubleshooting](#rds-database-troubleshooting)
- [Elastic Load Balancer Problems](#elastic-load-balancer-problems)
- [CloudWatch Monitoring and Logs](#cloudwatch-monitoring-and-logs)
- [Lambda Function Issues](#lambda-function-issues)
- [AWS CLI Troubleshooting](#aws-cli-troubleshooting)

## EC2 Instance Troubleshooting

### Instance Connection Issues

```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Get system log
aws ec2 get-console-output --instance-id i-1234567890abcdef0

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0

# Verify if instance is in public subnet
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query "Reservations[*].Instances[*].SubnetId" --output text
aws ec2 describe-subnets --subnet-ids subnet-1234567890abcdef0 --query "Subnets[*].MapPublicIpOnLaunch"
```

Common connection issues:
1. Security group doesn't allow SSH (port 22) or RDP (port 3389)
2. Network ACL blocking traffic
3. Instance in private subnet without proper routing
4. SSH key issues (wrong key, permission too open)

SSH connection troubleshooting:
```bash
# Check SSH key permissions
chmod 400 key.pem

# Verbose SSH connection for debugging
ssh -vvv -i key.pem ec2-user@ec2-xx-xx-xx-xx.compute-1.amazonaws.com

# SSH via Session Manager (if direct SSH fails)
aws ssm start-session --target i-1234567890abcdef0
```

### Instance Performance Issues

```bash
# Get CloudWatch metrics for CPU
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization --period 300 --statistics Average --dimensions Name=InstanceId,Value=i-1234567890abcdef0 --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Check instance type
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query "Reservations[*].Instances[*].InstanceType" --output text

# Stop and start instance (if possible, to migrate to different host)
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
aws ec2 start-instances --instance-ids i-1234567890abcdef0
```

Within the instance:
```bash
# Check CPU usage
top

# Check memory usage
free -h

# Check disk usage
df -h

# Check I/O stats
iostat -xz 1
```

### EC2 Instance Status Check Failures

```bash
# Get status check details
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Reboot the instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0

# Start system status diagnostic
aws ec2 report-instance-status --instances i-1234567890abcdef0 --status impaired --reason unresponsive
```

Status check failures types:
1. **System Status Check**: Hardware issues on the physical host
2. **Instance Status Check**: Software issues with your instance

## EBS Volume Issues

### Volume Performance

```bash
# Check volume details
aws ec2 describe-volumes --volume-ids vol-1234567890abcdef0

# Get volume metrics
aws cloudwatch get-metric-statistics --namespace AWS/EBS --metric-name VolumeReadOps --period 300 --statistics Sum --dimensions Name=VolumeId,Value=vol-1234567890abcdef0 --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)
```

Within the instance:
```bash
# Check I/O wait times
iostat -xz 1

# Check I/O operations
sudo iotop

# Check which process is using the disk
sudo iotop -o
```

### Volume Attachment Issues

```bash
# Check volume attachment status
aws ec2 describe-volumes --volume-ids vol-1234567890abcdef0 --query "Volumes[*].Attachments[*]"

# Detach volume
aws ec2 detach-volume --volume-id vol-1234567890abcdef0

# Attach volume
aws ec2 attach-volume --volume-id vol-1234567890abcdef0 --instance-id i-1234567890abcdef0 --device /dev/sdf
```

Within the instance:
```bash
# List block devices
lsblk

# Check if filesystem is mounted
mount | grep /dev/xvdf

# Mount volume manually
sudo mkdir -p /mnt/data
sudo mount /dev/xvdf1 /mnt/data
```

### Volume Full Issues

```bash
# Create a snapshot before working on the volume
aws ec2 create-snapshot --volume-id vol-1234567890abcdef0 --description "Backup before resize"

# Increase volume size
aws ec2 modify-volume --volume-id vol-1234567890abcdef0 --size 100
```

Within the instance (after volume resize):
```bash
# Check if OS sees the new size
sudo lsblk

# For ext4 filesystem
sudo resize2fs /dev/xvdf1

# For XFS filesystem
sudo xfs_growfs /mount/point
```

## VPC and Networking Problems

### Connectivity Issues

```bash
# Check VPC details
aws ec2 describe-vpcs --vpc-ids vpc-1234567890abcdef0

# Verify subnet details
aws ec2 describe-subnets --subnet-ids subnet-1234567890abcdef0

# Check route tables
aws ec2 describe-route-tables --route-table-ids rtb-1234567890abcdef0

# Validate security groups
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0
```

From instance:
```bash
# Check routing table
netstat -rn

# Test connectivity to external endpoint
curl -v https://example.com

# Test specific port
nc -zv example.com 443

# Trace route
traceroute example.com
```

### NAT Gateway Issues

```bash
# Check NAT gateway status
aws ec2 describe-nat-gateways --nat-gateway-ids nat-1234567890abcdef0

# Check if it has an Elastic IP
aws ec2 describe-nat-gateways --nat-gateway-ids nat-1234567890abcdef0 --query "NatGateways[*].NatGatewayAddresses[*].AllocationId"

# Check the route table for private subnets
aws ec2 describe-route-tables --filters "Name=route.nat-gateway-id,Values=nat-1234567890abcdef0"
```

Testing from private instance:
```bash
# Install AWS CLI on private instance
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Test if instance can reach S3 (through NAT or VPC endpoint)
aws s3 ls
```

### VPC Peering Issues

```bash
# Check peering connection status
aws ec2 describe-vpc-peering-connections --vpc-peering-connection-ids pcx-1234567890abcdef0

# Verify route tables in both VPCs
aws ec2 describe-route-tables --filters "Name=route.vpc-peering-connection-id,Values=pcx-1234567890abcdef0"
```

## IAM and Permissions

### Permission Issues

```bash
# Check current user/role
aws sts get-caller-identity

# List user policies
aws iam list-attached-user-policies --user-name username

# List role policies
aws iam list-attached-role-policies --role-name rolename

# Check policy details
aws iam get-policy --policy-arn arn:aws:iam::123456789012:policy/policyname
aws iam get-policy-version --policy-arn arn:aws:iam::123456789012:policy/policyname --version-id v1
```

### Testing IAM Permissions

```bash
# Simulate a policy evaluation
aws iam simulate-principal-policy --policy-source-arn arn:aws:iam::123456789012:user/username --action-names s3:GetObject --resource-arns arn:aws:s3:::bucket-name/key

# Get IAM Access Analyzer findings
aws accessanalyzer list-findings --analyzer-arn arn:aws:access-analyzer:region:123456789012:analyzer/analyzer-name
```

### IAM Role for EC2

```bash
# Check instance profile
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query "Reservations[*].Instances[*].IamInstanceProfile"

# Get role details from instance profile
aws iam get-instance-profile --instance-profile-name profile-name

# List policies attached to a role
aws iam list-attached-role-policies --role-name role-name
```

## S3 Storage Issues

### Access Issues

```bash
# Check bucket permissions
aws s3api get-bucket-policy --bucket bucket-name

# Check bucket ACL
aws s3api get-bucket-acl --bucket bucket-name

# Check object ACL
aws s3api get-object-acl --bucket bucket-name --key object-name

# List all objects (to verify existence)
aws s3 ls s3://bucket-name/ --recursive
```

### Bucket Policy Issues

```bash
# Get current bucket policy
aws s3api get-bucket-policy --bucket bucket-name

# Check bucket public access settings
aws s3api get-public-access-block --bucket bucket-name
```

### S3 Performance Issues

```bash
# Check object metadata
aws s3api head-object --bucket bucket-name --key object-name

# Use parallel operations for large uploads/downloads
aws s3 cp large-file s3://bucket-name/ --region us-west-2 --acl bucket-owner-full-control --quiet

# Use multipart uploads for large files
# Using the AWS SDK recommended for production environments
```

## RDS Database Troubleshooting

### Connection Issues

```bash
# Check RDS instance status
aws rds describe-db-instances --db-instance-identifier db-identifier

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0

# Check if publicly accessible
aws rds describe-db-instances --db-instance-identifier db-identifier --query "DBInstances[*].PubliclyAccessible"
```

From EC2 instance:
```bash
# Test MySQL connection
mysql -h endpoint.rds.amazonaws.com -u username -p

# Test PostgreSQL connection
psql -h endpoint.rds.amazonaws.com -U username -d dbname

# Test connection using netcat
nc -zv endpoint.rds.amazonaws.com 3306
```

### Performance Issues

```bash
# Check CloudWatch metrics
aws cloudwatch get-metric-statistics --namespace AWS/RDS --metric-name CPUUtilization --period 300 --statistics Average --dimensions Name=DBInstanceIdentifier,Value=db-identifier --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Enable Enhanced Monitoring
aws rds modify-db-instance --db-instance-identifier db-identifier --monitoring-interval 60 --monitoring-role-arn arn:aws:iam::123456789012:role/rds-monitoring-role

# View Performance Insights
aws rds describe-db-instance-performance --db-instance-identifier db-identifier
```

### Storage Issues

```bash
# Check storage metrics
aws cloudwatch get-metric-statistics --namespace AWS/RDS --metric-name FreeStorageSpace --period 300 --statistics Average --dimensions Name=DBInstanceIdentifier,Value=db-identifier --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Increase storage
aws rds modify-db-instance --db-instance-identifier db-identifier --allocated-storage 100 --apply-immediately
```

## Elastic Load Balancer Problems

### Health Check Failures

```bash
# Check target group health
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:region:123456789012:targetgroup/tg-name/1234567890abcdef0

# Check load balancer attributes
aws elbv2 describe-load-balancer-attributes --load-balancer-arn arn:aws:elasticloadbalancing:region:123456789012:loadbalancer/app/lb-name/1234567890abcdef0

# Check target group settings
aws elbv2 describe-target-group-attributes --target-group-arn arn:aws:elasticloadbalancing:region:123456789012:targetgroup/tg-name/1234567890abcdef0
```

From EC2 instance:
```bash
# Check if health check endpoint responds
curl -v http://localhost/health

# Check if required port is listening
netstat -tulpn | grep LISTEN
```

### Connection Issues

```bash
# Check security groups for ELB
aws elbv2 describe-load-balancers --load-balancer-arns arn:aws:elasticloadbalancing:region:123456789012:loadbalancer/app/lb-name/1234567890abcdef0 --query "LoadBalancers[*].SecurityGroups"

# Check security groups for targets
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0

# Verify VPC settings
aws elbv2 describe-load-balancers --load-balancer-arns arn:aws:elasticloadbalancing:region:123456789012:loadbalancer/app/lb-name/1234567890abcdef0 --query "LoadBalancers[*].VpcId"
```

## CloudWatch Monitoring and Logs

### Missing Metrics

```bash
# Check if metrics are being published
aws cloudwatch list-metrics --namespace AWS/EC2 --dimensions Name=InstanceId,Value=i-1234567890abcdef0

# Verify CloudWatch agent status (on EC2)
sudo systemctl status amazon-cloudwatch-agent
```

### Log Issues

```bash
# Check log groups
aws logs describe-log-groups --log-group-name-prefix /aws/ec2/

# Check log streams
aws logs describe-log-streams --log-group-name /aws/ec2/instance-id

# Get recent log events
aws logs get-log-events --log-group-name /aws/ec2/instance-id --log-stream-name stream-name
```

On EC2 instance:
```bash
# Check CloudWatch agent config
cat /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Check agent logs
tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

## Lambda Function Issues

### Execution Failures

```bash
# Check Lambda function details
aws lambda get-function --function-name function-name

# Invoke function for testing
aws lambda invoke --function-name function-name --payload '{"key":"value"}' output.txt

# Check execution logs
aws logs get-log-events --log-group-name /aws/lambda/function-name --log-stream-name stream-name
```

### Cold Start and Performance Issues

```bash
# Check configured memory
aws lambda get-function-configuration --function-name function-name

# Update memory allocation
aws lambda update-function-configuration --function-name function-name --memory-size 1024

# Configure provisioned concurrency
aws lambda put-provisioned-concurrency-config --function-name function-name --qualifier alias-or-version --provisioned-concurrent-executions 5
```

### Permissions Issues

```bash
# Check Lambda execution role
aws lambda get-function --function-name function-name --query "Configuration.Role"

# Get policy for role
aws iam get-role-policy --role-name role-name --policy-name policy-name

# Check resource-based policy
aws lambda get-policy --function-name function-name
```

## AWS CLI Troubleshooting

### Configuration Issues

```bash
# Check current configuration
aws configure list

# Check credentials file
cat ~/.aws/credentials

# Check config file
cat ~/.aws/config
```

### Permission Issues

```bash
# Verify identity
aws sts get-caller-identity

# Test a specific permission
aws s3 ls s3://bucket-name/ --debug
```

### AWS CLI Performance

```bash
# Use specific endpoint
aws s3 ls --endpoint-url https://s3.us-west-2.amazonaws.com

# Speed up S3 operations with concurrent transfers
aws s3 cp large-directory s3://bucket-name/ --recursive --quiet --region us-west-2 --acl bucket-owner-full-control --only-show-errors

# Use AWS SSO for improved authentication experience
aws configure sso
```

## Real-World Troubleshooting Examples

### Case Study: EC2 Instance Not Accessible via SSH

**Symptoms:**
- Unable to connect to EC2 instance via SSH
- Connection timeouts or "connection refused" errors

**Diagnosis Steps:**
```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0

# Verify security group allows SSH access
aws ec2 describe-security-groups --group-ids sg-1234567890abcdef0 --query "SecurityGroups[*].IpPermissions[?ToPort==`22`]"

# Check if instance is in a public subnet
aws ec2 describe-instances --instance-ids i-1234567890abcdef0 --query "Reservations[*].Instances[*].SubnetId" --output text
aws ec2 describe-subnets --subnet-ids subnet-1234567890abcdef0 --query "Subnets[*].MapPublicIpOnLaunch"

# Get the console output for system-level issues
aws ec2 get-console-output --instance-id i-1234567890abcdef0
```

**Solution:**
1. **If security group is blocking SSH:**
   ```bash
   aws ec2 authorize-security-group-ingress --group-id sg-1234567890abcdef0 --protocol tcp --port 22 --cidr your-ip-address/32
   ```

2. **If instance in private subnet:**
   - Set up a bastion host in a public subnet
   - Use AWS Systems Manager Session Manager:
   ```bash
   aws ssm start-session --target i-1234567890abcdef0
   ```

3. **If SSH service not running:**
   - Stop and start the instance (not just reboot):
   ```bash
   aws ec2 stop-instances --instance-ids i-1234567890abcdef0
   aws ec2 start-instances --instance-ids i-1234567890abcdef0
   ```

### Case Study: S3 Access Denied Errors

**Symptoms:**
- "Access Denied" errors when accessing S3 bucket or objects
- Unable to upload/download from bucket despite having IAM permissions

**Diagnosis Steps:**
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket bucket-name

# Check bucket ACL
aws s3api get-bucket-acl --bucket bucket-name

# Check public access settings
aws s3api get-public-access-block --bucket bucket-name

# Verify IAM permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/username \
  --action-names s3:GetObject s3:PutObject \
  --resource-arns arn:aws:s3:::bucket-name/object-key
```

**Solution:**
1. **If bucket policy is restrictive:**
   Modify bucket policy to allow necessary access:
   ```bash
   aws s3api put-bucket-policy --bucket bucket-name --policy '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {"AWS": "arn:aws:iam::123456789012:user/username"},
         "Action": ["s3:GetObject", "s3:PutObject"],
         "Resource": "arn:aws:s3:::bucket-name/*"
       }
     ]
   }'
   ```

2. **If public access block is enabled:**
   ```bash
   aws s3api put-public-access-block --bucket bucket-name --public-access-block-configuration '{"BlockPublicAcls": true, "IgnorePublicAcls": true, "BlockPublicPolicy": false, "RestrictPublicBuckets": false}'
   ```

3. **If IAM permissions are missing:**
   ```bash
   aws iam attach-user-policy --user-name username --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
   ```

### Case Study: RDS Database High CPU Usage

**Symptoms:**
- Database performance degradation
- High CPU utilization showing in CloudWatch
- Slow query responses

**Diagnosis Steps:**
```bash
# Check CPU utilization over time
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --period 300 \
  --statistics Average \
  --dimensions Name=DBInstanceIdentifier,Value=db-identifier \
  --start-time $(date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)

# Check for slow queries (if Enhanced Monitoring is enabled)
aws rds download-db-log-file-portion \
  --db-instance-identifier db-identifier \
  --log-file-name slowquery/mysql-slowquery.log \
  --output text

# Check Performance Insights for query load
aws pi get-resource-metrics \
  --service-type RDS \
  --identifier db-identifier \
  --metric-queries '[{"Metric":"db.load.avg","GroupBy":{"Group":"db.sql","Limit":10}}]' \
  --start-time $(date -u -d '2 hours ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period-in-seconds 300
```

**Solution:**
1. **If specific queries are causing load:**
   - Optimize queries with proper indexing
   - Implement query caching
   - Use read replicas for read-heavy workloads:
   ```bash
   aws rds create-db-instance-read-replica \
     --db-instance-identifier read-replica-identifier \
     --source-db-instance-identifier source-db-identifier
   ```

2. **If instance is undersized:**
   ```bash
   aws rds modify-db-instance \
     --db-instance-identifier db-identifier \
     --db-instance-class db.r5.xlarge \
     --apply-immediately
   ```

3. **If connection overload:**
   Implement connection pooling at the application level

### Case Study: Lambda Function Timeouts

**Symptoms:**
- Lambda function executions fail with timeout errors
- Function takes longer than configured timeout period

**Diagnosis Steps:**
```bash
# Check current timeout configuration
aws lambda get-function-configuration \
  --function-name function-name \
  --query "Timeout"

# Check CloudWatch logs for execution duration
aws logs filter-log-events \
  --log-group-name /aws/lambda/function-name \
  --filter-pattern "REPORT" \
  --query "events[*].message"

# Check if function is running out of memory
aws logs filter-log-events \
  --log-group-name /aws/lambda/function-name \
  --filter-pattern "REPORT" \
  --query "events[*].message" | grep "Memory used"
```

**Solution:**
1. **Increase timeout limit:**
   ```bash
   aws lambda update-function-configuration \
     --function-name function-name \
     --timeout 30
   ```

2. **Increase memory allocation (also increases CPU):**
   ```bash
   aws lambda update-function-configuration \
     --function-name function-name \
     --memory-size 1024
   ```

3. **Optimize function code:**
   - Use async operations efficiently
   - Initialize clients outside the handler function
   - Implement caching for repeated operations

4. **Break large functions into smaller ones:**
   - Use Step Functions to orchestrate workflows
   ```bash
   aws stepfunctions create-state-machine \
     --name MyStepFunction \
     --definition '{json-definition}' \
     --role-arn arn:aws:iam::123456789012:role/stepfunctions-role
   ```

## Best Practices for AWS Troubleshooting

### Preparation Before Issues Occur

1. **Set up proper monitoring:**
   ```bash
   # Create CloudWatch dashboard
   aws cloudwatch put-dashboard \
     --dashboard-name MyDashboard \
     --dashboard-body '{...dashboard json...}'
     
   # Configure alarms for critical metrics
   aws cloudwatch put-metric-alarm \
     --alarm-name high-cpu-alarm \
     --metric-name CPUUtilization \
     --namespace AWS/EC2 \
     --statistic Average \
     --period 300 \
     --threshold 80 \
     --comparison-operator GreaterThanThreshold \
     --dimensions Name=InstanceId,Value=i-1234567890abcdef0 \
     --evaluation-periods 2 \
     --alarm-actions arn:aws:sns:region:123456789012:topic-name
   ```

2. **Use Infrastructure as Code for reproducibility:**
   ```bash
   # Deploy CloudFormation template
   aws cloudformation deploy \
     --template-file template.yaml \
     --stack-name my-stack \
     --parameter-overrides Param1=value1 Param2=value2 \
     --capabilities CAPABILITY_IAM
   ```

3. **Implement proper tagging:**
   ```bash
   # Tag resources for easier identification
   aws ec2 create-tags \
     --resources i-1234567890abcdef0 \
     --tags Key=Environment,Value=Production Key=Team,Value=DevOps
   ```

### Methodical Troubleshooting Approach

1. **Gather information:**
   - Identify the scope (single resource or multiple)
   - Check related services and dependencies
   - Review recent changes

2. **Isolate the issue:**
   - Test with minimal configuration
   - Reproduce in a separate environment if possible

3. **Check AWS Service Health Dashboard:**
   ```bash
   # Use AWS CLI to check service health (requires custom script)
   # Or check https://status.aws.amazon.com/
   ```

4. **Use AWS Support when needed:**
   ```bash
   # Create support case via CLI
   aws support create-case \
     --subject "EC2 Instance Connectivity Issue" \
     --service-code amazon-elastic-compute-cloud-linux \
     --category-code system-performance \
     --severity-code urgent \
     --communication-body "Detailed description of the issue"
   ```

---

Remember that AWS troubleshooting requires a combination of AWS-specific knowledge and general systems/networking understanding. The AWS environment is complex with many interdependencies between services, so a methodical, step-by-step approach is essential for effective problem-solving.