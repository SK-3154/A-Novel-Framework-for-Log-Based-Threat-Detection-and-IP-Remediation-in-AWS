# Towards an Automated Defense: Log-Based Threat Detection and IP Remediation in AWS

**Authors:** Suhaib Kashif & Ali Sher Afzal
**Affiliation:** Department of Computer and Software Engineering, Information Technology University (ITU)

---

## 📖 Executive Summary

In the modern threat landscape, speed is as critical as strength. Manual log review creates a dangerous latency gap where attackers operate undetected. This project presents a **serverless, event-driven security framework on AWS** that automates the full lifecycle of **threat detection → decision → remediation**, reducing **Mean Time to Respond (MTTR)** to approximately **1.2 seconds**.

The system ingests **Application Load Balancer (ALB) access logs**, detects malicious patterns in near real time, and **automatically blocks offending IPs** using **Security Groups** and **Network ACLs**, all without human intervention.

---

## 🚀 Key Features

* **Real-Time Detection** — Parses ALB access logs using AWS Lambda as soon as they land in S3.
* **Automated Remediation** — Dynamically updates Security Groups and NACLs to block malicious IPs.
* **Serverless Architecture** — Event-driven design (S3, Lambda, DynamoDB) with zero idle cost.
* **State Management** — DynamoDB table tracks active threats and known malicious actors.
* **Observability** — CloudWatch metrics and dashboards for operational visibility.

---

## 🏗️ Architecture Overview

The system is composed of four logical flows, each with a clearly defined responsibility.

### 🔴 1. Attack Path (Infiltration)

* **Vector:** Malicious HTTP requests (SQLi, XSS) simulated from attacker EC2 instances.
* **Ingress:** Traffic enters through an **Application Load Balancer (ALB)**.
* **Logging:** ALB generates detailed access logs containing source IP, URI, and response codes.

### 🔵 2. Detection Pipeline (Analysis)

* **Trigger:** ALB logs are delivered to an **S3 bucket**.
* **Event:** `s3:ObjectCreated` triggers EventBridge.
* **Processing:** Detection Lambda retrieves and parses the log file.
* **Logic:** Regex-based signature matching (e.g., `UNION SELECT`, `<script>`).
* **Outcome:** Malicious IPs are written to the **Threats DynamoDB table**.

### 🟢 3. Response Pipeline (Mitigation)

* **Trigger:** DynamoDB Streams detect new threat entries.
* **Response Lambda Actions:**

  * **Stateful Control:** Update EC2 Security Group to deny the IP.
  * **Stateless Control:** Update subnet NACL to drop traffic at the network edge.

### 🟡 4. Monitoring Layer (Visibility)

* Metrics and logs are pushed to **Amazon CloudWatch**.
* A custom dashboard displays:

  * Number of threats detected
  * Successful remediations
  * Lambda execution duration and error rates

---

## 🛠️ AWS Services Used

| Service       | Purpose                                                   |
| ------------- | --------------------------------------------------------- |
| EC2           | Hosts vulnerable web application and attacker simulations |
| VPC (SG/NACL) | Network isolation and IP blocking mechanisms              |
| ALB           | Traffic entry point and log generation                    |
| S3            | Centralized log storage and event trigger source          |
| Lambda        | Detection and response logic (Python)                     |
| DynamoDB      | Persistent threat state storage                           |
| CloudWatch    | Monitoring, dashboards, and events                        |

---

---

## 🔐 IAM & Security Model (As Implemented)

This deployment utilizes the pre-provisioned **AWS Learner Lab IAM role (`LabRole`)** as the execution role for both Lambda functions.  
This design choice ensures smooth deployment within the constrained Learner Lab environment while maintaining secure and functional operation.

The assigned role already includes the essential permissions required by the system, including:

- **Amazon DynamoDB access** — to store and retrieve detected threat data  
- **Amazon S3 access** — to read and manage dataset and log objects  
- **AWS Lambda execution permissions** — for serverless function execution  
- **Amazon CloudWatch logging** — for centralized logging, monitoring, and debugging  

This approach enables consistent behavior across deployments while avoiding unnecessary IAM complexity in a sandboxed academic environment.

---



## 📊 Results

* **MTTR:** Reduced from hours to ~**1.2 seconds**
* **Scalability:** Automatically handles traffic spikes via AWS Lambda scaling
* **Cost Efficiency:** Pay-per-execution model with no always-on security servers

---

## 🧪 Deployment Overview

1. Deploy VPC with public subnet, Security Groups, and NACLs
2. Launch EC2 instances (Web App + Attacker Simulator)
3. Configure ALB with access logging enabled
4. Create S3 bucket for ALB logs
5. Deploy Detection Lambda and attach S3 trigger
6. Create DynamoDB Threats table with Streams enabled
7. Deploy Response Lambda triggered by DynamoDB Streams
8. Configure CloudWatch dashboard

---
## 📊 System Benefits

The proposed framework offers the following technical and operational advantages:

- **Automated Threat Processing** — Security threats are detected, recorded, and mitigated without manual intervention.
- **No Always-On Servers** — The system relies entirely on serverless components, eliminating idle infrastructure costs.
- **High Scalability** — AWS Lambda automatically scales with workload, allowing the system to handle varying traffic volumes efficiently.
- **Minimal Operational Overhead** — Infrastructure management and maintenance requirements are significantly reduced.
- **Rapid Response Time** — Event-driven execution enables near real-time threat detection and remediation.
- **Cloud-Native Architecture** — Built entirely on managed AWS services for reliability, availability, and fault tolerance.

---

## 🧬 Infrastructure Management

All infrastructure components are defined, deployed, and maintained using **Terraform**, ensuring full **Infrasructure-as-Code (IaC)** compliance.

The system supports:

- **Version-controlled infrastructure**
- **Reproducible deployments**
- **Safe recovery mechanisms** using Terraform state import
- **Configuration drift reconciliation** to maintain consistency between declared and actual infrastructure

These capabilities enable professional-grade infrastructure lifecycle management and align the project with modern DevOps best practices.

---

## 🔮 Future Enhancements

* **AWS WAF Integration** — Layer 7 blocking with rule-based and managed protections
* **Machine Learning Detection** — Anomaly detection using Amazon SageMaker
* **Multi-Region Defense** — Global threat synchronization across AWS regions

---

## 📄 References

* F. Ullah et al., *Cyber security threats detection in internet of things using deep learning approach*, IEEE Access, 2019.
* Q. Yan et al., *SDN and DDoS Attacks in Cloud Computing Environments*, IEEE, 2016.
* NIST SP 800-61 Rev. 2, *Computer Security Incident Handling Guide*.

---

## 📬 Contact

For questions, collaboration, or academic use, please contact the authors.
