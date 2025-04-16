import requests
import json
import os
from urllib.parse import urlparse
import shutil

# Create directories for data and images
os.makedirs('data', exist_ok=True)
os.makedirs('static/images/products', exist_ok=True)

def download_image(url, product_id):
    try:
        response = requests.get(url, stream=True)
        if response.status_code == 200:
            # Get file extension from URL
            parsed_url = urlparse(url)
            ext = os.path.splitext(parsed_url.path)[1]
            if not ext:
                ext = '.jpg'  # Default extension
            
            # Save image
            image_path = f'static/images/products/{product_id}{ext}'
            with open(image_path, 'wb') as f:
                response.raw.decode_content = True
                shutil.copyfileobj(response.raw, f)
            return f'/static/images/products/{product_id}{ext}'
    except Exception as e:
        print(f"Error downloading image for product {product_id}: {e}")
    return url  # Return original URL if download fails

def download_products():
    # Download all products
    response = requests.get('https://fakestoreapi.com/products')
    products = response.json()
    
    # Process each product
    processed_products = []
    for product in products:
        # Download image and update image URL
        local_image_path = download_image(product['image'], product['id'])
        product['image'] = local_image_path
        
        # Add to processed products
        processed_products.append(product)
    
    # Save products to JSON file
    with open('data/products.json', 'w') as f:
        json.dump(processed_products, f, indent=2)
    
    print(f"Downloaded {len(processed_products)} products")
    print("Products data saved to data/products.json")
    print("Images saved to static/images/products/")

if __name__ == '__main__':
    download_products() 