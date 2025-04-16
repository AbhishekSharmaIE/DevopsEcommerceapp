import pytest
from app.app import app, db

@pytest.fixture
def app_fixture():
    app.config['TESTING'] = True
    app.config['WTF_CSRF_ENABLED'] = False
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()

@pytest.fixture
def client(app_fixture):
    with app_fixture.test_client() as client:
        yield client

def test_home_page(client):
    """Test that home page loads successfully"""
    rv = client.get('/')
    assert rv.status_code == 200
    assert b'Welcome' in rv.data

def test_about_page(client):
    """Test that about page loads successfully"""
    rv = client.get('/about')
    assert rv.status_code == 200
    assert b'About' in rv.data

def test_products_page(client):
    """Test that products page loads successfully"""
    rv = client.get('/products')
    assert rv.status_code == 200
    assert b'Products' in rv.data 