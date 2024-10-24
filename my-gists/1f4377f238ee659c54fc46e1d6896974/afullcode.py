import urllib

def crawler(seedurl,max_depth):
    tocrawl=[seedurl]
    crawled=[]
    index={}
    graph={}
    while tocrawl:
        url=tocrawl.pop()
        if url not in crawled and len(crawled)<=max_depth:
            indexcontent=get_source(url)
            graph[url]=get_all_links(indexcontent)
            add_page_to_index(index,url,indexcontent)
            union(tocrawl,get_all_links(indexcontent))
            crawled.append(url)
            
    return index,graph
    
    
    
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



def get_source(url):
    try:
        sock=urllib.urlopen(url)
        pagesource=sock.read()
        return pagesource
    except:
        return ""
        
        
        
def add_page_to_index(index,url,content):
    keywords=content.split()
    position=0
    for key in keywords:
        add_to_index(index,key,url,position)
        position=position+1



def add_to_index(index,key,url,position):
    if key in index:
        index[key].append([url,position])
    else:
        index[key]=[[url,position]]
        


def lookup(index,keyword):
    for e in index:
        if e==keyword:
            return index[keyword]



def lucky_search(index,keyword,ranks):
    urls=lookup(index,keyword)
    if urls:
        besturl=urls[0]
        for url in urls:
            if ranks[url[0]]>ranks[besturl[0]]:
                besturl=url
        return besturl
    else:
        return None


def ordered_search(index,keyword,ranks):
    ordered_urls=[]
    pages=lookup(index,keyword)
    if pages:
        return quick_sort(pages,ranks)
    else:
        return None


    
def quick_sort(pages,ranks):
    if not pages or len(pages)<=1:
        return pages
    else:
        pivot=ranks[pages[0][0]]
        worse=[]
        best=[]
        for links in pages[1:]:
            if ranks[links[0]]<=pivot:
                worse.append([links[0]])
            else:
                best.append([links[0]])
        return quick_sort(best,ranks)+[[pages[0][0]]]+quick_sort(worse,ranks)



def multiword_lookup(index,keywords,ranks):
    if not keywords:
        return []
    keyword=keywords.split()
    activepos=lookup(index,keyword[0])
    for key in keyword[1:]:
        newactivepos=[]
        nexturlpos=lookup(index,key)
        if nexturlpos:
            for pos in activepos:
                if [pos[0],pos[1]+1] in nexturlpos:
                    newactivepos.append([pos[0],pos[1]+1])
        activepos=newactivepos
    return quick_sort(activepos,ranks)



def get_multiword_urls(index,keywords,ranks):
    k=multiword_lookup(index,keywords,ranks)
    j=[]
    if k:
        for e in k:
            if e[0] not in j:
                j.append(e[0])
        return j
    
        
def compute_rank(graph):
    ranks={}
    d=0.8
    for url in graph:
        ranks[url]=1.0/len(graph)
    for i in range(0,10):
        newranks={}
        for page in graph:
            newrank=(1.0-d)/len(graph)
            for node in graph:
                if page in graph[node]:
                    newrank=newrank+ranks[node]*d/len(graph[node])
            newranks[page]=newrank
        ranks=newranks
    return ranks

def union(p,q):
    for e in q:
        if e not in p:
            p.append(e)
    return p






#to print the index of crawled pages call below function
#print crawler("http://python.org/",5)[0]
#also you can search any keyword by calling lookup functions.