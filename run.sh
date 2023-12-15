#!/bin/bash

# You need to replace it with your own aws profile name
AWS_PROFILE=admin-master
# The region of S3, you may need to replace it
REGION=ap-east-1
# Set your AWS S3 bucket name and CloudFormation stack names
S3_BUCKET_NAME=vps-fhqou3bjdshobo84
# Your email address for receiving notification
SNSSubsciptionEmail=example@email.com

VPS_INFRASTRUCTURE_STACK=vps-infrastructure
VPS_INSTANCE_STACK=vps-instance

case "$1" in
  "init")
    # Upload files to S3 bucket
    aws s3api create-bucket --bucket $S3_BUCKET_NAME --region $REGION --create-bucket-configuration LocationConstraint=$REGION --profile $AWS_PROFILE
    aws s3 cp ./cf_init.yaml s3://$S3_BUCKET_NAME/  --region $REGION --profile $AWS_PROFILE
    aws s3 cp ./cf_vps.yaml s3://$S3_BUCKET_NAME/  --region $REGION --profile $AWS_PROFILE

    # Create vpc, subnet and other resources
    aws cloudformation create-stack \
      --stack-name $VPS_INFRASTRUCTURE_STACK \
      --template-url https://$S3_BUCKET_NAME.s3.$REGION.amazonaws.com/cf_init.yaml \
      --capabilities CAPABILITY_NAMED_IAM \
      --parameters ParameterKey=SNSSubsciptionEmail,ParameterValue=$SNSSubsciptionEmail \
      --region $REGION \
      --profile $AWS_PROFILE
    ;;

  "deploy")
    # Create VPS
    aws cloudformation create-stack \
      --stack-name $VPS_INSTANCE_STACK \
      --template-url https://$S3_BUCKET_NAME.s3.$REGION.amazonaws.com/cf_vps.yaml \
      --region $REGION \
      --profile $AWS_PROFILE
    ;;

  "delete")
    # Create VPS
    aws cloudformation delete-stack \
      --stack-name $VPS_INSTANCE_STACK \
      --region $REGION \
      --profile $AWS_PROFILE
    ;;

  "clean")
    # Delete the S3 bucket
    aws s3 rb s3://$S3_BUCKET_NAME --force --region $REGION --profile $AWS_PROFILE

    aws cloudformation delete-stack \
      --stack-name $VPS_INFRASTRUCTURE_STACK \
      --region $REGION \
      --profile $AWS_PROFILE
    ;;
    
  *)
    echo "Usage: $0 {init|deploy|delete|clean}"
    exit 1
    ;;
esac

exit 0
