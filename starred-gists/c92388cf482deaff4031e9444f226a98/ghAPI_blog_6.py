from github import Github

g = Github('xyAAAXcXACZYBx2YybC1zAzCxAYxc1Cxyz2AByb2')

repo = g.get_repo('sandbox/gh_api')

contents = repo.get_contents('data/dataset.csv')

decoded = contents.decoded_content

with open('dataset.csv', 'wb') as f:
    f.write(decoded)
