import sys
import subprocess

# implement pip as a subprocess:

subprocess.check_call([sys.executable, '-m', 'ensurepip', '--upgrade'])

subprocess.check_call([sys.executable, '-m', 'pip', 'install', 
'update'])


subprocess.check_call([sys.executable, '-m', 'pip', 'install', 
'requests'])

subprocess.check_call([sys.executable, '-m', 'pip', 'install', 
'tqdm'])
