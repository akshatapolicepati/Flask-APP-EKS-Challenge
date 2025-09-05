# -------------------------------
# Project Variables
# -------------------------------
AWS_REGION      := us-east-1
AWS_ACCOUNT_ID  := 804540873939
ECR_REPO        := flask-ecr
ECR_URI         := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPO)
CLUSTER_NAME    := eks-cluster
NAMESPACE       := flask-app
FLASK_DIR       := flask-app
K8S_DIR         := k8s
TERRAFORM_DIR   := terraform

# -------------------------------
# Terraform Commands
# -------------------------------
init:
	@echo "\n🚀 Initializing Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

plan:
	@echo "\n📦 Generating Terraform Plan..."
	cd $(TERRAFORM_DIR) && terraform plan

apply:
	@echo "\n🌎 Applying Terraform to create AWS Infrastructure..."
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

destroy:
	@echo "\n💀 Destroying AWS Infrastructure..."
	cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

# -------------------------------
# ECR & Docker Commands
# -------------------------------
ecr-login:
	@echo "\n🔐 Logging in to AWS ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

ecr-create:
	@echo "\n📦 Creating ECR Repository if it doesn't exist..."
	aws ecr describe-repositories --repository-names $(ECR_REPO) --region $(AWS_REGION) || \
	aws ecr create-repository --repository-name $(ECR_REPO) --region $(AWS_REGION)

docker-build:
	@echo "\n🐳 Building Flask App Docker Image..."
	cd $(FLASK_DIR) && docker build -t $(ECR_REPO) .

docker-push: ecr-login ecr-create docker-build
	@echo "\n🚀 Pushing Docker Image to ECR..."
	docker tag $(ECR_REPO):latest $(ECR_URI):latest
	docker push $(ECR_URI):latest

# -------------------------------
# Kubernetes Commands
# -------------------------------
kubeconfig:
	@echo "\n🔗 Updating kubeconfig for EKS..."
	aws eks update-kubeconfig --name $(CLUSTER_NAME) --region $(AWS_REGION)

create-namespace:
	@echo "\n📂 Creating Kubernetes Namespace..."
	kubectl apply -f $(K8S_DIR)/namespace.yaml

deploy-db:
	@echo "\n🛢️ Deploying PostgreSQL..."
	kubectl apply -f $(K8S_DIR)/postgres-secret.yaml
	kubectl apply -f $(K8S_DIR)/postgres-pvc.yaml
	kubectl apply -f $(K8S_DIR)/postgres-service.yaml
	kubectl apply -f $(K8S_DIR)/postgres-statefulset.yaml

deploy-app:
	@echo "\n🚀 Deploying Flask Application..."
	kubectl apply -f $(K8S_DIR)/flask-deployment.yaml
	kubectl apply -f $(K8S_DIR)/flask-service.yaml

deploy-ingress:
	@echo "\n🌐 Deploying ALB Ingress..."
	kubectl apply -f $(K8S_DIR)/ingress.yaml

deploy-hpa:
	@echo "\n📈 Deploying Horizontal Pod Autoscaler..."
	kubectl apply -f $(K8S_DIR)/hpa.yaml

deploy-all: kubeconfig create-namespace deploy-db deploy-app deploy-ingress deploy-hpa
	@echo "\n✅ Full Kubernetes Deployment Completed!"

# -------------------------------
# Verification & Monitoring
# -------------------------------
get-pods:
	kubectl get pods -n $(NAMESPACE)

get-services:
	kubectl get svc -n $(NAMESPACE)

get-ingress:
	kubectl get ingress -n $(NAMESPACE)

get-hpa:
	kubectl get hpa -n $(NAMESPACE)

get-pvc:
	kubectl get pvc -n $(NAMESPACE)

get-pv:
	kubectl get pv

get-all:
	kubectl get all -n $(NAMESPACE)

# -------------------------------
# Cleanup Kubernetes Resources
# -------------------------------
delete-all:
	@echo "\n🧹 Deleting All Kubernetes Resources..."
	kubectl delete -f $(K8S_DIR) --ignore-not-found=true

# -------------------------------
# End of Makefile
# -------------------------------

