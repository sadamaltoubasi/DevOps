# 🚀 Advanced Cloud Infrastructure & GitOps Engineering Portfolio
###
## 👨‍💻 About Me
A results-driven **DevOps Engineer** specializing in designing and orchestrating high-availability cloud infrastructure, secure cloud-native architectures, and robust automation frameworks. 

This portfolio demonstrates an elite capability to operate across **hybrid ecosystems (Multi-CI/CD Engines, Multi-IaC Workflows, and Advanced Container Orchestration)**. Every architectural blueprint featured here is engineered to production-grade standards, prioritizing strict quality gates, zero-trust cloud security (DevSecOps), and absolute infrastructure repeatability.

---

## 🛠️ Core Technology Matrix
* **Cloud & Platforms:** AWS (VPC, EKS, ECS, Elastic Beanstalk, RDS, ECR, Route 53, CloudFront, EventBridge, Lambda)
* **Infrastructure as Code (IaC):** Terraform (Modular Designs, Remote State Locking, tfsec)
* **Configuration Management:** Ansible (Dynamic Inventories, Modular Roles, AWS Boto Automation)
* **Containerization & K8s:** Kubernetes (Ingress, PVC, EBS StorageClasses, Secrets), Docker, Docker Compose, Helm
* **CI/CD & GitOps:** GitLab CI, GitHub Actions, Jenkins, AWS CodePipeline (Build, Deploy)
* **DevSecOps & Quality:** SonarQube, SonarCloud, Trivy Container Scan, Checkstyle

---

## 🏆 Featured Architectures (Primary Showcase)
*These core projects demonstrate my ability to architect and manage highly complex, multi-environment enterprise lifecycles with absolute precision.*

### 1️⃣ Hybrid GitOps Infrastructure Automation (GitLab CI/CD & Amazon EKS)
* **The Challenge:** Enforcing zero-trust security and preventing configuration drift in cloud-native application delivery without storing permanent static cloud access keys.
* **The Solution:** Engineered a sophisticated dual-track GitOps pipeline within GitLab CI. The infrastructure pipeline utilizes Terraform with static security analysis via `tfsec` to provision an enterprise-grade AWS VPC and Amazon EKS cluster. The application delivery pipeline leverages OpenID Connect (OIDC) via AWS STS for temporary token exchange, runs automated unit tests, executes container vulnerability scans using `Trivy`, and automates application rollout into isolated worker node pools using Helm Charts.
* **Tech Stack:** GitLab CI/CD, Terraform, tfsec, Trivy, Amazon EKS, Helm, AWS ECR, OIDC.
* **Architecture Blueprint:**
  ![GitLab CI EKS GitOps Pipeline](./images/GitOps%20with%20Github%20Actions.png)

### 2️⃣ Unified Enterprise IaC & Configuration Management Framework (Jenkins & Ansible)
* **The Challenge:** Automating the structural provisioning and configuration execution gap between raw cloud infrastructure and environment node states for staging and production targets.
* **The Solution:** Built a unified provisioning engine. Terraform automates the delivery of a multi-AZ `vpro-vpc` managing scalable compute tiers inside Auto Scaling Groups backed by AWS RDS, RabbitMQ, and Memcached. Upon completion, a multi-stage Jenkins pipeline triggers an ephemeral Dockerized Ansible agent (`alpine/ansible`) to automatically establish secure SSH pipelines and apply precise configuration roles across separated staging and production workloads.
* **Tech Stack:** Jenkins, Terraform, Ansible, AWS VPC, Amazon RDS, Auto Scaling, Amazon ECR, SonarCloud, Slack.
* **Architecture Blueprint:**
  ![Jenkins Ansible Enterprise Framework](./images/Continuous%20Delivery%20And%20Configuration%20Management%20Jenkins%2C%20Ansible%20plus%20Terraform.png)

### 3️⃣ Multi-Track GitOps Application Delivery Lifecycle (GitHub Actions & ECS)
* **The Challenge:** Constructing a unified, low-latency workflow natively integrated into GitHub for rapid testing, security analysis, and container service deployments.
* **The Solution:** Formulated a declarative, matrix-based GitHub Actions workflow. Every code push initiates automated Maven testing and remote code quality scans inside SonarCloud. Validated code paths automatically trigger secure Docker multi-stage builds, pushing immutable container images into Amazon ECR registry buckets. The lifecycle concludes by executing progressive task definition adjustments across active Amazon ECS container tasks secured behind an Elastic Load Balancer (ELB).
* **Tech Stack:** GitHub Actions, Maven, SonarCloud, Docker, Amazon ECR, Amazon ECS, ELB.
* **Architecture Blueprint:**
  ![GitHub Actions ECS Pipeline](./images/Github%20Actions%20for%20CICD.png)

