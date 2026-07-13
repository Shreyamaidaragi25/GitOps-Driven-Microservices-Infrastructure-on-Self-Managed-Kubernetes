# ☸️ GitOps-Driven Microservices Infrastructure on Self-Managed Kubernetes

This repository contains the complete implementation of a production-ready, cloud-native microservices platform. The entire lifecycle—encompassing infrastructure provisioning, configuration management, containerization, orchestration, and continuous observability—is managed completely as code.

Instead of relying on heavy, black-box managed cloud platforms, this architecture implements a lightweight, self-managed **K8s Kubernetes** cluster across standard cloud compute instances, providing enterprise-grade infrastructure orchestration with near-zero overhead.

---

## 🏗️ Architecture Overview

The following diagram illustrates the deployment pipeline and system runtime topology:

```text
                        +-------------------+
                        |   Local VS Code   |
                        +---------+---------+
                                  |
                   (Terraform)    |    (Ansible Playbooks)
                                  v
                        +-------------------+
                        |   AWS VPC Space   |
                        |  (Custom Subnet)  |
                        +---------+---------+
                                  |
         +------------------------+------------------------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|  Control Plane   |     |  Worker Node 01  |     |  Worker Node 02  |
|  (K8s Master)    |     |   (K8s Worker)   |     |   (K8s Worker)   |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         | (Orchestration)        |                        |
         +------------------------+------------------------+
                                  |
                                  v
                 +--------------------------------+
                 |    Kubernetes Pod Ecosystem    |
                 |  [Flask Pod] [Flask Pod] [...] |
                 +----------------+---------------+
                                  |
                                  v
                 +--------------------------------+
                 |  Observability (Namespace)     |
                 |  [Prometheus] ---> [Grafana]   |
                 +----------------+---------------+

---
```
# 🛠 Technologies Used

| Category | Tool |
|-----------|------|
| Cloud | AWS EC2 |
| IaC | Terraform |
| Configuration Management | Ansible |
| Containerization | Docker |
| Orchestration | Kubernetes (K8s) |
| Monitoring | Prometheus |
| Visualization | Grafana |
| Application | Python Flask |
| Version Control | Git & GitHub |

---
```
# 📂 Project Structure

GitOps-K8s-Capstone/
├── terraform/
│   ├── main.tf                 # Core AWS infrastructure configurations
│   ├── output.tf               # Structural dynamic outputs for node matching
│   └── terraform.tfvars        # Cloud variable assignment
├── ansible/
│   ├── inventory.ini           # System targeted configuration bindings
│   └── install-docker.yml      # Cluster runtime orchestration playbook
├── app/
│   ├── app.py                  # Core microservice framework logic
│   ├── requirements.txt        # Hardened dependency definitions
│   └── Dockerfile              # Minimized Multi-stage compilation config
├── k8s/
│   ├── deploy.yaml             # Cluster ReplicaSet state manifests
│   └── service.yaml            # Load-balanced routing interfaces
├── screenshots/                # Validation & structural run verification captures
└── README.md                   # System operational manual

```

---

# 🚀 Step 1: Provision Infrastructure using Terraform

## Initialize Terraform

```bash
terraform init
```

## Validate Configuration

```bash
terraform validate
```

## Preview Infrastructure

```bash
terraform plan
```

## Create Infrastructure

```bash
terraform apply 
```
<img width="1052" height="995" alt="Screenshot 2026-07-12 235748" src="https://github.com/user-attachments/assets/2f6bdfaf-3416-4774-a969-1b07861062d4" />

Terraform provisions:

- Custom VPC
- Public Subnet
- Security Group
- 1 K8s Master Node
- 2 K8s Worker Nodes

---
<img width="1272" height="367" alt="Screenshot 2026-07-12 235800" src="https://github.com/user-attachments/assets/b07f8f27-dfa8-4172-b8a4-a29a29913808" />
---

