# 🏛️ OctaByte Cloud Architecture & Data Flow Reference

**Company**: Octa Byte AI Pvt Ltd  
**Platform**: AWS Cloud & GitHub Actions CI/CD  
**Author**: Senior DevOps Engineering Team  

---

## 1. High-Level System Infrastructure Architecture

```text
                                   🌐 INTERNET
                                       │
                                       │ HTTP (Port 80) / HTTPS (Port 443)
                                       ▼
                     ┌───────────────────────────────────┐
                     │   Application Load Balancer (ALB) │
                     └─────────────────┬─────────────────┘
                                       │
                ┌──────────────────────┴──────────────────────┐
                │ Private Subnets (Multi-AZ)                  │
                ▼                                             ▼
  ┌───────────────────────────┐                 ┌───────────────────────────┐
  │  ECS Fargate Task 1       │                 │  ECS Fargate Task 2       │
  │  (octabyte-app:3000)      │                 │  (octabyte-app:3000)      │
  └─────────────┬─────────────┘                 └─────────────┬─────────────┘
                │                                             │
                └──────────────────────┬──────────────────────┘
                                       │ PostgreSQL (Port 5432)
                                       ▼
                     ┌───────────────────────────────────┐
                     │   AWS RDS PostgreSQL (Private DB) │
                     │   (Encrypted at Rest, KMS)        │
                     └───────────────────────────────────┘
```

---

## 2. Continuous Integration & Deployment (CI/CD) Architecture

```text
┌──────────────────────┐
│  GitHub Repository   │
│  (Pull Request / Main)│
└──────────┬───────────┘
           │ Trigger Workflow
           ▼
┌────────────────────────────────────────────────────────────────────────┐
│                        GitHub Actions Pipeline                         │
│                                                                        │
│  1. Unit & Integration Tests (npm test)                                │
│  2. Terraform Format & Validation (terraform validate)                │
│  3. Docker Image Build (octabyte-app:${GITHUB_SHA})                    │
│  4. Trivy Container Vulnerability Scan                                 │
│  5. AWS OIDC Auth via STS AssumeRole                                   │
└──────────┬─────────────────────────────────────────────────────────────┘
           │ Push Built Docker Image Tag
           ▼
┌──────────────────────────────┐
│  Amazon ECR Repository       │
│  (octabyte-staging-app)      │
└──────────┬───────────────────┘
           │
           │ Deploy Updated Task Definition
           ▼
┌──────────────────────────────┐          Manual Approval          ┌──────────────────────────────┐
│  ECS Staging Cluster         ├──────────────────────────────────►│  ECS Production Cluster      │
│  (1 Task, Single NAT GW)     │       (GitHub Environment)        │  (2 Tasks, Multi-AZ NAT GW)  │
└──────────────────────────────┘                                   └──────────────────────────────┘
```

---

## 3. Monitoring, Metrics & Centralized Logging Architecture

```text
 ┌───────────────────────────┐                  ┌───────────────────────────┐
 │   ECS Container Instance  │                  │   ECS Container stdout    │
 └─────────────┬─────────────┘                  └─────────────┬─────────────┘
               │                                              │
               │ Scrape /metrics (Port 3000)                  │ awslogs Log Driver
               ▼                                              ▼
 ┌───────────────────────────┐                  ┌───────────────────────────┐
 │   Prometheus Server       │                  │   AWS CloudWatch Logs     │
 │   (Scrapes every 15s)     │                  │   (/ecs/octabyte-app)     │
 └─────────────┬─────────────┘                  └───────────────────────────┘
               │
               │ Data Source Query
               ▼
 ┌───────────────────────────┐
 │   Grafana Dashboards      │
 │   - Infra Overview        │
 │   - App RED Metrics       │
 │   - Database Metrics      │
 └───────────────────────────┘
```

---

## 4. Secrets Injection & Security Flow Architecture

```text
 ┌──────────────────────────────────────┐
 │  AWS Secrets Manager                 │
 │  (octabyte-staging-db-credentials)   │
 └──────────────────┬───────────────────┘
                    │
                    │ Encrypted Secret ARN
                    ▼
 ┌──────────────────────────────────────┐
 │  ECS Task Execution Role             │
 │  Policy: secretsmanager:GetSecretValue│
 └──────────────────┬───────────────────┘
                    │
                    │ Inject DB_PASSWORD at runtime
                    ▼
 ┌──────────────────────────────────────┐
 │  ECS Fargate Container Task          │
 │  Env: DB_HOST, DB_NAME, DB_USER      │
 │  Secret: DB_PASSWORD (from SM)       │
 └──────────────────────────────────────┘
```

---

## 5. Security & Network Isolation Layers

| Layer | Component | Security Control | Access Restriction |
| :--- | :--- | :--- | :--- |
| **Edge / Public** | ALB | ALB Security Group | Ingress `80/443` from `0.0.0.0/0` |
| **Compute** | ECS Fargate | ECS Security Group | Ingress port `3000` **ONLY** from ALB SG |
| **Database** | RDS PostgreSQL | RDS Security Group | Ingress port `5432` **ONLY** from ECS SG |
| **Secrets** | Secrets Manager | IAM Role Policy | `GetSecretValue` allowed **ONLY** for Task Execution Role |
| **Identity** | AWS Auth | GitHub OIDC Provider | Short-lived STS AssumeRole tokens |
