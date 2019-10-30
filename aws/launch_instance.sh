AMIID=$(aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2" \
       "Name=state,Values=available" --query "reverse(sort_by(Images, &CreationDate))[:1].ImageId" --output text)
VPCID=$(aws ec2 describe-vpcs --filter "Name=isDefault,Values=true" "Name=state,Values=available" \
        --query "Vpcs[0].VpcId" --output text)
SUBNETID=$(aws ec2 describe-subnets --filter "Name=vpc-id,Values=$VPCID" "Name=availability-zone,Values=us-east-1a" \
        "Name=state,Values=available" --query "Subnets[0].SubnetId" --output text)

echo "Default Configuration: AMI ${AMIID}, VPC ${VPCID}, SUBNET ${SUBNETID}"

SG_NAME="my-securitygroup"
SG_DES="HTTP, SSH and PING ECHO"
echo "Start creating Security Group ${SG_NAME}"
SGID=$(aws ec2 create-security-group --group-name ${SG_NAME} --description "${SG_DES}" --vpc-id $VPCID --output text)
echo "Security Group ${SGID} Created"
aws ec2 authorize-security-group-ingress --group-id $SGID \
--protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SGID \
--protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SGID \
--protocol tcp --port 443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $SGID \
--protocol icmp --port 8 --cidr 0.0.0.0/0
echo "Authorize in-bound policy for ${SGID} security group"

INSTANCEID=$(aws ec2 run-instances --image-id $AMIID --key-name mykey --instance-type t2.micro --security-group-ids $SGID \
             --subnet-id $SUBNETID --user-data file://$HOME/scripts/aws/test.sh --query "Instances[0].InstanceId" --output text)

echo "Waiting for instance ${INSTANCEID}"

aws ec2 wait instance-running --instance-ids $INSTANCEID

DOMAINNAME=$(aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].PublicDnsName" \
             --output text)

VOLUMEID=$(aws ec2 describe-volumes --filter "Name=availability-zone,Values=us-east-1a" \
           --query "Volumes[0].VolumeId" --output text)

if [[ -n "$VOLUMEID" ]]; then
    aws ec2 attach-volume --volume-id $VOLUMEID --instance-id $INSTANCEID --device /dev/sdf
    echo "Attach Volume ${VOLUMEID} to Instance ${INSTANCEID}"
else
    echo "Volume not found in us-east-1a"
fi

echo "${INSTANCEID} accepting SSH connection under ${DOMAINNAME}"
echo "ssh -i mykey.pem ec2-user@${DOMAINNAME}"
read -p "Press [Enter] key to terminate ${INSTANCEID} .."

aws ec2 terminate-instances --instance-id $INSTANCEID
echo "terminating instance $INSTANCEID"
aws ec2 wait instance-terminated --instance-ids $INSTANCEID
aws ec2 delete-security-group --group-id $SGID
echo "delete security group ${SGID}"
echo "finished"
