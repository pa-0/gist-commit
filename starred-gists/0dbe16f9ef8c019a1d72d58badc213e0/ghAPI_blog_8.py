from github import Github
import base64

g = Github('xyAAAXcXACZYBx2YybC1zAzCxAYxc1Cxyz2AByb2')

repo = g.get_repo('sandbox/gh_api')

contents = repo.get_contents('data/image.jpg')

rawdata = contents.decoded_content
decoded = base64.decodebytes(rawdata)

with open('image.jpg', 'wb') as f:
    f.write(decoded)