# Deployment Guide for Classic Notetaker

## Prerequisites

1. **DigitalOcean Account**: Sign up at [digitalocean.com](https://digitalocean.com)
2. **Domain Name** (optional): For a custom domain
3. **SSH Key**: Set up SSH key authentication

## 🔧 Manual Deployment Steps

### Step 1: Connect to Your Droplet
Open your terminal and run:
```bash
ssh root@159.89.113.96
```
When prompted about the host authenticity, type `yes` and press Enter.

### Step 2: Clone Your Repository
Once connected to your droplet, run:
```bash
git clone https://github.com/spinachbro/standard_notetaker.git /var/www/flask_notetaker
cd /var/www/flask_notetaker
```

### Step 3: Run the Deployment Script
```bash
chmod +x deploy.sh
./deploy.sh
```

### Step 4: Configure Firewall
```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw enable
```

## 🎯 What This Will Do:

✅ **Install Python, nginx, and dependencies**
✅ **Set up virtual environment**
✅ **Create systemd service for auto-start**
✅ **Configure nginx as reverse proxy**
✅ **Set up database**
✅ **Enable services to start on boot**

## 🌐 After Deployment:

Your Classic Notetaker will be available at:
**http://159.89.113.96**

##  Troubleshooting:

If you get any errors during deployment, you can:
- Check service status: `sudo systemctl status flask_notetaker`
- View logs: `sudo journalctl -u flask_notetaker -f`
- Restart services: `sudo systemctl restart flask_notetaker`

Would you like me to help you with any specific part of the deployment process, or do you want to try running these commands manually? 