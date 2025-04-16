# E-commerce Application

![CI/CD Pipeline](https://github.com/AbhishekSharmaIE/DevopsEcommerceapp/actions/workflows/cicd.yml/badge.svg)
![CodeQL](https://github.com/AbhishekSharmaIE/DevopsEcommerceapp/actions/workflows/codeql.yml/badge.svg)

A Flask-based e-commerce application with features including:
- User authentication (login/register)
- Product catalog with local storage
- Shopping cart functionality
- Wishlist management
- Order processing
- Search functionality

## Features

- Secure user authentication with password requirements
- Local product storage with image management
- Shopping cart with session management
- Wishlist functionality
- Order history tracking
- Product search and filtering
- Responsive design using Bootstrap

## Technology Stack

- Python 3.11
- Flask web framework
- AWS CodeDeploy for deployment
- GitHub Actions for CI/CD
- Nginx as reverse proxy
- Gunicorn as WSGI server

## Development

1. Clone the repository:
```bash
git clone https://github.com/AbhishekSharmaIE/DevopsEcommerceapp.git
cd DevopsEcommerceapp
```

2. Create and activate virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Initialize the product database:
```bash
python init_db.py
```

5. Run the application:
```bash
python app.py
```

## Deployment

The application is automatically deployed to AWS EC2 using CodeDeploy when changes are pushed to the main branch.

## Security

- CodeQL analysis for security scanning
- Regular dependency updates
- Secure configuration practices

## Password Requirements

When registering, passwords must meet the following criteria:
- Minimum 8 characters
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one number (0-9)
- At least one special character (!@#$%^&(),.?":{}|<>)

## Project Structure

- `app.py`: Main application file
- `templates/`: HTML templates
- `static/`: Static files (CSS, JS, images)
- `data/`: Local data storage
- `requirements.txt`: Project dependencies

# Test CI/CD Pipeline Trigger - $(date)
