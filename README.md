# 🐾 PawCare – GitOps-Driven DevSecOps Application on Self-Managed Kubernetes

## 📌 Project Overview

PawCare is a production-style DevSecOps project that demonstrates the complete lifecycle of deploying, managing, and monitoring a containerized web application on a self-managed Kubernetes cluster running on AWS.

The project combines Infrastructure as Code, cloud infrastructure, containerization, CI/CD, Kubernetes orchestration, persistent database storage, and monitoring into a single end-to-end workflow.

### Technologies Used

- AWS
- Terraform
- Linux / Ubuntu
- Docker
- Docker Hub
- Jenkins
- Git
- GitHub
- Kubernetes
- K3s
- Python
- Flask
- PostgreSQL
- Amazon RDS
- Kubernetes Secrets
- Helm
- Prometheus
- Grafana

---

# 🎯 Project Objective

The main objective of this project is to build an end-to-end DevSecOps workflow where infrastructure provisioning, application development, containerization, CI/CD, Kubernetes deployment, database persistence, and monitoring are integrated into a single platform.

The project demonstrates:

1. Infrastructure provisioning using Terraform
2. AWS VPC and networking
3. EC2-based self-managed Kubernetes
4. K3s Kubernetes cluster
5. Flask application deployment
6. Docker containerization
7. Docker Hub image management
8. Jenkins CI/CD automation
9. Kubernetes Deployment and Service
10. PostgreSQL persistence using Amazon RDS
11. Kubernetes Secrets for database configuration
12. Kubernetes self-healing
13. Rolling application deployments
14. Prometheus metrics collection
15. Grafana monitoring
16. Git-based source and infrastructure management

---

# 💡 Use Case

In a traditional deployment process, developers may need to manually build applications, copy files to servers, configure environments, restart services, and verify application availability.

PawCare automates this workflow.

The overall deployment flow is:

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
```

---

# 🏗️ Overall Architecture

```text
                           AWS CLOUD
                              │
                              ▼
                       ┌─────────────┐
                       │     VPC     │
                       │ 10.0.0.0/16 │
                       └──────┬──────┘
                              │
             ┌────────────────┴────────────────┐
             │                                 │
             ▼                                 ▼
      Public Subnet                     Private Subnets
             │                           │          │
             ▼                           ▼          ▼
       K3s Master EC2                Private 1   Private 2
             │
       ┌─────┴─────┐
       │           │
       ▼           ▼
  K3s Worker 1  K3s Worker 2
       │           │
       └─────┬─────┘
             │
             ▼
        K3s Cluster
             │
       ┌─────┴─────┐
       │           │
       ▼           ▼
  PawCare Pod 1  PawCare Pod 2
       │           │
       └─────┬─────┘
             │
             ▼
       PostgreSQL RDS

             +

        Prometheus
             │
             ▼
          Grafana
```

---

# ☁️ AWS Infrastructure

The PawCare infrastructure is hosted on Amazon Web Services (AWS).

Terraform is used to provision and manage the AWS infrastructure required for the self-managed Kubernetes environment.

The infrastructure is deployed in the AWS `ap-south-1` region.

## AWS Components

The project includes:

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
```

PostgreSQL uses:

```text
Port: 5432
Protocol: TCP
```

---

# 🌐 AWS Network Architecture

The project uses a custom VPC with public and private networking.

```text
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
       └──────┬───────┘              └──────────────┘
              │
              ▼
       ┌──────────────┐
       │ K3s Worker 2 │
       └──────────────┘
```

The Internet Gateway provides Internet connectivity for resources that require it.

Security Groups control network access between:

- Kubernetes nodes
- Application workloads
- PostgreSQL RDS
- Administrative access

---

# 🏗️ Terraform Infrastructure

Terraform is used as Infrastructure as Code to create and manage the AWS infrastructure.

The main Terraform resources include:

```text
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
```

## Terraform Files

```text
terraform/
├── main.tf
├── output.tf
├── .terraform.lock.hcl
├── terraform.tfstate
└── terraform.tfstate.backup
```

### `main.tf`

Defines the AWS infrastructure including:

- VPC
- Subnets
- Internet Gateway
- Route Tables
- Security Groups
- EC2 instances
- Kubernetes infrastructure

### `output.tf`

Provides useful infrastructure outputs such as:

```text
master_ip
worker1_ip
worker2_ip
```

### `.terraform.lock.hcl`

Locks the Terraform provider versions used by the project.

### Terraform State

Terraform uses state files to track the infrastructure it manages.

