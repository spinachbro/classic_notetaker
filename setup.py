#!/usr/bin/env python3
"""
Setup script for Classic Notetaker
"""

import subprocess
import sys
import os

def install_requirements():
    """Install required packages"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Dependencies installed successfully!")
    except subprocess.CalledProcessError:
        print("❌ Failed to install dependencies")
        return False
    return True

def create_database():
    """Create the database"""
    try:
        from app import app, db
        with app.app_context():
            db.create_all()
        print("✅ Database created successfully!")
    except Exception as e:
        print(f"❌ Failed to create database: {e}")
        return False
    return True

def main():
    print("🚀 Setting up Classic Notetaker...")
    
    # Install requirements
    if not install_requirements():
        return
    
    # Create database
    if not create_database():
        return
    
    print("\n🎉 Setup complete!")
    print("To run the application:")
    print("  python app.py")
    print("Then open http://localhost:5000 in your browser")

if __name__ == "__main__":
    main() 