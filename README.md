---

```md
# 🚀 Flask App Deployment on AWS using Terraform, GitHub Actions, Docker & Custom Domain

This project demonstrates how to deploy a Flask web application on AWS ECS Fargate using Docker and Terraform. It includes:

- CI/CD via GitHub Actions
- SSL via AWS ACM
- Domain mapping (`23surajrc.com`) via Route 53 & Namecheap

---

## 📁 Project Structure

```

.
├── app/                          # Flask app
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
├── terraform/                    # Terraform infrastructure
│   ├── main.tf
│   ├── vpc.tf
│   ├── ecs.tf
│   ├── alb.tf
│   ├── iam.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── backend.tf               # (Optional) Remote state backend (S3 + DynamoDB)
│   └── backend-setup/          # (Optional) Initial backend setup logic
│       └── backend-setup.tf
├── .github/workflows/
│   └── simpletime\_tf.yaml       # GitHub Actions pipeline
├── .gitignore
└── README.md

````

---

## 🐍 Flask App (`app/app.py`)

```python
from flask import Flask, request, jsonify
from datetime import datetime

app = Flask(__name__)

@app.route("/", methods=["GET"])
def get_time_and_ip():
    current_time = datetime.utcnow().isoformat() + "Z"
    visitor_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    
    return jsonify({
        "timestamp": current_time,
        "ip": visitor_ip
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
````

---

## 🐳 Dockerfile (Secure, Non-Root)

```dockerfile
# Use a lightweight official Python image
FROM python:3.12-slim

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Set working directory
WORKDIR /app

# Copy requirements first for layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Change ownership of the app directory
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose the port your Flask app will run on
EXPOSE 5000

# Run the Flask app
CMD ["python", "app.py"]
```

---

## 🛠️ Terraform Infrastructure

### Run locally:

```bash
cd terraform
terraform init
terraform apply
```

Creates:

* VPC (public + private subnets)
* ECS Cluster (Fargate)
* Load Balancer (ALB)
* IAM Roles
* Target Group, Listener
* (Optional) Remote backend support via S3 + DynamoDB

---

## 🔐 SSL & Domain Mapping

### 1. Route 53 Hosted Zone

* Create hosted zone for `23surajrc.com`
* Copy NS records into Namecheap domain settings

### 2. ACM Certificate

* Request certificate for:

  * `23surajrc.com`
  * `www.23surajrc.com`
* Choose **DNS validation**
* Add generated CNAME records to Route 53
* Wait for `ISSUED` status

### 3. ALB Configuration (via Terraform)

* HTTPS listener (port 443)

  * Uses ACM certificate
  * Forwards to ECS target group
* Optional HTTP (port 80) → Redirect to HTTPS

### 4. Route 53 Records

* Create Alias records:

  * `23surajrc.com` → ALB DNS
  * `www.23surajrc.com` → ALB DNS

---

## 🐙 GitHub Actions: `simpletime_tf.yaml`

### 📄 `.github/workflows/simpletime_tf.yaml`

```yaml
name: Terraform Pipeline for creating the infrastructure and also for deploying the simpletimesvc on the ECS Fargate cluster

on:
  workflow_dispatch:
    inputs:
      action:
        description: 'Terraform action to perform'
        required: true
        default: 'apply'
        type: choice
        options:
          - apply
          - destroy

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-south-1

      - name: Create S3 Bucket for Terraform Backend
        run: |
          BUCKET_NAME="terraform-backend-bucket-suraj2310"
          echo "BUCKET_NAME=$BUCKET_NAME" >> $GITHUB_ENV

          if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
            aws s3api create-bucket \
              --bucket "$BUCKET_NAME" \
              --region ap-south-1 \
              --create-bucket-configuration LocationConstraint=ap-south-1
            echo "S3 bucket $BUCKET_NAME created."
          else
            echo "S3 bucket $BUCKET_NAME already exists."
          fi

      - name: Create DynamoDB Table for Locking
        run: |
          if aws dynamodb describe-table --table-name terraform-locks >/dev/null 2>&1; then
            echo "DynamoDB table already exists. Skipping creation."
          else
            aws dynamodb create-table \
              --table-name terraform-locks \
              --attribute-definitions AttributeName=LockID,AttributeType=S \
              --key-schema AttributeName=LockID,KeyType=HASH \
              --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
          fi

      - name: Wait for DynamoDB Table to become ACTIVE
        run: |
          while true; do
            STATUS=$(aws dynamodb describe-table --table-name terraform-locks --query "Table.TableStatus" --output text)
            if [ "$STATUS" == "ACTIVE" ]; then break; fi
            sleep 5
          done

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform CD Init
        working-directory: ./terraform
        run: terraform init

      - name: Terraform Plan
        working-directory: ./terraform
        run: terraform plan

      - name: Terraform Apply or Destroy
        working-directory: ./terraform
        run: |
          if [[ "${{ github.event.inputs.action }}" == "destroy" ]]; then
            terraform destroy -auto-approve
          else
            terraform apply -auto-approve
```

---

## ✅ Summary

| Feature                 | Status |
| ----------------------- | ------ |
| Dockerized Flask App    | ✅      |
| ECS Fargate Deployment  | ✅      |
| HTTPS via ACM           | ✅      |
| Domain (Route 53 + ALB) | ✅      |
| Terraform Infra Setup   | ✅      |
| GitHub Actions CI/CD    | ✅      |
| S3 & DynamoDB Backend   | ✅      |

---

## 📝 Tips

* ✅ Open ports 80 & 443 in ALB security group
* ✅ Use `terraform destroy` to clean up
* ✅ ACM + Route 53 DNS validation is preferred
* 🚀 GitHub Actions deploys on-demand (`apply` or `destroy`) via `workflow_dispatch`

---

## 🤝 Contributing

Feel free to fork this repo and open pull requests for improvements!

```

