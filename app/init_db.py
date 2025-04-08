import json
import os
from download_products import download_products

def init_database():
    # Create necessary directories
    os.makedirs('data', exist_ok=True)
    os.makedirs('static/images/products', exist_ok=True)
    
    # Download products from FakeStoreAPI
    print("Downloading products from FakeStoreAPI...")
    download_products()
    
    print("Database initialization complete!")

if __name__ == '__main__':
    init_database() 