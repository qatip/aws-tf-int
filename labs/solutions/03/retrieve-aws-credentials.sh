#!/bin/bash

# Define Variables
AWS_REGION="us-east-1"
SECRET_NAME="terraform-aws-credentials"
ENV_FILE="aws_credentials.env"

# Retrieve credentials from AWS Secrets Manager
CREDS=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query SecretString --output text)

# Extract values using jq
ACCESS_KEY=$(echo $CREDS | jq -r '.aws_access_key_id')
SECRET_KEY=$(echo $CREDS | jq -r '.aws_secret_access_key')

# Export environment variables for Terraform
export AWS_ACCESS_KEY_ID=$ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$SECRET_KEY

# Save to .env file
echo "AWS_ACCESS_KEY_ID=$ACCESS_KEY" > $ENV_FILE
echo "AWS_SECRET_ACCESS_KEY=$SECRET_KEY" >> $ENV_FILE

echo "AWS credentials have been set for Terraform authentication and stored in $ENV_FILE."
