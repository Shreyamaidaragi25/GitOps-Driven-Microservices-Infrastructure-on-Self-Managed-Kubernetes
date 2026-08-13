# 🐾 PawCare – GitOps-Driven DevSecOps Application on Self-Managed Kubernetes

## 📌 Project Overview

PawCare is a production-style DevSecOps project that demonstrates the complete lifecycle of deploying a containerized web application on a self-managed Kubernetes cluster running on AWS.

The project combines:

- Infrastructure as Code using Terraform
- AWS cloud infrastructure
- Self-managed K3s Kubernetes cluster
- Python Flask application
- Docker containerization
- Docker Hub container registry
- Jenkins CI/CD
- PostgreSQL database
- Amazon RDS
- Kubernetes Secrets
- Helm
- Prometheus
- Grafana
- Git and GitHub

The project is designed to simulate how a DevOps/Cloud engineering team can automate application delivery from source code to a running Kubernetes workload while maintaining persistent database storage and infrastructure monitoring.

---

# 🎯 Project Objective

The main objective of this project is to build an end-to-end DevSecOps workflow where infrastructure, application deployment, containerization, database persistence, and monitoring are integrated into a single platform.

The project demonstrates:

1. Infrastructure provisioning using Terraform
2. AWS VPC and networking configuration
3. EC2-based Kubernetes infrastructure
4. Self-managed K3s cluster
5. Flask application deployment
6. Docker image creation
7. Docker Hub image management
8. Jenkins-based CI/CD
9. Kubernetes Deployment and Service
10. PostgreSQL persistence using Amazon RDS
11. Kubernetes Secrets for database credentials
12. Kubernetes self-healing
13. Rolling application deployments
14. Prometheus metrics collection
15. Grafana monitoring and visualization
16. Git-based application and infrastructure management

---

# 💡 Use Case

In a traditional deployment process, developers may need to manually build applications, copy files to servers, configure environments, restart services, and manually verify whether the application is running.

This project automates that workflow.

The simulated workflow is:

```text
Developer
    │
    │ git push
    ▼
GitHub
    │
    ▼
Jenkins
    │
    ├── Checkout Source Code
    ├── Validate Application
    ├── Build Docker Image
    └── Push Image
            │
            ▼
       Docker Hub
            │
            ▼
      K3s Kubernetes
            │
       ┌────┴────┐
       │         │
       ▼         ▼
   PawCare    PawCare
    Pod 1      Pod 2
       │         │
       └────┬────┘
            │
            ▼
      PostgreSQL RDS

            +
            
       Prometheus
            │
            ▼
         Grafana

         # ☁️ AWS Infrastructure

The PawCare infrastructure is hosted on Amazon Web Services (AWS).

Terraform is used to provision and manage the AWS infrastructure required for the self-managed Kubernetes cluster.

The infrastructure is deployed in the AWS `ap-south-1` region.

## AWS Components

The project includes the following AWS resources:

- Amazon VPC
- Public Subnet
- Private Subnet 1
- Private Subnet 2
- Internet Gateway
- Public Route Table
- Route Table Association
- Kubernetes Security Group
- RDS Security Group
- K3s Master EC2 Instance
- K3s Worker EC2 Instance 1
- K3s Worker EC2 Instance 2
- PostgreSQL Amazon RDS

The Kubernetes EC2 instances are logically identified as:

```text
pawcare-k3s-master
pawcare-k3s-worker1
pawcare-k3s-worker2

#  🌐 AWS Network Architecture
The project uses a custom VPC with public and private networking.


                         AWS Cloud
                             │
                             ▼
                    ┌─────────────────┐
                    │       VPC       │
                    │   10.0.0.0/16   │
                    └────────┬────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
              ▼                             ▼
       ┌──────────────┐              ┌──────────────┐
       │ Public Subnet│              │Private Subnets│
       │              │              │              │
       │ K3s Master   │              │ Private 1    │
       │              │              │ Private 2    │
       └──────┬───────┘              └──────┬───────┘
              │                             │
              ▼                             ▼
       ┌──────────────┐              ┌──────────────┐
       │ K3s Worker 1 │              │ PostgreSQL   │
       │              │              │     RDS      │
       └──────────────┘              └──────────────┘
              │
              ▼
       ┌──────────────┐
       │ K3s Worker 2 │
       └──────────────┘


The Internet Gateway provides Internet connectivity for resources that require it.

Security Groups control access between:

Kubernetes nodes
Application workloads
PostgreSQL RDS
Administrative access

# 🏗️ Terraform Infrastructure

Terraform is used as Infrastructure as Code to create and manage the AWS infrastructure.

The main Terraform resources include:

aws_vpc.main
aws_subnet.public
aws_subnet.private1
aws_subnet.private2
aws_internet_gateway.igw
aws_route_table.public_rt
aws_route_table_association.public_assoc
aws_security_group.k3s_sg
aws_security_group.rds_sg
aws_instance.master
aws_instance.worker1
aws_instance.worker2

 ## Terraform Files

 terraform/
├── main.tf
├── output.tf
├── .terraform.lock.hcl
├── terraform.tfstate
└── terraform.tfstate.backup
