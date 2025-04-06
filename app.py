from flask import Flask, render_template, request, redirect, url_for, flash, session
from flask_bcrypt import Bcrypt
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField, TextAreaField, SelectField
from wtforms.validators import DataRequired, Email, Length, EqualTo, ValidationError
import json
import os
import re
from datetime import datetime

app = Flask(__name__)
app.config["SECRET_KEY"] = "open-secret-key"  # Using a simple key for development
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message_category = 'info'

class User(UserMixin):
    def __init__(self, id, username, email, password):
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.orders = []
        self.addresses = []
        self.wishlist = []

    def get_id(self):
        return str(self.id)

# Load products from local JSON file
def load_products():
    try:
        with open('data/products.json', 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return []

# Get all products
def get_all_products():
    return load_products()

# Get product by ID
def get_product(product_id):
    products = load_products()
    for product in products:
        if product['id'] == product_id:
            return product
    return None

# Get products by category
def get_products_by_category(category):
    products = load_products()
    return [p for p in products if p['category'] == category]

# Get products by search term
def search_products(term):
    products = load_products()
    term = term.lower()
    return [p for p in products if term in p['title'].lower() or term in p['description'].lower()]

# Load users from JSON file
def load_users():
    try:
        with open('data/users.json', 'r') as f:
            data = json.load(f)
            # Convert stored users back to User objects
            users_dict = {}
            for user_id, user_data in data['users'].items():
                user = User(
                    int(user_id),
                    user_data['username'],
                    user_data['email'],
                    user_data['password']
                )
                users_dict[int(user_id)] = user
            return users_dict
    except FileNotFoundError:
        return {}

# Save users to JSON file
def save_users(users_dict):
    users_data = {
        'users': {
            str(user_id): {
                'username': user.username,
                'email': user.email,
                'password': user.password
            }
            for user_id, user in users_dict.items()
        }
    }
    with open('data/users.json', 'w') as f:
        json.dump(users_data, f, indent=4)

# Load users at startup
users = load_users()

# In-memory storage for orders, addresses, and wishlist
orders = {}
addresses = {}
wishlist = {}

class RegistrationForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired(), Length(min=4, max=20)])
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[
        DataRequired(),
        Length(min=8, message='Password must be at least 8 characters long')
    ])
    confirm_password = PasswordField('Confirm Password', validators=[
        DataRequired(),
        EqualTo('password', message='Passwords must match')
    ])
    submit = SubmitField('Register')

    def validate_password(self, field):
        password = field.data
        if len(password) < 8:
            raise ValidationError('Password must be at least 8 characters long')
        if not re.search(r'[A-Z]', password):
            raise ValidationError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', password):
            raise ValidationError('Password must contain at least one lowercase letter')
        if not re.search(r'[0-9]', password):
            raise ValidationError('Password must contain at least one number')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
            raise ValidationError('Password must contain at least one special character (!@#$%^&*(),.?":{}|<>)')

class AddressForm(FlaskForm):
    street = StringField('Street Address', validators=[DataRequired()])
    city = StringField('City', validators=[DataRequired()])
    state = StringField('State', validators=[DataRequired()])
    zip_code = StringField('ZIP Code', validators=[DataRequired()])
    country = StringField('Country', validators=[DataRequired()])
    submit = SubmitField('Save Address')

class SearchForm(FlaskForm):
    search = StringField('Search', validators=[DataRequired()])
    category = SelectField('Category', choices=[
        ('all', 'All Categories'),
        ('electronics', 'Electronics'),
        ('jewelery', 'Jewelery'),
        ('men\'s clothing', 'Men\'s Clothing'),
        ('women\'s clothing', 'Women\'s Clothing')
    ])
    submit = SubmitField('Search')

class LoginForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(), Email()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Login')

class CheckoutForm(FlaskForm):
    street = StringField('Street Address', validators=[DataRequired()])
    city = StringField('City', validators=[DataRequired()])
    state = StringField('State', validators=[DataRequired()])
    zip_code = StringField('ZIP Code', validators=[DataRequired()])
    country = StringField('Country', validators=[DataRequired()])
    submit = SubmitField('Place Order')

@login_manager.user_loader
def load_user(user_id):
    return users.get(int(user_id))

@app.route('/')
def home():
    products = get_all_products()
    return render_template('index.html', products=products)

@app.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        if any(user.email == form.email.data for user in users.values()):
            flash('Email already registered', 'danger')
            return redirect(url_for('register'))
        
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        user_id = len(users) + 1
        user = User(user_id, form.username.data, form.email.data, hashed_password)
        users[user_id] = user
        save_users(users)  # Save users to JSON file
        flash('Registration successful! Please login.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html', form=form)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    
    form = LoginForm()
    if form.validate_on_submit():
        user = next((user for user in users.values() if user.email == form.email.data), None)
        if user and bcrypt.check_password_hash(user.password, form.password.data):
            login_user(user)
            # Initialize session variables for the user
            if 'cart' not in session:
                session['cart'] = []
            if 'wishlist' not in session:
                session['wishlist'] = []
            if 'orders' not in session:
                session['orders'] = []
            session.modified = True
            flash('Logged in successfully!', 'success')
            return redirect(url_for('home'))
        flash('Invalid email or password', 'danger')
    
    return render_template('login.html', form=form)

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('You have been logged out', 'success')
    return redirect(url_for('home'))