For production/team environments, Terraform state should preferably be stored in a secure remote backend.

---

# 🔄 Terraform Workflow

The infrastructure follows this workflow:

```text
Terraform Configuration
        │
        ▼
terraform init
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
terraform apply
        │
        ▼
AWS Infrastructure
```

---

# 🚀 Terraform Setup

Navigate to the Terraform directory:

```bash
cd PawCare-DevSecOps/terraform
```

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform validate
```

Generate an execution plan:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

View Terraform outputs:

```bash
terraform output
```

The outputs provide information such as the public IP addresses of the Kubernetes nodes.

---

# ⚠️ Terraform Best Practices

Always review the Terraform plan before applying changes.

Use:

```bash
terraform plan
```

before:

```bash
terraform apply
```

Terraform should be treated as the source of truth for infrastructure that it manages.

Avoid manually deleting or modifying Terraform-managed AWS resources because this can create infrastructure drift between AWS and Terraform state.

---

# ☸️ Self-Managed Kubernetes with K3s

K3s is used as the Kubernetes distribution for this project.

K3s provides a lightweight Kubernetes environment suitable for development, learning, labs, and production-style demonstrations.

The cluster contains:

```text
1 K3s Master
2 K3s Workers
```

Architecture:

```text
                    K3s Master
                        │
               ┌────────┴────────┐
               │                 │
               ▼                 ▼
        K3s Worker 1       K3s Worker 2
```

---

# 🔎 Verify the Kubernetes Cluster

Connect to the K3s master:

```bash
ssh ubuntu@<MASTER_PUBLIC_IP>
```

Check the nodes:

```bash
sudo kubectl get nodes
```

Check all pods:

```bash
sudo kubectl get pods -A
```

Check PawCare pods:

```bash
sudo kubectl get pods -l app=pawcare
```

---

# 🐾 PawCare Application

PawCare is a Python Flask application designed as a simple pet adoption management system.

The application provides:

- Pet listing
- Add pet functionality
- Pet adoption functionality
- REST APIs
- Application health endpoint
- PostgreSQL database persistence

---

# ✨ Application Features

## View Pets

The home page displays pets stored in the database.

Example pets include:

```text
Bruno - Labrador - Dog
Luna - Persian Cat - Cat
Max - Beagle - Dog
```

## Add Pet

Users can add a new pet.

Example:

```text
Name: Rocky
Breed: Golden Retriever
Age: 2
Species: Dog
```

## Adopt Pet

A pet's status can be changed from:

```text
Available
```

to:

```text
Adopted
```

## Health Endpoint

The application provides:

```text
/health
```

Example response:

```json
{
  "status": "healthy"
}
```

## Pet API

```text
/pets
```

Returns the list of pets.

## Individual Pet API

```text
/pets/<pet_id>
```

Returns details about a specific pet.

## Add Pet API

```text
/pets/add
```

Uses a POST request to create a new pet.

## Adopt Pet API

```text
/pets/<pet_id>/adopt
```

Uses a POST request to update a pet's adoption status.

---

# 📁 Application Structure

```text
app/
├── app.py
├── requirements.txt
└── templates/
    └── index.html
```

---

# 🐳 Docker Containerization

The PawCare application is packaged as a Docker image.

Docker provides:

- Application isolation
- Consistent runtime environment
- Portable deployment
- Reproducible builds
- Easy Kubernetes integration

The workflow is:

```text
Flask Application
       │
       ▼
    Dockerfile
       │
       ▼
  Docker Image
       │
       ▼
   Docker Hub
       │
       ▼
 Kubernetes
```

The Docker image is published to Docker Hub.

Example:

```text
kuki25/pawcare:<tag>
```

---

# 🧪 Build Docker Image Locally

Build the image:

```bash
docker build -t pawcare-test .
```

Check the image:

```bash
docker images pawcare-test
```

Run locally:

```bash
docker run -p 5000:5000 pawcare-test
```

Access the application:

```text
http://localhost:5000
```

---

# 🔄 CI/CD Pipeline with Jenkins

Jenkins is used to automate the PawCare application build and deployment process.

The pipeline is defined in:

```text
Jenkinsfile
```

The CI/CD workflow is:

```text
GitHub
   │
   ▼
Jenkins
   │
   ├── Checkout Source Code
   ├── Python Environment
   ├── Install Dependencies
   ├── Application Validation
   ├── Docker Build
   ├── Docker Hub Push
   │
   ▼
Docker Hub
   │
   ▼
K3s Kubernetes
   │
   ▼
