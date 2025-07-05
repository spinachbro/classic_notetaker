# GitHub Setup and Deployment Guide

## Step 1: Create GitHub Repository

1. **Go to GitHub.com** and sign in
2. **Click "New repository"** (green button)
3. **Repository name**: `flask-notetaker`
4. **Description**: `A Flask-based notetaking application`
5. **Make it Public** (or Private if you prefer)
6. **Don't initialize** with README (we already have one)
7. **Click "Create repository"**

## Step 2: Connect Your Local Repository

After creating the repository, GitHub will show you commands. Run these in your terminal:

```bash
# Add the remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/flask-notetaker.git

# Push your code to GitHub
git push -u origin main
```

## Step 3: Verify on GitHub

1. **Refresh your GitHub repository page**
2. **You should see all your files** uploaded
3. **Check that the repository is public** (if you want others to see it)

## Step 4: Deploy to DigitalOcean

Now you can deploy using Git instead of SCP:

### Create Your Droplet
1. **Go to DigitalOcean** and create a new droplet
2. **Choose Ubuntu 22.04 LTS**
3. **Basic plan** ($6/month)
4. **Copy the IP address**

### Deploy Using Git

SSH into your droplet and run:

```bash
# Connect to your droplet
ssh root@YOUR_DROPLET_IP

# Clone your repository
git clone https://github.com/YOUR_USERNAME/flask-notetaker.git
cd flask-notetaker

# Run the deployment script
chmod +x deploy.sh
./deploy.sh
```

## Step 5: Set Up Automatic Updates (Optional)

To automatically pull updates from GitHub:

```bash
# Create a deployment user
adduser deploy
usermod -aG sudo deploy

# Switch to deploy user
su - deploy

# Clone the repository
git clone https://github.com/YOUR_USERNAME/flask-notetaker.git
cd flask-notetaker

# Run deployment as deploy user
sudo ./deploy.sh
```

## Step 6: Update Your Application

When you make changes locally:

```bash
# Make your changes
# Commit them
git add .
git commit -m "Your update message"
git push

# On your droplet, pull the updates
ssh root@YOUR_DROPLET_IP
cd /var/www/flask_notetaker
git pull
sudo systemctl restart flask_notetaker
```

## Benefits of Using Git

✅ **Version Control**: Track all your changes
✅ **Easy Updates**: Just `git pull` to update
✅ **Backup**: Your code is safely stored on GitHub
✅ **Collaboration**: Others can contribute
✅ **Rollback**: Easy to revert to previous versions
✅ **Professional**: Shows your coding skills

## Next Steps

1. **Create the GitHub repository**
2. **Push your code** using the commands above
3. **Create your DigitalOcean droplet**
4. **Deploy using Git** instead of SCP
5. **Set up automatic updates** (optional)

Your Classic Notetaker will be live and easily maintainable! 🚀 