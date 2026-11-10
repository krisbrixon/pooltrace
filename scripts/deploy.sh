#!/usr/bin/env bash
# Deploy pooltrace to krisbrixon.com (DreamHost).
# Auth: SSH key via Host "dreamhost" in ~/.ssh/config — no passwords involved.
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
REMOTE_DIR="krisbrixon.com/public/pooltrace/v1"

scp -q "$REPO/index.html" "dreamhost:$REMOTE_DIR/index.html"

local_md5=$(md5sum "$REPO/index.html" | cut -d' ' -f1)
remote_md5=$(ssh -o BatchMode=yes dreamhost "md5sum $REMOTE_DIR/index.html" | cut -d' ' -f1)
live_md5=$(curl -s https://krisbrixon.com/pooltrace/v1/ | md5sum | cut -d' ' -f1)

if [[ "$local_md5" == "$remote_md5" && "$local_md5" == "$live_md5" ]]; then
  echo "DEPLOY OK — repo == server == live (md5 $local_md5)"
else
  echo "MISMATCH: local=$local_md5 server=$remote_md5 live=$live_md5" >&2
  exit 1
fi