PawCare Deployment
   │
   ▼
Rollout Verification
```

---

# 🔁 Jenkins Pipeline Stages

## 1. Source Code Checkout

Jenkins retrieves the latest source code from GitHub.

```text
GitHub → Jenkins Workspace
```

## 2. Python Environment

Jenkins prepares the Python environment required by the application.

## 3. Dependency Installation

Dependencies are installed from:

```text
app/requirements.txt
```

## 4. Application Validation

The application is validated before containerization.

## 5. Docker Build

Jenkins builds the PawCare Docker image.

## 6. Docker Hub Push

The image is pushed to Docker Hub.

```text
Jenkins
   │
   ▼
Docker Image
   │
   ▼
Docker Hub
```

## 7. Kubernetes Deployment

Jenkins connects to the K3s cluster and deploys the updated application.

## 8. Rollout Verification

Jenkins verifies that Kubernetes successfully completes the deployment.

```bash
kubectl rollout status deployment/pawcare
```

---

# 📦 Kubernetes Deployment

The PawCare application is deployed using a Kubernetes Deployment.

The Deployment controls:

- Application replicas
- Docker image
- Container port
- Environment variables
- Kubernetes Secrets
- Pod labels
- Image pull policy

The application runs with two replicas:

```yaml
replicas: 2
```

Architecture:

```text
              PawCare Deployment
                      │
              ┌───────┴───────┐
              │               │
              ▼               ▼
         PawCare Pod 1   PawCare Pod 2
```

---

# 🌐 Kubernetes Service

A Kubernetes Service provides stable network access to the PawCare pods.

Instead of accessing individual pod IP addresses:

```text
Client
  │
  ▼
Kubernetes Service
  │
  ├── PawCare Pod 1
  │
  └── PawCare Pod 2
```

The Service provides stable access while Kubernetes manages the underlying pods.

---

# 📄 Kubernetes Configuration Files

The main Kubernetes files are:

```text
deploy.yaml
service.yaml
```

## `deploy.yaml`

Defines:

- Replica count
- Docker image
- Container port
- Database environment variables
- Kubernetes Secret references
- Pod configuration

## `service.yaml`

Defines the Kubernetes Service used to expose the PawCare application.

---

# 🗄️ PostgreSQL Database

PawCare uses PostgreSQL as its persistent database.

The database is hosted using:

```text
Amazon RDS
```

PostgreSQL uses:

```text
Port: 5432
Protocol: TCP
```

The application connects to the RDS database through Kubernetes Secret configuration.

Architecture:

```text
PawCare Pod
     │
     ▼
PostgreSQL RDS
     │
     ▼
Persistent Application Data
```

---

# 💾 Database Persistence

Kubernetes pods are temporary.

If application data were stored only inside a pod, the data could be lost when the pod is replaced.

PawCare instead stores application data in PostgreSQL RDS.

```text
PawCare Pod 1
      │
      ▼
PostgreSQL RDS
      ▲
      │
PawCare Pod 2
```

Therefore, application data remains available when:

- A pod is deleted
- A pod crashes
- Kubernetes recreates a pod
- A new application version is deployed
- The application is restarted
- The browser is refreshed

---

# 🔐 Kubernetes Secrets

Database configuration is provided through a Kubernetes Secret.

Secret name:

```text
pawcare-db-secrets
```

The Secret contains:

```text
DB_HOST
DB_PORT
DB_NAME
DB_USER
DB_PASSWORD
```

The Deployment uses `secretKeyRef` to provide these values to the container.

Example:

```yaml
env:
  - name: DB_HOST
    valueFrom:
      secretKeyRef:
        name: pawcare-db-secrets
        key: DB_HOST

  - name: DB_PORT
    valueFrom:
      secretKeyRef:
        name: pawcare-db-secrets
        key: DB_PORT

  - name: DB_NAME
    valueFrom:
      secretKeyRef:
        name: pawcare-db-secrets
        key: DB_NAME

  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: pawcare-db-secrets
        key: DB_USER

  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: pawcare-db-secrets
        key: DB_PASSWORD
```

Actual database passwords should never be committed to GitHub.

---

# 🔎 Verify Kubernetes Secret

Check whether the Secret exists:

```bash
sudo kubectl get secret pawcare-db-secrets
```

View the Secret metadata and keys:

```bash
sudo kubectl describe secret pawcare-db-secrets
```

---

# 🧪 Application Health Check

The application provides:

```text
/health
```

Test it using:

```bash
curl http://<APPLICATION_ADDRESS>/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

---

