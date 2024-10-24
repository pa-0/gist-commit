def get_next_target(content):
    start_link=content.find('<a href=')
    if start_link==-1:
        return None,0
    start_quote=content.find('"',start_link)
    end_quote=content.find('"',start_quote+1)
    url=content[start_quote+1:end_quote]
    return url,end_quote



def get_all_links(content):
    links=[]
    while True:
        url,end_quote=get_next_target(content)
        if url:
            links.append(url)
            content=content[end_quote:]
        else:
            break
    return links



            
    

#from get_source import get_source
#print get_all_links(get_source(("file:///C:/Users/RaushanRaj/Desktop/home.html")))



