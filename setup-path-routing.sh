#!/bin/bash

# Setup script for path-based routing on DigitalOcean droplet

echo "🌐 Setting up nginx for path-based routing..."

# Backup existing nginx config
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Create new nginx configuration
sudo tee /etc/nginx/sites-available/flask-apps > /dev/null <<'EOF'
# Nginx configuration for path-based multiple applications

server {
    listen 80;
    server_name 159.89.113.96;  # Replace with your domain when you have one

    # Main Classic Notetaker app (classic-notetaker path)
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files for main app
    location /static {
        alias /var/www/flask_notetaker/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
}
EOF

# Disable default site and enable flask-apps
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/flask-apps /etc/nginx/sites-enabled/

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    # Reload nginx
    sudo systemctl reload nginx
    echo "✅ Nginx configured successfully for path-based routing!"
    echo "🌐 Your main app is available at: http://159.89.113.96"
    echo "📋 To add new apps, use: ./deploy-path-app.sh <app_name> <port> <path> <github_repo>"
else
    echo "❌ Nginx configuration test failed!"
    echo "Please check the configuration manually."
fi 