# ♻️ Kubernetes Self-Healing

The application runs with:

```text
replicas: 2
```

If one pod is deleted or fails, Kubernetes automatically creates a replacement.

Example:

```text
Before:

Pod 1
Pod 2

       ↓ Pod 1 deleted

Pod 2
Pod 3
```

The Deployment maintains the desired number of replicas.

---

# 🧪 Demonstrate Self-Healing

Check PawCare pods:

```bash
sudo kubectl get pods -l app=pawcare
```

Delete one pod:

```bash
sudo kubectl delete pod <pod-name>
```

Watch the replacement:

```bash
sudo kubectl get pods -l app=pawcare -w
```

Kubernetes automatically creates a replacement pod.

---

# 🔄 Rolling Updates

When a new application version is deployed, Kubernetes gradually replaces old pods with new ones.

```text
Old Version
    │
    ▼
New Pod Created
    │
    ▼
New Pod Becomes Ready
    │
    ▼
Old Pod Removed
    │
    ▼
Next New Pod
    │
    ▼
Deployment Complete
```

Check rollout status:

```bash
sudo kubectl rollout status deployment/pawcare
```

View rollout history:

```bash
sudo kubectl rollout history deployment/pawcare
```

---

# 📦 Helm

Helm is used as the Kubernetes package manager for the monitoring stack.

Helm simplifies:

- Installation
- Upgrades
- Configuration
- Management of Kubernetes applications

Check Helm:

```bash
helm version
```

Check installed releases:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm list -A
```

---

# 📊 Monitoring with Prometheus and Grafana

The project uses Prometheus and Grafana for Kubernetes monitoring.

The monitoring stack is installed using:

```text
kube-prometheus-stack
```

The monitoring namespace is:

```text
monitoring
```

The stack includes:

- Prometheus
- Grafana
- Alertmanager
- Node Exporter
- kube-state-metrics

Architecture:

```text
K3s Cluster
     │
     ▼
Kubernetes Metrics
     │
     ▼
Prometheus
     │
     ▼
Grafana
```

---

# 🛠️ Install Monitoring Stack

Add the Prometheus Community repository:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update Helm repositories:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
helm repo update
```

Create the monitoring namespace:

```bash
sudo kubectl create namespace monitoring
```

Install the monitoring stack:

```bash
sudo env KUBECONFIG=/etc/rancher/k3s/k3s.yaml \
helm install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring
```

Verify:

```bash
sudo kubectl get pods -n monitoring
```

---

# 🔑 Grafana Login

Retrieve the Grafana administrator password:

```bash
sudo kubectl get secret monitoring-grafana \
-n monitoring \
-o jsonpath="{.data.admin-password}" | base64 -d
echo
```

Default username:

```text
admin
```

The generated password should be treated as a secret.

---

# 🌐 Access Grafana

Check the Grafana Service:

```bash
sudo kubectl get svc -n monitoring
```

For temporary demonstration access, use port forwarding:

```bash
sudo kubectl port-forward \
-n monitoring \
svc/monitoring-grafana \
3000:80 \
--address=0.0.0.0
```

Access Grafana through:

```text
http://<K3S_MASTER_PUBLIC_IP>:3000
```

The AWS Security Group must allow TCP port `3000` from the required client IP when accessing Grafana externally.

---

# 📊 Grafana Monitoring

Grafana can be used to visualize:

- Kubernetes node CPU
- Kubernetes node memory
- Pod CPU
- Pod memory
- Pod restart counts
- Deployment replicas
- Pod availability
- Cluster resource utilization

A dedicated PawCare dashboard can be created using Prometheus as the datasource.

---

# 📈 Useful Prometheus Queries

## PawCare Ready Pods

```promql
sum(kube_pod_status_ready{
  namespace="default",
  pod=~"pawcare-.*",
  condition="true"
})
```

Expected result when both replicas are healthy:

```text
2
```

## PawCare Pod Restarts

```promql
sum(kube_pod_container_status_restarts_total{
  namespace="default",
  pod=~"pawcare-.*"
})
```

## PawCare CPU Usage

```promql
sum(rate(
  container_cpu_usage_seconds_total{
    namespace="default",
    pod=~"pawcare-.*",
    container="pawcare"
  }[5m]
))
```

## PawCare Memory Usage

```promql
sum(
  container_memory_working_set_bytes{
    namespace="default",
    pod=~"pawcare-.*",
    container="pawcare"
  }
)
```

---

# 🧪 Database Persistence Demonstration

Database persistence is one of the most important demonstrations in the project.

