#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="us-east-1"
SECRET_NAME="terraform-aws-credentials"
ENV_FILE="aws_credentials.env"

# Retrieve credentials from AWS Secrets Manager
CREDS=$(aws secretsmanager get-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --query 'SecretString' \
  --output text)

# Extract values using jq
ACCESS_KEY=$(echo "$CREDS" | jq -r '.aws_access_key_id')
SECRET_KEY=$(echo "$CREDS" | jq -r '.aws_secret_access_key')

# Validate values
if [[ -z "$ACCESS_KEY" || "$ACCESS_KEY" == "null" || -z "$SECRET_KEY" || "$SECRET_KEY" == "null" ]]; then
  echo "Failed to extract credentials from secret: $SECRET_NAME"
  exit 1
fi

# Export environment variables for Terraform
export AWS_ACCESS_KEY_ID="$ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$SECRET_KEY"

# Save to env file
echo "export AWS_ACCESS_KEY_ID=\"$ACCESS_KEY\"" > "$ENV_FILE"
echo "export AWS_SECRET_ACCESS_KEY=\"$SECRET_KEY\"" >> "$ENV_FILE"

echo "AWS credentials have been set for Terraform authentication and stored in $ENV_FILE."