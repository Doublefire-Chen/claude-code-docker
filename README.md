# Claude Code Docker

Run [Claude Code](https://claude.ai/claude-code) in a Docker container with SSH access.

## Features

- Claude Code installed via native installer
- SSH access with public key authentication (password login disabled)
- Persistent home directory (login session, projects, and config survive restarts)
- Disk usage healthcheck (10GB limit)
- Container isolated from host (no sudo, no privileged access)

## Setup

1. Add your SSH public key(s) to `authorized_keys` (one per line):

```bash
cat ~/.ssh/id_rsa.pub > authorized_keys
```

2. Build and start the container:

```bash
docker compose build && docker compose up -d
```

3. SSH in and log in to Claude Code (only needed once):

```bash
ssh claude@<host-ip> -p 2222
claude
# Run /login inside Claude Code
```

## Usage

```bash
ssh claude@<host-ip> -p 2222
claude
```

## File Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── authorized_keys        # Your SSH public keys (one per line)
└── README.md
```

## Healthcheck

The container monitors disk usage and reports `unhealthy` if it exceeds 10GB:

```bash
docker ps
```

## Installing Extra Global npm Packages

The `claude` user has no sudo access, and root installs don't persist across container restarts. Use npm's prefix config to install global packages under your home directory:

```bash
# One-time setup
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Then install as usual
npm install -g @openai/codex
```

Packages installed this way are stored in `/home/claude/.npm-global`, which is persisted by the Docker volume.

## Stop / Restart

```bash
docker compose down          # stop (data preserved)
docker compose up -d         # start again
docker compose down -v       # stop and delete all data
```
