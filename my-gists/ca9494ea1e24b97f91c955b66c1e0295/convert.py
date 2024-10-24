import os
import re
import sys
from bs4 import BeautifulSoup
import html2text

def generate_frontmatter(title, date):
    return """---
title: %s
date: %s
draft: false
---

""" % (title, date)

def convert(item, destination):
    if item.endswith(".html"):
        content = ""
        with open(item , mode='r') as content_file:
            content = content_file.read()
        soup = BeautifulSoup(content, "html.parser")

        article = soup.find('div', attrs={'class':"article"})
        title = ""
        if article.h2:
            title = article.h2.extract().string

        date_elem = soup.find('abbr', attrs={'class':'published'})
        date = ""
        if date_elem:
            date = date_elem['title']
            soup.find('div', attrs={'class':'byline'}).extract()

        markdown = html2text.html2text(article.prettify())
        output_yearmonth = re.match(r".*/(\d+/\d+)$", os.path.dirname(item))

        output_directory = output_yearmonth and destination + "/" + output_yearmonth.groups(1)[0] or destination

        if not os.path.exists(output_directory):
            os.makedirs(output_directory)
        output_file = output_directory + '/' + os.path.splitext(os.path.basename(item))[0] + ".md"

        with open(output_file, mode='w') as output_file:
            output_file.write(generate_frontmatter(title, date))
            output_file.write(markdown.encode('utf-8'))


def convert_directory(root, directory, destination):
    for path in os.walk(root+directory):
        for item in path[2]:
            convert(path[0]+'/'+item, destination)

def process():
    source = "../../sitharus.com/"
    destination = "../content/post"
    roots = os.listdir(source)

    for dirname in roots:
        if re.match(r"\d+", dirname) is not None and os.path.isdir(source + dirname):
            convert_directory(source, dirname, destination)


if len(sys.argv) > 1:
    filename = sys.argv[1]
    destination = sys.argv[2]
    print "Converting %s to %s" % (filename, destination)
    convert(filename, destination)
else:
    process()
