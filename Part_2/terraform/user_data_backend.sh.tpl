#!/bin/bash
set -euo pipefail
exec > >(tee -a /var/log/user_data.log) 2>&1
echo "[INFO] user_data start (backend)"
export DEBIAN_FRONTEND=noninteractive

REPO_URL="${repo_url}"
BRANCH="${branch}"
FLASK_SUBDIR="${flask_path}"

apt-get update -y
apt-get upgrade -y
apt-get install -y python3 python3-pip python3-venv git curl jq rsync

mkdir -p /opt/apps
cd /opt/apps
if [ ! -d repo/.git ]; then
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" repo
else
  cd repo
  git fetch origin "$BRANCH" --depth 1
  git checkout "$BRANCH"
  git reset --hard "origin/$BRANCH"
  cd ..
fi

BACKEND_CLEAN_DIR="/opt/apps/repo/backend_clean"
mkdir -p "$BACKEND_CLEAN_DIR"
rsync -a "/opt/apps/repo/$FLASK_SUBDIR"/ "$BACKEND_CLEAN_DIR"/ || true

cd "$BACKEND_CLEAN_DIR"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip || echo "[WARN] pip upgrade failed"
if [ -f requirements.txt ]; then
  pip install -r requirements.txt || echo "[ERROR] requirements install failed"
else
  echo "[WARN] No requirements.txt found"
fi

cat > /etc/systemd/system/flask.service <<EOF
[Unit]
Description=Flask App
After=network.target
[Service]
User=root
WorkingDirectory=/opt/apps/repo/backend_clean
ExecStart=/opt/apps/repo/backend_clean/venv/bin/python app.py
Restart=always
Environment=PYTHONUNBUFFERED=1
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flask.service
systemctl start flask.service

echo "[INFO] user_data completed (backend)"
