# GitHub Actions Runner Container

Docker container for automated GitHub Actions self-hosted runners.

Inspired from https://github.com/chaddyc/gha-runner and tweaked for my personal needs

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

# OPTIONAL Additional comma-separated runner labels
# Default labels are always included: docker,linux,ubuntu-{version},runner-{version}
RUNNER_LABELS=<label1,label2>

# OPTIONAL Run in ephemeral mode (default: false)
# https://docs.github.com/pt/actions/reference/runners/self-hosted-runners#ephemeral-runners-for-autoscaling
EPHEMERAL=false

# OPTIONAL Disable automatic runner software updates (default: false)
# https://docs.github.com/pt/actions/reference/runners/self-hosted-runners#runner-software-updates-on-self-hosted-runners
DISABLE_UPDATE=false

````

## Volumes

For persistent logs and runner data between container restarts:

- **`/runner/_work`** - Job execution logs and temporary files
- **`/opt/hostedtoolcache`** - Tool cache for faster job execution (optional)

## Usage

### Using Pre-built Images

The project automatically builds and publishes images to **Docker Hub**: `leogomide/gha-runner`

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
  -v runner_work:/runner/_work \
  -v runner_toolcache:/opt/hostedtoolcache \
  --privileged \
  leogomide/gha-runner:latest-x64

# ARM64 architecture
docker run -d \
  -e REPO_URL=https://github.com/owner/repo \
  -e REGISTRATION_TOKEN=your_token_here \
  -e RUNNER_NAME=my-runner \
  -e RUNNER_LABELS=docker,linux,custom \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v runner_work:/runner/_work \
  -v runner_toolcache:/opt/hostedtoolcache \
  --privileged \
  leogomide/gha-runner:latest-arm64
```

### Building the image:
```bash
# Build with default version (2.311.0)
docker build -t github-runner .

# Build with specific version
docker build --build-arg RUNNER_VERSION=2.328.0 -t github-runner .
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
