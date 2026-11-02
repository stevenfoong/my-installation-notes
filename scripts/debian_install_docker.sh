#!/usr/bin/env bash
# debian_install_docker.sh - Install Docker CE on Debian from Docker's official repo.
# Bash equivalent of the debian_install_docker.yml Ansible playbook.
#
# Usage: sudo ./debian_install_docker.sh

set -euo pipefail

KEYRING_DIR=/etc/apt/keyrings
KEY_FILE=$KEYRING_DIR/docker.asc
SOURCES_FILE=/etc/apt/sources.list.d/docker.sources

log() { echo -e "\n==> $*"; }

# ---- pre-checks ------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Error: run this script as root (e.g. sudo $0)" >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Error: /etc/os-release not found; cannot detect distribution" >&2
  exit 1
fi

# shellcheck source=/dev/null
. /etc/os-release
DISTRO=${ID,,}                  # e.g. debian
RELEASE=${VERSION_CODENAME,,}   # e.g. bookworm

if [[ $DISTRO != "debian" ]]; then
  echo "Error: this script is for Debian (detected: $DISTRO)" >&2
  exit 1
fi
if [[ -z $RELEASE ]]; then
  echo "Error: could not detect Debian release codename" >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# ---- 1. required system packages -------------------------------------------
log "Installing required system packages"
apt-get update
apt-get install -y ca-certificates curl

# ---- 2. keyring directory ---------------------------------------------------
log "Creating $KEYRING_DIR"
install -m 0755 -d "$KEYRING_DIR"

# ---- 3. Docker GPG key (always re-downloaded, like force: true) -------------
log "Downloading Docker official GPG key"
curl -fsSL "https://download.docker.com/linux/$DISTRO/gpg" -o "$KEY_FILE"
chmod 0644 "$KEY_FILE"

# ---- 4. Docker APT repository (deb822 format) -------------------------------
log "Adding Docker APT repository ($DISTRO $RELEASE)"
cat > "$SOURCES_FILE" <<EOF
Types: deb
URIs: https://download.docker.com/linux/$DISTRO
Suites: $RELEASE
Components: stable
Signed-By: $KEY_FILE
Enabled: yes
EOF
chmod 0644 "$SOURCES_FILE"

# ---- 5 & 6. update cache and install Docker ---------------------------------
log "Updating APT cache"
apt-get update

log "Installing Docker CE and plugins"
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# ---- 7. start and enable the service ----------------------------------------
log "Enabling and starting Docker service"
systemctl enable --now docker

log "Done"
docker --version
docker compose version
