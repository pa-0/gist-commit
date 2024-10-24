import base64
import mimetypes
import os

from bs4 import BeautifulSoup


with open('example.html', 'rb') as file_handle:  # Read in as a binary file
    soup = BeautifulSoup(file_handle)

for idx, img in enumerate(soup.findAll('img')):
    img_src = img.attrs['src']

    mimetype = mimetypes.guess_type(img_src)
    img_ext = mimetype[0].split('/')[1]

    base64_key_str = ';base64,'
    b64_idx = img_src.index(base64_key_str) + len(base64_key_str)
    img_b64_str = img_src[b64_idx:].encode('utf-8')

    file_name = str(idx) + os.extsep + img_ext
    file_path = os.path.join('images', file_name)
    with open(file_path, 'wb') as f:
        decoded_a_bytes = base64.decodebytes(img_b64_str)
        f.write(decoded_a_bytes)

    img.attrs['src'] = file_path

html = soup.prettify(soup.original_encoding)
with open('example_decoded.html', 'wb') as file_handle:
    file_handle.write(html)