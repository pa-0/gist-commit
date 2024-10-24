from union import union
from get_all_links import *
from indexing import *
from get_source import get_source
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


print crawler("http://python.org/",2)[0]

# have to use threading for indexing
        
        
            
