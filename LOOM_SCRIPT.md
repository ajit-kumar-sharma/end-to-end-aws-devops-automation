# 📹 Loom Video Recording Script & Walkthrough Checklist

**Target Duration**: 3–5 Minutes  
**Audience**: HR & Technical Interviewers at 8Byte.ai  

---

## 🎬 Recording Script Outline

### 1. Introduction (0:00 - 0:45)
- **Greeting**: "Hi 8Byte team! My name is Ajit Kumar Sharma, and this is my submission for the DevOps Engineer Technical Assignment."
- **Overview**: Briefly mention what you built:
  - Multi-tier Node.js/Express app with PostgreSQL and Prometheus RED metrics.
  - Infrastructure as Code with modular AWS Terraform (VPC, ECS Fargate, ALB, RDS).
  - CI/CD automation with GitHub Actions, Trivy security scanning, and manual approval gates.
  - Observability stack using Prometheus & Grafana dashboards.

---

### 2. Infrastructure & Codebase Walkthrough (0:45 - 2:00)
- **Repository Structure**: Show GitHub repo layout (`app/`, `terraform/`, `.github/`, `monitoring/`).
- **Terraform Modules**: Point out modular VPC, Security Groups (ALB -> ECS -> RDS least privilege), and state locking configuration.
- **Dockerfile**: Highlight security hardening (multi-stage build, `node:20-alpine`, non-root user `USER nodejs`).

---

### 3. CI/CD & Security Demonstration (2:00 - 3:15)
- **GitHub Actions Workflows**:
  - Show `.github/workflows/pr-checks.yml` running unit tests and Trivy container vulnerability scans.
  - Show `.github/workflows/deploy-staging.yml` auto-deploying to Staging upon merge to `main`.
  - Show `.github/workflows/deploy-production.yml` featuring the GitHub Environment manual approval gate and Slack alerts.

---

### 4. Live Environment & Monitoring Demo (3:15 - 4:30)
- **Show Running Local Stack**:
  - Open terminal and show `docker-compose ps`.
  - Open browser to `http://localhost:3000/health` (Show UP & DB Connected status).
  - Open `http://localhost:3000/metrics` (Show Prometheus metrics format).
- **Grafana Dashboards**:
  - Open Grafana (`http://localhost:3001`).
  - Show **Dashboard 1**: Infrastructure & Resource Utilization.
  - Show **Dashboard 2**: Application RED Metrics (Latency P95, Error Rates, Request Rates).

---

### 5. Challenges & Wrap-Up (4:30 - 5:00)
- **Challenges**: Briefly highlight 1 key challenge (e.g., zero-downtime database health checks or NAT Gateway cost optimization in non-prod).
- **Conclusion**: "Thank you for reviewing my assignment! I look forward to discussing this solution further in the live technical round."

---

## 📋 Pre-Recording Checklist
- [ ] Run `docker-compose up -d` prior to recording so all services are active.
- [ ] Have tabs pre-opened for:
  - GitHub Repository
  - Application Health (`/health`)
  - Prometheus Target Status (`:9090`)
  - Grafana Dashboards (`:3001`)
- [ ] Set browser zoom to 110% for clear video visibility.
