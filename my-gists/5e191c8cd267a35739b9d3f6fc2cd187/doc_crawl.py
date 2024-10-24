# -*- coding: utf-8 -*-
"""
Download safariflow books into mobi (or anything else)

Here's what to do:

- Set your firefox profile directory at FIREFOX_PROFILE or if you are
  not sure what it is make it None and I'll make a good guess.

- Login to safariflow from firefox.

- Change the call of safariflow_book defining the output html where I
  will download it initially and the url of the book.

- Install calibre and run

$ ebook-convert ml-with-clojure.html ml-with-clojure.mobi
"""

from bs4 import BeautifulSoup as BS
import urllib2

import cookielib
import sqlite3
import os
import glob

CONTENTS = "host, path, isSecure, expiry, name, value"
COOKIEFILE = 'cookies.lwp'
FIREFOX_PROFILE = "/scratch/mozilla/firefox"

# ff_cookiejar("www.safariflow.com")
def ff_cookiejar(host, ff_dir=None):
    cookie_dir= ff_dir or FIREFOX_PROFILE or \
                glob.glob(os.path.expanduser("~/.mozilla/firefox/*.default")).pop(0)
    cj = cookielib.LWPCookieJar()
    print "Opeing with sqlite3.connect('%s')" % (cookie_dir + "/cookies.sqlite")
    con = sqlite3.connect(cookie_dir + "/cookies.sqlite")
    cur = con.cursor()
    sql = "SELECT {c} FROM moz_cookies WHERE host LIKE '%{h}%'".format(c=CONTENTS, h=host)
    cur.execute(sql)
    for item in cur.fetchall():
        c = cookielib.Cookie(0, item[4], item[5],
                             None, False,
                             item[0], item[0].startswith('.'), item[0].startswith('.'),
                             item[1], False,
                             item[2],
                             item[3], item[3]=="",
                             None, None, {})
        cj.set_cookie(c)

    return cj

def fetch(url, post=None, cj=None):
    """
    Fetch pretending to be firefox.
    """
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
    headers =  {'User-agent' : 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT)'}
    data = post and urllib.urlencode(post) or None
    req = urllib2.Request(url, data, headers)    # create a request object
    handle = opener.open(req)                       # and open it to return a handle on the url

    return handle.read()

def crawl(url, link_path, article_path, toc_path=None, firefox_dir=None, skip=None, wrap=str, cj=None):
    soup = BS(wrap(fetch(url, cj=cj)))
    title = soup.title
    toc = soup.select(toc_path or article_path).pop()

    urls = []
    pages = [toc]

    for h in pages[0].select(link_path):
        link = h.attrs["href"].split("#")[0]

        if link not in urls and (not skip or not skip(link)):
            print "Downloading from", link
            urls.append(link)
            html = wrap(fetch(link, cj=cj).decode('utf8'))
            article = BS(html).select(article_path)

            if article:
                pages.append(article[0])
            else:
                print "No article found in", link

    return title.text.encode("utf8"), pages

# machine learning clojure book

def subst(text, str1, str2):
    return text.replace(str1, str2)

# http://www.safariflow.com/library/view/clojure-for-machine/9781783284351/
def safariflow_pages(url):
    cj = ff_cookiejar("www.safariflow.com")
    title, pages = crawl(url,
                         link_path=".t-chapter",
                         article_path="#sbo-rt-content",
                         toc_path=".detail-toc", cj=cj,
                         wrap=lambda html: html.replace('/library/', 'http://www.safariflow.com/library/'))

    top = u"<html> <head><title>" + title + u"</title></head><body>"
    # We already get table of contents from the crawl ;)
    mid = u"\n<!-- SPLIT -->\n".join(map(lambda t: t.prettify(), pages[1:]))
    bottom = u"</body></html>"

    return top + mid + bottom

# UX article
def ux_pages():
    if not hasattr(ux_pages, "ret"):
        ux_pages.title, ux_pages.ret = crawl("http://thehipperelement.com/post/75476711614/ux-crash-course-31-fundamentals",
                                             "a", ".post", skip=lambda l: not l.startswith("http://thehipperelement.com/"))

    return ux_pages.ret

def ux_book():
    # Get from: http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000765211
    # pandoc -s ux.html --normalize ux.pdf
    # kindlegen ux.pdf
    body = u"\n<!-- SPLIT -->\n".join(map(lambda t: t.prettify(), ux_pages())).encode('utf8')
    open("./ux.html", "w+").write(body)

def safariflow_book(safariflow_book_url, html_out_fname):
    open(html_out_fname, "w+").write(safariflow_pages(safariflow_book_url).encode("utf-8"))

if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print "Download a book into a single html file"
        print "Usage: %s book_url ouptut_html_file" % sys.argv[0]

    safariflow_book(sys.argv[1], sys.argv[2])
    print "Ten run something like (pandoc is to pull the images correctly)"
    print "\tpandoc %s --normal --smart -o %s" % (sys.argv[2], sys.argv[2].replace(".html", ".epub"))
    print "\tebook-convert %s %s" % (sys.argv[2].replace(".html", ".epub"), sys.argv[2].replace(".html", ".mobi"))
    print "You will need calibre for that"
