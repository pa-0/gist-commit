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