```

# 🚀 Step 1.1: Connect to EC2 Instances

After Terraform provisions the infrastructure, retrieve the public IP addresses:

```bash
terraform output
```

Example Output:

```text
master_public_ip  = 15.206.xx.xx
worker1_public_ip = 13.xx.xx.xx
worker2_public_ip = 43.xx.xx.xx
```

---

## SSH into Master Node

```bash
ssh -i ubuntu.pem ubuntu@<MASTER_PUBLIC_IP>
```

Example:

```bash
ssh -i ubuntu.pem ubuntu@15.206.xx.xx
```

Verify hostname:

```bash
hostname
```

Expected:

```text
ip-10-0-1-45
```

---

## Verify Private IP Address of Master

```bash
hostname -I
```

Expected:

```text
10.0.1.45
```

---

## SSH into Worker Node 1

```bash
ssh -i ubuntu.pem ubuntu@<WORKER1_PUBLIC_IP>
```

Example:

```bash
ssh -i ubuntu.pem ubuntu@13.xx.xx.xx
```

Verify:

```bash
hostname
```

Expected:

```text
ip-10-0-1-13
```

---

## Verify Private IP Address of Worker 1

```bash
hostname -I
```

Expected:

```text
10.0.1.13
```

---

## SSH into Worker Node 2

```bash
ssh -i ubuntu.pem ubuntu@<WORKER2_PUBLIC_IP>
```

Example:

```bash
ssh -i ubuntu.pem ubuntu@43.xx.xx.xx
```

Verify:

```bash
hostname
```

Expected:

```text
ip-10-0-1-38
```

---

## Verify Private IP Address of Worker 2

```bash
hostname -I
```

Expected:

```text
10.0.1.38
```

---

## Copy SSH Key to Master Node

From your local machine:

```bash
scp -i ubuntu.pem ubuntu.pem ubuntu@<MASTER_PUBLIC_IP>:/home/ubuntu/
```

Example:

```bash
scp -i ubuntu.pem ubuntu.pem ubuntu@15.206.xx.xx:/home/ubuntu/
```

---

## Secure the SSH Key on Master

SSH back into the Master Node:

```bash
ssh -i ubuntu.pem ubuntu@<MASTER_PUBLIC_IP>
```

Set proper permissions:

```bash
chmod 400 /home/ubuntu/ubuntu.pem
```

Verify:

```bash
ls -l /home/ubuntu/ubuntu.pem
```

Expected:

```text
-r-------- 1 ubuntu ubuntu
```

---

## Verify SSH Access from Master to Worker 1

```bash
ssh -i ubuntu.pem ubuntu@10.0.1.13
```

Expected:

```text
ubuntu@ip-10-0-1-13
```

Exit:

```bash
exit
```

---

## Verify SSH Access from Master to Worker 2

```bash
ssh -i ubuntu.pem ubuntu@10.0.1.38
```

Expected:

```text
ubuntu@ip-10-0-1-38
```

Exit:

```bash
exit
```

---

## Verify Node Connectivity

From Master Node:

```bash
ping -c 4 10.0.1.13
```

```bash
ping -c 4 10.0.1.38
```

Expected:

```text
64 bytes from 10.0.1.13
64 bytes from 10.0.1.38
```

If connectivity is successful, proceed with K3s cluster installation.

# 🚀 Step 2: Configure Kubernetes Cluster (K8s)

## Install K8s on Master

```bash
curl -sfL https://get.K8s.io | sh -
```

Verify:

```bash
sudo kubectl get nodes
```

---

## Get Cluster Join Token

```bash
sudo cat /var/lib/rancher/K8s/server/node-token
```

---

## Get Master Private IP

```bash
hostname -I
```

---

## Join Worker Nodes

```bash
curl -sfL https://get.K8s.io | \
K3S_URL=https://<MASTER_PRIVATE_IP>:6443 \
K3S_TOKEN=<TOKEN> \
sh -
```

---

## Verify Cluster

```bash
sudo kubectl get nodes
```

Expected Output:

```text
master     Ready
worker-1   Ready
worker-2   Ready
```
<img width="1388" height="613" alt="Screenshot 2026-07-13 001924" src="https://github.com/user-attachments/assets/9c36a5fa-8d83-4919-920d-df6eada8c8d1" />
---

# 🚀 Step 3: Install Docker using Ansible

## Install Ansible

```bash
sudo apt update
sudo apt install ansible -y
```

---

## Create Inventory

```ini
[k8s_master]
10.0.1.45

[K8s_workers]
10.0.1.13
10.0.1.38

[K8s_cluster:children]
k8s_master
k8s_workers

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=/home/ubuntu/ubuntu.pem
```

---

## Verify Connectivity

```bash
ansible all -i inventory.ini -m ping
```
<img width="1440" height="751" alt="Screenshot 2026-07-13 003723" src="https://github.com/user-attachments/assets/11637dfd-9fca-4c4b-a75e-73bd1d59b9fb" />
---

## Install Docker Playbook

```yaml
---
- name: Install Docker
  hosts: K8s_cluster
  become: yes

  tasks:

    - name: Install Docker
      apt:
        name: docker.io
        state: present
        update_cache: yes

    - name: Start Docker
      service:
        name: docker
        state: started
        enabled: yes
```

---

## Execute Playbook

```bash
ansible-playbook -i inventory.ini install-docker.yml
```
<img width="1082" height="666" alt="Screenshot 2026-07-13 004540" src="https://github.com/user-attachments/assets/44b9fb81-187f-4288-b672-090541ff222a" />

---

# 🚀 Step 4: Build Flask Application

## app.py

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "GitOps Infrastructure Project Running Successfully!"

@app.route("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## requirements.txt

```text
flask==3.0.3
```

---

## Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY app/ .

EXPOSE 5000

CMD ["python","app.py"]
```

---

# 🚀 Step 5: Build and Push Docker Image

## Build Image

```bash
docker build -t <dockerhub-username>/flask-app:latest .
```

---

## Login Docker Hub

```bash
docker login
```

---

## Push Image

```bash
docker push <dockerhub-username>/flask-app:latest
```
<img width="1202" height="952" alt="Screenshot 2026-07-13 010928" src="https://github.com/user-attachments/assets/21dff75a-c4bd-4989-a9ea-45471499bc67" />

