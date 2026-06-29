# CI/CD Pipeline Documentation — Vortex

Vortex utilizes automated GitHub Actions workflows defined in `.github/workflows/`.

---

## 1. Continuous Integration (`ci.yml`)
- **Trigger**: Pull Requests targeting `main` or `master`.
- **Validation Steps**:
  1. Builds React frontend (`npm run build`).
  2. Verifies Node backend module installation.
  3. Validates `services/docker-compose.yml` configuration syntax.
  4. Validates `infra/terraform` HCL code syntax (`terraform validate`).

---

## 2. Continuous Deployment (`deploy.yml`)
- **Trigger**: Direct pushes to `main` or `master`.
- **Deployment Flow**:
  1. Authenticates to EC2 host via SSH (`appleboy/ssh-action`).
  2. Pulls latest commit from repository.
  3. Executes `docker compose down` and `docker compose up -d --build` in `services/`.
  4. Polls `/health` endpoint to verify successful startup.

---

## 3. Required GitHub Secrets
- `EC2_HOST`: Elastic IP address of EC2 instance.
- `EC2_USER`: Default SSH user (`ubuntu`).
- `EC2_SSH_KEY`: Private RSA key corresponding to AWS key pair.
