# pandoc-webpage.py
# Requires: pyandoc http://pypi.python.org/pypi/pyandoc/
# (Change path to pandoc binary in core.py before installing package)
# TODO: Iterate over a list of webpages
# TODO: Clean up HTML by removing hard linebreaks
# TODO: Delete header and footer

import urllib2
import pandoc

# Open the desired webpage
url = 'http://mcdaniel.blogs.rice.edu/?p=158'
response = urllib2.urlopen(url)
webContent = response.read()

# Call on pandoc to convert webContent to markdown and write to file
doc = pandoc.Document()
doc.html = webContent
webConverted = doc.markdown

f = open('wendell-phillips.txt','w')
f.write(webConverted)
f.close()