---

# 🚀 Step 6: Deploy Application to Kubernetes

## Deployment Manifest

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app

spec:
  replicas: 3

  selector:
    matchLabels:
      app: flask-app

  template:
    metadata:
      labels:
        app: flask-app

    spec:
      containers:
      - name: flask-app
        image: <dockerhub-username>/flask-app:latest

        ports:
        - containerPort: 5000
```

---

## Service Manifest

```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-service

spec:
  selector:
    app: flask-app

  type: NodePort

  ports:
  - port: 5000
    targetPort: 5000
    nodePort: 30090
```

---

## Apply Manifests

```bash
kubectl apply -f deploy.yaml
kubectl apply -f service.yaml
```
<img width="985" height="960" alt="Screenshot 2026-07-13 011736" src="https://github.com/user-attachments/assets/5152f796-7fb8-4d5d-ac44-468d0ed70065" />

---

## Verify Deployment

```bash
kubectl get deployments
kubectl get pods
kubectl get svc
```
<img width="1380" height="465" alt="Screenshot 2026-07-13 005129" src="https://github.com/user-attachments/assets/6209cc7a-60c7-4bd2-8b66-63dee56b580c" />
<img width="847" height="257" alt="Screenshot 2026-07-13 011923" src="https://github.com/user-attachments/assets/5ab0cb94-7128-4792-9fd6-0ec553b8467b" />
---

## Access Application

```text
http://<MASTER_PUBLIC_IP>:30090
```

Expected Output:

```text
GitOps Infrastructure Project Running Successfully!
```
<img width="497" height="128" alt="Screenshot 2026-07-13 020701" src="https://github.com/user-attachments/assets/c9c22946-2a17-4893-8592-fdffbf94bdb8" />

---

# 🚀 Step 7: Monitoring with Prometheus & Grafana

## Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

## Add Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

---

## Create Monitoring Namespace

```bash
kubectl create namespace monitoring
```


---

## Install Monitoring Stack

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring
```

---

## Verify Pods

```bash
kubectl get pods -n monitoring
```

Expected:

```text
grafana
prometheus
alertmanager
node-exporter
kube-state-metrics
```
<img width="888" height="281" alt="Screenshot 2026-07-13 021003" src="https://github.com/user-attachments/assets/aced8ca0-0119-41a7-aa3d-1da0ba9e2af7" />

---

## Expose Grafana

```bash
kubectl patch svc monitoring-grafana \
-n monitoring \
-p '{"spec":{"type":"NodePort"}}'
```

---

## Get Grafana Service

```bash
kubectl get svc -n monitoring
```

Example:

```text
monitoring-grafana   NodePort   80:30519/TCP
```
<img width="1107" height="287" alt="Screenshot 2026-07-13 021059" src="https://github.com/user-attachments/assets/33bca70b-880e-451b-bc75-022f0939443a" />

---

## Access Grafana

```text
http://<MASTER_PUBLIC_IP>:30519
```
<img width="602" height="542" alt="Screenshot 2026-07-13 021318" src="https://github.com/user-attachments/assets/f6520cf4-ea49-4f53-9e67-eb8eb69b785e" />

---

## Retrieve Grafana Password

```bash
kubectl get secret monitoring-grafana \
-n monitoring \
-o jsonpath="{.data.admin-password}" | base64 --decode
```

---

# 📊 Monitoring Dashboard

Grafana provides:

- CPU Usage
- Memory Usage
- Disk Utilization
- Network Traffic
- Kubernetes Cluster Metrics
- Node Exporter Metrics

---
<img width="1670" height="916" alt="Screenshot 2026-07-13 022319" src="https://github.com/user-attachments/assets/ac4ef656-d25f-4ff2-b21d-a13832a5a3cf" />

<img width="876" height="227" alt="Screenshot 2026-07-13 023300" src="https://github.com/user-attachments/assets/4ca8526a-5737-415a-9352-68cfe729ba53" />

<img width="1418" height="811" alt="Screenshot 2026-07-13 023450" src="https://github.com/user-attachments/assets/f1d6fa32-f333-43ee-93fc-e307630314ec" />

# 📸 Screenshots

Add screenshots for:

- AWS EC2 Instances
- Terraform Apply Output
- Kubernetes Nodes
- Kubernetes Pods
- Flask Application
- Grafana Dashboard
---

# 🎯 Key Learning Outcomes

- Infrastructure as Code using Terraform
- Kubernetes Cluster Administration
- Docker Containerization
- Configuration Management with Ansible
- Application Deployment on Kubernetes
- Monitoring and Visualization using Prometheus and Grafana
- GitOps and DevOps Best Practices

---

# 👩‍💻 Author

**Shreya Maidaragi**

DevOps | Cloud | Kubernetes | AWS

GitHub: https://github.com/<your-github-username>

LinkedIn: https://linkedin.com/in/shreya-maidaragi-a5a5b0214

---
⭐ If you found this project useful, don't forget to star the repository.

