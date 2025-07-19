---

```md
# Flask App Deployment on AWS with Terraform, GitHub Actions, and Custom Domain

This project demonstrates how to deploy a Flask web application using Docker, ECS (Fargate), and Terraform. It also integrates GitHub Actions for CI/CD and maps a custom domain (`23surajrc.com`) using Route 53, ACM (SSL), and Namecheap.

---

## 🚀 Project Structure

```

.
├── app/                          # Flask app folder
│   ├── Dockerfile
│   └── app.py
├── terraform/
│   ├── app-infra/                # Terraform infrastructure setup
│   │   ├── main.tf
│   │   ├── vpc.tf
│   │   ├── ecs.tf
│   │   ├── alb.tf
│   │   ├── iam.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── provider.tf
│   ├── backend-setup/           # (Commented) Optional Terraform backend
│   │   └── backend-setup.tf
│   └── backend.tf               # (Commented) S3 + DynamoDB backend config
├── .github/workflows/
│   └── deploy.yml               # GitHub Actions CI/CD pipeline
├── README.md
└── .gitignore

````

---

## 🐍 Flask App (`app/app.py`)

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Flask on ECS!"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
````

---

## 🐳 Dockerfile

```Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install flask
CMD ["python", "app.py"]
```

---

## 🛠️ Terraform Infrastructure (Basic Setup)

Navigate to the `terraform/app-infra` directory and run:

```bash
terraform init
terraform apply
```

This will create:

* A VPC with public/private subnets
* IAM roles and ECS cluster
* Fargate service to run the Flask container
* Application Load Balancer (ALB) for routing

> ℹ️ **Note**: Files like `backend.tf` and `backend-setup.tf` are included but commented out. These are for setting up a remote backend (S3 + DynamoDB) and can be used in future by uncommenting and running `terraform init` with appropriate backend configuration.

---

## 🐙 GitHub Actions CI/CD

`.github/workflows/deploy.yml` handles CI/CD with every push to `main`:

```yaml
name: Deploy Flask App to ECS

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-south-1

      - name: Build & Push Docker image to ECR
        run: |
          echo "Build and push image logic here"

      - name: Terraform Apply
        run: |
          cd terraform/app-infra
          terraform init
          terraform apply -auto-approve
```

---

## 🔗 Custom Domain & SSL (`23surajrc.com`)

### 1. Route 53 Hosted Zone

* Create hosted zone for `23surajrc.com` in Route 53
* Update **NS records** in Namecheap under DNS settings

### 2. ACM Certificate (SSL)

* Request certificate for:

  * `23surajrc.com`
  * `www.23surajrc.com`
* Use **DNS validation** and add CNAME records to Route 53
* Wait until status is `ISSUED`

### 3. ALB Configuration

* ALB should have:

  * Port 443 listener
  * Attached ACM certificate
  * Forward rule to ECS target group

### 4. Route 53 Records

* Create A Records:

  * `23surajrc.com` → Alias → ALB DNS
  * `www.23surajrc.com` → Alias → ALB DNS

---

## ✅ Summary

| Feature                  | Status |
| ------------------------ | ------ |
| Flask App in Docker      | ✅      |
| ECS (Fargate) Deployment | ✅      |
| Terraform Infra Setup    | ✅      |
| GitHub Actions CI/CD     | ✅      |
| Domain Mapping           | ✅      |
| SSL with ACM             | ✅      |

---

## 📝 Notes

* Ensure port 80 and 443 are open on the ALB security group
* You can use `terraform destroy` in `terraform/app-infra` to tear down resources
* Remote backend support is optional; can be added by uncommenting backend files and reinitializing Terraform

---

## 🤝 Contributing

Feel free to fork this repo and raise pull requests for improvements or suggestions.

```

---

You can now **copy-paste this directly** into your `README.md` file — it's already formatted for GitHub and reflects your current project structure and behavior. Let me know if you'd like a version with badges or deployment status indicators!
```
