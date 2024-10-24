import os
from pathlib import Path

from PIL import Image


def rename_png_to_jpg(dirpath: str):
  for fullname in os.listdir(dirpath):
    src_path = os.path.join(dirpath, fullname)
    if os.path.isdir(src_path):
      rename_png_to_jpg(src_path)
      continue

    filepath = Path(src_path)
    ext = filepath.suffix.lower()
    if ext != '.png':
      continue

    with Image.open(src_path) as png:
      dst_path = os.path.join(dirpath, f'{filepath.stem}.jpg')
      png.save(dst_path, "JPEG")
      os.remove(src_path)


if __name__ == '__main__':
  rename_png_to_jpg(r'F:\Book Scan\MICRO SOFTWARE 2018 VOL.393')
