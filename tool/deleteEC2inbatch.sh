#! /bin/sh
# 批量删除Region下的所有EC2，仅用于清理账号，切勿随便使用
for line in $(aws ec2 describe-instances  --query 'Reservations[].Instances[].{Instance:InstanceId}' --output text)
do
aws ec2 terminate-instances --instance-ids   $line;
done;