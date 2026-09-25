#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Commit a UTC heartbeat for the off-property GitHub Actions check.
set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
host_name="${HOST_NAME:-my-server}"

case "$host_name" in
  ''|*/*|*..*|*[!A-Za-z0-9._-]*)
    echo "HOST_NAME must contain only letters, numbers, dot, underscore, or dash" >&2
    exit 1
    ;;
esac

cd "$repository_root"
git pull --rebase
mkdir -p heartbeat
printf '%s\n' "$(date -u +%s)" > "heartbeat/$host_name"
git add "heartbeat/$host_name"

if git diff --cached --quiet; then
  echo "heartbeat unchanged; nothing to commit"
  exit 0
fi

git commit -m "chore: heartbeat $host_name"
git push
