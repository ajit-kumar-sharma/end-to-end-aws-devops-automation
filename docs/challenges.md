# 🛠️ Engineering Challenges & Technical Resolutions

**Project**: OctaByte AWS DevOps Practical Assignment  
**Document Version**: 1.0.0  

---

## 1. Challenge: ECS Task Execution Role Missing Permissions for AWS Secrets Manager

**What happened**:  
During initial deployment of the ECS Fargate task definition with secret injection (`DB_PASSWORD` from Secrets Manager), ECS tasks immediately failed with status `STOPPED` and error: `ResourceInitializationError: unable to pull secrets or extract secret_value`.

**Root cause**:  
The default AWS IAM policy `AmazonECSTaskExecutionRolePolicy` attached to the ECS Task Execution Role provides permissions for ECR image pulling and CloudWatch logging, but does NOT grant `secretsmanager:GetSecretValue` permissions to decrypt and retrieve Secrets Manager secrets.

**Solution**:  
Created a dedicated IAM policy `aws_iam_policy.ecs_secrets_policy` in the Terraform `ecs` module granting `secretsmanager:GetSecretValue` scoped strictly to the RDS secret ARN (`var.db_secret_arn`), and attached it to `aws_iam_role.ecs_execution_role`.

**How it was verified**:  
Ran `terraform apply` in staging environment, deployed task definition, and verified container startup status changed to `RUNNING` without secret initialization errors.

---

## 2. Challenge: High Egress NAT Gateway Costs in AWS Multi-AZ VPC Architecture

**What happened**:  
Provisioning separate NAT Gateways across 2 Availability Zones in non-production environments (Dev/Staging) added ~$64/month in baseline NAT Gateway idle charges plus data transfer costs.

**Root cause**:  
Default VPC modules instantiate 1 NAT Gateway per public subnet to achieve full regional zone independence, which is necessary for production HA but unnecessarily expensive for staging test suites.

**Solution**:  
Parameterized NAT Gateway creation in `terraform/modules/vpc` using a `single_nat_gateway = true` boolean variable for staging (creating 1 shared NAT Gateway and EIP) while setting `single_nat_gateway = false` for production to ensure full multi-AZ fault tolerance.

**How it was verified**:  
Ran `terraform plan` on `environments/staging` and verified only 1 EIP and 1 NAT Gateway were queued for creation instead of 2.

---

## 3. Challenge: Zero-Downtime ECS Rolling Deployments Failing Health Checks on Startup

**What happened**:  
Deploying new application image tags caused ALB target groups to flag new ECS tasks as `unhealthy`, triggering deployment rollbacks.

**Root cause**:  
The Node.js container attempted to initialize the PostgreSQL database connection (`initDb()`) before the container environment fully initialized, causing `/health` endpoint probes to return 500 errors during the initial 5 seconds of container boot.

**Solution**:  
1. Configured container health check start period (`--start-period=5s`) in Dockerfile.
2. Updated Express `/health` endpoint to catch database initialization errors gracefully without throwing unhandled exceptions.
3. Set ALB Target Group `health_check` settings with `healthy_threshold = 2`, `unhealthy_threshold = 3`, and `matcher = "200"`.

**How it was verified**:  
Executed `npm test` integration tests mocking DB failure, verified `/health` returned structured HTTP 500 payload without crashing the Node process, and verified successful ALB target health transitions during Docker container startup.

---

## 4. Challenge: Long-Lived AWS Access Key Leakage Risk in CI/CD Workflows

**What happened**:  
Traditional GitHub Actions workflows require storing `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in repository secrets, creating security vulnerabilities if keys are exposed or compromised.

**Root cause**:  
Static credentials do not expire automatically and grant persistent permissions unless manually rotated.

**Solution**:  
Configured OpenID Connect (OIDC) authentication using `aws-actions/configure-aws-credentials@v4` with an IAM Role trusted by GitHub's OIDC provider (`token.actions.githubusercontent.com`).

**How it was verified**:  
Validated workflow syntax in `.github/workflows/build-and-push.yml` with `permissions: id-token: write` and `role-to-assume: ${{ secrets.AWS_ROLE_ARN }}`.

---

## 5. Challenge: Untracked `node_modules` Dependencies inflating Git Repository Size

**What happened**:  
The initial project structure contained a pre-committed `app/node_modules` directory with over 390 node dependency packages checked into Git.

**Root cause**:  
Missing root `.gitignore` file permitted `node_modules/` to be committed into repository tracking.

**Solution**:  
1. Executed `Remove-Item -Recurse -Force app/node_modules` to delete local committed dependencies.
2. Created a comprehensive root `.gitignore` file ignoring `node_modules/`, `.terraform/`, `*.tfstate`, `.env`, and OS files.
3. Updated CI/CD workflows to execute `npm ci` in clean container runners using `package-lock.json`.

**How it was verified**:  
Ran `git status` to confirm `node_modules/` is excluded from git tracking, and verified clean automated build execution via `npm ci` and `npm test`.
