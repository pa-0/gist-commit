def get_product_links(search):
    SEARCH_VALUES = search.replace(' ', '+')
    COMPLETE_ENDPOINT = BASE_ENDPOINT + SEARCH_VALUES
    HEADERS = rotate_agents()
    r = requests.get(COMPLETE_ENDPOINT, headers=HEADERS)
    soup = BeautifulSoup(r.content, "html.parser")

    all_links = []
    for link in soup.find_all('a'):
        all_links.append(link.get('href'))

    product_links = [link for link in all_links if 'keyword' in str(
        link) and not('offer-listing' in str(link))]

    complete_product_links = []
    split = 4
    counter = 0
    for link in product_links:
        if counter % split == 0:
            complete_product_links.append('https://www.amazon.co.uk'+link)
        counter += 1
    return complete_product_links