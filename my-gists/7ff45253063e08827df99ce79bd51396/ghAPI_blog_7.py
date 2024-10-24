from github import Github
import base64

g = Github('xyAAAXcXACZYBx2YybC1zAzCxAYxc1Cxyz2AByb2')

repo = g.get_repo('sandbox/gh_api')

with open('image.jpg', "rb") as f:
    bytes = f.read()
    b64_data = base64.b64encode(bytes)

repo.create_file('image.jpg', 'upload image', b64_data)