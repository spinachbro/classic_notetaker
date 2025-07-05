#!/bin/bash

# Deployment script for Classic Notetaker on DigitalOcean

echo "🚀 Starting deployment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Python and pip
echo "🐍 Installing Python and pip..."
sudo apt install -y python3 python3-pip python3-venv

# Install nginx
echo "🌐 Installing nginx..."
sudo apt install -y nginx

# Create application directory
echo "📁 Setting up application directory..."
sudo mkdir -p /var/www/flask_notetaker
sudo chown $USER:$USER /var/www/flask_notetaker

# Copy application files (if not using git)
if [ ! -d "/var/www/flask_notetaker/.git" ]; then
    echo "📋 Copying application files..."
    cp -r * /var/www/flask_notetaker/
else
    echo "📋 Using Git repository..."
    cd /var/www/flask_notetaker
    git pull origin main
fi

# Set up virtual environment
echo "🔧 Setting up virtual environment..."
cd /var/www/flask_notetaker
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create database
echo "🗄️ Creating database..."
python3 -c "
from app import app, db
with app.app_context():
    db.create_all()
print('Database created successfully!')
"

# Create systemd service
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/flask_notetaker.service > /dev/null <<EOF
[Unit]
Description=Classic Notetaker
After=network.target

[Service]
User=$USER
WorkingDirectory=/var/www/flask_notetaker
Environment="PATH=/var/www/flask_notetaker/venv/bin"
ExecStart=/var/www/flask_notetaker/venv/bin/gunicorn --config gunicorn.conf.py wsgi:app
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Configure nginx
echo "🌐 Configuring nginx..."
sudo tee /etc/nginx/sites-available/flask_notetaker > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location /classic-notetaker {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Script-Name /classic-notetaker;
    }

    location /classic-notetaker/static {
        alias /var/www/flask_notetaker/static;
    }
}
EOF

# Enable nginx site
sudo ln -sf /etc/nginx/sites-available/flask_notetaker /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Start services
echo "🚀 Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable flask_notetaker
sudo systemctl start flask_notetaker
sudo systemctl restart nginx

# Check status
echo "📊 Checking service status..."
sudo systemctl status flask_notetaker --no-pager -l
sudo systemctl status nginx --no-pager -l

echo "✅ Deployment complete!"
echo "🌐 Your application should be available at: http://$(curl -s ifconfig.me)"
echo "📝 To check logs: sudo journalctl -u flask_notetaker -f" 