#!/bin/bash

# Define Variables
AWS_REGION="us-east-1"
IAM_USER="terraform-user"
SECRET_NAME="terraform-aws-credentials"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/terraform-user-policy"

# Create an IAM user
aws iam create-user --user-name $IAM_USER

# Attach necessary permissions
aws iam attach-user-policy --user-name $IAM_USER --policy-arn $POLICY_ARN

# Create Access Keys
CREDS=$(aws iam create-access-key --user-name $IAM_USER)

# Extract Access Key and Secret Key
ACCESS_KEY=$(echo $CREDS | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo $CREDS | jq -r '.AccessKey.SecretAccessKey')

# Store in AWS Secrets Manager
if aws secretsmanager describe-secret --secret-id $SECRET_NAME --region $AWS_REGION >/dev/null 2>&1; then
	aws secretsmanager put-secret-value --secret-id $SECRET_NAME --secret-string "{\"aws_access_key_id\":\"$ACCESS_KEY\", \"aws_secret_access_key\":\"$SECRET_KEY\"}" --region $AWS_REGION
else
	aws secretsmanager create-secret --name $SECRET_NAME --secret-string "{\"aws_access_key_id\":\"$ACCESS_KEY\", \"aws_secret_access_key\":\"$SECRET_KEY\"}" --region $AWS_REGION
fi

echo "AWS credentials stored in Secrets Manager under secret name: $SECRET_NAME"