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
          
    
        
    
        
#from crawler import crawler
#index=crawler("file:///C:/Users/RaushanRaj/Desktop/home.html",5)[0]
#print index
#print compute_rank(graph)
