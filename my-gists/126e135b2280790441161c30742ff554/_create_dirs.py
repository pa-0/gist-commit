import os


if __name__ == '__main__':
  with open(r'_스캔 예정 리스트.txt', 'r', encoding='utf-8') as fp:
    for dir_name in fp.readlines():
      dir_name = dir_name.strip()

      dir_path = os.path.join(r'D:\Book Scan\_스캔 예정 리스트', dir_name)
      if os.path.exists(dir_path):
        continue

      print(dir_path)
      os.mkdir(dir_path)
