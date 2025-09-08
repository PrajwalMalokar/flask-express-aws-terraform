#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y python3 python3-pip git curl
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
mkdir -p /opt/apps /opt/apps/flask-app /opt/apps/express-app
cd /opt/apps/flask-app
pip3 install --upgrade pip
if [ -f requirements.txt ]; then
  pip3 install -r requirements.txt
fi
cat > /etc/systemd/system/flask.service <<'EOF'
[Unit]
Description=Flask App
After=network.target
[Service]
User=root
WorkingDirectory=/opt/apps/flask-app
ExecStart=/usr/bin/python3 app.py
Restart=always
[Install]
WantedBy=multi-user.target
EOF
cd /opt/apps/express-app
npm install --production
cat > /etc/systemd/system/express.service <<'EOF'
[Unit]
Description=Express App
After=network.target
[Service]
User=root
WorkingDirectory=/opt/apps/express-app
ExecStart=/usr/bin/node index.js
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable flask.service express.service
systemctl start flask.service express.service