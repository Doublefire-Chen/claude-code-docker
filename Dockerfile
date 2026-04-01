FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    git \
    sudo \
    locales \
    vim \
    nano \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install Node.js (needed for MCP servers)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

RUN mkdir /var/run/sshd

# SSH: pubkey only, disable password login
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Create user (no password, no sudo)
RUN useradd -ms /bin/bash claude
RUN mkdir -p /home/claude/.ssh && chown claude:claude /home/claude/.ssh && chmod 700 /home/claude/.ssh

# Install Claude Code as claude user
USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

EXPOSE 22

CMD chown -R claude:claude /home/claude/.claude && \
    if [ ! -f /home/claude/.claude/.claude.json ]; then \
      echo '{"hasCompletedOnboarding":true,"installMethod":"native"}' > /home/claude/.claude/.claude.json && \
      chown claude:claude /home/claude/.claude/.claude.json; \
    fi && \
    /usr/sbin/sshd -D
