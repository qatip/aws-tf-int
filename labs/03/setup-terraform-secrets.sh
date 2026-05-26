#!/bin/bash
set -euo pipefail

AWS_REGION="us-east-1"
IAM_USER="terraform-user"
SECRET_NAME="terraform-aws-credentials"
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      AWS_REGION="$2"
      shift 2
      ;;
    --user-name)
      IAM_USER="$2"
      shift 2
      ;;
    --secret-id|--secret-name)
      SECRET_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--region us-east-1] [--user-name terraform-user] [--secret-id terraform-aws-credentials]"
      exit 1
      ;;
  esac
done

echo "Using region: $AWS_REGION"
echo "Using IAM user: $IAM_USER"
echo "Using secret name: $SECRET_NAME"

echo "Checking whether IAM user exists..."
if aws iam get-user --user-name "$IAM_USER" >/dev/null 2>&1; then
  echo "IAM user already exists: $IAM_USER"
else
  echo "Creating IAM user: $IAM_USER"
  aws iam create-user --user-name "$IAM_USER" >/dev/null
fi

echo "Attaching policy: $POLICY_ARN"
aws iam attach-user-policy \
  --user-name "$IAM_USER" \
  --policy-arn "$POLICY_ARN"

echo "Creating new access key..."
CREDS=$(aws iam create-access-key --user-name "$IAM_USER")

ACCESS_KEY=$(echo "$CREDS" | jq -r '.AccessKey.AccessKeyId')
SECRET_KEY=$(echo "$CREDS" | jq -r '.AccessKey.SecretAccessKey')

SECRET_STRING=$(jq -n \
  --arg access_key "$ACCESS_KEY" \
  --arg secret_key "$SECRET_KEY" \
  --arg region "$AWS_REGION" \
  '{
    aws_access_key_id: $access_key,
    aws_secret_access_key: $secret_key,
    region: $region
  }'
)

echo "Creating or updating Secrets Manager secret..."
if aws secretsmanager describe-secret --secret-id "$SECRET_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "Secret already exists. Updating secret value..."
  aws secretsmanager put-secret-value \
    --secret-id "$SECRET_NAME" \
    --secret-string "$SECRET_STRING" \
    --region "$AWS_REGION" >/dev/null
else
  echo "Creating new secret..."
  aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --secret-string "$SECRET_STRING" \
    --region "$AWS_REGION" >/dev/null
fi

echo
echo "Terraform AWS credentials stored successfully."
echo "Secret name: $SECRET_NAME"
echo "IAM user: $IAM_USER"
echo
echo "You can retrieve the credentials with:"
echo "aws secretsmanager get-secret-value --secret-id $SECRET_NAME --region $AWS_REGION"