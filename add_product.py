import json
import os
from datetime import datetime

def add_product(title, price, description, category, image_path):
    # Load existing products
    products = []
    if os.path.exists('data/products.json'):
        with open('data/products.json', 'r') as f:
            products = json.load(f)
    
    # Generate new ID
    new_id = max([p['id'] for p in products], default=0) + 1
    
    # Create new product
    new_product = {
        'id': new_id,
        'title': title,
        'price': float(price),
        'description': description,
        'category': category,
        'image': f'/static/images/products/{new_id}.jpg'  # Assuming .jpg extension
    }
    
    # Add to products list
    products.append(new_product)
    
    # Save updated products
    with open('data/products.json', 'w') as f:
        json.dump(products, f, indent=2)
    
    # Copy image to static directory
    if os.path.exists(image_path):
        os.makedirs('static/images/products', exist_ok=True)
        import shutil
        shutil.copy2(image_path, f'static/images/products/{new_id}.jpg')
    
    print(f"Product added successfully with ID: {new_id}")

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Add a new product to the database')
    parser.add_argument('--title', required=True, help='Product title')
    parser.add_argument('--price', required=True, type=float, help='Product price')
    parser.add_argument('--description', required=True, help='Product description')
    parser.add_argument('--category', required=True, help='Product category')
    parser.add_argument('--image', required=True, help='Path to product image')
    
    args = parser.parse_args()
    add_product(args.title, args.price, args.description, args.category, args.image) 