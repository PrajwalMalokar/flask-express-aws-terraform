# Flask + Express Deployment on AWS with Terraform

This repository contains Terraform configurations and scripts to deploy a **Flask backend** and an **Express frontend** application on AWS in three different setups:

1. **Part 1**: Both Flask and Express on a single EC2 instance.
2. **Part 2**: Flask and Express on separate EC2 instances.
3. **Part 3**: Flask and Express as Docker containers deployed via AWS ECS (with ECR, VPC, and ALB).

All three parts are included in this repo under separate directories.

---

## 📂 Project Structure

```
├── part1-single-ec2/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user_data.sh
│   └── apps/
│       ├── flask-app/
│       │   ├── app.py
│       │   └── requirements.txt
│       └── express-app/
│           ├── index.js
│           └── package.json
│
├── part2-two-ec2/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── user_data_flask.sh
│   └── user_data_express.sh
│
├── part3-docker-ecs/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── flask-app/
│   │   ├── Dockerfile
│   │   ├── app.py
│   │   └── requirements.txt
│   └── express-app/
│       ├── Dockerfile
│       ├── index.js
│       └── package.json
│
├── README.md (this file)
└── docs/
    └── screenshots.docx  # Final submission with screenshots and commands
```

---

## 🚀 Deployment Parts

### Part 1: Flask + Express on a Single EC2

**Objective**: Deploy both applications on one EC2 instance running on different ports (Flask → 5000, Express → 3000).

* **Terraform tasks**:

  * Provision an EC2 instance.
  * Attach a security group with inbound rules for ports 22, 5000, and 3000.
  * Use `user_data.sh` to install dependencies (Python, pip, Node.js) and configure services.
* **Deliverables**:

  * Terraform files (`main.tf`, `variables.tf`, `outputs.tf`).
  * EC2 instance accessible via public IP.
  * Flask and Express running and accessible on their ports.

---

### Part 2: Flask and Express on Separate EC2 Instances

**Objective**: Deploy Flask and Express on two different EC2 instances.

* **Terraform tasks**:

  * Provision 2 EC2 instances (one for Flask, one for Express).
  * Create VPC, subnets, route tables, and security groups.
  * Configure communication between instances and open ports to the internet.
  * Use `user_data_flask.sh` and `user_data_express.sh` for setup.
* **Deliverables**:

  * Terraform files (`main.tf`, `variables.tf`, `outputs.tf`).
  * 2 EC2 instances with Flask and Express running independently.
  * Security groups ensuring both apps are accessible.

---

### Part 3: Flask + Express with Docker, ECR, ECS, ALB

**Objective**: Containerize both apps and deploy them on AWS ECS using Terraform.

* **Terraform tasks**:

  * Create 2 **ECR repositories** (Flask, Express).
  * Create **VPC**, subnets, internet gateway, NAT gateway, route tables, and security groups.
  * Build and push Docker images of Flask and Express to ECR.
  * Create ECS Cluster and Task Definitions (1 for Flask, 1 for Express).
  * Create ECS Services using Fargate launch type.
  * Provision an **Application Load Balancer (ALB)** with listeners and target groups to route requests.
* **Deliverables**:

  * Terraform files (`main.tf`, `variables.tf`, `outputs.tf`).
  * Dockerfiles for both apps.
  * Images pushed to ECR.
  * ECS services accessible via ALB DNS.

---

## ⚙️ General Requirements & Best Practices

* **Terraform state** should be stored remotely (e.g., S3 backend + DynamoDB for locking).
* Use `terraform plan` and `terraform apply` before deployment.
* Separate variables in `variables.tf` and outputs in `outputs.tf`.
* Reusable modules can be created for VPC, EC2, ECS, and ALB.
* Follow least privilege principle when creating IAM roles.

---

## 📸 Submission Guidelines

* Run deployments for each part and take **screenshots**:

  * Terraform plan & apply outputs.
  * AWS Console (EC2, ECS, ECR, VPC, ALB).
  * Flask and Express apps running in browser.
* Save screenshots in `docs/screenshots.docx` with explanations.
* Push entire project to GitHub.
* Share the repo link + `.docx` as final submission.

---

## ✅ Expected Outcomes

1. **Part 1** → Single EC2 with both Flask & Express running on different ports.
2. **Part 2** → Two EC2s, one dedicated to Flask, one to Express, communicating via VPC.
3. **Part 3** → Dockerized Flask & Express deployed on ECS via Fargate, fronted by ALB.

---

## 🔗 Useful Commands

```bash
# Terraform workflow
terraform init
terraform plan
terraform apply

# Docker build & push (Part 3)
docker build -t flask-app ./flask-app
docker tag flask-app:latest <account_id>.dkr.ecr.<region>.amazonaws.com/flask-repo:latest
docker push <account_id>.dkr.ecr.<region>.amazonaws.com/flask-repo:latest

# Check systemd services (Part 1 & 2)
systemctl status flask.service
systemctl status express.service
journalctl -u flask.service -f
journalctl -u express.service -f
```

---

## 👨‍💻 Author

Prajwal – DevOps & Cloud AWS Engineer Student

