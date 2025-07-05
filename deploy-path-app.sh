#!/bin/bash

# Deployment script for path-based routing apps

APP_NAME=$1
APP_PORT=$2
APP_PATH=$3
GITHUB_REPO=$4

if [ -z "$APP_NAME" ] || [ -z "$APP_PORT" ] || [ -z "$APP_PATH" ] || [ -z "$GITHUB_REPO" ]; then
    echo "Usage: ./deploy-path-app.sh <app_name> <port> <path> <github_repo>"
    echo "Example: ./deploy-path-app.sh blog 8001 /blog https://github.com/user/blog.git"
    exit 1
fi

echo "🚀 Deploying $APP_NAME on port $APP_PORT at path $APP_PATH..."

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

# Update nginx configuration
echo "🌐 Updating nginx configuration..."
sudo tee -a /etc/nginx/sites-available/flask-apps > /dev/null <<EOF

    # $APP_NAME app
    location $APP_PATH {
        proxy_pass http://127.0.0.1:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Script-Name $APP_PATH;
    }

    # Static files for $APP_NAME app
    location $APP_PATH/static {
        alias /var/www/$APP_NAME/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
EOF

# Test nginx configuration
sudo nginx -t

if [ $? -eq 0 ]; then
    # Reload nginx
    sudo systemctl reload nginx
    echo "✅ $APP_NAME deployed successfully!"
    echo "🌐 Access your app at: http://159.89.113.96$APP_PATH"
    echo "📊 Check status: sudo systemctl status $APP_NAME"
else
    echo "❌ Nginx configuration test failed!"
    echo "Please check the nginx configuration manually."
fi 