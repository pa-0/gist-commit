#!/usr/bin/env python2.7

from bs4 import BeautifulSoup as bs
import base64 as b64
import urllib
import os
import re
import unicodedata
import inspect

cssContainer = '<style type="text/css"><!--\n{0}\n-->\n</style>'
jsContainer = '<script type="text/javascript"><!--\n{0}\n-->\n</style>'
imgSrcContainer = r'data:image/{0};base64,{1}'
cssUriContainer = r'data:image/png;base64,{0}'
cssImgPattern = re.compile(r'''url\((["']?)(.+?\.png)\1\)''', flags=re.I)

def printpath(path):
	path, lengthList = terminalWidth(path)
	#print lengthList
	if sum(lengthList) > 76:
		total = 0
		for i in xrange(len(lengthList)-1, -1, -1):
			if total <= 73:
				total+=lengthList[i]
			else:
				cutoffset = i+2
				break
		path = u'...' + path[cutoffset:]
	print path

def terminalWidth(string, encoding='utf-8'):
	if str in inspect.getmro(string.__class__):
		string = string.decode(encoding)
	charWidthList = [2 if unicodedata.east_asian_width(i) in ('W', 'F') else 1
			for i in string ]
	return (string,charWidthList)

def get_encoding(soup):
	encod = soup.meta.get('charset')
	if encod == None:
		encod = soup.meta.get('content-type')
		if encod == None:
			content = soup.meta.get('content')
			match = re.search('charset=(.*)', content)
			if match:
				encod = match.group(1)
			else:
				encod = 'utf-8'
	return encod

def embedCSS(soup, rootpath, encoding):
	for e in soup(['style', 'link']):
		try:
			if e.name == 'style':
				if e['type'] == 'text/css':
					path = os.path.join(
							rootpath,urllib.unquote(e['src'].encode(encoding)))
					del e['src']
					#e.extract()
				else:
					continue
			elif e.name == 'link':
				if 'stylesheet' in e.get('rel', '') or \
					e.get('type', '') == 'text/css':
					path = os.path.join(
							rootpath, urllib.unquote(e['href'].encode(encoding)))
					del e['href']
					#e.extract()
				else:
					continue
		except KeyError:
			continue
		try:
			cssrootpath = os.path.dirname(path)
			csslines = []
			with open(path) as cssf:
				for line in cssf:
					while True:
						urlpattern = cssImgPattern.search(line)
						if urlpattern is None:
							break
						s, e = urlpattern.regs[2]
						pngpath = os.path.join(cssrootpath,urlpattern.group(2))
						try:
							pngdata = cssUriContainer.format(
									b64.b64encode(open(pngpath, 'rb').read()))
						except IOError:
							pngdata = ''
						line = line[:s] + pngdata + line[e:]
					csslines.append(line)
			printpath(path)
			soup.head.append(bs(cssContainer.format(''.join(csslines))).style)
		except IOError:
			continue


def embedJS(soup, rootpath, encoding):
	for e in soup('script'):
		try:
			path = os.path.join(
					rootpath, urllib.unquote(e['src'].encode(encoding)))
			del e['src']
			#e.extract()
		except KeyError:
			continue
		try:
			soup.head.append(
					bs(jsContainer.format(open(path, 'rb').read())).script)
			printpath(path)
		except IOError:
			continue

def embedImage(soup, rootpath, encoding):
	for img in soup.body.findAll('img'):
		imgpath = urllib.unquote(img['src'].encode(encoding))
		imgpath = os.path.join(rootpath, imgpath)
		imgtype = os.path.splitext(imgpath)[1].lstrip('.')
		try:
			imgb64data = b64.b64encode(open(imgpath, 'rb').read())
		except IOError:
			pass
		else:
			img['src'] = imgSrcContainer.format(imgtype, imgb64data)
			printpath(imgpath)

def main(pathOfFile):
	filename, fileext = os.path.splitext(pathOfFile)
	rootpath = os.path.dirname(pathOfFile)
	soup = bs(open(pathOfFile, 'rb').read())
	encoding = get_encoding(soup).lower()
	embedCSS(soup, rootpath, encoding)
	#print soup.body
	embedJS(soup, rootpath, encoding)
	embedImage(soup, rootpath, encoding)
	open(filename+'_single_'+fileext, 'wb').write(soup.prettify(encoding))

if __name__ == '__main__':
	import sys
	htmlfile = sys.argv[1]
	main(htmlfile)