### 4️⃣ Serverless Cloud-Native CI/CD Pipeline (AWS CodePipeline)
* **The Challenge:** Abstracting pipeline computing infrastructure entirely using AWS native serverless options while maintaining high-velocity compilation and delivery.
* **The Solution:** Engineered an entirely serverless continuous delivery workflow on AWS. Triggered dynamically by source updates inside Bitbucket, AWS CodePipeline orchestrates isolated AWS CodeBuild execution nodes. These nodes pull specialized base container images from Amazon ECR to perform code compilation, dependency caching, and Sonar analysis, transferring artifacts securely via Amazon S3 to AWS CodeDeploy for automated rolling target updates.
* **Tech Stack:** AWS CodePipeline, CodeBuild, CodeDeploy, Amazon ECR, Amazon S3, Bitbucket.
* **Architecture Blueprint:**
  ![AWS Native CodePipeline](./images/Continuous%20Delivery%20on%20AWS%20Cloud%20Java%20Application.png)

---

## 🗄️ Project Archive (Complete Repository Index)
*Below is the extended ledger of core engineering frameworks and infrastructure topologies built to demonstrate specific technological focus areas.*

<details>
<summary>📂 Expand Cloud Migration & Architecture Strategies</summary>

### Lift-and-Shift Migration to AWS EC2
* **Summary:** Transitioning a legacy multi-tier enterprise stack (Tomcat, MySQL, RabbitMQ, Memcached) into highly available, decoupled security zones behind an internet-facing Application Load Balancer.
* **Blueprint:** `![Architecture](./images/AWS%20Cloud%20for%20Web%20App%20Setup%20Lift%20%26%20Shift.png)`

### Re-Architecting to Cloud-Native PaaS (Elastic Beanstalk)
* **Summary:** Eliminating localized single-point-of-failure risks by refactoring compute runtimes to AWS Elastic Beanstalk and migrating backend databases and caching layers to fully managed services (RDS, ElastiCache, Amazon MQ).
* **Blueprint:** `![Architecture](./images/Re-Architecting%20Web%20App%20on%20AWS%20Cloud%20Cloud%20Native.png)`
</details>

<details>
<summary>📂 Expand Infrastructure as Code (IaC) & Local Runtimes</summary>

### Automated Multi-AZ VPC via Terraform
* **Summary:** Pure declarative scripting to erect isolated public and private subnet configurations across two availability zones, managing dynamic transit paths via AWS NAT Gateways.
* **Blueprint:** `![Architecture](./images/Terraform%20for%20Cloud%20State%20Management%201.png)`

### Remote State Management & S3 Architecture
* **Summary:** Building secure, collaborative backend locks for enterprise state management using S3 backends paired with state mapping files.
* **Blueprint:** `![Architecture](./images/Terraform%20for%20Cloud%20State%20Management%202.png)`

### Multi-Tier Polyglot Microservices Isolation (EMart App)
* **Summary:** Establishing an API Gateway architecture with Nginx to reverse-proxy decoupled multi-stack container ecosystems (Angular, NodeJS, MongoDB, Java).
* **Blueprint:** `![Architecture](./images/Containerization%20of%20Java%20project%20using%20Docker%20-%20Emart%20App.png)`
</details>

<details>
<summary>📂 Expand Kubernetes Orchestration & Core Pipelines</summary>

### Production-Ready High-Availability Kubernetes Cluster
* **Summary:** Implementing path-based Nginx Ingress controllers, abstracting state security with K8s Secrets, and maintaining dynamic storage allocation via PersistentVolumeClaims (PVC) mapped to Amazon EBS.
* **Blueprint:** `![Architecture](./images/Java%20App%20Deployment%20on%20Kubernetes%20Cluster.png)`

### Self-Hosted Enterprise CI Lifecycle (Jenkins & Quality Gates)
* **Summary:** Orchestrating complete quality gates featuring automated Checkstyle validations, SonarQube quality criteria tracking, and immutable asset artifact pushing to Sonatype Nexus repositories.
* **Blueprint:** `![Architecture](./images/Continuous%20Integration%20Using%20Jenkins%2C%20Nexus%2C%20Sonarqube%20%26%20Slack.png)`

### Enterprise Full-Stack Automation via Ansible Roles
* **Summary:** Eliminating configuration divergence across complex multi-tier infrastructures using modular Ansible Roles and live dynamic AWS inventories.
* **Blueprint:** `![Architecture](./images/Ansible%20for%20Complete%20Stack%20Setup.jpg)`
</details>