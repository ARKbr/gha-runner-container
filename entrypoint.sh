#!/bin/bash

echo "Starting..."

set -e

if [ -z "$REPO_URL" ]; then
    echo "Error: REPO_URL environment variable is required"
    echo "Example: https://github.com/owner/repo"
    exit 1
fi

if [ -z "$REGISTRATION_TOKEN" ]; then
    echo "Error: REGISTRATION_TOKEN environment variable is required"
    echo "Get token from: $REPO_URL/settings/actions/runners/new"
    exit 1
fi

RUNNER_NAME=${RUNNER_NAME:-"docker-runner-$(hostname)"}
EPHEMERAL=${EPHEMERAL:-"false"}
DISABLE_UPDATE=${DISABLE_UPDATE:-"false"}

# Get Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)

# Get runner version from the installed runner
RUNNER_VERSION=$(./bin/Runner.Listener --version | head -1 | cut -d' ' -f3)

# Build labels with version info always included
DEFAULT_LABELS="docker,ubuntu-${UBUNTU_VERSION},runner-${RUNNER_VERSION}"
USER_LABELS=${RUNNER_LABELS:-""}

if [ -n "$USER_LABELS" ]; then
    RUNNER_LABELS="${DEFAULT_LABELS},${USER_LABELS}"
else
    RUNNER_LABELS="$DEFAULT_LABELS"
fi

echo "Configuring GitHub Actions Runner..."
echo "Runner Version: $RUNNER_VERSION"
echo "Repository: $REPO_URL"
echo "Runner Name: $RUNNER_NAME"
echo "Labels: $RUNNER_LABELS"
echo "Ephemeral: $EPHEMERAL"
echo "Disable Update: $DISABLE_UPDATE"

CONFIG_ARGS="--url $REPO_URL --token $REGISTRATION_TOKEN --name $RUNNER_NAME --labels $RUNNER_LABELS --work _work --unattended --replace"

if [ "$EPHEMERAL" = "true" ]; then
    CONFIG_ARGS="$CONFIG_ARGS --ephemeral"
fi

if [ "$DISABLE_UPDATE" = "true" ]; then
    CONFIG_ARGS="$CONFIG_ARGS --disableupdate"
fi

./config.sh $CONFIG_ARGS

cleanup() {
    if [ "$EPHEMERAL" != "true" ]; then
        echo "Removing runner..."
        ./config.sh remove --token "$REGISTRATION_TOKEN"
    else
        echo "Ephemeral runner - no manual cleanup needed"
    fi
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

echo "Starting GitHub Actions Runner..."
./run.sh & wait $!