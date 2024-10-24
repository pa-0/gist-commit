import os
from pathlib import Path


def rename_counter(dirpath: str, add_count: int):
  for fullname in os.listdir(dirpath):
    src_path = os.path.join(dirpath, fullname)
    if os.path.isdir(src_path):
      continue

    filepath = Path(src_path)
    filestem = filepath.stem.split('_')
    counter = int(filestem[-1]) + add_count
    filestem[-1] = f'{counter:03}'

    dst_path = os.path.join(dirpath, f'{"_".join(filestem)}.png')
    print(src_path)
    print(f'{dst_path}\n')
    os.rename(src_path, dst_path)


def rename_counter(dirpath: str, add_count: int):
  def _rename(dirpath_: str, add_count_: int):
    for fullname in os.listdir(dirpath_):
      src_path = os.path.join(dirpath_, fullname)
      if os.path.isdir(src_path):
        continue

      filepath = Path(src_path)
      filestem = filepath.stem.split('_')
      counter = int(filestem[-1]) + add_count_
      filestem[-1] = f'{counter:03}'

      dst_path = os.path.join(dirpath_, f'{"_".join(filestem)}.png')
      print(src_path)
      print(f'{dst_path}\n')
      os.rename(src_path, dst_path)

  _rename(dirpath, add_count=100 + add_count)
  _rename(dirpath, add_count=-100)


if __name__ == '__main__':
  dirpath = r'D:\Book Scan\0.scanning'
  rename_counter(dirpath, add_count=4)