from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os
from config import config

app = Flask(__name__)
app.config.from_object(config['production'])

# Configure URL prefix for the application
app.config['APPLICATION_ROOT'] = '/classic-notetaker'
app.config['PREFERRED_URL_SCHEME'] = 'https'

db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

# Models
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(120), nullable=False)
    topics = db.relationship('Topic', backref='owner', lazy=True)

class Topic(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.String(200), nullable=False)
    date_added = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    entries = db.relationship('Entry', backref='topic', lazy=True, cascade='all, delete-orphan')

class Entry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.Text, nullable=False)
    date_added = db.Column(db.DateTime, default=datetime.utcnow)
    topic_id = db.Column(db.Integer, db.ForeignKey('topic.id'), nullable=False)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        if User.query.filter_by(username=username).first():
            flash('Username already exists')
            return render_template('register.html')
        
        user = User(username=username, password_hash=generate_password_hash(password))
        db.session.add(user)
        db.session.commit()
        
        login_user(user)
        flash('Registration successful!')
        return redirect(url_for('index'))
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            flash('Logged in successfully!')
            return redirect(url_for('index'))
        else:
            flash('Invalid username or password')
    
    return render_template('login.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Logged out successfully!')
    return redirect(url_for('index'))

@app.route('/topics')
@login_required
def topics():
    topics = Topic.query.filter_by(user_id=current_user.id).order_by(Topic.date_added).all()
    return render_template('topics.html', topics=topics)

@app.route('/topics/<int:topic_id>')
@login_required
def topic(topic_id):
    topic = Topic.query.get_or_404(topic_id)
    if topic.user_id != current_user.id:
        flash('You do not have permission to view this topic.')
        return redirect(url_for('topics'))
    
    entries = Entry.query.filter_by(topic_id=topic_id).order_by(Entry.date_added.desc()).all()
    return render_template('topic.html', topic=topic, entries=entries)

@app.route('/new_topic', methods=['GET', 'POST'])
@login_required
def new_topic():
    if request.method == 'POST':
        text = request.form['text']
        if text.strip():
            topic = Topic(text=text, user_id=current_user.id)
            db.session.add(topic)
            db.session.commit()
            flash('Topic added successfully!')
            return redirect(url_for('topics'))
        else:
            flash('Topic text cannot be empty')
    
    return render_template('new_topic.html')

@app.route('/new_entry/<int:topic_id>', methods=['GET', 'POST'])
@login_required
def new_entry(topic_id):
    topic = Topic.query.get_or_404(topic_id)
    if topic.user_id != current_user.id:
        flash('You do not have permission to add entries to this topic.')
        return redirect(url_for('topics'))
    
    if request.method == 'POST':
        text = request.form['text']
        if text.strip():
            entry = Entry(text=text, topic_id=topic_id)
            db.session.add(entry)
            db.session.commit()
            flash('Entry added successfully!')
            return redirect(url_for('topic', topic_id=topic_id))
        else:
            flash('Entry text cannot be empty')
    
    return render_template('new_entry.html', topic=topic)

@app.route('/edit_entry/<int:entry_id>', methods=['GET', 'POST'])
@login_required
def edit_entry(entry_id):
    entry = Entry.query.get_or_404(entry_id)
    if entry.topic.user_id != current_user.id:
        flash('You do not have permission to edit this entry.')
        return redirect(url_for('topics'))
    
    if request.method == 'POST':
        text = request.form['text']
        if text.strip():
            entry.text = text
            db.session.commit()
            flash('Entry updated successfully!')
            return redirect(url_for('topic', topic_id=entry.topic_id))
        else:
            flash('Entry text cannot be empty')
    
    return render_template('edit_entry.html', entry=entry, topic=entry.topic)

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, port=5001) 