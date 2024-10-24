def construct_product_json(soup, product_type,search):
    '''
    body_html = description - (copy HTML)
    images = obvious -
    tags = tags can get from amazon -
    title = obvious -
    price = use markup from original price - 
    vendor = from title-
    product_type = get_from_amazon - 
    '''     
    data = {
        "product": {
            "title": title,
            "body_html": description,
            "vendor": '****',
            "product_type": product_type,
            "tags": tags,
            "price": price,
            "images": images[:image_limit]
        }
    }

    return data