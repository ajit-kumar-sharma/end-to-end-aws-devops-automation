# 🛠️ Engineering Challenges & Technical Resolutions Document

**Applicant Name**: Ajit Kumar Sharma  
**Target Role**: DevOps Engineer at 8Byte.ai  
**Assignment**: Technical Assignment Round  

---

## 📌 Executive Summary
During the end-to-end design, infrastructure provisioning, CI/CD pipeline automation, and monitoring setup for the 8Byte DevOps microservice, several complex cloud and container engineering challenges were encountered. This document outlines the 5 key challenges faced and the engineering resolutions implemented.

---

## 1. Challenge: Zero-Downtime ECS Fargate Task Updates with Database Dependency
### Problem:
When deploying a new container revision to ECS Fargate, new tasks were being launched before database migrations/tables were guaranteed to be ready, leading to initial 500 errors on incoming requests.

### Resolution:
- Configured ECS Service Deployment Controls in Terraform (`deployment_minimum_healthy_percent = 50` and `deployment_maximum_percent = 200`).
- Implemented an idempotent database initialization check (`initDb()` with `CREATE TABLE IF NOT EXISTS`) in the Express app startup lifecycle.
- Configured ALB Target Group health checks to monitor `/health`, which explicitly verifies PostgreSQL connection status before marking the task healthy and routing live traffic.

---

## 2. Challenge: High Egress NAT Gateway Costs in AWS Multi-AZ VPC
### Problem:
Provisioning separate NAT Gateways across multiple Availability Zones in non-production environments (Dev/Staging) significantly inflates AWS monthly infrastructure costs (~$32 per NAT Gateway per month + data charges).

### Resolution:
- Parameterized NAT Gateway creation in the Terraform `vpc` module.
- For `dev` and `staging`, configured a single shared NAT Gateway across subnets, while maintaining multi-AZ subnets for high availability compute.
- Documented how production Terraform configurations toggle multi-NAT Gateways for full zone redundancy.

---

## 3. Challenge: Secure Handling of PostgreSQL Credentials across CI/CD and ECS
### Problem:
Hardcoding database credentials in container environment variables or Git commits poses severe security risks. Conversely, fetching secrets at build time bakes sensitive data into Docker image layers.

### Resolution:
- Utilized **AWS Secrets Manager** for database credentials.
- Integrated IAM Task Execution Roles in ECS with least privilege permissions to pull secrets dynamically at task startup (`valueFrom` ARNs).
- Used GitHub Secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `SLACK_WEBHOOK_URL`) in GitHub Actions workflows to ensure zero plaintext credential leakage.

---

## 4. Challenge: Prometheus Metrics Scraping in Dynamic Fargate Container Environments
### Problem:
In AWS ECS Fargate, container IP addresses are ephemeral and dynamically change on every deployment. Static Prometheus target IP configurations fail as tasks scale up/down.

### Resolution:
- In production, implemented AWS CloudWatch Container Insights combined with CloudWatch Prometheus Agent sidecars using AWS Service Discovery (Cloud Map DNS).
- For the local environment, utilized Docker Compose service DNS (`app:3000`) and configured Prometheus dynamic target scraping with `prom-client` custom RED metrics.

---

## 5. Challenge: Vulnerability Scanning in CI/CD without Breaking Builds on Low-Severity CVEs
### Problem:
Running strict container vulnerability scanners (like Trivy or Snyk) during PR checks can cause builds to fail due to unfixable, low-severity upstream OS package vulnerabilities in standard base images.

### Resolution:
- Adopted `node:20-alpine` as a minimal base image to reduce attack surface by over 80%.
- Configured the Trivy scanner step in GitHub Actions with `--severity CRITICAL,HIGH` and `--ignore-unfixed true`.
- This ensures developers are alerted immediately to critical actionable vulnerabilities without blocking CI pipelines on unpatchable OS-level informational warnings.
