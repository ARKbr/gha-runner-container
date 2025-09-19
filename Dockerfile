ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.source="https://github.com/leogomide/gha-runner"
LABEL org.opencontainers.image.description="GitHub Actions Self-Hosted Runner Container"

ARG RUNNER_VERSION=2.311.0
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    jq \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    python3-dev \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    sudo \
    tar \
    nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

WORKDIR /runner

RUN if [ "${TARGETARCH}" = "x64" ]; then \
      export RUNNER_ARCH="x64"; \
    elif [ "${TARGETARCH}" = "arm64" ]; then \
      export RUNNER_ARCH="arm64"; \
    else \
      echo "Unsupported architecture: ${TARGETARCH}"; exit 1; \
    fi && \
    curl -o actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz \
    && rm actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

RUN ./bin/installdependencies.sh

RUN useradd -m -s /bin/bash runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN groupadd -f docker && usermod -aG docker runner
RUN chown -R runner:runner /runner

RUN mkdir -p /opt/hostedtoolcache
RUN chown -R runner:runner /opt/hostedtoolcache

COPY entrypoint.sh /runner/entrypoint.sh
RUN chmod +x /runner/entrypoint.sh
RUN chown runner:runner /runner/entrypoint.sh

USER runner
WORKDIR /runner

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/entrypoint.sh"]