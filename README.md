# GitHub Actions Runner Container

Docker container for automated GitHub Actions self-hosted runners.

## How to get the Registration Token

1. Access your repository on GitHub
2. Go to Settings > Actions > Runners
3. Click on "New self-hosted runner"
4. Copy the token displayed in the "Configure" section

## Required Environment Variables

````dotenv
# GitHub repository URL
REPO_URL=https://github.com/owner/repo

# Runner registration token (obtained from Settings > Actions > Runners > New runner)
REGISTRATION_TOKEN=<your-registration-token>

# OPTIONAL Runner name (default: docker-runner-{hostname})
RUNNER_NAME=<your-runner-name>

# OPTIONAL Comma-separated runner labels (default: docker,linux)
RUNNER_LABELS=<your-runner-name>

# OPTIONAL Run in ephemeral mode (default: false)
EPHEMERAL=true

````
## Usage

### Using Pre-built Images

The project automatically builds and publishes images to:

- **Docker Hub**: `leogomide/gha-runner`
- **GitHub Container Registry**: `ghcr.io/leogomide/gha-runner`

### Available Tags

- `latest-x64` / `latest-arm64` - Latest runner version for each architecture
- `{version}-x64` / `{version}-arm64` - Specific runner version (e.g., `2.311.0-x64`)

```bash
# x64 architecture
docker run -d \
  -e REPO_URL=https://github.com/owner/repo \
  -e REGISTRATION_TOKEN=your_token_here \
  -e RUNNER_NAME=my-runner \
  -e RUNNER_LABELS=docker,linux,custom \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged \
  arkbr/gha-runner-container:latest-x64

# ARM64 architecture
docker run -d \
  -e REPO_URL=https://github.com/owner/repo \
  -e REGISTRATION_TOKEN=your_token_here \
  -e RUNNER_NAME=my-runner \
  -e RUNNER_LABELS=docker,linux,custom \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --privileged \
  arkbr/gha-runner-container:latest-arm64
```

### Building the image:
```bash
# Build with default version (2.311.0)
docker build -t github-runner .

# Build with specific version
docker build --build-arg RUNNER_VERSION=2.312.0 -t github-runner .
```

## Included Features

- Ubuntu 24.04 base
- Docker-in-Docker support
- Node.js LTS
- Python 3
- Git
- Essential build tools
- Automatic runner cleanup on container stop
- Configurable runner version via build argument
- Multi-architecture support (x64/ARM64)
- Ephemeral mode support - runs only one job and removes itself automatically
- Pre-configured toolcache directory with proper permissions