## Step 1 – Add a Pet

Open PawCare and add a new pet.

Example:

```text
Name: Rocky
Breed: Golden Retriever
Age: 2
Species: Dog
```

## Step 2 – Refresh

Refresh the browser.

The newly added pet should still be available.

## Step 3 – Delete a PawCare Pod

Check the pods:

```bash
sudo kubectl get pods -l app=pawcare
```

Delete one:

```bash
sudo kubectl delete pod <pod-name>
```

## Step 4 – Wait for Replacement

```bash
sudo kubectl get pods -l app=pawcare -w
```

Kubernetes will create a replacement.

## Step 5 – Verify Data

Refresh PawCare.

The pet should still exist.

This demonstrates:

```text
Application Pod
      │
      ▼
PostgreSQL RDS
      │
      ▼
Persistent Data
      │
      ▼
Replacement Pod
      │
      ▼
Data Still Available
```

---

# 🔁 How to Re-run the Project

The project does not need to be rebuilt from scratch every time.

The Git repository contains the application, Kubernetes configuration, Jenkins pipeline, and Terraform configuration.

Navigate to the project:

```bash
cd PawCare-DevSecOps
```

Check Git status:

```bash
git status
```

Pull the latest changes:

```bash
git pull origin main
```

Check Kubernetes:

```bash
sudo kubectl get nodes
```

Check PawCare:

```bash
sudo kubectl get pods -l app=pawcare
```

If the AWS infrastructure and K3s cluster are already running, there is no need to recreate them just to deploy an application change.

---

# ✏️ How to Modify the Application

Application code:

```text
app/app.py
```

HTML template:

```text
app/templates/index.html
```

Python dependencies:

```text
app/requirements.txt
```

After making changes:

```bash
git add .
git commit -m "Update PawCare application"
git push origin main
```

Then run the Jenkins pipeline.

---

# ✏️ How to Modify Kubernetes Configuration

Kubernetes configuration is maintained in:

```text
deploy.yaml
service.yaml
```

For example, to change the number of replicas:

```yaml
spec:
  replicas: 3
```

Commit the change:

```bash
git add deploy.yaml
git commit -m "Scale PawCare deployment"
git push origin main
```

Run Jenkins to deploy the updated configuration.

---

# ✏️ How to Modify Terraform Infrastructure

Terraform configuration is located under:

```text
terraform/
```

After making infrastructure changes:

```bash
cd terraform
terraform validate
terraform plan
```

Review the plan carefully.

If the changes are correct:

```bash
terraform apply
```

---

# 🔄 Complete Re-run Workflow

The complete environment follows this order:

```text
1. AWS Infrastructure
        │
        ▼
2. K3s Cluster
        │
        ▼
3. PostgreSQL RDS
        │
        ▼
4. Kubernetes Secrets
        │
        ▼
5. PawCare Deployment
        │
        ▼
6. Kubernetes Service
        │
        ▼
7. Jenkins CI/CD
        │
        ▼
8. Docker Hub
        │
        ▼
9. Prometheus
        │
        ▼
10. Grafana
```

---

# 🧹 Complete Infrastructure Rebuild

If the entire AWS environment intentionally needs to be recreated, Terraform can be used.

First inspect the current infrastructure:

```bash
terraform plan
```

If you intentionally want to destroy the environment:

```bash
terraform destroy
```

After destruction:

```bash
terraform apply
```

> `terraform destroy` should only be used when you intentionally want to remove the AWS infrastructure.

---

# 🔎 Useful Kubernetes Commands

## Check Nodes

```bash
sudo kubectl get nodes
```

## Check All Pods

```bash
sudo kubectl get pods -A
```

## Check PawCare Pods

```bash
sudo kubectl get pods -l app=pawcare
```

## Check Deployment

```bash
sudo kubectl get deployment pawcare
```

## Check Service

```bash
sudo kubectl get service
```

## Check Application Logs

```bash
sudo kubectl logs -l app=pawcare
```

## Describe a Pod

```bash
sudo kubectl describe pod <pod-name>
```

## Describe Deployment

```bash
sudo kubectl describe deployment pawcare
```

## Check Rollout

```bash
sudo kubectl rollout status deployment/pawcare
```

## Restart Deployment

```bash
sudo kubectl rollout restart deployment/pawcare
```

## View Rollout History

```bash
sudo kubectl rollout history deployment/pawcare
```

## Check Monitoring Pods

```bash
sudo kubectl get pods -n monitoring
```

## Check Monitoring Services

