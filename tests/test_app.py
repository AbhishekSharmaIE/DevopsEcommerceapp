import pytest
from app.app import app

@pytest.fixture
def app_fixture():
    app.config['TESTING'] = True
    app.config['WTF_CSRF_ENABLED'] = False
    return app

@pytest.fixture
def client(app_fixture):
    with app_fixture.test_client() as client:
        yield client

def test_home_page(client):
    """Test that home page loads successfully"""
    rv = client.get('/')
    assert rv.status_code == 200

def test_about_page(client):
    """Test that about page loads successfully"""
    rv = client.get('/about')
    assert rv.status_code == 200 