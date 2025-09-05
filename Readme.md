# 🚀 Flask Application Deployment on AWS EKS

This project demonstrates how to **deploy a Flask-based web application** on **Amazon EKS** using **Terraform** for infrastructure, **Docker** for containerization, and **Kubernetes** for orchestration. It also integrates **PostgreSQL**, **Horizontal Pod Autoscaling (HPA)**, and an **AWS ALB Ingress** for external access.

---

## 📌 Project Overview
This project automates the entire process of deploying a production-ready Flask application on **AWS EKS**:
- Provision AWS infrastructure using **Terraform**
- Build & push Flask Docker images to **AWS ECR**
- Deploy **Flask App** & **PostgreSQL** on **Amazon EKS**
- Configure **Horizontal Pod Autoscaler (HPA)** for scaling
- Expose the app using **AWS ALB Ingress**
- Manage the entire workflow via a **Makefile**

---

## 🏗️ Architecture Overview
```
                    +--------------------------+
                    |        AWS EKS           |
                    |   (Kubernetes Cluster)   |
                    +------------+-------------+
                                 |
                 +---------------+----------------+
                 |                                |
        +--------v---------+            +----------v--------+
        |  Flask App Pods  |            | PostgreSQL Pod    |
        | (Deployment +    |            | (StatefulSet)     |
        |  Service)        |            | Persistent Volume |
        +------------------+            +-------------------+
                 |
        +--------v--------+
        |  ALB Ingress    |
        | (External DNS)  |
        +-----------------+
```

---

## ⚙️ Technologies Used
| Technology      | Purpose                                |
|----------------|----------------------------------------|
| **AWS EKS**    | Managed Kubernetes service            |
| **Terraform**  | Infrastructure as Code (IaC)          |
| **Docker**     | Flask app containerization            |
| **AWS ECR**    | Private container registry            |
| **PostgreSQL** | Database for the Flask app            |
| **Kubernetes** | Deployments, StatefulSets, PVC, HPA   |
| **AWS ALB**    | Exposes the application externally   |

---

## 📂 Project Structure
```
eks-flask-app/
├── terraform/                     # Terraform scripts for AWS infra
│   ├── main.tf                    # Creates VPC, EKS, NodeGroups, ECR, S3
│   ├── variables.tf               # Input variables
│   ├── provider.tf                # AWS provider setup
│   └── outputs.tf                 # Terraform outputs
│
├── flask-app/                     # Flask app source code
│   ├── app.py                     # Main Flask app
│   ├── Dockerfile                 # Flask app Dockerfile
│   └── requirements.txt          # Python dependencies
│
├── k8s/                           # Kubernetes manifests
│   ├── namespace.yaml
│   ├── flask-deployment.yaml
│   ├── flask-service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── postgres-secret.yaml
│   ├── postgres-pvc.yaml
│   ├── postgres-service.yaml
│   └── postgres-statefulset.yaml
│
├── Makefile                      # Automates the entire workflow
└── README.md                     # Project documentation
```

---

## 🚀 Setup & Deployment
### 1️⃣ Clone the Repository
```bash
git clone https://github.com/<your-username>/eks-flask-app.git
cd eks-flask-app
```

### 2️⃣ Configure AWS CLI
```bash
aws configure
```
Provide:
- **AWS Access Key**
- **AWS Secret Key**
- **Default Region** (us-east-1)

### 3️⃣ Provision AWS Infrastructure
```bash
make init
make apply
```
This will:
- Create an **EKS Cluster**
- Create **Node Groups**
- Setup **ECR & S3 bucket**
- Configure **networking & IAM roles**

### 4️⃣ Build & Push Flask Docker Image
```bash
make docker-push
```
This will:
- Build the Docker image
- Create an **ECR repository** (if missing)
- Push the image to **AWS ECR**

### 5️⃣ Deploy Application & Database
```bash
make deploy-all
```
This will:
- Configure **kubeconfig** for EKS
- Create namespace (**flask-app**)
- Deploy **PostgreSQL** (StatefulSet + PVC + Service)
- Deploy **Flask App** (Deployment + Service)
- Deploy **Ingress Controller** for ALB
- Deploy **Horizontal Pod Autoscaler**

### 6️⃣ Verify Deployment
```bash
make get-all
```
Or check individual resources:
```bash
make get-pods
make get-services
make get-ingress
make get-hpa
```

### 7️⃣ Access the Application
```bash
kubectl get ingress -n flask-app
```
Copy the **ALB DNS** and open it in your browser.

---

## 📈 Horizontal Pod Autoscaling
The **HPA** automatically scales Flask pods based on CPU & memory usage.

Check HPA status:
```bash
make get-hpa
```

Simulate load:
```bash
kubectl run -i --tty load-generator --image=busybox --restart=Never -- sh
while true; do wget -q -O- http://<FLASK_SERVICE_IP>; done
```

---

## 🧹 Cleanup
Delete Kubernetes resources:
```bash
make delete-all
```
Destroy AWS infrastructure:
```bash
make destroy
```

---

## 📝 Key Makefile Commands
| Command         | Description                          |
|---------------|--------------------------------------|
| `make init`   | Initialize Terraform                 |
| `make apply`  | Create AWS infrastructure            |
| `make docker-push` | Build & push Docker image to ECR |
| `make deploy-all`  | Deploy Flask, PostgreSQL, HPA & Ingress |
| `make get-all`     | Get all Kubernetes resources    |
| `make delete-all`  | Delete all Kubernetes resources |
| `make destroy`     | Destroy entire AWS infra        |

---

## 🏁 Final Output
✅ Flask App running on **AWS EKS**  
✅ Integrated with **PostgreSQL DB**  
✅ Exposed via **AWS ALB DNS**  
✅ Auto-scalable using **HPA**  
✅ Fully automated with a **Makefile**