```bash
sudo kubectl get svc -n monitoring
```

---

# 🔐 Security Practices

The project follows several DevSecOps security practices.

## Kubernetes Secrets

Database credentials are provided through Kubernetes Secrets instead of being hardcoded in application source code.

## Database Security

PostgreSQL access is controlled using AWS Security Groups.

## Git Security

Sensitive information should not be committed to GitHub.

This includes:

- Passwords
- SSH private keys
- AWS credentials
- Database credentials
- Kubernetes Secret files containing real credentials
- `.env` files

## Container Security

The application is packaged into a controlled Docker image.

## Infrastructure Security

AWS Security Groups restrict network access to required ports.

## Infrastructure as Code

Terraform provides version-controlled infrastructure configuration.

---

# 🛡️ Recommended .gitignore

The repository should ignore local development files and sensitive information.

Example:

```text
__pycache__/
*.pyc
venv/
.env
*.pem
.terraform/
*.tfstate
*.tfstate.backup
```

Sensitive credentials must never be committed to GitHub.

---

# 📁 Final Project Structure

The project should be maintained as one repository and one project folder.

```text
PawCare-DevSecOps/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
│       └── index.html
│
├── terraform/
│   ├── main.tf
│   ├── output.tf
│   └── .terraform.lock.hcl
│
├── Dockerfile
├── Jenkinsfile
├── deploy.yaml
├── service.yaml
├── inventory.ini
├── requirements.txt
├── .gitignore
└── README.md
```

---

# 📂 Directory Explanation

## `app/`

Contains the PawCare Flask application.

### `app.py`

Contains the application logic.

### `requirements.txt`

Contains Python dependencies.

### `templates/`

Contains HTML templates.

---

## `terraform/`

Contains Infrastructure as Code.

### `main.tf`

Defines AWS infrastructure.

### `output.tf`

Defines useful Terraform outputs.

### `.terraform.lock.hcl`

Locks Terraform provider versions.

---

## `Dockerfile`

Defines how the PawCare application is packaged into a Docker image.

---

## `Jenkinsfile`

Defines the Jenkins CI/CD pipeline.

---

## `deploy.yaml`

Defines the PawCare Kubernetes Deployment.

---

## `service.yaml`

Defines the Kubernetes Service.

---

## `inventory.ini`

Contains infrastructure information used for remote access or automation where applicable.

---

## `.gitignore`

Prevents unnecessary and sensitive files from being committed.

---

## `README.md`

Contains complete project documentation.

---

# 🔄 Complete End-to-End DevSecOps Workflow

```text
                         Developer
                             │
                             │ Git Push
                             ▼
                          GitHub
                             │
                             ▼
                          Jenkins
                             │
                 ┌───────────┴───────────┐
                 │                       │
                 ▼                       ▼
        Application Validation      Docker Build
                                         │
                                         ▼
                                   Docker Image
                                         │
                                         ▼
                                     Docker Hub
                                         │
                                         ▼
                                  K3s Kubernetes
                                         │
                             ┌───────────┴───────────┐
                             │                       │
                             ▼                       ▼
                       PawCare Pod 1           PawCare Pod 2
                             │                       │
                             └───────────┬───────────┘
                                         │
                                         ▼
                                   PostgreSQL RDS

                                         │
                                         ▼
                                  Kubernetes Metrics
                                         │
                                         ▼
                                     Prometheus
                                         │
                                         ▼
                                      Grafana
```

---

# 🔐 DevSecOps Lifecycle

The project demonstrates the following lifecycle:

```text
PLAN
  │
  ▼
CODE
  │
  ▼
BUILD
  │
  ▼
CONTAINERIZE
  │
  ▼
PUBLISH
  │
  ▼
DEPLOY
  │
  ▼
RUN
  │
  ▼
MONITOR
  │
  ▼
IMPROVE
```

---

# 🎯 Project Demonstration Flow

The following sequence can be used to demonstrate the project.

## 1. Explain the Problem

Manual application deployment requires repetitive activities such as:

- Building the application
- Creating Docker images
- Uploading images
- Connecting to servers
- Deploying containers
- Restarting applications
- Verifying application health

The project automates these processes.

---

## 2. Explain the Solution

The project integrates:

```text
Terraform
+
AWS
+
Docker
+
Jenkins
+
Kubernetes
+
PostgreSQL RDS
+
Prometheus
+
Grafana
```

---

## 3. Show AWS Infrastructure

Demonstrate:

- VPC
- Subnets
- EC2 instances
- Security Groups
- RDS

