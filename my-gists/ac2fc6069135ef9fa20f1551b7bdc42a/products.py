import csv
import time

from requests import get
from bs4 import BeautifulSoup

# Define constants
BASE_URL = 'https://demo.theme-sky.com/loobek-drone/shop/'
NUM_PAGES = 4
# Define a function to get the product links from a page
def get_links(page_url):
    """Get the product links from a page.

    Args:
        page_url: The URL of the page to scrape.

    Returns:
        A list of product links.
    """

    try:
        response = get(page_url)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        products = soup.find('div', class_='products')
        links = [product.find('a')['href'] for product in products]
        return links
    except Exception as e:
        print(f'Error getting links from {page_url}: {e}')
        return []

# Define a function to get the product data from a link
def get_product_data(link):
    """Get the product data from a link.

    Args:
        link: The URL of the product page to scrape.

    Returns:
        A dictionary of product data.
    """

    try:
        response = get(link)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')

        title = soup.find('h1').text.strip()
        price = soup.find('span', class_='woocommerce-Price-amount').text.strip()
        sku = soup.find('span', class_='sku').text.strip()
        
        div_element = soup.find('div', class_='images')
        image_elements = div_element.find_all('img', {'data-src': True})
        image_urls = [image_element['data-src'] for image_element in image_elements]

        product = {
           # 'title': title,
           # 'price': price,
            'sku': sku,
            'images': ','.join(image_urls)
        }

        return product
    except Exception as e:
        print(f'Error getting product data from {link}: {e}')
        return {}

# Define a function to download the images for a product
def download_product_images(product):
    """Download the images for a product.

    Args:
        product: A dictionary of product data.
    """

    for i, image_url in enumerate(product['image_urls']):
        try:
            image_response = get(image_url)
            image_response.raise_for_status()
            image_name = f"product_images/{product['title']}_{product['sku']}_{i}.jpg"
            with open(image_name, "wb") as image_file:
                image_file.write(image_response.content)
        except Exception as e:
            print(f'Error downloading image from {image_url}: {e}')

# Open a CSV file for writing
with open('drone.csv', 'w', encoding='utf8', newline='') as f:
    # Create a CSV writer object with the field names
    fc = csv.DictWriter(f, fieldnames=['sku', 'images'])
    # Write the header row
    fc.writeheader()

    # Loop over each page number
    for page in range(1, NUM_PAGES + 1):
        # Construct the page URL with the query parameter
        page_url = f'{BASE_URL}?paged={page}'
        # Get the product links from the page
        links = get_links(page_url)

        # Loop over each product link
        for link in links:
            # Get the product data from the link
            product = get_product_data(link)

            # Download the product images
            # download_product_images(product)

            # Write the product data to the CSV file
            fc.writerow(product)

            # Wait for one second to avoid overloading the server
            time.sleep(1)
