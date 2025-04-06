# E-commerce Application

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

## Setup

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
