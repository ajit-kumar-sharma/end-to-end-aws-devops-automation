# 🎯 Technical Approach & Architectural Decision Record (ADR)

**Project Name**: OctaByte AWS DevOps Microservice Architecture  
**Company**: Octa Byte AI Pvt Ltd  
**Author**: DevOps Engineering Team  

---

## 1. Executive Overview

This document presents the technical justifications and engineering rationale behind the design and implementation of the OctaByte cloud platform on AWS.

---

## 2. Infrastructure Component Decisions

### Why AWS ECS Fargate over EKS / Kubernetes?
* **Lower Operational Overhead**: ECS Fargate is a serverless compute engine for containers. It eliminates the need to provision, patch, or manage EC2 instances or Kubernetes control planes (etcd, API servers, worker nodes).
* **Cost Efficiency for Assignment Workloads**: EKS requires a $0.10/hour ($72/month) control plane fee per cluster regardless of workload. ECS Fargate charges only for exact CPU and memory consumed during task execution.
* **Seamless AWS Integration**: Built-in support for AWS IAM roles for tasks, CloudWatch Logs, AWS Secrets Manager dynamic injection, and ALB Target Group IP routing (`awsvpc` network mode).

### Why Application Load Balancer (ALB) over Network Load Balancer (NLB)?
* **Layer 7 Traffic Routing**: ALB operates at Layer 7 (HTTP/HTTPS), providing HTTP health check monitoring (`/health` returning 200 OK), path-based routing, header matching, and SSL/TLS termination.
* **Container Integration**: Native integration with ECS Fargate services to dynamically add and remove container IP targets during zero-downtime rolling deployments.

### Why Private RDS PostgreSQL over Self-Hosted Postgres on EC2?
* **Zero Public Exposure**: Placed strictly in private subnets with Security Groups allowing port `5432` ingress exclusively from the ECS Security Group.
* **Managed Operational Excellence**: Automated multi-AZ failover (production), automated daily backups (7–14 day retention), storage auto-scaling (20GB -> 100GB gp3), and storage encryption at rest using AWS KMS.

---

## 3. Deployment & Secrets Management Decisions

### Why GitHub Actions + AWS OIDC Authentication?
* **Security Compliance**: Short-lived, temporary credentials issued via AWS Security Token Service (STS) using OpenID Connect (OIDC).
* **No Long-Lived AWS Keys**: Eliminates storing `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in GitHub repository secrets, mitigating credential leak risks.

### Why AWS Secrets Manager for DB Credentials?
* **Zero Plaintext Secrets**: Eliminates hardcoded passwords in Git, Terraform state variables, or container env vars.
* **Dynamic Runtime Injection**: Secrets Manager secret values are injected directly into container environment variables at Fargate task startup using the ECS Task Execution Role (`secretsmanager:GetSecretValue`).

### Why Amazon ECR with Image Scanning & Lifecycle Rules?
* **Native AWS Security**: Built-in image vulnerability scanning on push using Clair/Trivy rules.
* **Cost Control**: Automated lifecycle policy to purge untagged container builds while retaining the latest 10 production release tags.

---

## 4. Monitoring & Observability Decisions

### Why Prometheus & Grafana?
* **Standardized Microservice Metrics**: Express app exposes `/metrics` formatted with standard `prom-client` metrics (`http_requests_total`, `http_request_duration_seconds`, `db_query_duration_seconds`).
* **Visual Dashboards**: Automated provisioning of Grafana dashboards for Infrastructure Overview, RED Metrics (Rate, Error, Duration), and Database performance.

### Why AWS CloudWatch Logs?
* **Centralized Container Logging**: ECS task definitions use `awslogs` driver sending stdout/stderr to `/ecs/octabyte-staging-app` and `/ecs/octabyte-production-app` with 14-day retention.

---

## 5. Environment Separation & Security Model

* **Staging vs. Production**:
  * `Staging`: 1 Fargate task, Single NAT Gateway (cost optimization), DB single-AZ, final snapshot skipped on teardown.
  * `Production`: 2+ Fargate tasks (high availability), Multi-AZ NAT Gateways, Multi-AZ RDS, mandatory manual approval gate in GitHub Actions (`environment: production`), final snapshot enforced.
