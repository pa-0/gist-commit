#Python 3.4

import random
import string
import time
from pastebin import PastebinAPI
x = PastebinAPI()


DEV_KEY1 = '475b38cdfbba7a92d8bde6c56adfb241' #primary key
DEV_KEY2 = 'c0e51096a9e615d73537f34b6fd4abfa' #backup key 1
DEV_KEY3 = '' #backup key 2

paste_code = '' #title 
paste_code2 = '' #paste text

MAX_PASTES = 1 #max pastes

i = 0
while i <= MAX_PASTES:
    try:
        url = x.paste(DEV_KEY1,paste_code,paste_name = paste_code2,paste_private = 'public')
    except:
        try:
            url = x.paste(DEV_KEY2,paste_code,paste_name = paste_code2,paste_private = 'public')
        except:
            try:
                url = x.paste(DEV_KEY3,paste_code,paste_name = paste_code2,paste_private = 'public')
            except:
                print("No More! Wait 24 hours")
                time.sleep(86500)
    print(url) #url to paste
    MAX_PASTES+=1