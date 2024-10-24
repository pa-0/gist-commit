import sys

def success():
  print("==> Exiting with standard success exit code")
  return None

def failure():
  print("==> Exiting with standard failure exit code")    # Syntax Error
  return None

if __name__ == "__main__":
  
  method_name = sys.argv[1]
  
  if method_name == 'success':
    success()
  else:
    failure()