@app.route('/product/<int:id>')
def product_details(id):
    product = get_product(id)
    if not product:
        flash('Product not found', 'danger')
        return redirect(url_for('home'))
    return render_template('product_details.html', product=product)

@app.route('/add_to_cart/<int:product_id>')
@login_required
def add_to_cart(product_id):
    if 'cart' not in session:
        session['cart'] = []
    
    product = get_product(product_id)
    if product:
        # Check if product is already in cart
        for item in session['cart']:
            if isinstance(item, dict) and item['id'] == product_id:
                flash('Product is already in your cart', 'info')
                return redirect(url_for('cart'))
        
        # Add product as a dictionary
        session['cart'].append({
            'id': product_id,
            'title': product['title'],
            'price': product['price'],
            'image': product['image']
        })
        session.modified = True
        flash('Product added to cart!', 'success')
    else:
        flash('Product not found', 'danger')
    
    return redirect(url_for('cart'))

@app.route('/cart')
@login_required
def cart():
    cart_items = session.get('cart', [])
    # Ensure all items are dictionaries
    cart_items = [item for item in cart_items if isinstance(item, dict)]
    total = sum(item['price'] for item in cart_items)
    return render_template('cart.html', cart_items=cart_items, total=total)

@app.route('/remove_from_cart/<int:index>')
@login_required
def remove_from_cart(index):
    if 'cart' in session and 0 <= index < len(session['cart']):
        session['cart'].pop(index)
        session.modified = True
        flash('Product removed from cart', 'success')
    return redirect(url_for('cart'))

@app.route('/addresses', methods=['GET', 'POST'])
@login_required
def addresses_page():
    form = AddressForm()
    if form.validate_on_submit():
        address = {
            'street': form.street.data,
            'city': form.city.data,
            'state': form.state.data,
            'zip_code': form.zip_code.data,
            'country': form.country.data
        }
        if current_user.id not in addresses:
            addresses[current_user.id] = []
        addresses[current_user.id].append(address)
        flash('Address saved successfully!', 'success')
        return redirect(url_for('addresses_page'))
    return render_template('addresses.html', form=form, addresses=addresses.get(current_user.id, []))

@app.route('/orders')
@login_required
def orders():
    orders = session.get('orders', [])
    user_orders = [order for order in orders if order['user_id'] == current_user.id]
    return render_template('orders.html', orders=user_orders)

@app.route('/wishlist')
@login_required
def wishlist_page():
    if 'wishlist' not in session:
        session['wishlist'] = []
    
    wishlist_items = []
    for product_id in session['wishlist']:
        product = get_product(product_id)
        if product:
            wishlist_items.append(product)
    
    return render_template('wishlist.html', wishlist_items=wishlist_items)

@app.route('/add_to_wishlist/<int:product_id>')
@login_required
def add_to_wishlist(product_id):
    if 'wishlist' not in session:
        session['wishlist'] = []
    
    if product_id not in session['wishlist']:
        session['wishlist'].append(product_id)
        session.modified = True
        flash('Product added to wishlist!', 'success')
    else:
        flash('Product already in wishlist', 'info')
    
    return redirect(url_for('wishlist_page'))

@app.route('/remove_from_wishlist/<int:product_id>')
@login_required
def remove_from_wishlist(product_id):
    if 'wishlist' in session and product_id in session['wishlist']:
        session['wishlist'].remove(product_id)
        session.modified = True
        flash('Product removed from wishlist', 'success')
    return redirect(url_for('wishlist_page'))

@app.route('/search', methods=['GET', 'POST'])
def search():
    form = SearchForm()
    products = []
    if form.validate_on_submit():
        search_term = form.search.data.lower()
        category = form.category.data
        all_products = get_all_products()
        for product in all_products:
            if (search_term in product['title'].lower() or 
                search_term in product['description'].lower()):
                if category == 'all' or product['category'] == category:
                    products.append(product)
    return render_template('search.html', form=form, products=products)

@app.route('/checkout', methods=['GET', 'POST'])
@login_required
def checkout():
    form = CheckoutForm()
    cart_items = session.get('cart', [])
    
    if not cart_items:
        flash('Your cart is empty', 'warning')
        return redirect(url_for('cart'))
    
    total = sum(item['price'] for item in cart_items)
    
    if form.validate_on_submit():
        order = {
            'user_id': current_user.id,
            'items': cart_items,
            'total': total,
            'shipping_address': {
                'street': form.street.data,
                'city': form.city.data,
                'state': form.state.data,
                'zip_code': form.zip_code.data,
                'country': form.country.data
            },
            'order_date': datetime.now().isoformat(),
            'status': 'pending'
        }
        
        if 'orders' not in session:
            session['orders'] = []
        session['orders'].append(order)
        
        # Clear cart after successful order
        session['cart'] = []
        session.modified = True
        
        flash('Order placed successfully!', 'success')
        return redirect(url_for('orders'))
    
    return render_template('checkout.html', form=form, cart_items=cart_items, total=total)

if __name__ == '__main__':
    # Create necessary directories
    os.makedirs('data', exist_ok=True)
    os.makedirs('static/images/products', exist_ok=True)
    
    # Initialize products.json if it doesn't exist
    if not os.path.exists('data/products.json'):
        with open('data/products.json', 'w') as f:
            json.dump([], f)
    
    # Initialize users.json if it doesn't exist
    if not os.path.exists('data/users.json'):
        with open('data/users.json', 'w') as f:
            json.dump({'users': {}}, f, indent=4)
    
    app.run(debug=True)