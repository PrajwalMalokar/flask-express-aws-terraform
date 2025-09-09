# Flask + Express Multi‑Stage Deployment on AWS (Terraform)

This repository implements the full assignment requirement to deploy a **Flask backend** and an **Express frontend** across three progressively advanced AWS architectures using **Terraform**. Each part lives in its own directory and is independently deployable.

Assignment Mapping (✓ implemented):
1. Part 1: Single EC2 instance running both apps on different ports (✓)
2. Part 2: Two EC2 instances (one backend, one frontend) with networking & security segregation (✓)
3. Part 3: Containerized deployment using Docker, ECR, ECS (Fargate), dedicated ECS clusters, ALBs, VPC (✓)

This README documents: objectives, structure, how to deploy each part, verification steps, and deliverables for submission (screenshots + repo link).

---

## 📂 Actual Project Structure

```
Task/
├── Part 1/
│   ├── backend/
│   │   ├── app.py
│   │   ├── bussiness.py
│   │   ├── names.txt
│   │   └── requirements.txt
│   ├── frontend/
│   │   ├── app.js
│   │   ├── views/index.ejs
│   │   └── package.json
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── user_data.sh.tpl   (installs Python + Node.js, starts both apps)
│
├── Part_2/
│   ├── backend/ (same app structure)
│   ├── frontend/ (same app structure)
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── user_data_backend.sh.tpl
│       └── user_data_frontend.sh.tpl
│
├── Part_3/
│   ├── backend/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   ├── bussiness.py
│   │   ├── names.txt
│   │   └── requirements.txt
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── app.js
│   │   ├── views/index.ejs
│   │   └── package.json
│   └── terraform/
│       ├── main.tf          (ECR, VPC, ECS clusters, services, ALBs)
│       ├── variables.tf
│       ├── outputs.tf       (ALB DNS + Backend ALB DNS + ECR repos)
│       ├── provider.tf
│
└── README.md
```

---

## 🚀 Deployment Parts & Instructions

### Part 1 – Single EC2 (Both Apps)
Objective: Run Flask (port 5000) and Express (port 3000) on one instance.

Terraform provisions:
- VPC (or default depending on your configuration), security group (22, 5000, 3000 ingress), EC2 instance
- `user_data.sh.tpl` installs: Python3 + pip, Node.js, app dependencies, then launches both apps (typically via nohup or systemd)

How to deploy:
```bash
cd "Part 1/terraform"
terraform init
terraform plan
terraform apply -auto-approve
```
Verify:
```bash
PUBLIC_IP=$(terraform output -raw instance_public_ip)
curl http://$PUBLIC_IP:5000/
curl http://$PUBLIC_IP:3000/
```
Deliverables:
- Terraform code + screenshot of successful apply
- Browser / curl output showing both endpoints
- Explanation of user_data flow

---

### Part 2 – Two EC2 Instances (Separated Roles)
Objective: Isolate backend and frontend on distinct hosts.

Terraform provisions:
- Custom VPC, subnets, route table, security groups
- Backend EC2 (port 5000), Frontend EC2 (port 3000)
- Security groups allow frontend ↔ backend communication (frontend fetches backend API)
- Separate user data templates for backend & frontend

Deployment:
```bash
cd Part_2/terraform
terraform init
terraform apply -auto-approve
```
Outputs (example):
```bash
terraform output
# backend_public_ip, frontend_public_ip, backend_url, frontend_url
```
Validation:
```bash
curl http://$(terraform output -raw backend_public_ip):5000/api
curl http://$(terraform output -raw frontend_public_ip):3000/
```
Deliverables:
- Terraform code
- Screenshots of both instances + security groups
- Curl proof of cross-instance access

---

### Part 3 – Docker + ECR + ECS (Fargate) + Dual ALBs
Objective: Run both apps as containers with independent ECS clusters and distinct public endpoints.

Provisioned by Terraform (`Part_3/terraform/main.tf`):
- 2 ECR repositories: `part3-backend`, `part3-frontend` (force_delete enabled)
- VPC, 2 public subnets, routing, security groups (ALB + tasks)
- 2 ECS clusters: backend & frontend
- 2 Task Definitions (health checks using curl)
- 2 ECS Services (Fargate, awsvpc networking)
- 2 ALBs:
  * Frontend ALB (serves React/Express root path)
  * Backend ALB (direct backend API + root JSON hello)
- Target groups with health checks (`/` and `/api`)

Terraform Outputs (examples produced after apply):
```
alb_dns_name              = part3-flask-express-alb-XXXX.ap-south-1.elb.amazonaws.com
backend_alb_dns_name      = part3-backend-alb-YYYY.ap-south-1.elb.amazonaws.com
backend_api_url           = http://part3-backend-alb-YYYY.ap-south-1.elb.amazonaws.com/api
frontend_url              = http://part3-flask-express-alb-XXXX.ap-south-1.elb.amazonaws.com/
ecr_backend_repo          = <acct>.dkr.ecr.ap-south-1.amazonaws.com/part3-backend
ecr_frontend_repo         = <acct>.dkr.ecr.ap-south-1.amazonaws.com/part3-frontend
```

Build & Push Images (after `terraform apply` creates repos):
```bash
AWS_REGION=ap-south-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Backend
docker build -t part3-backend ./Part_3/backend
docker tag part3-backend:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/part3-backend:latest
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/part3-backend:latest

# Frontend
docker build -t part3-frontend ./Part_3/frontend
docker tag part3-frontend:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/part3-frontend:latest
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/part3-frontend:latest

# Force services to pull updated images (optional)
aws ecs update-service --cluster part3-flask-express-cluster --service part3-backend-svc --force-new-deployment --region $AWS_REGION
aws ecs update-service --cluster part3-frontend-cluster      --service part3-frontend-svc --force-new-deployment --region $AWS_REGION
```

Health Verification:
```bash
curl -I $(terraform output -raw frontend_url)
curl -I $(terraform output -raw backend_api_url)
curl $(terraform output -raw backend_api_url) | jq
```

Deliverables:
- Terraform infra code (ECR, ECS, VPC, ALBs) + Dockerfiles
- Screenshots: ECR repos, ECS clusters/services, ALB target group health, curl output
- Explanation of environment variables (`BACKEND_URL`), health checks, separate clusters rationale

---

## 📸 Submission Guidelines (What to Capture)

Include in your documentation (Google Doc / Word):
1. Part 1:
  - Terraform apply output (last 15–20 lines) & instance details page
  - Browser / curl proof both ports respond
2. Part 2:
  - Apply output
  - EC2 list showing two instances
  - Security group inbound rules
  - Curl backend API + frontend page
3. Part 3:
  - Apply output (showing ALB & ECS service creation)
  - ECR repositories with images
  - ECS clusters (backend & frontend) + services running
  - ALBs (two DNS names) + target group health (green)
  - Curl backend `/api` JSON + frontend root

---
## 👨‍💻 Author
Prajwal – DevOps / Cloud Engineering Track