Explain that Terraform provisions and manages the infrastructure.

---

## 4. Show Terraform

Run:

```bash
terraform plan
```

and:

```bash
terraform output
```

Explain that infrastructure is defined as code.

---

## 5. Show K3s

Run:

```bash
sudo kubectl get nodes
```

Explain:

```text
1 Master
2 Workers
```

---

## 6. Show PawCare Pods

Run:

```bash
sudo kubectl get pods -l app=pawcare
```

Show the two running replicas.

---

## 7. Demonstrate PawCare

Open the application and demonstrate:

- Viewing pets
- Adding a pet
- Adopting a pet
- Health endpoint

---

## 8. Demonstrate Database Persistence

Add a pet.

Delete one PawCare pod.

Wait for Kubernetes to create the replacement.

Refresh the application.

Show that the pet is still available.

Explain:

```text
Kubernetes Pod = Temporary
PostgreSQL RDS = Persistent
```

---

## 9. Show Jenkins

Run the Jenkins pipeline.

Explain:

```text
GitHub
   ↓
Jenkins
   ↓
Docker Build
   ↓
Docker Hub
   ↓
Kubernetes
```

---

## 10. Show Docker Hub

Show the PawCare image and its version tag.

Explain that Kubernetes pulls the image from Docker Hub.

---

## 11. Show Kubernetes Rolling Update

Run:

```bash
sudo kubectl rollout status deployment/pawcare
```

Explain how Kubernetes replaces the old application version with the new version.

---

## 12. Show Grafana

Open Grafana and demonstrate:

- Kubernetes nodes
- Pod availability
- CPU
- Memory
- Pod restarts
- Cluster resources

Explain:

```text
Kubernetes
    ↓
Prometheus
    ↓
Grafana
```

---

# 🧠 Key DevOps Concepts Demonstrated

## Infrastructure as Code

Terraform defines AWS infrastructure as code.

## Continuous Integration

Jenkins retrieves and validates application changes.

## Continuous Delivery

Jenkins builds the Docker image, pushes it to Docker Hub, and deploys the application to Kubernetes.

## Containerization

Docker packages the application into a portable image.

## Container Registry

Docker Hub stores deployable application images.

## Kubernetes

K3s manages:

- Pods
- Deployments
- Services
- Replicas
- Self-healing
- Rolling updates

## Persistent Storage

PostgreSQL RDS stores application data independently from Kubernetes pods.

## Secrets Management

Kubernetes Secrets provide sensitive database configuration.

## Monitoring

Prometheus collects metrics and Grafana visualizes them.

## Git-Based Management

GitHub stores:

- Application source code
- Docker configuration
- Jenkins pipeline
- Kubernetes configuration
- Terraform configuration

---

# 📈 Why Kubernetes Is Used

Kubernetes provides:

### Self-Healing

Failed pods are automatically recreated.

### Scaling

The number of application replicas can be increased.

For example:

```yaml
replicas: 3
```

### Rolling Updates

New application versions can be deployed gradually.

### Service Discovery

Kubernetes Services provide stable access to changing pod IP addresses.

### Declarative Configuration

The desired application state is defined using YAML files.

---

# 📈 Why Docker Is Used

Docker provides:

- Consistent environments
- Application isolation
- Portable application packaging
- Versioned application images
- Easy Kubernetes integration

---

# 📈 Why Terraform Is Used

Terraform allows infrastructure to be:

- Version controlled
- Reviewed
- Recreated
- Automated
- Consistent

Instead of manually creating every AWS resource, infrastructure is defined using Terraform configuration.

---

# 📈 Why Jenkins Is Used

Without Jenkins:

```text
Developer
   ↓
Manual Build
   ↓
Manual Docker Build
   ↓
Manual Push
   ↓
Manual Kubernetes Deployment
```

With Jenkins:

```text
Developer
   ↓
Git Push
   ↓
Jenkins
   ↓
Automated Build
   ↓
Docker
   ↓
Docker Hub
   ↓
Kubernetes
```

---

# 📈 Why Amazon RDS Is Used

Amazon RDS provides managed PostgreSQL database infrastructure.

The application does not depend on the lifecycle of an individual Kubernetes pod for persistent data.

The architecture is:

```text
Application Layer
       │
       ▼
Kubernetes
       │
       ▼
Database Layer
       │
       ▼
Amazon RDS
```

---

# 📈 Why Prometheus and Grafana Are Used

A deployed application should not only be running; it should also be observable.

Prometheus provides:

```text
Metric Collection
```

Grafana provides:

```text
Metric Visualization
```

