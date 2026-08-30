# 🚀 OctaByte AI AWS DevOps Practical Assignment Solution

Production-grade, end-to-end AWS DevOps cloud architecture for **Octa Byte AI Pvt Ltd**. Demonstrates automated infrastructure provisioning via Terraform, continuous deployment using GitHub Actions with AWS OIDC, container security with Trivy, real AWS Secrets Manager integration, and Prometheus/Grafana monitoring.

---

## 1. Project Title
**OctaByte AI Production-Grade AWS DevOps Microservice Architecture**

---

## 2. Project Overview
This repository delivers an automated, secure, and observable cloud platform on AWS hosting a high-performance Node.js microservice backed by Amazon RDS PostgreSQL. It implements multi-environment isolation (Staging vs. Production), least-privilege zero-trust security groups, automated container vulnerability scanning, non-root Docker builds, dynamic secret injection, remote Terraform state locking, and comprehensive RED/Infrastructure monitoring dashboards.

---

## 3. Architecture Diagram

```text
                                   🌐 INTERNET
                                       │
                                       │ HTTP 80 / HTTPS 443
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
                                       │ PostgreSQL 5432
                                       ▼
                     ┌───────────────────────────────────┐
                     │   AWS RDS PostgreSQL (Private DB) │
                     │   (Storage Encrypted, KMS)        │
                     └───────────────────────────────────┘
```

---

## 4. Technology Stack
* **Application Framework**: Node.js 20 LTS, Express.js
* **Database**: AWS RDS PostgreSQL 15 (Encrypted at rest, gp3 storage)
* **Containerization**: Docker (Hardened multi-stage non-root build), Amazon ECR
* **Orchestration**: AWS ECS Fargate (Serverless container compute)
* **Networking & LB**: AWS VPC (Public & Private Multi-AZ Subnets), Application Load Balancer (ALB)
* **Infrastructure as Code**: Terraform >= 1.5.0 (Modularized)
* **CI/CD Automation**: GitHub Actions, AWS OIDC Authentication, Trivy Scanner, Slack Webhooks
* **Secrets Management**: AWS Secrets Manager
* **Observability & Monitoring**: Prometheus v2.50, Grafana 10.3, AWS CloudWatch Logs

---

## 5. Repository Structure
```text
.
├── .github/
│   └── workflows/
│       ├── pull-request.yml        # PR validation: npm test, terraform fmt/validate, npm audit
│       ├── build-and-push.yml      # Build image, Trivy container scan, AWS OIDC, push to ECR
│       ├── deploy-staging.yml      # Automated ECS Fargate Staging deployment & verification
│       └── deploy-production.yml   # Manual approval gate & Production release workflow
├── app/
│   ├── src/                        # Express API, DB connection pool, Prometheus metrics
│   ├── test/                       # Unit & integration test suites
│   ├── Dockerfile                  # Hardened multi-stage non-root container build
│   ├── .dockerignore
│   └── package.json
├── terraform/
│   ├── modules/
│   │   ├── vpc/                    # VPC, Public/Private subnets, IGW, NAT Gateway toggle
│   │   ├── security_groups/        # Least privilege security group references
│   │   ├── alb/                    # Application Load Balancer & Target Groups
│   │   ├── rds/                    # RDS PostgreSQL & AWS Secrets Manager integration
│   │   ├── ecs/                    # ECS Fargate Cluster, Task Definitions & IAM policies
│   │   └── ecr/                    # Amazon ECR Repository, lifecycle policies & encryption
│   └── environments/
│       ├── staging/                # Staging environment orchestration
│       └── production/             # Production environment orchestration
├── monitoring/
│   ├── prometheus/                 # Prometheus scrape configuration
│   └── grafana/                    # Automated provisioning & 3 JSON dashboards
├── docs/
│   ├── approach.md                 # Technical decision record & architectural justifications
│   ├── challenges.md               # 5 Real engineering challenges & solutions
│   └── architecture.md             # Detailed ASCII architecture diagrams & data flows
├── docker-compose.yml              # Local stack runner (App + Postgres + Prometheus + Grafana)
├── .gitignore                      # Excludes node_modules, secrets, & terraform state
└── README.md                       # Master Architecture & Setup Documentation
```

---

## 6. Prerequisites
* **AWS CLI** v2 configured with adequate permissions
* **Terraform** >= 1.5.0
* **Docker** & **Docker Compose**
* **Node.js** v20+ and `npm`
* **Git**

---

## 7. AWS Setup
1. Create an AWS IAM Role for GitHub Actions OIDC with trust policy for `repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main`.
2. Attach permissions for ECS, ECR, RDS, VPC, ALB, Secrets Manager, and CloudWatch.
3. Configure GitHub Repository Secrets:
   * `AWS_ROLE_ARN`: `arn:aws:iam::ACCOUNT_ID:role/octabyte-github-actions-role`
   * `SLACK_WEBHOOK_URL`: `https://hooks.slack.com/services/XXX/YYY/ZZZ`

---

## 8. Terraform Setup
To provision staging infrastructure locally:
```bash
cd terraform/environments/staging
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

To provision production infrastructure:
```bash
cd terraform/environments/production
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

---

