import random
import re
import time

from bs4 import BeautifulSoup
from bs4.element import Tag
from cookielib import split_header_words
import requests


YEAR = 2016
DOMAIN = 'https://www.amazon.com'
ORDERS_URL = 'https://www.amazon.com/gp/your-account/order-history?opt=ab&digitalOrders=1&unifiedOrders=1&returnTo=&orderFilter=year-{year}'.format(year=YEAR)
USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36'
COOKIES_FILE = 'cookies.txt'

def get_order_page_urls(page):
    container = page.find(id='ordersContainer')
    for order in container('div', class_='order'):
        link = order.find('a', href=re.compile('^/gp/your-account/order-details/'))
        yield '/'.join((DOMAIN, link.attrs['href']))


def get_next_page(session, page):
    container = page.find(id='ordersContainer')
    pagination = container.find(class_='a-pagination')
    next_page_el = pagination.find('li', class_='a-last')
    if next_page_el and 'a-disabled' not in next_page_el.attrs['class']:
        url = '/'.join((DOMAIN, next_page_el.a.attrs['href']))
        resp = session.get(url)
        if resp.status_code != 200:
            raise RuntimeError('Page response to {} not 200: {}'.format(url, resp))
        session.headers.update({'Referer': url})
        return BeautifulSoup(resp.text)


def get_order_page(session, url):
    resp = session.get(url)
    if resp.status_code != 200:
        raise RuntimeError('Order page response to {} not 200: {}'.format(url, resp))
    return BeautifulSoup(resp.text)


def _find_tax_el(el):
    if (
        not isinstance(el, Tag) and
        (not el.name == 'div' or 'a-column' not in el.attrs.get('class'))
    ):
        return False

    prev_tag = None
    for prev in el.previous_siblings:
        if isinstance(el, Tag) and prev.name == 'div':
            prev_tag = prev
    if not prev_tag or 'a-column' not in prev_tag.attrs.get('class'):
        return False

    return 'tax to be collected' in prev_tag.text.strip()


def get_tax_amount(order_page):
    container = order_page.find('div', id='orderDetails')
    tax_container = container.find(_find_tax_el)
    if tax_container:
        text = tax_container.text.strip().lstrip('$')
        return float(text)


def get_total_tax():
    session = requests.Session()
    session.headers.update({
        'User-Agent': USER_AGENT,
        'Referer': 'https://www.amazon.com/gp/css/order-history/ref=nav_nav_orders_first'
    })
    cookie_str = open(COOKIES_FILE).read().strip()
    cookie_attrs = split_header_words([cookie_str])[0]
    session.cookies.update(dict(cookie_attrs))
    resp = session.get(ORDERS_URL)
    if resp.status_code != 200:
        raise RuntimeError('Main page response not 200: {}'.format(resp))
    soup = BeautifulSoup(resp.text)
    session.headers.update({'Referer': ORDERS_URL})

    tax_amt = 0.
    page = 1
    while soup:
        for order_url in get_order_page_urls(soup):
            order_page = get_order_page(session, order_url)
            this_tax_amt = get_tax_amount(order_page)
            if this_tax_amt is None:
                print('  Warning: no tax found from {}'.format(order_url))
                this_tax_amt = 0.0

            print('  %0.2f from %s' % (this_tax_amt, order_url))

            tax_amt += this_tax_amt

            time.sleep(random.random())

        soup = get_next_page(session, soup)

        print('Total of %0.2f after Page %d' % (tax_amt, page))
        page += 1

    return tax_amt


if __name__ == '__main__':
    total = get_total_tax()

    print('Grand total: %0.2f' % total)
