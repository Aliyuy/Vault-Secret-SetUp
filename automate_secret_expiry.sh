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

SSL validation failed for https://sns.us-east-2.amazonaws.com/ [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: self signed certificate in certificate chain (_ssl.c:1129)

 scp -i /home/vault-sbx-us2-key.pem /c/Users/e5688954/Downloads/vault-sbx-ec2-key.pem ec2-user@2-18-217-229-216:~/

Warning: Identity file /home/vault-sbx-us2-key.pem not accessible: No such file or directory.
ssh: Could not resolve hostname 2-18-217-229-216: Name or service not known
scp: Connection closed

scp -i /c/Users/e5688954/Downloads/vault-sbx-us2-key.pem /c/Users/e5688954/Downloads/vault-sbx-ec2-key.pem ec2-user@2.18.217.229.216:~/
chmod 400 /c/Users/e5688954/Downloads/vault-sbx-us2-key.pem


https://careers.fisglobal.com/us/en/c/client-services-jobs
import boto3
import hvac

# Vault configuration
vault_address = 'https://your-vault-address'
vault_token = 'your-vault-token'
vault_secret_path = 'secret/data/your-secret'

# AWS S3 configuration
aws_access_key = 'your-aws-access-key'
aws_secret_key = 'your-aws-secret-key'
s3_bucket_name = 'your-s3-bucket-name'
s3_object_key = 'backup.zip'

# Connect to Vault
vault_client = hvac.Client(url=vault_address, token=vault_token)

# Retrieve the secret from Vault
vault_response = vault_client.read(vault_secret_path)
if vault_response and 'data' in vault_response:
    secret_data = vault_response['data']['data']
else:
    print(f"Error: Unable to retrieve secret from Vault. Response: {vault_response}")
    exit()

# Your backup logic goes here...
# This could include creating a backup of files or a database and storing it in a zip file.

# Create a zip file or use any other method to package your backup data
# For example, if you have a directory to backup, you can use the shutil module:
# import shutil
# shutil.make_archive('backup', 'zip', '/path/to/backup/directory')

# Upload the backup to S3
s3_client = boto3.client('s3', aws_access_key_id=aws_access_key, aws_secret_access_key=aws_secret_key)
with open('backup.zip', 'rb') as backup_file:
    s3_client.upload_fileobj(backup_file, s3_bucket_name, s3_object_key)

print(f"Backup successfully uploaded to S3: s3://{s3_bucket_name}/{s3_object_key}")




       # Download and install Vault
sudo apt-get update
sudo apt-get install -y unzip
wget https://releases.hashicorp.com/vault/{version}/vault_{version}_linux_amd64.zip
unzip vault_{version}_linux_amd64.zip
sudo mv vault /usr/local/bin/

# Verify installation
vault --version


curl -ki -vvv -X POST -H "X-Vault-Token:<VAULT_TOKEN>" --header 'Content-Type: application/json' -d '{"format": "hex"}' https://vault-nlb.rpsstg.awsfisretirement.net/v1/sys/tools/random/32 | jq .


curl -ki -vvv -X POST -H "X-Vault-Token: <VAULT_TOKEN>" --header 'Content-Type: application/json' -d '{"data": {"format": "hex"}}' https://vault-nlb.rpsstg.awsfisretirement.net/v1/sys/tools/random/32 | jq .


 Connection #0 to host vault-nlb.rpsstg.awsfisretirement.net left intact
parse error: Invalid numeric literal at line 1, column 9

{"request_id":"c9066e5e-8fa9-bc5f-91b5-d07274e4a831","lease_id":"","renewable":false,"lease_duration":0,"data":{"random_bytes":"TfVLaLxXFuLHYrlFDXyesl0wig36xQJ6wObgDxmwNmw="},"wrap_info":null,"warnings":null,"auth":null}
* Connection #0 to host vault-nlb.rpsstg.awsfisretirement.net left intact




curl -ki -vvv -X POST -H "X-Vault-Token: <VAULT_TOKEN>" --header 'Content-Type: application/json' -d '{"data": {"format": "hex"}}' https://vault-nlb.rpsstg.awsfisretirement.net/v1/sys/tools/random/32 | grep -oP '"random_bytes":\s*"\K[^"]+'

VAULT_VERSION="1.8.1"  # Replace with the latest version available
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo mv vault /usr/local/bin/
wget https://golang.org/dl/go1.21.5.linux-amd64.tar.gz

sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

export PATH=$PATH:/usr/local/go/bin



ake: *** [check-go-version] Error 1
[root@ip-10-109-42-174 vault]# wget https://golang.org/dl/go1.21.5.linux-amd64.tar.gz
--2024-01-29 19:37:21--  https://golang.org/dl/go1.21.5.linux-amd64.tar.gz
Resolving golang.org (golang.org)... 172.253.122.141, 2607:f8b0:4004:c19::8d
Connecting to golang.org (golang.org)|172.253.122.141|:443... connected.
Unable to establish SSL connection.

wget -q --no-check-certificate https://golang.org/dl/go1.21.5.linux-amd64.tar.gz

[root@ip-10-109-42-174 vault]# wget -q --no-check-certificate https://golang.org/dl/go1.21.5.linux-amd64.tar.gz
[root@ip-10-109-42-174 vault]# tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
tar (child): go1.21.5.linux-amd64.tar.gz: Cannot open: No such file or directory
tar (child): Error is not recoverable: exiting now
tar: Child returned status 2
tar: Error is not recoverable: exiting nowtar -C /usr/local -xzf /path/to/your/home/directory/go1.21.5.linux-amd64.tar.gz




