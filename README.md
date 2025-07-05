# Classic Notetaker

A Flask-based version of the Learning Log application, converted from Django.

## Features

- User registration and authentication
- Create and manage learning topics
- Add entries to topics
- Edit existing entries
- Responsive design with modern UI

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the application:
```bash
python app.py
```

4. Open your browser and navigate to `http://localhost:5001`

Note: In production, the app is available at `/classic-notetaker` path.

## Project Structure

```
flask_notetaker/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── templates/            # HTML templates
│   ├── base.html
│   ├── index.html
│   ├── login.html
│   ├── register.html
│   ├── topics.html
│   ├── topic.html
│   ├── new_topic.html
│   ├── new_entry.html
│   └── edit_entry.html
├── static/               # Static files
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── script.js
└── notetaker.db         # SQLite database (created automatically)
```

## Key Differences from Django Version

1. **Framework**: Uses Flask instead of Django
2. **Database**: SQLAlchemy ORM instead of Django ORM
3. **Authentication**: Flask-Login instead of Django's built-in auth
4. **Templates**: Jinja2 templates (same syntax as Django templates)
5. **URLs**: Flask routes instead of Django URL patterns
6. **Forms**: Simple HTML forms instead of Django forms

## Database Models

- **User**: Stores user information and authentication data
- **Topic**: Learning topics created by users
- **Entry**: Individual learning entries within topics

## Routes

- `/classic-notetaker/` - Home page
- `/classic-notetaker/register` - User registration
- `/classic-notetaker/login` - User login
- `/classic-notetaker/logout` - User logout
- `/classic-notetaker/topics` - List all user topics
- `/classic-notetaker/topics/<id>` - View specific topic and entries
- `/classic-notetaker/new_topic` - Create new topic
- `/classic-notetaker/new_entry/<topic_id>` - Add entry to topic
- `/classic-notetaker/edit_entry/<entry_id>` - Edit existing entry

## Security Features

- Password hashing with Werkzeug
- User authentication with Flask-Login
- CSRF protection (built into Flask)
- User-specific data isolation 