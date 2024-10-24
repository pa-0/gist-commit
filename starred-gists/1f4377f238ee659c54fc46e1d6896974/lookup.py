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
    
        
            
    



    

from crawler import crawler
from compute_rank import compute_rank
ig=crawler("https://www.google.co.in/",3)
index=ig[0]
print index
print "\n"
graph=ig[1]
print graph
print "\n"
ranks=compute_rank(graph)
print ranks
print "\n"
#print ranks["file:///C:/Users/RaushanRaj/Desktop/home.html"]
print lookup(index,'<html>')
#print "\n"
print get_multiword_urls(index,'<html>',ranks)
