#!/bin/bash

# Multi-app deployment script for DigitalOcean droplet

APP_NAME=$1
APP_PORT=$2
GITHUB_REPO=$3

if [ -z "$APP_NAME" ] || [ -z "$APP_PORT" ] || [ -z "$GITHUB_REPO" ]; then
    echo "Usage: ./multi-app-deploy.sh <app_name> <port> <github_repo>"
    echo "Example: ./multi-app-deploy.sh myapp 8001 https://github.com/user/myapp.git"
    exit 1
fi

echo "🚀 Deploying $APP_NAME on port $APP_PORT..."

# Create app directory
sudo mkdir -p /var/www/$APP_NAME
sudo chown $USER:$USER /var/www/$APP_NAME

# Clone or update repository
if [ -d "/var/www/$APP_NAME/.git" ]; then
    echo "📋 Updating existing repository..."
    cd /var/www/$APP_NAME
    git pull origin main
else
    echo "📋 Cloning new repository..."
    git clone $GITHUB_REPO /var/www/$APP_NAME
    cd /var/www/$APP_NAME
fi

# Set up virtual environment
echo "🔧 Setting up virtual environment..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create systemd service
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/$APP_NAME.service > /dev/null <<EOF
[Unit]
Description=$APP_NAME Flask App
After=network.target

[Service]
User=root
WorkingDirectory=/var/www/$APP_NAME
Environment="PATH=/var/www/$APP_NAME/venv/bin"
ExecStart=/var/www/$APP_NAME/venv/bin/gunicorn --config gunicorn.conf.py wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Update gunicorn config for the specific port
sed -i "s/bind = \"0.0.0.0:8000\"/bind = \"0.0.0.0:$APP_PORT\"/" /var/www/$APP_NAME/gunicorn.conf.py

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable $APP_NAME
sudo systemctl start $APP_NAME

echo "✅ $APP_NAME deployed successfully on port $APP_PORT!"
echo "🌐 Access your app at: http://159.89.113.96:$APP_PORT"
echo "📊 Check status: sudo systemctl status $APP_NAME" 