## 9. Remote State Setup
Configure remote S3 state storage with DynamoDB state locking by uncommenting the backend block in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "octabyte-tf-state-staging"
    key            = "terraform/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "octabyte-tf-locks-staging"
    encrypt        = true
  }
}
```

---

## 10. How to Deploy Staging
1. Create a branch and open a Pull Request to `main`.
2. On PR merge to `main`, `.github/workflows/build-and-push.yml` builds the container, runs Trivy security scan, and pushes the image to ECR tagged with `${GITHUB_SHA}`.
3. `.github/workflows/deploy-staging.yml` automatically updates the Staging ECS Task Definition and waits for service stability.

---

## 11. How to Deploy Production
1. Navigate to **Actions** -> **Deploy to Production Environment** in GitHub.
2. Click **Run workflow**, enter the Git SHA or version tag.
3. **Manual Approval Gate**: The workflow triggers a pending review status in the `production` GitHub Environment. Authorized reviewers must approve the release.
4. On approval, the pipeline promotes the staging image to Production ECR and updates the Production ECS cluster.

---

## 12. Docker Commands
Run local stack:
```bash
docker-compose up --build -d
```
Test endpoints:
* Root Welcome: `curl http://localhost:3000/`
* Health Check: `curl http://localhost:3000/health`
* Prometheus Metrics: `curl http://localhost:3000/metrics`
* App Metadata: `curl http://localhost:3000/api/info`

Clean local stack:
```bash
docker-compose down -v
```

---

## 13. CI/CD Explanation
* **`pull-request.yml`**: Runs on PRs. Validates unit/integration tests, checks dependency vulnerabilities via `npm audit`, checks `terraform fmt`, and validates Terraform syntax across staging and production environments.
* **`build-and-push.yml`**: Runs on merge to `main`. Builds Docker image, executes Trivy container scan, authenticates via AWS OIDC, and pushes tagged image to ECR.
* **`deploy-staging.yml`**: Automatically deploys the image tag to Staging ECS Fargate and verifies service stability.
* **`deploy-production.yml`**: Manual workflow dispatch enforcing GitHub Environment reviewer approval gate before releasing to production.

---

## 14. Monitoring
Prometheus scrapes microservice metrics on `/metrics` every 15s. Access Grafana at `http://localhost:3001` (Login: `admin` / `admin`).

### Pre-configured Grafana Dashboards:
1. **Infrastructure & ECS Fargate Overview** (`infrastructure_overview.json`): Container CPU %, Resident Memory (RSS), Heap memory, Event loop lag.
2. **Application RED Metrics** (`application_red_metrics.json`): Rate (HTTP throughput), Errors (4xx/5xx rates), Latency (P95/P99 duration histograms).
3. **RDS PostgreSQL & Database Performance** (`database_overview.json`): Query execution duration, active connection pool stats.

---

## 15. Logging
Container logs are streamed to **AWS CloudWatch Logs**:
* Staging Log Group: `/ecs/octabyte-staging-app`
* Production Log Group: `/ecs/octabyte-production-app`
* Retention: 14 days (cost optimized).

---

## 16. Security
* **Non-Root Container**: Container runs as unprivileged user `nodejs` (UID 1001).
* **AWS Secrets Manager**: Database passwords injected dynamically at task launch (`secretsmanager:GetSecretValue`). No plaintext passwords in Git or task env vars.
* **Zero-Trust Network Segmentation**: Security Groups strictly reference each other (`ALB SG` -> `ECS SG` -> `RDS SG`). Port 5432 is never exposed publicly.
* **OIDC Authentication**: Short-lived AWS STS tokens for GitHub Actions instead of static access keys.
* **Vulnerability Scanning**: Trivy scanner enforces severity checks on built container images.

---

## 17. Backup Strategy
* **RDS Automated Backups**: Daily automated snapshots with 7-day retention in staging and 14-day retention in production.
* **Point-In-Time Recovery (PITR)**: AWS RDS automated backups provide point-in-time recovery within the configured backup retention window.
* **Storage Encryption**: KMS encrypted storage (`storage_encrypted = true`).
* **Final Snapshots**: `skip_final_snapshot = false` enforced in production environments.

---

## 18. Cost Optimization
1. **Single NAT Gateway for Staging**: Uses 1 NAT Gateway in staging, saving ~$64/month.
2. **Fargate Resource Sizing**: Right-sized tasks (256 CPU / 512MB RAM for staging).
3. **RDS Storage Auto-scaling**: Dynamic gp3 storage starting at 20GB up to 100GB.
4. **Log Retention Capping**: CloudWatch retention capped at 14 days.
5. **ECR Lifecycle Policies**: Automatically purges old untagged container builds.

---

## 19. Testing
Run tests locally inside `app/`:
```bash
npm ci
npm test                  # Runs unit & integration test suites
npm run test:unit         # Unit tests only
npm run test:integration  # Integration resilience tests only
```

---

## 20. Troubleshooting
* **ECS Task Fails on Boot**: Check CloudWatch Log Group `/ecs/octabyte-staging-app`. Verify IAM Execution Role has `secretsmanager:GetSecretValue` permission for the DB secret ARN.
* **ALB Target Group Unhealthy**: Ensure Express `/health` returns 200 OK and container is listening on port 3000.
* **Database Connection Failure**: Verify RDS Security Group allows port 5432 ingress from ECS Security Group ID.

---

## 21. Cleanup / Destroy Instructions
To destroy AWS infrastructure and prevent incurring charges:
```bash
# Destroy Staging
cd terraform/environments/staging
terraform destroy -auto-approve

# Destroy Production
cd terraform/environments/production
terraform destroy -auto-approve
```

---

## 22. Challenges Faced
Detailed engineering resolutions for 5 major challenges (Secrets Manager IAM permissions, NAT Gateway cost reduction, ALB health check startup timing, AWS OIDC adoption, and node_modules cleanup) are documented in [`docs/challenges.md`](file:///c:/Users/Ajit/OneDrive/Desktop/project/docs/challenges.md).

---

## 23. Future Improvements
* Implement AWS Route 53 DNS and ACM SSL/TLS certificates for HTTPS termination.
* Implement AWS WAF (Web Application Firewall) on the ALB to protect against OWASP Top 10 vulnerabilities.
* Integrate AWS Auto Scaling Policies for ECS Fargate based on CPU and memory target tracking metrics.
