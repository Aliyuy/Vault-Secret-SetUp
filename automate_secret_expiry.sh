# 1- Enable the Key-Value Secrets Engine:

#Enable the Key-Value (KV) secrets engine. For example, enable version 2:

vault secrets enable -path=secrets kv-v2

# 2- Configure AWS Secrets Engine:
#Enable the AWS Secrets Engine and configure it with appropriate AWS credentials:

vault secrets enable -path=aws aws
vault write aws/config/root access_key=YOUR_AWS_ACCESS_KEY secret_key=YOUR_AWS_SECRET_KEY region=us-east-1

# 3- Create AWS IAM Role in Vault:
#Create an AWS IAM role in Vault that will be used for dynamic AWS credentials:

vault write aws/roles/my-role \
  credential_type=iam_user \
  policy_document=-<<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "ec2:DescribeInstances",
        "Resource": "*"
      }
    ]
  }
  EOF
  
  vault write aws/roles/my-role credential_type=iam_user policy_document="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"ec2:DescribeInstances\",\"Resource\":\"*\"}]}"

  vault write aws/roles/my-role \
  credential_type=iam_user \
  policy_document="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"ec2:DescribeInstances\",\"Resource\":\"*\"}]}"

# 4- Write a Secret to Vault: Write a Secret with Expiration Date
#Store your secret in Vault with an associated expiration date. For example:

vault kv put secrets/my-secret my-key=my-value expire_time=$(date -d "7 days" -u +"%Y-%m-%dT%H:%M:%SZ")

#Set Up AWS SNS for Email Notifications
# 5- Create an SNS Topic:
#Create an SNS topic to which the email notifications will be published:

aws sns create-topic --name VaultSecretExpiration

# 6- Subscribe to the SNS Topic:
#Subscribe your email address (or the email address of the recipient) to the SNS topic:

aws sns subscribe --topic-arn YOUR_SNS_TOPIC_ARN --protocol email --notification-endpoint YOUR_EMAIL_ADDRESS

#Create a Script to Check Expiration and Trigger Notification
# 7- Create a Script:
#Create a script (e.g., check_secret_expiry.sh) that checks the expiration time and triggers an email notification using AWS SNS.

#!/bin/bash

# Set your AWS region
AWS_REGION="us-east-1"

# Set your AWS SNS topic ARN
SNS_TOPIC_ARN="YOUR_SNS_TOPIC_ARN"

# Get the expiration time from Vault
expire_time=$(vault kv get -format=json secrets/my-secret | jq -r '.data.data.expire_time')

# Calculate the time 7 days before expiration
notify_time=$(date -d "$expire_time - 7 days" "+%Y-%m-%dT%H:%M:%SZ")

# Get the current time
current_time=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

if [ "$current_time" == "$notify_time" ]; then
  # Send an email notification using AWS SNS
  aws sns publish --topic-arn $SNS_TOPIC_ARN --message "The secret is expiring in 7 days. Please take action."
fi

# 8- Make the Script Executable:
#Make the script executable:

chmod +x check_secret_expiry.sh

#Schedule the Script Execution
# 9- Schedule with Cron:
#Add a cron job to schedule the script execution. Open the crontab for editing:

crontab -e

# 10- Add a line to run the script daily:

0 0 * * * /path/to/check_secret_expiry.sh

#Run the Script Manually:
#Run the script manually to ensure it correctly calculates the notification time and triggers the email notification using AWS SNS.
#Wait for Scheduled Execution:
#Wait for the scheduled cron job to execute and verify that the email notification is sent when the secret is about to expire.

# Download the latest version of Vault
curl -O https://releases.hashicorp.com/vault/$(curl -s https://releases.hashicorp.com/vault/ | grep -E 'href.*vault_[0-9]' | sed -E 's/.*href="([^"]+)".*/\1/' | head -n 1)

# Install Vault
sudo unzip vault_*_linux_amd64.zip -d /usr/local/bin# Replace VERSION with the desired Vault version, e.g., 1.8.2
export VAULT_VERSION=1.8.2
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin

# Replace VERSION with the desired Vault version, e.g., 1.8.2
export VAULT_VERSION=1.8.2

# Download the Vault binary
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

# Unzip and install Vault
unzip vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin




Error enabling: Post "https://vault-test2.fsndbx.net/v1/sys/mounts/secrets": dial tcp: lookup vault-test2.fsndbx.net on 10.108.116.2:53: no such host


