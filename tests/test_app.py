import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_page(client):
    """Test that home page loads successfully"""
    rv = client.get('/')
    assert rv.status_code == 200

def test_about_page(client):
    """Test that about page loads successfully"""
    rv = client.get('/about')
    assert rv.status_code == 200 