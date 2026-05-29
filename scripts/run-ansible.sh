#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(cd "${SCRIPT_DIR}/../ansible" && pwd)"

cd "${ANSIBLE_DIR}"
ansible-playbook -i inventory.ini playbook.yml
