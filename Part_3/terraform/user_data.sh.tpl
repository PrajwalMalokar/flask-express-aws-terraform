#!/bin/bash
set -euo pipefail
exec > >(tee -a /var/log/user_data.log) 2>&1
echo "[INFO] user_data start"
export DEBIAN_FRONTEND=noninteractive

REPO_URL="${repo_url}"
BRANCH="${branch}"
FLASK_SUBDIR="${flask_path}"
EXPRESS_SUBDIR="${express_path}"

echo "[INFO] Updating base packages"
apt-get update -y
apt-get upgrade -y
apt-get install -y python3 python3-pip python3-venv git curl jq rsync
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

mkdir -p /opt/apps
cd /opt/apps
if [ ! -d repo/.git ]; then
  echo "[INFO] Cloning repo $REPO_URL (branch $BRANCH)"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" repo
else
  echo "[INFO] Updating existing repo"
  cd repo
  git fetch origin "$BRANCH" --depth 1
  git checkout "$BRANCH"
  git reset --hard "origin/$BRANCH"
  cd ..
fi

# Sanitize (space) paths by copying to clean dirs
echo "[INFO] Creating sanitized directories"
BACKEND_CLEAN_DIR="/opt/apps/repo/backend_clean"
FRONTEND_CLEAN_DIR="/opt/apps/repo/frontend_clean"
mkdir -p "$BACKEND_CLEAN_DIR" "$FRONTEND_CLEAN_DIR"
rsync -a "/opt/apps/repo/$FLASK_SUBDIR"/ "$BACKEND_CLEAN_DIR"/ || true
rsync -a "/opt/apps/repo/$EXPRESS_SUBDIR"/ "$FRONTEND_CLEAN_DIR"/ || true

echo "[INFO] Installing Python deps in virtualenv"
cd "$BACKEND_CLEAN_DIR"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip || echo "[WARN] pip upgrade failed"
if [ -f requirements.txt ]; then
  pip install -r requirements.txt || echo "[ERROR] requirements install failed"
else
  echo "[WARN] No requirements.txt found"
fi

echo "[INFO] Installing Node deps"
cd "$FRONTEND_CLEAN_DIR"
if [ -f package-lock.json ]; then
  npm ci --omit=dev || npm ci || npm install --production
elif [ -f package.json ]; then
  npm install --production
else
  echo "[WARN] No package.json found"
fi

echo "[INFO] Writing systemd units"
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

cat > /etc/systemd/system/express.service <<EOF
[Unit]
Description=Express App
After=network.target
[Service]
User=root
WorkingDirectory=/opt/apps/repo/frontend_clean
ExecStart=/usr/bin/node app.js
Restart=always
Environment=BACKEND_URL=http://127.0.0.1:5000/api NODE_ENV=production
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flask.service express.service
if ! systemctl start flask.service express.service; then
  echo "[ERROR] Failed to start services" >&2
  systemctl status flask.service express.service || true
  exit 1
fi
echo "[INFO] Services started"
echo "[INFO] user_data completed"