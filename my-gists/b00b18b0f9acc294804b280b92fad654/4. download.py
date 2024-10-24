import requests
import shutil
import sys
from tqdm.auto import tqdm

from os import path
from sys import argv
import os, shutil
import errno
from zipfile import ZipFile, is_zipfile


# make an HTTP request within a context manager
def dl(_qtversion, _qtsubversion, _rootpath ):
	fullUrl = "https://download.qt.io/archive/qt/" + _qtversion + "/" + _qtsubversion + "/single/qt-everywhere-src-" + _qtsubversion + ".zip"
	print("Downloading source archive from " + fullUrl )
	dlPath = _rootpath +"/download"
	print("Download folder : " +  dlPath )
	fullFilePath = dlPath + "/qt-everywhere-src-" + _qtsubversion + ".zip"
	print("Downloaded file path : " +  fullFilePath )
	try:
		os.makedirs(dlPath)
	except OSError as e:
		if errno.EEXIST != e.errno:
			raise
	for filename in os.listdir(dlPath):
		file_path = os.path.join(dlPath, filename)
		try:
			if os.path.isfile(file_path) or os.path.islink(file_path):
				os.unlink(file_path)
			elif os.path.isdir(file_path):
				shutil.rmtree(file_path)
		except Exception as e:
			print('Failed to delete %s. Reason: %s' % (file_path, e))
			sys.exit(1)
			
	with requests.get(fullUrl, stream=True) as r:
		# check header to get content length, in bytes
		total_length = int(r.headers.get("Content-Length"))
    
		# implement progress bar via tqdm
		with tqdm.wrapattr(r.raw, "read", total=total_length, desc="")as raw:
			# save the output to a file
			with open(fullFilePath, 'wb')as output:
				shutil.copyfileobj(raw, output)
				
	if path.exists(fullFilePath):
		if is_zipfile(fullFilePath):
			print(fullFilePath + " is a valid ZIP file")
		else:
			print(fullFilePath + " is a NOT valid ZIP file")
			sys.exit(2)
		print("Extracting: " + fullFilePath)
		with ZipFile(fullFilePath,"r") as zip_ref:
			for file in tqdm(iterable=zip_ref.namelist(), total=len(zip_ref.namelist())):
				zip_ref.extract(member=file, path=_rootpath)
		sys.exit(0)		
	else:
		print("Cannot find:" + fullFilePath)
		sys.exit(3)
		
			
script, _qtversion, _qtsubversion, _rootpath = argv			
dl(_qtversion, _qtsubversion, _rootpath )