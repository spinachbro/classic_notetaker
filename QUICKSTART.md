# Quick Start Guide - Classic Notetaker

## Prerequisites
- Python 3.7 or higher
- pip (Python package installer)

## Installation

1. **Navigate to the Flask directory:**
   ```bash
   cd flask_notetaker
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   ```

3. **Activate the virtual environment:**
   - On macOS/Linux:
     ```bash
     source venv/bin/activate
     ```
   - On Windows:
     ```bash
     venv\Scripts\activate
     ```

4. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

5. **Run the setup script (optional):**
   ```bash
   python setup.py
   ```

## Running the Application

1. **Start the Flask server:**
   ```bash
   python app.py
   ```

2. **Open your web browser and go to:**
   ```
   http://localhost:5000
   ```

## First Steps

1. **Register a new account** by clicking "Register" in the navigation
2. **Create your first topic** by clicking "Add New Topic"
3. **Add entries to your topic** by clicking on the topic name and then "Add New Entry"
4. **Edit entries** by clicking the "Edit" link next to any entry

## Features

- ✅ User registration and login
- ✅ Create and manage learning topics
- ✅ Add detailed entries to topics
- ✅ Edit existing entries
- ✅ Responsive design
- ✅ User-specific data isolation

## Troubleshooting

### Common Issues:

1. **"ModuleNotFoundError: No module named 'flask'"**
   - Make sure you've activated the virtual environment
   - Run `pip install -r requirements.txt`

2. **"Address already in use"**
   - The port 5000 might be in use
   - Change the port in `app.py` or kill the existing process

3. **Database errors**
   - Delete `notetaker.db` and restart the application
   - The database will be recreated automatically

### Getting Help:
- Check the `README.md` for detailed documentation
- Review `COMPARISON.md` to understand differences from Django version
- Ensure all dependencies are installed correctly

## Development

To modify the application:

1. **Edit `app.py`** for routes and logic
2. **Edit templates in `templates/`** for HTML
3. **Edit `static/css/style.css`** for styling
4. **Edit `static/js/script.js`** for JavaScript

The application will automatically reload when you make changes (in debug mode). 