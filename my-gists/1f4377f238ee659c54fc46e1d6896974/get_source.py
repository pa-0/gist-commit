import urllib
def get_source(url):
    try:
        sock=urllib.urlopen(url)
        pagesource=sock.read()
        return pagesource
    except:
        return ""
    

    
#print get_source("file:///C:/Users/RaushanRaj/Desktop/home.html")
