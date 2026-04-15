# AI Arcade Snake CI/CD

This repository hosts a retro-style AI content landing page with an integrated Snake game. It includes a GitHub Actions workflow that builds a Docker image, verifies it, and deploys it automatically to a remote server.

## How the CI/CD workflow works

The workflow is defined in `.github/workflows/ci-cd.yml` and runs on every push to `main` or `master`.

### Job flow

1. **build**
   - Checks out the repository.
   - Validates `index.html` using Python's HTML parser.
   - Sets up Docker Buildx.
   - Logs in to GitHub Container Registry (`ghcr.io`).
   - Builds the Docker image from `Dockerfile`.
   - Pushes the built image to `ghcr.io/${{ github.repository_owner }}/${{ github.repository }}:latest`.

2. **smoke-test**
   - Runs after `build` succeeds.
   - Logs in again to `ghcr.io`.
   - Launches a temporary container from the pushed image.
   - Verifies the service responds on `http://localhost:8099`.
   - Stops and removes the temporary test container.

3. **deploy**
   - Runs after `smoke-test` succeeds.
   - Only executes on the `main` or `master` branch.
   - Uses SSH to connect to the target server.
   - Pulls the latest Docker image from GHCR.
   - Stops any old container named `ai-arcade-snake-service`.
   - Starts a new container bound to port `8099`.

## How auto-deploy works

When a push is made to `main` or `master`:

- GitHub Actions builds the Docker image and pushes it to GHCR.
- The workflow confirms the image runs correctly with a smoke test.
- If successful, the deploy job SSHes into your server and runs the latest image.
- The deployed service listens on port `8099` on the target machine.

## Required secrets

To enable auto-deploy, set these repository secrets in GitHub:

- `DEPLOY_HOST` — the remote server hostname or IP address.
- `DEPLOY_USER` — SSH username for the remote server.
- `DEPLOY_SSH_KEY` — the private SSH key for remote login.
- `GHCR_TOKEN` — a token for pulling the Docker image from GHCR if the repository/image is private.
- `DEPLOY_PORT` — optional SSH port (default is `22`).

### Example secret setup

In GitHub repository settings:
1. Go to `Settings > Secrets and variables > Actions`.
2. Click `New repository secret`.
3. Add each secret name and value.

## Remote server requirements

Your deployment target must have:

- Docker installed and running.
- Network access to `ghcr.io`.
- SSH access from GitHub Actions using the provided key.
- Permission to pull and run Docker containers.

## Local deploy helper

You can also deploy locally using `deploy.sh`:

```bash
bash deploy.sh
```

This script builds the image locally and runs the container as `ai-arcade-snake-service` on port `8099`.

## Notes

- The workflow uses `appleboy/ssh-action` to run deployment commands remotely.
- The Docker image is exposed on port `8099` both inside the container and on the host.
- If you want a public URL, make sure your server accepts incoming traffic on port `8099`.
