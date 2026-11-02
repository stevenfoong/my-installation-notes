# debian_install_docker.sh

Installs Docker CE on Debian from Docker's official APT repository.

Bash equivalent of the `debian_install_docker.yml` Ansible playbook, so Docker
can be installed without installing Ansible first.

## Requirements

- Debian (release detected automatically from `/etc/os-release`)
- Root access (`sudo`)
- Internet access to `deb.debian.org` and `download.docker.com`

## Installation

```bash
chmod +x debian_install_docker.sh
```

## Usage

```bash
sudo ./debian_install_docker.sh
```

No arguments are needed.

Example output (end of run):

```
==> Done
Docker version 28.x.x, build xxxxxxx
Docker Compose version v2.x.x
```

## What the script does

| Step | Action |
|------|--------|
| 1 | Installs `ca-certificates` and `curl` |
| 2 | Creates `/etc/apt/keyrings` (mode `0755`) |
| 3 | Downloads Docker's GPG key to `/etc/apt/keyrings/docker.asc` (always re-downloaded) |
| 4 | Adds the Docker repository as `/etc/apt/sources.list.d/docker.sources` (deb822 format) |
| 5 | Updates the APT cache |
| 6 | Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin` |
| 7 | Enables and starts the `docker` service |
| 8 | Prints the installed Docker and Docker Compose versions |

## Repository file created

`/etc/apt/sources.list.d/docker.sources`:

```
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: <release codename, e.g. bookworm>
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
Enabled: yes
```

## Safety checks

The script stops with an error if:

- it is not run as root
- `/etc/os-release` is missing
- the OS is not Debian
- the Debian release codename cannot be detected
- any command fails (`set -euo pipefail`)

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Docker installed and running |
| `1` | A pre-check failed |
| other | A command failed (e.g. `apt-get` or `curl`); see the output above the error |

## Notes

- Safe to re-run: existing packages are kept, and the key and repository file are overwritten with the same content.
- To run Docker without `sudo`, add your user to the `docker` group, then log out and back in:

  ```bash
  sudo usermod -aG docker "$USER"
  ```
