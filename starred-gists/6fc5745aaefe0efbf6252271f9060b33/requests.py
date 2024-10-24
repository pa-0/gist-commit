import requests 

BASE_ENDPOINT = 'https://%s:%s@%s.myshopify.com/admin' % (
    API_KEY, PASSWORD, SHOP_NAME)
PRODUCT_ENDPOINT = '/api/2021-07/products.json'

def create_new_product(json_data):
    complete_endpoint = BASE_ENDPOINT + PRODUCT_ENDPOINT
    r = requests.post(complete_endpoint, json=json_data)
    return r

def delete_new_product(json_data):
    complete_endpoint = BASE_ENDPOINT + PRODUCT_ENDPOINT
    r = requests.delete(complete_endpoint, data=json_data)
    return r

def get_products():
    complete_endpoint = BASE_ENDPOINT + PRODUCT_ENDPOINT
    r = requests.get(complete_endpoint)
    return r