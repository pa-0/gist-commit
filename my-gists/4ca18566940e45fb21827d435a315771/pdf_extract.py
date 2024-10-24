#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python311 python311Packages.pypdf

import sys
from pypdf import PdfReader

def extract_subpdfs():
    for filename in sys.argv[1:]:
        print("Extracting " + filename)
        root_doc = PdfReader(open(filename, "rb"))
        
        for name, doc in root_doc.attachments.items():
            print ("  Found " + name)
            doc_bytes = doc[0]
            with open(name, "wb") as fw:
                fw.write(doc_bytes)

if __name__ == "__main__":
    extract_subpdfs()
