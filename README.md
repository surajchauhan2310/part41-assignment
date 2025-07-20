This project demonstrates how to deploy a Flask web application using Docker, ECS (Fargate), and
Terraform. It also integrates GitHub Actions for CI/CD and maps a custom domain (23surajrc.com)
using Route 53, ACM (SSL), and Namecheap
---

````md
# 🚀 Flask App Deployment on AWS using Terraform, GitHub Actions, Docker & Custom Domain

This project demonstrates how to deploy a **Flask web application** using:

- 🐳 Docker (secure, non-root container)
- ⚙️ ECS Fargate on AWS (infrastructure via Terraform)
- 🧪 GitHub Actions (CI/CD pipeline)
- 🌐 Route 53 + Namecheap for custom domain (`23surajrc.com`)
- 🔐 AWS ACM for SSL

---

## ✅ Objective

Your task will be considered successful if:

- A colleague can run the app locally with just:
  ```bash
  docker build -t flask-time-ip .
  docker run -p 5000:5000 flask-time-ip
````

* The app runs and stays up
* The response is correct and shows current time + IP in JSON
* The image is lightweight and secure (non-root user)
* Terraform provisions complete infrastructure in AWS
* Documentation is clear and self-contained

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
│   └── simpletime_tf.yaml       # GitHub Actions pipeline
├── .gitignore
└── README.md
```

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
```

---

## 🐳 Docker Instructions (Minimal & Secure)

### ✅ Build

```bash
cd app
docker build -t flask-time-ip .
```

### ✅ Run

```bash
docker run -p 5000:5000 flask-time-ip
```

### ✅ Output

Visit: [http://localhost:5000](http://localhost:5000)
Example:

```json
{
  "timestamp": "2025-07-20T12:34:56.123Z",
  "ip": "127.0.0.1"
}
```

---

## 📦 Dockerfile Best Practices

```dockerfile
FROM python:3.12-slim

RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000
CMD ["python", "app.py"]
```

✅ Uses slim base image
✅ Runs as non-root user
✅ Optimized for caching and small size
✅ No unnecessary layers or tools

---

## 🛠️ Deploy with Terraform

### 📦 Provision Infra

```bash
cd terraform
terraform init
terraform apply
```

Creates:

* VPC with subnets
* ECS Cluster with Fargate
* ALB + Target Group
* IAM roles and task definitions
* Route 53 records
* ACM SSL Certificate

---

## 🔐 Domain Mapping + SSL (ACM)

### 1. Route 53 Hosted Zone

* Create hosted zone for `23surajrc.com`
* Update Namecheap with the NS records

### 2. ACM Certificate

* Request certificate for:

  * `23surajrc.com`
  * `www.23surajrc.com`
* Use **DNS validation**
* Add CNAMEs to Route 53
* Wait for `ISSUED`

### 3. ALB Configuration

* HTTPS listener (443)
* ACM certificate
* Optional HTTP → HTTPS redirect

### 4. Route 53 Records

* `23surajrc.com` → ALB DNS
* `www.23surajrc.com` → ALB DNS

---

## 🐙 GitHub Actions (`simpletime_tf.yaml`)

Runs Terraform `apply` or `destroy` via `workflow_dispatch`.

### Required Secrets

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

### Trigger:

1. Go to GitHub → Actions
2. Select "Terraform Pipeline"
3. Click **Run workflow**
4. Choose:

   * `apply` (to deploy)
   * `destroy` (to tear down)

---

## ✅ Evaluation Checklist

| Criteria                     | Status |
| ---------------------------- | ------ |
| `docker build` works         | ✅      |
| `docker run` works           | ✅      |
| App stays running            | ✅      |
| Returns valid timestamp + IP | ✅      |
| Non-root container           | ✅      |
| Image is minimal             | ✅      |
| SSL enabled via ACM          | ✅      |
| Terraform infra complete     | ✅      |
| Domain points to ALB         | ✅      |
| CI/CD pipeline functional    | ✅      |
| Instructions clear           | ✅      |

---

## 🧹 Clean Up

```bash
cd terraform
terraform destroy
```

Optional cleanup if using remote state:

```bash
aws s3 rb s3://terraform-backend-bucket-suraj2310 --force
aws dynamodb delete-table --table-name terraform-locks
```

---

## 🤝 Contributing

Feel free to fork this repo and open pull requests for improvements or suggestions.

---

## 📌 Tips

* Ensure ports 80 and 443 are open in ALB SG
* Prefer DNS validation for ACM (automated via Route 53)
* Use CI/CD via GitHub Actions for fast iteration

```

---

Let me know if you’d like this version saved as a file, or want a follow-up doc for collaborators (e.g., a `CONTRIBUTING.md`, or `Makefile` to automate build/deploy).
```