Together:

```text
Kubernetes
    │
    ▼
Prometheus
    │
    ▼
Grafana
```

This provides visibility into the health and resource utilization of the Kubernetes environment.

---

# 🛠️ Operational Health Checks

Before considering the application healthy, verify the following.

## AWS

Verify that the required AWS resources are running.

## Kubernetes

```bash
sudo kubectl get nodes
```

All Kubernetes nodes should show:

```text
Ready
```

## PawCare Pods

```bash
sudo kubectl get pods -l app=pawcare
```

Both replicas should be running.

## Deployment

```bash
sudo kubectl rollout status deployment/pawcare
```

## Service

```bash
sudo kubectl get svc
```

## Database

Verify that PawCare can retrieve and store pet data.

## Monitoring

```bash
sudo kubectl get pods -n monitoring
```

Prometheus and Grafana components should be running.

---

# 🚀 Future Enhancements

The current project can be extended with:

- Argo CD for GitOps-based continuous reconciliation
- Terraform remote state using Amazon S3
- Terraform state locking
- AWS Load Balancer
- HTTPS/TLS
- Route 53 domain integration
- Horizontal Pod Autoscaling
- Kubernetes NetworkPolicies
- Container vulnerability scanning
- Image signing
- Automated security gates
- Centralized logging using Loki
- Prometheus alerting
- Grafana alerts
- Application-level metrics
- Database backup and recovery
- High-availability Kubernetes control plane
- Separate development, staging, and production environments
- Automated rollback
- Blue/Green deployments
- Canary deployments

These are future enhancements and are not part of the current implementation.

---

# 📌 Current Project Scope

The current project focuses on an end-to-end DevSecOps deployment of the PawCare application.

The primary components are:

```text
Flask Application
        +
PostgreSQL
        +
Docker
        +
Docker Hub
        +
Jenkins
        +
Kubernetes / K3s
        +
AWS
        +
Terraform
        +
Prometheus
        +
Grafana
```

The project is intended to demonstrate practical DevOps, Cloud, Kubernetes, CI/CD, Infrastructure as Code, database persistence, and monitoring concepts.

---

# 🏁 Final Project Outcome

PawCare demonstrates a complete cloud-native DevSecOps workflow:

```text
Terraform
    │
    ▼
AWS Infrastructure
    │
    ▼
Self-Managed K3s Cluster
    │
    ▼
Dockerized Flask Application
    │
    ▼
Jenkins CI/CD
    │
    ▼
Docker Hub
    │
    ▼
Kubernetes Deployment
    │
    ▼
PostgreSQL RDS
    │
    ▼
Persistent Application Data
    │
    ▼
Prometheus
    │
    ▼
Grafana
```

The project demonstrates how infrastructure provisioning, application development, containerization, CI/CD, Kubernetes orchestration, persistent database storage, self-healing, rolling deployments, and monitoring can be integrated into one complete DevSecOps workflow.

---

# ⭐ Project Highlights

- AWS cloud infrastructure
- Terraform Infrastructure as Code
- Custom AWS VPC
- Public and private subnets
- EC2-based self-managed Kubernetes
- K3s cluster
- 1 Master + 2 Worker architecture
- Dockerized Flask application
- Docker Hub container registry
- Jenkins CI/CD automation
- Kubernetes Deployment
- Two PawCare replicas
- Kubernetes Service
- PostgreSQL database
- Amazon RDS persistence
- Kubernetes Secrets
- Kubernetes self-healing
- Rolling deployments
- Helm
- Prometheus
- Grafana
- Git and GitHub
- Persistent application data
- Infrastructure monitoring

---

# 👩‍💻 Author

## Shreya Maidaragi

DevOps / Cloud Engineering Project

### Technologies Demonstrated

```text
AWS
Terraform
Linux
Docker
Docker Hub
Kubernetes
Jenkins
Git
GitHub
Python
PostgreSQL
Amazon RDS
Helm
Prometheus
Grafana
```

---

# ⭐ Project Summary

**PawCare is a Git-driven DevSecOps application deployed on a self-managed Kubernetes cluster running on AWS, with Terraform-managed infrastructure, Jenkins-based CI/CD, Docker-based containerization, Docker Hub image management, PostgreSQL persistence through Amazon RDS, Kubernetes Secrets for secure configuration, and Prometheus/Grafana monitoring.**

The project demonstrates the complete lifecycle from infrastructure provisioning and application development to automated deployment, persistent storage, Kubernetes self-healing, rolling updates, and infrastructure observability.
