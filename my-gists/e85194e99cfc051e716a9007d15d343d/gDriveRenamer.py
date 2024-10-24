import apiclient
import argparse
import httplib2
from oauth2client import tools
import oauth2client.client
import oauth2client.file
import operator
import re

flow = oauth2client.client.flow_from_clientsecrets('e:\client_secret.json', 'https://www.googleapis.com/auth/drive.metadata')
flow.user_agent = "batch renamer"
flags = argparse.ArgumentParser(parents=[tools.argparser]).parse_args()
credentials = tools.run_flow(flow, oauth2client.file.Storage('e:\creds.json'), flags)
http = credentials.authorize(httplib2.Http())
service = apiclient.discovery.build('drive', 'v3', http=http)
files_api = service.files()
results = files_api.list(fields="files(id, name)", q="'1w1fZgj_rDSqiV6qV2ZLRIAeiMrlMxwcD' in parents").execute()
items = results.get('files', [])
if not items:
	print 'No files found.'
else:
	print 'Files:'
	for item in items:
		print '{0} ({1})'.format(item['name'], item['id'])
items = filter(lambda single_item: re.match("Mom", single_item["name"]), items)
for cur_item in items:
	cur_item["name"] = cur_item["name"][: 3] + cur_item["name"][7 : 11] + cur_item["name"][5 : 7] + cur_item["name"][3 : 5] + cur_item["name"][11 :]
items = sorted(items, key=operator.itemgetter("name"))
for cur_item in items:
	updated_file = files_api.update(fileId=cur_item["id"], body={"name": cur_item["name"]}).execute()
	print '{} ({})'.format(updated_file['name'], updated_file['id'])
