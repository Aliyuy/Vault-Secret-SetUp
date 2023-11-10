#check_secret_expiry.sh
#!/bin/bash

secret_data=$(vault kv get -format=json secrets/my-secret)

# Extract the expiration time from the secret
expiration_time=$(echo $secret_data | jq -r .data.data.expire_time)

# Calculate the time 7 days before expiration
notify_time=$(date -d "$expiration_time - 7 days" "+%Y-%m-%dT%H:%M:%SZ")

# Get the current time
current_time=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

if [ "$current_time" == "$notify_time" ]; then
  # Send an email notification here
  # (Replace the following line with your email notification logic)
  echo "The secret is expiring in 7 days. Please take action." | mail -s "Secret Expiration Reminder" your@email.com
fi



#automate_secret_expiry.sh

#!/bin/bash

# Set your Vault address
VAULT_ADDR="https://your-vault-address"

# Set AWS region
AWS_REGION="your-aws-region"

# Set your AWS credentials
AWS_ACCESS_KEY="your-aws-access-key"
AWS_SECRET_KEY="your-aws-secret-key"

# Set the path to your script that checks secret expiry and sends email
CHECK_EXPIRY_SCRIPT_PATH="/path/to/check_secret_expiry.sh"

# Function to check if a Vault token is present or obtain a new one
get_vault_token() {
    if [[ -z "${VAULT_TOKEN}" ]]; then
        # Authenticate to Vault and set the token
        VAULT_TOKEN=$(vault login -method=aws role=my-role -format=json | jq -r '.auth.client_token')
        export VAULT_TOKEN
    fi
}

# Function to write a secret to Vault with an expiration date
write_secret_to_vault() {
    vault kv put secrets/my-secret my-key=my-value expire_time=$(date -d "7 days" -u +"%Y-%m-%dT%H:%M:%SZ")
}

# Function to schedule a cron job for checking secret expiration and sending email
schedule_cron_job() {
    # Add a cron job to run the expiration check script
    (crontab -l ; echo "0 0 * * * ${CHECK_EXPIRY_SCRIPT_PATH}") | crontab -
}

# Function to set up AWS SES for email notifications
configure_aws_ses() {
    # Configure AWS SES for email notifications
    aws ses create-receipt-rule-set --rule-set-name vault-email-notifications
    aws ses create-receipt-rule --rule-set-name vault-email-notifications \
        --rule-name vault-email-rule \
        --enabled \
        --recipients "recipient@example.com" \
        --actions S3Action="{BucketName=vault-email-logs,objectkeyprefix=email/}"
}

# Main Script

# Set AWS CLI credentials
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_KEY}"
export AWS_DEFAULT_REGION="${AWS_REGION}"

# Set Vault address
export VAULT_ADDR="${VAULT_ADDR}"

# Authenticate to Vault
get_vault_token

# Write a secret to Vault with an expiration date
write_secret_to_vault

# Schedule a cron job for checking secret expiration and sending email
schedule_cron_job

# Configure AWS SES for email notifications
configure_aws_ses

# Clean up environment variables
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION
unset VAULT_ADDR
unset VAULT_TOKEN

echo "Script execution completed successfully."


#chmod +x automate_secret_expiry.sh
#chmod +x check_secret_expiry.sh

#./check_secret_expiry.sh
#./automate_secret_expiry.sh


# Create s3 on cli: aws s3api create-bucket --bucket vault-email-logs --region your-aws-region

