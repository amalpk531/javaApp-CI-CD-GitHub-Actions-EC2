### AWS IAM OIDC Setup (one-time manual steps)

#### Step 1 — Create the OIDC Identity Provider in IAM

Go to **IAM → Identity Providers → Add provider**

| Field | Value |
|---|---|
| Provider type | OpenID Connect |
| Provider URL | `https://token.actions.githubusercontent.com` |
| Audience | `sts.amazonaws.com` |

Click **Get thumbprint**, then **Add provider**.

#### Step 2 — Create the IAM Role

Go to **IAM → Roles → Create role**

- Trusted entity type: **Web identity**
- Identity provider: `token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

Add a condition to scope it to your specific repo (critical for security):

```json
{
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:ref:refs/heads/main"
  }
}
```

Attach these permissions policies to the role:

- `AmazonEC2ContainerRegistryFullAccess` — to push images to ECR

Click **Next**, name the role `github-actions-deploy-role`, create it.

Copy the **Role ARN** — looks like `arn:aws:iam::123456789012:role/github-actions-deploy-role`

#### Step 3 — Create the ECR Repository

```bash
aws ecr create-repository \
  --repository-name task-api \
  --region us-east-1
```

#### Step 4 — Add GitHub Secrets

Go to your GitHub repo → **Settings → Secrets and variables → Actions**

| Secret name | Value |
|---|---|
| `AWS_ROLE_ARN` | The Role ARN from Step 2 |
| `EC2_HOST` | Your EC2 public IP or DNS |
| `EC2_SSH_KEY` | Contents of your EC2 `.pem` private key file |

#### Step 5 — EC2 Instance setup (run once after launching instance)

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@YOUR_EC2_IP

# Install Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ubuntu   # so ubuntu user can run docker without sudo

# Install AWS CLI (needed to authenticate Docker to ECR)
sudo apt install -y awscli

# Attach an IAM instance role to EC2 with ECR read access
# Do this in AWS Console: EC2 → Instance → Actions → Security → Modify IAM role
# Attach a role with AmazonEC2ContainerRegistryReadOnly policy
```
