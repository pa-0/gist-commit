def union(p,q):
    for e in q:
        if e not in p:
            p.append(e)
    return p



#print union([1,2,3],[1,2,2,2,2,5,6,7])