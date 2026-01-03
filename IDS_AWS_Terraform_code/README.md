# 🛡️ Offline Intrusion Detection System (IDS) on AWS — Terraform Deployment

This project implements an **offline, cloud-based Intrusion Detection System (IDS)** using the **UNSW-NB15 dataset** on AWS.  
The complete cloud infrastructure is deployed and managed using **Terraform**.

This README focuses exclusively on the **code and deployment workflow**, including:

- AWS CLI setup  
- Terraform installation  
- Infrastructure deployment  
- IDS pipeline testing and validation  

---

## 🧱 Project Architecture (Overview)

```

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

````

---

## 🛠 Prerequisites

### 1️⃣ AWS Account

You must have:

- An active AWS account  
- Programmatic credentials (Access Key ID & Secret Access Key)

---

### 2️⃣ Install AWS CLI

#### 🪟 Windows
Download from:  
https://aws.amazon.com/cli/

#### 🐧 Linux / 🍎 macOS

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
````

Verify installation:

```bash
aws --version
```

---

### 3️⃣ Configure AWS CLI

```bash
aws configure
```

Enter:

* **AWS Access Key ID**
* **AWS Secret Access Key**
* **Default region name:** `us-east-1`
* **Default output format:** (press Enter)

Verify configuration:

```bash
aws sts get-caller-identity
```

---

### 4️⃣ Install Terraform

Download Terraform from:
[https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads)

Verify installation:

```bash
terraform -version
```

---

## 📦 Clone the Repository

```bash
git clone https://github.com/SK-3154/A-Novel-Framework-for-Log-Based-Threat-Detection-and-IP-Remediation-in-AWS
```

```bash
cd A-Novel-Framework-for-Log-Based-Threat-Detection-and-IP-Remediation-in-AWS/IDS_AWS_Terraform_code
```

---

## 🚀 Deploy the Infrastructure

Move into the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Preview the deployment:

```bash
terraform plan
```

Apply the deployment:

```bash
terraform apply
```

Type **`yes`** when prompted.

✅ Your complete IDS infrastructure is now deployed on AWS.

---

## 📁 Upload Dataset to S3

From the project root:

```bash
aws s3 cp dataset/UNSW-NB15_1.csv s3://offline-ids-dataset/UNSW-NB15_1.csv
```

Verify upload:

```bash
aws s3 ls s3://offline-ids-dataset/
```

---

## 🧪 Test the IDS Pipeline

### 🔹 Step 1: Create Test Event

Create a file named **`event.json`** in the project root:

```json
{
  "bucket": "offline-ids-dataset",
  "key": "UNSW-NB15_4.csv"
}
```

---

### 🔹 Step 2: Invoke Detection Lambda

```bash
aws lambda invoke \
  --function-name offline_ids_detection \
  --cli-binary-format raw-in-base64-out \
  --payload file://event.json \
  output.json
```

Check result:

```bash
cat output.json
```

Expected output:

```json
{ "statusCode": 200, "detected_ips": 4 }
```

---

### 🔹 Step 3: View Detection Logs

```bash
aws logs tail /aws/lambda/offline_ids_detection --since 10m
```

---

### 🔹 Step 4: View Detected IPs & Attack Types

```bash
aws dynamodb scan --table-name ThreatIPs
```

Example record:

```json
{
  "ip": { "S": "59.166.0.0" },
  "detected_at": { "S": "2026-01-03T14:11:22Z" },
  "attack_category": { "S": "Exploits" },
  "dataset": { "S": "UNSW-NB15-RAW" }
}
```

---

### 🔹 Step 5: Verify Automated Response

Run detection again, then check response logs:

```bash
aws logs tail /aws/lambda/offline_ids_response --since 10m
```

Expected output:

```
=== IDS RESPONSE (DRY-RUN) ===
Malicious IP detected: 59.166.0.0
Attack category: Exploits
Action: This IP WOULD be blocked (WAF / NACL)
```

---

## 🧹 Cleanup Resources

When finished:

```bash
cd terraform
terraform destroy
```

Type **`yes`** to remove all AWS resources.

---

## 🧠 What This Project Demonstrates

* Infrastructure as Code using **Terraform**
* Offline IDS using real **UNSW-NB15 dataset**
* Event-driven cloud security pipeline
* Automated detection and response design
* Secure AWS serverless security architecture

---

## 📌 Notes

This project is designed for **academic and learning purposes**.
Blocking actions are currently **dry-run only** for safety.
Real blocking (AWS WAF / NACL) can be integrated later.

---

## 👨‍💻 Authors

**Ali Sher Afzal**

**Suhaib Kashif**

**Offline IDS on AWS — Terraform Project**
