# Offline Intrusion Detection System (IDS) on AWS — Terraform Deployment

This project implements an **offline, cloud‑based Intrusion Detection System (IDS)** using the **UNSW‑NB15 dataset** on AWS.  
The entire infrastructure is deployed using **Terraform**.

This README explains **only the code & deployment process**:
- How to set up AWS CLI
- How to install Terraform
- How to deploy the project
- How to test the IDS pipeline

---

## 🧱 Project Architecture (Summary)

Dataset (S3)
↓
Detection Lambda
↓
DynamoDB (ThreatIPs)
↓
DynamoDB Streams
↓
Response Lambda
↓
CloudWatch Logs

---

## 🛠 Prerequisites

### 1. AWS Account
You must have:
- An AWS account
- Access keys (Access Key ID & Secret Access Key)

### 2. Install AWS CLI

#### Windows
- Download: https://aws.amazon.com/cli/

#### Linux / Mac
- curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip

- unzip awscliv2.zip
- sudo ./aws/install

Verify

- aws --version

---
### 3. Configure AWS CLI

aws configure
- Enter:

- AWS Access Key ID:
- AWS Secret Access Key:
- Default region name: us-east-1
- Default output format: 

Verify:
- aws sts get-caller-identity
### 4. Install Terraform
Download from: https://developer.hashicorp.com/terraform/downloads

Verify:

terraform -version
📦 Clone the Repository

git clone https://github.com/SK-3154/A-Novel-Framework-for-Log-Based-Threat-Detection-and-IP-Remediation-in-AWS

#### cd A-Novel-Framework-for-Log-Based-Threat-Detection-and-IP-Remediation-in-AWS/IDS_AWS_Terraform_code

🚀 Deploy the Infrastructure
Move into the Terraform directory:

- cd terraform

Initialize Terraform:
- terraform init

Preview the deployment:
- terraform plan

Apply the deployment:
- terraform apply

Type yes when prompted.

When complete, your entire AWS infrastructure is live.

📁 Upload Dataset to S3
From the project root:

#### aws s3 cp dataset/UNSW-NB15_1.csv s3://offline-ids-dataset/UNSW-NB15_1.csv
Verify:
#### aws s3 ls s3://offline-ids-dataset/
### 🧪 Test the IDS Pipeline

#### Step 1: Create test event file

#### Create a file named event. in the project root:

{
  "bucket": "offline-ids-dataset",
  "key": "UNSW-NB15_1.csv"
}


#### Step 2: Invoke Detection Lambda


aws lambda invoke \
  --function-name offline_ids_detection \
  --cli-binary-format raw-in-base64-out \
  --payload file://event. \
  output.

#### Check result:
cat output.

Expected output example:

{ "statusCode": 200, "detected_ips": 4 }

#### Step 3: View Detected IPs & Attack Types


aws dynamodb scan --table-name ThreatIPs

Example record:

{
  "ip": { "S": "59.166.0.0" },
  "detected_at": { "S": "2026-01-03T14:11:22Z" },
  "attack_category": { "S": "Exploits" },
  "dataset": { "S": "UNSW-NB15-RAW" }
}

#### Step 4: Verify Automated Response

After running detection again:

aws logs tail /aws/lambda/offline_ids_response --since 10m

Expected logs:


=== IDS RESPONSE (DRY-RUN) ===
Malicious IP detected: 59.166.0.0

Attack category: Exploits

Action: This IP WOULD be blocked (WAF / NACL)


### 🧹 Cleanup Resources

#### When finished:

- cd terraform

- terraform destroy

Type yes to remove all AWS resources.

## 🧠 What This Project Demonstrates
- Infrastructure as Code using Terraform

- Offline IDS using real UNSW‑NB15 dataset

- Event‑driven cloud security pipeline

- Automated detection & response design

- AWS serverless security architecture

### 📌 Notes
This project is designed for learning & academic demonstration.

Blocking actions are currently dry‑run only for safety.

Real blocking (AWS WAF / NACL) can be added later.

## 👨‍💻 Author
### Ali Sher Afzal
### Suhaib Kashif
### Offline IDS on AWS — Terraform Project


---