#!/bin/bash
set -euo pipefail
exec > >(tee -a /var/log/user_data.log) 2>&1
echo "[INFO] user_data start (frontend)"
export DEBIAN_FRONTEND=noninteractive

REPO_URL="${repo_url}"
BRANCH="${branch}"
EXPRESS_SUBDIR="${express_path}"
BACKEND_URL="${backend_url}"

apt-get update -y
apt-get upgrade -y
apt-get install -y git curl jq rsync
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

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

FRONTEND_CLEAN_DIR="/opt/apps/repo/frontend_clean"
mkdir -p "$FRONTEND_CLEAN_DIR"
rsync -a "/opt/apps/repo/$EXPRESS_SUBDIR"/ "$FRONTEND_CLEAN_DIR"/ || true

cd "$FRONTEND_CLEAN_DIR"
if [ -f package-lock.json ]; then
  npm ci --omit=dev || npm ci || npm install --production
elif [ -f package.json ]; then
  npm install --production
else
  echo "[WARN] No package.json found"
fi

cat > /etc/systemd/system/express.service <<EOF
[Unit]
Description=Express App
After=network.target
[Service]
User=root
WorkingDirectory=/opt/apps/repo/frontend_clean
ExecStart=/usr/bin/node app.js
Restart=always
Environment=NODE_ENV=production BACKEND_URL=${backend_url}
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable express.service
systemctl start express.service

echo "[INFO] user_data completed (frontend)"
