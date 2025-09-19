#!/bin/bash

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
RUNNER_LABELS=${RUNNER_LABELS:-"docker,linux"}
EPHEMERAL=${EPHEMERAL:-"false"}

echo "Configuring GitHub Actions Runner..."
echo "Repository: $REPO_URL"
echo "Runner Name: $RUNNER_NAME"
echo "Labels: $RUNNER_LABELS"
echo "Ephemeral: $EPHEMERAL"

if [ "$EPHEMERAL" = "true" ]; then
    ./config.sh \
        --url "$REPO_URL" \
        --token "$REGISTRATION_TOKEN" \
        --name "$RUNNER_NAME" \
        --labels "$RUNNER_LABELS" \
        --work "_work" \
        --unattended \
        --replace \
        --ephemeral
else
    ./config.sh \
        --url "$REPO_URL" \
        --token "$REGISTRATION_TOKEN" \
        --name "$RUNNER_NAME" \
        --labels "$RUNNER_LABELS" \
        --work "_work" \
        --unattended \
        --replace
fi

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